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

if [ -z "$1" ]; then
    echo "error: 'input' (argument 1) is not set!"
    exit -1
fi

if [ -z "$1" ]; then
    echo "error: 'output' (argument 2) is not set!"
    exit -1
fi


CI_SRC=$1
CI_DST=$2

CI_PATH=.ci
CI_PIPELINE=$CI_PATH/pipeline
CI_RSRC=$CI_PATH/resource
CI_TYPE=$CI_PATH/type
CI_JOBS=$CI_PATH/job
CI_STEP=$CI_PATH/step
CI_EXT=.yml

DATETIME=`date`

target=ci


process_resource_type()
{
    local stream=$1
    local resource=$2

    local name=`basename $resource $CI_EXT`

    # echo "$stream: processing '{{type:$name}}'"
    echo "#### $resource" >> $stream
    cat $resource \
	| sed -e "s#{{NAME}}#$name#g" \
	| sed -e "/#   /d" \
	| sed -e "/#$/d" \
	      >> $stream
    echo "" >> $stream
}


process_include()
{
    local stream=$1
    local resource=$2
    local filter=$3
    local path=$4

    local indent=`echo "$resource" | sed "s/{{.*//g"`

    if [ "$filter" = "R" ]; then
	data=`echo $resource | sed "s/{{resource://g" | sed "s/}}//g"`
    elif [ "$filter" = "J" ]; then
	data=`echo $resource | sed "s/{{job://g" | sed "s/}}//g"`
    elif [ "$filter" = "S" ]; then
	data=`echo $resource | sed "s/{{step://g" | sed "s/}}//g"`
    else
	exit -1
    fi

    local opt=`echo $data | grep "%" | sed "s/.*%//g"`
    local arg=`echo $data | grep "&" | sed "s/.*&//g" | sed "s/%.*//g"`
    local tag=`echo $data | grep "@" | sed "s/.*@//g" | sed "s/&.*//g" | sed "s/%.*//g"`
    local repo=`echo $data | grep ":" | sed "s/.*://g" | sed "s/@.*//g" | sed "s/&.*//g" | sed "s/%.*//g"`
    local name=`echo $data | sed "s/:.*//g" | sed "s/@.*//g" | sed "s/&.*//g" | sed "s/%.*//g"`

    local file=`echo $path/$name$CI_EXT`

    if [ -z "$tag" ]; then
	tag="master"
    fi

    if [ -z "$repo" ]; then
	repo=`echo $name | grep "\/" | sed "s/.*\///g"`
    fi

    if [ -z "$repo" ]; then
	repo=$name
    fi

    # echo "$stream: processing '$resource' $filter"
    # echo "$stream:       inde='$indent'"
    # echo "$stream:       data='$data'"
    # echo "$stream:       name='$name'"
    # echo "$stream:       repo='$repo'"
    # echo "$stream:        tag='$tag'"
    # echo "$stream:        arg='$arg'"
    # echo "$stream:        opt='$opt'"
    # echo "$stream:       file='$file'"

    if [ "$filter" = "R" ]; then
	if [ -z "$repo" ]; then
	    # echo "$resource" >> $stream
	    echo "" >> $stream
	    return
	fi
    fi

    if [ -e $file ]; then
	echo "#### $file" >> $stream
	cat $file \
	    | sed -e "s/^/$indent/" \
	    | sed -e "s/{{OPT}}/$opt/g" \
	    | sed -e "s/{{ARG}}/$arg/g" \
	    | sed -e "s/{{TAG}}/$tag/g" \
	    | sed -e "s/{{REPO}}/$repo/g" \
	    | sed -e "s#{{NAME}}#$name#g" \
	    | sed -e "/#   /d" \
	    | sed -e "/#$/d" \
		  >> $stream

	echo "" >> $stream
    else
	echo "error: file '$file' not found!"
	exit -1
    fi
}


process_resource()
{
    process_include $1 $2 R $CI_RSRC
}


process_job()
{
    local file=`mktemp`
    local stream=$1
    
    printf "" > $file
    process_include $file "$2" J $CI_JOBS

    while IFS='' read -r line; do
	# echo "ci@J:'$line'"

	if echo $line | grep -qe "{{step:.*}}"; then
	    process_step $stream "$line"
	    continue
	fi

	echo "$line" >> $stream
    done < "$file"

    rm -f $file
}


process_step()
{
    local file=`mktemp`
    local stream=$1

    printf "" > $file
    process_include $file "$2" S $CI_STEP

    while IFS='' read -r line; do
	# echo "ci@J:'$line'"

	if echo $line | grep -qe "{{step:.*}}"; then
	    process_step $stream "$line"
	    continue
	fi

	echo "$line" >> $stream
    done < "$file"

    rm -f $file
}


process_pipeline()
{
    local stream=$1
    local origin=$2

    echo "#### generated at '$DATETIME' from '$origin'" > $stream
    echo "" >> $stream

    while IFS='' read -r line; do
	# echo "ci:'$line'"

	if [ "$line" == "---" ]; then
	    echo "$line" >> $stream
	    echo "resource_types:" >> $stream
	    for resource_type in `ls $CI_TYPE/*$CI_EXT`; do
		process_resource_type $stream $resource_type
	    done
	    echo "" >> $stream
	    continue
	fi

	if [ "$line" == "{{active}}" ]; then
	    # echo "$stream: processing '$line'"
	    state=up
	    continue
	fi

	if [ "$line" == "{{public}}" ]; then
	    # echo "$stream: processing '$line'"
	    exposure=ep
	    continue
	fi

	if echo "$line" | grep -qe "{{resource:.*}}"; then
	    process_resource $stream "$line"
	    continue
	fi

	if echo "$line" | grep -qe "{{job:.*}}"; then
	    process_job $stream "$line"
	    continue
	fi

	if echo "$line" | grep -qe "{{step:.*}}"; then
	    process_step $stream "$line"
	    continue
	fi

	echo "$line" >> $stream
    done < "$origin"

}


origin=$CI_SRC
stream=$CI_DST

pipeline=`basename $origin $CI_EXT`
state=pp
exposure=hp

if [ -e $origin ]; then
    process_pipeline $stream $origin
else
    exit -1
fi



fly vp -c $stream && \
fly -t $target sp -p $pipeline -c $stream -l ~/.ci.yml && \
fly -t $target $state -p $pipeline && \
fly -t $target $exposure -p $pipeline
