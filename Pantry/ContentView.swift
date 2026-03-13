import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            InventoryView()
                .tabItem {
                    Label("Inventory", systemImage: "list.bullet")
                }
            
            ScannerView()
                .tabItem {
                    Label("Scanner", systemImage: "barcode.viewfinder")
                }
            
            ChefView()
                .tabItem {
                    Label("Chef", systemImage: "fork.knife")
                }
        }
    }
}

// MARK: - Placeholder Views

struct InventoryView: View {
    var body: some View {
        VStack {
            Text("🥦 Inventory")
                .font(.largeTitle)
                .bold()
            Text("Your pantry items will live here")
                .foregroundColor(.gray)
        }
    }
}

struct ChefView: View {
    var body: some View {
        VStack {
            Text("👨‍🍳 Chef")
                .font(.largeTitle)
                .bold()
            Text("AI recipe coming soooooon :)")
                .foregroundColor(.gray)
        }
    }
}
