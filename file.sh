#!/bin/sh

###############################################################################
# Manages .epub files
#
# Usage:
# ./file.sh add path/to/file.epub
# ./file.sh del path/to/file.epub (must be in LIB_DIR/Files)
# ./file.sh info path/to/file.epub OR ./file.sh info [tai] path/to/file.epub
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

# ---

mkdir -p $WORK_DIR
mkdir -p $FILES_DIR

# ---

if [ "X$COMMAND" = "Xadd" ]; then
	filepath=`get_abs_path "$2"`
	if [ ! -s "$filepath" ]; then
		echo "File does not exist!"
		echo "$filepath"
		exit 1
	fi

	newname=`java -Dfile.encoding=UTF8 -cp $EPUBMAN_DIR/java/classes:$EPUBMAN_DIR/java/lib/* epubman.EpubCli f "$filepath" 2> $WORK_DIR/file_add_out2.log`
	newpath="$FILES_DIR/$newname"

	echo "Adding file\n\t$newpath"
	cp "$filepath" "$newpath"

	if $INDEX_NEW_FILES ; then
		$EPUBMAN_DIR/index.sh add "$newpath"
	fi

	if $DEVICE_NEW_FILES ; then
		$EPUBMAN_DIR/device.sh add "$newpath"
	fi

	$EPUBMAN_DIR/label.sh 

elif [ "X$COMMAND" = "Xdel" ]; then
	filepath=`get_abs_path "$2"`
	if [ ! -s "$filepath" ]; then
		echo "File does not exist!"
		exit 1
	fi

	if [[ "$filepath" =~ ^"$FILES_DIR"* ]]; then
		$EPUBMAN_DIR/index.sh del "${filepath}"
		$EPUBMAN_DIR/device.sh del "${filepath}"
		echo "Removing file\n\t${filepath}"
		rm "${filepath}"
	else
		echo "ERROR: File is not in the library!"
		echo "Can delete only from:\n\t$FILES_DIR"
		exit 1
	fi

elif [ "X$COMMAND" = "Xinfo" ]; then
	if [ "X$3" = "X" ]; then
		c="tai"
		f=$2
	else
		c=$2
		f=$3
	fi
	args=$@
	args=${args:5}
	java -Dfile.encoding=UTF8 -cp $EPUBMAN_DIR/java/classes:$EPUBMAN_DIR/java/lib/* epubman.EpubCli "$c" "$f" 2> $WORK_DIR/file_info_out2.log
fi
