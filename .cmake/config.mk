#
#   Copyright (C) 2014-2021 CASM Organization <https://casm-lang.org>
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

ifndef TARGET
  $(error TARGET not defined!)
endif

OBJ = obj
BIN = install
.PHONY: $(OBJ)
.NOTPARALLEL: $(OBJ)

ifneq (,$(findstring sh,$(SHELL)))
ENV_SHELL := sh
WHICH := which
DEVNUL := /dev/null
endif
ifneq (,$(findstring cmd,$(SHELL)))
ENV_SHELL := cmd
WHICH := where
DEVNUL := NUL
endif
ifeq ($(ENV_SHELL),)
  $(error environment shell '$(ENV_SHELL)' not supported!)
endif

ifeq ($(shell ${WHICH} uname 2>${DEVNUL}),)
  $(error "'uname' is not in your system PATH")
endif
ifeq ($(shell ${WHICH} cmake 2>${DEVNUL}),)
  $(error "'cmake' is not in your system PATH")
endif

ENV_ARCH := $(shell uname -m)
# x86_64
# i686
ifneq ($(ENV_ARCH),x86_64)
ifneq ($(ENV_ARCH),i686)
  $(error environment architecture '$(ENV_ARCH)' not supported!)
endif
endif

ENV_PLAT := "$(shell uname -a)"
ifneq (,$(findstring Linux,$(ENV_PLAT)))
  ENV_OSYS := Linux
endif
ifneq (,$(findstring Darwin,$(ENV_PLAT)))
  ENV_OSYS := Mac
  $(eval ENV_PLAT="$(shell uname -vns | sed 's/; / /g' | sed 's/: / /g' | sed 's/Darwin Kernel Version//g')")
endif
ifneq (,$(findstring MSYS,$(ENV_PLAT)))
  ENV_OSYS := Windows
  $(eval ENV_PLAT="$(shell uname -vnsmo)")
endif
ifneq (,$(findstring MINGW,$(ENV_PLAT)))
  ENV_OSYS := Windows
  $(eval ENV_PLAT="$(shell uname -vnsmo)")
endif
ifneq (,$(findstring CYGWIN,$(ENV_PLAT)))
  ENV_OSYS := Windows
  $(eval ENV_PLAT="$(shell uname -vnsmo)")
endif
ifeq ($(ENV_OSYS),)
  $(error environment OS '$(ENV_PLAT)' not supported!)
endif

ifeq ($(ENV_OSYS),Linux)
  ENV_CPUM := $(shell cat /proc/cpuinfo | grep -e "model name" | sed "s/model name.*: //g" | head -n1 )
endif
ifeq ($(ENV_OSYS),Mac)
  ENV_CPUM := $(shell sysctl -n machdep.cpu.brand_string )
endif
ifeq ($(ENV_OSYS),Windows)
  ENV_CPUM := $(shell wmic CPU get NAME | head -n2 | tail -n1 )
endif

CLANG := $(shell ${WHICH} clang 2>${DEVNUL})
GCC := $(shell gcc --version 2>${DEVNUL})

ifdef C
  ifeq ($(C),clang)
    ENV_CC=clang
    ENV_CXX=clang++
  endif
  ifeq ($(C),gcc)
    ENV_CC=gcc
    ENV_CXX=g++
  endif
  ifeq ($(C),msvc)
    ENV_CC=msvc
    ENV_CXX=msvc
  endif
  ifeq ($(C),emcc)
    ENV_CC=emcc
    ENV_CXX=em++
  endif
else
  ifdef CLANG
    ENV_CC=clang
    ENV_CXX=clang++
  else
    ifdef GCC
      ENV_CC=gcc
      ENV_CXX=g++
    endif
  endif
endif

ifeq ($(ENV_CC),)
  $(error environment C compiler '$(C)' not defined!)
endif

ifeq ($(ENV_CXX),)
  $(error environment C++ compiler '$(X)' not defined!)
endif

ifndef LTO
  LTO=0
endif


ifdef ENV_GEN
  G=$(ENV_GEN)
endif

ifndef G
  G=make
endif

# Unix Makefiles
ifeq ($(G),make)
  $(eval ENV_GEN="Unix Makefiles")
endif
ifeq ($(G),make-cb)
  $(eval ENV_GEN="CodeBlocks - Unix Makefiles")
endif
ifeq ($(G),make-cl)
  $(eval ENV_GEN="CodeLite - Unix Makefiles")
