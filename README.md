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

## 新しいスキルを追加する

1. `scripts/new-skill.sh my-skill` で雛形を作成
2. `SKILL.md` を編集
3. `scripts/validate.sh` で検証
4. 下記の配布先ごとにやることを実施

## 配布先ごとにやること

### 1. Claude Code（plugin）

push → `/plugin marketplace update nakai-skills`（新規追加・更新とも同じ）

### 2. Claude Code（personal/project、plugin を使わない）

- 新規追加時: `scripts/install-local.sh` を実行
- 更新時: 何もしなくてよい（symlink 経由で自動反映）

### 3. Claude アプリ / Web（zip アップロード）

`scripts/build-zips.sh` で zip を生成し、**Settings → Capabilities → Skills → Upload skill** からアップロードする。

- 新規追加: そのままアップロード
- 更新: 古いスキルを削除してから同名で再アップロード
