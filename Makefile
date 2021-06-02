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

TARGET = casm

UPDATE_PATH  = .
UPDATE_PATH += lib/pass
UPDATE_PATH += lib/tptp
UPDATE_PATH += lib/casm-ir
UPDATE_PATH += lib/casm-rt
UPDATE_PATH += lib/casm-fe
UPDATE_PATH += lib/casm-tc
UPDATE_PATH += app/casmd
UPDATE_PATH += app/casmf
UPDATE_PATH += app/casmi

UPDATE_FILE  = .clang-format
UPDATE_FILE += .github/workflows/build.yml
UPDATE_FILE += .github/workflows/nightly.yml
UPDATE_FILE += .ycm_extra_conf.py

CONFIG  = lib/stdhl
ifeq ($(wildcard $(CONFIG)/.cmake/.*),)
  CONFIG = lib/stdhl
  ifeq ($(wildcard $(CONFIG)/.cmake/.*),)
    $(git config --add --local url."https://github.com/casm-lang/libstdhl".insteadOf "git@github.com:casm-lang/libstdhl")
    $(shell git submodule update --init $(CONFIG) && git -C $(CONFIG) checkout master)
  endif
endif

INCLUDE = $(CONFIG)/.cmake/config.mk
include $(INCLUDE)


clean-deps:
	rm -rf app/*/obj lib/*/obj lib/*/build


doxy: export PROJECT_NUMBER:=$(shell git describe --always --tags --dirty)

.PHONY: doxy
doxy:
	@echo "$(PROJECT_NUMBER)"
	@mkdir -p obj
	@doxygen


grammar:
	@for i in `grep "#+html: {{page>.:grammar:" lib/casm-fe/src/various/Grammar.org | sed "s/#+html: {{page>.:grammar:/doc\/language\/grammar\//g" | sed "s/&noheader&nofooter}}/.org/g"`; do if [ ! -f $$i ]; then echo "Documentation of '$$i' is missing!"; fi; done
	@echo "Grammar Rules"
	@grep "#+html: {{page>.:grammar:" doc/language/syntax.org | wc -l
	@echo "Grammar Descriptions"
	@ls doc/language/grammar/ | wc -l


GITHUB_PATH  = $(subst ., $(CONFIG), $(UPDATE_PATH))
GITHUB_DIR   = .github
GITHUB_FILE  = CODE_OF_CONDUCT.md
GITHUB_FILE += CODE_OF_CONDUCT.org
GITHUB_FILE += CONTRIBUTING_SUBMODULE.org
GITHUB_FILE += ISSUE_TEMPLATE.org
GITHUB_FILE += PULL_REQUEST_TEMPLATE.org

github: $(GITHUB_FILE:%=github-%)

define github-command
  $(eval GH_SRC := $(GITHUB_DIR)/$(2))
  $(eval GH_DST := $(1)/$(GH_SRC))
#  $(info "-- Generating '$(GH_SRC)' -> '$(GH_DST)'")
  $(shell cp -vf $(GH_SRC) $(GH_DST))
endef

github-%:
	$(foreach path,$(GITHUB_PATH),$(call github-command,$(path),$(patsubst github-%,%,$@)))

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
