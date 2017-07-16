//
//  LibraryViewController.swift
//  JustMusic
//
//  Created by Shekar on 4/13/17.
//  Copyright © 2017 Shekar. All rights reserved.
//

import UIKit
import MediaPlayer
import SCLAlertView


/// Notification for updating songList
let songListNotification = Notification.init(name: Notification.Name(rawValue: "songListUpdated"))

/// List of Song objects in library currently
var songList = [Song]() {
    didSet {
        notificationCenter.post(songListNotification)
    }
}

/// Controller for handling music data
var musicController = MusicController()


class LibraryViewController: UITableViewController {
    
    /// Flag to determine if library has been loaded
    var musicDataHasBeenLoaded = false
    
    /// Used to store fetched core data
    var dataArray : [PlaylistData] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Setups library while view is being setup if authorization is already given
        if MPMediaLibrary.authorizationStatus() == MPMediaLibraryAuthorizationStatus.authorized {
            loadMusicData()
            getData()
            for item in dataArray {
                playlists.append(Playlist(title: item.title!, songs: musicController.convertIdsToSongs(ids: item.songs!)))
            }
        }
        self.tableView.estimatedSectionHeaderHeight = 50
        // catch songList notification and update tableview
        notificationCenter.addObserver(self, selector: #selector(self.catchNotif), name: songListNotification.name, object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        handlePermissions()
        if(UserDefaults.standard.bool(forKey: "SeenTutorial")) {
            // don't need to display tutorial
        } else {
            // user's first time using the app
            displayTutorial()
        }
    }
    
    
    func displayTutorial() {
        print("first time")
        let appearance = SCLAlertView.SCLAppearance(
            kTitleFont: UIFont(name: "HelveticaNeue", size: 20)!,
            kTextFont: UIFont(name: "HelveticaNeue", size: 14)!,
            kButtonFont: UIFont(name: "HelveticaNeue-Bold", size: 14)!,
            showCloseButton: false
        )
        
        let alertView = SCLAlertView(appearance: appearance)
        alertView.addButton("Start") {
            UserDefaults.standard.set(true, forKey: "SeenTutorial")
            UserDefaults.standard.synchronize()
        }
        alertView.showSuccess("Thanks!", subTitle: "Welcome to JustMusic! Here's a quick tutorial.\n\n1. This main menu here will list all the songs you want to listen to.\n\n2. Swipe left view the playlists menu, and create your own playlists by pressing the \"+\" button.\n\n3. Swipe right to get to the song view. You can control the volume, shuffle mode, skipping to the next song, etc.\n\nEnjoy! Press \"Start\" to begin.")
    }
    
    
    /**
     Fetches core data entity
    */
    func getData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            dataArray = try context.fetch(PlaylistData.fetchRequest()) as! [PlaylistData]
        } catch {
            print("Failed: getData()")
        }
    }
    
    
    /**
     Used to update view
    */
    func catchNotif(_ n:Notification) {
        self.tableView.reloadData()
    }
    
    
    /**
     Handles all states of user's music permissions for application
     */
    func handlePermissions() {
        let permissionStatus = MPMediaLibrary.authorizationStatus()
        switch (permissionStatus) {
        case MPMediaLibraryAuthorizationStatus.authorized:
            print("permission status is authorized")
            if !musicDataHasBeenLoaded {
                loadMusicData()
            }
        case MPMediaLibraryAuthorizationStatus.notDetermined:
            print("permission status is not determined")
            MPMediaLibrary.requestAuthorization() { status in
                if status == .authorized {
                    sleep(1)
                    DispatchQueue.main.async(){
                        self.loadMusicData()
                    }
                } else if status == .denied {
                    self.askForPermission()
                }
            }
        case MPMediaLibraryAuthorizationStatus.denied:
            print("permission status is denied")
            askForPermission()
        case MPMediaLibraryAuthorizationStatus.restricted:
            print("permission status is restricted")
            exit(0)
        }
    }
    
    
    /**
     Creates an alert asking user to allow access
     */
    func askForPermission() {
        let alert = UIAlertController(title: "Need Authoriation",
            message: "Would you like to authoize this app to use your Music Library?",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (UIAlertAction) in
            exit(0)
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.open(url)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /**
     Initializes music data
     */
    func loadMusicData() {
        musicDataHasBeenLoaded = true
        musicController.setupLibrary()
        songList = musicController.getAllSongs()
        playlists.append(Playlist(title: "All Songs", songs: musicController.getAllSongs()))
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("SongCellView", owner: self, options: nil)?.first as! SongCellViewTableViewCell
        cell.songImage.image = songList[indexPath.row].artwork.image(at: CGSize(width: 50, height: 50))
        cell.topLabel.text = songList[indexPath.row].title
        cell.bottomLabel.text = songList[indexPath.row].artist
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        musicController.playSong(index: indexPath.row, songList: songList)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed("SongHeaderView", owner: self, options: nil)?.first as! UIView
        return header
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}

