//
//  PeopleViewModel.swift
//  AroundMe
//
//  Created by Mariya on 09.02.2025.
//

import Foundation
import CoreLocation
import Combine

@MainActor
class PeopleViewModel: ObservableObject {
    @Published private(set) var people: [Person] = []
    @Published private(set) var userLocation: CLLocation?

    private let peopleService = PeopleService()
    private let locationManager: LocationManager
    private var cancellables = Set<AnyCancellable>()

    init(locationManager: LocationManager) {
        self.locationManager = locationManager
        observeLocationUpdates()
        loadPeople()
    }

    private func observeLocationUpdates() {
        locationManager.$userLocation
            .assign(to: &$userLocation)
    }

    func loadPeople() {
        peopleService.fetchPeople { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let fetchedPeople):
                self.people = fetchedPeople
            case .failure(let error):
                print("Ошибка загрузки данных: \(error)")
            }
        }
    }

    func distance(to person: Person) -> String? {
        guard let userLocation = userLocation else { return nil }
        let kms = userLocation.distance(from: person.clLocation) / 1000
        return String(format: "%.0f", kms)
    }
}
