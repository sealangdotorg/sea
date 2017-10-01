#
#   Copyright (c) 2014-2017 CASM Organization
#   All rights reserved.
#
#   Developed by: Philipp Paulweber
#                 Emmanuel Pescosta
#                 https://github.com/casm-lang/casm
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

include .cmake/config.mk



DATETIME=$(shell date)
ATTIC=.attic
CI_PL_CFG=$(ATTIC)/ci_pipeline_config.yml
CI_PATH=.ci
CI_RSRC=$(CI_PATH)/resource
CI_TYPE=$(CI_PATH)/type
CI_JOBS=$(CI_PATH)/job
CI_EXT=.yml

doxy:
	@mkdir -p obj
	@doxygen

$(ATTIC):
	@mkdir -p $@



ci: $(ATTIC)
	@echo $(CI_PL_CFG)

	@echo "#### generated at '$(DATETIME)'" > $(CI_PL_CFG)
	@echo "resource_types:" >> $(CI_PL_CFG)
	@( for i in `ls $(CI_TYPE)/*$(CI_EXT)`; do \
		echo "$@: processing '$$i'"; \
		export FILENAME=`basename $$i $(CI_EXT)`; \
		echo "#### $$i" >> $(CI_PL_CFG); \
		cat $$i | sed -e "s/{{NAME}}/$$FILENAME/g" | sed -e "/#   /d" >> $(CI_PL_CFG); \
		echo "" >> $(CI_PL_CFG); \
	done )

	@echo "resources:" >> $(CI_PL_CFG)
	@( for i in `ls $(CI_RSRC)/*$(CI_EXT)`; do \
		echo "$@: processing '$$i'"; \
		export FILENAME=`basename $$i $(CI_EXT)`; \
		echo "#### $$i" >> $(CI_PL_CFG); \
		cat $$i | sed -e "s/{{NAME}}/$$FILENAME/g" | sed -e "/#   /d" >> $(CI_PL_CFG); \
		echo "" >> $(CI_PL_CFG); \
	done )

	@echo "groups: [] ## TODO: FIXME: PPA: add automatic group generation" >> $(CI_PL_CFG)

	@echo "jobs:" >> $(CI_PL_CFG)
	@( for i in `ls $(CI_JOBS)/*$(CI_EXT)`; do \
		echo "$@: processing '$$i'"; \
		export FILENAME=`basename $$i $(CI_EXT)`; \
		echo "#### $$i" >> $(CI_PL_CFG); \
		cat $$i | \
			sed -e "s/{{NAME}}/$$FILENAME/g" | \
			sed "/{{fetch_build_test}}/ r .ci/job/.fetch_build_test" | \
			sed "/{{fetch_build_test}}/d" | \
			sed -e "/#   /d" >> $(CI_PL_CFG); \
		echo "" >> $(CI_PL_CFG); \
	done )

	fly -t casm sp -p casm -c $(CI_PL_CFG) -l ~/.ci.yml






update-LibPackage: lib/stdhl/.cmake/LibPackage.cmake
	cp -v $^ .cmake/
	cp -v $^ lib/pass/.cmake/
	cp -v $^ lib/casm-ir/.cmake/
	cp -v $^ lib/casm-rt/.cmake/
	cp -v $^ lib/casm-fe/.cmake/
	cp -v $^ lib/casm-tc/.cmake/
	cp -v $^ app/casmd/.cmake/
	cp -v $^ app/casmf/.cmake/
	cp -v $^ app/casmi/.cmake/
