//
//  PeopleService.swift
//  AroundMe
//
//  Created by Mariya on 09.02.2025.
//

import Foundation
@MainActor
class PeopleService {
    private var people: [Person] = []
    private var timer: Timer?
    
    func fetchPeople() async throws -> [Person] {
        guard let url = Bundle.main.url(forResource: "mock_people", withExtension: "json") else {
            throw NSError(domain: "FileNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "Файл с мок-данными не найден"])
        }
        let data = try Data(contentsOf: url)
        let people = try JSONDecoder().decode([Person].self, from: data)
        self.people = people
        return people
    }
    
    func startUpdatingPositions() -> AsyncStream<[Person]> {
        return AsyncStream { continuation in
            self.timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
                guard let self = self else { return }
                
                Task { @MainActor in
                    self.people = self.people.map { person in
                        var updatedPerson = person
                        updatedPerson.location = Location(
                            latitude: person.location.latitude + Double.random(in: -0.01...0.01),
                            longitude: person.location.longitude + Double.random(in: -0.01...0.01)
                        )
                        return updatedPerson
                    }
                    continuation.yield(self.people)
                }
            }
            
            RunLoop.main.add(self.timer!, forMode: .common)
            
            continuation.onTermination = { _ in
                Task { @MainActor in
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }
        }
    }
}
