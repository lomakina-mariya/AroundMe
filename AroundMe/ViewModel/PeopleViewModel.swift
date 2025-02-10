//
//  PeopleViewModel.swift
//  AroundMe
//
//  Created by Mariya on 09.02.2025.
//

import Foundation
import CoreLocation

@MainActor
class PeopleViewModel: ObservableObject {
    @Published private(set) var people: [Person] = []
    private let locationManager: LocationManager
    private let peopleService: PeopleService
    private var updateTask: Task<Void, Never>?

    init(locationManager: LocationManager, peopleService: PeopleService) {
        self.locationManager = locationManager
        self.peopleService = peopleService
        self.loadPeople()
    }

    func loadPeople() {
        Task {
            do {
                let fetchedPeople = try await peopleService.fetchPeople()
                self.people = fetchedPeople
                self.startUpdatingPositions()
            } catch {
                print("Ошибка загрузки данных: \(error)")
            }
        }
    }

    func startUpdatingPositions() {
        updateTask = Task {
            for await updatedPeople in peopleService.startUpdatingPositions() {
                self.people = updatedPeople
                self.updateDistances()
            }
        }
    }

    func stopUpdatingPositions() {
        updateTask?.cancel()
    }

    func updateDistances() {
        guard let userLocation = locationManager.userLocation else { return }
        for i in 0..<people.count {
            let distanceToUser = userLocation.distance(from: people[i].clLocation) / 1000
            people[i].distance = distanceToUser
        }
    }
}
