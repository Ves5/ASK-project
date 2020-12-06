#!/bin/sh -e

# save metadata for all the files in the folder given in the first argument
# metadata in the same form as for git repos, look into git_metadata.sh
find $1 \
	\( -printf 'chown -h %U -- "%p"\n' \) \
	\( -printf 'chgrp -h %G -- "%p"\n' \) \
	\( -printf 'touch -h -c -d "%AY-%Am-%Ad %AH:%AM:%AS" -- "%p"\n' \) \
	! -type l \( -printf 'chmod %#m -- "%p"\n' \) ;
