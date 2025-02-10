//
//  ContentView.swift
//  AroundMe
//
//  Created by Mariya on 09.02.2025.
//

import SwiftUI

struct PeopleListView: View {
    @StateObject private var viewModel = PeopleViewModel(locationManager: LocationManager())

    var body: some View {
        NavigationView {
            List(viewModel.people) { person in
                VStack(alignment: .leading) {
                    HStack {
                        avatarView(url: person.avatarURL)
                        VStack(alignment: .leading) {
                            Text(person.name)
                                .font(.headline)
                            if let distance = viewModel.distance(to: person) {
                                Text("Расстояние: \(distance) км")
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
                .navigationTitle("Список людей")
                .onAppear {
                    viewModel.loadPeople()
                }
            }
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
                    .frame(width: 50, height: 50)
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
