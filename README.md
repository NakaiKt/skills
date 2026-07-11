# skills

Claude 用の **Agent Skills** を一元管理し、Claude Code とアプリ/Web の全面へ配布するためのリポジトリ。

## 設計方針: 単一ソース・全面展開

各スキルは [Agent Skills 標準](https://agentskills.io/specification) 準拠のフォルダ
（`SKILL.md` + 任意の `scripts/` `references/` `assets/`）として **1 箇所** に置く。
標準準拠フォルダはそのままどの面でも動くので、以下すべてに同じソースを展開できる。

```
skills/<name>/SKILL.md   ← 唯一の正 (single source of truth)
        │
        ├─ Claude Code (plugin)      … marketplace 経由で /plugin install・update
        ├─ Claude Code (personal/project) … ~/.claude/skills へ symlink
        └─ Claude アプリ / Web        … zip 化してアップロード
```

## ディレクトリ構成

```
.
├── .claude-plugin/
│   ├── marketplace.json   # このリポジトリを marketplace として公開
│   └── plugin.json        # 全スキルを束ねる 1 プラグインの定義
├── skills/                # ★ スキル本体（各面へ配布される正）
│   └── summarize-text/
│       └── SKILL.md
├── templates/
│   └── skill-template/    # 新規スキルの雛形（skills/ の外なのでロードされない）
│       └── SKILL.md
├── scripts/
│   ├── new-skill.sh       # 雛形から新スキル作成
│   ├── validate.sh        # 全スキルの SKILL.md を検証
│   ├── build-zips.sh      # 各スキルを dist/<name>.zip 化（アプリ用）
│   └── install-local.sh   # ~/.claude/skills へ symlink（plugin を使わない導入）
└── dist/                  # 生成物（gitignore）
```

> `templates/` を `skills/` の外に置いているのは、`skills/` 直下は Claude Code が
> スキルとして自動ロードするため。雛形が誤ってスキル化するのを防ぐ。

## 配布先ごとの使い方

まずローカルのリポジトリを編集（`skills/` にスキルを追加・修正）し、そのうえで
配布先ごとに下記の操作をする。**新規追加**と**更新**で手順が変わるので注意。

### 早見表


| 配布先                                   | 新規スキルを追加                              | 既存スキルを更新                               |
| ------------------------------------- | ------------------------------------- | -------------------------------------- |
| **1. Claude Code (plugin)**           | push → `/plugin marketplace update`   | push → `/plugin marketplace update`    |
| **2. Claude Code (personal/project)** | `scripts/install-local.sh` を実行        | **何もしなくてよい**（編集が自動反映）                  |
| **3. Claude アプリ / Web**               | `scripts/build-zips.sh` → zip をアップロード | `scripts/build-zips.sh` → zip を再アップロード |


---

### 1. local の Claude Code — plugin として

リポジトリ自体が marketplace 兼 plugin。まず一度だけインストールする（GitHub に push 後）:

```
/plugin marketplace add KatsuhiroNakai/skills
/plugin install nakai-skills@nakai-skills
```

- **新規追加も更新も同じ**: ローカルを編集して push → `/plugin marketplace update nakai-skills`。
`plugin.json` に `version` を置いていないため、**push した commit ごとに新バージョン**
として更新が届く。
- スキル名は名前空間付き: `/nakai-skills:summarize-text`。
- ローカル検証（push 前に試す）: `claude --plugin-dir .`

### 2. Claude Code — personal / project スキルとして（plugin を使わない）

名前空間なしの短い名前（`/summarize-text`）で使いたい、または plugin を挟みたく
ない場合。`~/.claude/skills` に **symlink** を張る。

**新規スキルを追加したとき** — スクリプトを実行してリンクを張る:

```bash
scripts/install-local.sh                 # 全スキルを ~/.claude/skills へ symlink
scripts/install-local.sh summarize-text  # 個別
scripts/install-local.sh --project       # このリポジトリの .claude/skills へ
```

**既存スキルを更新したとき** — symlink がリポジトリの実体を指しているので、
`SKILL.md` を編集するだけでセッションに自動反映される。**再実行は不要**。

> 補足: `~/.claude/skills` がセッション開始時に存在しなかった場合のみ、初回リンク後に
> Claude Code の再起動が必要。`--copy`（symlink でなくコピー）を使った場合は、更新の
> たびに `install-local.sh` の再実行が必要になる。

### 3. Claude アプリ / Web（Claude Code・Claude アプリ両方）— アップロード

ファイルアップロード面では zip を渡す。**新規追加も更新も、zip を作って
「スキルを追加（Upload skill）」から入れる**流れは同じ。

```bash
scripts/build-zips.sh                 # dist/*.zip を生成（全スキル）
scripts/build-zips.sh summarize-text  # 個別
```

生成した `dist/<name>.zip` を各アプリの
**Settings → Capabilities → Skills → Upload skill** からアップロードする。

- **新規追加**: そのままアップロードするだけ。
- **更新**: アプリ側に自動更新はないため、zip を作り直し、古いスキルを削除してから
再アップロードする（同名で入れ直す）。

（対応プランや導線の詳細は各アプリの Skills ヘルプを参照。）

## 新しいスキルを追加する

```bash
scripts/new-skill.sh my-skill      # skills/my-skill/SKILL.md を雛形から生成
# SKILL.md の description と本文を編集
scripts/validate.sh                # 命名・frontmatter を検証
```

その後、上記 1〜3 の各導線で配布する。詳細は [docs/adding-skills.md](docs/adding-skills.md)。

## 移植性の注意

`SKILL.md` の本文だけで完結するスキルは全面で同一に動く（同梱の `summarize-text`
が例）。次は **Claude Code 専用**の拡張で、アプリ側では無視される:

- 動的コンテキスト注入 `!`command`` / ````!` ブロック
- `context: fork` / `agent:`（サブエージェント実行）
- `allowed-tools` / `disable-model-invocation` / `user-invocable`

これらに依存するスキルはアプリ側で挙動が変わるため、可搬性を保ちたいスキルでは
使用を避けるか、代替手順を本文に書いておく。

## 命名（marketplace / plugin 名）の変更

`nakai-skills` は公開名（ユーザーが `/plugin install <plugin>@<marketplace>` で打つ）。
変えるときは `.claude-plugin/marketplace.json` の `name` と `plugins[].name`、
`.claude-plugin/plugin.json` の `name` を揃えて更新する。