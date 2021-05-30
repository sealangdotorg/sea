rem
rem Copyright (C) 2014-2020 CASM Organization <https://casm-lang.org>
rem All rights reserved.
rem
rem Developed by: Philipp Paulweber
rem               Emmanuel Pescosta
rem               <https://github.com/casm-lang/casm>
rem
rem This file is part of casm.
rem
rem casm is free software: you can redistribute it and/or modify
rem it under the terms of the GNU General Public License as published by
rem the Free Software Foundation, either version 3 of the License, or
rem (at your option) any later version.
rem
rem casm is distributed in the hope that it will be useful,
rem but WITHOUT ANY WARRANTY; without even the implied warranty of
rem MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
rem GNU General Public License for more details.
rem
rem You should have received a copy of the GNU General Public License
rem along with casm. If not, see <http://www.gnu.org/licenses/>.
rem

make --no-print-directory -C app/casmf test

make --no-print-directory -C app/casmi test
