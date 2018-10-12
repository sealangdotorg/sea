#
#   Copyright (C) 2014-2018 CASM Organization <https://casm-lang.org>
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

TARGET = casm

UPDATE_ROOT  = lib/stdhl
UPDATE_PATH  = .
UPDATE_PATH += lib/pass
UPDATE_PATH += lib/casm-ir
UPDATE_PATH += lib/casm-rt
UPDATE_PATH += lib/casm-fe
UPDATE_PATH += lib/casm-tc
UPDATE_PATH += app/casmd
UPDATE_PATH += app/casmf
UPDATE_PATH += app/casmi

UPDATE_FILE  = .clang-format
UPDATE_FILE += .cmake/config.mk
UPDATE_FILE += .cmake/LibPackage.cmake

include .cmake/config.mk


clean-deps:
	rm -rf app/*/obj lib/*/obj lib/*/build


doxy: export PROJECT_NUMBER:=$(shell git describe --always --tags --dirty)

.PHONY: doxy
doxy:
	@echo "$(PROJECT_NUMBER)"
	@mkdir -p obj
	@doxygen


FLY_PATH=.ci
FLY_PIPELINE=$(FLY_PATH)/pipeline
FLY_EXT=.yml

PIPELINES  = forks
PIPELINES += development
PIPELINES += nightly
PIPELINES += release

fly: $(PIPELINES:%=fly-%)

ATTIC=.attic

$(ATTIC):
	@mkdir -p $@

fly-%: $(ATTIC)
	$(eval FLY_SRC := $(FLY_PIPELINE)/$(patsubst fly-%,%,$@)$(FLY_EXT))
	$(eval FLY_DST := $(ATTIC)/$(patsubst fly-%,%,$@)$(FLY_EXT))
	@echo "-- Generating '$(FLY_SRC)' -> '$(FLY_DST)'"
	@(sh .ci/script/pipeline.sh $(FLY_SRC) $(FLY_DST))

status-fly:
	@( clear; while true; do date; fly -t ci bs -c 25; fly -t ci ws; tput cup 0 0; sleep 1; done)


ci-fetch: ci-git-access

ci-git-access:
	@echo "-- Git Access Configuration"
	@git config --global \
	url."https://$(GITHUB_TOKEN)@github.com/".insteadOf "https://github.com/"
	@git config --global \
	url."https://$(GITHUB_TOKEN)@github.com/".insteadOf "git@github.com:"


