import SwiftUI
import Speech
import AVFoundation

struct NewRequestView: View {
    @EnvironmentObject var calendarService: CalendarService
    @EnvironmentObject var requestStore: RequestStore
    @EnvironmentObject var profileManager: UserProfileManager
    @ObservedObject var minutesManager = MinutesManager.shared

    @State private var businessName = ""
    @State private var phoneNumber = ""
    @State private var serviceDescription = ""
    @State private var selectedSlots: [TimeSlot] = []
    @State private var listenInEnabled = false
    @State private var showAvailability = false
    @State private var showCallStatus = false
    @State private var activeRequest: AppointmentRequest?
    @State private var callError: String?
    @State private var showLowBalanceAlert = false
    @State private var showPurchaseSheet = false

    // Speech recognition
    @State private var isRecording = false
    @State private var speechRecognizer = SFSpeechRecognizer()
    @State private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    @State private var recognitionTask: SFSpeechRecognitionTask?
    @State private var speechAudioEngine = AVAudioEngine()
    @State private var speechPermissionDenied = false

    private var isFormValid: Bool {
        !businessName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty &&
        !serviceDescription.trimmingCharacters(in: .whitespaces).isEmpty &&
        !selectedSlots.isEmpty
    }

    var body: some View {
        Form {
            if let profile = profileManager.activeProfile {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .foregroundStyle(Color.accentColor)
                        Text("Calling as \(profile.fullName)")
                            .font(.subheadline)
                        Spacer()
                        if profileManager.profiles.count > 1 {
                            Menu {
                                ForEach(profileManager.profiles) { p in
                                    Button {
                                        profileManager.setActive(p)
                                    } label: {
                                        HStack {
                                            Text(p.fullName)
                                            if p.id == profileManager.activeProfileId {
                                                Image(systemName: "checkmark")
                                            }
                                        }
                                    }
                                }
                            } label: {
                                Text("Switch")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }

            Section("Business Details") {
                TextField("Business Name", text: $businessName)
                    .textContentType(.organizationName)

                TextField("Phone Number", text: $phoneNumber)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
            }

            Section {
                TextField("What service do you need?", text: $serviceDescription, axis: .vertical)
                    .lineLimit(2...4)

                Button {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                } label: {
                    HStack {
                        Image(systemName: isRecording ? "mic.fill" : "mic")
                            .foregroundStyle(isRecording ? .red : .accentColor)
                        Text(isRecording ? "Stop Recording" : "Dictate")
                            .foregroundStyle(isRecording ? .red : .accentColor)
                        if isRecording {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .disabled(speechPermissionDenied)

                if speechPermissionDenied {
                    Text("Speech recognition permission denied. Enable it in Settings.")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            } header: {
                Text("Appointment")
            }

            Section {
                Button {
                    showAvailability = true
                } label: {
                    HStack {
                        Image(systemName: "calendar")
                        Text(selectedSlots.isEmpty ? "Select Available Times" : "\(selectedSlots.count) time(s) selected")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }

                if !selectedSlots.isEmpty {
                    ForEach(selectedSlots) { slot in
                        HStack {
                            Image(systemName: "clock")
                                .foregroundStyle(.secondary)
                            Text(slot.displayString)
                                .font(.subheadline)
                        }
                    }
                }
            } header: {
                Text("Available Times")
            } footer: {
                Text("Select times when you're free. The AI will try to book within these windows.")
            }

            Section {
                Toggle(isOn: $listenInEnabled) {
                    VStack(alignment: .leading) {
                        Text("Listen In")
                        Text("Hear the call in real time")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                Text("Call Options")
            } footer: {
                Text("When enabled, you can listen to the AI making the call and optionally join the conversation.")
            }

            Section {
                Button {
                    placeCall()
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "phone.fill")
                        Text("Place Call")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(!isFormValid)
            }
        }
        .navigationTitle("New Appointment")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                MinutesBalanceWidget(minutesManager: minutesManager)
            }
        }
        .sheet(isPresented: $showAvailability) {
            NavigationStack {
                AvailabilityView(selectedSlots: $selectedSlots)
            }
        }
        .fullScreenCover(isPresented: $showCallStatus) {
            if let request = activeRequest {
                NavigationStack {
                    CallStatusView(request: request)
                }
            }
        }
        .alert("Call Failed", isPresented: Binding(
            get: { callError != nil },
            set: { if !$0 { callError = nil } }
        )) {
            Button("OK") { callError = nil }
        } message: {
            Text(callError ?? "Unknown error")
        }
        .alert("Insufficient Minutes", isPresented: $showLowBalanceAlert) {
            Button("Buy Minutes") {
                showPurchaseSheet = true
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("You need at least 7.5 minutes to place a call. Your balance: \(minutesManager.balance.remainingMinutesInt) minutes.")
        }
        .sheet(isPresented: $showPurchaseSheet) {
            NavigationStack {
                PurchaseMinutesView()
            }
        }
    }

    // MARK: - Speech Recognition

    private func startRecording() {
        SFSpeechRecognizer.requestAuthorization { status in
            DispatchQueue.main.async {
                guard status == .authorized else {
                    speechPermissionDenied = true
                    return
                }
                beginAudioRecording()
            }
        }
    }

    private func beginAudioRecording() {
        recognitionTask?.cancel()
        recognitionTask = nil

        // Configure audio session BEFORE accessing inputNode
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.record, mode: .measurement)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            callError = "Could not start recording: \(error.localizedDescription)"
            return
        }

        let request = SFSpeechAudioBufferRecognitionRequest()
        request.shouldReportPartialResults = true
        recognitionRequest = request

        let inputNode = speechAudioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        do {
            speechAudioEngine.prepare()
            try speechAudioEngine.start()
            isRecording = true
        } catch {
            callError = "Could not start audio engine: \(error.localizedDescription)"
            return
        }

        let textBeforeRecording = serviceDescription
        recognitionTask = speechRecognizer?.recognitionTask(with: request) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    let transcribed = result.bestTranscription.formattedString
                    if textBeforeRecording.isEmpty {
                        serviceDescription = transcribed
                    } else {
                        serviceDescription = textBeforeRecording + " " + transcribed
                    }
                }
            }
            if error != nil || (result?.isFinal ?? false) {
                DispatchQueue.main.async {
                    stopRecording()
                }
            }
        }
    }

    private func stopRecording() {
        speechAudioEngine.stop()
        speechAudioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        recognitionTask = nil
        recognitionRequest = nil
        isRecording = false
    }

    // MARK: - Call Placement

    private func placeCall() {
        // Check minute balance before placing call
        let estimatedMinutes = 7.5
        guard minutesManager.hasEnoughMinutes(estimatedMinutes) else {
            showLowBalanceAlert = true
            return
        }

        let activeProfile = profileManager.activeProfile

        var request = AppointmentRequest(
            businessName: businessName,
            phoneNumber: phoneNumber,
            serviceDescription: serviceDescription,
            preferredTimes: selectedSlots,
            status: .calling,
            listenInEnabled: listenInEnabled,
            userProfileId: activeProfile?.id
        )
        requestStore.add(request)
        activeRequest = request

        Task {
            do {
                let callResponse = try await VapiService.shared.createCall(for: request, userProfile: activeProfile)
                request.callId = callResponse.id
                request.status = .calling
                requestStore.update(request)
                activeRequest = request
                showCallStatus = true
            } catch {
                request.status = .failed
                requestStore.update(request)
                callError = error.localizedDescription
            }
        }
    }
}

#Preview {
    NavigationStack {
        NewRequestView()
            .environmentObject(CalendarService())
            .environmentObject(RequestStore())
            .environmentObject(UserProfileManager())
    }
}
