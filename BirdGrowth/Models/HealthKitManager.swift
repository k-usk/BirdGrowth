//
//  HealthKitManager.swift
//  てくぴよ
//

import Foundation
import HealthKit
import Observation

/// ヘルスケア（HealthKit）との連携を管理するマネージャ
@MainActor
@Observable
class HealthKitManager {
    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    /// 今日の歩数
    var todaySteps: Int = 0

    /// ヘルスケアデータが利用可能かどうか
    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    private init() {}

    /// 歩数データの読み取り許可をリクエストする
    func requestAuthorization() async throws {
        guard isAvailable else {
            throw HKError(.errorHealthDataUnavailable)
        }

        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HKError(.errorInvalidArgument)
        }

        try await healthStore.requestAuthorization(toShare: [], read: [stepCountType])
    }

    /// 今日の0:00から現在までの歩数を取得する
    func fetchTodaySteps() async {
        guard isAvailable else { return }

        guard let stepCountType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            return
        }

        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: stepCountType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                guard let result = result, let sum = result.sumQuantity() else {
                    print("Error fetching steps: \(error?.localizedDescription ?? "Unknown error")")
                    continuation.resume()
                    return
                }

                let steps = Int(sum.doubleValue(for: HKUnit.count()))
                Task { @MainActor in
                    self.todaySteps = steps
                    continuation.resume()
                }
            }
            healthStore.execute(query)
        }
    }
}
