//
//  File.swift
//  
//
//  Created by Mac13 on 2020/06/29.
//

import Foundation

public struct VDAlbum {
    public init(id:Int, catalogNumber:String, albumTitle:String, date:String, mediaFormat:String) {
        self.id = id
        self.catalogNumber = catalogNumber
        self.albumTitle = albumTitle
        self.date = date
        self.mediaFormat = mediaFormat
    }
    
    public let id: Int
    public let catalogNumber: String
    public let albumTitle: String
    public let date: String
    public let mediaFormat: String   
}
