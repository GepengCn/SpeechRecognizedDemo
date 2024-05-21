//
//  SpeechRecognizer.swift
//  SpeechRecognizedDemo
//
//  Created by 葛鹏 on 2024/5/18.
//

import Foundation
import AVFoundation
import Speech
import SwiftUI

actor SpeechRecognizer: ObservableObject {
    enum RecognizerError: Error {
        case nilRecognizer
        case notAuthorizedToRecognize
        case notPermittedToRecord
        case recognizerIsUnavailable
        
        var message: String {
            switch self {
            case .nilRecognizer: return "无法初始化语音识别器"
            case .notAuthorizedToRecognize: return "未授权语音识别"
            case .notPermittedToRecord: return "未授权录音"
            case .recognizerIsUnavailable: return "语音识别器不可用"
            }
        }
    }
    
    @MainActor @Published var transcript: String = ""
    
    @MainActor @Published var audioURL: URL?
        
    private var audioEngine: AVAudioEngine?
    private var request: SFSpeechAudioBufferRecognitionRequest?
    private var task: SFSpeechRecognitionTask?
    private let recognizer: SFSpeechRecognizer?
    
    /**
     初始化一个新的语音识别器。如果这是你第一次使用这个类，它会请求访问语音识别器和麦克风。
     */
    init() {
        recognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh_CN"))
        guard recognizer != nil else {
            transcribe(RecognizerError.nilRecognizer)
            return
        }
        
        Task {
            do {
                guard await SFSpeechRecognizer.hasAuthorizationToRecognize() else {
                    throw RecognizerError.notAuthorizedToRecognize
                }
                guard await AVAudioSession.sharedInstance().hasPermissionToRecord() else {
                    throw RecognizerError.notPermittedToRecord
                }
            } catch {
                transcribe(error)
            }
        }
    }
    
    @MainActor func startTranscribing() {
        Task {
            audioURL = await transcribe()
        }
    }
    
    @MainActor func resetTranscript() {
        Task {
            await reset()
        }
    }
    
    @MainActor func stopTranscribing() {
        Task {
            await reset()
        }
    }
    
    private static func createAudioFileURL() throws -> URL {
        let fileManager = FileManager.default
        let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let audioURL = documentDirectory.appendingPathComponent(UUID().uuidString).appendingPathExtension("m4a")
        return audioURL
    }
    
    /**
     开始转录音频。
     
     创建一个 `SFSpeechRecognitionTask`，它将语音转录为文本，直到你调用 `stopTranscribing()`。生成的转录会连续写入发布的 `transcript` 属性。
     */
    private func transcribe() -> URL?{
        guard let recognizer, recognizer.isAvailable else {
            self.transcribe(RecognizerError.recognizerIsUnavailable)
            return nil
        }
        
        do {
            
            let (audioEngine, request, url) = try Self.prepareEngine()
            self.audioEngine = audioEngine
            self.request = request
            self.task = recognizer.recognitionTask(with: request, resultHandler: { [weak self] result, error in
                self?.recognitionHandler(audioEngine: audioEngine, result: result, error: error)
            })
            return url
        } catch {
            self.reset()
            self.transcribe(error)
        }
        return nil
    }
    
    /// 重置语音识别器。
    private func reset() {
        task?.cancel()
        audioEngine?.stop()
        audioEngine = nil
        request = nil
        task = nil
        
        Task {@MainActor in
            audioURL = nil
        }

    }
    
    
    /// 准备并返回配置好的`AVAudioEngine`和`SFSpeechAudioBufferRecognitionRequest`，用于语音识别。
    /// - Throws: 如果音频会话或音频引擎配置失败，则抛出错误。
    /// - Returns: 包含`AVAudioEngine`和`SFSpeechAudioBufferRecognitionRequest`的元组。
    private static func prepareEngine() throws -> (AVAudioEngine, SFSpeechAudioBufferRecognitionRequest, URL) {
        let audioEngine = AVAudioEngine()
        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        
        // 设置音频会话类别，允许录制并播放音频，且当其他应用播放音频时进行降音处理。
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        let audioURL = try createAudioFileURL()
        
        let audioFile = try AVAudioFile(forWriting: audioURL, settings: [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ])

        // 安装一个Tap以从音频输入节点接收音频数据。
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            request.append(buffer)
            do {
                try audioFile.write(from: buffer)
            } catch {
                print("Error writing audio file: \(error)")
            }
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        return (audioEngine, request, audioURL)
    }
    
    nonisolated private func recognitionHandler(audioEngine: AVAudioEngine, result: SFSpeechRecognitionResult?, error: Error?) {
        let receivedFinalResult = result?.isFinal ?? false
        let receivedError = error != nil
        
        if receivedFinalResult || receivedError {
            audioEngine.stop()
            audioEngine.inputNode.removeTap(onBus: 0)
        }
        
        if let result {
            transcribe(result.bestTranscription.formattedString)
        }
    }
    
    nonisolated private func transcribe(_ message: String) {
        Task { @MainActor in
            transcript = message
        }
    }
    
    nonisolated private func transcribe(_ error: Error) {
        var errorMessage = ""
        if let error = error as? RecognizerError {
            errorMessage += error.message
        } else {
            errorMessage += error.localizedDescription
        }
        Task { @MainActor [errorMessage] in
            transcript = "<< \(errorMessage) >>"
        }
    }
}

extension SFSpeechRecognizer {
    static func hasAuthorizationToRecognize() async -> Bool {
        await withCheckedContinuation { continuation in
            requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}

extension AVAudioSession {
    func hasPermissionToRecord() async -> Bool {
        
        await withCheckedContinuation { continuation in
            
            AVAudioApplication.requestRecordPermission { authorized in
                continuation.resume(returning: authorized)
            }
            
        }
    }
}
