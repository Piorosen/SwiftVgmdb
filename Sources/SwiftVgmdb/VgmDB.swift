
import Foundation
import SwiftSoup

public class SwiftVgmDb {
    public init() {
        
    }
    
    func makeQuery(ack:VDSearchAnnotation) -> String {
        return "action=advancedsearch" +
            "&albumtitles=\(ack.title)" +
            "&catalognum=\(ack.discNum)" +
            "&eanupcjan=\(ack.barcode)" +
            "&dosearch=Search+Albums+Now&pubtype%5B0%5D=1&pubtype%5B1%5D=1&pubtype%5B2%5D=1&distype%5B0%5D=1&distype%5B1%5D=1&distype%5B2%5D=1&distype%5B3%5D=1&distype%5B4%5D=1&distype%5B5%5D=1&distype%5B6%5D=1&distype%5B7%5D=1&distype%5B8%5D=1&category%5B1%5D=0&category%5B2%5D=0&category%5B4%5D=0&category%5B8%5D=0&category%5B16%5D=0" +
            "&composer=\(ack.composer.joined(separator: "_"))" +
            "&arranger=\(String())" +
            "&performer=\(ack.artist.joined(separator: "_"))" +
            "&lyricist=\(String())" +
            "&publisher=\(ack.publisher.joined(separator: "_"))" +
            "&game=\(String())" +
            "&trackname=\(String())" +
            "&caption=\(String())" +
            "&notes=\(String())" +
            "&anyfield=\(String())" +
        "&classification%5B1%5D=0&classification%5B2%5D=0&classification%5B32%5D=0&classification%5B4%5D=0&classification%5B16%5D=0&classification%5B256%5D=0&classification%5B512%5D=0&classification%5B64%5D=0&classification%5B4096%5D=0&classification%5B8%5D=0&classification%5B128%5D=0&classification%5B1024%5D=0&classification%5B2048%5D=0&releasedatemodifier=is&day=0&month=0&year=0&discsmodifier=is&discs=&pricemodifier=is&price_value=&wishmodifier=0&sellmodifier=0&collectionmodifier=0&tracklistmodifier=is&tracklists=&scanmodifier=is&scans=&albumadded=&albumlastedit=&scanupload=&tracklistadded=&tracklistlastedit=&sortby=albumtitle&orderby=ASC&childmodifier=0"
    }
    
    func requestWeb(ack:VDSearchAnnotation, completeHandler: @escaping (String?) -> Void) -> Void {
        var req = URLRequest(url: URL(string: "https://vgmdb.net/search?do=results")!)
        req.httpMethod = "POST"
        req.httpBody = makeQuery(ack: ack).data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }
            
            let responseString = String(data: data, encoding: .utf8)
            
            completeHandler(responseString)
        }
        task.resume()
    }
    
    func getInfoTbody(web:Document) -> [VDTrackInfo:String] {
        var result = [VDTrackInfo:String]()
        
        guard let category = try? web.select("#rightcolumn > div:nth-child(2) > div > div:nth-child(4)").first() else {
            return result
        }
        
        result[VDTrackInfo.genre] = category.ownText().trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let tr = try? web.select("#album_infobit_large > tbody > tr") else {
            return result
        }
        
        for item in tr {
            guard let key = try? item.select("td:nth-child(1)").first() else {
                continue
            }
            guard let value = try? item.select("td:nth-child(2)").first() else {
                continue
            }
            
            guard let sKey = try? key.text().trimmingCharacters(in: .whitespacesAndNewlines) else {
                continue
            }
            guard let sValue = try? value.text().trimmingCharacters(in: .whitespacesAndNewlines) else {
                continue
            }
            
            result[VDTrackInfo(rawValue: sKey) ?? VDTrackInfo.none] = sValue
        }
        
        return result
    }
    
    func getDiscList(web:Document) -> [VDLangauge:[[String]]] {
        var result = [VDLangauge:[[String]]]()
        
        guard let langList = try? web.select("#tlnav > li").array() else {
            return result
        }
        
        guard let list = try? web.select("#tracklist > span").array() else {
            return result
        }
        
        if langList.count == list.count {
            for index in langList.indices {
                let key = VDLangauge(value: (try? langList[index].text()) ?? String())!
                
                guard let discs = try? list[index].select("table") else {
                    continue
                }
                
                var discsItem = [[String]]()
                
                for disc in discs {
                    guard let ss = try? disc.select("tbody > tr.rolebit > td:nth-child(2)") else {
                        continue
                    }
                    var discItem = [String]()
                    for discElement in ss {
                        if let text = try? discElement.text() {
                            discItem.append(text.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
                    }
                    discsItem.append(discItem)
                }
                
                result[key] = discsItem
            }
        }
        
        return result
    }
    
    
    public func getAlbumList(ack:VDSearchAnnotation, completeHanlder: @escaping ([VDAlbum]) -> Void) {
        requestWeb(ack: ack) { data in
            var result = [VDAlbum]()
            
            if let data = data {
                let doc = try? SwiftSoup.parse(data)
                if let table = try? doc!.select("body > div:nth-child(5) > table:nth-child(3) > tbody > tr > td > table > tbody > tr") {
                    
                    for item in table.array() {
                        let catalogHtml = try? item.select("td:nth-child(1) > span").first()
                        let titleHtml = try? item.select("td:nth-child(3) > a > span:nth-child(1)").first()
                        let idHtml = try? item.select("td:nth-child(3) > a").first()
                        
                        let dateHtml = try? item.select("td:nth-child(4) > a").first()
                        let formatHtml = try? item.select("td:nth-child(5)").first()
                        
                        if let catalogHtml = catalogHtml, let titleHtml = titleHtml, let dateHtml = dateHtml, let formatHtml = formatHtml, let idHtml = idHtml, let id = try? idHtml.attr("href") {
                            
                            let id = Int(id.split(separator: "/").last!) ?? -1
                            let catalog = catalogHtml.ownText()
                            let title = titleHtml.ownText()
                            let date = dateHtml.ownText()
                            let media = formatHtml.ownText()
                            
                            result.append(
                                VDAlbum(id: id, catalogNumber: catalog, albumTitle: title, date: date, mediaFormat: media))
                        }
                    }
                }
            }
            
            completeHanlder(result)
        }
    }
    
    public func getTrackList(id:Int, completeHandler: @escaping (VDTrack) -> Void) {
        let result = [VDTrack]()
        let req = URLRequest(url: URL(string: "https://vgmdb.net/album/\(id)")!)
        
        let task = URLSession.shared.dataTask(with: req) { data, response, error in
            guard let data = data,
//                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    return
            }
            
            guard let str = String(data: data, encoding: .utf8) else {
                return
            }
            
            guard let doc = try? SwiftSoup.parse(str) else {
                return
            }
            
            let p = self.getInfoTbody(web: doc)
            let r = self.getDiscList(web: doc)
            let track = VDTrack(albumInfo: p, trackInfo: r)
            
            completeHandler(track)
        }
        task.resume()
        
        return result
    }
}
