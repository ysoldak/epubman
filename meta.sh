#!/bin/bash

###############################################################################
# Edits .epub file metadata
#
# Usage:
# ./meta.sh path/to/file.epub
#
# Requires:
#   Pashua GUI tool to be installed ( http://www.bluem.net/en/mac/pashua/ )
#
###############################################################################


pwd_tmp=`pwd`
cd `dirname "$0"`
EPUBMAN_DIR=`pwd`
cd "$pwd_tmp"
WORK_DIR=$EPUBMAN_DIR/work

# ---

source $EPUBMAN_DIR/epubman.cfg
source $EPUBMAN_DIR/general.inc

# ---

FILE=$1

orig_id=`$EPUBMAN_DIR/file.sh info i "$FILE"`
orig_title=`$EPUBMAN_DIR/file.sh info t "$FILE"`
orig_author=`$EPUBMAN_DIR/file.sh info a "$FILE"`

pashua_run() {

	# Write config file
	pashua_configfile=`/usr/bin/mktemp /tmp/pashua_XXXXXXXXX`
	echo "$1" > $pashua_configfile

	# Find Pashua binary. We do search both . and dirname "$0"
	# , as in a doubleclickable application, cwd is /
	# BTW, all these quotes below are necessary to handle paths
	# containing spaces.
	bundlepath="Pashua.app/Contents/MacOS/Pashua"
	if [ "$3" = "" ]
	then
		mypath=`dirname "$0"`
		for searchpath in "$mypath/Pashua" "$mypath/$bundlepath" "./$bundlepath" \
						  "/Applications/$bundlepath" "$HOME/Applications/$bundlepath"
		do
			if [ -f "$searchpath" -a -x "$searchpath" ]
			then
				pashuapath=$searchpath
				break
			fi
		done
	else
		# Directory given as argument
		pashuapath="$3/$bundlepath"
	fi

	if [ ! "$pashuapath" ]
	then
		echo "Error: Pashua could not be found"
		exit 1
	fi

	# Get result
	result=`"$pashuapath" -e utf8 $pashua_configfile | sed 's/ /;;;/g'`

	# Remove config file
	rm $pashua_configfile

	# Parse result
	for line in $result
	do
		key=`echo $line | sed 's/^\([^=]*\)=.*$/\1/'`
		value=`echo $line | sed 's/^[^=]*=\(.*\)$/\1/' | sed 's/;;;/ /g'`		
		varname=$key
		varvalue="$value"
		eval $varname='$varvalue'
	done

}

# text, textfield, textbox

conf="
*.title = ePub Metadata Editor

id.type = text
id.label = ID
id.default = $orig_id
id.width = 310

title.type = textfield
title.label = Title
title.default = $orig_title
title.width = 310

author.type = text
author.label = Authors
author.default = $orig_author
author.width = 310

cb.type=cancelbutton
"

pashua_run "$conf"

echo "  ID  = $id"
echo "  Title  = $title"
echo "  Author  = $author"
echo "  cb = $cb"

if [ "X$cb" = "X0" ]; then
	# following looks good, but does not work! :(
	# if [ "X$orig_author" != "X$author" ]; then
	# 	authors=`echo $author | sed 's/;/" --author "/g'`
	# 	authors='--author "'$authors'"'
	# 	echo $authors
	# 	#exit 1
	# fi
	java -cp "$EPUBMAN_DIR/java/lib/epublib-tools-3.0-SNAPSHOT-complete.jar" nl.siegmann.epublib.Fileset2Epub $authors --title "$title" --in "$FILE" --out "$WORK_DIR/out.epub" --type "epub" 2>"$WORK_DIR/meta_edit_out2.txt"
	#mv out.epub "$FILE"
	"$EPUBMAN_DIR/file.sh" add "$WORK_DIR/out.epub"
	"$EPUBMAN_DIR/file.sh" del "$FILE"
fi

#rm out.txt
