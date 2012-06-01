#!/bin/sh

###############################################################################
# Manages indices for .epub files stored in the LIB_DIR/Files
# Normally you don't need to run this script, file.sh does that for you instead
#
# Usage:
# ./index.sh [add|del] [path/to/file.epub]
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

COMMAND=$1
FILE=$2

# ---

mkdir -p $WORK_DIR
mkdir -p $INDEX_AUTHORS

# ---

add_file() {
	echo "Adding indices for\n\t$1"
	filename=`basename "$1"`
	$EPUBMAN_DIR/file.sh info a "$1" | tr ';' '\n' > $WORK_DIR/authors.txt
	while read line; do
		mkdir -p "${INDEX_AUTHORS}/${line}"
		ln -sf "../../Files/$filename" "$INDEX_AUTHORS/$line/$newfilename"
	done < $WORK_DIR/authors.txt
	rm $WORK_DIR/authors.txt
}

del_file() {
	echo "Removing indices for\n\t$1"
	filename=`basename "$1"`
	find "${INDEX_AUTHORS}" -type l -exec ls -l {} \; | grep "$filename" | sed "s/->.*//" | sed "s,.*${INDEX_AUTHORS},${INDEX_AUTHORS}," > $WORK_DIR/links.txt
	if [ -s "$WORK_DIR/links.txt" ] ; then
		while read line; do
			#echo "\t\t"$line
			rm "$line"
		done < "$WORK_DIR/links.txt"
	fi
	#rm $WORK_DIR/links.txt
}

# ---

if [ "X$COMMAND" = "Xadd" ]; then
	if [ "X$FILE" != "X" ]; then
		add_file "$FILE"
	else
		rm -rf $INDEX_AUTHORS
		mkdir -p $INDEX_AUTHORS
		ls "$FILES_DIR" > "$WORK_DIR/files.txt"
		while read line; do
			add_file "$FILES_DIR/$line"
		done < $WORK_DIR/files.txt
		rm $WORK_DIR/files.txt
	fi
elif [ "X$COMMAND" = "Xdel" ]; then
	if [ "X$FILE" != "X" ]; then
		del_file "$FILE"
	else
		rm -r "${INDEX_AUTHORS}/*"
	fi
fi

# cleanup empty dirs (always)
echo "Index cleanup"
find "${INDEX_AUTHORS}" -name "${INDEX_AUTHORS}/*" -type d -empty > "$WORK_DIR/empty.txt"
if [ -s "$WORK_DIR/empty.txt" ] ; then
	while read line; do
		echo "Removing empty dir\n\t$line"
		rm -r "$line"
	done < "$WORK_DIR/empty.txt"
fi
rm "$WORK_DIR/empty.txt"