const fs = require('fs');
const { GoogleGenerativeAI } = require('@google/generative-ai');

// 必要な情報を取得
const apiKey = process.env.GEMINI_API_KEY;
const issueBody = process.env.ISSUE_BODY || "";
const commentBody = process.env.COMMENT_BODY || "";
const instruction = commentBody.replace(/^\/gemini\s*/i, '');

// ターゲットのファイルを直接読み込む（迷子防止）
const filePath = 'BirdGrowth/ContentView.swift';
const fileContent = fs.readFileSync(filePath, 'utf8');

// APIへ渡す指示文（プロンプト）
const prompt = `
あなたは優秀なiOSエンジニアです。
以下のSwiftUIコードを、ユーザーの指示に従って"直接"修正してください。

【リクエスト背景（Issueの内容）】
${issueBody}

【今回の修正指示】
${instruction}

【現在のコード（${filePath}）】
\`\`\`swift
${fileContent}
\`\`\`

出力は必ず修正後の完全なコードのみ（\`\`\`swift 〜 \`\`\` のブロックのみ）にしてください。解説やマークダウン以外の文章は一切不要です。
`;

async function run() {
  const genAI = new GoogleGenerativeAI(apiKey);
  // 高速で安価な標準モデルを指定（これを1回だけ呼ぶのでAPI制限に引っかからなくなります）
  const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash' });
  
  console.log("Gemini APIを呼び出し中...");
  const result = await model.generateContent(prompt);
  let text = result.response.text();
  
  // Markdownの不要なコードブロック記号（```swift や ```）を取り除いて純粋なコードにする
  text = text.replace(/```swift\n?/i, '').replace(/```\n?/g, '').trim();
  
  // 新しい内容で上書き保存
  fs.writeFileSync(filePath, text);
  console.log("ファイルの書き換えが完了しました！");
}

run().catch(console.error);
