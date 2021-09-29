//
//  ImageUploader.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 14/09/2021.
//

import FirebaseStorage
import Foundation
import UIKit

enum UploadPath: String {
    case icon = "/icon/"
    case banner = "/banner/"
    case post = "/post/"
}

struct ImageUploader {
    static func uploadImage(image: UIImage, path: UploadPath,  completion: @escaping (String) -> ()){
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }
        
        let filename = NSUUID().uuidString
        
        let ref = Storage.storage().reference(withPath: "\(path)\(filename)")
        
        ref.putData(imageData, metadata: nil) { metaData, error in
            if let error = error {
                print("DEBUG: \(error.localizedDescription)")
                return
            }
            
            ref.downloadURL { url, error in
                if let error = error {
                    print("DEBUG: \(error.localizedDescription)")
                    return
                }
                
                guard let imageURL = url else { return }

                
                completion(imageURL.absoluteString)
            }
        }
    }
}
