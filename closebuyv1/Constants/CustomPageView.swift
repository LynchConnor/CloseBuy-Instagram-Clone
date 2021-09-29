//
//  CustomPageView.swift
//  closebuyv1
//
//  Created by Connor A Lynch on 22/09/2021.
//

import SwiftUI

struct CustomPageView<Content: View>: View {
    
    let selection: [String]
    
    @Namespace var animation
    
    @Binding var selected: String
    
    var content: () -> Content
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(selection, id: \.self) { tag in
                VStack(spacing: 0) {
                    Text(tag)
                        .foregroundColor(selected == tag ? .black : Color.gray)
                        .frame(maxWidth: .infinity, alignment: .bottom)
                        .font(.system(size: 17, weight: selected == tag ? .semibold : .medium))
                        .padding(.vertical, 12)
                        .background(Color.white)
                    
                    ZStack(alignment: .bottom) {
                        
                        Color.gray.opacity(0.25)
                            .frame(height: 1)
                            .matchedGeometryEffect(id: tag, in: animation, properties: .frame, isSource: true)
                        
                        Color.orange
                            .frame(height: 3)
                            .frame(maxWidth: .infinity, alignment: .bottom)
                            .matchedGeometryEffect(id: selected, in: animation, isSource: false)
                    }
                }
                .onTapGesture {
                    withAnimation {
                        selected = tag
                    }
                }
            }
        }
    }
}

struct CustomPageView_Previews: PreviewProvider {
    
    static var previews: some View {
        CustomPageView(selection: ["Near you", "Following"], selected: .constant("Near you")) {
            HStack {
                VStack {
                    Text("1")
                }
                VStack {
                    Text("2")
                }
            }
        }
    }
}
