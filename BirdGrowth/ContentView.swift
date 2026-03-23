//
//  ContentView.swift
//  BirdGrowth
//

import SwiftUI

struct ContentView: View {
    // MARK: - App State (Variables)
    @State private var steps: Int = 0

    // 画像ガチャ用の状態変数
    @State private var availableSprites: [URL] = [] // Sprites フォルダ内の画像URL一覧
    @State private var currentSpriteURL: URL? = nil // 現在表示中の画像URL

    /// 現在の鳥の名前（表示用：#以降の削除、_ をスペースに置換）
    private var currentBirdName: String {
        guard let name = currentSpriteURL?.deletingPathExtension().lastPathComponent else { return "---" }
        // # 以降を削除
        let baseName = name.components(separatedBy: "#").first ?? name
        // _ をスペースに置換
        return baseName.replacingOccurrences(of: "_", with: " ")
    }

    // 定数定義
    private let chickThreshold = 1000
    private let adultThreshold = 5000
    private let stepIncrement = 1000

    private enum GrowthStage {
        case egg
        case chick
        case adult
    }

    private var stage: GrowthStage {
        switch steps {
        case 0 ..< chickThreshold:
            return .egg
        case chickThreshold ..< adultThreshold:
            return .chick
        default:
            return .adult
        }
    }

    /// 成長段階ごとに入力画像を左右にスライドさせるためのインデックス（0: 卵, 1: ヒナ, 2: 成鳥）
    private var stageIndex: Int {
        switch stage {
        case .egg: return 0
        case .chick: return 1
        case .adult: return 2
        }
    }

    /// 配色：オキナインコのイメージで、ブルー系のやさしいトーン
    private var stageColor: Color {
        switch stage {
        case .egg:
            return Color(red: 1.0, green: 0.98, blue: 0.9)
        case .chick:
            return Color.blue.opacity(0.85)
        case .adult:
            return Color.indigo.opacity(0.85)
        }
    }

    var body: some View {
        ZStack {
            // 背景：ブルーの優しいグラデーション
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.12),
                    Color.cyan.opacity(0.16),
                    Color.blue.opacity(0.10),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 18) {
                Spacer(minLength: 60)

                // 画面中央：大きなインコアイコン＋歩数
                VStack(spacing: 16) {
                    let frameSize: CGFloat = 180

                    // 鳥の名前（画像の上に配置し、レイアウトを固定）
                    VStack {
                        if stage == .adult {
                            Text(currentBirdName)
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.primary)
                                .transition(.opacity.combined(with: .scale))
                        } else {
                            // 非表示中も高さを確保してレイアウト崩れを防ぐ
                            Text(" ")
                                .font(.title3)
                        }
                    }
                    .frame(height: 32)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: stage)

                    ZStack {
                        // AI生成画像のデフォルト背景色（白）に合わせて、キャンバスを真っ白にする
                        Color.white
                        
                        // Folder Reference (Sprites/) から選ばれた画像を読み込む
                        if let url = currentSpriteURL, let uiImage = UIImage(contentsOfFile: url.path) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: frameSize * 3, height: frameSize * 3)
                                .offset(x: frameSize * CGFloat(1 - stageIndex))
                        } else {
                            // 画像がない場合のフォールバック
                            Image(systemName: "bird")
                                .resizable()
                                .scaledToFit()
                                .padding(40)
                                .foregroundStyle(Color.blue.opacity(0.4))
                        }
                    }
                    .frame(width: frameSize, height: frameSize)
                    // 枠全体を角丸にして「一枚の白いディスプレイ」や「ポラロイド写真」のように扱い、背景から浮かび上がらせる
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
                    .accessibilityLabel("成長段階の画像")

                    Text("歩数: \(steps)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primary)
                        .monospacedDigit()

                    // デバッグ用（あとで消します）
                    Text("認識画像: \(availableSprites.count)枚")
                        .font(.footnote)
                        .foregroundStyle(availableSprites.isEmpty ? .red : .gray)
                }

                // ボタン：ステップ増やす / リセット
                VStack(spacing: 12) {
                    Button {
                        steps += stepIncrement
                    } label: {
                        Text("\(stepIncrement)歩増やす")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.blue.opacity(0.95))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue.opacity(0.14))
                            )
                    }

                    Button {
                        steps = 0
                        // ガチャ処理：リセット時にランダムで1つを選択
                        currentSpriteURL = availableSprites.randomElement()
                    } label: {
                        Text("リセット")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.blue.opacity(0.9))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue.opacity(0.07))
                            )
                    }
                }
                .padding(.top, 4)
                .padding(.horizontal, 10)

                Spacer(minLength: 60)
            }
            .padding()
            // 画面が最初に表示されたとき、スキャンして1つ選ぶ
            .onAppear {
                setupSprites()
            }
        }
    }

    /// Sprites フォルダ内の全PNG画像をスキャンし、1つをランダムに選ぶ
    /// 画像を追加する際は Sprites フォルダに PNG を置くだけでOK（完全自動）
    private func setupSprites() {
        let urls = Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: "Sprites") ?? []
        availableSprites = urls
        currentSpriteURL = urls.randomElement()
    }
}

#Preview {
    ContentView()
}