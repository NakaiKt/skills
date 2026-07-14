# skills

Claude 用の **Agent Skills** を一元管理し、Claude Code とアプリ/Web に配布するリポジトリ。

各スキルは `skills/<name>/SKILL.md` を唯一の正として管理する。編集は常に **スキル単位の追加・全体更新** のみ行う（個別ファイルの差分配布はしない）。

## ディレクトリ構成

```
.
├── .claude-plugin/   # marketplace / plugin 定義
├── skills/           # スキル本体（配布される正）
├── templates/        # 新規スキルの雛形
├── scripts/          # 新規作成・検証・配布用スクリプト
└── dist/             # 生成物（gitignore）
```

スクリプトは Windows PowerShell 用（`.ps1`）。PowerShell から実行する。

## 新しいスキルを追加する

1. `.\scripts\new-skill.ps1 my-skill` で雛形を作成
2. `SKILL.md` を編集
3. `.\scripts\validate.ps1` で検証
4. 使う面ごとに下記のどれかで配布

## スキルの入れ方（使う面ごとに選ぶ）

同じスキルでも、使う面によって入れ方が変わる。**面を1つ選び、その手順だけ行う**。

### ターミナルの Claude Code

次の A・B の**どちらか一方**でよい（両方やる必要はない）。

**A. plugin として入れる**（呼び出し名は `/nakai-skills:<skill>`）

初回だけ:

```
/plugin marketplace add NakaiKt/skills
/plugin install nakai-skills@nakai-skills
```

追加・更新は GitHub に push してから:

```
/plugin marketplace update nakai-skills
```

**B. 個人スキルとして入れる**（呼び出し名は `/<skill>`）

```
.\scripts\install-local.ps1              # 全スキルを ~/.claude/skills へ
.\scripts\install-local.ps1 my-skill     # 個別
.\scripts\install-local.ps1 -Project     # このリポジトリの .claude/skills へ
```

コピーではなくリポジトリ本体を指すリンクを張るので、以後 `SKILL.md` を編集すれば**再実行なしで反映される**（更新時にやることはない）。

### アプリ / デスクトップ版の Claude Code

`/plugin` コマンドは使えない。プロンプト欄の **＋ボタン → Plugins** から marketplace 経由で入れる。上の B（`install-local.ps1`）もローカルセッションで使える。

### Claude チャット（claude.ai のチャット）

zip を作ってアップロードする。Claude Code とはスキルが同期しない別の面。

```
.\scripts\build-zips.ps1                 # dist\*.zip を生成（全スキル）
.\scripts\build-zips.ps1 my-skill        # 個別
```

生成した `dist\<name>.zip` を **Settings → Capabilities → Skills → Upload skill** から入れる。更新時は古いスキルを削除してから同名で再アップロードする。

### Cursor / Codex

同じスキルを Cursor と OpenAI Codex でも使える形に変換できる。

```
.\scripts\build-cursor.ps1               # → dist\cursor\.cursor\rules\*.mdc
.\scripts\build-codex.ps1                # → dist\codex\AGENTS.md (+ .codex\skills\)
```

`-Project` を付けるとカレントのリポジトリ直下に直接生成する。手順と注意点（Notion MCP の設定、`skill-curator` の扱いなど）は [docs/porting-cursor-codex.md](docs/porting-cursor-codex.md)。
