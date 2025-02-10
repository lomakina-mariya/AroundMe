//
//  Person.swift
//  AroundMe
//
//  Created by Mariya on 09.02.2025.
//

import Foundation
import CoreLocation

struct Person: Codable, Identifiable {
    let id: Int
    let name: String
    let avatarURL: String
    var location: Location
    var clLocation: CLLocation {
        CLLocation(latitude: location.latitude, longitude: location.longitude)
    }
    var distance: Double?
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
}
