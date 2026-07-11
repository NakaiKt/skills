---
name: notion-knowledge
description: "KatsuhiroのNotionナレッジDBにナレッジを蓄積するスキル。技術的なトラブルシューティング、解決策、ノウハウ、設計メモ、コマンドや手順などを学習した際にこのスキルを使ってNotionに保存する。「ナレッジとして残して」「ノウハウを蓄積して」などのフレーズで必ず使用すること。ユーザーが明示的に頼まなくても、有益な知識が得られたと判断した場合は積極的に提案すること。"
---

# Notionナレッジ蓄積スキル

KatsuhiroのNotionナレッジDBにナレッジを記録・蓄積するためのスキル。

## ナレッジDB情報

- **DB名**: ナレッジDB
- **data_source_id**: `314c77a9-8998-80fa-b6e0-000b649f4438`
- **DB URL**: `https://www.notion.so/314c77a98998808988a8fc7c91a08fdb`

---

## プロパティスキーマ

| プロパティ | 型 | 説明 |
|---|---|---|
| `ナレッジ名` | title (必須) | ナレッジのタイトル。検索しやすい具体的な名前にする |
| `概要` | text | 1〜3文の短い要約。「何を・なぜ・どうする」を簡潔に |
| `テーマ` | multi_select | 下記テーマ一覧から選択。**最大2〜3個まで** |
| `ツール` | multi_select | 下記ツール一覧から選択。**最大2〜3個まで** |
| `ステータス` | status | 新規作成時は `未着手` か `完了` を設定 |

### テーマ一覧（既存）
`設計` / `セキュリティ` / `テスト` / `API` / `認証` / `パフォーマンス` / `CI/CD` / `インフラ` / `AI活用` / `チーム・プロセス` / `UX` / `トラブルシューティング` / `UI` / `生活習慣` / `DB` / `CLI`

### ツール一覧（既存）
`shell` / `Claude Code` / `Notion` / `mac` / `windows` / `Terraform` / `CloudFormation` / `pytest` / `TypeScript` / `React` / `REST` / `Next` / `GraphQL` / `Websocket` / `AWS IoT` / `Python` / `AWS Cognito` / `GitHub Actions` / `AWS IAM` / `API Gateway` / `ACM` / `Route53` / `AWS ECS` / `AWS VPC` / `AWS EC2` / `Codepen` / `Tailwind` / `CSS` / `HTML` / `JavaScript` / `MQTT` / `Github Copilot` / `git`

### タグ付けのルール
- **最大2〜3個**に絞る。迷ったら少ない方を選ぶ
- 既存の選択肢に適切なものがなければ**新規追加してOK**
- `テーマ`は「何について学んだか」、`ツール`は「何を使って解決したか」で選ぶ

---

## アイコン・カバー選定

### アイコン（絵文字）の選定ロジック

**優先順位1: ツールからサービスが特定できる場合**

| ツール | 絵文字 | ツール | 絵文字 |
|---|---|---|---|
| AWS系全般（EC2/ECS/VPC/IAM/Cognito等） | ☁️ | React / Next | ⚛️ |
| TypeScript / JavaScript | 📘 | Python | 🐍 |
| GraphQL | 🔗 | Terraform / CloudFormation | 🏗️ |
| GitHub Actions | 🔄 | Git | 🌿 |
| shell / CLI系 | 💻 | pytest | 🧪 |
| Notion | 📓 | Claude Code | 🤖 |
| Tailwind / CSS | 🎨 | REST / API Gateway | 🔌 |
| Websocket / MQTT / AWS IoT | 📡 | Docker | 🐳 |

**優先順位2: ツールが特定できない場合はテーマから選ぶ**

| テーマ | 絵文字 | テーマ | 絵文字 |
|---|---|---|---|
| 設計 | 📐 | セキュリティ | 🔒 |
| テスト | 🧪 | API | 🔌 |
| 認証 | 🔑 | パフォーマンス | ⚡ |
| CI/CD | 🔄 | インフラ | 🏗️ |
| AI活用 | 🤖 | チーム・プロセス | 👥 |
| UX | 🎨 | トラブルシューティング | 🔧 |
| UI | 🖥️ | 生活習慣 | 🌱 |
| DB | 🗄️ | CLI | ⌨️ |

複数ツール・テーマがある場合は最初のものを基準にする。

