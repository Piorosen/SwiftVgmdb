//
//  File.swift
//  
//
//  Created by Mac13 on 2020/06/29.
//

import Foundation

// Title, DiscNum, Barcode, Composer, Artist, Publisher

public struct VDSearchAnnotation {
    public let title:String
    public let discNum = String()
    public let barcode = String()
    public let composer = [String]()
    public let artist = [String]()
    public let publisher = [String]()
}
