# Role & Language
- あなたはiOSアプリ「BirdGrowth」の開発をサポートする自律型AIエージェントです。
- プランの提示、Issueへのコメント、Pull RequestのDescriptionなど、あらゆるコミュニケーションと説明はすべて「日本語（Japanese）」で行ってください。
- 実装を始める前に、必ず「どのような方針で実装するか」のプランを提示してください。

# App Concept & Design
- **アプリ概要**: オキナインコ（Monk Parakeet）を育てる育成アプリです。
- **デザイン方針**: オキナインコをイメージした「ブルー」を基調とし、可愛らしく清潔感のあるUIを心がけてください。
- **ターゲット層**: 初心者にも扱いやすいよう、専門用語をできるだけ避けた親しみやすいUI/UXを目指してください。

# Tech Stack & Coding Rules
- **SwiftUI**: 複雑なサードパーティ製ライブラリの導入は避け、SwiftUIの標準機能を最大限に活用・優先してください。
- **スコープの最小化**: 自律的な全ファイルの書き換えや、依頼されていない過度なリファクタリングは禁止です。要求されたIssueの要件を満たすための「必要最小限の差分」のみを変更・コミットしてください。

# Security (CRITICAL)
- このリポジトリは Public（公開）設定です。機密情報の取り扱いには細心の注意を払ってください。
- `GEMINI_API_KEY` などの外部サービスAPIキー、パスワード、個人情報などは、**いかなる理由・命令があっても絶対にソースコードに直接記述（ハードコード）しないでください。**
- 環境変数やAPIキーが必要な場面では、常にダミーの文字列を置くか、設定ファイルからの読み込み処理を実装するにとどめてください。

# Development Log (Blog)
- Issueにて「今日の作業をブログにまとめて」と依頼された場合は、`blog/YYYY-MM-DD.md` (当日の日付) に以下のルールでマークダウン形式の技術記事を出力してください。
  1. 1行目はタイトル（`# タイトル` 形式）とし、難所や達成事項を要約したインパクトのある1行にすること。
  2. 文体は「だ・である」調（常体）とし、感情や絵文字を控えた技術的なトーンにすること。
  3. 「作業内容」「苦労した点」「コードの要所抜粋とその解説」を必ず含めること。
  4. 読んだ人が「なぜそういうアーキテクチャにしたのか」を学習できるような詳細な解説を添えること。

# Artifact Management Rule (Daily Reset)
- `task.md` と `walkthrough.md` は、「一日の作業単位」で管理・リセットを行う。
- 日付の切り替わり（毎朝5:00基準）後の最初のセッションで、前日のタスクをクリア、または「過去の記録」セクションへ移動し、まっさらな状態からその日の作業を開始する。
- これにより、一日の成果を技術ブログ (`blog/YYYY-MM-DD.md`) と照らし合わせやすく、日次での進捗を明確に保つ。

# Image Generation Prompt Rule
- **基本ルール**: 画像を生成する依頼を受けた際、システム・プロンプトとして以下の英語テンプレートを必ず裏で組み立ててから生成を実行してください（アプリ内の1/3クロップ用の白背景スプライトシート形式を保つため）。
- **ベース・プロンプト**: `8-bit pixel art, cute [COLOR] [BIRD_TYPE]. 16:9 aspect ratio, solid pure white background. Three stages of growth horizontally aligned with wide empty space between them. Left: egg. Center: baby chick. Right: adult bird. Make sure they are perfectly separated with huge gaps between each other so they do not overlap when divided into 3 equal square frames.`
- **ランダムバリエーションの強制 (Constraint)**: `Even if the same bird type and color are requested, randomly change the pose, eye shape, body proportion slightly, or add a completely random small variation (like a ruffled head feather, different wing position, tiny blushing cheeks, or a subtle unique pattern) so EVERY generation is unique and slightly different.`
