//
//  ContentView.swift
//  BirdGrowth
//

import SwiftUI

enum GrowthStage {
    case egg, chick, adult
}

struct ContentView: View {
    // MARK: - App State
    @State private var steps: Int = 0
    @State private var availableSprites: [URL] = []
    @State private var currentSpriteURL: URL? = nil
    @State private var selectedTab: Int = 0
    
    // デザイン用の定数
    private let chickThreshold = 1000
    private let adultThreshold = 5000
    private let stepIncrement = 1200
    private let goalSteps: Int = 10000
    
    // MARK: - Computed Properties
    private var currentBirdName: String {
        guard let name = currentSpriteURL?.deletingPathExtension().lastPathComponent else { return "???" }
        let baseName = name.components(separatedBy: "#").first ?? name
        return baseName.replacingOccurrences(of: "_", with: " ")
    }
    
    private var stage: GrowthStage {
        if steps < chickThreshold { return .egg }
        if steps < adultThreshold { return .chick }
        return .adult
    }
    
    private var stageIndex: Int {
        switch stage {
        case .egg: return 0
        case .chick: return 1
        case .adult: return 2
        }
    }
    
    private var statusMessage: String {
        switch stage {
        case .egg: return "静かに眠っています。ときどき動くかも？"
        case .chick: return "元気いっぱいのヒナ。たくさん歩こう！"
        case .adult: return "立派な成鳥になりました！"
        }
    }

    var body: some View {
        ZStack {
            // 背景グラデーション
            LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.98, blue: 1.0),
                    Color(red: 0.9, green: 0.95, blue: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // 上部ステータスバー（リファレンスの真似）
                HStack {
                    Spacer()
                    StatPill(icon: "leaf.fill", value: 0, color: .blue.opacity(0.1))
                    StatPill(icon: "hexagon.fill", value: 0, color: .orange.opacity(0.1))
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                // ナラティブ・ヘッダー
                VStack(spacing: 4) {
                    Text("3日目") // ダミー
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                    Text(statusMessage)
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                
                // メイン育成カード
                BirdCardView(
                    birdName: currentBirdName,
                    steps: steps,
                    goalSteps: goalSteps,
                    stage: stage,
                    stageIndex: stageIndex,
                    currentSpriteURL: currentSpriteURL
                )
                .padding(.horizontal)
                
                // シェアボタン
                Button(action: { /* Share action */ }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("シェア")
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // デバッグ用操作パネル
                HStack(spacing: 20) {
                    Button(action: { steps += stepIncrement }) {
                        Label("\(stepIncrement)歩", systemImage: "figure.walk")
                            .font(.system(size: 14, weight: .bold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Capsule().fill(Color.blue.opacity(0.1)))
                    }
                    
                    Button(action: { 
                        steps = 0
                        currentSpriteURL = availableSprites.randomElement()
                    }) {
                        Label("リセット", systemImage: "arrow.counterclockwise")
                            .font(.system(size: 14, weight: .bold))
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(Capsule().fill(Color.red.opacity(0.05)))
                            .foregroundStyle(.red.opacity(0.7))
                    }
                }
                
                Spacer().frame(height: 60) // タブバー用のスペース
            }
            
            // フローティング・タブバー
            VStack {
                Spacer()
                FloatingTabBar(selectedTab: $selectedTab)
            }
        }
        .onAppear {
            setupSprites()
        }
    }
    
    private func setupSprites() {
        let urls = Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: "Sprites") ?? []
        availableSprites = urls
        currentSpriteURL = urls.randomElement()
    }
}

// MARK: - Subviews

struct StatPill: View {
    let icon: String
    let value: Int
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
            Text("\(value)")
                .font(.system(size: 14, weight: .bold, design: .monospaced))
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .background(Capsule().fill(color))
    }
}

struct BirdCardView: View {
    let birdName: String
    let steps: Int
    let goalSteps: Int
    let stage: GrowthStage
    let stageIndex: Int
    let currentSpriteURL: URL?
    
    private let frameSize: CGFloat = 200
    
    var body: some View {
        VStack(spacing: 20) {
            // カード内上部ステータス
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(steps)")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                        Text("steps")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.white.opacity(0.6))
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            
            // 鳥の画像エリア
            ZStack {
                // ドット絵背景（ごく薄いグリッドをイメージ）
                Color.white
                
                if let url = currentSpriteURL, let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
                        .interpolation(.none) // ドットをパキッとさせる
                        .resizable()
                        .frame(width: frameSize * 3, height: frameSize * 3)
                        .offset(x: frameSize * CGFloat(1 - stageIndex))
                } else {
                    Image(systemName: "bird")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue.opacity(0.2))
                }
            }
            .frame(width: frameSize, height: frameSize)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
            
            // カード内下部ステータス
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(stage == .adult ? birdName : "For this bird")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white.opacity(0.8))
                    Text("\(steps) / \(goalSteps) steps")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                
                // セグメント化された成長プログレスバー
                GrowthProgressBar(currentSteps: steps, goalSteps: goalSteps)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .background(
            RoundedRectangle(cornerRadius: 32)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.6), Color.blue.opacity(0.5)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 32)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .blue.opacity(0.2), radius: 20, x: 0, y: 10)
    }
}

struct GrowthProgressBar: View {
    let currentSteps: Int
    let goalSteps: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<4) { index in
                segment(for: index)
            }
        }
    }
    
    @ViewBuilder
    private func segment(for index: Int) -> some View {
        let segmentGoal = Double(goalSteps) / 4.0
        let progress = min(max(Double(currentSteps) - segmentGoal * Double(index), 0) / segmentGoal, 1.0)
        
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.2))
                Capsule()
                    .fill(.white)
                    .frame(width: geo.size.width * CGFloat(progress))
            }
        }
        .frame(height: 6)
    }
}

struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack {
            TabItem(icon: "leaf.fill", label: "ホーム", isSelected: selectedTab == 0) { selectedTab = 0 }
            Spacer()
            TabItem(icon: "square.grid.2x2.fill", label: "コレクション", isSelected: selectedTab == 1) { selectedTab = 1 }
            Spacer()
            TabItem(icon: "gearshape.fill", label: "設定", isSelected: selectedTab == 2) { selectedTab = 2 }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(.white)
                .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 5)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 20)
    }
}

struct TabItem: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                Text(label)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .foregroundStyle(isSelected ? .black : .gray.opacity(0.5))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .background(
                isSelected ? Capsule().fill(Color.gray.opacity(0.1)) : Capsule().fill(Color.clear)
            )
        }
    }
}

#Preview {
    ContentView()
}
