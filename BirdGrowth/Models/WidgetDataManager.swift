//
//  WidgetDataManager.swift
//  てくぴよ
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
        static let colorRowIndex = "w_color"
        static let lastUpdated = "w_updated"
    }

    struct WidgetData {
        let steps: Int
        let birdName: String
        let spriteFileName: String
        let stageIndex: Int
        let colorRowIndex: Int
        let statusMessage: String
    }

    static func save(data: WidgetData) {
        guard let defaults = sharedDefaults else { return }

        defaults.set(data.steps, forKey: Keys.steps)
        defaults.set(data.birdName, forKey: Keys.birdName)
        defaults.set(data.spriteFileName, forKey: Keys.spriteName)
        defaults.set(data.stageIndex, forKey: Keys.stageIndex)
        defaults.set(data.colorRowIndex, forKey: Keys.colorRowIndex)
        defaults.set(data.statusMessage, forKey: Keys.statusMessage)
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
            colorRowIndex: defaults.integer(forKey: Keys.colorRowIndex),
            statusMessage: defaults.string(forKey: Keys.statusMessage) ?? "いっしょに歩こう！"
        )
    }

    static var defaultData: WidgetData {
        WidgetData(
            steps: 0,
            birdName: "鳥さん",
            spriteFileName: "",
            stageIndex: 0,
            colorRowIndex: 1, // デフォルトは中段（Yellow）
            statusMessage: "こんにちは！"
        )
    }
}
