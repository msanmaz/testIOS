//
//  HomeView.swift
//  testIOS
//
//  Created by Mert Osanmaz on 03/10/2024.
//

import SwiftUI

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.isLoading {
                    ProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                } else {
                    List(viewModel.yachts) { yacht in
                        YachtRow(yacht: yacht)
                    }
                }
            }
            .navigationTitle("Yachts")
        }
        .onAppear {
            viewModel.fetchYachts()
        }
    }
}

struct YachtRow: View {
    let yacht: Yacht
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(yacht.name)
                .font(.headline)
            Text(yacht.description)
                .font(.subheadline)
                .lineLimit(2)
            HStack {
                Text("Price per day: $\(yacht.rentalDetail.pricePerDay)")
                Spacer()
                Text("Capacity: \(yacht.capacity)")
            }
            .font(.caption)
        }
    }
}


#Preview {
    HomeView()
}
