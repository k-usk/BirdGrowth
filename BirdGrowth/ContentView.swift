//
//  ContentView.swift
//  BirdGrowth
//

import SwiftUI

struct ContentView: View {
    @State private var steps = 0

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
                        
                        Image("bird_sprite")
                            .resizable()
                            .frame(width: frameSize * 3, height: frameSize * 3)
                            .offset(x: frameSize * CGFloat(1 - stageIndex))
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
        }
    }
}

#Preview {
    ContentView()
}