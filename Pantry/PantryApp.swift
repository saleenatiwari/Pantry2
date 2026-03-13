//
//  PantryApp.swift
//  Pantry
//
//  Created by Saleena Tiwari on 12.03.26.
//

import SwiftUI
import SwiftData

@main
struct PantryApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: FoodItem.self)
    }
}
