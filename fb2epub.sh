#!/bin/bash

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

EPUB_FILE=`echo "$FILE" | sed 's/.fb2/.epub/'`
echo $EPUB_FILE

java -jar $EPUBMAN_DIR/java/lib/fb2epub-0.3.0.jar "${FILE}" "${EPUB_FILE}"
