//
//  NowPlayingUpdater.swift
//  Quran
//
//  Created by Afifi, Mohamed on 4/28/19.
//  Copyright © 2019 Quran.com. All rights reserved.
//

import MediaPlayer

@MainActor
public class NowPlayingUpdater {
    // MARK: Lifecycle

    public init(center: MPNowPlayingInfoCenter) {
        self.center = center
    }

    // MARK: Public

    public func clear() {
        nowPlayingInfo = nil
    }

    public func update(duration: TimeInterval) {
        update([MPMediaItemPropertyPlaybackDuration: duration])
    }

    public func update(elapsedTime: TimeInterval) {
        update([MPNowPlayingInfoPropertyElapsedPlaybackTime: elapsedTime])
    }

    public func update(info: PlayerItemInfo) {
        update([MPMediaItemPropertyTitle: info.title,
                MPMediaItemPropertyArtist: info.artist])
        if let artwork = info.artwork {
            update([MPMediaItemPropertyArtwork: artwork])
        }
    }

    public func update(rate: Float) {
        update([MPNowPlayingInfoPropertyPlaybackRate: rate])
    }

    public func update(count: Int) {
        update([MPNowPlayingInfoPropertyPlaybackQueueCount: count])
    }

    public func update(playingIndex: Int) {
        update([MPNowPlayingInfoPropertyPlaybackQueueIndex: playingIndex])
    }

    // MARK: Private

    private let center: MPNowPlayingInfoCenter

    private var nowPlayingInfo: [String: Any]? {
        get { center.nowPlayingInfo }
        set { center.nowPlayingInfo = newValue }
    }

    private func update(_ values: [String: Any]) {
        var info = center.nowPlayingInfo ?? nowPlayingInfo ?? [:]
        for (key, value) in values {
            info[key] = value
        }
        nowPlayingInfo = info
    }
}
