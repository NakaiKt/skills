# Cursor / Codex への移植

`skills/*/SKILL.md` を正として、Cursor と OpenAI Codex でも同じスキルを使える形に
変換する。Claude 向けの配布（plugin / 個人スキル / zip）と同様、**本体は編集せず、
面ごとのファイルを生成する**。

## なぜこの2面だけ簡単なのか

Agent Skills は「`description` を見てモデルが該当スキルを選び、必要時に本文をロードする」
仕組みに依存する。Cursor と Codex はどちらもファイルベースで、MCP も繋げるため素直に移植
できる。ChatGPT はファイルベースのスキル機構を持たない（Custom GPT / Projects に手で貼る
しかなく、多数スキルの自動選択もできない）ため、ここでは対象外。

| 面 | 受け皿 | 自動選択 | MCP |
|---|---|---|---|
| Cursor | `.cursor/rules/<name>.mdc`（Project Rules） | ○ description で auto-attach | ○ Settings → MCP |
| Codex | `AGENTS.md`（＋ `.codex/skills/`） | △ 常時読み込みの索引で代替 | ○ `~/.codex/config.toml` |

## Cursor

```powershell
# Windows
.\scripts\build-cursor.ps1                 # 全スキル → dist/cursor/.cursor/rules/
.\scripts\build-cursor.ps1 goal-design     # 個別
.\scripts\build-cursor.ps1 -Project        # カレントのリポジトリの .cursor/rules/ へ
```

```bash
# Mac / Linux
./scripts/build-cursor.sh                  # 全スキル → dist/cursor/.cursor/rules/
./scripts/build-cursor.sh goal-design      # 個別
./scripts/build-cursor.sh --project        # カレントのリポジトリの .cursor/rules/ へ
```

- 各スキルは `description` を持ち `alwaysApply: false` の **Agent Requested ルール**になる。
  Cursor のエージェントが description を見て必要時に読み込む（Skills の挙動に最も近い）。
- `references/` は `.cursor/rules/<name>/references/` にコピーし、本文中の相対リンクを
  そのコピー先へ張り替える。エージェントは必要時に自分のツールで開ける。
- 使うとき: `dist/cursor/.cursor` を対象プロジェクト直下にコピーするか、対象プロジェクトで
  `-Project`（Mac/Linux は `--project`）を付けて実行する。

## Codex

```powershell
# Windows
.\scripts\build-codex.ps1                  # 全スキル → dist/codex/AGENTS.md (+ .codex/skills/)
.\scripts\build-codex.ps1 -Project         # カレントに AGENTS.md と .codex/skills/ を生成
```

```bash
# Mac / Linux
./scripts/build-codex.sh                   # 全スキル → dist/codex/AGENTS.md (+ .codex/skills/)
./scripts/build-codex.sh --project         # カレントに AGENTS.md と .codex/skills/ を生成
```

- Codex には description ベースの選択がないため、`AGENTS.md` は**軽量な索引**にする。
  各スキルの発動条件を1行で並べ、「該当する作業に入ったら該当 SKILL.md 全文を読め」と
  指示する。本体は `.codex/skills/<name>/` にコピーしてポインタを解決可能にする。
- 使うとき: `dist/codex/AGENTS.md` と `dist/codex/.codex` を対象プロジェクト直下へ置くか、
  対象プロジェクトで `-Project`（Mac/Linux は `--project`）を実行する。グローバルに効かせたいなら `~/.codex/AGENTS.md`。

## 注意点

- **Notion 系スキル**（`notion-*`）は Notion への読み書きが前提。各ツールで Notion MCP を
  繋がないと動かない（Cursor: Settings → MCP、Codex: `~/.codex/config.toml` の
  `[mcp_servers.*]`）。DB の `data_source_id` は SKILL.md 内に埋め込み済み。
- **`skill-curator`** はこのリポジトリの `docs/skill-map.md` や `references/` を編集する
  メタスキル。他プロジェクトに単独で移しても十分機能しないので、基本はこのリポジトリ内で使う。
- 生成物は `dist/`（gitignore 済み）に出る。`-Project` / `--project` で対象へ置いたファイルは、その
  プロジェクト側で管理する。
- SKILL.md を編集したら再生成する（Claude 版の zip 再アップロードと同じく、生成物に自動同期はない）。
