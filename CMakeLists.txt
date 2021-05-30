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

set( PROJECT casm )

cmake_minimum_required( VERSION ${CMAKE_VERSION} )

project( ${PROJECT} )
set( CMAKE_VERSION 3.2 )
set( CMAKE_MODULE_PATH ${${PROJECT}_SOURCE_DIR}/.cmake )
include( ${CMAKE_CONFIG_PATH}/LibPackage.cmake )

package_git( ${PROJECT} )
package_git_submodule( libstdhl   master REQUIRED obj   lib/stdhl   )
package_git_submodule( libgtest   master REQUIRED build lib/gtest   )
package_git_submodule( libhayai   master REQUIRED build lib/hayai   )
package_git_submodule( libz3      master REQUIRED build lib/z3      )
package_git_submodule( libpass    master REQUIRED obj   lib/pass    )
package_git_submodule( libtptp    master REQUIRED obj   lib/tptp    )
package_git_submodule( libcasm-ir master REQUIRED obj   lib/casm-ir )
package_git_submodule( libcasm-fe master REQUIRED obj   lib/casm-fe )
#package_git_submodule( libcasm-rt master REQUIRED obj   lib/casm-rt )
#package_git_submodule( libcasm-be master REQUIRED obj   lib/casm-be )
package_git_submodule( libcasm-tc master REQUIRED obj   lib/casm-tc )
#package_git_submodule( libcjel-ir master REQUIRED obj   lib/cjel-ir )
#package_git_submodule( libcjel-rt master REQUIRED obj   lib/cjel-rt )
#package_git_submodule( libcjel-fe master REQUIRED obj   lib/cjel-fe )
#package_git_submodule( libcjel-be master REQUIRED obj   lib/cjel-be )
#package_git_submodule( libcjel-tc master REQUIRED obj   lib/cjel-tc )
#package_git_submodule( casmc      master REQUIRED obj   app/casmc   )
package_git_submodule( casmd      master REQUIRED obj   app/casmd   )
package_git_submodule( casmf      master REQUIRED obj   app/casmf   )
package_git_submodule( casmi      master REQUIRED obj   app/casmi   )
package_git_deps(
  libgtest>libstdhl
  libhayai>libstdhl
  libstdhl>libpass
  libpass>libtptp
  libz3>libtptp
  libtptp>libcasm-ir
  libcasm-ir>libcasm-fe
  libcasm-fe>libcasm-tc
  libcasm-tc>casmd
  libcasm-tc>casmf
  libcasm-tc>casmi
  )

include( CPack )
include( FeatureSummary )

#
#
# project
#

add_custom_target( ${PROJECT}
  DEPENDS
    ${PROJECT}-deps
)

#
#
# test
#

IF( WIN32 )
add_custom_target( ${PROJECT}-check
  COMMAND
    ${CMAKE_COMMAND} -E copy
    ${CMAKE_SOURCE_DIR}/src/${PROJECT}-test.bat
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT}-check.bat
  WORKING_DIRECTORY
    ${PROJECT_SOURCE_DIR}
)
ELSE()
add_custom_target( ${PROJECT}-check
  COMMAND
    ${CMAKE_COMMAND} -E copy
    ${CMAKE_SOURCE_DIR}/src/${PROJECT}-test
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT}-check
  WORKING_DIRECTORY
    ${PROJECT_SOURCE_DIR}
)
ENDIF()

#
#
# benchmark
#

IF( WIN32 )
add_custom_target( ${PROJECT}-run
  COMMAND
    ${CMAKE_COMMAND} -E copy
    ${CMAKE_SOURCE_DIR}/src/${PROJECT}-benchmark.bat
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT}-run.bat
  WORKING_DIRECTORY
    ${PROJECT_SOURCE_DIR}
)
ELSE()
add_custom_target( ${PROJECT}-run
  COMMAND
    ${CMAKE_COMMAND} -E copy
    ${CMAKE_SOURCE_DIR}/src/${PROJECT}-benchmark
    ${CMAKE_CURRENT_BINARY_DIR}/${PROJECT}-run
  WORKING_DIRECTORY
    ${PROJECT_SOURCE_DIR}
)
ENDIF()

#
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
#
# bundle
#

install(
  DIRECTORY
    app/casmd/obj/install/
    app/casmf/obj/install/
    app/casmi/obj/install/
  DESTINATION
    "."
    )

#
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
#
# build features and checks
#

feature_summary( WHAT
  PACKAGES_NOT_FOUND
  DISABLED_FEATURES
)
