//
//  File.swift
//  
//
//  Created by Mac13 on 2020/06/29.
//

import Foundation

public enum VDLangauge: Int {
    public init?(value:String) {
        switch value {
        case "en", "English":
            self.init(rawValue: VDLangauge.english.rawValue)
            break
            
        case "ja-Latn", "Romaji":
            self.init(rawValue: VDLangauge.romjai.rawValue)
            break
        
        case "ja", "Japanese":
            self.init(rawValue: VDLangauge.japanese.rawValue)
            break
            
        default:
            self.init(rawValue: VDLangauge.none.rawValue)
        }
    }
    
    case none
    case english
    case romjai
    case japanese
}

//
//= "en", "English"
//= "ja-Latn", "Romaji"
//= "ja", "Japanese"
