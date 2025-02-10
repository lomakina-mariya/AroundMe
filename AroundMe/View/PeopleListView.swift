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
            VStack {
                if let pinnedPerson = viewModel.pinnedPerson {
                    Section {
                        pinnedPersonView(person: pinnedPerson)
                    }
                    .background(Color.white)
                    .shadow(radius: 3)
                }
        
                List {
                    ForEach(viewModel.people.filter { $0.id != viewModel.pinnedPerson?.id }) { person in
                        personRow(person: person)
                            .listRowSeparator(.hidden)
                    }
                }
                .listStyle(PlainListStyle())
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
    
    func pinnedPersonView(person: Person) -> some View {
        VStack {
            personRow(person: person)
                .background(Color.white)
                .cornerRadius(10)
                .padding()
        }
        .frame(maxWidth: .infinity)
    }
    
    func personRow(person: Person) -> some View {
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
            Button(action: { viewModel.togglePinPerson(person: person) }) {
                Image(systemName: viewModel.pinnedPerson?.id == person.id ? "pin.fill" : "pin")
                    .foregroundColor(viewModel.pinnedPerson?.id == person.id ? .blue : .gray)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 4)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
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
