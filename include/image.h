//  Copyright (c) 2013 Jakub Filipowicz <jakubf@gmail.com>
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

#ifndef IMAGE_H
#define IMAGE_H

#include <inttypes.h>

int img_write();
int img_next_sector(int new_ic);
int img_get_sector();
int img_get_ic();
int img_get_filepos();
int img_set_ic(int new_ic);
int img_inc_ic();
int img_put_at(int addr, int orig_ic, uint16_t word);
int img_put(uint16_t word);


#endif

// vim: tabstop=4