endif
ifeq ($(G),make-s2)
  $(eval ENV_GEN="Sublime Text 2 - Unix Makefiles")
endif
ifeq ($(G),make-kp)
  $(eval ENV_GEN="Kate - Unix Makefiles")
endif
ifeq ($(G),make-e4)
  $(eval ENV_GEN="Eclipse CDT4 - Unix Makefiles")
endif

# MinGW Makefiles
ifeq ($(G),make-gw)
  $(eval ENV_GEN="MinGW Makefiles")
endif
ifeq ($(G),make-gw-cb)
  $(eval ENV_GEN="CodeBlocks - MinGW Makefiles")
endif
ifeq ($(G),make-gw-cl)
  $(eval ENV_GEN="CodeLite - MinGW Makefiles")
endif
ifeq ($(G),make-gw-s2)
  $(eval ENV_GEN="Sublime Text 2 - MinGW Makefiles")
endif
ifeq ($(G),make-gw-kp)
  $(eval ENV_GEN="Kate - MinGW Makefiles")
endif
ifeq ($(G),make-gw-e4)
  $(eval ENV_GEN="Eclipse CDT4 - MinGW Makefiles")
endif

# Msys Makefiles
ifeq ($(G),make-ms)
  $(eval ENV_GEN="MSYS Makefiles")
endif

# Watcom Makefiles
ifeq ($(G),make-wc)
  $(eval ENV_GEN="Watcom WMake")
endif

# Borland Makefiles
ifeq ($(G),make-bl)
  $(eval ENV_GEN="Borland Makefiles")
endif

# NMake Makefiles
ifeq ($(G),make-nm)
  $(eval ENV_GEN="NMake Makefiles")
endif
ifeq ($(G),make-nm-cb)
  $(eval ENV_GEN="CodeBlocks - NMake Makefiles")
endif
ifeq ($(G),make-nm-cl)
  $(eval ENV_GEN="CodeLite - NMake Makefiles")
endif
ifeq ($(G),make-nm-s2)
  $(eval ENV_GEN="Sublime Text 2 - NMake Makefiles")
endif
ifeq ($(G),make-nm-kp)
  $(eval ENV_GEN="Kate - NMake Makefiles")
endif
ifeq ($(G),make-nm-e4)
  $(eval ENV_GEN="Eclipse CDT4 - NMake Makefiles")
endif
ifeq ($(G),make-nj)
  $(eval ENV_GEN="NMake Makefiles JOM")
endif
ifeq ($(G),make-nj-cb)
  $(eval ENV_GEN="CodeBlocks - NMake Makefiles JOM")
endif

# Green Hills MULTI
ifeq ($(G),multi)
  $(eval ENV_GEN="Green Hills MULTI")
endif

# Ninja
ifeq ($(G),ninja)
  $(eval ENV_GEN="Ninja")
endif
ifeq ($(G),ninja-cb)
  $(eval ENV_GEN="CodeBlocks - Ninja")
endif
ifeq ($(G),ninja-cl)
  $(eval ENV_GEN="CodeLite - Ninja")
endif
ifeq ($(G),ninja-s2)
  $(eval ENV_GEN="Sublime Text 2 - Ninja")
endif
ifeq ($(G),ninja-kp)
  $(eval ENV_GEN="Kate - Ninja")
endif
ifeq ($(G),ninja-e4)
  $(eval ENV_GEN="Eclipse CDT4 - Ninja")
endif

# Visual Studio 2019 (Version 16)
ifeq ($(G),vs19)
  $(eval ENV_GEN="Visual Studio 16 2019")
endif
ifeq ($(G),vs19w64)
  $(eval ENV_GEN="Visual Studio 16 2019 Win64")
endif
ifeq ($(G),vs19arm)
  $(eval ENV_GEN="Visual Studio 16 2019 ARM")
endif

# Visual Studio 2017 (Version 15)
ifeq ($(G),vs17)
  $(eval ENV_GEN="Visual Studio 15 2017")
endif
ifeq ($(G),vs17w64)
  $(eval ENV_GEN="Visual Studio 15 2017 Win64")
endif
ifeq ($(G),vs17arm)
  $(eval ENV_GEN="Visual Studio 15 2017 ARM")
endif

# Visual Studio 2015 (Version 14)
ifeq ($(G),vs15)
  $(eval ENV_GEN="Visual Studio 14 2015")
endif
ifeq ($(G),vs15w64)
  $(eval ENV_GEN="Visual Studio 14 2015 Win64")
