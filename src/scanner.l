%{
//  Copyright (c) 2012-2013 Jakub Filipowicz <jakubf@gmail.com>
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation; either version 2 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "keywords.h"
#include "parser.h"
#include "elements.h"

void yyerror(char *, ...);
char comment_buf[1024];
int comment_pos;
extern int parser_lineno;

#define YY_USER_ACTION	parser_lineno = yylineno;

%}

%option nounput
%option noinput
%option yylineno
%s is_id in_comment

ws				[ \t]
nl				[\n\r\f]+
comment_output	\<.*\>
name			[a-zA-Z]+
pragma			[a-zA-Z]+\*
identifier		[@#%a-zA-Z][a-zA-Z0-9]*
suffix_op		[,\(]
dec				[0-9]+
oct				0[0-7]+
dchar			!..
r40				\$[A-Z0-9\ _%#]{1,3}
bitmask			\?[ZMVCLEGYX1234567]{1,16}
sfloat			[0-9]*\.[0-9]+
string			\".+\"
chars			[-+/=:,\(&'\*]
echars			[\)\.]

%%

<INITIAL,is_id>{nl}	{ yylval.val.s = strdup("\n"); return NL; }

<INITIAL,is_id>\[ { BEGIN(in_comment); comment_pos = 0; }
<in_comment>{
[^\]\n]+	{ comment_pos += sprintf(comment_buf+comment_pos, "%s", yytext); }
\n			{ comment_pos += sprintf(comment_buf+comment_pos, "%s", yytext); }
\]			{ BEGIN(INITIAL); yylval.val.s = strdup(comment_buf); return CMT; }
}
{comment_output} {
	yylval.val.s = strdup(yytext);
	return CMT;
}

{oct} {
	yylval.val.v = strtol(yytext, NULL, 8);
	yylval.val.s = strdup(yytext);
	return VALUE;
}
{dec} {
	yylval.val.v = strtol(yytext, NULL, 10);
	yylval.val.s = strdup(yytext);
	return VALUE;
}
{dchar} {
	yylval.val.v = 0;
	if (yytext[1] != '!')	yylval.val.v += yytext[1]*256;
	if (yytext[2] != '!')	yylval.val.v += yytext[2];
	yylval.val.s = strdup(yytext);
	return VALUE;
}
{r40} {
	int val = 0;
	int mul = 1600;
	char *s = yytext+1;
	yylval.val.v = 0;
	while (*s) {
		if ((*s >= 'A') && (*s <= 'Z')) {
			val = *s - 64;
		} else if ((*s >= 'a') && (*s <= 'z')) {
			val = *s - 96;
		} else if ((*s >= '0') && (*s <= '9')) {
			val = *s - 21;
		} else if (*s == ' ') {
			val = 0;
		} else if (*s == '_') {
			val = 37;
		} else if (*s == '%') {
			val = 38;
		} else if (*s == '#') {
			val = 39;
		} else {
			yyerror("wrong R-40 code: %s", yytext);
			return YERR;
		}
		yylval.val.v += val*mul;
		mul /= 40;
		s++;
	}
	yylval.val.s = strdup(yytext);
	return VALUE;
}
{bitmask} {
	int value = 0;
	char *c = yytext+1;
	while (*c) {
		switch (*c) {
			case 'Z': value |= 1 << 15; break;
			case 'M': value |= 1 << 14; break;
			case 'V': value |= 1 << 13; break;
			case 'C': value |= 1 << 12; break;
			case 'L': value |= 1 << 11; break;
			case 'E': value |= 1 << 10; break;
			case 'G': value |= 1 << 9; break;
			case 'Y': value |= 1 << 8; break;
			case 'X': value |= 1 << 7; break;
			case '1': value |= 1 << 6; break;
			case '2': value |= 1 << 5; break;
			case '3': value |= 1 << 4; break;
			case '4': value |= 1 << 3; break;
			case '5': value |= 1 << 2; break;
			case '6': value |= 1 << 1; break;
			case '7': value |= 1 << 0; break;
			default:
				yyerror("Unknown bit in bitmask: %c", *c);
				break;
		}
		c++;
	}
	yylval.val.v = value;
	yylval.val.s = strdup(yytext);
	return VALUE;
}
{string} {
	yylval.val.s = strndup(yytext+1, strlen(yytext)-2);
	return STRING;
}

{chars} { return *yytext; }
{echars} { BEGIN(INITIAL); return *yytext; }

<is_id>{name} {
	int copy = 7;
	if (isalpha(*yytext)) copy = 6;
	yylval.val.s = strndup(yytext, copy);
	return IDENTIFIER;
}

{name}/{suffix_op} {
	struct kw_t *op = get_op(mnemo_sel, yytext);
	if (op) {
		BEGIN(is_id);
		yylval.val.v = op->opcode;
		return op->type;
	} else {
		yylval.val.s = strndup(yytext, 6);
		return IDENTIFIER;
	}
}

{pragma} {
	BEGIN(is_id);
	struct kw_t *pragma = get_pragma(1, yytext);
	if (!pragma) {
		yyerror("unknown pragma: %s", yytext);
	} else {
		return pragma->type;
	}
}

{identifier}/: {
	int copy = 7;
	if (isalpha(*yytext)) copy = 6;
	yylval.val.s = strndup(yytext, copy);
	return LABEL;
}

{identifier}/= {
	int copy = 7;
	if (isalpha(*yytext)) copy = 6;
	yylval.val.s = strndup(yytext, copy);
	return VAR;
}

{identifier} {
	int copy = 7;
	if (isalpha(*yytext)) copy = 6;
	yylval.val.s = strndup(yytext, copy);
	return IDENTIFIER;
}

{ws} ;
. {  }

%%

int yywrap(void) {
	return 1;
}

// vim: tabstop=4
