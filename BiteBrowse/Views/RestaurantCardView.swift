//
//  ContentView.swift
//  BiteBrowse
//
//  Created by Redwan Khan on 4/18/24.
//

import SwiftUI

struct RestaurantCardsView: View {
    @StateObject var viewModel = RestaurantsViewModel()
    @State private var offset: CGFloat = 0 // Offset for swiping animation

    var body: some View {
        VStack {
            if let restaurant = viewModel.currentRestaurant {
                GeometryReader { geometry in
                    RestaurantCard(restaurant: restaurant)
                        .offset(x: self.offset)
                        .gesture(
                            DragGesture()
                                .onChanged { gesture in
                                    self.offset = gesture.translation.width
                                }
                                .onEnded { _ in
                                    if self.offset > 100 {
                                        self.viewModel.showPreviousRestaurant()
                                    } else if self.offset < -100 {
                                        self.viewModel.showNextRestaurant()
                                    }
                                    self.offset = 0
                                }
                        )
                        .animation(.spring(), value: offset)
                }
                .frame(height: 400) // Set a fixed height for the card
            } else {
                Text("No restaurants available")
                    .foregroundColor(.gray)
            }
        }
        .onAppear {
            viewModel.loadRestaurants() // Sample coordinates
        }
    }
}

// Subview representing an individual restaurant card
struct RestaurantCard: View {
    var restaurant: Restaurant

    var body: some View {
            VStack {
                AsyncImage(url: URL(string: restaurant.imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill)
                    case .failure(_):
                        Text("Unable to load image") // Shows when image fails to load
                            .foregroundColor(.red)
                            .frame(width: 300, height: 200)
                    case .empty:
                        Color.gray // Shows when no image is available
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(width: 300, height: 200)
                .cornerRadius(10)
                .clipped()

                Text(restaurant.name)
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.top, 2) // Adds spacing from the image

                Text("Rating: \(restaurant.rating, specifier: "%.1f")/5")
                    .font(.subheadline)
                    .foregroundColor(.black) // Subtle color for secondary text
            }
            .padding()
            .background(Color.white) // Card background color
            .cornerRadius(12)
            .shadow(radius: 5)
            .padding(.horizontal) // Adds padding around the card to prevent edge clipping
        }
    }


#Preview {
    RestaurantCardsView()
}
