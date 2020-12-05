#!/bin/sh -e

find $(git ls-files)\
	\( -printf 'chown -h %U -- "%p"\n' \) \
	\( -printf 'chgrp -h %G -- "%p"\n' \) \
	\( -printf 'touch -h -c -d "%AY-%Am-%Ad %AH:%AM:%AS" -- "%p"\n' \) \
	! -type l \( -printf 'chmod %#m -- "%p"\n' \) ;

