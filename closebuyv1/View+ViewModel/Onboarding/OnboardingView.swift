//
//  Onboarding.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 10/09/2021.
//

import SwiftUI

struct OnboardingView: View {
    
    @State var isActive: Bool = false
    
    @State var phoneNumber: String = ""
    
    var body: some View {
        VStack {
            
            TabView {
                ForEach(1...5, id: \.self){ tab in
                    Rectangle()
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 350)
            
            VStack(spacing: 10) {
                
                Text("Enter your phone to get started")
                    .font(.system(size: 17, weight: .light))
                    .padding(.vertical, 10)
                
                VStack(spacing: 0) {
                    
                    HStack(spacing: 10) {
                        
                        Rectangle()
                            .frame(width: 25, height: 25)
                        
                        TextField("", text: $phoneNumber)
                            .keyboardType(.numberPad)
                            .font(.system(size: 20, weight: .regular))
                    }
                    
                    Rectangle()
                        .frame(height: 1.25)
                        .padding(.vertical, 10)
                        .foregroundColor(Color.gray)
                }
                .padding(.bottom, 15)
                
                Spacer()
                
                NavigationLink(
                    destination: VerifyPhoneNumberView(number: phoneNumber),
                    isActive: $isActive,
                    label: {
                    Button {
                        AuthViewModel.shared.verifyPhoneNumber(phoneNumber) {
                            self.isActive = true
                        }
                    } label: {
                        Text("LETS' GO".uppercased())
                            .foregroundColor(.white)
                            .font(.system(size: 17, weight: .bold))
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    })
                .background(SYSTEM_ORANGE)
                .cornerRadius(10)
                .padding(.horizontal, 15)
                
                Text("or".uppercased())
                    .font(.system(size: 16, weight: .bold))
                
                
                Button {
                    
                } label: {
                    Text("Continue with Apple".uppercased())
                        .foregroundColor(.white)
                        .font(.system(size: 17, weight: .bold))
                        .padding()
                        .frame(maxWidth: .infinity)
                }
                .background(SYSTEM_ORANGE)
                .cornerRadius(10)
                .padding(.horizontal, 15)
                
            }
            .padding(20)
            
        }
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationBarHidden(true)
        .navigationTitle("")
    }
}

struct VerifyPhoneNumberView: View {
    
    @State var isActive: Bool = false
    
    let number: String
    
    @Environment(\.presentationMode) var presentationMode
    
    @State var confirmCodeOne: String = ""
    @State var confirmCodeTwo: String = ""
    @State var confirmCodeThree: String = ""
    @State var confirmCodeFour: String = ""
    @State var confirmCodeFive: String = ""
    @State var confirmCodeSix: String = ""
    
    var body: some View {
        VStack(spacing: 20) {
            
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "arrow.turn.up.left")
                        .font(.system(size: 21, weight: .semibold))
                }
                .foregroundColor(SYSTEM_BLACK)
                
                Spacer()
                
            }
            .padding(.vertical, 10)
            
            Text("Sending code to \(Text(number).bold())")
            
            HStack(spacing: 10) {
                
                TextField("", text: $confirmCodeOne)
                    .font(.system(size: 21))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white)
                    .clipped()
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 0)
                    .frame(maxWidth: .infinity)
                
                TextField("", text: $confirmCodeTwo)
                    .font(.system(size: 21))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white)
                    .clipped()
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 0)
                    .frame(maxWidth: .infinity)
                
                TextField("", text: $confirmCodeThree)
                    .font(.system(size: 21))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white)
                    .clipped()
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 0)
                    .frame(maxWidth: .infinity)
                
                TextField("", text: $confirmCodeFour)
                    .font(.system(size: 21))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white)
                    .clipped()
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 0)
                    .frame(maxWidth: .infinity)
                
                
                TextField("", text: $confirmCodeFive)
                    .font(.system(size: 21))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white)
                    .clipped()
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 0)
                    .frame(maxWidth: .infinity)
                
                TextField("", text: $confirmCodeSix)
                    .font(.system(size: 21))
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.white)
                    .clipped()
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 0)
                    .frame(maxWidth: .infinity)
            }
            
            NavigationLink(
                destination: CreateProfileView(),
                isActive: $isActive,
                label: {
                    Button {
                    
                    let confirmationCode = confirmCodeOne + confirmCodeTwo + confirmCodeThree + confirmCodeFour + confirmCodeFive + confirmCodeSix
                    
                    AuthViewModel.shared.signInPhoneNumber(withCode: confirmationCode) { result in
                        switch result {
                        case .success(_):
                            return
                        case .failure(let error):
                            switch error {
                            case .noData:
                                self.isActive = true
                            case .error:
                                return
                            }
                            return
                        }
                        
                    }
                } label: {
                    Text("Confirm".uppercased())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                }
            })
                .background(SYSTEM_ORANGE)
                .padding()
        }
        .padding(.horizontal, 15)
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationBarHidden(true)
        .navigationTitle("")
    }
}

struct Onboarding_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            OnboardingView()
        }
    }
}
