//
//  AuthViewModel.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 10/09/2021.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

enum AuthState {
    case signedIn
    case loading
    case signedOut
}

class AuthViewModel: ObservableObject {
    
    @Published var currentState: Firebase.User?
    @Published var currentUser: User?
    
    @Published var error: String?
    
    @Published var authState: AuthState = .loading
    
    static var shared = AuthViewModel()
    
    var currentId: String { Auth.auth().currentUser?.uid ?? "" }
    
    init(){
        validateAuthState()
    }
    
    func validateAuthState(){
        if (isUserSignedIn) {
            fetchUser(withId: Auth.auth().currentUser!.uid) { [weak self] user in
                self?.currentUser = user
                self?.authState = .signedIn
            }
        }else{
            self.authState = .signedOut
        }
    }
    
    //Checks whether the user is signed in
    private var isUserSignedIn: Bool { return Auth.auth().currentUser != nil }
    
    private func fetchUser(withId id: String, completion: @escaping (User) -> Void){
        COLLECTION_USERS.document(id).getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            guard let document = snapshot, document.exists else { return }
            
            do {
                guard let user = try document.data(as: User.self) else { return }
                completion(user)
            }catch {
                print("DEBUG: \(error.localizedDescription)")
            }
            
        }
    }
    
    func verifyPhoneNumber(_ phoneNumber: String, completion: @escaping () -> ()){
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { verificationID, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            
            completion()
        }
    }
    
    func signInPhoneNumber(withCode verificationCode: String, completion: @escaping (Result<Bool, FetchUserError>) -> ()){
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else { return }
        
        let credential = PhoneAuthProvider.provider().credential(
          withVerificationID: verificationID,
          verificationCode: verificationCode
        )
        
        Auth.auth().signIn(with: credential) { [weak self] dataResult, error in
            if let error = error  {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            guard let user = dataResult?.user else { return }
            
            self?.currentState = user
            
            guard let id = dataResult?.user.uid else { return }
            
            print("DEBUG: \(id)")
            
            //Checks whether the user has stored details in the database, if not, prompt them to
            //Provide details as part of their profile, otherwise, continue.
            
            self?.fetchUserDetails(withId: id) { result in
                switch result {
                case .success(_):
                    self?.validateAuthState()
                    return
                case .failure(let error):
                    switch error {
                    case .noData:
                        completion(.failure(.noData))
                        return
                    case .error:
                        return
                    }
                }
            }
            
            //If the user does already have an account. (A document exists within the database, continue)
        }
    }
    
    enum FetchUserError: Error {
        case noData
        case error
    }
    
    private func fetchUserDetails(withId userId: String, completion: @escaping (Result<User, FetchUserError>) -> ()){
        COLLECTION_USERS.document(userId).getDocument { snapshot, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                completion(.failure(.error))
                return
            }
            
            guard let documents = snapshot, documents.exists else {
                completion(.failure(.noData))
                return
            }
            
            do {
                guard let user = try documents.data(as: User.self) else {
                    return
                }
                completion(.success(user))
            }catch {
                print("DEBUG: \(error.localizedDescription)")
            }
        }
    }
    
    func signOut(){
        try? Auth.auth().signOut()
        self.currentUser = nil
        authState = .signedOut
    }
    
}
