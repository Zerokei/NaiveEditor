#!/bin/bash
input=$1
echo $input

tput civis # hide the cursor
# store the text
lines=$(wc -l $input | awk '{print $1;}')
arrVar=()
# read file with spaces of prefix, credit to https://www.codegrepper.com/code-examples/shell/bash+read+file+line+by+line+with+spaces
while IFS= read -r
do
	arrVar+=("$REPLY\n")
done < "$input"


# output the text
echo "wow"
mode=0
bottom_text=""
print_in_bottom () {
    local lines=$(tput lines)
    local columns=$(tput cols)           # get the terminal width
    local text=${1:0:$columns}           # truncate the text to fit on a line if needed
    tput sc                              # Save the Cursor position
    bottom_length=$(echo -ne "$2" | wc -c)
    if [[ $1 == 'left' ]]
    then
        tput cup $lines 0   # move the CUrsor Position to the top line, with just enough space for $text on the right
    elif [[ $1 == 'right' ]]
    then
        tput cup $lines $((columns-bottom_length))   # move the CUrsor Position to the top line, with just enough space for $text on the right
    fi
    if [[ $3 == 'yellow' ]]
    then
        echo -ne '\033[0;33m'$2'\033[0m'
    else 
        echo -ne $2
    fi
    tput rc                              # Restore the Cursor position saved by sc
}
print(){
	clear
    lines=${#arrVar[@]}
    # printf -- '- %s\n' "${arrVar[@]}"
    # echo $lines
	for index in $(seq 0 $((lines-1))) ; do
		value="${arrVar[$index]}"
		if [ $(($1)) -eq $index ]
		then
            if [ $(($2)) -eq $((${#value}-2)) ]
            then
                echo -e "${value:0:$((${#value}-2))}""\e[48;5;244m \e[0m"
            else 
			    echo -ne "${value:0:$2}""\e[48;5;244m${value:$2:1}\e[0m""${value:$(($2+1))}"
            fi
		else
			echo -ne "$value"
		fi
		# echo $value
	done
}
save(){
    lines=${#arrVar[@]}
    > $input
	for index in $(seq 0 $((lines-1))) ; do
        value="${arrVar[$index]}"
        echo -e "${value:0:$((${#value}-2))}" >> $input
    done
}

posc=0
posl=0

print

# main program
while read -sN1 acc
do
    # the read mode, credit to EIS https://github.com/Geronymos/EIS/blob/main/eis.sh
    read -sN1 -t 0.0001 k1
    read -sN1 -t 0.0001 k2
    read -sN1 -t 0.0001 k3
    acc+=${k1}${k2}${k3}

    # echo $acc
    # timedout_read 1 acc
    # echo $acc
    # if [ -n $key ];then
    #     acc=$key
    #     echo $acc| tr -d "\n" | od -An -t dC
    # fi
    # continue
    # if [[ "$key" == "l" ]]; then
    #     exit
    # fi
    if [[ "$mode" -eq 0 ]]
    then
        case $acc in
            $'l') posl=$posl+1 ;;
            $'h') posl=$posl-1 ;;
            $'j') posc=$posc+1 ;;
            $'k') posc=$posc-1 ;;
            $'i') mode=1 ;;
            $':')
                print posc posl
                print_in_bottom 'left' ':'
                # read more
                read -n1 acc 
                print posc posl
                print_in_bottom 'left' ':'$acc
                case $acc in
                    $'w') 
                        save
                        print_in_bottom 'right' 'SAVE SUCCESSFULLY!' 'yellow' ;;
                    $'q') 
                        exit ;;
                esac
                continue
        esac
    elif [[ "$mode" -eq 1 ]]
    then
        case "$acc" in
            $'\x1b') # esc key 
                mode=0 ;; 
            $'\x7f') # back key
                if [[ "$posl" -gt 0 ]] ;then
                    value="${arrVar[$posc]}"
                    value="${value:0:$(($posl-1))}${value:$(($posl))}"
                    arrVar[$posc]="$value"
                    posl=$posl-1
                else # the line should be moved to the previous one.
                    # [0...posc-1][posc+1...end]
                    if [[ "$posc" -gt 0 ]] ;then # if it is the first line, there is no need to move
                        newVar=("${arrVar[@]:0:$((posc))}")
                        newVar+=("${arrVar[@]:$((posc+1))}")
                        posl=${#arrVar[$((posc-1))]}-2
                        newVar[$((posc-1))]="${newVar[$((posc-1))]:0:$((${#arrVar[$posc-1]}-2))}${arrVar[$((posc))]}"
                        arrVar=("${newVar[@]}")
                        posc=$posc-1
                    fi
                fi ;;
            $' ') 
                value=${arrVar[$posc]}
                value="${value:0:$(($posl))} ${value:$(($posl))}"
                arrVar[$posc]=${value}
                posl=$posl+1 ;;
            $'\n') # enter key
                    # [0..posc][""][posc+1]
                newVar=("${arrVar[@]:0:$((posc+1))}")
                newVar+=("\n")
                newVar+=("${arrVar[@]:$((posc+1))}")
                newVar[posc]="${arrVar[posc]:0:posl}""\n"
                newVar[((posc+1))]="${arrVar[posc]:posl}"
                arrVar=("${newVar[@]}")
                posc=$posc+1
                posl=0
                ;;
            *)  value="${arrVar[$posc]}"
                value="${value:0:$(($posl))}$acc${value:$(($posl))}"
                arrVar[$posc]="$value"
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
    if [[ "$mode" -eq 0 ]]
    then
        print_in_bottom 'left' '-- VIEW --'
    elif [[ "$mode" -eq 1 ]]
    then
        print_in_bottom 'left' '-- EDIT --'
    fi
    print_in_bottom 'right' 'Position:'$((posc)):$((posl))

done
