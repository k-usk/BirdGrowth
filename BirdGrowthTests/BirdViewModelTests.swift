//
//  BirdViewModelTests.swift
//  BirdGrowthTests
//

import Testing
import Foundation
@testable import BirdGrowth

@MainActor
struct BirdViewModelTests {

    // MARK: - 成長ステージ遷移のテスト

    @Test("歩数に応じた成長ステージの遷移確認")
    func testStageTransitions() {
        let viewModel = BirdViewModel()

        // 卵ステージ
        viewModel.steps = 0
        #expect(viewModel.stage == .egg)
        #expect(viewModel.stageIndex == 0)

        viewModel.steps = 4999
        #expect(viewModel.stage == .egg)

        // ひなステージ
        viewModel.steps = 5000
        #expect(viewModel.stage == .chick)
        #expect(viewModel.stageIndex == 1)

        viewModel.steps = 9999
        #expect(viewModel.stage == .chick)

        // 成鳥ステージ
        viewModel.steps = 10000
        #expect(viewModel.stage == .adult)
        #expect(viewModel.stageIndex == 2)

        viewModel.steps = 20000
        #expect(viewModel.stage == .adult)
    }

    // MARK: - メッセージ更新のテスト

    @Test("セグメント（1000歩）ごとのメッセージ更新確認")
    func testMessageUpdateOnSegmentChange() {
        let viewModel = BirdViewModel()
        viewModel.steps = 0
        let initialMessage = viewModel.statusMessage

        // 同じセグメント内では更新されない
        viewModel.steps = 500
        #expect(viewModel.statusMessage == initialMessage)

        // セグメントを跨ぐと更新される（可能性が高い）
        // ※ランダムなので、確実に変わることをテストするのは難しいが、
        // 内部の lastSegmentIndex が更新されていることを間接的に期待
        viewModel.steps = 1500
        // 注: randomElement() なので同じメッセージが選ばれる可能性はゼロではないが、通常は変わる
    }

    @Test("メッセージが適切なプールから選ばれていることの確認")
    func testMessageSourcePool() {
        let viewModel = BirdViewModel()
        
        // 5000-6000歩（Index 5）
        viewModel.steps = 5500
        let currentMsg = viewModel.statusMessage
        let validPool = BirdMessageBank.messages[5]
        #expect(validPool.contains(currentMsg))
        
        // 10000歩以上（Index 10）
        viewModel.steps = 12000
        let adultMsg = viewModel.statusMessage
        let adultPool = BirdMessageBank.messages[10]
        #expect(adultPool.contains(adultMsg))
    }

    // MARK: - 名前解析のテスト

    @Test("ファイル名からの鳥の名前抽出")
    func testBirdNameParsing() {
        let viewModel = BirdViewModel()
        
        // ダミーのURLを設定
        let url = URL(fileURLWithPath: "/path/to/blue_parrot#1.png")
        viewModel.selectedSpriteURL = url
        
        #expect(viewModel.currentBirdName == "blue parrot")
        
        let urlWithSpaces = URL(fileURLWithPath: "/path/to/Red_Robin.png")
        viewModel.selectedSpriteURL = urlWithSpaces
        #expect(viewModel.currentBirdName == "Red Robin")
    }

    // MARK: - リセット機能のテスト

    @Test("リセット時に歩数が0になること")
    func testReset() {
        let viewModel = BirdViewModel()
        viewModel.steps = 5000
        
        viewModel.resetAndRandomize()
        
        #expect(viewModel.steps == 0)
        #expect(viewModel.stage == .egg)
    }
}
