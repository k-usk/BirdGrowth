//
//  CurrentBirdTests.swift
//  BirdGrowthTests
//

import Testing
import Foundation
@testable import BirdGrowth

struct CurrentBirdTests {

    // MARK: - Codable のテスト

    @Test("CurrentBird を JSON にエンコードできること")
    func testEncode() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let bird = CurrentBird(
            spriteKey: "1_さすらいのホリドリ",
            colorRowIndex: 2,
            startDate: date,
            steps: 3000
        )
        let data = try JSONEncoder().encode(bird)
        #expect(!data.isEmpty)
    }

    @Test("エンコード→デコードで値が保持されること")
    func testRoundTrip() throws {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let original = CurrentBird(
            spriteKey: "42_Blue_Parrot",
            colorRowIndex: 1,
            startDate: date,
            steps: 8500
        )
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(CurrentBird.self, from: data)

        #expect(decoded.spriteKey == original.spriteKey)
        #expect(decoded.colorRowIndex == original.colorRowIndex)
        #expect(decoded.steps == original.steps)
        // Date は秒精度で一致を確認
        #expect(abs(decoded.startDate.timeIntervalSince(original.startDate)) < 1.0)
    }

    @Test("不正なJSONはデコードに失敗すること")
    func testDecodeFailure() {
        let invalidJSON = Data("{ \"spriteKey\": \"test\" }".utf8) // 必須フィールド不足
        #expect(throws: (any Error).self) {
            try JSONDecoder().decode(CurrentBird.self, from: invalidJSON)
        }
    }

    // MARK: - フィールドの境界値テスト

    @Test("colorRowIndex の境界値が正常に格納されること")
    func testColorRowIndexBoundary() throws {
        let date = Date()
        let birdMin = CurrentBird(spriteKey: "test", colorRowIndex: 0, startDate: date, steps: 0)
        let birdMax = CurrentBird(spriteKey: "test", colorRowIndex: 2, startDate: date, steps: 0)
        #expect(birdMin.colorRowIndex == 0)
        #expect(birdMax.colorRowIndex == 2)
    }

    @Test("steps が大きな値でも正常に保持されること")
    func testLargeSteps() throws {
        let bird = CurrentBird(spriteKey: "test", colorRowIndex: 0, startDate: .now, steps: 1_000_000)
        let data = try JSONEncoder().encode(bird)
        let decoded = try JSONDecoder().decode(CurrentBird.self, from: data)
        #expect(decoded.steps == 1_000_000)
    }
}
