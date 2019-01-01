#!/bin/bash
#
#   Copyright (C) 2014-2019 CASM Organization <https://casm-lang.org>
#   All rights reserved.
#
#   Developed by: Philipp Paulweber
#                 Emmanuel Pescosta
#                 <https://github.com/casm-lang/casm>
#
#   This file is part of casm.
#
#   casm is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   casm is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with casm. If not, see <http://www.gnu.org/licenses/>.
#

if [ -z "$IN" ]; then
    echo "error: environment variable 'IN' is not set!"
    exit -1
fi

if [ -z "$OUT" ]; then
    echo "error: environment variable 'OUT' is not set!"
    exit -1
fi

if [ -z "$REPO" ]; then
    echo "error: environment variable 'REPO' is not set!"
    exit -1
fi

set -e -x
date
uname -a

mkdir /tmp/ci

mv `pwd`/$IN/* /tmp/ci

(cd /tmp/ci/$REPO; make $ARGS)

cp -rf /tmp/ci/* $OUT/

mv /tmp/ci/* `pwd`/$IN