endif
ifeq ($(G),vs15arm)
  $(eval ENV_GEN="Visual Studio 14 2015 ARM")
endif

# Visual Studio 2013 (Version 12)
ifeq ($(G),vs13)
  $(eval ENV_GEN="Visual Studio 12 2013")
endif
ifeq ($(G),vs13w64)
  $(eval ENV_GEN="Visual Studio 12 2013 Win64")
endif
ifeq ($(G),vs13arm)
  $(eval ENV_GEN="Visual Studio 12 2013 ARM")
endif

# Visual Studio 2012 (Version 11)
ifeq ($(G),vs12)
  $(eval ENV_GEN="Visual Studio 11 2012")
endif
ifeq ($(G),vs12w64)
  $(eval ENV_GEN="Visual Studio 11 2012 Win64")
endif
ifeq ($(G),vs12arm)
  $(eval ENV_GEN="Visual Studio 11 2012 ARM")
endif

# Visual Studio 2010 (Version 10)
ifeq ($(G),vs10)
  $(eval ENV_GEN="Visual Studio 10 2010")
endif
ifeq ($(G),vs10w64)
  $(eval ENV_GEN="Visual Studio 10 2010 Win64")
endif
ifeq ($(G),vs10ia64)
  $(eval ENV_GEN="Visual Studio 10 2010 IA64")
endif

# Visual Studio 2008 (Version 10)
ifeq ($(G),vs08)
  $(eval ENV_GEN="Visual Studio 9 2008")
endif
ifeq ($(G),vs08w64)
  $(eval ENV_GEN="Visual Studio 9 2008 Win64")
endif
ifeq ($(G),vs08ia64)
  $(eval ENV_GEN="Visual Studio 9 2008 IA64")
endif

ifeq ($(ENV_GEN),)
  $(error environment generator '$(G)' not supported!, see 'make info-generators')
endif


ifdef ENV_INSTALL
  I=$(ENV_INSTALL)
endif

ifndef I
  I=$(BIN)
endif

ifeq ($(I),)
  $(eval ENV_INSTALL=$(BIN))
else
  $(eval ENV_INSTALL=$(I))
endif

ifeq ($(ENV_INSTALL),)
  $(error empty environment install path detected! $(I), $(ENV_INSTALL), $(BIN))
endif

ifeq ($(ENV_OSYS),Windows)
  ENV_SET := set
else
  ENV_SET := export
endif


default: debug

help:
	@echo "TODO"


$(OBJ):
ifeq ($(wildcard $(OBJ)),)
	@mkdir $(OBJ)
endif

clean:
ifneq ("$(wildcard $(OBJ)/CMakeCache.txt)","")
	@$(MAKE) $(MFLAGS) --no-print-directory -C $(OBJ) clean
endif

clean-all:
	@echo "-- Removing build directory" $(OBJ)
	@rm -rf $(OBJ)

TYPES = debug sanitize coverage release

SYNCS = $(TYPES:%=%-sync)
FETCH = $(TYPES:%=%-fetch)
DEPS  = $(TYPES:%=%-deps)
BUILD = $(TYPES:%=%-build)
TESTS = $(TYPES:%=%-test)
BENCH = $(TYPES:%=%-benchmark)
ANALY = $(TYPES:%=%-analyze)
INSTA = $(TYPES:%=%-install)
ALL   = $(TYPES:%=%-all)


ENV_CMAKE_FLAGS  = -G$(ENV_GEN)
ENV_CMAKE_FLAGS += -DCMAKE_BUILD_TYPE=$(TYPE)

ENV_CMAKE_CXX_FLAGS =
ifeq (,$(findstring Visual,$(ENV_GEN)))
  ifeq ($(ENV_OSYS),Windows)
    ENV_CMAKE_CXX_FLAGS += -Wa,-mbig-obj
  else
    ifeq ("$(TYPE)","release")
      ifeq ($(LTO),1)
        ENV_CMAKE_CXX_FLAGS += -flto
      endif
    endif
  endif
endif

