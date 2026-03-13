//
//  FoodAPIService.swift
//  Pantry
//
//  Created by Saleena Tiwari on 12.03.26.
//

import Foundation

// MARK: - Data Models (matching Open Food Facts JSON)

struct OFFResponse: Codable {
    let status: Int
    let product: OFFProduct?
}

struct OFFProduct: Codable {
    let productName: String?
    let brands: String?
    let quantity: String?
    let imageFrontURL: String?
    let nutriscoreGrade: String?
    let ingredientsText: String?
    let nutriments: OFFNutriments?

    enum CodingKeys: String, CodingKey {
        case productName = "product_name"
        case brands
        case quantity
        case imageFrontURL = "image_front_url"
        case nutriscoreGrade = "nutriscore_grade"
        case ingredientsText = "ingredients_text"
        case nutriments
    }
}

struct OFFNutriments: Codable {
    let energyKcal: Double?
    let proteins: Double?
    let carbohydrates: Double?
    let fat: Double?
    let fiber: Double?
    let salt: Double?

    enum CodingKeys: String, CodingKey {
        case energyKcal = "energy-kcal_100g"
        case proteins = "proteins_100g"
        case carbohydrates = "carbohydrates_100g"
        case fat = "fat_100g"
        case fiber = "fiber_100g"
        case salt = "salt_100g"
    }
}

// MARK: - Clean app-facing model

struct FoodItem: Identifiable {
    let id = UUID()
    let barcode: String
    let name: String
    let brand: String
    let quantity: String
    let imageURL: String?
    let nutriscoreGrade: String?
    let ingredients: String?
    let calories: Double?
    let protein: Double?
    let carbs: Double?
    let fat: Double?
    var expiryDate: Date?
}

// MARK: - API Service

class FoodAPIService {
    static let shared = FoodAPIService()

    func fetchProduct(barcode: String) async throws -> FoodItem? {
        let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"

        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(OFFResponse.self, from: data)

        // status 0 means product not found
        guard response.status == 1, let product = response.product else {
            return nil
        }

        return FoodItem(
            barcode: barcode,
            name: product.productName ?? "Unknown Product",
            brand: product.brands ?? "",
            quantity: product.quantity ?? "",
            imageURL: product.imageFrontURL,
            nutriscoreGrade: product.nutriscoreGrade,
            ingredients: product.ingredientsText,
            calories: product.nutriments?.energyKcal,
            protein: product.nutriments?.proteins,
            carbs: product.nutriments?.carbohydrates,
            fat: product.nutriments?.fat
        )
    }
}

// MARK: - Errors

enum APIError: Error {
    case invalidURL
    case productNotFound
    case decodingError
}
