//
//  ContentView.swift
//  SpeechRecognizedDemo
//
//  Created by 葛鹏 on 2024/5/17.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject private var speechRecognizer: SpeechRecognizer
    
    @State private var messages: [String] = []

    
    var body: some View {
        VStack(spacing: 5) {
            
            ScrollView {
                LazyVStack {
                    
                    ForEach(0..<messages.count, id: \.self){index in
                        HStack(spacing: 0) {
                            Spacer()
                            MessageBubble(radius: 5, arrow: 15, text: messages[index])
                                
                            
                            Circle()
                                .fill(.orange)
                                .frame(width: 60)
                                .overlay {
                                    Text("我")
                                        .font(.title3)
                                        .foregroundStyle(.white)
                                }
                        }
                        
                    }
                }
            }
           
           
            Spacer()
            
            SpeechRecognizedButton{text in
                messages.append(text)
            }
           
        }
        .padding()
    }
}

#Preview {
    ContentView().environmentObject(SpeechRecognizer())
}
