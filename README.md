# claude-cloud-environment

Claude Code のクラウド環境 (claude.ai/code) 用セットアップスクリプト。

## 内容

| ファイル | 役割 |
|---|---|
| `setup.sh` | 入口。同じコミットの各スクリプトを順に実行する |
| `setup-scala.sh` | coursier / scala / scalac / scala-cli / sbt を入れ、プロキシ CA と Maven Central ミラーに対応したラッパーを置く |

## 使い方

環境の設定 (セッションのタイトルバーの環境メニュー → Edit → Setup script) に、コミットハッシュを固定して書く。

```bash
REF=<commit-hash>
curl -fsSL "https://raw.githubusercontent.com/windymelt/claude-cloud-environment/$REF/setup.sh" | CLAUDE_ENV_REF="$REF" bash
```

更新するときは、新しいコミットを push してから Setup script 欄の `REF` を書き換える。
