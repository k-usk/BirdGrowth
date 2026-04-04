//
//  BirdCatalogLoader.swift
//  てくぴよ
//

import Foundation

/// BirdCatalog.json を読み込み、スプライトキーから説明文を引くユーティリティ
struct BirdCatalogLoader {
    // MARK: - 内部モデル（JSONデコード用）
    private struct CatalogEntry: Decodable {
        let description: String
    }

    // MARK: - キャッシュ（起動時に1回だけ読む）
    private static var _catalog: [String: CatalogEntry]?

    private static var catalog: [String: CatalogEntry] {
        if let cached = _catalog { return cached }
        guard
            let url = Bundle.main.url(forResource: "BirdCatalog", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([String: CatalogEntry].self, from: data)
        else {
            _catalog = [:]
            return [:]
        }
        _catalog = decoded
        return decoded
    }

    // MARK: - 公開API

    /// スプライトのファイル名（拡張子なし）から説明文を返す
    /// - Parameter spriteKey: 例 "1_さすらいのホリドリ"
    /// - Returns: 説明文。見つからなければ nil
    static func description(for spriteKey: String) -> String? {
        catalog[spriteKey]?.description
    }
}
