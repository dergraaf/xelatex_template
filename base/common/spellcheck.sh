#!/bin/bash
SCRIPTPATH=$( cd "$(dirname "$0")" ; pwd -P )

DICT=$1
shift

for FILE in "$@"
do
  aspell --lang=en --mode=tex --dont-tex-check-comments --encoding=utf-8 \
		--add-tex-command="ac op" \
		--add-tex-command="newacronym ppP" \
		--personal=$DICT --extra-dicts=$SCRIPTPATH/aspell_global.dict \
		check $FILE
done

