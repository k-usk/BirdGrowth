//
//  BirdWidget.swift
//  BirdWidget
//

import SwiftUI
import WidgetKit

struct Provider: TimelineProvider {
    typealias Entry = BirdEntry

    func placeholder(in context: Context) -> Entry {
        BirdEntry(
            date: Date(),
            steps: 5000,
            birdName: "オキナインコ",
            spriteFileName: "",
            stageIndex: 1,
            statusMessage: "こんにちは！"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (Entry) -> Void) {
        let data = WidgetDataManager.fetch()
        let entry = BirdEntry(
            date: Date(),
            steps: data.steps,
            birdName: data.birdName,
            spriteFileName: data.spriteFileName,
            stageIndex: data.stageIndex,
            statusMessage: data.statusMessage
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let data = WidgetDataManager.fetch()
        let entry = BirdEntry(
            date: Date(),
            steps: data.steps,
            birdName: data.birdName,
            spriteFileName: data.spriteFileName,
            stageIndex: data.stageIndex,
            statusMessage: data.statusMessage
        )

        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
}

struct BirdEntry: TimelineEntry {
    let date: Date
    let steps: Int
    let birdName: String
    let spriteFileName: String
    let stageIndex: Int
    let statusMessage: String
}

struct BirdWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily)
    var family

    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [Color.white, Color(red: 1.0, green: 0.98, blue: 0.94)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            switch family {
            case .systemSmall:
                smallView
            case .systemLarge:
                largeView
            default:
                smallView
            }
        }
    }

    // 小サイズ用ビュー
    var smallView: some View {
        VStack(spacing: 8) {
            birdImage(size: 80)

            VStack(spacing: 0) {
                Text("\(entry.steps)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.brown)
                Text("steps")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundStyle(.brown.opacity(0.5))
            }
        }
        .padding()
    }

    // 大サイズ用ビュー
    var largeView: some View {
        VStack(spacing: 16) {
            // 上部：鳥のイラストと名前
            VStack(spacing: 4) {
                birdImage(size: 120)
                Text(entry.birdName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(.brown.opacity(0.8))
            }

            // 中央：メッセージ
            Text(entry.statusMessage)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: .brown.opacity(0.1), radius: 4, x: 0, y: 2)
                )
                .foregroundStyle(.brown.opacity(0.7))

            // 下部：歩数とインジケータ
            VStack(spacing: 10) {
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(entry.steps)")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.brown)
                    Text("/ 10,000 steps")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.brown.opacity(0.5))
                        .padding(.bottom, 6)
                }

                // カスタムゲージ
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.brown.opacity(0.1))
                            .frame(height: 12)

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.orange, .yellow],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width
                                    * CGFloat(min(Double(entry.steps) / 10000.0, 1.0)),
                                height: 12
                            )
                            .shadow(color: .orange.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
                .frame(height: 12)
                .padding(.horizontal, 20)
            }
        }
        .padding()
    }

    @ViewBuilder
    func birdImage(size: CGFloat) -> some View {
        if let uiImage = loadSprite() {
            Image(uiImage: uiImage)
                .interpolation(.none)
                .resizable()
                .frame(width: size * 3, height: size * 3)
                .offset(x: size * CGFloat(1 - entry.stageIndex))
                .frame(width: size, height: size)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Image(systemName: "bird.fill")
                .font(.system(size: size * 0.5))
                .foregroundStyle(.brown.opacity(0.1))
        }
    }

    private func loadSprite() -> UIImage? {
        guard !entry.spriteFileName.isEmpty else { return nil }

        // Spritesフォルダ内のURLを取得
        guard let url = Bundle.main.url(
            forResource: entry.spriteFileName,
            withExtension: nil,
            subdirectory: "Sprites"
        ) else { return nil }

        return UIImage(contentsOfFile: url.path)
    }
}

struct BirdWidget: Widget {
    let kind: String = "BirdWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                BirdWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                BirdWidgetEntryView(entry: entry)
                    .background()
            }
        }
        .configurationDisplayName("BirdGrowth")
        .description("あなたの鳥さんの成長をホーム画面で見守れます。")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    BirdWidget()
} timeline: {
    BirdEntry(
        date: .now,
        steps: 3500,
        birdName: "オカメインコ",
        spriteFileName: "",
        stageIndex: 1,
        statusMessage: "元気に歩こう！"
    )
}

#Preview(as: .systemLarge) {
    BirdWidget()
} timeline: {
    BirdEntry(
        date: .now,
        steps: 7200,
        birdName: "オカメインコ",
        spriteFileName: "",
        stageIndex: 1,
        statusMessage: "あと少しで1万歩だよ！\nがんばって！"
    )
}
