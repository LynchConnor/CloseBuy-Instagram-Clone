//
//  ContentView.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 10/09/2021.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                switch viewModel.authState {
                case .signedIn:
                    TabBarView()
                case .loading:
                    VStack {
                    ProgressView()
                        Button {
                            AuthViewModel.shared.signOut()
                        } label: {
                            Text("Sign out")
                        }

                    }
                    
                case .signedOut:
                    OnboardingView()
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
