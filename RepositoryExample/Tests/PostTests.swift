//
//  PostTests.swift
//  DigiMeRepository_Tests
//
//  Created on 12/12/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

@testable import DigiMeSDK
import XCTest

class PostTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Setup code here
    }
    
    override func tearDown() {
        // Teardown code here
        super.tearDown()
    }
    
    func testDecodeSingle() {

    }
    
    func testFacebookPosts() {
        let data = """
[
]
""".data(using: .utf8)!
        do {
            let decoder = Post.decoder
            let posts = try decoder.decode([Post].self, from: data)
            XCTAssertNotNil(posts)
            XCTAssert(posts.count == 3, "Expected 3 Posts, got \(posts.count)")
        }
        catch {
            XCTFail("Unable to parse json to Facebook posts array: \(error)")
        }
    }
    
    func testInstagramPosts() {
        let data = """
[
]
""".data(using: .utf8)!
        do {
            let decoder = Post.decoder
            let posts = try decoder.decode([Post].self, from: data)
            XCTAssertNotNil(posts)
            XCTAssert(posts.count == 3, "Expected 3 Posts, got \(posts.count)")
        }
        catch {
            XCTFail("Unable to parse json to Instagram posts array: \(error)")
        }
    }
    
    func testFlickrPosts() {
        let data = """
[
]
""".data(using: .utf8)!
        do {
            let decoder = Post.decoder
            let posts = try decoder.decode([Post].self, from: data)
            XCTAssertNotNil(posts)
            XCTAssert(posts.count == 3, "Expected 3 Posts, got \(posts.count)")
        }
        catch {
            XCTFail("Unable to parse json to Flickr posts array: \(error)")
        }
    }
    
    func testTwitterPosts() {
        let data = """
[
]
""".data(using: .utf8)!
        do {
            let decoder = Post.decoder
            let posts = try decoder.decode([Post].self, from: data)
            XCTAssertNotNil(posts)
            XCTAssert(posts.count == 3, "Expected 3 Posts, got \(posts.count)")
        }
        catch {
            XCTFail("Unable to parse json to Twitter posts array: \(error)")
        }
    }
    
    func testPinterestPosts() {
        let data = """
[
]
""".data(using: .utf8)!
        do {
            let decoder = Post.decoder
            let posts = try decoder.decode([Post].self, from: data)
            XCTAssertNotNil(posts)
            XCTAssert(posts.count == 3, "Expected 3 Posts, got \(posts.count)")
        }
        catch {
            XCTFail("Unable to parse json to Pinterest posts array: \(error)")
        }
    }
}
