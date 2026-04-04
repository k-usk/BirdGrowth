//
//  HomeView.swift
//  てくぴよ
//

import SwiftUI

struct HomeView: View {
    @Bindable var viewModel: BirdViewModel
    @Environment(\.modelContext) private var modelContext
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

                Spacer()
            }

            // 成鳥（卒業）演出オーバーレイ
            if viewModel.stage == .adult {
                loreOverlay
            }
        }
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
        }
    }

    /// 図鑑説明文を表示するオーバーレイ
    private var loreOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Text(viewModel.currentBirdName)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.brown)

                    Text(viewModel.currentLore)
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.brown.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal)
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: 32)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32)
                                .stroke(Color.white.opacity(0.5), lineWidth: 2)
                        )
                )
                .padding(.horizontal, 24)

                // 「羽ばたく」ボタン
                Button {
                    Task {
                        await viewModel.graduateBird(context: modelContext)
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: "hand.thumbsup.fill") // または翼のイメージ
                        Text("羽ばたく")
                    }
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 40)
                    .background(Color.brown)
                    .clipShape(Capsule())
                    .shadow(color: .brown.opacity(0.3), radius: 10, x: 0, y: 5)
                }
            }
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.spring(), value: viewModel.stage)
    }
}

#Preview {
    HomeView(viewModel: BirdViewModel())
        .modelContainer(for: BirdRecord.self, inMemory: true)
}
