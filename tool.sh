#!/bin/bash

#TODO: Add ability to compare IDs ($1) from one file to another.
#TODO: Add more verbose help output, showing the many options.

PARSEDB='parsedb.awk'

FAIL(){
	printf "[L%0.4d] ERROR: %s\n" "$2" "$3" 1>&2
	[ $1 -eq 1 ] && exit 1
}

while [ "$1" ]; do
	case $1 in
		-h|--help|-\?)
			printf "SYNTAX: ${0##*/} [OPTS] FILE\n"
			exit 0 ;;
		-a|--show-all)
			SHOWALL="true" ;;
		-f|--first-names)
			COLNUM=3 ;;
		-l|--last-names)
			COLNUM=2 ;;
		-s|--social-media)
			COLNUM=9 ;;
		-b|--browser)
			COLNUM=8 ;;
		-ds|--dob-since)
			shift
			BS_DATE=$1
			BIRTH_SINCE="true" ;;
		-du|--dob-until)
			shift
			BU_DATE=$1
			BIRTH_UNTIL="true" ;;
		--reverse|-R)
			REV='-r' ;;
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

if [ "$REV" == '-r' ] && ! [ "$BIRTH_SINCE" == 'true' -o "$BIRTH_UNTIL" == 'true' ]; then
	FAIL 1 "$LINENO" "Option '-R|--reverse' applies only to DOB filtering."
fi

if [ -n "$BIRTH_SINCE" -o -n "$BIRTH_UNTIL" ]; then
	if ! [[ $BS_DATE =~ [0-9]+-[0-9]+-[0-9]+$ ]]\
	&& ! [[ $BU_DATE =~ [0-9]+-[0-9]+-[0-9]+$ ]]; then
		FAIL 1 "$LINENO" "Filtering by DOB requires a 'YYYY-MM-DD' date."
	fi
fi

declare -i DEPCOUNT=0
for DEP in awk uname sort; {
	if ! type -fP "$DEP" > /dev/null 2>&1; then
		FAIL 0 "$LINENO" "Dependency '$DEP' not met."
		DEPCOUNT+=1
	fi
}

[ $DEPCOUNT -eq 0 ] || exit 1

OS=`uname -s`

if ! { [ -f "$*" ] && [ -r "$*" ]; }; then
	FAIL 1 $LINENO "Input file missing or inaccessible."
else
	FILENAME=$*
fi

PARSE(){
	if [ -f "$PARSEDB" ] && [ -r "$PARSEDB" ]; then
		# Must be executed in the same directory as the files.
		awk -v T="$OS" -v C=$1 -v OPT=$2 -f "$PARSEDB" "$FILENAME"
		return $?
	else
		FAIL 1 $LINENO "File '$PARSEDB' missing or inaccessible."
	fi
}

BIRTH_SORT(){
	PARSE 5 "BIRTH_$1-$2" | sort $REV -n -t '|' -k 5
}

if [ "$SHOWALL" == 'true' ]; then
	# Skips the lines beginning with '#' (comment).
	PARSE 0 ALL
	exit $?
elif [ ${COLNUM:-0} -ge 1 -a ${COLNUM:-0} -le 9 ]; then
	PARSE $COLNUM
elif [ "$BIRTH_SINCE" == "true" ]; then
	BIRTH_SORT SINCE "${BS_DATE//-}"
elif [ "$BIRTH_UNTIL" == "true" ]; then
	BIRTH_SORT UNTIL "${BU_DATE//-}"
fi
