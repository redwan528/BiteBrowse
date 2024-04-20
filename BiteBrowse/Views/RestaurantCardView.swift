//
//  ContentView.swift
//  BiteBrowse
//
//  Created by Redwan Khan on 4/18/24.
//

import SwiftUI

struct RestaurantCardsView: View {
    @StateObject var viewModel = RestaurantsViewModel()
    // ViewModel instance for the view
    
    
    var body: some View {
        VStack {
            ForEach(viewModel.restaurants) { restaurant in
                RestaurantCard(restaurant: restaurant)
                // creating a card for each restaurant
            }
        }
        .onAppear {
            viewModel.loadRestaurants(latitude: 38.7749, longitude: -122.4194) // Example coordinates
            // Loading restaurants on view appearance
        }
    }
}

// subview representing an individual restaurant card
struct RestaurantCard: View {
    var restaurant: Restaurant

    var body: some View {
        VStack {
            AsyncImage(url: URL(string: restaurant.imageUrl)) { image in
                image.resizable()
            } placeholder: {
                Color.gray
            }
            .frame(width: 300, height: 200)
            .cornerRadius(10)

            Text(restaurant.name)
                .font(.headline)

            Text("Rating: \(restaurant.rating)")
                .font(.subheadline)
        }
        .padding()
        .border(Color.gray, width: 1)
    }
}


#Preview {
    RestaurantCardsView()
}
