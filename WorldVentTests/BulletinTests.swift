//
//  BulletinTests.swift
//  BulletinTests
//
//  Created by Tim Ekl on 4/19/20.
//  Copyright © 2020 Tim Ekl. All rights reserved.
//

import XCTest

@testable import WorldVent

class BulletinTests: XCTestCase {
    
    private var temporaryCacheURL: URL {
        return FileManager.default.temporaryDirectory
    }
    
    private var bulletinIndexCacheURL: URL {
        return temporaryCacheURL.appendingPathComponent("bulletins").appendingPathComponent("index").appendingPathExtension("json")
    }
    
    private var bulletinIndexServerURL: URL {
        return URL(string: "https://example.com/index.json")!
    }
    
    private var bulletinContentsURL: URL {
        return URL(string: "https://example.com/index.html")!
    }
    
    private var bulletinManager: BulletinManager!

    // MARK: Bulletin URL proxy accessors
    
    func testCacheBulletinURLs() throws {
        let metadata = Bulletin.Metadata(url: bulletinContentsURL, published: Date())
        let bulletin = Bulletin(metadata: metadata, source: .cache(bulletinIndexCacheURL))
        
        XCTAssertEqual(bulletinIndexCacheURL, bulletin.sourceURL)
        XCTAssertEqual(bulletinContentsURL, bulletin.contentsURL)
    }
    
    func testServerBulletinURLs() throws {
        let metadata = Bulletin.Metadata(url: bulletinContentsURL, published: Date())
        let bulletin = Bulletin(metadata: metadata, source: .server(bulletinIndexServerURL))
        
        XCTAssertEqual(bulletinIndexServerURL, bulletin.sourceURL)
        XCTAssertEqual(bulletinContentsURL, bulletin.contentsURL)
    }
    
    // MARK: Bulletin manager cache
    
    func testBulletinManagerLoadsCache() throws {
        let manager = BulletinManager(cacheURL: temporaryCacheURL)
        let bulletinChangeExpectation = self.expectation(forNotification: BulletinManager.bulletinDidChangeNotification, object: manager, handler: nil)
        
        try manager.loadCachedBulletin()
        wait(for: [bulletinChangeExpectation], timeout: 1)
        
        let latest = manager.latestBulletin
        XCTAssertEqual(bulletinIndexCacheURL, latest?.sourceURL)
        // cannot assert about contents URL, since it won't be on a server like we expect
    }

}
