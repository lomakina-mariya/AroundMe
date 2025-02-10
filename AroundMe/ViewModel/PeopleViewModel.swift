//
//  PeopleViewModel.swift
//  AroundMe
//
//  Created by Mariya on 09.02.2025.
//

import Foundation
import CoreLocation

@MainActor
final class PeopleViewModel: ObservableObject {
    @Published private(set) var people: [Person] = []
    @Published var isLoading: Bool = true
    @Published var pinnedPerson: Person?
    
    private let locationManager: LocationManager
    private let peopleService: PeopleService
    private var updateTask: Task<Void, Never>?
    private let userDefaultsKey = "PinnedPersonID"
    

    init(locationManager: LocationManager, peopleService: PeopleService) {
        self.locationManager = locationManager
        self.peopleService = peopleService
        self.loadPeople()
    }

    func loadPeople() {
        isLoading = true
        Task {
            do {
                let fetchedPeople = try await peopleService.fetchPeople()
                self.people = fetchedPeople
                self.isLoading = false
                self.startUpdatingPositions()
                self.loadPinnedPersonID()
            } catch {
                print("Ошибка загрузки данных: \(error)")
                self.isLoading = false
            }
        }
    }

    private func startUpdatingPositions() {
        updateTask = Task {
            for await updatedPeople in peopleService.startUpdatingPositions() {
                self.people = updatedPeople
                self.updateDistances()
            }
        }
    }
    
    private func savePinnedPersonID() {
        if let pinnedPersonID = pinnedPerson?.id {
            UserDefaults.standard.set(pinnedPersonID, forKey: userDefaultsKey)
        }
    }
    
    private func loadPinnedPersonID() {
        let savedID = UserDefaults.standard.integer(forKey: userDefaultsKey)
        self.pinnedPerson = people.first { $0.id == savedID }
    }

    func updateDistances() {
        guard let baseLocation = pinnedPerson?.clLocation ?? locationManager.userLocation else { return }
        for i in people.indices {
            if people[i].id == pinnedPerson?.id {
                guard let userLocation = locationManager.userLocation else { return }
                let distance = userLocation.distance(from: people[i].clLocation) / 1000
                people[i].distance = distance
                pinnedPerson?.distance = distance
            } else {
                people[i].distance = baseLocation.distance(from: people[i].clLocation) / 1000
            }
        }
        people.sort { $0.distance ?? Double.greatestFiniteMagnitude < $1.distance ?? Double.greatestFiniteMagnitude }
    }
    
    func togglePinPerson(person: Person) {
        if pinnedPerson?.id == person.id {
            pinnedPerson = nil
            UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        } else {
            pinnedPerson = person
            savePinnedPersonID()
        }
        updateDistances()
    }
    
    func stopUpdatingPositions() {
        updateTask?.cancel()
    }
}
