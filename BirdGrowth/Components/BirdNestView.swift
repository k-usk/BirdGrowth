//
//  BirdNestView.swift
//  てくぴよ
//

import SwiftUI

/// 鳥と歩数・進捗を表示するメインの「ネスト（巣）」コンポーネント
struct BirdNestView: View {
    let birdName: String
    let statusMessage: String
    let steps: Int
    let goalSteps: Int
    let stage: GrowthStage
    let stageIndex: Int
    let colorRowIndex: Int
    let currentSpriteURL: URL?

    private let frameSize: CGFloat = 300

    var body: some View {
        VStack(spacing: 24) {
            // 歩数表示エリア
            VStack(spacing: 6) {
                Text("Today's Steps")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.brown.opacity(0.4))

                Text("\(steps)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.brown.opacity(0.8))
            }
            .padding(.top, 40)

            // 鳥の画像エリア
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .frame(width: frameSize, height: frameSize)
                    .shadow(color: Color.brown.opacity(0.05), radius: 15, x: 0, y: 5)

                if let url = currentSpriteURL, let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
                        .interpolation(.none)
                        .resizable()
                        .frame(width: frameSize * 3, height: frameSize * 3)
                        .offset(x: {
                            let baseOffset = frameSize * CGFloat(1 - stageIndex)
                            let fineTune: CGFloat = 0
                            if stageIndex == 0 { return baseOffset + fineTune } // 卵を右に
                            if stageIndex == 2 { return baseOffset - fineTune } // 成鳥を左に
                            return baseOffset
                        }(), y: {
                            // 3x3グリッドの行選択（0:上段, 1:中段, 2:下段）
                            // 初期位置が中央（中段）なので、上段は +frameSize, 下段は -frameSize オフセット
                            return frameSize * CGFloat(1 - colorRowIndex)
                        }())
                        .animation(nil, value: stageIndex) // 成長段階の切り替えを即時に
                        .animation(nil, value: colorRowIndex) // カラーバリエーションの切り替えを即時に
                } else {
                    Image(systemName: "bird.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.brown.opacity(0.1))
                }
            }
            .frame(width: frameSize, height: frameSize)
            .clipShape(RoundedRectangle(cornerRadius: 24))

            // 下部ステータスとプログレス
            VStack(spacing: 20) {
                Text(statusMessage)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.brown.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                GrowthTrailView(currentSteps: steps, goalSteps: goalSteps, stage: stage)

                Text("\(steps) / \(goalSteps) steps")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.brown.opacity(0.4))
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 48)
                .fill(Color.white.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 48)
                .stroke(Color.white, lineWidth: 2)
        )
        .shadow(color: Color.brown.opacity(0.06), radius: 25, x: 0, y: 15)
    }
}

#Preview {
    let stage: GrowthStage = .chick
    BirdNestView(
        birdName: "オキナインコ ブルー",
        statusMessage: "ぴよぴよ元気！たくさん歩いてね。",
        steps: 6000,
        goalSteps: 10000,
        stage: stage,
        stageIndex: 1,
        colorRowIndex: 1,
        currentSpriteURL: nil
    )
    .padding()
}
