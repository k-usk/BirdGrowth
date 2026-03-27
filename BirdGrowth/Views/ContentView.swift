//
//  ContentView.swift
//  BirdGrowth
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var viewModel = BirdViewModel()

    var body: some View {
        ZStack {
            // 背景コンポーネント
            BackgroundView()

            VStack(spacing: 20) {
                Spacer(minLength: 20)

                // メインタイトル（高さを固定してガタつきを防止）
                Text(viewModel.currentBirdName)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.brown.opacity(0.8))
                    .opacity(viewModel.stage == .adult ? 1 : 0)
                    .frame(height: 32)
                    .padding(.top, 20)

                // 鳥のネスト（メイン画面）
                BirdNestView(
                    birdName: viewModel.currentBirdName,
                    statusMessage: viewModel.statusMessage,
                    steps: viewModel.steps,
                    goalSteps: viewModel.goalSteps,
                    stage: viewModel.stage,
                    stageIndex: viewModel.stageIndex,
                    currentSpriteURL: viewModel.currentSpriteURL
                )
                .padding(.horizontal, 10)

                Spacer()

                // デバッグ用コントロール
                DebugControlsView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.setupSprites()
        }
    }
}

#Preview {
    ContentView()
}