### カバー画像（Unsplash）のテーマ別URL

| テーマ | カバー画像URL |
|---|---|
| 設計 | `https://images.unsplash.com/photo-1507238691740-187a5b1d37b8?w=1600&q=80` |
| セキュリティ | `https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=1600&q=80` |
| テスト | `https://images.unsplash.com/photo-1518770660439-4636190af475?w=1600&q=80` |
| API | `https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=1600&q=80` |
| 認証 | `https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=1600&q=80` |
| パフォーマンス | `https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=1600&q=80` |
| CI/CD | `https://images.unsplash.com/photo-1618401471353-b98afee0b2eb?w=1600&q=80` |
| インフラ | `https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=1600&q=80` |
| AI活用 | `https://images.unsplash.com/photo-1677442135703-1787eea5ce01?w=1600&q=80` |
| チーム・プロセス | `https://images.unsplash.com/photo-1522071820081-009f0129c71c?w=1600&q=80` |
| UX | `https://images.unsplash.com/photo-1561070791-2526d30994b5?w=1600&q=80` |
| トラブルシューティング | `https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=1600&q=80` |
| UI | `https://images.unsplash.com/photo-1498050108023-c5249f4df085?w=1600&q=80` |
| 生活習慣 | `https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=1600&q=80` |
| DB | `https://images.unsplash.com/photo-1544383835-bda2bc66a55d?w=1600&q=80` |
| CLI | `https://images.unsplash.com/photo-1629654297299-c8506221ca97?w=1600&q=80` |

テーマが複数ある場合は最初のテーマのURLを使う。テーマ未設定の場合はAI活用のURLで代替する。

---

## ワークフロー

### 1. ナレッジを整理する

1. **ナレッジ名**: 「[ツール名] [動詞] [対象]」形式が検索しやすい  
   例: `npm permissionエラーの解消`, `useCallbackの依存配列の正しい設計`
2. **概要**: 3文以内で問題・解決策・注意点を要約
3. **テーマ・ツール**: 最大2〜3個に絞る。既存にない場合は新規追加OK
4. **ステータス**: 作業済みなら `完了`、後で肉付けするなら `未着手`
5. **アイコン・カバー**: 上記マッピングから決定する

### 2. レコードを作成する

`notion-create-pages` で作成。`icon` と `cover` を必ず含める：

```
parent: { data_source_id: "314c77a9-8998-80fa-b6e0-000b649f4438" }
pages:
  - properties:
      ナレッジ名: "<タイトル>"
      概要: "<要約テキスト>"
      テーマ: '["<テーマ1>"]'
      ツール: '["<ツール1>", "<ツール2>"]'
      ステータス: "完了"
    icon: "<絵文字>"
    cover: "<カバーURL>"
    content: |
      <本文>
```

### 3. ページ本文のフォーマット

```markdown
## 背景・問題
何が起きたか、何をしたかったか

## 解決策・手順
具体的なコードやコマンドを含む

## 注意点・ポイント
ハマりやすいポイント、関連知識

## 参考
関連するURL、ドキュメントなど（あれば）
```

内容によってセクションは柔軟に調整してよい。

### 4. 既存ナレッジの検索・参照

```
notion-search:
  query: "<検索キーワード>"
  data_source_url: "collection://314c77a9-8998-80fa-b6e0-000b649f4438"
```

### 5. 既存ページの更新

`notion-fetch` でページIDを取得後、`notion-update-page` で更新する。

---

## 判断基準：何をナレッジとして残すか

- **トラブルシューティング**: エラー解決、環境構築のハマりポイント
- **設計判断**: アーキテクチャの選択理由、パターンの使い分け
- **コマンド・手順**: 再利用するシェルコマンド、セットアップ手順
- **API・ツールの使い方**: 忘れやすいオプション、挙動の注意点
- **ベストプラクティス**: コードレビューで学んだこと、リファクタリングの知見

---

## 注意事項

- `テーマ` と `ツール` はJSONの配列文字列として渡す: `'["React", "TypeScript"]'`
- `ステータス` に設定できる値: `未着手` / `進行中` / `完了` / `投稿`
- `最終更新日時` は自動設定されるため、プロパティに含めない
- ナレッジ名は日本語・英語どちらでもOK（検索しやすい方を選ぶ）
- カバー画像URLが表示されない場合はAI活用のURLで代替する