ifeq (,$(findstring Visual,$(ENV_GEN)))
  ENV_CMAKE_FLAGS += -DCMAKE_C_COMPILER=$(ENV_CC)
  ENV_CMAKE_FLAGS += -DCMAKE_CXX_COMPILER=$(ENV_CXX)

  ifeq ("$(TYPE)","debug")
    ENV_CMAKE_FLAGS += -DCMAKE_CXX_FLAGS="-O0 -g\
      $(ENV_CMAKE_CXX_FLAGS)"
  endif

  ifeq ("$(TYPE)","release")
    ENV_CMAKE_FLAGS += -DCMAKE_CXX_FLAGS="-O3 -DNDEBUG\
      $(ENV_CMAKE_CXX_FLAGS)"
  endif

  ifeq ("$(TYPE)","sanitize")
    ENV_CMAKE_FLAGS += -DCMAKE_CXX_FLAGS="-O1 -g -Wall -Wextra\
      -fno-omit-frame-pointer\
      -fno-optimize-sibling-calls\
      -fsanitize=undefined\
      -fsanitize=address\
      $(ENV_CMAKE_CXX_FLAGS)"
  endif

  ifeq ("$(TYPE)","coverage")
    ENV_CMAKE_FLAGS += -DCMAKE_CXX_FLAGS="-O0 -g -Wall -Wextra\
      -fprofile-arcs\
      -ftest-coverage\
      $(ENV_CMAKE_CXX_FLAGS)"
  endif

  ifeq ("$(TYPE)","release")
      ENV_CMAKE_FLAGS += -DCMAKE_EXE_LINKER_FLAGS="-s"
      ENV_CMAKE_FLAGS += -DCMAKE_SHARED_LINKER_FLAGS="-s"
  endif

  ifeq ($(ENV_OSYS),Windows)
    ifeq ($(ENV_CC),clang)
      ENV_CMAKE_FLAGS += -DCMAKE_EXE_LINKER_FLAGS="-Wl,--allow-multiple-definition"
    endif
  endif
else
  ENV_CMAKE_FLAGS += -DCMAKE_CXX_FLAGS="\
   /D_SILENCE_TR1_NAMESPACE_DEPRECATION_WARNING\
   /D_CRT_SECURE_NO_WARNINGS\
   /WX-\
   /EHsc\
   /MTd\
  "
  ENV_CMAKE_FLAGS += -DCMAKE_STATIC_LINKER_FLAGS="\
   /VERBOSE:LIB\
  "
  ENV_CMAKE_FLAGS += -DCMAKE_EXE_LINKER_FLAGS="\
   /VERBOSE:LIB\
  "
  ifeq ($(ENV_CC),clang)
    ENV_CMAKE_FLAGS += -T LLVM-vs2017
    $(eval ENV_CC=clang-cl)
    $(eval ENV_CXX=clang-cl)
  endif
endif


ENV_BUILD_FLAGS  =
ifneq (,$(findstring Makefile,$(ENV_GEN)))
  ENV_BUILD_FLAGS += --no-print-directory $(MFLAGS)
endif


# generates ${CMAKE_BINARY_DIR}/compile_commands.json
ENV_CMAKE_FLAGS += -DCMAKE_EXPORT_COMPILE_COMMANDS=ON

# defines install location
ENV_CMAKE_FLAGS += -DCMAKE_INSTALL_PREFIX=$(ENV_INSTALL)


# define the config path to load .cmake modules
ifndef CONFIG
  CONFIG = .
endif
ENV_CMAKE_FLAGS += -DCMAKE_CONFIG_PATH=$(CONFIG)/.cmake


sync: debug-sync

sync-all: $(TYPES:%=%-sync)

$(OBJ)/CMakeCache.txt: $(OBJ) info-build
	@cd $(OBJ) && cmake $(ENV_CMAKE_FLAGS) ..

ifeq ("$(wildcard $(OBJ)/CMakeCache.txt)","")
$(SYNCS):%-sync: $(OBJ)
	@$(MAKE) --no-print-directory TYPE=$(patsubst %-sync,%,$@) $(OBJ)/CMakeCache.txt
else
$(SYNCS):%-sync: $(OBJ)
	@cmake --build $(OBJ) --config $(patsubst %-sync,%,$@) --target rebuild_cache -- $(ENV_BUILD_FLAGS)
endif

$(TYPES):%: %-sync
	@cmake --build $(OBJ) --config $(patsubst %-sync,%,$@) --target $(TARGET) -- $(ENV_BUILD_FLAGS)


all: debug-all

$(ALL):%-all: %-sync
	@cmake --build $(OBJ) --config $(patsubst %-sync,%,$@) -- $(ENV_BUILD_FLAGS)


test: debug-test

test-all: $(TYPES:%=%-test)

