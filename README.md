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

スクリプトは2種類用意している。中身は同じで、OS に合わせて選ぶ。

- **Windows**: PowerShell 用の `.ps1`（`.\scripts\xxx.ps1`）
- **Mac / Linux**: bash 用の `.sh`（`./scripts/xxx.sh`）。追加インストールは不要（標準の bash で動く）

以下の例は Windows(`.ps1`) と Mac/Linux(`.sh`) を併記する。オプションの書き方だけ差があり、`.ps1` は `-Project` / `-Copy`、`.sh` は `--project` / `--copy` を使う。

## 新しいスキルを追加する

1. 雛形を作成
   - Windows: `.\scripts\new-skill.ps1 my-skill`
   - Mac/Linux: `./scripts/new-skill.sh my-skill`
2. `SKILL.md` を編集
3. 検証
   - Windows: `.\scripts\validate.ps1`
   - Mac/Linux: `./scripts/validate.sh`
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

```powershell
# Windows
.\scripts\install-local.ps1              # 全スキルを ~/.claude/skills へ
.\scripts\install-local.ps1 my-skill     # 個別
.\scripts\install-local.ps1 -Project     # このリポジトリの .claude/skills へ
```

```bash
# Mac / Linux
./scripts/install-local.sh               # 全スキルを ~/.claude/skills へ
./scripts/install-local.sh my-skill      # 個別
./scripts/install-local.sh --project     # このリポジトリの .claude/skills へ
```

コピーではなくリポジトリ本体を指すリンクを張るので、以後 `SKILL.md` を編集すれば**再実行なしで反映される**（更新時にやることはない）。

### アプリ / デスクトップ版の Claude Code

`/plugin` コマンドは使えない。プロンプト欄の **＋ボタン → Plugins** から marketplace 経由で入れる。上の B（`install-local.ps1` / `install-local.sh`）もローカルセッションで使える。

### Claude チャット（claude.ai のチャット）

zip を作ってアップロードする。Claude Code とはスキルが同期しない別の面。

```powershell
# Windows
.\scripts\build-zips.ps1                 # dist\*.zip を生成（全スキル）
.\scripts\build-zips.ps1 my-skill        # 個別
```

```bash
# Mac / Linux
./scripts/build-zips.sh                  # dist/*.zip を生成（全スキル）
./scripts/build-zips.sh my-skill         # 個別
```

生成した `dist\<name>.zip` を **Settings → Capabilities → Skills → Upload skill** から入れる。更新時は古いスキルを削除してから同名で再アップロードする。

### Cursor / Codex

同じスキルを Cursor と OpenAI Codex でも使える形に変換できる。

```powershell
# Windows
.\scripts\build-cursor.ps1               # → dist\cursor\.cursor\rules\*.mdc
.\scripts\build-codex.ps1                # → dist\codex\AGENTS.md (+ .codex\skills\)
```

```bash
# Mac / Linux
./scripts/build-cursor.sh                # → dist/cursor/.cursor/rules/*.mdc
./scripts/build-codex.sh                 # → dist/codex/AGENTS.md (+ .codex/skills/)
```

Windows は `-Project`、Mac/Linux は `--project` を付けるとカレントのリポジトリ直下に直接生成する。手順と注意点（Notion MCP の設定、`skill-curator` の扱いなど）は [docs/porting-cursor-codex.md](docs/porting-cursor-codex.md)。
