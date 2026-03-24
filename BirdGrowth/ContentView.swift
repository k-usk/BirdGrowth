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
    
    // デザイン用の定数
    private let chickThreshold = 5000
    private let adultThreshold = 10000
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
        case .egg: return "ころんとしています。もうすぐかな？"
        case .chick: return "ぴよぴよ元気！たくさん歩いてね。"
        case .adult: return "立派な成鳥さん！"
        }
    }

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
                Text(currentBirdName)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.brown.opacity(0.8))
                    .opacity(stage == .adult ? 1 : 0)
                    .frame(height: 32)
                    .padding(.top, 20)
                
                // 鳥のネスト（メイン画面）
                BirdNestView(
                    birdName: currentBirdName,
                    statusMessage: statusMessage,
                    steps: steps,
                    goalSteps: goalSteps,
                    stage: stage,
                    stageIndex: stageIndex,
                    currentSpriteURL: currentSpriteURL
                )
                .padding(.horizontal, 10) // 左右の余白をさらに詰め、画面いっぱいに表示
                
                Spacer()
                
                // デバッグ用（控えめなボタン）
                HStack(spacing: 30) {
                    Button(action: { steps += stepIncrement }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                    }
                    
                    Button(action: { 
                        steps = 0
                        currentSpriteURL = availableSprites.randomElement()
                    }) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.system(size: 24))
                    }
                }
                .foregroundStyle(Color.brown.opacity(0.15))
                .padding(.bottom, 20)
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

struct BirdNestView: View {
    let birdName: String
    let statusMessage: String
    let steps: Int
    let goalSteps: Int
    let stage: GrowthStage
    let stageIndex: Int
    let currentSpriteURL: URL?
    
    private let frameSize: CGFloat = 300 // イラスト表示エリアをさらに拡大
    
    var body: some View {
        VStack(spacing: 24) {
            // 歩数表示エリア
            VStack(spacing: 6) {
                Text("Today's Steps")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.brown.opacity(0.4))
                
                Text("\(steps)")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.brown.opacity(0.8))
            }
            .padding(.top, 40)
            
            // 鳥の画像エリア
            ZStack {
                // ドット絵背景（少し角を丸めた正方形）
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .frame(width: frameSize, height: frameSize)
                    .shadow(color: Color.brown.opacity(0.05), radius: 15, x: 0, y: 5)
                
                if let url = currentSpriteURL, let uiImage = UIImage(contentsOfFile: url.path) {
                    Image(uiImage: uiImage)
                        .interpolation(.none)
                        .resizable()
                        .frame(width: frameSize * 3, height: frameSize * 3)
                        .offset(x: frameSize * CGFloat(1 - stageIndex))
                } else {
                    Image(systemName: "bird.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.brown.opacity(0.1))
                }
            }
            .frame(width: frameSize, height: frameSize)
            .clipShape(RoundedRectangle(cornerRadius: 24)) // ここも角丸正方形に
            
            // 下部ステータスとプログレス
            VStack(spacing: 20) {
                // 鳥からのメッセージをメインに表示
                Text(statusMessage)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.brown.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // オリジナル進捗バー
                GrowthTrailView(currentSteps: steps, goalSteps: goalSteps)
                
                Text("\(steps) / \(goalSteps) steps")
                    .font(.system(size: 14, weight: .medium, design: .monospaced))
                    .foregroundStyle(Color.brown.opacity(0.4))
            }
            .padding(.bottom, 40)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // 枠を画面いっぱいに広げる
        .background(
            RoundedRectangle(cornerRadius: 48)
                .fill(Color.white.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 48)
                .stroke(Color.white, lineWidth: 2)
        )
        .shadow(color: Color.brown.opacity(0.06), radius: 25, x: 0, y: 15)
    }
}

struct GrowthTrailView: View {
    let currentSteps: Int
    let goalSteps: Int
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<5) { index in
                featherIcon(for: index)
            }
        }
    }
    
    private func featherIcon(for index: Int) -> some View {
        let segmentGoal = Double(goalSteps) / 5.0
        let reached = Double(currentSteps) >= segmentGoal * Double(index + 1)
        
        return Image(systemName: "feather.fill")
            .font(.system(size: 18))
            .foregroundStyle(reached ? Color.orange.opacity(0.6) : Color.brown.opacity(0.1))
            .scaleEffect(reached ? 1.1 : 0.9)
            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: reached)
    }
}

#Preview {
    ContentView()
}