$(TESTS):%-test: %
	@cmake --build $(OBJ) --config $(patsubst %-test,%,$@) --target $(TARGET)-check -- $(ENV_BUILD_FLAGS)
ifeq ($(ENV_CC),emcc)
	cd ./$(OBJ) && \
	`cat CMakeFiles/$(TARGET)-check.dir/link.txt | \
	sed "s/$(TARGET)-check/$(TARGET)-check.js -s MAIN_MODULE=1/g"`
	cd ./$(OBJ) && ln -fs $(TARGET)-check.js $(TARGET)-check
endif
	@echo "-- Running unit test"
ifeq ($(ENV_OSYS),Windows)
	@$(ENV_FLAGS) .\\$(OBJ)\\$(TARGET)-check --gtest_output=xml:obj/report.xml $(ENV_ARGS)
else
	@$(ENV_FLAGS) ./$(OBJ)/$(TARGET)-check --gtest_output=xml:obj/report.xml $(ENV_ARGS)
endif

benchmark: debug-benchmark

benchmark-all: $(TYPES:%=%-benchmark)

$(BENCH):%-benchmark: %
	@cmake --build $(OBJ) --config $(patsubst %-benchmark,%,$@) --target $(TARGET)-run -- $(ENV_BUILD_FLAGS)
ifeq ($(ENV_CC),emcc)
	cd ./$(OBJ) && \
	`cat CMakeFiles/$(TARGET)-run.dir/link.txt | \
	sed "s/$(TARGET)-run/$(TARGET)-run.js -s MAIN_MODULE=1/g"`
	cd ./$(OBJ) && ln -fs $(TARGET)-run.js $(TARGET)-run
endif
	$(if $(filter $(patsubst %-benchmark,%,$@),release), \
	  @$(ENV_FLAGS) ./$(OBJ)/$(TARGET)-run -o console -o json:obj/report.json $(ENV_ARGS) \
	, \
	  @echo "-- Run benchmark via 'make run-benchmark'" \
	)

run-benchmark:
	@echo "-- Running benchmark"
ifeq ($(ENV_OSYS),Windows)
	@$(ENV_FLAGS) .\\$(OBJ)\$(TARGET)-run -o console -o json:obj/report.json $(ENV_ARGS)
else
	@$(ENV_FLAGS) ./$(OBJ)/$(TARGET)-run -o console -o json:obj/report.json $(ENV_ARGS)
endif


install: debug-install

install-all: $(TYPES:%=%-install)

$(INSTA):%-install: %
	@cmake --build $(OBJ) --config $(patsubst %-install,%,$@) --target install -- $(ENV_BUILD_FLAGS)


build: debug

$(BUILD):%-build: %


deps: debug-deps

$(DEPS):%-deps: %-sync
	@cmake --build $(OBJ) --config $(patsubst %-deps,%,$@) --target $(TARGET)-deps -- $(ENV_BUILD_FLAGS)


format: $(FORMAT:%=%-format-cpp)

%-format-cpp:
	@echo "-- Formatting Code C++: $(patsubst %-format-cpp,%,$@)"
	@clang-format -i `ls $(patsubst %-format-cpp,%,$@)/*.h 2> /dev/null | grep -e "\.h"` 2> /dev/null
	@clang-format -i `ls $(patsubst %-format-cpp,%,$@)/*.cpp 2> /dev/null | grep -e "\.cpp"` 2> /dev/null

update: $(UPDATE_FILE:%=%-update)

%-update:
	@echo "-- Updating: $(patsubst %-update,%,$@)"
	@for i in $(UPDATE_PATH); \
	  do \
	    cp -v \
	    $(CONFIG)/$(patsubst %-update,%,$@) \
	    $$i/$(patsubst %-update,%,$@); \
	  done


license: $(CONFIG:%=%-license) $(UPDATE_PATH:%=%-license)

%-license:
	@echo "-- Relicense: $(patsubst %-update,%,$@)"
	@cd $(patsubst %-update,%,$@); \
	python2 $(CONFIG)/src/py/Licenser.py

license-info:
	@grep LICENSE.txt -e "---:" | sed "s/---://g"
	@head -n `grep -B1 -ne "---" LICENSE.txt | head -n 1 | sed "s/-//g"` LICENSE.txt > $(OBJ)/notice.txt
	@cat $(OBJ)/notice.txt | sed "s/^/  /g" | sed "s/$$/\\\n/g" | tr -d '\n' > $(OBJ)/notice


analyze: debug-analyze

