//
//  BirdDetailSheet.swift
//  てくぴよ
//

import SwiftUI

struct BirdDetailSheet: View {
    let record: BirdRecord
    @Environment(\.dismiss) private var dismiss
    @State private var selectedStageIndex: Int = 2 // デフォルトは成鳥
    
    private let frameSize: CGFloat = 160

    var body: some View {
        ZStack {
            BackgroundView()

            VStack(spacing: 24) {
                // ヘッダー（戻るボタン）
                HStack {
                    Spacer()
                    Button(action: { dismiss() }, label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundStyle(Color.brown.opacity(0.2))
                    })
                }
                .padding()

                ScrollView {
                    VStack(spacing: 32) {
                        // 大きなイラスト
                        VStack(spacing: 16) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 32)
                                    .fill(Color.white)
                                    .frame(width: 200, height: 200)
                                    .shadow(color: Color.brown.opacity(0.05), radius: 10, x: 0, y: 5)
                                
                                if let url = Bundle.main.url(forResource: record.spriteKey,
                                                             withExtension: "png",
                                                             subdirectory: "Sprites"),
                                   let uiImage = UIImage(contentsOfFile: url.path) {
                                    Image(uiImage: uiImage)
                                        .interpolation(.none)
                                        .resizable()
                                        .scaledToFill()
                                        .scaleEffect(3)
                                        .offset(
                                            x: CGFloat(1 - selectedStageIndex) * frameSize,
                                            y: CGFloat(1 - record.colorRowIndex) * frameSize
                                        )
                                        .frame(width: frameSize, height: frameSize)
                                        .clipShape(RoundedRectangle(cornerRadius: 24))
                                }
                            }
                            
                            // イラスト切り替え Picker
                            Picker("成長段階", selection: $selectedStageIndex) {
                                Text("たまご").tag(0)
                                Text("ひな").tag(1)
                                Text("成鳥").tag(2)
                            }
                            .pickerStyle(.segmented)
                            .padding(.horizontal, 40)
                        }

                        // 名前
                        VStack(spacing: 8) {
                            Text(record.spriteKey.replacingOccurrences(of: #"^\d+_"#,
                                                                       with: "",
                                                                       options: .regularExpression))
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.brown)
                        }

                        // 伝承（Lore）
                        VStack(spacing: 12) {
                            Text("伝承 / Lore")
                                .font(.system(size: 14, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.brown.opacity(0.4))

                            Text(BirdCatalogLoader.description(for: record.spriteKey) ?? "この鳥に関する記録は失われている……")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(Color.brown.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .lineSpacing(6)
                                .padding(.horizontal)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.5))
                        )
                        .padding(.horizontal)

                        // 育成統計
                        VStack(spacing: 16) {
                            statRow(image: "calendar", title: "一緒にいた日数", value: "\(record.totalDays)日")
                            statRow(image: "figure.walk", title: "総歩数", value: "\(record.totalSteps)歩")
                            statRow(image: "sparkles", title: "旅立ちの日", value: formatDate(record.graduationDate))
                        }
                        .padding(24)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.white.opacity(0.3))
                        )
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
    }

    private func statRow(image: String, title: String, value: String) -> some View {
        HStack {
            Label(title, systemImage: image)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundStyle(Color.brown.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(Color.brown.opacity(0.8))
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

extension BirdRecord: Identifiable {} // 念のため

#Preview {
    let mockRecord = BirdRecord(
        spriteKey: "1_さすらいのホリドリ",
        colorRowIndex: 1,
        startDate: Date().addingTimeInterval(-86400 * 3),
        graduationDate: Date(),
        totalDays: 3,
        totalSteps: 10000
    )
    BirdDetailSheet(record: mockRecord)
}
