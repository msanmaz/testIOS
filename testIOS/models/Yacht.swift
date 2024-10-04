//
//  Yatch.swift
//  testIOS
//
//  Created by Mert Osanmaz on 04/10/2024.
//

import Foundation

struct Yacht: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let specifications: String
    let capacity: Int
    let imageUrls: [String]
    let locationId: Int
    let categoryId: Int
    let createdAt: String
    let updatedAt: String
    let location: Location
    let category: Category
    let rentalDetail: RentalDetail
    let saleDetail: SaleDetail
    let bookings: [Booking]
    let availabilities: [Availability]
}

struct Location: Codable, Identifiable {
    let id: Int
    let name: String
}

struct Category: Codable, Identifiable {
    let id: Int
    let name: String
}

struct RentalDetail: Codable, Identifiable {
    let id: Int
    let yachtId: Int
    let pricePerDay: Int
    let available: Bool
}

struct SaleDetail: Codable, Identifiable {
    let id: Int
    let yachtId: Int
    let price: Int
    let forSale: Bool
}

struct Booking: Codable, Identifiable {
    let id: Int
    let userId: Int
    let yachtId: Int
    let startDate: String
    let endDate: String
    let status: String
    let totalPrice: Int
    let createdAt: String
    let updatedAt: String
}

struct Availability: Codable, Identifiable {
    let id: Int
    let yachtId: Int
    let date: String
    let available: Bool
}
