//
//  InputViewModel.swift
//  Bubbly
//
//  Created by Divyansh Bhardwaj on 11/12/24.
//

import Foundation
import Combine

final class InputViewModel: ObservableObject {

    @Published var text = ""
    @Published var attachments = InputViewAttachments()
    @Published var state: InputViewState = .empty

    @Published var showPicker = false
    @Published var mediaPickerMode = MediaPickerMode.photos

    @Published var showActivityIndicator = false

//    var recordingPlayer: RecordingPlayer?
    var didSendMessage: ((DraftMessage) -> Void)?

//    private var recorder = Recorder()

    private var saveEditingClosure: ((String) -> Void)?

    private var recordPlayerSubscription: AnyCancellable?
    private var subscriptions = Set<AnyCancellable>()
    
//    func setRecorderSettings(recorderSettings: RecorderSettings = RecorderSettings()) {
//        self.recorder.recorderSettings = recorderSettings
//    }

    func onStart() {
        subscribeValidation()
//        subscribePicker()
    }

    func onStop() {
        subscriptions.removeAll()
    }

    func reset() {
        DispatchQueue.main.async { [weak self] in
            self?.showPicker = false
            self?.text = ""
            self?.saveEditingClosure = nil
            self?.attachments = InputViewAttachments()
            self?.subscribeValidation()
            self?.state = .empty
        }
    }

    func send() {
//        recorder.stopRecording()
//        recordingPlayer?.reset()
        sendMessage()
            .store(in: &subscriptions)
    }

//    func edit(_ closure: @escaping (String) -> Void) {
//        saveEditingClosure = closure
//        state = .editing
//    }

    func inputViewAction() -> (InputViewAction) -> Void {
        { [weak self] in
            self?.inputViewActionInternal($0)
        }
    }
    
    private func inputViewActionInternal(_ action: InputViewAction) {
        switch action {
        case .send:
            send()
        }
    }

//    private func recordAudio() {
//        if recorder.isRecording {
//            return
//        }
//        Task { @MainActor in
//            attachments.recording = Recording()
//            let url = await recorder.startRecording { duration, samples in
//                DispatchQueue.main.async { [weak self] in
//                    self?.attachments.recording?.duration = duration
//                    self?.attachments.recording?.waveformSamples = samples
//                }
//            }
//            if state == .waitingForRecordingPermission {
//                state = .isRecordingTap
//            }
//            attachments.recording?.url = url
//        }
//    }
}

private extension InputViewModel {

    func validateDraft() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if !self.text.isEmpty || self.attachments.medias != nil {
                self.state = .hasTextOrMedia
            } else {
                self.state = .empty
            }
        }
    }

    func subscribeValidation() {
        $attachments.sink { [weak self] _ in
            self?.validateDraft()
        }
        .store(in: &subscriptions)

        $text.sink { [weak self] _ in
            self?.validateDraft()
        }
        .store(in: &subscriptions)
    }

//    func subscribePicker() {
//        $showPicker
//            .sink { [weak self] value in
//                if !value {
//                    self?.attachments.medias
//                }
//            }
//            .store(in: &subscriptions)
//    }


    func unsubscribeRecordPlayer() {
        recordPlayerSubscription = nil
    }
}

private extension InputViewModel {
    
    func mapAttachmentsForSend() -> AnyPublisher<[Attachment], Never> {
        attachments.medias.publisher
            .receive(on: DispatchQueue.global())
            .asyncMap { media in
                guard let thumbnailURL = await media.getThumbnailURL() else {
                    return nil
                }

                switch media.type {
                case .image:
                    return Attachment(id: UUID().uuidString, url: thumbnailURL, type: .image)
                case .video:
                    guard let fullURL = await media.getURL() else {
                        return nil
                    }
                    return Attachment(id: UUID().uuidString, thumbnail: thumbnailURL, full: fullURL, type: .video)
                }
            }
            .compactMap {
                $0
            }
            .collect()
            .eraseToAnyPublisher()
    }

    func sendMessage() -> AnyCancellable {
        showActivityIndicator = true
        return mapAttachmentsForSend()
            .compactMap { [attachments] _ in
                DraftMessage(
                    text: self.text,
                    medias: attachments.medias,
                    createdAt: Date()
                )
            }
            .sink { [weak self] draft in
                self?.didSendMessage?(draft)
                DispatchQueue.main.async { [weak self] in
                    self?.showActivityIndicator = false
                    self?.reset()
                }
            }
    }
}

extension Publisher {
    func asyncMap<T>(
        _ transform: @escaping (Output) async -> T
    ) -> Publishers.FlatMap<Future<T, Never>, Self> {
        flatMap { value in
            Future { promise in
                Task {
                    let output = await transform(value)
                    promise(.success(output))
                }
            }
        }
    }
}

public enum MediaPickerMode: Equatable {

    case photos
    case albums
//    case album(Album)
    case camera
    case cameraSelection

    public static func == (lhs: MediaPickerMode, rhs: MediaPickerMode) -> Bool {
        switch (lhs, rhs) {
        case (.photos, .photos):
            return true
        case (.albums, .albums):
            return true
//        case (.album(let a1), .album(let a2)):
//            return a1.id == a2.id
        case (.camera, .camera):
            return true
        case (.cameraSelection, .cameraSelection):
            return true
        default:
            return false
        }
    }
}
