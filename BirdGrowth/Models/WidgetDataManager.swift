//
//  WidgetDataManager.swift
//  BirdGrowth
//

import Foundation

/// アプリとウィジェット間でデータを共有するためのマネージャ
struct WidgetDataManager {
    /// App Group ID
    static let appGroupID = "group.com.cluppou.BirdGrowth"

    /// 共有のUserDefaults
    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    // MARK: - Keys
    enum Keys {
        static let steps = "widget_steps"
        static let birdName = "widget_bird_name"
        static let spriteFileName = "widget_sprite_file_name"
        static let stageIndex = "widget_stage_index"
        static let statusMessage = "widget_status_message"
        static let lastUpdated = "widget_last_updated"
    }

    /// ウィジェット表示用のデータ構造
    struct WidgetData {
        let steps: Int
        let birdName: String
        let spriteFileName: String
        let stageIndex: Int
        let statusMessage: String
    }

    /// データを保存する
    static func save(steps: Int, birdName: String, spriteFileName: String, stageIndex: Int, statusMessage: String) {
        guard let defaults = sharedDefaults else { return }

        defaults.set(steps, forKey: Keys.steps)
        defaults.set(birdName, forKey: Keys.birdName)
        defaults.set(spriteFileName, forKey: Keys.spriteFileName)
        defaults.set(stageIndex, forKey: Keys.stageIndex)
        defaults.set(statusMessage, forKey: Keys.statusMessage)
        defaults.set(Date(), forKey: Keys.lastUpdated)
    }

    /// データを取得する（ウィジェット側で使用）
    static func fetch() -> WidgetData {
        guard let defaults = sharedDefaults else {
            return WidgetData(
                steps: 0,
                birdName: "鳥さん",
                spriteFileName: "",
                stageIndex: 0,
                statusMessage: "……"
            )
        }

        let steps = defaults.integer(forKey: Keys.steps)
        let birdName = defaults.string(forKey: Keys.birdName) ?? "鳥さん"
        let spriteFileName = defaults.string(forKey: Keys.spriteFileName) ?? ""
        let stageIndex = defaults.integer(forKey: Keys.stageIndex)
        let statusMessage = defaults.string(forKey: Keys.statusMessage) ?? "……"

        return WidgetData(
            steps: steps,
            birdName: birdName,
            spriteFileName: spriteFileName,
            stageIndex: stageIndex,
            statusMessage: statusMessage
        )
    }
}
