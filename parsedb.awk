#!/bin/awk

#----------------------------------------------------------------------------------
# Project Name      - parseawk.awk
# Started On        - Thu 14 Nov 17:08:25 GMT 2019
# Last Change       - Thu 14 Nov 18:18:16 GMT 2019
# Author E-Mail     - terminalforlife@yahoo.com
# Author GitHub     - https://github.com/terminalforlife
#----------------------------------------------------------------------------------
# Usage: awk -v T="$OSTYPE" C=$column_mode -f parseawk.awk dataSet.dat
#
# Where C is equal to either `1`, `2`, `3`, etc.
#
# Intended output for '$9' being the value of C:
#
#   PLATFORM             TOTAL
#   Flickr               1326
#   Google+              1104
#   LinkedIn             1105
#   Instagram            1105
#   Youtube              1546
#   Twitter              1325
#   Facebook             1105
#   Blogger              884
#----------------------------------------------------------------------------------

BEGIN{
	if(! T){
		MSG="Missing `-v T=$OSTYPE` when calling awk."
		printf("ERROR: %s\n", MSG) > "/dev/stderr"
		DO_EXIT++
	}else if(! C){
		MSG="Missing `-v C=$column_mode` when calling awk."
		printf("ERROR: %s\n", MSG) > "/dev/stderr"
		DO_EXIT++
	}else if(C !~ /^[1-9]$/){
		MSG="Invalid column mode for `C` when calling awk."
		printf("ERROR: %s\n", MSG) > "/dev/stderr"
		DO_EXIT++
	}

	if(DO_EXIT > 1){
		# Avoids `END` still being processed.
		EXIT_AWK=1

		exit 1
	}

	FS="|"
}

{
	if(NR!=1){
		# Assign the X associative array variable's index, based on the
		# name of the current line's field, which itself then gets an
		# integer value and is incremented for each time it's discovered.
		X[$C]++
	}
}

# Just saves repeating code, and makes the `END` block a bit cleaner.
function output(P){
	printf("%-20s %-d\n", P, X[I])
}

END{
	# Don't execute this code if told to exit in `BEGIN`.
	if(EXIT_AWK != 1){
		printf("%-20s %-s\n", "COLUMN", "TOTAL")

		# Iterate over each index in the X associative array variable, where I is
		# equal to the name of the field in the database. T requires `-v T=$OSTYPE`
		# be used, when calling for awk on a terminal.
		for(I in X){
			# Remove suffixed `^M` if on Linux. (we use `\n`)
			if(/$/&&T~/^linux-gnu$/){
				A=substr(I, 0, length(I)-1)
				output(A)
			}else{
				output(I)
			}
		}
	}
}
