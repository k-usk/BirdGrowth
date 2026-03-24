//
//  ContentView.swift
//  BirdGrowth
//

import SwiftUI

struct ContentView: View {
    
    @State private var viewModel = BirdViewModel()
    
    var body: some View {
        ZStack {
            // 背景：優しく暖かいパステルカラー
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.98, blue: 0.94), // クリーム色
                    Color(red: 1.0, green: 0.94, blue: 0.94)  // ほんのりピンク
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
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
                
                // デバッグ用（控えめなボタン）
                HStack(spacing: 30) {
                    Button(action: { viewModel.steps += viewModel.stepIncrement }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                    }
                    
                    Button(action: { viewModel.resetAndRandomize() }) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.system(size: 24))
                    }
                }
                .foregroundStyle(Color.brown.opacity(0.15))
                .padding(.bottom, 20)
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
