#!/usr/bin/env bash
# usage: cpuprof.sh <project-dir> <label> ; runs clean;compile then profiles nativeLink
DIR=$1; LABEL=$2; O=/home/user/sn-bench-results/cpu_$LABEL; mkdir -p $O; cd $DIR
( prev=($(head -1 /proc/stat)); while true; do sleep 0.5; cur=($(head -1 /proc/stat));
  idle=$(( ${cur[4]}+${cur[5]} - ${prev[4]} - ${prev[5]} )); tot=0; for k in 1 2 3 4 5 6 7 8; do tot=$((tot + ${cur[$k]} - ${prev[$k]})); done
  echo "$(date +%s.%N) $(( 100*(tot-idle)/tot ))"; prev=("${cur[@]}"); done ) > $O/cpu.txt &
SP=$!
sbt -batch clean compile nativeLink 2>&1 | while IFS= read -r l; do echo "$(date +%s.%N) $l"; done > $O/sbt.txt
kill $SP
