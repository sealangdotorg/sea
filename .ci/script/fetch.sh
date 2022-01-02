#!/bin/bash
#
#   Copyright (C) 2014-2022 CASM Organization <https://casm-lang.org>
#   All rights reserved.
#
#   Developed by: Philipp Paulweber et al.
#                 <https://github.com/casm-lang/casm/graphs/contributors>
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

set -e

# print 'in'
ls -lA $IN

# modules
if [ -n "$MODS" ]; then
    echo "info: fetch sub-modules '$MODS'"
    git -C $IN/$REPO submodule update --init $MODS
fi

# libraries
if [ -n "$LIBS" ]; then
    if [ -z "$DEPS" ]; then
	DEPS=$IN
    fi

    echo "info: fetch libraries '$LIBS' to '$DEPS'"
    cnt=1
    for i in $LIBS; do
	cp -rf lib$cnt $DEPS/$i
	cnt=$((cnt + 1))
    done
fi

# print 'git' repository and sub-module information
(cd $IN/$REPO; \
 printf "%s %-20s %-10s %-25s %s\n" \
	"--" \
	"Repository" \
	`git rev-parse --short HEAD` \
	`git describe --tags --always --dirty` \
	`git branch | grep -e "\* " | sed "s/* //g"`; \
 git submodule foreach \
	 'printf "   %-20s %-10s %-25s %s\n" \
	 $path \
	 `git rev-parse --short HEAD` \
	 `git describe --tags --always --dirty` \
	 `git branch | grep -e "\* " | sed "s/* //g"`' | sed '/Entering/d' \
)

# copy 'in' to 'out'
cp -rf $IN/* $OUT/

# print 'out'
ls -lA $OUT
