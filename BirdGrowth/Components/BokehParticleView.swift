//
//  BokehParticleView.swift
//  てくぴよ
//

import SwiftUI

/// 柔らかい光の粒（玉ボケ）が舞うパーティクル演出
struct BokehParticleView: View {
    @State private var animate = false
    private let particleCount = 30 // 15 -> 30 に増量

    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { _ in
                Circle()
                    .fill(Color.orange.opacity(Double.random(in: 0.2...0.5))) // 不透明度アップ
                    .frame(width: CGFloat.random(in: 15...45))
                    .blur(radius: CGFloat.random(in: 3...10)) // ぼかしの幅を拡大
                    .offset(
                        x: animate ? CGFloat.random(in: -160...160) : CGFloat.random(in: -20...20),
                        y: animate ? CGFloat.random(in: -220...220) : CGFloat.random(in: -20...20)
                    )
                    .opacity(animate ? 0 : 0.8)
                    .scaleEffect(animate ? 1.4 : 0.4)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 4...8))
                            .repeatForever(autoreverses: false)
                            .delay(Double.random(in: 0...6)),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        BokehParticleView()
    }
}
