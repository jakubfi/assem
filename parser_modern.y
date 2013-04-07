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

#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include "ops.h"
#include "elements.h"
#include "eval.h"


void m_yyerror(char *s, ...);
int yylex(void);
int got_error;
%}

%locations

%union {
	struct val_t {
		int v;
		char *s;
	} val;
	struct norm_t *norm;
	struct node_t *node;
	struct nodelist_t *nl;
};

%token '[' ']' ',' ':'
%token MP_DATA MP_EQU MP_RES MP_SEG MP_FINSEG MP_MACRO MP_FINMACRO
%token <val.s> MP_PROG MP_FINPROG
%token <val.s> NAME STRING CMT_CODE CMT_LINE
%token <val> VALUE ADDR
%token <val.v> REGISTER
%token <val.v> MOP_2ARG MOP_FD MOP_KA1 MOP_JS MOP_KA2 MOP_C MOP_SHC MOP_S MOP_HLT MOP_J MOP_L MOP_G MOP_BN

%type <norm> normval norm
%type <node> instruction expr comment
%type <nl> res words data dataword comments code sentence sentences

%left '+' '-'
%left SHR SHL
%nonassoc UMINUS


%%

program:
	comments MP_PROG STRING sentences MP_FINPROG comments { 
		printf("Assembling program '%s'\n", $3);
		program = nl_append_n(program, make_prog($2, $3));
		program = nl_append(program, $1);
		program = nl_append(program, $4);
		program = nl_append(program, $6);
		program = nl_append_n(program, make_finprog($5));
		free($2);
		free($3);
	}
	| comments MP_PROG sentences MP_FINPROG	comments {
		printf("Assembling unnamed program\n");
		program = nl_append_n(program, make_prog($2, ""));
		program = nl_append(program, $1);
		program = nl_append(program, $3);
		program = nl_append(program, $5);
		program = nl_append_n(program, make_finprog($4));
		free($2);
	}
	;

sentences:
	sentences sentence { $$ = nl_append($1, $2); }
	| { $$ = NULL; }
	;

sentence:
	code			{ $$ = $1; }
	| code CMT_CODE	{ make_code_comment($1, $2); }
	| comment		{ $$ = make_nl($1); }
	;

code:
	words				{ $$ = $1; }
	| MP_EQU NAME expr	{ $$ = make_nl(make_equ($2, $3)); }
	| NAME ':'			{ $$ = make_nl(make_label($1)); }
	;

comments:
	comments comment	{ $$ = nl_append_n($1, $2); }
	|					{ $$ = NULL; }
	;

comment:
	CMT_LINE		{ $$ = make_comment($1); }
	;

words:
	instruction		{ $$ = make_nl($1); program_ic++; }
	| MP_DATA data	{ $$ = $2; }
	| res			{ $$ = $1; }
	;

data:
	dataword			{ $$ = $1; }
	| dataword ',' data	{ $$ = nl_append($1, $3); }
	;

dataword:
	expr		{ $$ = make_nl($1); program_ic++; }
	| STRING	{ $$ = make_string($1); program_ic += strlen($1); }
	;

res:
	MP_RES VALUE				{ $$ = make_rep($2.v, 0, NULL); program_ic += $2.v; }
	| MP_RES VALUE ',' VALUE	{ $$ = make_rep($2.v, $4.v, $4.s); program_ic += $2.v; }
	;

instruction:
	MOP_2ARG REGISTER ',' norm	{ $$ = make_op(N_2ARG,	$1, $2, NULL, $4); }
	| MOP_FD norm				{ $$ = make_op(N_FD,	$1, 0,  NULL, $2); }
	| MOP_KA1 REGISTER ',' expr	{ $$ = make_op(N_KA1,	$1, $2, $4,   NULL); }
	| MOP_JS expr				{ $$ = make_op(N_JS,	$1, 0,  $2,   NULL); }
	| MOP_KA2 expr				{ $$ = make_op(N_KA2,	$1, 0,  $2,   NULL); }
	| MOP_C REGISTER			{ $$ = make_op(N_C,		$1, $2, NULL, NULL); }
	| MOP_SHC REGISTER ',' expr	{ $$ = make_op(N_SHC,	$1, $2, $4,   NULL); }
	| MOP_S						{ $$ = make_op(N_S,		$1, 0,  NULL, NULL); }
	| MOP_HLT expr				{ $$ = make_op(N_HLT,	$1, 0,  $2,   NULL); }
	| MOP_J norm				{ $$ = make_op(N_J,		$1, 0,  NULL, $2); }
	| MOP_L norm				{ $$ = make_op(N_L,		$1, 0,  NULL, $2); }
	| MOP_G norm				{ $$ = make_op(N_G,		$1, 0,  NULL, $2); }
	| MOP_BN norm				{ $$ = make_op(N_BN,	$1, 0,  NULL, $2); }
	;

norm:
	normval					{ $$ = $1; }
	| '[' normval ']'		{ $$ = $2; $$->d = 1; }
	;

normval:
	REGISTER				{ $$ = make_norm($1, 0, NULL); }
	| expr					{ $$ = make_norm(0, 0, $1); program_ic++; }
	| REGISTER '+' REGISTER	{ $$ = make_norm($1, $3, NULL); }
	| REGISTER '+' expr		{ $$ = make_norm(0, $1, $3); program_ic++; }
	| REGISTER '-' expr		{ $$ = make_norm(0, $1, make_oper(N_UMINUS, $3, NULL)); program_ic++; }
	| expr '+' REGISTER		{ $$ = make_norm(0, $3, $1); program_ic++; }
	;

expr:
	VALUE					{ $$ = make_value($1.v, $1.s); }
	| NAME					{ $$ = make_name($1); }
	| expr '+' expr			{ $$ = make_oper(N_PLUS, $1, $3); }
	| expr '-' expr			{ $$ = make_oper(N_MINUS, $1, $3); }
	| '-' expr %prec UMINUS	{ $$ = make_oper(N_UMINUS, $2, NULL); }
	| '(' expr ')'			{ $$ = $2; }
	| expr SHL expr			{ $$ = make_oper(N_SHL, $1, $3); }
	| expr SHR expr			{ $$ = make_oper(N_SHR, $1, $3); }
	;

%%

// -----------------------------------------------------------------------
void m_yyerror(char *s, ...)
{
	va_list ap;
	va_start(ap, s);
	printf("Error parsing source, line %d: ", m_yylloc.first_line);
	vprintf(s, ap);
	printf("\n");
	va_end(ap);
	got_error = 1;
}

// vim: tabstop=4
