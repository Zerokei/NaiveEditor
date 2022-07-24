#!/bin/bash
input=$1
echo $input

# store the text
lines=$(wc -l $input | awk '{print $1;}')
arrVar=()
while read -r line
do
	arrVar+=("$line\n")
done < "$input"


# output the text
echo "wow"
mode=0
print(){
	clear
    printf -- '- %s\n' "${arrVar[@]}"
    lines=${#arrVar[@]}
    echo $lines
	for index in $(seq 0 $((lines-1))) ; do
		value=${arrVar[$index]}
		if [ $(($1)) -eq $index ]
		then
            if [ $(($2)) -eq $((${#value}-2)) ]
            then
                echo -e ${value:0:$((${#value}-2))}"\033[5m_\033[m"
            else 
			    echo -ne ${value:0:$2}"\033[1;30m${value:$2:1}\033[m"${value:$(($2+1))}
            fi
		else
			echo -ne $value
		fi
		# echo $value
	done
	if [[ "$mode" -eq 0 ]]
    then
        echo -en "-- VIEW --\x0aPosition:"$(($1)):$(($2))" Press:"
    elif [[ "$mode" -eq 1 ]]
    then
        echo -en "-- EDIT --\x0aPosition:"$(($1)):$(($2))" Press:"
    fi
}

posc=0
posl=0

print
# main program
while true
do
    read -n1 acc
    if [[ "$mode" -eq 0 ]]
    then
        case $acc in
            $'l') posl=$posl+1 ;;
            $'h') posl=$posl-1 ;;
            $'j') posc=$posc+1 ;;
            $'k') posc=$posc-1 ;;
            $'i') mode=1 ;;
            # $':') mode=2 ;;
        esac
    elif [[ "$mode" -eq 1 ]]
    then
        case $acc in
            $'\x1b') # esc key 
                mode=0 ;; 
            $'\x7f') # back key
                if [[ "$posl" -gt 0 ]] ;then
                    value=${arrVar[$posc]}
                    value=${value:0:$(($posl-1))}${value:$(($posl))}
                    arrVar[$posc]=$value
                    posl=$posl-1
                else # the line should be moved to the previous one.
                    # [0...posc-1][posc+1...end]
                    if [[ "$posc" -gt 0 ]] ;then # if it is the first line, there is no need to move
                        newVar=(${arrVar[@]:0:$((posc))})
                        newVar+=(${arrVar[@]:$((posc+1))})
                        posl=${#arrVar[$((posc-1))]}-2
                        newVar[$((posc-1))]=${newVar[$((posc-1))]:0:$((${#arrVar[$posc-1]}-2))}${arrVar[$((posc))]}
                        arrVar=(${newVar[@]})
                        posc=$posc-1
                    fi
                fi ;;
            $"") # enter key
                    # [0..posc][""][posc+1]
                    newVar=(${arrVar[@]:0:$((posc+1))})
                    newVar+=("\n")
                    newVar+=(${arrVar[@]:$((posc+1))})
                    newVar[posc]=${arrVar[posc]:0:posl}"\n"
                    newVar[((posc+1))]=${arrVar[posc]:posl}
                    arrVar=(${newVar[@]})
                    posc=$posc+1
                    posl=0
                ;;
            *)  value=${arrVar[$posc]}
                value=${value:0:$(($posl))}$acc${value:$(($posl))}
                arrVar[$posc]=$value 
                posl=$posl+1 ;;
        esac
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
    elif [ $(($posl)) -ge $((${#arrVar[$posc]}-1)) ]
    then
        posl=${#arrVar[$posc]}-2
    fi

    print posc posl
    lines=${#arrVar[@]}
    echo $acc
done
