//
//  MusicLibrary.swift
//  JustMusic
//
//  Created by Shekar on 4/11/17.
//  Copyright © 2017 Shekar. All rights reserved.
//

import Foundation
import MediaPlayer

/**
 Data structure to handle storage of Song objects
 */
struct MusicLibrary {
    
    /// Array of Song objects
    var musicLibrary: [Song] = [Song]()
    
    /// Dictionary of persistentID's to MPMediaItem
    var idDictionary: [UInt64: MPMediaItem] = [:]
    
    ///
    var songDictionary: [UInt64: Song] = [:]
    
    
    /// Array of songs data from user's device
    var songCollection : MPMediaItemCollection {
        let query = MPMediaQuery.songs()
        let isPresent = MPMediaPropertyPredicate(value:false,
            forProperty:MPMediaItemPropertyIsCloudItem,
            comparisonType:.equalTo)
        query.addFilterPredicate(isPresent)
        return MPMediaItemCollection(items: query.items!)
    }
    
    
    /**
     Collects song data from user's device adds it to musicLibrary
    */
    mutating func addSongs() {
        for index in 0..<songCollection.count {
            let mediaItem = songCollection.items[index]
            let song = Song(
                title: mediaItem.title!,
                album: mediaItem.albumTitle ?? "",
                artist: mediaItem.artist ?? "",
                artwork: mediaItem.artwork ?? MPMediaItemArtwork.init(boundsSize:
                    CGSize.init(width: 50, height: 50), requestHandler: { (size) -> UIImage in
                    return UIImage.init(imageLiteralResourceName: "defaultAlbumCover")
                }),
                persistentID: mediaItem.persistentID,
                genre: mediaItem.genre ?? ""
            )
            idDictionary[song.persistentID] = mediaItem
            songDictionary[song.persistentID] = song
            musicLibrary.append(song)
        }
    }
    
}
