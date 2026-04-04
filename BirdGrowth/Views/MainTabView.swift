//
//  MainTabView.swift
//  てくぴよ
//

import SwiftUI

struct MainTabView: View {
    @State private var viewModel = BirdViewModel()

    var body: some View {
        TabView {
            HomeView(viewModel: viewModel)
                .tabItem {
                    Label("おうち", systemImage: "house.fill")
                }

            EncyclopediaView()
                .tabItem {
                    Label("ずかん", systemImage: "book.fill")
                }
        }
        .tint(.brown) // てくぴよの世界観に合わせたカラー
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: BirdRecord.self, inMemory: true)
}
