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

#ifndef OPS_H
#define OPS_H

#include <inttypes.h>

enum _mnemo_e {
	MNEMO_MERA400 = 0,
	MNEMO_K202 = 1
};

enum _optype_e {
	O_2ARG = 0,
	O_FD,
	O_KA1,
	O_JS,
	O_KA2,
	O_C,
	O_SHC,
	O_HLT,
	O_S,
	O_J,
	O_L,
	O_G,
	O_BN,
	O_DATA
};

struct op_t {
	char *mnemo[2];
	int type;
	uint16_t opcode;
};

extern struct op_t ops[];
extern int mnemo_sel;

struct op_t * get_op(char *opname);

#endif

// vim: tabstop=4
