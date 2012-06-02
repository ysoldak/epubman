FILES_DIR=$LIB_DIR/Files
INDEX_ROOT=$LIB_DIR/Index
INDEX_AUTHORS=$INDEX_ROOT/Authors
DEVICE_LOCAL_DIR=$LIB_DIR/Device

# ---

get_abs_path() {
    local PARENT_DIR=$(dirname "$1")
    cd "$PARENT_DIR"
    local ABS_PATH="$(pwd -P)"/"$(basename "$1")"
    cd - >/dev/null
    echo $ABS_PATH
}
