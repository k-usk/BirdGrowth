//
//  DebugControlsView.swift
//  BirdGrowth
//

import SwiftUI

/// 開発・テスト用のデバッグコントロールを表示するコンポーネント
struct DebugControlsView: View {
    @Binding var steps: Int
    let stepIncrement: Int
    let onReset: () -> Void

    var body: some View {
        HStack(spacing: 30) {
            Button(action: {
                steps += stepIncrement
            }, label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
            })

            Button(action: { onReset() }, label: {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 24))
            })
        }
        .foregroundStyle(Color.brown.opacity(0.15))
        .padding(.bottom, 20)
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var steps = 5000
        var body: some View {
            DebugControlsView(steps: $steps, stepIncrement: 1000, onReset: {})
        }
    }
    return PreviewWrapper()
}
