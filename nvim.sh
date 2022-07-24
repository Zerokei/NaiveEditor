#!/bin/bash
input=$1
echo $input

# store the text
lines=$(wc -l $input | awk '{print $1;}')
arrVar=()
while read -r line
do
	arrVar+=("$line")
done < "$input"


# output the text
echo "wow"
print(){
	clear
	for index in $(seq 0 $((lines-1))) ; do
		value=${arrVar[$index]}
		if [ $(($1)) -eq $index ]
		then
            if [ $(($2)) -eq ${#value} ]
            then
                echo -e $value"\033[5m_\033[m"
            else 
			    echo -e ${value:0:$2}"\033[1;30m${value:$2:1}\033[m"${value:$(($2+1))}
            fi
		else
			echo $value
		fi
		# echo $value
	done
	echo -en "-- VIEW --"
}

posc=0
posl=0
print
# main program
while true
do
    read -s -n1 acc
    echo $acc
    if [[ $acc = "l" ]]
    then
        posl=$posl+1
    elif [[ $acc = "h" ]]
    then
        posl=$posl-1
    elif [[ $acc = "j" ]]
    then
        posc=$posc+1
    elif [[ $acc = "k" ]]
    then
        posc=$posc-1
    fi
    if [[ "$posc" -lt 0 ]]
    then
        posc=0
    elif [[ "$posc" -ge "$lines" ]]
    then
        posc=$((lines))-1
    fi
    if [[ "$posl" -lt 0 ]]
    then 
        posl=0
    elif [[ "$posl" -gt ${#arrVar[$posc]} ]]
    then
        echo "!"
        posl=${#arrVar[$posc]}
    fi
    print posc posl
done
