//
//  CurrentBird.swift
//  てくぴよ
//

import Foundation

/// 現在育てている鳥の状態（UserDefaultsに永続化）
struct CurrentBird: Codable {
    /// Spritesファイル名（拡張子なし）例: "1_さすらいのホリドリ"
    var spriteKey: String
    /// カラー行インデックス（0:上, 1:中, 2:下）
    var colorRowIndex: Int
    /// 育て始めた日付
    var startDate: Date
    /// 育て始めてからの累計歩数
    var steps: Int
}
