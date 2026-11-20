#!/usr/bin/env bash
# usage: bench.sh <project-dir> <label> [trials]
# One trial = one fresh sbt JVM running:
#   clean; compile; nativeLink; nativeLink; <1-line edit>; nativeLink
set -euo pipefail
DIR=$1; LABEL=$2; N=${3:-3}
OUT=/home/user/sn-bench-results/$LABEL; mkdir -p "$OUT"
cd "$DIR"
for i in ${TRIAL:-$(seq 1 "$N")}; do
  git checkout -q -- src/main/scala/bench/Main.scala
  start=$(date +%s%N)
  sbt -batch -Dsbt.task.timings=true \
    clean compile nativeLink nativeLink \
    'eval { val p = java.nio.file.Paths.get("src/main/scala/bench/Main.scala"); java.nio.file.Files.writeString(p, java.nio.file.Files.readString(p).replace("bench v1", "bench v2")) }' \
    nativeLink > "$OUT/run$i.log" 2>&1
  end=$(date +%s%N)
  echo "wall_ms=$(( (end-start)/1000000 ))" >> "$OUT/run$i.log"
  git checkout -q -- src/main/scala/bench/Main.scala
  echo "$LABEL run$i done: $(( (end-start)/1000000 )) ms"
done
