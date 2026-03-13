//
//  AddToInventorySheet.swift
//  Pantry
//
//  Created by Saleena Tiwari on 12.03.26.
//

import SwiftUI
import SwiftData

struct AddToInventorySheet: View {
    let product: ScannedFood
    let daysOffset: Int
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var expirationDate: Date {
        ExpiryCalculator.calculateExpiryDate(daysOffset: daysOffset)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Product summary
                VStack(spacing: 6) {
                    Text(product.name)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.center)
                    if !product.brand.isEmpty {
                        Text(product.brand)
                            .foregroundColor(.secondary)
                    }
                    Text("Expires in \(daysOffset) days")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                }
                .padding(.top)
                
                Divider()
                
                // Storage section picker
                Text("Where will you store this?")
                    .font(.headline)
                
                VStack(spacing: 12) {
                    ForEach(StorageSection.allCases, id: \.self) { section in
                        Button {
                            saveItem(section: section)
                        } label: {
                            HStack {
                                Text(sectionEmoji(section))
                                Text(section.rawValue)
                                    .font(.headline)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("Add to Pantry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Save to SwiftData
    func saveItem(section: StorageSection) {
        let newItem = FoodItem(
            name: product.name,
            barcode: product.barcode,
            section: section,
            expirationDate: expirationDate,
            dateAdded: .now,
            nutriScore: product.nutriscoreGrade,
            brand: product.brand,
            imageURL: product.imageURL,
            calories: product.calories,
            ingredients: product.ingredients
        )
        
        modelContext.insert(newItem)
        print("✅ Saved \(newItem.name) to \(section.rawValue), expires \(expirationDate)")
        dismiss()
    }
    
    func sectionEmoji(_ section: StorageSection) -> String {
        switch section {
        case .fridge: return "🧊"
        case .freezer: return "❄️"
        case .pantry: return "🗄️"
        case .other: return "📦"
        }
    }
}
