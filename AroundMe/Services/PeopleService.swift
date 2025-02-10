//
//  PeopleService.swift
//  AroundMe
//
//  Created by Mariya on 09.02.2025.
//

import Foundation

class PeopleService {
    func fetchPeople(completion: @escaping (Result<[Person], Error>) -> Void) {
        guard let url = Bundle.main.url(forResource: "mock_people", withExtension: "json") else {
            completion(.failure(NSError(domain: "FileNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "Файл с мок-данными не найден"])))
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let people = try JSONDecoder().decode([Person].self, from: data)
            completion(.success(people))
        } catch {
            completion(.failure(error))
        }
    }
}
