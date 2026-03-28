import CarPlay
import MediaPlayer
import QueuePlayer
import QuranAudio
import QuranAudioKit
import QuranKit
import ReciterService
import UIKit

@MainActor
final class CarPlaySceneDelegate: UIResponder, @preconcurrency CPTemplateApplicationSceneDelegate {
    private var interfaceController: CPInterfaceController?
    private var playbackController: AudioPlaybackController?
    private var playbackObserverId: UUID?
    private var chaptersTemplate: CPListTemplate?
    private var recitersTemplate: CPListTemplate?
    private var playbackModesTemplate: CPListTemplate?
    private var chapters: [ChapterInfo] = []
    private var reciters: [Reciter] = []
    private let audioPreferences = AudioPreferences.shared
    private var selectedSurahNumber = 1
    private var selectedReciterId: Int?
    private var selectedPlaybackMode = AudioEnd.juz
    private var lastObservedPlaybackState: AudioPlaybackController.PlaybackState?
    private var isPresentingNowPlaying = false

    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        self.interfaceController = interfaceController
        chapters = createChapters()

        guard let playbackController = AudioPlaybackControllerStore.shared else {
            print("[CarPlay] No shared AudioPlaybackController available")
            return
        }

        self.playbackController = playbackController
        observePlaybackController(playbackController)
        selectedPlaybackMode = audioPreferences.audioEnd

