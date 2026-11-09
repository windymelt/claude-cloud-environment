# claude-cloud-environment

Claude Code のクラウド環境 (claude.ai/code) 用セットアップスクリプト。

## 内容

| ファイル | 役割 |
|---|---|
| `setup.sh` | 入口。同じコミットの各スクリプトを順に実行する |
| `setup-claude-md.sh` | `~/.claude/CLAUDE.md` (Proton Pass の使い方) を配置する |
| `setup-proton-pass.sh` | Proton Pass CLI (`pass-cli`) を入れる |
| `setup-sdkman.sh` | SDKMAN を入れる (インストール済みならスキップ) |
| `setup-scala.sh` | coursier / scala / scalac / scala-cli / sbt を入れ、プロキシ CA と Maven Central ミラーに対応したラッパーを置く |
| `setup-cosense-mcp.sh` | Cosense の MCP サーバー (`scrapbox-cosense-mcp`) を `cosense` としてユーザー設定に登録する。PAT は起動時に Proton Pass (`Claude Code` ボールトの `Cosense PAT` アイテム、`PAT` 欄) から取り出す。対象は `windymelt` と `windymelt-20168004` に限定 |

## 使い方

環境の設定 (セッションのタイトルバーの環境メニュー → Edit → Setup script) に、コミットハッシュを固定して書く。

```bash
REF=<commit-hash>
curl -fsSL "https://raw.githubusercontent.com/windymelt/claude-cloud-environment/$REF/setup.sh" | CLAUDE_ENV_REF="$REF" bash
```

更新するときは、新しいコミットを push してから Setup script 欄の `REF` を書き換える。
