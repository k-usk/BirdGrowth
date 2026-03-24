//
//  BirdViewModel.swift
//  BirdGrowth
//

import SwiftUI
import Observation

/// 鳥の成長に関わるビジネスロジックと状態を管理するViewModel
@Observable
class BirdViewModel {
    
    // MARK: - State
    var steps: Int = 0 {
        didSet {
            updateMessageIfNeeded()
        }
    }
    var availableSprites: [URL] = []
    var currentSpriteURL: URL? = nil
    
    // 現在表示中のランダムメッセージ
    private(set) var currentMessage: String = "しずかだね"
    private var lastSegmentIndex: Int = -1
    
    // MARK: - Constants
    let chickThreshold = 5000
    let adultThreshold = 10000
    let stepIncrement = 1000 // ゲージに合わせて1000歩に変更
    let goalSteps: Int = 10000
    
    // MARK: - Computed Properties
    
    /// ファイル名から鳥の名前を生成する
    var currentBirdName: String {
        guard let name = currentSpriteURL?.deletingPathExtension().lastPathComponent else { return "???" }
        let baseName = name.components(separatedBy: "#").first ?? name
        return baseName.replacingOccurrences(of: "_", with: " ")
    }
    
    /// 現在の歩数から成長段階を計算する
    var stage: GrowthStage {
        if steps < chickThreshold { return .egg }
        if steps < adultThreshold { return .chick }
        return .adult
    }
    
    /// スプライトシート内の段階を示すインデックス（0:卵, 1:ひな, 2:成鳥）
    var stageIndex: Int {
        switch stage {
        case .egg: return 0
        case .chick: return 1
        case .adult: return 2
        }
    }
    
    /// 段階に応じた鳥からのメッセージ（動的に更新される）
    var statusMessage: String {
        currentMessage
    }
    
    // MARK: - Methods
    
    /// 1,000歩ごとの区切りを越えたらメッセージを再抽選する
    private func updateMessageIfNeeded() {
        let segmentIndex = min(max(steps / 1000, 0), 10) // 10000歩以上の特別枠(Index 10)に対応
        if segmentIndex != lastSegmentIndex {
            let pool = BirdMessageBank.messages[segmentIndex]
            currentMessage = pool.randomElement() ?? "……"
            lastSegmentIndex = segmentIndex
        }
    }
    
    /// スプライト画像を読み込み、ランダムに1体を選ぶ
    func setupSprites() {
        let urls = Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: "Sprites") ?? []
        availableSprites = urls
        currentSpriteURL = urls.randomElement()
        updateMessageIfNeeded()
    }
    
    /// デバッグ用：歩数をリセットし、鳥をランダムに入れ替える
    func resetAndRandomize() {
        steps = 0
        lastSegmentIndex = -1 // リセットして初回メッセージが出るように
        currentSpriteURL = availableSprites.randomElement()
        updateMessageIfNeeded()
    }
}
