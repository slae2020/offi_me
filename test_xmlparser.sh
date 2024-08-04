#!/bin/bash

[[ -z "$cfile" ]] && cfile="config.xml"

echo $(xml_grep --cond "prog" --text_only "$cfile"  )

prog+=($(xml_grep 'prog' "$cfile" --text_only))

declare -p | grep prog


echo "== Ende =="
