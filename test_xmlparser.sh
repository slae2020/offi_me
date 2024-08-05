#!/bin/bash

#[[ -z "$cfile" ]] && cfile="config.xml"

#echo $(xml_grep --cond "prog" --text_only "$cfile"  )

#prog+=($(xml_grep 'prog' "$cfile" --text_only))

#declare -p | grep prog


#echo "== Ende =="



# Script to extract <prog> elements from a configuration XML file and print them.

# Configuration file name
cfile="config.xml"

# Extract <prog> elements from the XML file
prog=($(xml_grep 'prog' "$cfile" --text_only))

# Check if the extraction was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to extract <prog> elements from $cfile"
  exit 1
fi

# Print the extracted <prog> elements
for element in "${prog[@]}"; do
  echo "$element"
done

echo "== Ende =="
