#!/bin/bash

export C_RED="\x1b[91m"
export C_GREEN="\x1b[92m"
export C_YELLOW="\x1b[93m"
export C_BLUE="\x1b[94m"
export C_MAGENTA="\x1b[95m"
export C_CYAN="\x1b[96m"
export C_WHITE="\x1b[97m"
export CB_RED="\x1b[91;1m"
export CB_GREEN="\x1b[92;1m"
export CB_YELLOW="\x1b[93;1m"
export CB_BLUE="\x1b[94;1m"
export CB_MAGENTA="\x1b[95;1m"
export CB_CYAN="\x1b[96;1m"
export CB_WHITE="\x1b[97;1m"
export C_RST="\x1b[0m"

print_nl() {
	echo -e "$@"
}

print() {
	echo -ne "$@"
}

error_nl() {
	echo -e "$@" >&2
}

error() {
	echo -ne "$@" >&2
}
