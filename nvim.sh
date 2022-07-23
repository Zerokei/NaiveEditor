#!/bin/bash
input=$1
echo $input
clear
while read -r line
do
  echo "$line"
done < "$input"

