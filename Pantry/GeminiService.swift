//
//  GeminiService.swift
//  Pantry
//
//  Created by Saleena Tiwari on 12.03.26.
//

import Foundation

class GeminiService {
    static let shared = GeminiService()
    
    private let apiKey = Secrets.geminiAPIKey
    private let apiURL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent"
    
    // MARK: - Expiry Estimate
    func estimateDaysUntilExpiry(productName: String) async throws -> Int {
        do {
            let prompt = """
            Given a food product called "\(productName)", what is the average number of days \
            it stays fresh after purchase? Reply with only a number, nothing else.
            """
            let response = try await sendPrompt(prompt)
            let cleaned = response.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let days = Int(cleaned) else { return 7 }
            print("📅 Gemini estimates \(productName) lasts \(days) days")
            return days
        } catch {
            print("⚠️ Gemini unavailable, defaulting to 7 days")
            return 7
        }
    }
    
    // MARK: - Core API Call
    func sendPrompt(_ prompt: String) async throws -> String {
        guard let url = URL(string: "\(apiURL)?key=\(apiKey)") else {
            throw GeminiError.invalidURL
        }
        
        let body: [String: Any] = [
            "contents": [
                [
                    "parts": [
                        ["text": prompt]
                    ]
                ]
            ]
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GeminiError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorText = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ Gemini API error \(httpResponse.statusCode): \(errorText)")
            throw GeminiError.apiError(httpResponse.statusCode)
        }
        
        // Parse response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let candidates = json["candidates"] as? [[String: Any]],
              let first = candidates.first,
              let content = first["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String else {
            throw GeminiError.decodingError
        }
        
        return text
    }
}

// MARK: - Errors
enum GeminiError: Error {
    case invalidURL
    case invalidResponse
    case apiError(Int)
    case decodingError
}
