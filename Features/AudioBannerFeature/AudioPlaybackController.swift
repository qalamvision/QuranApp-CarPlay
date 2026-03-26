//
//  AudioPlaybackController.md
//  QuranEngineApp
//
//  Created by aom on 3/9/26.
//


import Foundation
import QueuePlayer
import QuranAudio
import QuranAudioKit
import QuranKit
import ReciterService

@MainActor
final class AudioPlaybackController {
    private let audioPlayer: QuranAudioPlayer
    private let downloader: QuranAudioDownloader
    private let recentRecitersService: RecentRecitersService
    private let preferences = ReciterPreferences.shared
    private let reciterRetriever: ReciterDataRetriever
    var player: QuranAudioPlayer { audioPlayer }
    var audioDownloader: QuranAudioDownloader { downloader }
    init(
        audioPlayer: QuranAudioPlayer,
        downloader: QuranAudioDownloader,
        reciterRetriever: ReciterDataRetriever,
        recentRecitersService: RecentRecitersService
    ) {
        self.audioPlayer = audioPlayer
        self.downloader = downloader
        self.reciterRetriever = reciterRetriever
        self.recentRecitersService = recentRecitersService
    }

    func playSurah(_ surahNumber: Int) async throws {
        let quran = Quran.hafsMadani1405
        guard surahNumber >= 1, surahNumber <= quran.suras.count else {
            return
        }

        let sura = quran.suras[surahNumber - 1]
        try await play(from: sura.firstVerse, to: sura.lastVerse)
    }

    func play(
        from: AyahNumber,
        to: AyahNumber?,
        verseRuns: Runs = .one,
        listRuns: Runs = .one
    ) async throws {
        let reciters = await reciterRetriever.getReciters()
        guard let reciter = selectedReciter(from: reciters) ?? reciters.first else {
            return
        }

        let end = to ?? from.page.lastVerse
        recentRecitersService.updateRecentRecitersList(reciter)

        let alreadyDownloaded = await downloader.downloaded(
            reciter: reciter,
            from: from,
            to: end
        )

        if !alreadyDownloaded {
            let response = try await downloader.download(
                from: from,
                to: end,
                reciter: reciter
            )
            for try await _ in response.progress {
            }
        }

        try await audioPlayer.play(
            reciter: reciter,
            rate: AudioPreferences.shared.playbackRate,
            from: from,
            to: end,
            verseRuns: verseRuns,
            listRuns: listRuns
        )
    }

    func pause() {
        audioPlayer.pauseAudio()
    }

    func resume() {
        audioPlayer.resumeAudio()
    }

    func stop() {
        audioPlayer.stopAudio()
    }

    func stepForward() {
        audioPlayer.stepForward()
    }

    func stepBackward() {
        audioPlayer.stepBackward()
    }

    func setRate(_ rate: Float) {
        AudioPreferences.shared.playbackRate = rate
        audioPlayer.setRate(rate)
    }

    private func selectedReciter(from reciters: [Reciter]) -> Reciter? {
        reciters.first { $0.id == preferences.lastSelectedReciterId }
    }
}
