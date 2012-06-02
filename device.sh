#!/bin/sh

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

mkdir -p $DEVICE_LOCAL_DIR

# ---

if [ "X$COMMAND" = "Xadd" ]; then
	filename=`basename "$FILE"`
	ln -s "../Files/$filename" "$DEVICE_LOCAL_DIR/$filename"

elif [ "X$COMMAND" = "Xdel" ]; then
	filename=`basename "$FILE"`
	rm -f "$DEVICE_LOCAL_DIR/$filename"

elif [ "X$COMMAND" = "Xsync" ]; then
	echo "Syncing Nook with your Library"
	rsync -L -cr --stats --delete --include='*.epub' --exclude='*.*' "$DEVICE_LOCAL_DIR/" "$DEVICE_REMOTE_DIR/"
	echo ""
	echo "Done!"

fi

