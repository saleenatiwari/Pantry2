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
                    Label("Chef", systemImage: "frying.pan")
                }
        }
    }
}

// MARK: - Placeholder Views

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
