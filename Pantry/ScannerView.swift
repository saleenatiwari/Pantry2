//
//  ScannerView.swift
//  Pantry
//
//  Created by Saleena Tiwari on 12.03.26.
//
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
    
    // MARK: - Coordinator (handles barcode detection)
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var onBarcodeFound: (String) -> Void
        var session: AVCaptureSession?
        var lastScanned: String = ""
        var preview: AVCaptureVideoPreviewLayer?

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
            print("✅ Barcode scanned: \(barcode)")
            onBarcodeFound(barcode)

            // Pause scanning briefly to avoid duplicates
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.lastScanned = ""
            }
        }
    }
}

// MARK: - SwiftUI Scanner View
struct ScannerView: View {
    @State private var scannedBarcode: String = ""
    @State private var isScanning: Bool = true

    var body: some View {
        ZStack {
            // Camera feed
            BarcodeScannerRepresentable { barcode in
                self.scannedBarcode = barcode
                print("📦 Found barcode: \(barcode)")
            }
            .ignoresSafeArea()

            // Overlay UI
            VStack {
                Spacer()

                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 250, height: 150)

                Spacer()

                if !scannedBarcode.isEmpty {
                    VStack(spacing: 8) {
                        Text("Barcode detected!")
                            .font(.headline)
                            .foregroundColor(.white)
                        Text(scannedBarcode)
                            .font(.title2)
                            .bold()
                            .foregroundColor(.green)
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
}
