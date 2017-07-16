//
//  SongViewController.swift
//  JustMusic
//
//  Created by Shekar on 4/13/17.
//  Copyright © 2017 Shekar. All rights reserved.
//

import UIKit
import MediaPlayer


class SongViewController: UIViewController {
    
    /// Current playing song's title
    @IBOutlet weak var songTitle: UILabel!
    
    /// Current playing song's artist
    @IBOutlet weak var songArtist: UILabel!
    
    /// Move playlist to previous song
    @IBOutlet weak var prevButton: UIButton!
    
    /// Switch for playing music
    @IBOutlet weak var playPuaseButton: UIButton!
    
    /// Move playlist to next song
    @IBOutlet weak var nextButton: UIButton!
    
    /// System volume control
    @IBOutlet weak var volumeControl: UISlider!
    
    /// Repeat playlist
    @IBOutlet weak var repeatButton: UIButton!
    
    /// Shuffle playlist
    @IBOutlet weak var shuffleButton: UIButton!
    
    /// Image for background
    @IBOutlet weak var albumCoverImage: UIImageView!
    
    /// Adds gradient over ablum
    @IBOutlet weak var overlay: UIView!
    
    /// Player handling music output
    let player = MPMusicPlayerController.applicationMusicPlayer()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()
        songTitle.sizeToFit()
        songArtist.sizeToFit()
        // Adds a view off screen to prevent volume hub from showing
        let volumeView = MPVolumeView(frame: CGRect(x: 0, y: -50, width: 0, height: 0))
        self.view.addSubview(volumeView)
        // Adds notifications to be caught later
        player.beginGeneratingPlaybackNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // Updates labels and slider when app starts
        volumeControl.setValue(AVAudioSession.sharedInstance().outputVolume, animated: false)
        if MPMediaLibrary.authorizationStatus() == MPMediaLibraryAuthorizationStatus.authorized {
            if songList.count > 0 {
                songTitle.text = "   " + songList[0].title + "   "
                songArtist.text = "   " + songList[0].artist + "   "
            }
        }
        notificationCenter.addObserver(self, selector: #selector(self.changed),
            name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
        notificationCenter.addObserver(self, selector: #selector(systemVolumeDidChange),
            name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)
    }
    
    
    func setGradientBackground() {
        let colorTop =  UIColor(red: 71/255, green: 60/255, blue: 248/255, alpha: 0.2).cgColor
        let colorBottom = UIColor(red: 71/255, green: 60/255, blue: 248/255, alpha: 1.0).cgColor
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [ colorTop, colorBottom]
        gradientLayer.locations = [ 0.0, 1.0]
        gradientLayer.frame = self.view.frame
        self.overlay.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    
    /**
     This is called whenever the song changes
    */
    func changed(_ n:Notification) {
        let player = MPMusicPlayerController.applicationMusicPlayer()
        guard let obj = n.object, obj as AnyObject === player else { return }
        guard let title = player.nowPlayingItem?.title else {return}
        let artist = player.nowPlayingItem?.artist ?? ""
        let ix = player.indexOfNowPlayingItem
        guard ix != NSNotFound else {return}
        songTitle.text = "   " + title + "   "
        songArtist.text = "   " + artist + "   "
        albumCoverImage.image = player.nowPlayingItem?.artwork?.image(at: CGSize(width: self.view.frame.width, height: self.view.frame.height)) ?? UIImage(imageLiteralResourceName: "defaultBackground")
        playPuaseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notificationCenter.removeObserver(self)
    }
    
    
    /**
     Pauses currently playing song
     */
    @IBAction func playPauseSong(_ sender: Any) {
        if musicController.musicPlayer.playbackState == MPMusicPlaybackState.paused ||
            musicController.musicPlayer.indexOfNowPlayingItem == NSNotFound {
            musicController.musicPlayer.prepareToPlay()
            musicController.musicPlayer.play()
            playPuaseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        } else {
            musicController.pauseSong()
            playPuaseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
        }
    }
    
    
    /**
     Plays previous song in playlist when pressed
     */
    @IBAction func previousSong(_ sender: Any) {
        musicController.previousSong()
    }
    
    
    /**
     Plays next song in playlist when pressed
     */
    @IBAction func nextSong(_ sender: Any) {
        musicController.nextSong()
    }
    
    
    /**
     Updates system volume when updated
     */
    @IBAction func adjustVolume(_ sender: Any) {
        let volumeSlider = (MPVolumeView().subviews.filter { NSStringFromClass($0.classForCoder) == "MPVolumeSlider" }.first as! UISlider)
        volumeSlider.setValue((sender as AnyObject).value, animated: false)
    }
    
    
    /**
    Updates system volume when user presses device's volume buttons
    */
    func systemVolumeDidChange(notification: NSNotification) {
        volumeControl.setValue(notification.userInfo?["AVSystemController_AudioVolumeNotificationParameter"] as? Float ?? 0.0, animated: true)
    }
    

    @IBAction func shuffleSongs(_ sender: Any) {
        musicController.shuffleSongs()
    }
    
    
    @IBAction func repeatSong(_ sender: Any) {
        musicController.repeatSong()
        if musicController.repeatMode == true {
            repeatButton.tintColor = UIColor(red: 71/255, green: 60/255, blue: 200/255, alpha: 1.0)
        } else {
            repeatButton.tintColor = UIColor.white
        }
    }
    
}