analyze-all: $(TYPES:%=%-analyze)

$(ANALY):%-analyze: %
	@echo "-- Running analysis tools"
	$(MAKE) $(MFLAGS) $@-cppcheck
	$(MAKE) $(MFLAGS) $@-iwyu
	$(MAKE) $(MFLAGS) $@-scan-build


analyze-cppcheck: debug-analyze-cppcheck

CPPCHECK_REPORT = ./$(OBJ)/.cppcheck.xml

%-analyze-cppcheck:
	@echo "-- Running 'cppcheck' $(patsubst %-analyze-cppcheck,%,$@)"
	@echo -n "" > $(CPPCHECK_REPORT)
	cppcheck \
	-v \
	--template=gcc \
	--force \
	--report-progress \
	--enable=all \
	-I . \
	./src/c**

	cppcheck \
	-v \
	--template=gcc \
	--errorlist \
	--xml-version=2 \
	--force \
	--enable=all \
	-I . \
	./src/c** > $(CPPCHECK_REPORT)


analyze-iwyu: debug-analyze-iwyu

IWYU_REPORT = ./$(OBJ)/.iwyu.txt

%-analyze-iwyu:
	@echo "-- Running 'iwyu' $(patsubst %-analyze-iwyu,%,$@)"
	@echo -n "" > $(IWYU_REPORT)
	@for i in `find ./c*`; do include-what-you-use $$i; done
	@for i in `find ./c*`; do include-what-you-use $$i >> $(IWYU_REPORT); done


analyze-scan-build: debug-analyze-scan-build

SCAN_BUILD_REPORT = ./$(OBJ)/.scan-build
SCAN_BUILD_REPORT_ATTIC = $(SCAN_BUILD_REPORT).attic

%-analyze-scan-build: clean
	@echo "-- Running 'scan-build' $(patsubst %-analyze-scan-build,%,$@)"
ifeq ($(wildcard $(SCAN_BUILD_REPORT_ATTIC)/.*),)
	@mkdir $(SCAN_BUILD_REPORT_ATTIC)
endif

	scan-build \
	-v \
	-o $(SCAN_BUILD_REPORT).attic \
	-stats \
	-plist-html \
	-analyzer-config stable-report-filename=true \
	-enable-checker llvm.Conventions \
	--force-analyze-debug-code \
	--keep-going \
	--keep-empty \
	$(MAKE) $(MFLAGS) $(patsubst %-analyze-scan-build,%,$@)

	@ln -f -s \
	$(SCAN_BUILD_REPORT_ATTIC)/`ls -t $(SCAN_BUILD_REPORT_ATTIC) | head -1` \
	$(SCAN_BUILD_REPORT)


info:
	@echo "-- Environment"
	@echo "   M = $(ENV_CPUM)"
	@echo "   P = $(ENV_PLAT)"
	@echo "   O = $(ENV_OSYS)"
	@echo "   A = $(ENV_ARCH)"
	@echo "   S = $(shell ${WHICH} $(SHELL))"


info-build: info
	@echo "   C = $(shell ${WHICH} $(ENV_CC))"
	@echo "   X = $(shell ${WHICH} $(ENV_CXX))"
	@echo "   G = $(shell ${WHICH} cmake)"
	$(eval F=$(subst -D,\n       -D,$(ENV_CMAKE_FLAGS)))
	@printf '   F = $(F)\n'


info-repo:
	@printf "%s %-20s %-10s %-25s %s\n" \
		"--" \
		"Repository" \
		`git rev-parse --short HEAD` \
		`git describe --tags --always --dirty` \
		`git branch | grep -e "\* " | sed "s/* //g"`
	@git submodule foreach \
	'printf "   %-20s %-10s %-25s %s\n" \
		$$path \
		`git rev-parse --short HEAD` \
		`git describe --tags --always --dirty` \
		`git branch | grep "* " | sed "s/* //g" | sed "s/ /-/g"`' | sed '/Entering/d'

info-tools:
	@echo "-- Make"
	@make --version
	@echo ""
	@echo "-- CMake"
	@cmake --version
	@echo ""

info-variables:
	$(foreach v, $(.VARIABLES), $(info $(v) = $($(v))))


