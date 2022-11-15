#!/bin/bash

files=(
    "tmp/othello_m.txt"
    "tmp/sample.html"
    "tmp/weird.txt"
    "tmp/romeo.txt"
)

links=(
    "https://file.tamarine.me/wl/?id=CaFcNjLMy84BH19WQzRsAmuHdGjtyxQ7&fmode=open"
    "https://file.tamarine.me/wl/?id=nZKd96LXQ2vwyqEBTByovJhQet6b2aot&fmode=open"
    "https://file.tamarine.me/wl/?id=83YfMgV5XBVr38JfMuDzxKYfqxZro0aM&fmode=open"
    "https://file.tamarine.me/wl/?id=uGcJ9M2xub3GSOkKn5gVNnJPaPOk9mYZ&fmode=open"
)

regexs=(
    '"personal"'
    '"http[s]?://"'
    '"in|mark"'
    '"[tT]wo|[tT]raffic"'
    '"two"'
)

src="ruby src/rugrep.rb"

mkdir -p tmp
for i in ${!files[@]}; do
    if test ! -f ${files[$i]}; then
        curl -s ${links[$i]} > ${files[$i]}
    fi
done

rm -f .reportv2

set -x # Turn on debugging for command so I don't have to echo everytime

# Invalid 3 arg match
$src -F -c -o

# Invalid 2 arg match
$src --only-matching --invert-match

# Test no files given
$src ${regexs[@]}

# Test one invalid files given
$src ${regexs[@]} tmp/invalidhaha

# Testing only match and count
$src -o -c ${files[@]} ${regexs[@]}

# Testing only match and count with 2 invalid files
$src -o -c tmp/hehe ${files[@]} tmp/invalid.txt ${regexs[@]}

# Testing only match and count with 2 invalid files with 1 invalid reg
$src -o -c tmp/hehe ${files[@]} tmp/invalid.txt ${regexs[@]} '"[apple"'

# Testing count invert matches
$src -c -v ${files[@]} ${regexs[@]}

# Testing count invert matches with 2 invalid files
$src -c -v ${files[@]} tmp/invalid.txt tmp/ohno.txt ${regexs[@]}

# Testing count invert matches with 2 invalid files with 1 invalid reg
$src -c -v ${files[@]} tmp/invalid.txt tmp/ohno.txt ${regexs[@]} '"[apple"'

# Testing literal match with count
$src -F -c ${files[@]} ${regexs[@]}

# Testing literal match wtih only match
$src -F -o ${files[@]} ${regexs[@]}

# Testing literal match with invert match
$src -F -v ${files[@]} ${regexs[@]}

# Testing invert match for sanity check
$src -v ${files[@]} ${regexs[@]}

# Testing after context with invert match spacing = 2
$src --after-context=2 -v ${files[@]} ${regexs[@]}

# Testing after context with invert match spacing = 0
$src --after-context=0 -v ${files[@]} ${regexs[@]}

# Testing before context with invert match spacing = 2
$src --before-context=2 -v ${files[@]} ${regexs[@]}

# Testing before context with invert match spacing = 0
$src --before-context=0 -v ${files[@]} ${regexs[@]}

# Testing context with invert match spacing = 2
$src --context=2 -v ${files[@]} ${regexs[@]}

# Testing context with invert match spacing = 0
$src --context=0 -v ${files[@]} ${regexs[@]}

# Testing fixed string, count, and invert match altogether
$src -F -c --invert-match ${files[@]} ${regexs[@]}