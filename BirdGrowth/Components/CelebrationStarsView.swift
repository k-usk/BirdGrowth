//
//  CelebrationStarsView.swift
//  てくぴよ
//

import SwiftUI

/// 鳥の周りに配置される静的な星々の演出
struct CelebrationStarsView: View {
    let seed: String // 配置を固定するためのシード（鳥の名前など）
    private let starCount = 20

    var body: some View {
        // 配置を固定するため、シードに基づいてランダム値を生成（簡易版）
        GeometryReader { geometry in
            let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
            
            ForEach(0..<starCount, id: \.self) { index in
                let random = seededRandom(index: index)
                StarUnit(random: random)
                    .position(
                        x: center.x + CGFloat(random[0] * 320 - 160),
                        y: center.y + CGFloat(random[1] * 320 - 160)
                    )
            }
        }
    }

    /// シードに基づくランダム値（0.0〜1.0）の配列を返す
    private func seededRandom(index: Int) -> [Double] {
        // 簡易的な決定論的ランダム生成
        let combinedSeed = "\(seed)\(index)"
        var hash = 5381
        for char in combinedSeed.utf8 {
            hash = ((hash << 5) &+ hash) &+ Int(char)
        }
        
        let r1 = Double(abs(hash % 1000)) / 1000.0
        let r2 = Double(abs((hash / 1000) % 1000)) / 1000.0
        let r3 = Double(abs((hash / 1000000) % 1000)) / 1000.0
        
        return [r1, r2, r3]
    }
}

struct StarUnit: View {
    let random: [Double] // [posX, posY, size/blur]

    var body: some View {
        Circle()
            .fill(Color.orange.opacity(0.3 + random[2] * 0.4))
            .frame(width: 8 + random[0] * 20)
            .blur(radius: 2 + random[1] * 6)
            .scaleEffect(0.8 + random[2] * 0.4)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CelebrationStarsView(seed: "テストバード")
    }
}
