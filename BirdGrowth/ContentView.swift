//
//  ContentView.swift
//  BirdGrowth
//

import SwiftUI

struct ContentView: View {
    @State private var steps = 0

    private enum GrowthStage {
        case egg
        case chick
        case adult
    }

    private var stage: GrowthStage {
        switch steps {
        case 0 ... 999:
            return .egg
        case 1000 ... 4999:
            return .chick
        default:
            return .adult
        }
    }

    /// 成長段階ごとに表示するアイコン（SF Symbols）
    private var iconName: String {
        switch stage {
        case .egg:
            return "oval.portrait.fill"
        case .chick:
            return "bird"
        case .adult:
            return "bird.fill"
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
                VStack(spacing: 10) {
                    Image(systemName: iconName)
                        .font(.system(size: 120, weight: .regular))
                        .foregroundStyle(stageColor)
                        .accessibilityLabel("成長段階のアイコン")
                        .shadow(
                            color: stage == .egg
                                // 影の不透明度を上げ、半径を小さくして、輪郭を際立たせる
                                ? Color.black.opacity(0.25) // 不透明度を0.18から0.25に増加
                                : Color.clear,
                            radius: 8, // 半径を12から8に減少
                            x: 0,
                            y: 18 // オフセットyを16から18に増加
                        )

                    Text("歩数: \(steps)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.primary)
                        .monospacedDigit()
                }

                // ボタン：1000歩増やす / リセット
                VStack(spacing: 12) {
                    Button {
                        steps += 1000
                    } label: {
                        Text("1000歩増やす")
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