info-generators:
	@echo "-- Enviroment CMake Generator Aliases"
	@echo "   make       = 'Unix Makefiles'"
	@echo "   make-cb    = 'CodeBlocks - Unix Makefiles'"
	@echo "   make-cl    = 'CodeLite - Unix Makefiles'"
	@echo "   make-s2    = 'Sublime Text 2 - Unix Makefiles'"
	@echo "   make-kp    = 'Kate - Unix Makefiles'"
	@echo "   make-e4    = 'Eclipse CDT4 - Unix Makefiles'"
	@echo "   make-gw    = 'MinGW Makefiles'"
	@echo "   make-gw-cb = 'CodeBlocks - MinGW Makefiles'"
	@echo "   make-gw-cl = 'CodeLite - MinGW Makefiles'"
	@echo "   make-gw-s2 = 'Sublime Text 2 - MinGW Makefiles'"
	@echo "   make-gw-kp = 'Kate - MinGW Makefiles'"
	@echo "   make-gw-e4 = 'Eclipse CDT4 - MinGW Makefiles'"
	@echo "   make-ms    = 'MSYS Makefiles'"
	@echo "   make-wc    = 'Watcom WMake'"
	@echo "   make-bl    = 'Borland Makefiles'"
	@echo "   make-nm    = 'NMake Makefiles'"
	@echo "   make-nm-cb = 'CodeBlocks - NMake Makefiles'"
	@echo "   make-nm-cl = 'CodeLite - NMake Makefiles'"
	@echo "   make-nm-s2 = 'Sublime Text 2 - NMake Makefiles'"
	@echo "   make-nm-kp = 'Kate - NMake Makefiles'"
	@echo "   make-nm-e4 = 'Eclipse CDT4 - NMake Makefiles'"
	@echo "   make-nj    = 'NMake Makefiles JOM'"
	@echo "   make-nj-cb = 'CodeBlocks - NMake Makefiles JOM'"
	@echo "   multi      = 'Green Hills MULTI'"
	@echo "   ninja      = 'Ninja'"
	@echo "   ninja-cb   = 'CodeBlocks - Ninja'"
	@echo "   ninja-cl   = 'CodeLite - Ninja'"
	@echo "   ninja-s2   = 'Sublime Text 2 - Ninja'"
	@echo "   ninja-kp   = 'Kate - Ninja'"
	@echo "   ninja-e4   = 'Eclipse CDT4 - Ninja'"
	@echo "   vs17       = 'Visual Studio 15 2017'"
	@echo "   vs17w64    = 'Visual Studio 15 2017 Win64'"
	@echo "   vs17arm    = 'Visual Studio 15 2017 ARM'"
	@echo "   vs15       = 'Visual Studio 14 2015'"
	@echo "   vs15w64    = 'Visual Studio 14 2015 Win64'"
	@echo "   vs15arm    = 'Visual Studio 14 2015 ARM'"
	@echo "   vs13       = 'Visual Studio 12 2013'"
	@echo "   vs13w64    = 'Visual Studio 12 2013 Win64'"
	@echo "   vs13arm    = 'Visual Studio 12 2013 ARM'"
	@echo "   vs12       = 'Visual Studio 11 2012'"
	@echo "   vs12w64    = 'Visual Studio 11 2012 Win64'"
	@echo "   vs12arm    = 'Visual Studio 11 2012 ARM'"
	@echo "   vs10       = 'Visual Studio 10 2010'"
	@echo "   vs10w64    = 'Visual Studio 10 2010 Win64'"
	@echo "   vs10ia64   = 'Visual Studio 10 2010 IA64'"
	@echo "   vs08       = 'Visual Studio 9 2008'"
	@echo "   vs08w64    = 'Visual Studio 9 2008 Win64'"
	@echo "   vs08ia64   = 'Visual Studio 9 2008 IA64'"


#
#
# Continues Integration and Deployment
#

ENV_CI_BUILD  := "n.a."
ENV_CI_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
ENV_CI_COMMIT := $(shell git rev-parse HEAD)
ENV_CI_GITTAG := $(shell git describe --tags --always)


ifdef CIRRUS_CI
  # https://cirrus-ci.org/guide/writing-tasks/#environment-variables
  ENV_CI_BUILD := $(CIRRUS_BUILD_ID)
endif

ifdef GITHUB_WORKFLOW
  # https://help.github.com/en/articles/virtual-environments-for-github-actions#environment-variables
  ENV_CI_BUILD  := $(GITHUB_WORKFLOW)-$(GITHUB_ACTION)-$(GITHUB_EVENT_NAME)
  ENV_CI_BRANCH := $(shell echo $(GITHUB_REF) | sed "s/refs\/heads\///g")
endif

