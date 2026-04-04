//
//  BokehParticleView.swift
//  てくぴよ
//

import SwiftUI

/// 柔らかい光の粒（玉ボケ）が舞うパーティクル演出
struct BokehParticleView: View {
    @State private var animate = false
    private let particleCount = 15

    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { index in
                Circle()
                    .fill(Color.orange.opacity(Double.random(in: 0.1...0.3)))
                    .frame(width: CGFloat.random(in: 10...40))
                    .blur(radius: CGFloat.random(in: 2...8))
                    .offset(
                        x: animate ? CGFloat.random(in: -150...150) : 0,
                        y: animate ? CGFloat.random(in: -200...200) : 0
                    )
                    .opacity(animate ? 0 : 0.8)
                    .scaleEffect(animate ? 1.5 : 0.5)
                    .animation(
                        Animation.easeInOut(duration: Double.random(in: 3...6))
                            .repeatForever(autoreverses: false)
                            .delay(Double.random(in: 0...4)),
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
