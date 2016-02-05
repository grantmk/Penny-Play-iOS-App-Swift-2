//
//  Player.swift
//  pennyplay
//
//  Created by grant on 03/02/2016.
//  Copyright © 2016 GK Micro. All rights reserved.
//

import Foundation
import MediaPlayer

class Player
{
    var avPlayer: AVPlayer!
    
    init () {
        avPlayer = AVPlayer()
    }
    
    func playStream (fileUrl: String) {
        if let url = NSURL(string: fileUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!) {
        
            avPlayer = AVPlayer(URL: url)
            avPlayer.play()
        
            setPlayingScreen(fileUrl)
        
            print("Playing stream")
        }
    }
    
    func playAudio () {
        if (avPlayer.rate == 0 && avPlayer.error == nil) {
            avPlayer.play()
        }
    }
    
    func pauseAudio () {
        if (avPlayer.rate > 0 && avPlayer.error == nil) {
            avPlayer.pause()
        }
    }
    
    func setPlayingScreen (fileUrl: String) {
        let urlArray = fileUrl.characters.split{$0 == "/"}.map(String.init)
        
        let name = urlArray[urlArray.endIndex-1]
        
        print(name)
        
        let songInfo = [
            MPMediaItemPropertyTitle: name,
            MPMediaItemPropertyArtist: "Penny Play"
        ]
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo
        
    }
    
    
}






