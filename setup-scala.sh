#!/usr/bin/env bash
# Claude Code クラウド環境用: Scala ツールチェーン (coursier / scala / scalac / scala-cli / sbt) のセットアップ
#
# 背景:
#   - HTTPS はエージェントプロキシ経由で、プロキシの CA は /etc/ssl/certs/java/cacerts に入っている。
#     JVM は JAVA_TOOL_OPTIONS でこれを読むが、GraalVM ネイティブ版の cs / scala-cli は読まないため、
#     ラッパーでトラストストアを明示する。
#   - repo1.maven.org が 429 を返すことがあるため、Google の Maven Central ミラーを使う。
set -euo pipefail

CS_HOME=/opt/coursier
CS_BIN="$CS_HOME/bin"
CS_JAR="$CS_HOME/coursier.jar"
WRAP_DIR=/usr/local/bin
MIRROR="https://maven-central.storage-download.googleapis.com/maven2/"
TRUSTSTORE=/etc/ssl/certs/java/cacerts
TS_OPTS="-Djavax.net.ssl.trustStore=$TRUSTSTORE -Djavax.net.ssl.trustStoreType=JKS"

MIRROR_CONF="$CS_HOME/mirror.properties"

export COURSIER_REPOSITORIES="$MIRROR"
export COURSIER_MIRRORS="$MIRROR_CONF"

mkdir -p "$CS_BIN"

# 0. coursier のミラー設定 (アプリ定義に書かれた central もミラーに振り替える)
cat > "$MIRROR_CONF" <<EOF
central.from=https://repo1.maven.org/maven2
central.to=${MIRROR%/}
EOF

# 1. JVM 版 coursier
if [ ! -s "$CS_JAR" ]; then
  curl -fsSL --retry 4 --retry-delay 2 -o "$CS_JAR.tmp" \
    https://github.com/coursier/coursier/releases/latest/download/coursier.jar
  mv "$CS_JAR.tmp" "$CS_JAR"
fi

# 2. Scala ツール (インストール済みならスキップされる)
# shellcheck disable=SC2086
java $TS_OPTS -jar "$CS_JAR" install --install-dir "$CS_BIN" scala scalac scala-cli sbt

# 3. ラッパー
cat > "$WRAP_DIR/cs" <<EOF
#!/usr/bin/env bash
export COURSIER_REPOSITORIES="\${COURSIER_REPOSITORIES:-$MIRROR}"
export COURSIER_MIRRORS="\${COURSIER_MIRRORS:-$MIRROR_CONF}"
exec java $TS_OPTS -jar "$CS_JAR" "\$@"
EOF

cat > "$WRAP_DIR/scala-cli" <<EOF
#!/usr/bin/env bash
export COURSIER_REPOSITORIES="\${COURSIER_REPOSITORIES:-$MIRROR}"
export COURSIER_MIRRORS="\${COURSIER_MIRRORS:-$MIRROR_CONF}"
exec "$CS_BIN/scala-cli" $TS_OPTS "\$@"
EOF

for app in scala scalac; do
  cat > "$WRAP_DIR/$app" <<EOF
#!/usr/bin/env bash
export COURSIER_REPOSITORIES="\${COURSIER_REPOSITORIES:-$MIRROR}"
export COURSIER_MIRRORS="\${COURSIER_MIRRORS:-$MIRROR_CONF}"
exec "$CS_BIN/$app" "\$@"
EOF
done

cat > "$WRAP_DIR/sbt" <<EOF
#!/usr/bin/env bash
export COURSIER_REPOSITORIES="\${COURSIER_REPOSITORIES:-$MIRROR}"
export COURSIER_MIRRORS="\${COURSIER_MIRRORS:-$MIRROR_CONF}"
exec "$CS_BIN/sbt" -Dsbt.override.build.repos=true -Dsbt.repository.config="\$HOME/.sbt/repositories" "\$@"
EOF

chmod +x "$WRAP_DIR/cs" "$WRAP_DIR/scala-cli" "$WRAP_DIR/scala" "$WRAP_DIR/scalac" "$WRAP_DIR/sbt"

# 4. sbt のリポジトリ設定 (ミラーのみ)
mkdir -p "$HOME/.sbt"
cat > "$HOME/.sbt/repositories" <<EOF
[repositories]
  local
  gcs-maven-central: $MIRROR
  sbt-ivy-releases: https://repo.scala-sbt.org/scalasbt/ivy-releases/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext], bootOnly
  sbt-plugin-releases: https://repo.scala-sbt.org/scalasbt/sbt-plugin-releases/, [organization]/[module]/(scala_[scalaVersion]/)(sbt_[sbtVersion]/)[revision]/[type]s/[artifact](-[classifier]).[ext]
EOF

echo "Scala toolchain ready: $(ls "$CS_BIN" | tr '\n' ' ')"
