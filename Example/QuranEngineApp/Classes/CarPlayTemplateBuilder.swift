//
//  CarPlayTemplateBuilder.swift
//  QuranEngineApp
//
//  Created for CarPlay support
//
import CarPlay
import UIKit

final class CarPlayTemplateBuilder {
    static let shared = CarPlayTemplateBuilder()

    func createChapterListTemplate(
        with chapters: [ChapterInfo],
        selectionHandler: @escaping (ChapterInfo) -> Void
    ) -> CPListTemplate {
        let items: [CPListItem] = chapters.map { chapter in
            let item = CPListItem(text: "\(chapter.number). \(chapter.name)", detailText: nil)
            item.handler = { _, completion in
                selectionHandler(chapter)
                completion()
            }
            return item
        }

        return CPListTemplate(
            title: "Quran Chapters",
            sections: [CPListSection(items: items)]
        )
    }
}
