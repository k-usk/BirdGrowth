//
//  ContentView.swift
//  BirdGrowth
//

import SwiftUI

struct ContentView: View {
    // MARK: - App State (Variables)
    @State private var steps: Int = 0

    // 画像ガチャ用の状態変数
    @State private var availableSprites: [String] = [] // スマホ内に保存された画像（のフルパス）リスト
    @State private var currentSpritePath: String? = nil // 今ランダムで選ばれて表示されている画像

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
                VStack(spacing: 24) {
                    let frameSize: CGFloat = 180

                    ZStack {
                        // AI生成画像のデフォルト背景色（白）に合わせて、キャンバスを真っ白にする
                        Color.white
                        
                        // フォルダからランダムで選ばれた画像を読み込む
                        if let path = currentSpritePath, let uiImage = UIImage(contentsOfFile: path) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: frameSize * 3, height: frameSize * 3)
                                .offset(x: frameSize * CGFloat(1 - stageIndex))
                        } else {
                            // もしフォルダが見つからない/画像がない場合の保険（初期アセット）
                            Image("bird_sprite")
                                .resizable()
                                .frame(width: frameSize * 3, height: frameSize * 3)
                                .offset(x: frameSize * CGFloat(1 - stageIndex))
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
                    Text("認識した画像: \(availableSprites.count)枚")
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
                        
                        // ガチャ処理：リセット時に、手持ちの画像リストの中から再度ランダムで1つを引き当てる
                        if !availableSprites.isEmpty {
                            currentSpritePath = availableSprites.randomElement()
                        }
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
            // 画面が最初に表示されたときに、フォルダ内の画像を自動スキャンする
            .onAppear {
                setupSprites()
            }
        }
    }
    
    // MARK: - Logic Methods
    
    /// Spritesフォルダ内に入っている全ての画像をかき集め、1つをランダムに選ぶ
    private func setupSprites() {
        // Xcodeのグループ仕様（ただの仮想フォルダ）に対応するため、特定のフォルダ名を探すのではなく、アプリの全階層内からガチャ用画像（PNG/JPG）を全てかき集める
        if let urls = Bundle.main.urls(forResourcesWithExtension: nil, subdirectory: nil) {
            // PNGやJPGだけを抽出してパスに変換
            let paths = urls.filter { $0.pathExtension.lowercased() == "png" || $0.pathExtension.lowercased() == "jpg" }.map { $0.path }
            if !paths.isEmpty {
                availableSprites = paths
                currentSpritePath = paths.randomElement()
            }
        }
    }
}

#Preview {
    ContentView()
}