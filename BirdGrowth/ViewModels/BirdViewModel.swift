//
//  BirdViewModel.swift
//  てくぴよ
//

import Observation
import SwiftData
import SwiftUI
import WidgetKit

/// 鳥の成長に関わるビジネスロジックと状態を管理するViewModel
@MainActor
@Observable
class BirdViewModel {
    // MARK: - State
    var steps: Int = 0 {
        didSet {
            updateMessageIfNeeded()
            saveCurrentBird()
            updateWidgetData()
        }
    }
    var availableSprites: [URL] = []

    /// UserDefaultsに保存された「今育てている鳥」
    private(set) var currentBird: CurrentBird?

    /// テスト専用：currentBird を直接セットするためのアクセサ
    var currentBirdForTest: CurrentBird? {
        get { currentBird }
        set { currentBird = newValue }
    }

    /// カラー行インデックス (0:上段, 1:中段, 2:下段)
    var colorRowIndex: Int {
        get { currentBird?.colorRowIndex ?? 1 }
        set {
            guard var bird = currentBird else { return }
            bird.colorRowIndex = newValue
            currentBird = bird
            saveCurrentBird()
            updateWidgetData()
        }
    }

    /// 現在表示しているスプライトURL
    var currentSpriteURL: URL? {
        guard let key = currentBird?.spriteKey else { return nil }
        return availableSprites.first { $0.deletingPathExtension().lastPathComponent == key }
    }

    private let healthKitManager = HealthKitManager.shared

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
        guard let name = currentSpriteURL?
            .deletingPathExtension()
            .lastPathComponent else { return "???" }
        // 冒頭の「数字_」を削除
        let trimmedName = name.replacingOccurrences(of: #"^\d+_"#,
                                                    with: "",
                                                    options: .regularExpression)
        // 旧形式の「#」以降も念のため削除
        let baseName = trimmedName.components(separatedBy: "#").first ?? trimmedName
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

    /// スプライト画像を読み込み、永続化データがあれば復元、なければ新規作成する
    func setupSprites() {
        let urls = Bundle.main.urls(forResourcesWithExtension: "png", subdirectory: "Sprites") ?? []
        availableSprites = urls

        // UserDefaultsから「今育てている鳥」を復元
        if let data = UserDefaults.standard.data(forKey: .currentBirdKey),
           let saved = try? JSONDecoder().decode(CurrentBird.self, from: data) {
            currentBird = saved
            steps = saved.steps
        } else {
            // 初回起動時：ランダムに1体を選んで新しい currentBird を生成
            Task {
                await startNewBird()
            }
        }

        updateMessageIfNeeded()

        // HealthKitの同期
        Task {
            try? await healthKitManager.requestAuthorization()
            await syncSteps()
        }
    }

    /// ランダムに新しい鳥を選び、currentBirdを初期化してUserDefaultsに保存する
    func startNewBird() async {
        guard let url = availableSprites.randomElement() else { return }
        let key = url.deletingPathExtension().lastPathComponent
        let newBird = CurrentBird(
            spriteKey: key,
            colorRowIndex: Int.random(in: 0...2),
            startDate: Date(),
            steps: 0
        )
        currentBird = newBird
        steps = 0
        lastSegmentIndex = -1
        saveCurrentBird()
        updateMessageIfNeeded()
    }

    /// currentBird を UserDefaults に保存する
    private func saveCurrentBird() {
        guard var bird = currentBird else { return }
        bird.steps = steps
        currentBird = bird
        if let data = try? JSONEncoder().encode(bird) {
            UserDefaults.standard.set(data, forKey: .currentBirdKey)
        }
    }

    /// 現在の鳥を卒業させ、BirdRecordに記録してから新しい鳥を開始する
    /// - Parameter context: SwiftData の ModelContext（View側から渡す）
    @MainActor
    func graduateBird(context: ModelContext) async {
        guard let bird = currentBird else { return }

        let now = Date()
        let days = Calendar.current.dateComponents([.day], from: bird.startDate, to: now).day ?? 0
        let record = BirdRecord(
            spriteKey: bird.spriteKey,
            colorRowIndex: bird.colorRowIndex,
            startDate: bird.startDate,
            graduationDate: now,
            totalDays: max(days, 1),
            totalSteps: steps
        )
        context.insert(record)
        try? context.save()

        // currentBirdをリセットして新しい鳥を開始
        UserDefaults.standard.removeObject(forKey: .currentBirdKey)
        await startNewBird()
    }

    /// スプライトキー（ファイル名）を更新する（デバッグ用）
    func updateSpriteKey(to key: String) {
        guard var bird = currentBird else { return }
        bird.spriteKey = key
        currentBird = bird
        saveCurrentBird()
        updateWidgetData()
    }

    /// ヘルスケアデータと歩数を同期する
    func syncSteps() async {
        await healthKitManager.fetchTodaySteps()
        self.steps = healthKitManager.todaySteps
    }

    /// デバッグ用：現在の鳥をリセットし、新しい鳥をランダムに入れ替える
    func resetAndRandomize() {
        Task {
            await startNewBird()
        }
    }

    /// ウィジェット用のデータを更新し、リロードを要求する
    private func updateWidgetData() {
        WidgetDataManager.save(
            data: WidgetDataManager.WidgetData(
                steps: steps,
                birdName: currentBirdName,
                spriteFileName: currentSpriteURL?.lastPathComponent ?? "",
                stageIndex: stageIndex,
                colorRowIndex: colorRowIndex,
                statusMessage: statusMessage
            )
        )
        WidgetCenter.shared.reloadAllTimelines()
    }
}

private extension String {
    static let currentBirdKey = "tekupico_currentBird"
}
