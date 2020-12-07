#!/bin/sh -e

# save metadata of the current repo
# this script just print to stdout commands which
# must be performed to restore for all files in repo:
# file's ownerships, file's permissions and file's creation date
find \
	\( -printf 'chown -h %U -- "%p"\n' \) \
	\( -printf 'chgrp -h %G -- "%p"\n' \) \
	! -type l \( -printf 'chmod %#m -- "%p"\n' \) ;