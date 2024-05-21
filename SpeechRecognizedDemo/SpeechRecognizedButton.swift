//
//  SpeechRecognizedButton.swift
//  SpeechRecognizedDemo
//
//  Created by 葛鹏 on 2024/5/17.
//

import SwiftUI

struct SpeechRecognizedButton: View {
            
    @State private var isLongPressed: Bool = false
    
    @State private var yOffset: CGFloat = 0
        
    @EnvironmentObject private var speechRecognizer: SpeechRecognizer
    
    var success: (_ text: String, _ audioURL: URL?)-> Void
        
    func isCanceled() -> Bool {
        return yOffset < 0
    }
    
    func setOffset(yOffset: CGFloat){
        self.yOffset = yOffset
    }
    
    var body: some View {
        
        VStack {
            
            Text(speechRecognizer.transcript)
                .font(.footnote)
                .foregroundStyle(.secondary)
          
            
            RoundedRectangle(cornerRadius: 10)
                .fill(isCanceled() ? .red: isLongPressed ? .gray : .blue)
                .frame(height: 50)
                
                .overlay {
                    Label(isLongPressed ? isCanceled() ? "松手取消" : "松手发送，上移取消" : "按住说话", systemImage: "waveform")
                        .foregroundStyle(.white)
                        .font(.title3)
                        .bold()
                        
                }.gesture(LongPressGesture().onChanged { _ in
                    isLongPressed.toggle()
                    speechRecognizer.resetTranscript()
                    speechRecognizer.startTranscribing()
                }.simultaneously(with: DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged({ value in
                        setOffset(yOffset: value.location.y)
                        
                    })
                    .onEnded { value in
                                            
                        isLongPressed.toggle()
                        
                        if isCanceled() {
                            setOffset(yOffset: 0)
                        } else {
                            if !speechRecognizer.transcript.isEmpty {
                                success(speechRecognizer.transcript, speechRecognizer.audioURL)
                            }
                        }
                        speechRecognizer.transcript = ""
                        speechRecognizer.stopTranscribing()
                        
                        
                })).animation(.bouncy, value: isLongPressed)
                .animation(.bouncy, value: isCanceled())
                
        }.padding()
        
        
        
        
    }
}


