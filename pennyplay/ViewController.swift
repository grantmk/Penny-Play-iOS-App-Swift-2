//
//  ViewController.swift
//  pennyplay
//
//  Created by grant on 03/02/2016.
//  Copyright © 2016 GK Micro. All rights reserved.
//

import UIKit
import MediaPlayer
import Social
import Accounts

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var nowPlayingLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playPauseButton: UIButton!
    var player: Player!
    var songs: [Song] = []
    var currentId: Int!
    var currentSong: Song!

    @IBAction func likeButtonClicked(sender: UIButton) {
        if let id = currentId {
            likeSong(id)
        }
    }
    
    @IBAction func facebookButtonClicked(sender: UIButton) {
        shareFacebook()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setSession()
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        becomeFirstResponder()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleInterruption", name: AVAudioSessionInterruptionNotification, object: nil)
        
        player = Player()
        tableView.delegate = self
        tableView.dataSource = self
        retrieveSongs()
    }
    
    //delegate and source for tableview
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SongsTableViewCell", forIndexPath: indexPath) as! SongsTableViewCell
        
        cell.mainLabel.text = songs[indexPath.row].getCleanName()
        cell.artistLabel.text = songs[indexPath.row].getArtist()
        
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        player.playStream("https://www.learnappdevelopment.com/music_app/" + songs[indexPath.row].getArtist() + " - " + songs[indexPath.row].getName())
        changePlayButton()
        nowPlayingLabel.text = songs[indexPath.row].getCleanName()
        songPlayed(songs[indexPath.row].getId())
        currentId = songs[indexPath.row].getId()
        currentSong = songs[indexPath.row]
    }
    //END
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    func setSession () {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch {
            print(error)
        }
    }

    @IBAction func playPauseButtonClick(sender: AnyObject) {
        if (player.avPlayer.rate > 0) {
            player.pauseAudio()
        }
        else {
            player.playAudio()
        }
        changePlayButton()
    }
    
    func changePlayButton () {
        if(player.avPlayer.rate > 0) {
            playPauseButton.setImage(UIImage(named: "pauseIcon"), forState: UIControlState.Normal)
        }
        else {
            playPauseButton.setImage(UIImage(named: "playIcon"), forState: UIControlState.Normal)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if event!.type == UIEventType.RemoteControl {
            if event!.subtype == UIEventSubtype.RemoteControlPause{
                print("pause")
                player.pauseAudio()
            }
            else if event!.subtype == UIEventSubtype.RemoteControlPlay{
                print("playing")
                player.playAudio()
            }
        }
    }
    
    func handleInterruption(notification: NSNotification) {
        player.pauseAudio()
        
        let interruptionTypeAsObject = notification.userInfo![AVAudioSessionInterruptionTypeKey] as! NSNumber
        
        let interruptionType = AVAudioSessionInterruptionType(rawValue: interruptionTypeAsObject.unsignedLongValue)
        
        if let type = interruptionType {
            if type == .Ended {
                player.playAudio()
            }
        }
    }
    
    func retrieveSongs () {
        let url = NSURL(string: "https://learnappdevelopment.com/music_app/getmusic.php")
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            let retrievedList = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(retrievedList)
            self.parseSongs(retrievedList!)
        }
        
        task.resume()
        print("Getting songs")
    }
    
    func songPlayed (id: Int) {
        let url = NSURL(string: "https://learnappdevelopment.com/music_app/add_play.php?id=" + String(id))
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            let retrievedData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(retrievedData)
        }
        
        task.resume()
        print("Playing song")
    }
    
    func likeSong (id: Int) {
        let url = NSURL(string: "https://learnappdevelopment.com/music_app/like_song.php?id=" + String(id))
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) {(data, response, error) in
            let retrievedData = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(retrievedData)
        }
        
        task.resume()
        print("Liking song")
    }
    
    func parseSongs (data: NSString) {
        if (data.containsString("*")) {
            let dataArray = (data as String).characters.split{$0 == "*"}.map(String.init)
            for item in dataArray {
                let itemData = item.characters.split {$0 == ","}.map(String.init)
                let newSong = Song(id: itemData[0], name: itemData[1], numLikes: itemData[2], numPlays: itemData[3], artist: itemData[4])
                songs.append(newSong!)
            }
            for s in songs {
                print (s.getName())
            }
            dispatch_async(dispatch_get_main_queue()) { [unowned self] in
                self.tableView.reloadData()
            }
        }
    }
    
    func shareFacebook () {
        if let song = currentSong {
            let vc = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            vc.setInitialText("Listening to: " + song.getName() + " by " + song.getArtist() + ". Penny Play App")
            vc.addURL(NSURL(string: "https://www.learnappdevelopment.com"))
            presentViewController(vc, animated: true, completion: nil)
        }
    }
}












