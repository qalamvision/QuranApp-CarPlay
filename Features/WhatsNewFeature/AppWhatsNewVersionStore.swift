//
//  AppWhatsNewVersionStore.swift
//  Quran
//
//  Created by Afifi, Mohamed on 10/25/20.
//  Copyright © 2020 Quran.com. All rights reserved.
//

import Preferences
import WhatsNewKit

/// The InMemoryWhatsNewVersionStore
final class AppWhatsNewVersionStore: WhatsNewVersionStore {
    // MARK: Public

    public func has(version: WhatsNew.Version) -> Bool {
        hasSeenVersion(pendingVersion ?? version.description)
    }

    // MARK: Internal

    @Preference(whatsNewVersion)
    var lastSeenVersion: String?

    func prepare(version: String) {
        pendingVersion = version
    }

    func markSeen(version: String) {
        lastSeenVersion = version
        pendingVersion = nil
    }

    func set(version: WhatsNew.Version) {
        markSeen(version: pendingVersion ?? version.description)
    }

    // MARK: Private

    private static let whatsNewVersion = PreferenceKey<String?>(key: "whats-new.seen-version", defaultValue: nil)
    private var pendingVersion: String?

    private func hasSeenVersion(_ version: String) -> Bool {
        guard let lastSeenVersion else {
            return false
        }
        return version.compare(lastSeenVersion, options: .numeric) != .orderedDescending
    }
}
