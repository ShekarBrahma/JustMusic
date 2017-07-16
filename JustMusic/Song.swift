//
//  Song.swift
//  JustMusic
//
//  Created by Shekar on 4/11/17.
//  Copyright © 2017 Shekar. All rights reserved.
//

import Foundation
import MediaPlayer

/**
 Data structure to handle song data
 */
class Song: NSObject, NSCoding {
    
    var title: String
    var album: String
    var artist: String
    var artwork: MPMediaItemArtwork
    var persistentID: UInt64
    var genre: String
    
    
    /**
     - Parameters:
        - title: name of the song
        - album: album for song
        - artist: artist who wrote song
        - artwork: image on album cover
        - persistentID: id used to uniquely identify song on device
        - genre: category of music song applies to
    */
    init(title: String, album: String, artist: String, artwork: MPMediaItemArtwork, persistentID: UInt64, genre: String) {
        self.title = title
        self.album = album
        self.artist = artist
        self.artwork = artwork
        self.persistentID = persistentID
        self.genre = genre
    }
    
    // MARK: NSCoding
    
    required convenience init?(coder decoder: NSCoder) {
        guard let title = decoder.decodeObject(forKey: "title") as? String,
            let album = decoder.decodeObject(forKey: "album") as? String,
            let artist = decoder.decodeObject(forKey: "artist") as? String,
            let artwork = decoder.decodeObject(forKey: "artwork") as? MPMediaItemArtwork,
            let persistentID = decoder.decodeObject(forKey: "persistentID") as? UInt64,
            let genre = decoder.decodeObject(forKey: "genre") as? String
            else { return nil }
        
        self.init(
            title: title,
            album: album,
            artist: artist,
            artwork: artwork,
            persistentID: persistentID,
            genre: genre
        )
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(self.title, forKey: "title")
        coder.encode(self.album, forKey: "album")
        coder.encode(self.artist, forKey: "artist")
        coder.encode(self.persistentID, forKey: "persistentID")
        coder.encode(self.genre, forKey: "genre")
    }
    
}
