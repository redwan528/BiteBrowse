//
//  ContentView.swift
//  BiteBrowse
//
//  Created by Redwan Khan on 4/18/24.
//

import SwiftUI

struct RestaurantCardsView: View {
    @StateObject var viewModel = RestaurantsViewModel()
    @StateObject var locationManager = LocationManager()
    @State private var offset: CGFloat = 0
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
       @Environment(\.verticalSizeClass) var verticalSizeClass
       
    var title: some View {
          Group {
              if horizontalSizeClass == .compact && verticalSizeClass == .regular {
                  portraitTitle
              } else {
                  landscapeTitle
              }
          }
      }
       
       // Title view for portrait mode
       var portraitTitle: some View {
           VStack(alignment: .center, spacing: 4) {
               Text("BiteBrowse")
                   .font(.largeTitle)
                   .fontWeight(.bold)
                   .foregroundColor(.primary)
               Text("Swipe for nearby restaurants")
                   .font(.subheadline)
                   .foregroundColor(.secondary)
           }
           .padding(.top, 50)
       }
       
       // Title view for landscape mode
    var landscapeTitle: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("BiteBrowse")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                Text("Swipe for nearby restaurants")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 100)
            .padding(.horizontal, -50)
            .padding(.bottom, -350)

            Spacer() // pushes the VStack to the left
        }
        .padding(.horizontal)
    }
    var body: some View {
        VStack {
            title
            Spacer()
            // check if permission is denied and show appropriate message
            if locationManager.permissionDenied {
                Text("Please enable location services in your device settings.")
                    .foregroundColor(.red)
                    .padding()
                Button("Open Settings") {
                    // Directs user to the device settings
                    if let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:])
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    Text("Loading restaurants...")
                        .foregroundColor(.secondary)
                        .padding()
                } else if let restaurant = viewModel.currentRestaurant {
                    RestaurantCard(restaurant: restaurant)
                        .offset(x: offset)
                        .animation(.easeInOut, value: offset)
                    
                    
                        .gesture(dragGesture())
                        .frame(height: 350)
                        .padding(.horizontal, 20)
                } else {
                    Text("No restaurants available")
                        .foregroundColor(.gray)
                }
                
                Spacer()
                navigationButtons
            }
        }
                .onAppear {
                    viewModel.loadRestaurantsIfNeeded()
                }
        }
    
    
    private func dragGesture() -> some Gesture {
        DragGesture()
            .onChanged { gesture in
                self.offset = gesture.translation.width  // track finger movement dynamically
            }
            .onEnded { gesture in
                let threshold: CGFloat = 100  // define a clear threshold for swiping
                if abs(self.offset) > threshold {
                    let direction: CGFloat = self.offset > 0 ? 1 : -1
                    self.animateCard(direction: direction)
                } else {
                    // reset the offset if the swipe was not enough to change the card
                    self.offset = 0
                }
            }
    }
    
    private func animateCard(direction: CGFloat) {
        let screenWidth = UIScreen.main.bounds.width
        let animationDuration = 0.0  // time for the card to fly off the screen
        
        //
        
        // after the first animation completes, reset and prepare the next card
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            self.offset = -direction * screenWidth //negative makes it more bouncy
            
            // load the appropriate restaurant based on the swipe direction
            if direction == -1 {
                self.viewModel.showNextRestaurant()
            } else {
                self.viewModel.showPreviousRestaurant()
            }
            
            // animates the next card sliding into view from the opposite side
            withAnimation(.bouncy(duration: animationDuration)) {
                self.offset = 0  // reset offset to slide the card into the central view
            }
        }
    }
    
    var navigationButtons: some View {
        HStack {
            leftButton
            Spacer()
            rightButton
        }
        .padding(.horizontal, 30)
        .padding(.bottom, 20)
    }
    
    var leftButton: some View {
        Button(action: {
            withAnimation {
                viewModel.showPreviousRestaurant()
                offset = 0
            }
        }) {
            Image(systemName: "arrow.left.circle.fill")
                .resizable()
                .frame(width: 44, height: 44)
                .foregroundColor(.gray)
        }
    }
    
    var rightButton: some View {
        Button(action: {
            withAnimation {
                viewModel.showNextRestaurant()
                offset = 0
            }
        }) {
            Image(systemName: "arrow.right.circle.fill")
                .resizable()
                .frame(width: 44, height: 44)
                .foregroundColor(.gray)
        }
    }
}



struct RestaurantCard: View {
    var restaurant: Restaurant
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
       @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        if horizontalSizeClass == .compact && verticalSizeClass == .regular {
            card
                .padding(.horizontal) // adds horizontal padding to the card
                .frame(width: 340, height: 350)
        }
        else {
            card
                .padding(.top, 150)
                .frame(width: 540, height: 350)
        }
    }
    
    var card: some View {
        VStack(alignment: .leading, spacing: 10) {
            imageView
            restaurantInfo
            
        }
        .background(LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray.opacity(0.2)]), startPoint: .top, endPoint: .bottom))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
    
    var imageView: some View {
        // increase the image height and maintain aspect ratio
        AsyncImage(url: URL(string: restaurant.imageUrl)) { phase in
            switch phase {
            case .success(let image):
                image.resizable()
                    .aspectRatio(contentMode: .fill) // maintain the aspect ratio of the image
                    .frame(maxWidth: 320, maxHeight: 250) // increase the maximum height
                    .clipped()
            default:
                Rectangle()
                    .foregroundColor(.gray) // fallback color when no image is available
                    .frame(width: 320, height: 250) // same dimensions for consistency
            }
        }
        .cornerRadius(10)
        .shadow(radius: 3)
    }
    
    var restaurantInfo: some View {
        // restaurant name and rating section below the image
        VStack(alignment: .leading) {
            Text(restaurant.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("Rating: \(restaurant.rating, specifier: "%.1f")/5")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding([.horizontal, .bottom])
    }
    
    
    
    
    
}


#Preview {
    RestaurantCardsView()
}
