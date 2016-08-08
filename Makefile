#   
#   Copyright (c) 2014-2016 CASM Organization
#   All rights reserved.
#   
#   Developed by: Florian Hahn
#                 Philipp Paulweber
#                 Emmanuel Pescosta
#                 https://github.com/ppaulweber/casm
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

DATETIME=$(shell date)
ATTIC=.attic
CI_PL_CFG=$(ATTIC)/ci_pipeline_config.yml
CI_PATH=.ci
CI_RSRC=$(CI_PATH)/resource
CI_TYPE=$(CI_PATH)/type
CI_JOBS=$(CI_PATH)/job
CI_EXT=.yml

default:
	@echo "casm"




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
		cat $$i | sed -e "s/{{NAME}}/$$FILENAME/g" | sed -e "/#   /d" >> $(CI_PL_CFG); \
		echo "" >> $(CI_PL_CFG); \
	done )

	fly -t ci sp -p casm -c $(CI_PL_CFG) -l ~/.ci.yml
