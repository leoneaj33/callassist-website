import SwiftUI
import AVFoundation

struct ListenInView: View {
    let callId: String
    let businessName: String
    let listenUrl: String?
    let controlUrl: String?
    let userPhoneNumber: String?
    @Environment(\.dismiss) private var dismiss

    @State private var isListening = false
    @State private var audioLevel: CGFloat = 0.3
    @State private var errorMessage: String?
    @State private var isTransferring = false
    @State private var didTransfer = false
    @State private var webSocketTask: URLSessionWebSocketTask?
    @State private var audioEngine = AVAudioEngine()
    @State private var playerNode = AVAudioPlayerNode()
    @State private var retryCount = 0
    private let maxRetries = 3

    // Vapi sends stereo but only one channel has audio — extract to mono for clean playback
    private let sampleRate: Double = 16000
    private let monoFormat = AVAudioFormat(commonFormat: .pcmFormatFloat32, sampleRate: 16000, channels: 1, interleaved: false)!

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Audio visualization
            ZStack {
                ForEach(0..<3, id: \.self) { i in
                    Circle()
                        .stroke(lineWidth: 2)
                        .foregroundStyle(Color.accentColor.opacity(0.3 - Double(i) * 0.1))
                        .frame(
                            width: 100 + CGFloat(i) * 40 * audioLevel,
                            height: 100 + CGFloat(i) * 40 * audioLevel
                        )
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true).delay(Double(i) * 0.15), value: audioLevel)
                }

                Image(systemName: didTransfer ? "phone.fill" : "headphones")
                    .font(.system(size: 40))
                    .foregroundStyle(Color.accentColor)
            }
            .frame(height: 200)

            VStack(spacing: 8) {
                Text(didTransfer ? "Call Transferred" : isListening ? "Listening..." : "Listen In")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Call with \(businessName)")
                    .foregroundStyle(.secondary)

                if didTransfer {
                    Text("The call has been transferred to your phone")
                        .font(.caption)
                        .foregroundStyle(Color.accentColor)
                }
            }

            VStack(spacing: 12) {
                if isListening && !didTransfer {
                    Button {
                        transferToMe()
                    } label: {
                        Label("Transfer to Me", systemImage: "phone.arrow.right")
                            .frame(maxWidth: .infinity)
                            .fontWeight(.semibold)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(isTransferring || controlUrl == nil || userPhoneNumber == nil)

                    if controlUrl == nil {
                        Text("Transfer not available for this call.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else if userPhoneNumber == nil {
                        Text("Add a phone number to your profile to enable transfer.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Button {
                        stopListening()
                    } label: {
                        Label("Stop Listening", systemImage: "headphones")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                }

                if isTransferring {
                    ProgressView("Transferring...")
                }
            }
            .padding(.horizontal, 40)

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .navigationTitle("Listen In")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") {
                    stopListening()
                    dismiss()
                }
            }
        }
        .onAppear { startListening() }
        .onDisappear { stopListening() }
    }

    // MARK: - Audio Streaming

    private func startListening() {
        guard var urlString = listenUrl else {
            errorMessage = "Listen URL not available. The call may not support listen-in mode."
            return
        }

        // Convert https:// to wss:// for WebSocket protocol
        if urlString.hasPrefix("https://") {
            urlString = "wss://" + urlString.dropFirst("https://".count)
        } else if urlString.hasPrefix("http://") {
            urlString = "ws://" + urlString.dropFirst("http://".count)
        }

        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid listen URL."
            return
        }

        do {
            try configureAudioSession()
            try startAudioEngine()
        } catch {
            errorMessage = "Failed to set up audio: \(error.localizedDescription)"
            return
        }

        // Create authenticated WebSocket request with Vapi API key
        var request = URLRequest(url: url)
        request.setValue("Bearer \(AppConfig.shared.vapiApiKey)", forHTTPHeaderField: "Authorization")

        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: request)
        webSocketTask?.resume()
        isListening = true
        print("[ListenIn] Connecting to: \(urlString)")
        receiveAudio()
    }

    private func configureAudioSession() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback, mode: .default)
        try session.setActive(true)
    }

    private func startAudioEngine() throws {
        audioEngine.attach(playerNode)

        // Connect player node using the device output format
        let mixerFormat = audioEngine.mainMixerNode.outputFormat(forBus: 0)
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: mixerFormat)

        try audioEngine.start()
        playerNode.play()
    }

    private func stopListening() {
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil

        playerNode.stop()
        if audioEngine.isRunning {
            audioEngine.stop()
        }
        audioEngine.detach(playerNode)

        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        isListening = false
    }

    @State private var debugMessageCount = 0

    private func receiveAudio() {
        webSocketTask?.receive { [self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    // Log first 5 data messages for debugging
                    if self.debugMessageCount < 5 {
                        self.debugMessageCount += 1
                        let hexPrefix = data.prefix(32).map { String(format: "%02x", $0) }.joined(separator: " ")
                        print("[ListenIn] DEBUG #\(self.debugMessageCount): data size=\(data.count) bytes, first 32 bytes: \(hexPrefix)")
                    }
                    self.playAudioData(data)
                case .string(let text):
                    print("[ListenIn] Received text message: \(text.prefix(500))")
                @unknown default:
                    break
                }
                self.receiveAudio()
            case .failure(let error):
                DispatchQueue.main.async {
                    if self.isListening && self.retryCount < self.maxRetries {
                        self.retryCount += 1
                        print("[ListenIn] Connection failed, retrying (\(self.retryCount)/\(self.maxRetries)) in 2s...")
                        self.stopListening()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            self.startListening()
                        }
                    } else if self.isListening {
                        self.errorMessage = "Audio stream disconnected: \(error.localizedDescription)"
                        self.isListening = false
                    }
                }
            }
        }
    }

    private func playAudioData(_ data: Data) {
        // Vapi sends interleaved stereo (L R L R) but left channel is silent.
        // Extract the right channel (odd samples) into a mono Float32 buffer.
        let stereoSampleCount = data.count / 2  // total Int16 samples (both channels)
        let monoFrameCount = UInt32(stereoSampleCount / 2)  // frames = sample pairs
        guard monoFrameCount > 0,
              let buffer = AVAudioPCMBuffer(pcmFormat: monoFormat, frameCapacity: monoFrameCount) else {
            return
        }

        buffer.frameLength = monoFrameCount
        let floatChannel = buffer.floatChannelData![0]

        data.withUnsafeBytes { rawBuffer in
            let samples = rawBuffer.bindMemory(to: Int16.self)
            var sumOfSquares: Float = 0
            for i in 0..<Int(monoFrameCount) {
                // Right channel = odd-indexed samples in interleaved stream
                let sample = samples[i * 2 + 1]
                let f = Float(sample) / Float(Int16.max)
                floatChannel[i] = f
                sumOfSquares += f * f
            }

            let rms = sqrt(sumOfSquares / Float(monoFrameCount))
            DispatchQueue.main.async {
                self.audioLevel = CGFloat(min(rms * 4, 1.0))
            }
        }

        // Convert from 16kHz mono to device output format
        let outputFormat = audioEngine.outputNode.outputFormat(forBus: 0)
        let ratio = outputFormat.sampleRate / sampleRate
        let convertedCapacity = AVAudioFrameCount(Double(monoFrameCount) * ratio) + 1

        guard let converter = AVAudioConverter(from: monoFormat, to: outputFormat),
              let convertedBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: convertedCapacity) else {
            return
        }

        var conversionError: NSError?
        var inputConsumed = false
        converter.convert(to: convertedBuffer, error: &conversionError) { _, outStatus in
            if inputConsumed {
                outStatus.pointee = .noDataNow
                return nil
            }
            inputConsumed = true
            outStatus.pointee = .haveData
            return buffer
        }

        if conversionError == nil {
            playerNode.scheduleBuffer(convertedBuffer)
        }
    }

    // MARK: - Call Transfer

    private func transferToMe() {
        guard let controlUrl = controlUrl,
              let url = URL(string: controlUrl),
              let phoneNumber = userPhoneNumber else { return }

        isTransferring = true
        errorMessage = nil

        let e164Number = VapiService.toE164(phoneNumber)

        let body: [String: Any] = [
            "type": "transfer",
            "destination": [
                "type": "number",
                "number": e164Number
            ]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        Task {
            do {
                let (_, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let code = (response as? HTTPURLResponse)?.statusCode ?? 0
                    throw VapiError.apiError(statusCode: code, message: "Transfer failed")
                }

                await MainActor.run {
                    stopListening()
                    didTransfer = true
                    isTransferring = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Transfer failed: \(error.localizedDescription)"
                    isTransferring = false
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ListenInView(
            callId: "test-123",
            businessName: "Downtown Dental",
            listenUrl: nil,
            controlUrl: nil,
            userPhoneNumber: nil
        )
    }
}
