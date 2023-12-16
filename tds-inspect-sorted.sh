#!/usr/bin/env zsh
file=/tmp/tds-tmp-`date +%s.%N`
./tds-inspect.sh >${file}
header="$(head -n 1 ${file})"
n="$(echo $header | awk '{print $2}')"
echo $header
tail -n +2 $file | head -n $n | sort -k 10,10
tail -n 3 $file
rm $file
