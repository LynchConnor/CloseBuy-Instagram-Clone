//
//  RegisterView.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 11/09/2021.
//

import SwiftUI

struct RegisterView: View {
    
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            Button(action: {
            }, label: {
                Text("Create Account")
            })
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