info-ci: info
	@echo "   I = $(ENV_CI_BUILD)"
	@echo "   B = $(ENV_CI_BRANCH)"
	@echo "   # = $(ENV_CI_COMMIT)"

info-fetch: info-ci
ifdef ACCESS_TOKEN
	@echo ""
	@echo "-- Git Access Configuration"
	@git config --add --global \
	url."https://$(ACCESS_TOKEN)@github.com/".insteadOf "https://github.com/"
	@git config --add --global \
	url."https://$(ACCESS_TOKEN)@github.com/".insteadOf "git@github.com:"
endif
	@echo ""
	@echo "-- Submodules"
	@git submodule
	@echo ""

fetch: debug-fetch

$(FETCH):%-fetch: info-fetch
	$(if $(filter $(patsubst %-fetch,%,$@),release), \
	  $(eval SUBMODULES=$(shell grep submodule .gitmodules | grep "submodule" | grep -ve "# internal" | sed "s/\[submodule \"//g" | sed "s/\"\].*//g")) \
	, \
	  $(eval SUBMODULES=$(shell grep submodule .gitmodules | grep "submodule" | grep -ve "# external" | sed "s/\[submodule \"//g" | sed "s/\"\].*//g")) \
	)
	$(if $(SUBMODULES), @git submodule update --init $(SUBMODULES) )
	$(if $(SUBMODULES), @echo )
	@git submodule foreach \
	'git branch --remotes | grep $(ENV_CI_BRANCH) && git checkout $(ENV_CI_BRANCH) || git checkout master; echo ""'
	@$(MAKE) --no-print-directory info-repo


ci-tools:
	@$(MAKE) --no-print-directory C=$(C) G=$(G) I=$(I) info-tools

ci-fetch:
	@$(MAKE) --no-print-directory C=$(C) G=$(G) I=$(I) $(B)-fetch

ci-deps:
	@$(MAKE) --no-print-directory C=$(C) G=$(G) I=$(I) $(B)-deps

ci-build:
	@$(MAKE) --no-print-directory C=$(C) G=$(G) I=$(I) $(B)-build

ci-test:
	@$(MAKE) --no-print-directory C=$(C) G=$(G) I=$(I) $(B)-test

ci-benchmark:
	@$(MAKE) --no-print-directory C=$(C) G=$(G) I=$(I) $(B)-benchmark

ci-install:
	@$(MAKE) --no-print-directory C=$(C) G=$(G) I=$(I) $(B)-install

ci-bundle:
	@$(MAKE) --no-print-directory bundle


# bundle release

bundle: bundle-$(ENV_CI_GITTAG)

bundle-%:
	$(eval TAG := $(patsubst bundle-%,%,$@))
	$(eval BUNDLE := $(TARGET)-$(TAG))
ifeq ($(ENV_OSYS),Mac)
	$(eval OSYS := darwin)
else
	$(eval OSYS := $(shell echo $(ENV_OSYS) | tr A-Z a-z))
endif
	$(eval ARCH := $(shell echo $(ENV_ARCH) | tr A-Z a-z))
	$(eval ARCHIVE  := $(TARGET)-$(OSYS)-$(ARCH))
	@echo "-- Bundle   '$(TAG)' for '$(ENV_OSYS)' '$(ENV_ARCH)'"
	@mkdir -p $(OBJ)
	@mkdir -p $(OBJ)/bundle
	@cp -rf $(OBJ)/install $(OBJ)/bundle/$(BUNDLE)
ifeq ($(ENV_OSYS),Windows)
	$(eval ARCHIVE  := $(ARCHIVE).zip)
	@(cd $(OBJ)/bundle; zip -r $(ARCHIVE) $(BUNDLE))
else
	$(eval ARCHIVE  := $(ARCHIVE).tar.gz)
	@(cd $(OBJ)/bundle; tar cfvz $(ARCHIVE) $(BUNDLE))
endif
	@rm -rf $(OBJ)/bundle/$(BUNDLE)
	@echo "-- Archive  '$(ARCHIVE)'"
	$(eval CHECKSUM := $(ARCHIVE).sha2)
ifeq ($(ENV_OSYS),Mac)
	@(cd $(OBJ)/bundle; shasum -a 256 $(ARCHIVE) > $(CHECKSUM))
else
	@(cd $(OBJ)/bundle; sha256sum $(ARCHIVE) > $(CHECKSUM))
endif
	@echo "-- Checksum '$(CHECKSUM)'"
