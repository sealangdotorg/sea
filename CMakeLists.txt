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

set( PROJECT casm )

cmake_minimum_required( VERSION ${CMAKE_VERSION} )

project( ${PROJECT} LANGUAGES C CXX )
set( CMAKE_CXX_STANDARD 11 )
set( CMAKE_VERSION 3.2 )
set( CMAKE_INCLUDE_CURRENT_DIR ON )
set( CMAKE_MODULE_PATH ${${PROJECT}_SOURCE_DIR}/.cmake )


#
# packages
#

include( LibPackage )

package_git( ${PROJECT} )
package_git_submodule( libstdhl   master REQUIRED obj   lib/stdhl   )
package_git_submodule( libgtest   master REQUIRED build lib/gtest   )
package_git_submodule( libhayai   master REQUIRED build lib/hayai   )
package_git_submodule( libpass    master REQUIRED obj   lib/pass    )
package_git_submodule( libcasm-tc master REQUIRED obj   lib/casm-tc )
package_git_submodule( libcasm-fe master REQUIRED obj   lib/casm-fe )
package_git_submodule( libcasm-ir master REQUIRED obj   lib/casm-ir )
package_git_submodule( libcasm-rt master REQUIRED obj   lib/casm-rt )
#package_git_submodule( libcasm-be master REQUIRED obj   lib/casm-be )
#package_git_submodule( libcjel-tc master REQUIRED obj   lib/cjel-tc )
#package_git_submodule( libcjel-fe master REQUIRED obj   lib/cjel-fe )
#package_git_submodule( libcjel-ir master REQUIRED obj   lib/cjel-ir )
#package_git_submodule( libcjel-rt master REQUIRED obj   lib/cjel-rt )
#package_git_submodule( libcjel-be master REQUIRED obj   lib/cjel-be )
#package_git_submodule( casmc      master REQUIRED obj   app/casmc   )
package_git_submodule( casmd      master REQUIRED obj   app/casmd   )
#package_git_submodule( casmf      master REQUIRED obj   app/casmf   )
package_git_submodule( casmi      master REQUIRED obj   app/casmi   )


#
# includes
#

include( FeatureSummary )
include( CPack )


#
# project
#

add_custom_target( ${PROJECT}
  COMMAND make --no-print-directory -C lib/stdhl
  COMMAND make --no-print-directory -C lib/pass
  COMMAND make --no-print-directory -C lib/casm-tc
  COMMAND make --no-print-directory -C lib/casm-fe
  COMMAND make --no-print-directory -C lib/casm-ir
#  COMMAND make --no-print-directory -C lib/casm-rt
#  COMMAND make --no-print-directory -C lib/casm-be
#  COMMAND make --no-print-directory -C lib/cjel-tc
#  COMMAND make --no-print-directory -C lib/cjel-fe
#  COMMAND make --no-print-directory -C lib/cjel-ir
#  COMMAND make --no-print-directory -C lib/cjel-rt
#  COMMAND make --no-print-directory -C lib/cjel-be
#  COMMAND make --no-print-directory -C app/casmc
  COMMAND make --no-print-directory -C app/casmd
#  COMMAND make --no-print-directory -C app/casmf
  COMMAND make --no-print-directory -C app/casmi
  WORKING_DIRECTORY
    ${PROJECT_SOURCE_DIR}
)

#
# test
#

add_custom_target( ${PROJECT}-check
  COMMAND make --no-print-directory -C lib/stdhl test
  COMMAND make --no-print-directory -C lib/pass test
  COMMAND make --no-print-directory -C lib/casm-tc test
  COMMAND make --no-print-directory -C lib/casm-fe test
  COMMAND make --no-print-directory -C lib/casm-ir test
#  COMMAND make --no-print-directory -C lib/casm-rt test
#  COMMAND make --no-print-directory -C lib/casm-be test
#  COMMAND make --no-print-directory -C lib/cjel-tc test
#  COMMAND make --no-print-directory -C lib/cjel-fe test
#  COMMAND make --no-print-directory -C lib/cjel-ir test
#  COMMAND make --no-print-directory -C lib/cjel-rt test
#  COMMAND make --no-print-directory -C lib/cjel-be test
#  COMMAND make --no-print-directory -C app/casmc test
  COMMAND make --no-print-directory -C app/casmd test
#  COMMAND make --no-print-directory -C app/casmf test
  COMMAND make --no-print-directory -C app/casmi test
  WORKING_DIRECTORY
    ${PROJECT_SOURCE_DIR}
)


#
# benchmark
#

add_custom_target( ${PROJECT}-run
  COMMAND make --no-print-directory -C lib/stdhl benchmark
  COMMAND make --no-print-directory -C lib/pass benchmark
  COMMAND make --no-print-directory -C lib/casm-tc benchmark
  COMMAND make --no-print-directory -C lib/casm-fe benchmark
  COMMAND make --no-print-directory -C lib/casm-ir benchmark
#  COMMAND make --no-print-directory -C lib/casm-rt benchmark
#  COMMAND make --no-print-directory -C lib/casm-be benchmark
#  COMMAND make --no-print-directory -C lib/cjel-tc benchmark
#  COMMAND make --no-print-directory -C lib/cjel-fe benchmark
#  COMMAND make --no-print-directory -C lib/cjel-ir benchmark
#  COMMAND make --no-print-directory -C lib/cjel-rt benchmark
#  COMMAND make --no-print-directory -C lib/cjel-be benchmark
#  COMMAND make --no-print-directory -C app/casmc benchmark
  COMMAND make --no-print-directory -C app/casmd benchmark
#  COMMAND make --no-print-directory -C app/casmf benchmark
  COMMAND make --no-print-directory -C app/casmi benchmark
  WORKING_DIRECTORY
    ${PROJECT_SOURCE_DIR}
)


#
# install
#

install(
  TARGETS
  EXPORT   ${PROJECT}Targets
  LIBRARY  DESTINATION lib
  ARCHIVE  DESTINATION lib
  RUNTIME  DESTINATION bin
  INCLUDES DESTINATION include
)


#
# cmake
#

# install(
#   FILES
#     .cmake/Find${PROJECT}.cmake
#   DESTINATION
#     "share/cmake/Module/${PROJECT}"
#   )


#
# build features and checks
#

feature_summary( WHAT
  PACKAGES_NOT_FOUND
  DISABLED_FEATURES
)
