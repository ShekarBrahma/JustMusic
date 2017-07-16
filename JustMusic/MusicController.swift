//
//  MusicController.swift
//  JustMusic
//
//  Created by Shekar on 4/5/17.
//  Copyright © 2017 Shekar. All rights reserved.
//

import Foundation
import MediaPlayer

class MusicController {
    
    /// Stores all the music data
    var library = MusicLibrary()
    
    /// Controller that handles playing media
    let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
    
    /// Current state of playback queue
    var queue = [MPMediaItem]()
    
    /// State of repeat mode
    var repeatMode = false
    
    /// Index in queue stored when entering repeat mode
    var queueIndex = 0
    
    
    /**
     Adds the songs on the user's device to the library.
    */
    func setupLibrary() {
        library.addSongs()
        musicPlayer.prepareToPlay()
        queue = [MPMediaItem]()
        for item in getAllSongs() {
            queue.append(library.idDictionary[item.persistentID]!)
        }
        musicPlayer.setQueue(with: MPMediaItemCollection(items: queue))
    }
    
    
    /**
     Used to convert persistent ids back to Song objects
    */
    func convertIdsToSongs(ids: [UInt64]) -> [Song]{
        var conertedSongs = [Song]()
        for id in ids {
            conertedSongs.append(library.songDictionary[id]!)
        }
        return conertedSongs
    }
    
    
    /**
     Gets an array of all the Song objects in the library.
     
     - Returns: array of Song objects
    */
    func getAllSongs() -> [Song] {
        return sortSongs(songs: library.musicLibrary)
    }

    
    /**
     Sorts the Song objects by title, and makes numberical titles last.
     
     - Parameter songs: array of Song objects

     - Returns: sorted array of Song objects
    */
    func sortSongs(songs: [Song]) -> [Song] {
        var startsWithDigit = [Song]()
        var startsWithCharacter = [Song]()
        for song in songs {
            if let first = song.title.characters.first {
                if first >= "0" && first <= "9" {
                    startsWithDigit.append(song)
                }
                else {
                    startsWithCharacter.append(song)
                }
            }
        }
        func removeArticles(str: String) -> String {
            if str.lowercased().hasPrefix("the ".lowercased()) {
                let index = str.index(str.startIndex, offsetBy: 4)
                return str.substring(from: index)
            } else if str.lowercased().hasPrefix("an ".lowercased()) {
                let index = str.index(str.startIndex, offsetBy: 3)
                return str.substring(from: index)
            } else if str.lowercased().hasPrefix("a ".lowercased()) {
                let index = str.index(str.startIndex, offsetBy: 2)
                return str.substring(from: index)
            }
            return str
        }
        return startsWithCharacter.sorted(by: { removeArticles(str: $0.title) < removeArticles(str: $1.title) }) +
            startsWithDigit.sorted(by: { $0.title < $1.title })
    }
    

    /**
     Plays the selected song and sets up queque for next songs.
     
     - Parameter index: Index of song in songList
     - Parameter songList: current playlist
    */
    func playSong(index: Int, songList: [Song]) {
        queue = [MPMediaItem]()
        musicPlayer.stop()
        let list = songList[index..<songList.count] + songList[0..<index]
        for item in list {
            queue.append(library.idDictionary[item.persistentID]!)
        }
        musicPlayer.setQueue(with: MPMediaItemCollection(items: queue))
        musicPlayer.prepareToPlay()
        musicPlayer.play()
    }
    
    
    /**
     Pauses currently playing song.
    */
    func pauseSong() {
        musicPlayer.pause()
    }
    
    
    /**
     Moves player to previous song in playlist
     */
    func previousSong() {
        if musicPlayer.playbackState == MPMusicPlaybackState.paused ||
            musicPlayer.indexOfNowPlayingItem == NSNotFound {
            musicPlayer.skipToPreviousItem()
        } else {
            musicPlayer.pause()
            musicPlayer.skipToPreviousItem()
            musicPlayer.prepareToPlay()
            musicPlayer.play()
        }
    }
    
    
    /**
     Moves player to next song in playlist
     */
    func nextSong() {
        if musicPlayer.playbackState == MPMusicPlaybackState.paused ||
            musicPlayer.indexOfNowPlayingItem == NSNotFound {
            musicPlayer.skipToNextItem()
        } else {
            musicPlayer.pause()
            musicPlayer.skipToNextItem()
            musicPlayer.prepareToPlay()
            musicPlayer.play()
        }
    }
    
    
    /**
     Shuffles queue of songs
     */
    func shuffleSongs() {
        queue = [MPMediaItem]()
        let shuffledList = songList.shuffled()
        for item in shuffledList {
            queue.append(library.idDictionary[item.persistentID]!)
        }
        musicPlayer.setQueue(with: MPMediaItemCollection(items: queue))
    }
    
    
    /**
    */
    func repeatSong() {
        if musicPlayer.playbackState == MPMusicPlaybackState.playing &&
            musicPlayer.indexOfNowPlayingItem != NSNotFound {
            if repeatMode == false {
                queueIndex = musicPlayer.indexOfNowPlayingItem
                musicPlayer.setQueue(with: MPMediaItemCollection(items: [queue[queueIndex]]))
                repeatMode = true
            } else {
                var regList = [MPMediaItem]()
                for i in (queueIndex+1)..<queue.count {
                    regList.append(queue[i])
                }
                for i in 0..<(queueIndex+1) {
                    regList.append(queue[i])
                }
                queue = regList
                musicPlayer.setQueue(with: MPMediaItemCollection(items: regList))
                repeatMode = false
            }
            
        }
    }
    
}


// https://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift
extension MutableCollection where Indices.Iterator.Element == Index {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }
        
        for (firstUnshuffled , unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            let d: IndexDistance = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            guard d != 0 else { continue }
            let i = index(firstUnshuffled, offsetBy: d)
            swap(&self[firstUnshuffled], &self[i])
        }
    }
}


extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Iterator.Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
