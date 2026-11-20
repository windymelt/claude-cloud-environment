#!/usr/bin/env bash
for t in 1 2 3; do
  for x in base A B C D1 D2 E1 E2 F; do
    TRIAL=$t /home/user/sn-bench-tools/bench.sh /home/user/sn-wt/$x/scala-native-build-bench $x
  done
done
echo ALL_DONE
