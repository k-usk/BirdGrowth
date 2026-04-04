//
//  てくぴよApp.swift
//  てくぴよ
//
//  Created by Yusuke on 2026/03/19.
//

import SwiftData
import SwiftUI

@main
struct TekuPiyoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: BirdRecord.self)
    }
}
