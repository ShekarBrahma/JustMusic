//
//  SelectViewController.swift
//  JustMusic
//
//  Created by Shekar on 4/21/17.
//  Copyright © 2017 Shekar. All rights reserved.
//

import UIKit

class SelectViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// Table view in song selection view
    @IBOutlet weak var songSelection: UITableView!
    
    /// All the song data on user's device
    let songs = musicController.getAllSongs()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    /**
     Updates playlist data after user presses Done
    */
    @IBAction func finishedSelecting(_ sender: Any) {
        if let selectedRows = songSelection.indexPathsForSelectedRows {
            for row in selectedRows {
                playlists[playlists.count-1].songs.append(songs[row[1]])
            }
        }
        self.updatePlaylistDataModel()
        self.dismiss(animated: true, completion: nil)
    }
    
    
    /**
     Adds playlist object to core data
    */
    func updatePlaylistDataModel() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let data = PlaylistData(context: context)
        data.title = playlists[playlists.count-1].title as String
        var ids = [UInt64]()
        for song in playlists[playlists.count-1].songs {
            ids.append(song.persistentID)
        }
        data.songs = ids
        (UIApplication.shared.delegate as! AppDelegate).saveContext()

    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("SongCellView", owner: self, options: nil)?.first as! SongCellViewTableViewCell
        cell.songImage.image = songs[indexPath.row].artwork.image(at: CGSize(width: 50, height: 50))
        cell.topLabel.text = songs[indexPath.row].title
        cell.bottomLabel.text = songs[indexPath.row].artist
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

}
