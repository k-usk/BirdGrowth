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
            steps: 0,
            birdName: "BirdGrowth",
            spriteFileName: "",
            stageIndex: 0,
            colorRowIndex: 1,
            statusMessage: "BirdGrowthへようこそ！"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (BirdEntry) -> Void) {
        let data = WidgetDataManager.fetch()
        let entry = BirdEntry(
            date: Date(),
            steps: data.steps,
            birdName: data.birdName,
            spriteFileName: data.spriteFileName,
            stageIndex: data.stageIndex,
            colorRowIndex: data.colorRowIndex, // カラーを追加
            statusMessage: data.statusMessage
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<BirdEntry>) -> Void) {
        let data = WidgetDataManager.fetch()
        let entry = BirdEntry(
            date: Date(),
            steps: data.steps,
            birdName: data.birdName,
            spriteFileName: data.spriteFileName,
            stageIndex: data.stageIndex,
            colorRowIndex: data.colorRowIndex, // カラーを追加
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
    let colorRowIndex: Int
    let statusMessage: String
}

struct BirdWidgetEntryView: View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily)
    var family

    // アプリと共通の背景色
    let bgColor = Color(red: 1.0, green: 0.98, blue: 0.94)

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                smallView
            case .systemLarge:
                largeView
            default:
                smallView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .unredacted()
        .privacySensitive(false)
    }

    // 小サイズ：イラスト、今日のステップ数
    var smallView: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.brown.opacity(0.05), radius: 5, x: 0, y: 3)

                birdImage(size: 100)
            }
            .frame(width: 100, height: 100)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.top, 10)

            VStack(spacing: 0) {
                Text("\(entry.steps)")
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.brown.opacity(0.8))
                Text("steps")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.brown.opacity(0.5))
            }
        }
    }

    // 大サイズ：今日のステップ、イラスト、メッセージ、10段階のバー
    var largeView: some View {
        VStack(spacing: 0) {
            VStack(spacing: 2) {
                Text("Today's Steps")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundStyle(.brown.opacity(0.4))
                Text("\(entry.steps)")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.brown.opacity(0.8))
            }
            .padding(.top, 20)
            .foregroundStyle(.brown)

            // 中央：イラスト
            ZStack {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.white)
                    .shadow(color: Color.brown.opacity(0.05), radius: 10, x: 0, y: 5)

                birdImage(size: 240)
            }
            .frame(width: 240, height: 240)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .padding(.top, 4)
            .padding(.bottom, 4)

            Spacer()

            // イラスト下：メッセージ
            Text(entry.statusMessage)
                .font(.system(size: 15, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
                .foregroundStyle(.brown.opacity(0.7))
                .padding(.bottom, 8)

            // 下部：10段階のバー
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    ForEach(0..<10, id: \.self) { index in
                        let reached = index < (entry.steps / 1000)
                        let activeColor: Color = {
                            if entry.stageIndex == 0 { return .white } // 卵
                            if entry.stageIndex == 1 { return .orange.opacity(0.6) } // ひな
                            return Color(red: 1.0, green: 0.7, blue: 0.7) // 成鳥（ピンク）
                        }()

                        Capsule()
                            .fill(reached ? activeColor : Color.brown.opacity(0.1))
                            .frame(height: 3)
                    }
                }
                .frame(width: 140) // 全体の横幅を縮める
            }
            .padding(.bottom, 28)
        }
    }

    @ViewBuilder
    func birdImage(size: CGFloat) -> some View {
        if let uiImage = loadSprite() {
            Image(uiImage: uiImage)
                .interpolation(.none)
                .resizable()
                .frame(width: size * 3, height: size * 3)
                .offset(
                    x: size * CGFloat(1 - entry.stageIndex),
                    y: size * CGFloat(1 - entry.colorRowIndex)
                )
                .frame(width: size, height: size)
                .clipped()
        } else {
            Image(systemName: "bird.fill")
                .font(.system(size: size * 0.5))
                .foregroundStyle(.brown.opacity(0.1))
        }
    }

    private func loadSprite() -> UIImage? {
        guard !entry.spriteFileName.isEmpty else { return nil }

        // 1. 直接名前で試行 (Target Membership が正しく設定されていればこれで見える)
        if let image = UIImage(named: entry.spriteFileName) {
            return image
        }

        // 2. Folder Reference 名を含めて試行
        if let image = UIImage(named: "Sprites/\(entry.spriteFileName)") {
            return image
        }

        // 3. Bundle URL で明示的に検索
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
    let bgColor = Color(red: 1.0, green: 0.98, blue: 0.94)

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                BirdWidgetEntryView(entry: entry)
                    .containerBackground(bgColor, for: .widget)
            } else {
                BirdWidgetEntryView(entry: entry)
                    .padding()
                    .background(bgColor)
            }
        }
        .configurationDisplayName("BirdGrowth")
        .description("あなたの鳥さんの成長をホーム画面で見守れます。")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}
