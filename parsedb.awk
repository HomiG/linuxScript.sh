#!/bin/awk

#----------------------------------------------------------------------------------
# Project Name      - parsedb.awk
# Started On        - Thu 14 Nov 17:08:25 GMT 2019
# Last Change       - Thu 14 Nov 22:10:58 GMT 2019
# Author E-Mail     - terminalforlife@yahoo.com
# Author GitHub     - https://github.com/terminalforlife
#----------------------------------------------------------------------------------
# USAGE: awk -v T="$(uname -s)" C=$column_mode -f parseawk.awk dataSet.dat
#----------------------------------------------------------------------------------

#TODO: Needs more verbose usage, above.

BEGIN{
	if(length(OPT) > 0){
		# If exists special options, don't check variables, and skip `END`.
		IGNORE_END=1
	}else{
		if(length(T) == 0){
			MSG="Missing `-v T=$(uname -s)` when calling awk."
			printf("ERROR: %s\n", MSG) > "/dev/stderr"
			DO_EXIT++
		}else if(length(C) == 0){
			MSG="Missing `-v C=$column_mode` when calling awk."
			printf("ERROR: %s\n", MSG) > "/dev/stderr"
			DO_EXIT++
		}else if(C !~ /^[1-9]$/){
			MSG="Invalid column mode for `C` when calling awk."
			printf("ERROR: %s\n", MSG) > "/dev/stderr"
			DO_EXIT++
		}
	}

	if(DO_EXIT > 1){
		# Avoids `END` still being processed.
		IGNORE_END=1

		exit 1
	}

	FS="|"
}

{
	if(OPT ~ /^BIRTH_(SINCE|UNTIL)-/){
		if(NR != 1){
			if(OPT ~ /_SINCE-/){
				OLD5=$5
				gsub(/-/, "", $5)
				if($5 > substr(OPT, 13, 8)){
					printf("%s|%s|%s|%s|%s|%s|%s|%s|%s\n", $1,\
						$2, $3, $4, OLD5, $6, $7, $8, $9)\
						| "sort -rn -t '|' -k 5"
				}
			}else if(OPT ~ /_UNTIL-/){
				print
			}else{
				MSG="Invalid 'BIRTH_*' -- use 'SINCE' or 'UNTIL'."
				printf("ERROR: %s\n", MSG) > "/dev/stderr"
				exit 1
			}
		}
	}else if(OPT ~ /^ALL$/){
		if(NR!=1){
			print
		}
	}else{
		if(NR != 1){
			# Assign the X associative array variable's index, based on the
			# name of the current line's field, which itself then gets an
			# integer value and is incremented for each time it's discovered.
			X[$C]++
		}
	}
}

# Just saves repeating code, and makes the `END` block a bit cleaner.
function output(P){
	printf("%-20s %-d\n", P, X[I])
}

END{
	# Don't execute this code if told to exit in `BEGIN`.
	if(IGNORE_END != 1){
		printf("%-20s %-s\n", "COLUMN", "TOTAL")

		# Iterate over each index in the X associative array variable,
		# where I is equal to the name of the field in the database. T
		# requires `-v T=$(uname -s)` be used, when calling for awk on a
		# terminal.
		for(I in X){
			# Remove suffixed `^M` if on Linux. (we use `\n`) The ninth
			# field (at the end thereof) must have the ^M character, -
			# in order for the first condition set to be successful.
			if(C==9 && T ~ /^[lL]inux$/){
				A=substr(I, 0, length(I)-1)
				output(A)
			}else{
				output(I)
			}
		}
	}
}
