//
//  FoodItem.swift
//  Pantry
//
//  Created by Saleena Tiwari on 12.03.26.
//

import Foundation
import SwiftData

@Model
class FoodItem {
    var name: String
    var barcode: String
    var section: StorageSection
    var expirationDate: Date
    var dateAdded: Date
    var nutriScore: String?
    var brand: String?
    var imageURL: String?
    var calories: Double?
    var ingredients: String?
    
    init(
        name: String,
        barcode: String,
        section: StorageSection,
        expirationDate: Date,
        dateAdded: Date = .now,
        nutriScore: String? = nil,
        brand: String? = nil,
        imageURL: String? = nil,
        calories: Double? = nil,
        ingredients: String? = nil
    ) {
        self.name = name
        self.barcode = barcode
        self.section = section
        self.expirationDate = expirationDate
        self.dateAdded = dateAdded
        self.nutriScore = nutriScore
        self.brand = brand
        self.imageURL = imageURL
        self.calories = calories
        self.ingredients = ingredients
    }
    
    // MARK: - Computed helpers
    var daysUntilExpiry: Int {
        Calendar.current.dateComponents([.day], from: .now, to: expirationDate).day ?? 0
    }
    
    var isExpired: Bool {
        expirationDate < .now
    }
    
    var urgency: ExpiryUrgency {
        if isExpired { return .expired }
        if daysUntilExpiry <= 2 { return .critical }
        if daysUntilExpiry <= 5 { return .soon }
        return .fresh
    }
}

// MARK: - Storage Section
enum StorageSection: String, Codable, CaseIterable {
    case fridge = "Fridge"
    case freezer = "Freezer"
    case pantry = "Pantry"
    case other = "Other"
    
    var displayName: String {
        switch self {
        case .fridge: return "Fridge"
        case .freezer: return "Shelf"
        case .pantry: return "Pantry"
        case .other: return "Basement"
        }
    }
}

// MARK: - Expiry Urgency
enum ExpiryUrgency {
    case fresh, soon, critical, expired
    
    var color: String {
        switch self {
        case .fresh: return "green"
        case .soon: return "yellow"
        case .critical: return "orange"
        case .expired: return "red"
        }
    }
    
    var label: String {
        switch self {
        case .fresh: return "Fresh"
        case .soon: return "Use Soon"
        case .critical: return "Use Now"
        case .expired: return "Expired"
        }
    }
}

// MARK: - Expiry Date Calculator
struct ExpiryCalculator {
    static func calculateExpiryDate(daysOffset: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: daysOffset, to: .now) ?? .now
    }
}
