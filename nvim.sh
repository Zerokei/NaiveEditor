#!/bin/bash
input=$1
echo $input
lines=$(wc -l $input | awk '{print $1;}')

# store the text
arrVar=()
while read -r line
do
	arrVar+=("$line")
done < "$input"
# output the text

posc=2
posl=1

print(){
	clear
	echo "The text has "$lines" lines"
	for index in $(seq 0 $((lines-1))) ; do
		value=${arrVar[$index]}
		if [ $posc -eq $index ]
		then
			echo -e ${value:0:$((posl))}"\033[5m${value:$posl:1}\033[m"${value:1}
		else
			echo $value
		fi
		# echo $value
	done
	echo "-- VIEW --"
}
print
