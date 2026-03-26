//
//  WidgetDataManager.swift
//  BirdGrowth
//

import Foundation

/// アプリとウィジェット間でデータを共有するためのマネージャ
struct WidgetDataManager {
    static let appGroupID = "group.com.cluppou.BirdGrowth"

    static var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupID)
    }

    enum Keys {
        static let steps = "w_steps"           // キー名を短く刷新
        static let birdName = "w_name"
        static let spriteName = "w_sprite"
        static let stageIndex = "w_stage"
        static let statusMessage = "w_msg"
        static let lastUpdated = "w_updated"
    }

    struct WidgetData {
        let steps: Int
        let birdName: String
        let spriteFileName: String
        let stageIndex: Int
        let statusMessage: String
    }

    static func save(steps: Int, birdName: String, spriteFileName: String, stageIndex: Int, statusMessage: String) {
        guard let defaults = sharedDefaults else { return }

        defaults.set(steps, forKey: Keys.steps)
        defaults.set(birdName, forKey: Keys.birdName)
        defaults.set(spriteFileName, forKey: Keys.spriteName)
        defaults.set(stageIndex, forKey: Keys.stageIndex)
        defaults.set(statusMessage, forKey: Keys.statusMessage)
        defaults.set(Date(), forKey: Keys.lastUpdated)
    }

    static func fetch() -> WidgetData {
        guard let defaults = sharedDefaults else {
            return defaultData
        }

        return WidgetData(
            steps: defaults.integer(forKey: Keys.steps),
            birdName: defaults.string(forKey: Keys.birdName) ?? "鳥さん",
            spriteFileName: defaults.string(forKey: Keys.spriteName) ?? "",
            stageIndex: defaults.integer(forKey: Keys.stageIndex),
            statusMessage: defaults.string(forKey: Keys.statusMessage) ?? "いっしょに歩こう！"
        )
    }

    static var defaultData: WidgetData {
        WidgetData(
            steps: 0,
            birdName: "鳥さん",
            spriteFileName: "",
            stageIndex: 0,
            statusMessage: "こんにちは！"
        )
    }
}
