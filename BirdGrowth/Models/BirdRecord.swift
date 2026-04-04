//
//  BirdRecord.swift
//  てくぴよ
//

import Foundation
import SwiftData

/// 育て終えた鳥の記録（SwiftDataで永続化）
@Model
final class BirdRecord {
    /// Spritesファイル名（拡張子なし）例: "1_さすらいのホリドリ"
    var spriteKey: String
    /// カラー行インデックス（0:上, 1:中, 2:下）
    var colorRowIndex: Int
    /// 育て始めた日付
    var startDate: Date
    /// 卒業した日付
    var graduationDate: Date
    /// 育てるのにかかった日数
    var totalDays: Int
    /// 育てるのにかかった総歩数
    var totalSteps: Int

    init(
        spriteKey: String,
        colorRowIndex: Int,
        startDate: Date,
        graduationDate: Date,
        totalDays: Int,
        totalSteps: Int
    ) {
        self.spriteKey = spriteKey
        self.colorRowIndex = colorRowIndex
        self.startDate = startDate
        self.graduationDate = graduationDate
        self.totalDays = totalDays
        self.totalSteps = totalSteps
    }
}
