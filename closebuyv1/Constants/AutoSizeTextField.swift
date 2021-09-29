//
//  AutoSizeTextField.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 17/09/2021.
//

import SwiftUI
import Foundation

struct AutoSizeTextField: UIViewRepresentable {
    
    @Binding var text: String
    let hint: String
    @Binding var containerHeight: CGFloat
    
    func makeUIView(context: Context) -> UITextView {
        
        print(self)
        
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.textColor = .black
        textView.font = .systemFont(ofSize: 18)
        textView.delegate = context.coordinator
        
        return textView
        
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        uiView.text = text
        DispatchQueue.main.async {
            if containerHeight == 0 {
                containerHeight = uiView.contentSize.height
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        
        let parent: AutoSizeTextField
        
        init(_ parent: AutoSizeTextField){
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.hint {
                textView.text = ""
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.containerHeight = textView.contentSize.height
        }
        
    }
}

struct AutoSizeTextField_Example: View {
    
    @State var text: String = ""
    @State var containerHeight: CGFloat = 0
    
    var body: some View {
        
        VStack {
            AutoSizeTextField(text: $text, hint: "Enter your bio", containerHeight: $containerHeight)
                .frame(height: 100)
                .background(Color.white)
                .cornerRadius(10)
                .padding()
        }
        .background(Color.gray)
        .onAppear(perform: {
            self.text = "howdy"
        })
    }
}

struct AutoSizeTextField_Previews: PreviewProvider {
    
    static var previews: some View {
        AutoSizeTextField_Example()
    }
}
