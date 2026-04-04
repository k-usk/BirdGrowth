//
//  HomeView.swift
//  てくぴよ
//

import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: BirdViewModel
    @Environment(\.modelContext)
    private var modelContext
    @State private var showingDebugMenu = false

    var body: some View {
        ZStack {
            // 背景コンポーネント
            BackgroundView()

            VStack(spacing: 20) {
                Spacer(minLength: 20)

                // 鳥の名前
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
                    colorRowIndex: viewModel.colorRowIndex,
                    currentSpriteURL: viewModel.currentSpriteURL
                )
                .padding(.horizontal, 10)

                // 達成後の導線（固定スペースを確保してレイアウトのズレを防止）
                ZStack {
                    if viewModel.stage == .adult {
                        Button {
                            Task {
                                await viewModel.graduateBird(context: modelContext)
                            }
                        } label: {
                            HStack(spacing: 4) {
                                Text("新しい卵をお迎えする")
                                Image(systemName: "chevron.right")
                            }
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.brown.opacity(0.6))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 20)
                            .background(Color.white.opacity(0.5))
                            .clipShape(Capsule())
                        }
                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    }
                }
                .frame(height: 60) // ボタンの高さを予約

                Spacer()
            }
        }
        .animation(.spring(), value: viewModel.stage) // 全体の変化をスムーズに
        .contentShape(Rectangle())
        .onLongPressGesture {
            showingDebugMenu = true
        }
        .onAppear {
            viewModel.setupSprites(context: modelContext)
        }
        .sheet(isPresented: $showingDebugMenu) {
            NavigationStack {
                VStack {
                    DebugControlsView(viewModel: viewModel)
                }
                .navigationTitle("デバッグメニュー")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("閉じる") { showingDebugMenu = false }
                    }
                }
            }
            .presentationDetents([.medium])
            .presentationBackground(Color.white.opacity(0.2)) // 透過度アップ
        }
    }

    // loreOverlay は廃止
}

#Preview {
    HomeView(viewModel: BirdViewModel())
        .modelContainer(for: BirdRecord.self, inMemory: true)
}
