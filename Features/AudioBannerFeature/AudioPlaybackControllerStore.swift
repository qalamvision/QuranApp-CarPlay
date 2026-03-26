//
//  AudioPlaybackControllerStore.swift
//  QuranEngineApp
//
//  Created by aom on 3/9/26.
//

import AppDependencies
import Foundation
import QuranAudioKit
import ReciterService

@MainActor
enum AudioPlaybackControllerStore {
    static var shared: AudioPlaybackController?

    static func setUpIfNeeded(container: AppDependencies) {
        guard shared == nil else { return }

        let reciterRetriever = ReciterDataRetriever()
        let recentRecitersService = RecentRecitersService()
        let audioPlayer = QuranAudioPlayer()
        let downloader = QuranAudioDownloader(
            baseURL: container.filesAppHost,
            downloader: container.downloadManager
        )

        shared = AudioPlaybackController(
            audioPlayer: audioPlayer,
            downloader: downloader,
            reciterRetriever: reciterRetriever,
            recentRecitersService: recentRecitersService
        )
    }
}
