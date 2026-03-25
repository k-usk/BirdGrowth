//
//  GrowthTrailView.swift
//  BirdGrowth
//

import SwiftUI

/// 成長の進捗を羽根アイコンで表示するコンポーネント
struct GrowthTrailView: View {
    let currentSteps: Int
    let goalSteps: Int
    let stage: GrowthStage

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<10) { index in
                segmentView(for: index)
            }
        }
        .frame(width: 160) // 控えめなサイズに固定
    }

    private func segmentView(for index: Int) -> some View {
        let segmentGoal = Double(goalSteps) / 10.0
        let reached = Double(currentSteps) >= segmentGoal * Double(index + 1)

        // ステージに応じた到達カラー
        let activeColor: Color = {
            switch stage {
            case .egg: return .white
            case .chick: return .orange.opacity(0.6)
            case .adult: return Color(red: 1.0, green: 0.7, blue: 0.7) // 優しいピンク
            }
        }()

        return Capsule()
            .fill(reached ? activeColor : Color.brown.opacity(0.1))
            .frame(height: 4)
            .shadow(color: reached ? activeColor.opacity(0.3) : .clear, radius: 2)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: reached)
    }
}

#Preview {
    VStack(spacing: 20) {
        GrowthTrailView(currentSteps: 3000, goalSteps: 10000, stage: .egg)
        GrowthTrailView(currentSteps: 7000, goalSteps: 10000, stage: .chick)
        GrowthTrailView(currentSteps: 10000, goalSteps: 10000, stage: .adult)
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}
