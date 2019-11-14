#!/bin/bash

PARSEDB='parsedb.awk'

FAIL(){
	printf "[L%0.4d] ERROR: %s\n" "$2" "$3" 1>&2
	[ $1 -eq 1 ] && exit 1
}

SHOWALL="false"

while [ "$1" ]; do
	case $1 in
		-h|--help|-\?)
			printf "SYNTAX: ${0##*/} [OPTS] FILE\n"
			exit 0 ;;
		-va|--show-all)
			SHOWALL="true" ;;
		-f|--first-names)
			COLNUM=3 ;;
		-l|--last-names)
			COLNUM=2 ;;
		-s|--social-media)
			COLNUM=9 ;;
		-b|--browser)
			COLNUM=8 ;;
		-E)
			# Not sure what the point in this is:
			printf "1054429-1054406\n"
			exit 0 ;;
		-*)
			FAIL 1 "$LINENO" "Incorrect argument(s) specified." ;;
		*)
			break ;;
	esac
	shift
done

declare -i DEPCOUNT=0
for DEP in awk uname; {
	if ! type -fP "$DEP" > /dev/null 2>&1; then
		FAIL 0 "$LINENO" "Dependency '$DEP' not met."
		DEPCOUNT+=1
	fi
}

[ $DEPCOUNT -eq 0 ] || exit 1

if ! { [ -f "$*" ] && [ -r "$*" ]; }; then
	FAIL 1 $LINENO "Input file missing or inaccessible."
else
	FILENAME=$*
fi

if [ "$SHOWALL" == 'true' ]; then
	# Skips the lines beginning with '#' (comment).
	awk -F "|" '!/^#/' "$1"
	exit $?
elif [ -n $COLNUM ]; then
	if [ -f "$PARSEDB" ] && [ -r "$PARSEDB" ]; then
		# Must be executed in the same directory as the files.
		awk -v T="$(uname -s)" -v C=$COLNUM -f "$PARSEDB" "$FILENAME"
	else
		FAIL 1 $LINENO "File '$PARSEDB' missing or inaccessible."
	fi
fi

#----------------------------------------------------------------------------------
#	3)
#		shift
#		case $1 in
#			-f)
#				FILENAME=$1
#				let --offset ;;
#		esac
#	4)
#		# Variable used to determine desired argument's <> position.
#		offset=2
#
#		# Determines which awk will be executed.
#		bornMode=0
#
#		while [ $# -gt 0 ]
#		do
#			case $1 in
#				-f)
#					# Filename variable gets the content of the
#					# offset argument.
#					FILENAME=${!offset} ;;
#				-id)
#					id=${!offset} ;;
#				--born-until)
#					date=${!offset}
#					printf -v date "%d" "${date//-}"
#					bornMode=1 ;;
#				--born-since)
#					date=${!offset}
#					# Echo born $position and $# and $date.
#
#					# Ensure integer, by globally removing '-'.
#					printf -v date "%d" "${date//-}"
#					bornMode=2 ;;
#			esac
#			shift
#		done
#
#		case $bornMode in
#		0) # Runs Search with ID
#			# The -v flag declares a variable to be used internally.
#			# Also --> $1 ~ "^"pat"$" <-- means that.
#			awk -F "|" -v pat="$id" '
#				$1 ~ "^"pat"$"{print $2 " " $3 " " $5}
#			' $FILENAME ;;
#
#		# The search is ONLY on the ID field ($1) searching for the EXACT
#		# pattern (^ &).
#		1) # Runs born until
#			# Creates a temporary file containing IDs matching the
#			# --born-until condition.
#			awk -F "|" '/#/ {next} {print $1 " " $5}' $FILENAME\
#				| tr -d '-'\
#				| awk '$2<='"$date"'{print $1}' > ids.tmp
#
#			# Finds and prints the lines from the input file whose id's
#			# are the same with the ids.temp, -w for identical strings.
#			grep -w -f ids.tmp $FILENAME
#
#			# Remove the temporary file.
#			rm ids.tmp ;;
#
#			# The temp file is created so the dates will have the
#			# "right" format Y-m-d, otherwise the Y m d would not be
#			# separated with `-`, according to this implementation.
#		2) # Runs born since
#			# Creates a "temporary" file containing IDs matching the
#			# --born-since condition.
#			awk -F "|" '/#/ {next} {print $1 " " $5}' $FILENAME\
#				| tr -d '-'\
#				| awk '$2>='"$date"'{print $1}' > ids.tmp
#
#			# Finds and prints the lines from the input file whose IDs
#			# are the same with the `ids.temp`.
#			grep -w -f ids.tmp $FILENAME
#
#			# Remove the temporary file.
#			rm ids.tmp ;;
#		esac ;;
#	6)
#		offset=2
#		while [ $# -gt 0 ]
#		do
#			case $1 in
#				-f)
#					# Filename variable gets the content of the
#					# #offset argument.
#					FILENAME=${!offset} ;;
#				--born-since)
#					dateA=${!offset}
#
#					# Delete the `-` from the date parsed in
#					# the arguments, so the date will be
#					# treated as an int e.g. '1980-21-30' will
#					# be '19802130'.
#					printf -v dateA "%d" "${dateA//-}"
#
#					mode=0 ;;
#				--born-until)
#					dateB=${!offset}
#
#					# Delete the `-` from the date parsed in
#					# the arguments, so the date will be
#					# treated as an int e.g. '1980-21-30' will
#					# be '19802130'.
#					printf -v dateB "%d" "${dateB//-}" ;;
#				--edit)
#					id=${!offset}
#					offset=$((offset+1))
#					column=${!offset}
#					offset=$((offset+1))
#					value=${!offset}
#					offset=$((offset-2))
#					mode=1 ;;
#				esac
#				shift
#		done
#
#		case $mode in
#			0)
#				awk -F "|" '/#/ {next} {print $1 " " $5}' $FILENAME\
#					| sed 's/-//g'\
#					| awk '$2>='"$dateA"' && $2<='"$dateB"'{print $1}' > ids.tmp
#
#				# Finds and prints the lines from the input file
#				# containing IDs the same as in the `ids.temp`.
#				grep -w -f ids.tmp $FILENAME
#
#				# Remove the temporary file.
#				rm ids.tmp ;;
#			1)
#				if [ $column -gt 1 ] && [ $column -lt 9 ]
#				then
#					# Search for the ID, set Output Field
#					# Seperator to `|`, then replace the value
#					# at the column given in the arguments.
#					awk  -F "|" -v pat="$id" '
#						BEGIN{OFS="|"}
#						$1 ~ "^"pat"$"
#						{
#							$'"$column"' = "'"$value"'"
#						}1
#					' "$FILENAME"
#
#				# To save the change we made we can create a new
#				# file with the "changes", like:
#				#
#				#   awk  -F "|" -v pat="$id" '
#				#   	BEGIN{OFS="|"}
#				#   	$1 ~ "^"pat"$"
#				#   	{
#				#   		$'"$column"' = "'"$value"'"
#				#   	}1
#				#   ' > newFile.tmp
#				fi ;;
#		esac ;;
#esac
