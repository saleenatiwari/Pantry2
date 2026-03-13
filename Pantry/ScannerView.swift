import SwiftUI
import AVFoundation

// MARK: - The UIKit camera bridge
struct BarcodeScannerRepresentable: UIViewRepresentable {
    var onBarcodeFound: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onBarcodeFound: onBarcodeFound)
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .black

        let session = AVCaptureSession()

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            print("❌ Camera not available")
            return view
        }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        session.addOutput(output)
        output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
        output.metadataObjectTypes = [.ean8, .ean13, .upce]

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.videoGravity = .resizeAspectFill
        preview.frame = .zero
        view.layer.addSublayer(preview)

        context.coordinator.session = session
        context.coordinator.preview = preview

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            context.coordinator.preview?.frame = uiView.bounds
        }
    }

    // MARK: - Coordinator
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var onBarcodeFound: (String) -> Void
        var session: AVCaptureSession?
        var preview: AVCaptureVideoPreviewLayer?
        var lastScanned: String = ""

        init(onBarcodeFound: @escaping (String) -> Void) {
            self.onBarcodeFound = onBarcodeFound
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            guard let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let barcode = object.stringValue,
                  barcode != lastScanned else { return }

            lastScanned = barcode
            onBarcodeFound(barcode)

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.lastScanned = ""
            }
        }
    }
}

// MARK: - Scanner View
struct ScannerView: View {
    @State private var scannedBarcode: String = ""
    @State private var scannedProduct: ScannedFood? = nil
    @State private var isLoading: Bool = false
    @State private var errorMessage: String? = nil
    @State private var showingAddSheet: Bool = false
    @State private var geminiDaysOffset: Int = 7

    var body: some View {
        ZStack {
            // Camera feed
            BarcodeScannerRepresentable { barcode in
                guard barcode != scannedBarcode else { return }
                scannedBarcode = barcode
                Task {
                    await lookupProduct(barcode: barcode)
                }
            }
            .ignoresSafeArea()

            // Viewfinder box
            VStack {
                Spacer()
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 250, height: 150)
                Spacer()
            }

            // Bottom overlay
            VStack {
                Spacer()

                if isLoading {
                    VStack(spacing: 8) {
                        ProgressView()
                            .tint(.white)
                        Text("Looking up product...")
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    .padding(.bottom, 40)

                } else if let product = scannedProduct {
                    VStack(spacing: 6) {
                        Text("✅ Product Found!")
                            .font(.headline)
                            .foregroundColor(.green)
                        Text(product.name)
                            .font(.title3)
                            .bold()
                            .foregroundColor(.white)
                        if !(product.brand.isEmpty) {
                            Text(product.brand)
                                .foregroundColor(.gray)
                        }
                        Text("Barcode: \(scannedBarcode)")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        Button {
                                    showingAddSheet = true
                                } label: {
                                    Text("Add to Pantry")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 10)
                                        .background(Color.green)
                                        .cornerRadius(10)
                                }
                                .padding(.top, 6)
                        
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    .padding(.bottom, 40)
                    .sheet(isPresented: $showingAddSheet) {
                        if let product = scannedProduct {
                            AddToInventorySheet(product: product, daysOffset: geminiDaysOffset)
                        }
                    }

                } else if let error = errorMessage {
                    VStack(spacing: 8) {
                        Text("❌ \(error)")
                            .foregroundColor(.red)
                        Text("Barcode: \(scannedBarcode)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    .padding(.bottom, 40)

                } else {
                    Text("Point camera at a barcode")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(8)
                        .padding(.bottom, 40)
                }
            }
        }
    }

    // MARK: - API Lookup
    func lookupProduct(barcode: String) async {
        isLoading = true
        errorMessage = nil
        scannedProduct = nil

        do {
            let product = try await FoodAPIService.shared.fetchProduct(barcode: barcode)
                
                if let product = product {
                    scannedProduct = product
                    print("✅ Product found: \(product.name) by \(product.brand)")
                    
                    let days = try await GeminiService.shared.estimateDaysUntilExpiry(productName: product.name)
                    geminiDaysOffset = days
                    print("📅 Expiry estimate: \(days) days from today")
                } else {
                errorMessage = "Product not found in database"
                print("⚠️ Barcode \(barcode) not found in Open Food Facts")
            }
        } catch {
            errorMessage = "Network error — try again"
            print("❌ Error: \(error)")
        }

        isLoading = false
    }
}
