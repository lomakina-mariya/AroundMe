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
    @Published var pinnedPerson: Person?
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
        guard let baseLocation = pinnedPerson?.clLocation ?? locationManager.userLocation else { return }
        people = people.map { person in
            var updatedPerson = person
            if person.id == pinnedPerson?.id {
                updatedPerson.distance = (locationManager.userLocation?.distance(from: person.clLocation)).map { $0 / 1000 }
            } else {
                updatedPerson.distance = baseLocation.distance(from: person.clLocation) / 1000
            }
            
            return updatedPerson
        }
        
        people.sort { $0.distance ?? Double.greatestFiniteMagnitude < $1.distance ?? Double.greatestFiniteMagnitude }
    }
    
    func togglePinPerson(person: Person) {
        if pinnedPerson?.id == person.id {
            pinnedPerson = nil
        } else {
            pinnedPerson = person
        }
        updateDistances()
    }
}
