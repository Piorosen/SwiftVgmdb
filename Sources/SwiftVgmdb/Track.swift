//
//  File.swift
//  
//
//  Created by Mac13 on 2020/06/29.
//

import Foundation

public struct VDTrack {
    public init(albumInfo: [VDTrackInfo:String], trackInfo: [VDLangauge:[[String]]]) {
        self.albumInfo = albumInfo
        self.trackInfo = trackInfo
    }
    
    public let albumInfo:[VDTrackInfo:String]
    public let trackInfo:[VDLangauge:[[String]]]
}
