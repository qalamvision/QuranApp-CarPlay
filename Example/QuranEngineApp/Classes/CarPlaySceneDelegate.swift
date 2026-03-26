import CarPlay
import UIKit


@MainActor
final class CarPlaySceneDelegate: UIResponder, CPTemplateApplicationSceneDelegate {
    private var interfaceController: CPInterfaceController?
    private var playbackController: AudioPlaybackController?

    func templateApplicationScene(
        _ templateApplicationScene: CPTemplateApplicationScene,
        didConnect interfaceController: CPInterfaceController
    ) {
        print("[CarPlay] templateApplicationScene didConnect called")

        self.interfaceController = interfaceController
        let chapters = createChapters()

        let rootTemplate = CarPlayTemplateBuilder.shared.createChapterListTemplate(with: chapters) { [weak self] chapter in
            guard let self else { return }

            Task { @MainActor in
                guard let playbackController = AudioPlaybackControllerStore.shared else {
                    print("[CarPlay] No shared AudioPlaybackController available on selection")
                    return
                }

                self.playbackController = playbackController

                do {
                    print("[CarPlay] Selected surah \(chapter.number): \(chapter.name)")
                    try await playbackController.playSurah(chapter.number)
                    if let interfaceController = self.interfaceController,
                       interfaceController.topTemplate !== CPNowPlayingTemplate.shared {
                        try await interfaceController.pushTemplate(CPNowPlayingTemplate.shared, animated: true)
                    }
                } catch {
                    print("[CarPlay] Failed to play surah \(chapter.number): \(error)")
                }
            }
        }

        Task { @MainActor in
            do {
                try await interfaceController.setRootTemplate(rootTemplate, animated: true)
                print("[CarPlay] Root template set")
            } catch {
                print("[CarPlay] Failed to set root template: \(error)")
            }
        }
    }
    private func createChapters() -> [ChapterInfo] {
        (1...114).map { number in
            ChapterInfo(
                id: number,
                number: number,
                name: getChapterName(number)
            )
        }
    }

    private func getChapterName(_ number: Int) -> String {
        let chapterNames = [
            "Al-Fatihah", "Al-Baqarah", "Ali 'Imran", "An-Nisa", "Al-Ma'idah",
            "Al-An'am", "Al-A'raf", "Al-Anfal", "At-Taubah", "Yunus",
            "Hud", "Yusuf", "Ar-Ra'd", "Ibrahim", "Al-Hijr",
            "An-Nahl", "Al-Isra", "Al-Kahf", "Maryam", "Ta-Ha",
            "Al-Anbiya", "Al-Hajj", "Al-Mu'minun", "An-Nur", "Al-Furqan",
            "Ash-Shu'ara", "An-Naml", "Al-Qasas", "Al-'Ankabut", "Ar-Rum",
            "Luqman", "As-Sajdah", "Al-Ahzab", "Saba", "Fatir",
            "Ya-Sin", "As-Saffat", "Sad", "Az-Zumar", "Ghafir",
            "Fussilat", "Ash-Shura", "Az-Zukhruf", "Ad-Dukhan", "Al-Jathiya",
            "Al-Ahqaf", "Muhammad", "Al-Fath", "Al-Hujurat", "Qaf",
            "Adh-Dhariyat", "At-Tur", "An-Najm", "Al-Qamar", "Ar-Rahman",
            "Al-Waqi'ah", "Al-Hadid", "Al-Mujadilah", "Al-Hashr", "Al-Mumtahanah",
            "As-Saff", "Al-Jumu'ah", "Al-Munafiqun", "At-Taghabun", "At-Talaq",
            "At-Tahrim", "Al-Mulk", "Al-Qalam", "Al-Haqqah", "Al-Ma'arij",
            "Nuh", "Al-Jinn", "Al-Muzzammil", "Al-Muddaththir", "Al-Qiyamah",
            "Ad-Dahr", "Al-Mursalat", "An-Naba", "An-Nazi'at", "Abasa",
            "At-Takwir", "Al-Infitar", "Al-Mutaffifin", "Al-Inshiqaq", "Al-Buruj",
            "At-Tariq", "Al-A'la", "Al-Ghashiyah", "Al-Fajr", "Al-Balad",
            "Ash-Shams", "Al-Lail", "Ad-Duhaa", "Ash-Sharh", "At-Tin",
            "Al-'Alaq", "Al-Qadr", "Al-Bayyinah", "Az-Zilzal", "Al-Adiyat",
            "Al-Qari'ah", "At-Takathur", "Al-'Asr", "Al-Humazah", "Al-Fil",
            "Quraysh", "Al-Ma'un", "Al-Kawthar", "Al-Kafirun", "An-Nasr",
            "Al-Masad", "Al-Ikhlas", "Al-Falaq", "An-Nas"
        ]
        return number <= chapterNames.count ? chapterNames[number - 1] : "Chapter \(number)"
    }
}

struct ChapterInfo {
    let id: Int
    let number: Int
    let name: String
    

}
