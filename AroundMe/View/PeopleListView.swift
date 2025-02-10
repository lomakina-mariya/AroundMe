//
//  ContentView.swift
//  AroundMe
//
//  Created by Mariya on 09.02.2025.
//

import SwiftUI

struct PeopleListView: View {
    @StateObject private var viewModel: PeopleViewModel
    
    init() {
        let locationManager = LocationManager()
        let peopleService = PeopleService()
        _viewModel = StateObject(wrappedValue: PeopleViewModel(locationManager: locationManager, peopleService: peopleService))
    }
    
    var body: some View {
        NavigationView {
            List(viewModel.people) { person in
                VStack(alignment: .leading) {
                    HStack {
                        avatarView(url: person.avatarURL)
                        VStack(alignment: .leading) {
                            Text(person.name)
                                .font(.headline)
                            if let distance = person.distance {
                                Text("Расстояние: \(String(format: "%.0f", distance)) км")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            } else {
                                Text("Нет данных о расстоянии")
                                    .font(.subheadline)
                                    .foregroundColor(.red)
                            }
                        }
                        Spacer()
                    }
                }
            }
            .navigationTitle("Список людей")
        }
        .onAppear {
            viewModel.loadPeople()
        }
        .onDisappear {
            viewModel.stopUpdatingPositions()
        }
    }
    
    func avatarView(url: String) -> some View {
        AsyncImage(url: URL(string: url)) { phase in
            switch phase {
            case .empty:
                Image(systemName: "person.circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.gray)
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            case .failure:
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.red)
            @unknown default:
                EmptyView()
            }
        }
    }
}

#Preview {
    PeopleListView()
}
