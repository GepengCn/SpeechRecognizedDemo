//
//  ContentView.swift
//  SpeechRecognizedDemo
//
//  Created by 葛鹏 on 2024/5/17.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    
    struct Message: Identifiable {
        var id = UUID()
        var text: String
        var audioURL: URL?
    }
    
    
    @EnvironmentObject private var speechRecognizer: SpeechRecognizer
    
    @State private var messages: [Message] = []

    
    var body: some View {
        VStack(spacing: 5) {
            
            ScrollView {
                LazyVStack {
                    
                    ForEach(messages){message in
                        
                        HStack(spacing: 0) {
                            Spacer()
                           
                            MessageBubble(radius: 5, arrow: 15, text: message.text)
                                .onTapGesture {
                                    if let audioURL = message.audioURL {
                                        do {
                                            
                                            let data = try Data(contentsOf: audioURL)
                                            
                                            let audioPlayer : AVAudioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                                                                                
                                            let playResult = audioPlayer.play()
                                            
                                        } catch {
                                            print(error)
                                        }
                                    }
                                }
                            
                            
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
            
            SpeechRecognizedButton{text, audioURL in
                messages.append(Message(text: text, audioURL: audioURL))
            }
           
        }
        .padding()
    }
}

#Preview {
    ContentView().environmentObject(SpeechRecognizer())
}