        Task { @MainActor in
            let reciters = await playbackController.getReciters()
            self.reciters = reciters
            let snapshot = playbackController.snapshot
            selectedSurahNumber = snapshot.surahNumber ?? selectedSurahNumber
            selectedReciterId = snapshot.reciter?.id ?? reciters.first?.id

            let builder = CarPlayTemplateBuilder.shared
            let chaptersTemplate = builder.makeChapterListTemplate(
                chapters: chapters,
                selectedSurahNumber: selectedSurahNumber,
                selectionHandler: { [weak self] chapter in
                    self?.didSelectChapter(chapter)
                }
            )
            let recitersTemplate = builder.makeRecitersTemplate(
                reciters: reciterInfos(),
                selectedReciterId: selectedReciterId,
                selectionHandler: { [weak self] reciter in
                    self?.didSelectReciter(reciter)
                }
            )
            let playbackModesTemplate = builder.makePlaybackModesTemplate(
                playbackModes: [.juz, .sura, .page],
                selectedMode: selectedPlaybackMode,
                selectionHandler: { [weak self] mode in
                    self?.didSelectPlaybackMode(mode)
                }
            )

            self.chaptersTemplate = chaptersTemplate
            self.recitersTemplate = recitersTemplate
            self.playbackModesTemplate = playbackModesTemplate

            do {
                let rootTemplate = builder.makeRootTemplate(templates: [
                    chaptersTemplate,
                    recitersTemplate,
                    playbackModesTemplate,
                ])
                try await interfaceController.setRootTemplate(rootTemplate, animated: true)
                refreshTemplates()
                updateNowPlayingInfo(with: snapshot)
            } catch {
                print("[CarPlay] Failed to set root template: \(error)")
            }
        }
    }

    private func observePlaybackController(_ playbackController: AudioPlaybackController) {
        playbackObserverId = playbackController.addObserver { [weak self] snapshot in
            self?.handlePlaybackSnapshot(snapshot)
        }
    }

    private func handlePlaybackSnapshot(_ snapshot: AudioPlaybackController.Snapshot) {
        if let surahNumber = snapshot.surahNumber {
            selectedSurahNumber = surahNumber
        }
        if let reciterId = snapshot.reciter?.id {
            selectedReciterId = reciterId
        }

        refreshTemplates()
        updateNowPlayingInfo(with: snapshot)

        if case .playing = snapshot.playbackState, !isPlaying(lastObservedPlaybackState) {
            Task { @MainActor in
                await presentNowPlayingIfNeeded()
            }
        }

        lastObservedPlaybackState = snapshot.playbackState
    }

    private func didSelectChapter(_ chapter: ChapterInfo) {
        selectedSurahNumber = chapter.number
        refreshTemplates()
        Task { @MainActor in
            await playCurrentSelection()
        }
    }

    private func didSelectReciter(_ reciterInfo: ReciterInfo) {
        guard let playbackController,
              let reciter = reciters.first(where: { $0.id == reciterInfo.id }) else {
            return
        }

        selectedReciterId = reciter.id
        playbackController.setReciter(reciter)
        refreshTemplates()
        updateNowPlayingInfo(with: playbackController.snapshot)
    }

    private func didSelectPlaybackMode(_ mode: AudioEnd) {
        selectedPlaybackMode = mode
        audioPreferences.audioEnd = mode
        refreshTemplates()
        Task { @MainActor in
            await playCurrentSelection()
        }
    }

    private func playCurrentSelection() async {
        guard let playbackController else {
            return
        }

        let quran = Quran.hafsMadani1405
        guard quran.suras.indices.contains(selectedSurahNumber - 1) else {
            return
        }

        let surah = quran.suras[selectedSurahNumber - 1]
        let request = playbackRequest(for: surah, audioEnd: selectedPlaybackMode)

        do {
            try await playbackController.play(
                from: request.start,
                to: request.end,
                verseRuns: request.verseRuns,
                listRuns: request.listRuns
            )
            updateNowPlayingInfo(with: playbackController.snapshot)
            await presentNowPlayingIfNeeded()
        } catch {
            print("[CarPlay] Failed to play surah \(selectedSurahNumber): \(error)")
        }
    }

    private func presentNowPlayingIfNeeded() async {
        guard let interfaceController,
              !isPresentingNowPlaying,
              interfaceController.topTemplate !== CPNowPlayingTemplate.shared else {
            return
        }

        do {
            isPresentingNowPlaying = true
            defer { isPresentingNowPlaying = false }
            try await interfaceController.pushTemplate(CPNowPlayingTemplate.shared, animated: true)
        } catch {
            print("[CarPlay] Failed to push now playing template: \(error)")
        }
    }

    private func refreshTemplates() {
        let builder = CarPlayTemplateBuilder.shared

        if let chaptersTemplate {
            builder.updateChapterListTemplate(
                chaptersTemplate,
                chapters: chapters,
                selectedSurahNumber: selectedSurahNumber,
                selectionHandler: { [weak self] chapter in
                    self?.didSelectChapter(chapter)
                }
            )
        }

        if let recitersTemplate {
            builder.updateRecitersTemplate(
                recitersTemplate,
                reciters: reciterInfos(),
                selectedReciterId: selectedReciterId,
                selectionHandler: { [weak self] reciter in
                    self?.didSelectReciter(reciter)
                }
            )
        }

        if let playbackModesTemplate {
            builder.updatePlaybackModesTemplate(
                playbackModesTemplate,
                playbackModes: [.juz, .sura, .page],
                selectedMode: selectedPlaybackMode,
                selectionHandler: { [weak self] mode in
                    self?.didSelectPlaybackMode(mode)
                }
            )
        }
    }

    private func updateNowPlayingInfo(with snapshot: AudioPlaybackController.Snapshot) {
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]

        if let title = snapshot.surahTitle {
            info[MPMediaItemPropertyTitle] = title
        }
        if let reciterName = snapshot.reciterName {
            info[MPMediaItemPropertyArtist] = reciterName
        }

        let existingRate = (info[MPNowPlayingInfoPropertyPlaybackRate] as? NSNumber)?.floatValue ?? 1
        let playbackRate: Float = switch snapshot.playbackState {
        case .playing:
            existingRate
        case .paused, .stopped, .downloading:
            0
        }
        info[MPNowPlayingInfoPropertyPlaybackRate] = playbackRate

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info.isEmpty ? nil : info
    }

    private func createChapters() -> [ChapterInfo] {
        (1 ... 114).map { number in
            ChapterInfo(id: number, number: number, name: AudioPlaybackController.surahTitle(for: number))
        }
    }

    private func reciterInfos() -> [ReciterInfo] {
        reciters.map { ReciterInfo(id: $0.id, name: $0.localizedName) }
    }

    private func isPlaying(_ state: AudioPlaybackController.PlaybackState?) -> Bool {
        guard let state else {
            return false
        }
        if case .playing = state {
            return true
        }
        return false
    }

    private func playbackRequest(
        for surah: Sura,
        audioEnd: AudioEnd
    ) -> (start: AyahNumber, end: AyahNumber, verseRuns: Runs, listRuns: Runs) {
        let start = surah.firstVerse
        let end = audioEnd.findLastAyah(startAyah: start)
        return (start, end, .one, .one)
    }
}

struct ChapterInfo {
    let id: Int
    let number: Int
    let name: String
}

private extension AudioEnd {
    func findLastAyah(startAyah: AyahNumber) -> AyahNumber {
        let pageLastVerse = PageBasedLastAyahFinder().findLastAyah(startAyah: startAyah)
        let lastVerse: AyahNumber = switch self {
        case .juz:
            JuzBasedLastAyahFinder().findLastAyah(startAyah: startAyah)
        case .sura:
            SuraBasedLastAyahFinder().findLastAyah(startAyah: startAyah)
        case .page:
            pageLastVerse
        }
        return max(lastVerse, pageLastVerse)
    }
}
