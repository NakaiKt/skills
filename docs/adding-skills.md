# スキルの追加・更新ガイド

## 1. 作る

```powershell
.\scripts\new-skill.ps1 <skill-name>
```

`skills/<skill-name>/SKILL.md` が雛形から生成される。`<skill-name>` は
Agent Skills の命名規則に従うこと:

- 1〜64 文字、小文字英数字とハイフンのみ
- 先頭・末尾のハイフン不可、連続ハイフン `--` 不可
- **`SKILL.md` の `name:` とフォルダ名は一致必須**

## 2. 書く

`SKILL.md` は「YAML frontmatter + Markdown 本文」。

必須:

| フィールド | 制約 |
|---|---|
| `name` | フォルダ名と一致 |
| `description` | 最大 1024 文字。**何をする／いつ使う** を、モデルが拾うキーワードと共に。重要な用途を先頭に |

本文は 500 行以内を目安に。長い参照資料は `references/` に分け、`SKILL.md` から
相対パスで参照して必要時のみロードさせる:

```
skills/<name>/
├── SKILL.md
├── scripts/      実行スクリプト（Bash/Python/JS）
├── references/   詳細ドキュメント（オンデマンド読み込み）
└── assets/       テンプレート・画像・データ
```

## 3. 検証

```powershell
.\scripts\validate.ps1
```

`skills-ref`（公式 CLI）が入っていればそれを、無ければ組み込みの簡易チェックを使う。

公式 validator を使いたい場合:

```bash
# https://github.com/agentskills/agentskills の skills-ref を導入
skills-ref validate ./skills/<skill-name>
```

## 4. 配布する

| 面 | コマンド／操作 |
|---|---|
| Claude Code (plugin) | push → `/plugin marketplace update nakai-skills` |
| Claude Code (personal/project) | `.\scripts\install-local.ps1 [<name>]` |
| Claude アプリ / Web | `.\scripts\build-zips.ps1 [<name>]` → `dist/<name>.zip` をアップロード |

## 更新のモデル

- **plugin 版**: `plugin.json` に `version` を置いていないため、git commit の SHA が
  バージョンになる。push するたびに `/plugin marketplace update` で最新が届く。
  リリースを明示的に区切りたくなったら `plugin.json` に `version` を追加し、以後は
  変更のたびに手動で上げる運用へ切り替える。
- **junction 版**: `SKILL.md` の編集がセッションに即反映（本文のみ。`hooks/` 等の
  構造変更は `/reload-plugins` が必要）。
- **アプリ版**: zip を作り直して再アップロード（アプリ側に自動更新はない）。

## 複数プラグインに分割したくなったら

現状は「1 リポジトリ = 1 marketplace = 全スキルを束ねた 1 plugin」。カテゴリ別に
分けたい場合は `plugins/<plugin-name>/` を作り、それぞれに `.claude-plugin/plugin.json`
と `skills/` を置き、`marketplace.json` の `plugins[]` に列挙する。プラグインは自分の
ディレクトリ外（`../`）を参照できない点に注意（共有はシンボリックリンクで）。
