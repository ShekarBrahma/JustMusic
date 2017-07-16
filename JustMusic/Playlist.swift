//
//  Playlist.swift
//  JustMusic
//
//  Created by Shekar on 4/20/17.
//  Copyright © 2017 Shekar. All rights reserved.
//

import Foundation

/**
 Collection of Song objects
 */
struct Playlist {
    
    var title: String
    var songs: [Song]
    
    
    /**
     - Parameters
        - title: name of the playlist
        - songs: array of Song objects
    */
    init(title: String, songs: [Song]) {
        self.title = title
        self.songs = songs
    }
    
}
