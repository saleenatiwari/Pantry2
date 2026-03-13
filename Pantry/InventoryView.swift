import SwiftUI
import SwiftData

struct InventoryView: View {
    @State private var showingAddSection = false
    @State private var newSectionName = ""

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(StorageSection.allCases, id: \.self) { section in
                        NavigationLink(destination: SectionDetailView(section: section)) {
                            SectionCard(section: section)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    // Plus button
                    Button {
                        showingAddSection = true
                    } label: {
                        VStack(spacing: 12) {
                            Text("➕")
                                .font(.system(size: 44))
                            Text("Add Section")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("Custom")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 28)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)
            }
            .navigationTitle("Inventory")
            .sheet(isPresented: $showingAddSection) {
                AddCustomSectionSheet(sectionName: $newSectionName, isPresented: $showingAddSection)
            }
        }
    }
}

// MARK: - Section Card
struct SectionCard: View {
    let section: StorageSection
    @Query var allItems: [FoodItem]

    var sectionItems: [FoodItem] {
        allItems.filter { $0.section == section }
    }

    var body: some View {
        VStack(spacing: 12) {
            Text(sectionEmoji(section))
                .font(.system(size: 44))
            Text(section.displayName)
                .font(.headline)
                .foregroundColor(.primary)
            Text("\(sectionItems.count) item\(sectionItems.count == 1 ? "" : "s")")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 28)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }

    func sectionEmoji(_ section: StorageSection) -> String {
        switch section {
        case .fridge: return "❄️"
        case .freezer: return "🪤" //Shelf
        case .pantry: return "🥫" 
        case .other: return "🏠" //Basement
        }
    }
}

// MARK: - Add Custom Section Sheet
struct AddCustomSectionSheet: View {
    @Binding var sectionName: String
    @Binding var isPresented: Bool
    @State private var selectedEmoji = "🗂️"

    let emojiOptions = ["🗂️", "🧺", "🍷", "🌿", "🥗", "🍞", "🧃", "🫙"]

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Name your section")
                    .font(.headline)
                    .padding(.top)

                TextField("e.g. Wine Rack, Garage Shelf...", text: $sectionName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Text("Pick an emoji")
                    .font(.headline)

                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                    ForEach(emojiOptions, id: \.self) { emoji in
                        Button {
                            selectedEmoji = emoji
                        } label: {
                            Text(emoji)
                                .font(.system(size: 36))
                                .padding(8)
                                .background(selectedEmoji == emoji ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
                                .cornerRadius(10)
                        }
                    }
                }
                .padding(.horizontal)

                Button {
                    // In a full version this would save to SwiftData
                    // For now it acknowledges the input and dismisses
                    print("➕ Custom section requested: \(selectedEmoji) \(sectionName)")
                    isPresented = false
                    sectionName = ""
                } label: {
                    Text("Add Section")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(sectionName.isEmpty ? Color.gray : Color.accentColor)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                .disabled(sectionName.isEmpty)

                Spacer()
            }
            .navigationTitle("New Section")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isPresented = false }
                }
            }
        }
    }
}

// MARK: - Section Detail View
struct SectionDetailView: View {
    let section: StorageSection
    @Query var allItems: [FoodItem]

    var sectionItems: [FoodItem] {
        allItems
            .filter { $0.section == section }
            .sorted { $0.expirationDate < $1.expirationDate }
    }

    var body: some View {
        List {
            ForEach(sectionItems) { item in
                FoodItemRow(item: item)
            }
        }
        .navigationTitle(section.displayName)
        .overlay {
            if sectionItems.isEmpty {
                VStack(spacing: 12) {
                    Text("📭")
                        .font(.system(size: 48))
                    Text("No items here yet")
                        .foregroundColor(.secondary)
                    Text("Scan something to add it!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

// MARK: - Food Item Row
struct FoodItemRow: View {
    let item: FoodItem

    var urgencyColor: Color {
        switch item.urgency {
        case .fresh: return .green
        case .soon: return .yellow
        case .critical: return .orange
        case .expired: return .red
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(urgencyColor)
                .frame(width: 6)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                if let brand = item.brand, !brand.isEmpty {
                    Text(brand)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(item.urgency.label)
                    .font(.caption)
                    .bold()
                    .foregroundColor(urgencyColor)
                if item.isExpired {
                    Text("Expired")
                        .font(.caption2)
                        .foregroundColor(.red)
                } else {
                    Text("\(item.daysUntilExpiry)d left")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}


