//
//  BackgroundView.swift
//  BirdGrowth
//

import SwiftUI

/// アプリ全体の背景となる優しいグラデーションを表示するコンポーネント
struct BackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 1.0, green: 0.98, blue: 0.94), // クリーム色
                Color(red: 1.0, green: 0.94, blue: 0.94)  // ほんのりピンク
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}
