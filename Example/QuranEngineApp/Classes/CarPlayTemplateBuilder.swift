//
//  CarPlayTemplateBuilder.swift
//  QuranEngineApp
//
//  Created for CarPlay support
//
import CarPlay
import QuranAudio
import QuranAudioKit
import UIKit

struct ReciterInfo: Equatable {
    let id: Int
    let name: String
}

final class CarPlayTemplateBuilder {
    static let shared = CarPlayTemplateBuilder()

    func makeChapterListTemplate(
        chapters: [ChapterInfo],
        selectedSurahNumber: Int?,
        selectionHandler: @escaping (ChapterInfo) -> Void
    ) -> CPListTemplate {
        let template = configuredTemplate(
            title: "Quran Chapters",
            tabTitle: "Surahs",
            tabImage: "book.closed"
        )
        updateChapterListTemplate(
            template,
            chapters: chapters,
            selectedSurahNumber: selectedSurahNumber,
            selectionHandler: selectionHandler
        )
        return template
    }

    func updateChapterListTemplate(
        _ template: CPListTemplate,
        chapters: [ChapterInfo],
        selectedSurahNumber: Int?,
        selectionHandler: @escaping (ChapterInfo) -> Void
    ) {
        let items: [CPListItem] = chapters.map { chapter in
            let isSelected = chapter.number == selectedSurahNumber
            let item = CPListItem(
                text: "\(chapter.number). \(chapter.name)",
                detailText: isSelected ? "Current surah" : nil
            )
            item.handler = { _, completion in
                selectionHandler(chapter)
                completion()
            }
            return item
        }
        template.updateSections([CPListSection(items: items)])
    }

    func makeRecitersTemplate(
        reciters: [ReciterInfo],
        selectedReciterId: Int?,
        selectionHandler: @escaping (ReciterInfo) -> Void
    ) -> CPListTemplate {
        let template = configuredTemplate(
            title: "Reciters",
            tabTitle: "Reciters",
            tabImage: "person.wave.2"
        )
        updateRecitersTemplate(
            template,
            reciters: reciters,
            selectedReciterId: selectedReciterId,
            selectionHandler: selectionHandler
        )
        return template
    }

    func updateRecitersTemplate(
        _ template: CPListTemplate,
        reciters: [ReciterInfo],
        selectedReciterId: Int?,
        selectionHandler: @escaping (ReciterInfo) -> Void
    ) {
        let items: [CPListItem] = reciters.map { reciter in
            let isSelected = reciter.id == selectedReciterId
            let item = CPListItem(
                text: reciter.name,
                detailText: isSelected ? "Current reciter" : nil
            )
            item.handler = { _, completion in
                selectionHandler(reciter)
                completion()
            }
            return item
        }
        template.updateSections([CPListSection(items: items)])
    }

    func makePlaybackModesTemplate(
        playbackModes: [AudioEnd],
        selectedMode: AudioEnd,
        selectionHandler: @escaping (AudioEnd) -> Void
    ) -> CPListTemplate {
        let template = configuredTemplate(
            title: "Playback Options",
            tabTitle: "Playback",
            tabImage: "waveform"
        )
        updatePlaybackModesTemplate(
            template,
            playbackModes: playbackModes,
            selectedMode: selectedMode,
            selectionHandler: selectionHandler
        )
        return template
    }

    func updatePlaybackModesTemplate(
        _ template: CPListTemplate,
        playbackModes: [AudioEnd],
        selectedMode: AudioEnd,
        selectionHandler: @escaping (AudioEnd) -> Void
    ) {
        let items: [CPListItem] = playbackModes.map { mode in
            let detailText = mode == selectedMode ? "Current mode" : nil
            let item = CPListItem(text: mode.name, detailText: detailText)
            item.handler = { _, completion in
                selectionHandler(mode)
                completion()
            }
            return item
        }
        template.updateSections([CPListSection(items: items)])
    }

    func makeRootTemplate(templates: [CPTemplate]) -> CPTabBarTemplate {
        CPTabBarTemplate(templates: templates)
    }

    private func configuredTemplate(title: String, tabTitle: String, tabImage: String) -> CPListTemplate {
        let template = CPListTemplate(title: title, sections: [])
        template.tabTitle = tabTitle
        template.tabImage = UIImage(systemName: tabImage)
        return template
    }
}
