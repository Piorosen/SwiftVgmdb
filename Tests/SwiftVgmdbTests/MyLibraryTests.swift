import XCTest
@testable import SwiftVgmdb

final class MyLibraryTests: XCTestCase {
    func testGetAlbumList() {
        let exception = expectation(description: "receive Test")
        let run = SwiftVgmDb()
        run.getAlbumList(ack: VDSearchAnnotation(title: "myth")) { db in
            for item in db {
                print("\(item.id) : \(item.catalogNumber) : \(item.albumTitle) : \(item.date) : \(item.mediaFormat)")
            }
            exception.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testGetTrackList() {
        let exception = expectation(description: "receive Test")
        let run = SwiftVgmDb()
        run.getTrackList(id: 100670) { db in
            print(db)
        }
        
        run.getTrackList(id: 72868) { db in
            guard let list = db.trackInfo[.english] else {
                XCTFail()
                return
            }
            exception.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }

    static var allTests = [
        ("testExample", testGetAlbumList),
        ("testGetTrackList", testGetTrackList),
    ]
}
