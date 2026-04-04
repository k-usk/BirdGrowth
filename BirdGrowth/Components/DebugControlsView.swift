//
//  DebugControlsView.swift
//  てくぴよ
//

import SwiftUI

/// 開発・テスト用のデバッグコントロールを表示するコンポーネント
struct DebugControlsView: View {
    @Bindable var viewModel: BirdViewModel
    @Environment(\.modelContext)
    private var modelContext

    var body: some View {
        // デバッグパレット（カラー行）
        Menu {
            Button("上段 (Variation 1)") { viewModel.colorRowIndex = 0 }
            Button("中段 (Standard)") { viewModel.colorRowIndex = 1 }
            Button("下段 (Variation 2)") { viewModel.colorRowIndex = 2 }
        } label: {
            Image(systemName: "paintpalette.fill")
                .font(.system(size: 22))
        }

        HStack(spacing: 30) {
            // 画像セレクター
            Menu {
                Button("ランダム（再抽選）") {
                    viewModel.resetAndRandomize(context: modelContext)
                }
                Divider()
                ForEach(viewModel.availableSprites, id: \.self) { url in
                    let key = url.deletingPathExtension().lastPathComponent
                    Button(key) {
                        viewModel.updateSpriteKey(to: key)
                    }
                }
            } label: {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 22))
            }

            // 歩数追加ボタン
            Button(action: {
                viewModel.steps += viewModel.stepIncrement
            }, label: {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
            })

            // リセットボタン
            Button(action: { viewModel.resetAndRandomize(context: modelContext) }, label: {
                Image(systemName: "arrow.counterclockwise.circle.fill")
                    .font(.system(size: 24))
            })
        }
        .foregroundStyle(Color.brown.opacity(0.7)) // 0.15 -> 0.7 に強化
        .padding(.bottom, 20)
    }
}

#Preview {
    DebugControlsView(viewModel: BirdViewModel())
        .padding()
}
