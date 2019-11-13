#!/bin/bash 


#First case "desides" what part of code will be executed according the number of arguments that have been parsed.
#⬇⬇⬇
case "$#" in
"0")
		echo 1054429-1054406
		;;
"2")
		if [ $1 = "-f" ]
			then
			awk -F "|" '/#/ {next} {print}' $2	#skips the lines that contain # 
		fi
	;;
"3")
		offset=1
		while [ $# -gt 0 ] 
		do
		   case $1 in
			  -f)
			  	offset=$[offset+1]
				filename=${!offset}	#filename variable gets the content of the #offset (e.g. $3) argument. 
			  	offset=$[offset-1]
				;;
			  --firstnames)
			  		columne_mode='$3'	# $3 is the collumn that contains firstnames	
				;;
			  --lastnames)
			   		columne_mode='$2'	# $2 is the collumn that contains lastnames
				;;
			  --socialmedia)
					columne_mode='$9'	# $9 is the collumn that contains social media
				;;	
				
		   esac
			shift
		done
		
		if [[ "$columne_mode" == '$2' || "$columne_mode" == '$3' ]]
		then
			awk -F "|" '{print '"$columne_mode"' | "sort" }' $filename | uniq
		fi
		
		if [ "$columne_mode" == '$9' ]
		then
			awk -F "|" '{print $9 | "sort" }' dates.dat | uniq -c | tr -dc '[:print:]\n'| awk '{print $2 " " $1}'	#First awk prints the socialMediaUsed Sorted, then the uniq -c counts how many times each
																													#socialMedia appears in the list. (The tr -dc... prevent column text overwriting on "Terminal 
																													#printing" by striping the special characters.) Finally the last awk prints the data at the right
																													#order. P.S. The last 2 pipelines are being used in order print social media and times used
																													#in the right order which is --> SOCIAL MEDIA # <-- and not # SOCIAL MEDIA...
		fi
	;;
"4") 
		offset=2	#variable used to determine desired argument's <> position.
		bornMode=0 #determins what awk will be executed.
		
		while [ $# -gt 0 ] 
		do
		   case $1 in
			  -f)
				filename=${!offset}	#filename variable gets the content of the #offset argument. 
				;;
			  -id)
				id=${!offset}
				;;
				
			  --born-until)
			  	date=${!offset}
				date=$(echo -n $date | sed 's/-//g') #Delete the - from the date parased in the arguments, so the date will be treated as an int e.g. 1980-21-30 will be 19802130
			  	bornMode=1
				;;
			  --born-since)
			 	date=${!offset}
				#echo born position $position and $# and $date
				date=$(echo -n $date | sed 's/-//g') #Delete the - from the date parased in the arguments, so the date will be treated as an int
			  	bornMode=2
			  	;;
				

		   esac
			shift
		done
		
		case $bornMode in
		0) # Runs Search with ID
			awk -F "|" -v pat="$id" '$1 ~ "^"pat"$" {print $2 " " $3 " " $5}' $filename	#-v declears a variable that will be used in awk. Also --> $1 ~ "^"pat"$" <-- means that 
		;;																	#the search is ONLY on the ID field ($1) searching for the EXACT patern (^ &)
		1) # Runs born until
		
			awk -F "|" '/#/ {next} {print $1 " " $5}' $filename | sed 's/-//g' | awk '$2<='"$date"'{print $1}' > ids.tmp # Creates a "temporary" file that contains the IDS that match the condition --born-until
			grep -w -f ids.tmp $filename	#Finds and prints the lines from the input file which ids are the same with the ids.temp, -w for identical strings
			rm ids.tmp	#remove the temporary file.
			# The temp file is created so the dates will have the "right" format Y-m-d, otherwise the Y m d would not be seperated with - , according to this implemetation.
		;;
		2) # Runs born since
		
			awk -F "|" '/#/ {next} {print $1 " " $5}' $filename | sed 's/-//g' | awk '$2>='"$date"'{print $1}' > ids.tmp # Creates a "temporary" file that contains the IDS that match the condition --born-since
			grep -w -f ids.tmp $filename	#Finds and prints the lines from the input file which ids are the same with the ids.temp
			rm ids.tmp	#remove the temporary file.
		;;
		esac
	;;

"6") 
		offset=2
		while [ $# -gt 0 ] 
		do
		   case $1 in
			  -f)
				filename=${!offset}	#filename variable gets the content of the #offset argument. 
				;;
			  --born-since)
				dateA=${!offset}
				dateA=$(echo -n $dateA | sed 's/-//g') #Delete the - from the date parased in the arguments, so the date will be treated as an int e.g. 1980-21-30 will be 19802130
				mode=0
			  	;;
			  --born-until)
				dateB=${!offset}
				dateB=$(echo -n $dateB | sed 's/-//g') #Delete the - from the date parased in the arguments, so the date will be treated as an int e.g. 1980-21-30 will be 19802130			
				;;
			  --edit)
			  	id=${!offset}
				offset=$((offset+1))
				column=${!offset}
				offset=$((offset+1))
				value=${!offset}
				offset=$((offset-2))
				mode=1
				;;
			esac
				shift
		done
				
		case $mode in
		0)
			awk -F "|" '/#/ {next} {print $1 " " $5}' $filename | sed 's/-//g' | awk '$2>='"$dateA"' && $2<='"$dateB"'{print $1}' > ids.tmp
			grep -w -f ids.tmp $filename	#Finds and prints the lines from the input file which ids are the same with the ids.temp
			rm ids.tmp	#remove the temporary file.
		;;
		1)
		if [ $column -gt 1 ] && [ $column -lt 9 ]
		then
			awk  -F "|" -v pat="$id" 'BEGIN{OFS="|"} $1 ~ "^"pat"$"{$'"$column"' = "'"$value"'"}1' $filename #Search for the ID, set output Field Seperator | , replace the value at the column given in the arguments
																											 #with the new value.

#------> to save the change we made we can create a new file  with the "changes" like:
# awk  -F "|" -v pat="$id" 'BEGIN{OFS="|"} $1 ~ "^"pat"$"{$'"$column"' = "'"$value"'"}1' > newFile.tmp
			
		fi
		
		
		
		;;
		esac
	;;
	
esac

























