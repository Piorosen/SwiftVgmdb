//
//  File.swift
//  
//
//  Created by Mac13 on 2020/06/29.
//

import Foundation

// Title, DiscNum, Barcode, Composer, Artist, Publisher

public struct VDSearchAnnotation {
    public init(title:String,
                discNum:String = String(),
                barcode:String = String(),
                composer:[String] = [String](),
                artist:[String] = [String](),
                publisher:[String] = [String]()) {
        self.title = title
        self.discNum = discNum
        self.barcode = barcode
        self.composer = composer
        self.artist = artist
        self.publisher = publisher
    }
    
    public let title:String
    public let discNum:String
    public let barcode:String
    public let composer:[String]
    public let artist:[String]
    public let publisher:[String]
}
