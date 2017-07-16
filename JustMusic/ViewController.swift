//
//  ViewController.swift
//  JustMusic
//
//  Created by Shekar on 4/5/17.
//  Copyright © 2017 Shekar. All rights reserved.
//

import UIKit
import MediaPlayer

/// Broadcasts notifications when an event occurs
let notificationCenter = NotificationCenter.default


class ViewController: UIViewController, UIScrollViewDelegate {
    
    /// Scroll view to allow moving between main views
    @IBOutlet weak var scrollView: UIScrollView!
    
    /// Allows view that takes up most of the screen when swiping to be centered
    @IBOutlet weak var pageControl: UIPageControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.isHidden = true
        addViews()
        addPaging()
        var frame: CGRect = scrollView.frame
        frame.origin.x = frame.size.width
        frame.origin.y = 0
        scrollView.scrollRectToVisible(frame, animated: false)
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    /**
     Adds the seperate main views to the overall scroll view
     */
    func addViews() {
        let playlistView = PlaylistViewController(nibName: "PlaylistView", bundle: nil)
        self.addChildViewController(playlistView)
        self.scrollView.addSubview(playlistView.view)
        playlistView.didMove(toParentViewController: self)
        
        let libraryView = LibraryViewController(nibName: "LibraryView", bundle: nil)
        self.addChildViewController(libraryView)
        self.scrollView.addSubview(libraryView.view)
        libraryView.didMove(toParentViewController: self)
        
        let songView = SongViewController(nibName: "SongView", bundle: nil)
        self.addChildViewController(songView)
        self.scrollView.addSubview(songView.view)
        songView.didMove(toParentViewController: self)
        
        var playlistViewFrame = playlistView.view.frame
        playlistViewFrame.origin.y = 20
        playlistViewFrame.size.height = self.view.frame.height
        playlistView.view.frame = playlistViewFrame
        
        var libraryViewFrame = libraryView.view.frame
        libraryViewFrame.origin.x = self.view.frame.width
        libraryViewFrame.origin.y = 20
        libraryViewFrame.size.height = self.view.frame.height - 20
        libraryView.view.frame = libraryViewFrame
        
        var songViewFrame = songView.view.frame
        songViewFrame.origin.x = self.view.frame.width*2
        songView.view.frame = songViewFrame
        
        scrollView.contentSize = CGSize(width: self.view.frame.width*3, height: self.view.frame.height - 20)
    }
    
    
    /**
     Tells the page control how many pages to account for
    */
    func addPaging() {
        scrollView.isPagingEnabled = true
        pageControl.numberOfPages = 3
        pageControl.currentPage = 1
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // allows page contol's centering properties to kick in
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
    }

}

