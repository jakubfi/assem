#!/usr/bin/env python
# -*- coding: UTF-8 -*-

#  Copyright (c) 2014 Jakub Filipowicz <jakubf@gmail.com>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc.,
#  51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

import sys
import re

if len(sys.argv) != 2 or len(sys.argv[1]) != 7:
    print "Usage: %s <reg_symbols>" % sys.argv[0]
    print "Where <reg_symbols> is a string of 7 letters which are names for registers r1..r7"

regs = sys.argv[1]
regmap = { regs[i]:i+1 for i in range(0, 7) }

delims = re.escape("',&().")
rec = re.compile(r'([%s])([%s])([%s])' % (delims, regs, delims))

for line in sys.stdin:
    while 1:
        found = rec.search(line)
        if not found:
            break
        if len(found.groups()) != 3:
            print "Something's fishy here: " + str(found)
            sys.exit(1)
        match = re.escape(found.group())
        repl = "%s%s%s" % (found.group(1), regmap[found.group(2)], found.group(3))
        line = re.sub(match, repl, line)
    print line,

