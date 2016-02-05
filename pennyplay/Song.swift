//
//  Song.swift
//  pennyplay
//
//  Created by grant on 05/02/2016.
//  Copyright © 2016 GK Micro. All rights reserved.
//

import Foundation

class Song {
    var id: Int
    var name: String
    var numLikes: Int
    var numPlays: Int
    var artist: String
    
    init? (id: String, name: String, numLikes: String, numPlays: String, artist: String) {
        self.id = Int(id)!
        self.name = name
        self.numLikes = Int(numLikes)!
        self.numPlays = Int(numPlays)!
        self.artist = artist
    }
    
    func getId () -> Int {
        return id
    }
    
    func getName () -> String {
        return name
    }
    
    func getNumLikes () -> Int {
        return numLikes
    }
    
    func getNumPlays () -> Int {
        return numPlays
    }
    
    func getArtist () -> String {
        return artist
    }
    
    func getCleanName () -> String {
        return name.stringByReplacingOccurrencesOfString(".mp3", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
    }
}