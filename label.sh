#/bin/bash

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

# ---

OS=`uname`
if [ "X$OS" != "XDarwin" ]; then
	echo "Can set labels on Mac OS X only"
	exit
fi

echo "Refreshing file labels"

label_file() {
	filename=`basename "$1"`
	#echo "$filename"
	idx=0
	if [ -f "$DEVICE_LOCAL_DIR/$filename" ]; then
		let idx=idx+1
	fi
	if [ -f "$INDEX_LATEST/$filename" ]; then
		let idx=idx+2
	fi
	color=${MAC_LABEL_COLORS[$idx]}
	#echo $idx"/"$color
	osascript -e "set theFile to POSIX file (\"$FILES_DIR"/"$filename\") as alias
	tell application \"Finder\" to set label index of theFile to $color" > "$WORK_DIR/label_out.txt"
}


if [ "X$FILE" != "X" ]; then
	label_file "$FILE"
else
	ls "$FILES_DIR" > "$WORK_DIR/files.txt"
	if [ -s "$WORK_DIR/files.txt" ] ; then
		while read line; do
			label_file "$line"
		done < "$WORK_DIR/files.txt"
	fi
	rm "$WORK_DIR/files.txt"	
fi

