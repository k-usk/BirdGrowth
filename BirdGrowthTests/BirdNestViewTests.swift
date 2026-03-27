//
//  BirdNestViewTests.swift
//  BirdGrowthTests
//

import Testing
import SwiftUI
import ViewInspector
@testable import BirdGrowth

// ViewInspectorでViewを検査可能にするための宣言
extension BirdNestView: Inspectable {}
extension GrowthTrailView: Inspectable {}

@MainActor
struct BirdNestViewTests {

    @Test("BirdNestViewに正しい歩数が表示されているかの検証")
    func testStepsDisplay() throws {
        let steps = 1234
        let view = BirdNestView(
            birdName: "Test Bird",
            statusMessage: "Hello",
            steps: steps,
            goalSteps: 10000,
            stage: .egg,
            stageIndex: 0,
            currentSpriteURL: nil
        )
        
        // "1234" というテキストが含まれているか確認
        let result = try view.inspect().find(text: "\(steps)")
        #expect(result != nil)
    }

    @Test("BirdNestViewにステータスメッセージが表示されているかの検証")
    func testStatusMessageDisplay() throws {
        let message = "おなかすいたぴよ"
        let view = BirdNestView(
            birdName: "Test Bird",
            statusMessage: message,
            steps: 0,
            goalSteps: 10000,
            stage: .egg,
            stageIndex: 0,
            currentSpriteURL: nil
        )
        
        let result = try view.inspect().find(text: message)
        #expect(result != nil)
    }
}
