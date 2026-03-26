////
////  MediaPlayerManager.swift
////  QuranEngineApp
////
////  Created for CarPlay support
////
//
//import AVFoundation
//import MediaPlayer
//import Foundation
//
///// Manages audio playback and MediaPlayer remote commands
//class MediaPlayerManager: NSObject, AVAudioPlayerDelegate {
//    // MARK: Internal
//
//    static let shared = MediaPlayerManager()
//
//    var isPlaying: Bool {
//        audioPlayer?.isPlaying ?? false
//    }
//
//    var currentChapter: ChapterInfo?
//    var chapters: [ChapterInfo] = []
//
//    private var remoteCommandsConfigured = false
//
//    func setupRemoteTransportControls() {
//        guard !remoteCommandsConfigured else { return }
//        remoteCommandsConfigured = true
//
//        let commandCenter = MPRemoteCommandCenter.shared()
//
//        commandCenter.playCommand.addTarget { [weak self] _ in
//            self?.play()
//            return .success
//        }
//
//        commandCenter.pauseCommand.addTarget { [weak self] _ in
//            self?.pause()
//            return .success
//        }
//
//        commandCenter.nextTrackCommand.addTarget { [weak self] _ in
//            self?.playNext()
//            return .success
//        }
//
//        commandCenter.previousTrackCommand.addTarget { [weak self] _ in
//            self?.playPrevious()
//            return .success
//        }
//
//        commandCenter.skipForwardCommand.preferredIntervals = [15]
//        commandCenter.skipForwardCommand.addTarget { [weak self] _ in
//            self?.skipForward()
//            return .success
//        }
//
//        commandCenter.skipBackwardCommand.preferredIntervals = [15]
//        commandCenter.skipBackwardCommand.addTarget { [weak self] _ in
//            self?.skipBackward()
//            return .success
//        }
//    }
//
//
//    func loadChapters(_ chapters: [ChapterInfo]) {
//        self.chapters = chapters
//    }
//
//    func playChapter(_ chapter: ChapterInfo) {
//        currentChapter = chapter
//        guard let audioURL = chapter.audioURL else { return }
//
//        do {
//            audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
//            audioPlayer?.delegate = self
//            audioPlayer?.play()
//            updateNowPlaying()
//        } catch {
//            print("Error loading audio: \(error)")
//        }
//    }
//
//    func play() {
//        if audioPlayer == nil, let chapter = currentChapter {
//            playChapter(chapter)
//        } else {
//            audioPlayer?.play()
//            updateNowPlaying()
//        }
//    }
//
//    func pause() {
//        audioPlayer?.pause()
//        updateNowPlaying()
//    }
//
//    func playNext() {
//        guard let current = currentChapter,
//              let currentIndex = chapters.firstIndex(where: { $0.id == current.id }),
//              currentIndex + 1 < chapters.count else {
//            return
//        }
//        playChapter(chapters[currentIndex + 1])
//    }
//
//    func playPrevious() {
//        guard let current = currentChapter,
//              let currentIndex = chapters.firstIndex(where: { $0.id == current.id }),
//              currentIndex > 0 else {
//            return
//        }
//        playChapter(chapters[currentIndex - 1])
//    }
//
//    func skipForward() {
//        guard let player = audioPlayer else { return }
//        let newTime = player.currentTime + 15
//        player.currentTime = min(newTime, player.duration)
//    }
//
//    func skipBackward() {
//        guard let player = audioPlayer else { return }
//        let newTime = player.currentTime - 15
//        player.currentTime = max(0, newTime)
//    }
//
//    func updateNowPlaying() {
//        guard let chapter = currentChapter else { return }
//
//        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [String: Any]()
//
//        nowPlayingInfo[MPMediaItemPropertyTitle] = chapter.name
//        nowPlayingInfo[MPMediaItemPropertyArtist] = "Quran"
//        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = "Quran - Chapter \(chapter.number)"
//
//        if let player = audioPlayer {
//            nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = player.duration
//            nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = player.currentTime
//            nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.isPlaying ? 1.0 : 0.0
//        }
//
//        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
//    }
//
//    func getCurrentPlayer() -> AVAudioPlayer? {
//        return audioPlayer
//    }
//
//    // MARK: AVAudioPlayerDelegate
//
//    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
//        if flag {
//            playNext()
//        }
//    }
//
//    // MARK: Private
//
//    private var audioPlayer: AVAudioPlayer?
//
//    private override init() {
//        super.init()
//    }
//}
//
