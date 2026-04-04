//
//  EncyclopediaView.swift
//  てくぴよ
//

import SwiftUI
import SwiftData

struct EncyclopediaView: View {
    @Query(sort: \BirdRecord.graduationDate, order: .forward) private var records: [BirdRecord]
    @State private var selectedRecord: BirdRecord?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()

                if records.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "bird.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(Color.brown.opacity(0.1))
                        Text("まだ図鑑に記録がありません")
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(Color.brown.opacity(0.4))
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(records) { record in
                                BirdGridItem(record: record)
                                    .onTapGesture {
                                        selectedRecord = record
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("てくぴよ図鑑")
            .sheet(item: $selectedRecord) { record in
                BirdDetailSheet(record: record)
            }
        }
    }
}

/// グリッド内に表示される個別の鳥アイテム
struct BirdGridItem: View {
    let record: BirdRecord

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .aspectRatio(1, contentMode: .fit)
                    .shadow(color: Color.brown.opacity(0.05), radius: 5, x: 0, y: 2)

                // スプライト画像（成鳥のみ表示）
                if let url = Bundle.main.url(forResource: record.spriteKey,
                                             withExtension: "png",
                                             subdirectory: "Sprites"),
                   let uiImage = UIImage(contentsOfFile: url.path) {

                    // 3x3のスプライトシートから「成鳥」(stageIndex: 2) と「指定カラー」(colorRowIndex) を切り出す
                    Image(uiImage: uiImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFill()
                        .scaleEffect(3) // 3x3なので3倍
                        .offset(
                            x: -100, // 成鳥(右端)を表示
                            y: CGFloat(1 - record.colorRowIndex) * 100 // カラー行
                        )
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }

            Text(record.spriteKey.replacingOccurrences(of: #"^\d+_"#,
                                                       with: "",
                                                       options: .regularExpression))
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(Color.brown.opacity(0.6))
                .lineLimit(1)
        }
    }
}

#Preview {
    EncyclopediaView()
        .modelContainer(for: BirdRecord.self, inMemory: true)
}
