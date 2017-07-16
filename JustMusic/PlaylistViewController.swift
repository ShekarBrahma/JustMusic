//
//  PlaylistViewController.swift
//  JustMusic
//
//  Created by Shekar on 4/17/17.
//  Copyright © 2017 Shekar. All rights reserved.
//

import UIKit
import MediaPlayer
import SwiftyButton

/// Notification for updating songList
let playlistsNotification = Notification.init(name: Notification.Name(rawValue: "playlistsUpdated"))

/// Array of Playlist obects the user wants to keep track of
var playlists = [Playlist]() {
    didSet {
        notificationCenter.post(playlistsNotification)
    }
}


class PlaylistViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    /// Tableview in Playlist View
    @IBOutlet weak var playlistList: UITableView!
    
    /// Add button
    @IBOutlet weak var addButton: PressableButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playlistList.backgroundColor = #colorLiteral(red: 0.107675481, green: 0.1291435476, blue: 0.1935477475, alpha: 1)
        // Sends long gesture events to removePlaylist
        let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self,
            action: #selector(PlaylistViewController.removePlaylist(_:)))
        longPressGesture.minimumPressDuration = 1.0
        longPressGesture.delegate = self as? UIGestureRecognizerDelegate
        playlistList.addGestureRecognizer(longPressGesture)
        addButton.colors = .init(button: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1), shadow: #colorLiteral(red: 0.1019607857, green: 0.2784313858, blue: 0.400000006, alpha: 1))
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        notificationCenter.addObserver(self, selector: #selector(self.catchNotif), name: playlistsNotification.name, object: nil)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationCenter.removeObserver(self)
    }
    
    
    func catchNotif(_ n:Notification) {
        // Used to update view data
        playlistList.reloadData()
    }
    
    
    /**
     Allows the user to add new Playlist objects to playlists
    */
    @IBAction func addNewPlaylist(_ sender: Any) {
        let alertController = UIAlertController(title: "Add a Playlist", message: "Name for new playlist:", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            if let field = alertController.textFields?[0] {
                // Brings up selection view
                playlists.append(Playlist(title: field.text!, songs: [Song]()))
                let selectView = SelectViewController(nibName: "SelectView", bundle: nil)
                self.present(selectView, animated: true, completion: nil)
            }
        }
        alertController.addTextField { (textField) in
            // Name for new playlist
            textField.placeholder = ""
        }
        alertController.addAction(confirmAction)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    /**
     Allows the user to remove Playlist objects from playlists
     */
    func removePlaylist(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        // Prevents from being called multiple times in one long press
        if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = longPressGestureRecognizer.location(in: playlistList)
            if let indexPath = playlistList.indexPathForRow(at: touchPoint) {
                playlistList.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.top)
                var alertController = UIAlertController(title: "Remove Playlist", message: "", preferredStyle: .alert)
                let confirmAction = UIAlertAction(title: "Remove", style: .destructive) { (_) in
                    // Removes from local and core data
                    self.removeData(index: indexPath.row)
                    playlists.remove(at: indexPath.row)
                }
                if playlists[indexPath.row].title == "All Songs" {
                    alertController = UIAlertController(title: "Cannot delete this playlist", message: "", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "Ok", style: .cancel))
                } else {
                    alertController.addAction(confirmAction)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                }
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    /**
     Removes Playlist object from core data
     */
    func removeData(index: Int) {
        var dataArray: [PlaylistData] = []
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            dataArray = try context.fetch(PlaylistData.fetchRequest()) as! [PlaylistData]
            for item in dataArray {
                if item.title! == playlists[index].title {
                    context.delete(item)
                }
            }
        } catch {
            print("Failed: getData()")
        }
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playlists.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "PlaylistCell")
        cell.textLabel?.text = playlists[indexPath.row].title
        cell.textLabel?.textColor = UIColor.white
        cell.backgroundColor = #colorLiteral(red: 0.107675481, green: 0.1291435476, blue: 0.1935477475, alpha: 1)
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        songList = playlists[indexPath.row].songs
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}
