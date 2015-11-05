#!/bin/bash
#
#  2015 Magna cum laude. PD
#

if [ $# -lt 2 ]
 then
	echo "Usage: $0 [dir with .lprojs] [dev language (en)] <storyboard(s)> <source file(s)>"
	exit -1
fi

# get command line options
localisation_dir="$1"
dev_language="$2"

# treat rest of command line as references to source material
shift 2

# re-generate strings (in the development language) for storyboard files first
for storyboard
 do
	[[ "$storyboard" =~ .storyboard ]] || break
	shift
	ibtool --generate-strings-file "${localisation_dir}/${dev_language}.lproj/$( basename "${storyboard}" .storyboard ).strings" "$storyboard"
done

# then re-generate strings (in the development language) for all remaining files
genstrings -o "${localisation_dir}/${dev_language}.lproj" "$@"

# enumerate all languages except development and Base
shopt -s nullglob
for lproj in "${localisation_dir}"/*.lproj
 do
	if [[ "$lproj" =~ ${dev_language}.lproj || "$lproj" =~ Base.lproj ]]
	 then continue
	fi

	# enumerate all localisation (.strings) files found in the development language
	for strings in "$( dirname "$lproj" )/${dev_language}.lproj"/*.strings
	 do

		# target the corresponding file in current lproj
		target="${lproj}/$( basename ${strings} )"

		# read each line in the source file, converted to UTF-8
		iconv -f UTF-16 -t UTF-8 "$strings" | while IFS='' read l
		 do

			# skip comments and empty lines
			string_cond="^\""
			if [[ "$l" =~ $string_cond ]]
			 then

				# get the localisation key
				key="$( echo $l | cut -d \" -f 2 )"
				# get its value in the development language
				dev_value="$( echo $l | cut -d \" -f 4 )"

				# find an existing translation in current lproj
				target_value="$( iconv -f UTF-16 -t UTF-8 "$target" 2>/dev/null | grep "^\"${key}\"" | cut -d \" -f 4 )"

				# disqualify existing Xcode placeholders
				placeholder_regex="<#.*#>"

				# if an existing translation was found, replicate in the output
				if [ -n "$target_value" ] && ! [[ "$target_value" =~ $placeholder_regex ]]
				 then echo "\"$key\" = \"$target_value\";"

				# otherwise, write the base language version as placeholder (Xcode token) and report it
				 else echo "\"$key\" = \"<#${dev_value}#>\";"
					echo "Missing localisation(s) in $( basename ${strings} ) for language $( basename ${lproj} .lproj )" >&2
				fi

			# print comments and empty lines as-is
			 else echo "$l"
			fi

		# write a temporary file (as UTF-8)
		done > /tmp/localised.strings

		# find any old strings not found in the current version and append them at the end
		iconv -f UTF-16 -t UTF-8 "$target" | while IFS='' read l
		 do
			string_cond="^\""
			if [[ "$l" =~ $string_cond ]]
			 then
				grep "\"$( cut -d \" -f 2 <<<"$l" )\"" /tmp/localised.strings &>/dev/null || echo "$l"
			fi
		done > /tmp/redundant.strings
		if [ -s /tmp/redundant.strings ]
		 then
			echo $'\n/* Redundant strings:' >> /tmp/localised.strings
			cat /tmp/redundant.strings >> /tmp/localised.strings
			echo " */" >> /tmp/localised.strings
		fi

		# convert into UTF-16 and replace existing translations
		iconv -f UTF-8 -t UTF-16 /tmp/localised.strings > "$target"
		rm /tmp/{localised,redundant}.strings

	# keep enumerating .strings files, then other .lproj directories; aggregate and uniquate all Missing... warnings
	done
done 2>&1 | uniq | tee /tmp/.missing-strings.txt

# exit with error if missing strings were detected
! [ -s /tmp/.missing-strings.txt ]
