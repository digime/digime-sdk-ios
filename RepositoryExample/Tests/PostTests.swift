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
        let json =
            [
                "accountentityid": "1_1078609952155745",
                "annotation": "",
                "baseid": "1_1078609952155745_1078609952155745_1340776709272400",
                "commentcount": 0,
                "createddate": 1466608004000,
                "entityid": "1_1078609952155745_1078609952155745_1340776709272400",
                "favouritecount": 0,
                "iscommentable": 1,
                "isfavourited": 0,
                "islikeable": 1,
                "islikes": 0,
                "isshared": 0,
                "istruncated": 0,
                "latitude": 60.154503892316,
                "likecount": 19,
                "links": [
                    [
                        "link": "https://www.facebook.com/photo.php?fbid=1340775022605902&set=a.983362118347196&type=3",
                        "resources": [
                            [
                                "aspectratio": [
                                    "accuracy": 100,
                                    "actual": "1:1",
                                    "closest": "1:1"
                                ],
                                "height": 130,
                                "mimetype": "image/jpeg",
                                "resize": "fit",
                                "type": 0,
                                "url": "https://scontent.xx.fbcdn.net/v/t1.0-0/s130x130/13466116_1340775022605902_3254810757056494137_n.jpg?_nc_cat=108&_nc_ht=scontent.xx&oh=84e7dfa4237ea0cfeed821a9fba9d857&oe=5C639C12",
                                "width": 130
                            ]
                        ],
                        "title": "Photos from Alex Hamilton's post"
                    ]
                ],
                "longitude": 24.92077526015,
                "originalcrosspostid": "",
                "originalpostid": "",
                "originalposturl": "https://www.facebook.com/1078609952155745/posts/1340776709272400",
                "personentityid": "1_1078609952155745_1078609952155745",
                "personfilerelativepath": "",
                "personfileurl": "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773880&hash=AeQzkj3ZHd_DwOFN",
                "personfullname": "Alex Hamilton",
                "personusername": "Alex Hamilton",
                "postentityid": "",
                "postid": "1078609952155745_1340776709272400",
                "postreplycount": "",
                "posturl": "https://www.facebook.com/1078609952155745/posts/1340776709272400",
                "rawtext": "",
                "referenceentityid": "1_1078609952155745_1078609952155745_1340776709272400",
                "referenceentitytype": 15,
                "sharecount": 0,
                "socialnetworkuserentityid": "1_1078609952155745",
                "source": "",
                "text": "",
                "title": "Photos from Alex Hamilton's post",
                "type": 1,
                "updateddate": 1466608004000,
                "visibility": ""
                ] as [String: Any]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = Post.decoder
            let post = try decoder.decode(Post.self, from: data)
            
            var expectedDate = Date(timeIntervalSince1970: 1466608004000 / 1000)
            XCTAssert(post.createdDate == expectedDate, "Expected 'createdDate': \(expectedDate) got \(post.createdDate)")
            expectedDate = Date(timeIntervalSince1970: 1466608004000 / 1000)
            XCTAssert(post.updatedDate == expectedDate, "Expected 'updatedDate': \(expectedDate) got \(post.updatedDate)")
            
            XCTAssert(post.accountIdentifier == "1_1078609952155745", "Expected 'accountentityid': '1_1078609952155745, got \(post.accountIdentifier)")
            XCTAssert(post.baseIdentifier == "1_1078609952155745_1078609952155745_1340776709272400", "Expected 'baseid': '1_1078609952155745_1078609952155745_1340776709272400', got \(post.baseIdentifier)")
            XCTAssert(post.identifier == "1_1078609952155745_1078609952155745_1340776709272400", "Expected 'entityid': '1_1078609952155745_1078609952155745_1340776709272400', got \(post.identifier)")
            XCTAssert(post.originalPostUrl == "https://www.facebook.com/1078609952155745/posts/1340776709272400", "Expected 'originalposturl': 'https://www.facebook.com/1078609952155745/posts/1340776709272400', got \(post.originalPostUrl)")
            XCTAssert(post.personIdentifier == "1_1078609952155745_1078609952155745", "Expected 'personentityid': '1_1078609952155745_1078609952155745', got \(post.personIdentifier)")
            XCTAssert(post.personFileUrl == "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773880&hash=AeQzkj3ZHd_DwOFN", "Expected 'personfileurl': 'https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773880&hash=AeQzkj3ZHd_DwOFN', got \(post.personFileUrl)")
            XCTAssert(post.personFullname == "Alex Hamilton", "Expected 'personfullname': 'Alex Hamilton', got \(post.personFullname)")
            XCTAssert(post.personUsername == "Alex Hamilton", "Expected 'personusername': 'Alex Hamilton', got \(post.personUsername)")
            XCTAssert(post.postIdentifier == "1078609952155745_1340776709272400", "Expected 'postid': '1078609952155745_1340776709272400', got \(post.postIdentifier)")
            XCTAssert(post.postUrl == "https://www.facebook.com/1078609952155745/posts/1340776709272400", "Expected 'posturl': 'https://www.facebook.com/1078609952155745/posts/1340776709272400', got \(post.postUrl)")
            XCTAssert(post.referenceIdentifier == "1_1078609952155745_1078609952155745_1340776709272400", "Expected 'referenceentityid': '1_1078609952155745_1078609952155745_1340776709272400', got \(post.referenceIdentifier)")
            XCTAssert(post.accountIdentifier == "1_1078609952155745", "Expected 'socialnetworkuserentityid': '1_1078609952155745', got \(post.accountIdentifier)")
            XCTAssert(post.title == "Photos from Alex Hamilton's post", "Expected 'title': 'Photos from Alex Hamilton's post', got \(post.title)")
            XCTAssert(post.type.rawValue == 1, "Expected 'type': '1', got \(post.type)")
            XCTAssert(post.commentCount == 0, "Expected 'commentcount': '0', got \(post.commentCount)")
            XCTAssert(post.referenceEntityType == 15, "Expected 'referenceentitytype': '15', got \(post.referenceEntityType)")
            XCTAssert(post.shareCount == 0, "Expected 'sharecount': '0', got \(post.shareCount)")
            XCTAssert(post.favouriteCount == 0, "Expected 'favouritecount': '0', got \(post.favouriteCount)")
            XCTAssert(post.isCommentable == true, "Expected 'iscommentable': '1', got \(post.isCommentable)")
            XCTAssert(post.isFavourited == false, "Expected 'isfavourited': '0', got \(post.isFavourited)")
            XCTAssert(post.isLikeable == true, "Expected 'islikeable': '1', got \(post.isLikeable)")
            XCTAssert(post.isLikes == false, "Expected 'islikes': '0', got \(post.isLikes)")
            XCTAssert(post.isShared == false, "Expected 'isshared': '0', got \(post.isShared)")
            XCTAssert(post.isTruncated == false, "Expected 'istruncated': '0', got \(post.isTruncated)")
            XCTAssert(post.latitude == 60.154503892316, "Expected 'latitude': '60.154503892316', got \(post.latitude)")
            XCTAssert(post.likeCount == 19, "Expected 'likecount': '19', got \(post.likeCount)")
            XCTAssert(post.longitude == 24.92077526015, "Expected 'longitude': '24.92077526015', got \(post.longitude)")
            
            // optionals
            if let optionalLinks = post.links {
                XCTAssert(optionalLinks.count == 1, "Expected 'links' count '1', got \(optionalLinks.count)")
            }
            if let optionalAnnotation = post.annotation {
                XCTAssertNotNil(optionalAnnotation)
            }
            if let optionalVisibility = post.visibility {
                XCTAssertNotNil(optionalVisibility)
            }
            if let optionalSource = post.source {
                XCTAssertNotNil(optionalSource)
            }
            if let optionalText = post.text {
                XCTAssertNotNil(optionalText)
            }
            if let optionalRawText = post.rawText {
                XCTAssertNotNil(optionalRawText)
            }
            if let optionalPostReplyCount = post.postReplyCount {
                XCTAssertNotNil(optionalPostReplyCount)
            }
            if let optionalPostEntityIdentifier = post.postEntityIdentifier {
                XCTAssertNotNil(optionalPostEntityIdentifier)
            }
            if let optionalOriginalCrossPostIdentifier = post.originalCrossPostIdentifier {
                XCTAssertNotNil(optionalOriginalCrossPostIdentifier)
            }
            if let optionalOriginalPostIdentifier = post.originalPostIdentifier {
                XCTAssertNotNil(optionalOriginalPostIdentifier)
            }
            if let optionalPersonFileRelativePath = post.personFileRelativePath {
                XCTAssertNotNil(optionalPersonFileRelativePath)
            }
        }
        catch {
            XCTFail("Unable to parse json Post: \(error)")
        }
    }

    func testFacebookPosts() {
        let data = """
[
{
    "accountentityid": "1_1078609952155745",
    "annotation": "",
    "baseid": "1_1078609952155745_1078609952155745_1422347557781981",
    "commentcount": 0,
    "createddate": 1475075295000,
    "entityid": "1_1078609952155745_1078609952155745_1422347557781981",
    "favouritecount": 0,
    "iscommentable": 1,
    "isfavourited": 0,
    "islikeable": 1,
    "islikes": 0,
    "isshared": 0,
    "istruncated": 0,
    "latitude": 0,
    "likecount": 2,
    "links": [
        {
            "description": "Banks charge a lot for overseas transfers. We don't. Transfer money abroad easily and quickly with our low cost money transfers.",
            "link": "https://transferwise.com/u/6888f",
            "resources": [
                {
                    "aspectratio": {
                        "accuracy": 100,
                        "actual": "1:1",
                        "closest": "1:1"
                    },
                    "height": 130,
                    "mimetype": "application/x-httpd-php",
                    "resize": "fit",
                    "type": 0,
                    "url": "https://external.xx.fbcdn.net/safe_image.php?d=AQD1YUns6c-8ZXjJ&w=130&h=130&url=https%3A%2F%2Ftransferwise.com%2Fimages%2Ffb-og-logo-flag.png&cfs=1&_nc_hash=AQBQMnEA3419-wmR",
                    "width": 130
                }
            ],
            "subtitle": "transferwise.com",
            "title": "Transfer Money Online | Send Money Abroad with TransferWise"
        }
    ],
    "longitude": 0,
    "originalcrosspostid": "",
    "originalpostid": "",
    "originalposturl": "https://www.facebook.com/1078609952155745/posts/1422347557781981",
    "personentityid": "1_1078609952155745_1078609952155745",
    "personfilerelativepath": "",
    "personfileurl": "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773880&hash=AeQzkj3ZHd_DwOFN",
    "personfullname": "Alex Hamilton",
    "personusername": "Alex Hamilton",
    "postentityid": "",
    "postid": "1078609952155745_1422347557781981",
    "postreplycount": "",
    "posturl": "https://www.facebook.com/1078609952155745/posts/1422347557781981",
    "rawtext": "I really like this service!",
    "referenceentityid": "1_1078609952155745_1078609952155745_1422347557781981",
    "referenceentitytype": 15,
    "sharecount": 0,
    "socialnetworkuserentityid": "1_1078609952155745",
    "source": "TransferWise",
    "text": "I really like this service!",
    "title": "Transfer Money Online | Send Money Abroad with TransferWise",
    "type": 1,
    "updateddate": 1475075295000,
    "visibility": ""
},
{
    "accountentityid": "1_1078609952155745",
    "annotation": "",
    "baseid": "1_1078609952155745_1078609952155745_1416039165079487",
    "commentcount": 0,
    "createddate": 1474495181000,
    "entityid": "1_1078609952155745_1078609952155745_1416039165079487",
    "favouritecount": 0,
    "iscommentable": 1,
    "isfavourited": 0,
    "islikeable": 1,
    "islikes": 0,
    "isshared": 0,
    "istruncated": 0,
    "latitude": 53.385037873267,
    "likecount": 8,
    "links": [
        {
            "link": "https://www.facebook.com/photo.php?fbid=1416037835079620&set=a.750155571667853&type=3",
            "resources": [
                {
                    "aspectratio": {
                        "accuracy": 100,
                        "actual": "1:1",
                        "closest": "1:1"
                    },
                    "height": 130,
                    "mimetype": "image/jpeg",
                    "resize": "fit",
                    "type": 0,
                    "url": "https://scontent.xx.fbcdn.net/v/t1.0-0/s130x130/14370066_1416037835079620_3315577128360904375_n.jpg?_nc_cat=105&_nc_ht=scontent.xx&oh=a4e4e4e973cdcfe477ea3ad7e2bce5f9&oe=5C9C6091",
                    "width": 130
                }
            ]
        }
    ],
    "longitude": -1.4482393549017,
    "originalcrosspostid": "",
    "originalpostid": "",
    "originalposturl": "https://www.facebook.com/1078609952155745/posts/1416039165079487",
    "personentityid": "1_1078609952155745_1078609952155745",
    "personfilerelativepath": "",
    "personfileurl": "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773880&hash=AeQzkj3ZHd_DwOFN",
    "personfullname": "Alex Hamilton",
    "personusername": "Alex Hamilton",
    "postentityid": "",
    "postid": "1078609952155745_1416039165079487",
    "postreplycount": "",
    "posturl": "https://www.facebook.com/1078609952155745/posts/1416039165079487",
    "rawtext": "Achallader. Scotland. 13 photos stitched panorama. Low. res. image.",
    "referenceentityid": "1_1078609952155745_1078609952155745_1416039165079487",
    "referenceentitytype": 15,
    "sharecount": 0,
    "socialnetworkuserentityid": "1_1078609952155745",
    "source": "",
    "text": "Achallader. Scotland. 13 photos stitched panorama. Low. res. image.",
    "title": "",
    "type": 1,
    "updateddate": 1474495181000,
    "visibility": ""
},
{
    "accountentityid": "1_1078609952155745",
    "annotation": "",
    "baseid": "1_1078609952155745_1078609952155745_1416032851746785",
    "commentcount": 1,
    "createddate": 1474494437000,
    "entityid": "1_1078609952155745_1078609952155745_1416032851746785",
    "favouritecount": 0,
    "iscommentable": 1,
    "isfavourited": 0,
    "islikeable": 1,
    "islikes": 0,
    "isshared": 0,
    "istruncated": 0,
    "latitude": 56.796698323266,
    "likecount": 9,
    "links": [
        {
            "link": "https://www.facebook.com/photo.php?fbid=1416030955080308&set=a.750155571667853&type=3",
            "resources": [
                {
                    "aspectratio": {
                        "accuracy": 64.61538461538461,
                        "actual": "42:65",
                        "closest": "1:1"
                    },
                    "height": 130,
                    "mimetype": "image/jpeg",
                    "resize": "fit",
                    "type": 0,
                    "url": "https://scontent.xx.fbcdn.net/v/t1.0-0/q84/s130x130/14344233_1416030955080308_5639116713383824619_n.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=d93c225b9747d4302605dd223d783014&oe=5C9A1BAF",
                    "width": 84
                }
            ]
        }
    ],
    "longitude": -5.0038782032918,
    "originalcrosspostid": "",
    "originalpostid": "",
    "originalposturl": "https://www.facebook.com/1078609952155745/posts/1416032851746785",
    "personentityid": "1_1078609952155745_1078609952155745",
    "personfilerelativepath": "",
    "personfileurl": "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773880&hash=AeQzkj3ZHd_DwOFN",
    "personfullname": "Alex Hamilton",
    "personusername": "Alex Hamilton",
    "postentityid": "",
    "postid": "1078609952155745_1416032851746785",
    "postreplycount": "",
    "posturl": "https://www.facebook.com/1078609952155745/posts/1416032851746785",
    "rawtext": "Highland Scotland. 17 photos stitched panorama low res image.",
    "referenceentityid": "1_1078609952155745_1078609952155745_1416032851746785",
    "referenceentitytype": 15,
    "sharecount": 0,
    "socialnetworkuserentityid": "1_1078609952155745",
    "source": "",
    "text": "Highland Scotland. 17 photos stitched panorama low res image.",
    "title": "",
    "type": 1,
    "updateddate": 1474538938000,
    "visibility": ""
}
]
""".data(using: .utf8)!
        do {
            let decoder = Post.decoder
            let posts = try decoder.decode([[String: AnyJSONType]].self, from: data)
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
{
    "annotation": "",
    "baseid": "4_1758145925_1172565576574204176_1758145925",
    "cameramodelentityid": "",
    "commentcount": 2,
    "commententityid": "",
    "createddate": 1454000731000,
    "description": "",
    "entityid": "4_1758145925_1172565576574204176_1758145925",
    "favouritecount": 0,
    "iscommentable": 1,
    "isfavourited": 0,
    "islikeable": 1,
    "islikes": 0,
    "isshared": 0,
    "istruncated": 0,
    "latitude": 0,
    "likecount": 23,
    "longitude": 0,
    "originalcrosspostid": 0,
    "originalpostid": 0,
    "originalposturl": "",
    "personentityid": "4_1758145925_9db243b0fe3818a570b25d80125931fd",
    "personfilerelativepath": "",
    "personfileurl": "https://scontent.cdninstagram.com/vp/c880ee6e29389ff4461b62a6ff9ed497/5C9169BB/t51.2885-19/s150x150/13108977_278179932527659_274844554_a.jpg",
    "personfullname": "Alex Hamilton",
    "personusername": "alexdigime",
    "postentityid": "",
    "postid": "1172565576574204176_1758145925",
    "postreplycount": 0,
    "posturl": "https://www.instagram.com/p/BBFyi3rjnkQ/",
    "rawtext": "",
    "referenceentityid": "4_1758145925",
    "referenceentitytype": 15,
    "sharecount": 0,
    "socialnetworkuserentityid": "4_1758145925",
    "source": "",
    "text": "My career ladder  ",
    "title": "",
    "type": 20,
    "updateddate": 1454000731000,
    "visibility": "",
    "accountentityid": "4_1758145925"
},
{
    "annotation": "",
    "baseid": "4_1758145925_1172539312144546244_1758145925",
    "cameramodelentityid": "",
    "commentcount": 12,
    "commententityid": "",
    "createddate": 1453997600000,
    "description": "",
    "entityid": "4_1758145925_1172539312144546244_1758145925",
    "favouritecount": 0,
    "iscommentable": 1,
    "isfavourited": 0,
    "islikeable": 1,
    "islikes": 0,
    "isshared": 0,
    "istruncated": 0,
    "latitude": 0,
    "likecount": 12,
    "longitude": 0,
    "originalcrosspostid": 0,
    "originalpostid": 0,
    "originalposturl": "",
    "personentityid": "4_1758145925_9db243b0fe3818a570b25d80125931fd",
    "personfilerelativepath": "",
    "personfileurl": "https://scontent.cdninstagram.com/vp/c880ee6e29389ff4461b62a6ff9ed497/5C9169BB/t51.2885-19/s150x150/13108977_278179932527659_274844554_a.jpg",
    "personfullname": "Alex Hamilton",
    "personusername": "alexdigime",
    "postentityid": "",
    "postid": "1172539312144546244_1758145925",
    "postreplycount": 0,
    "posturl": "https://www.instagram.com/p/BBFskrBjnnE/",
    "rawtext": "",
    "referenceentityid": "4_1758145925",
    "referenceentitytype": 15,
    "sharecount": 0,
    "socialnetworkuserentityid": "4_1758145925",
    "source": "",
    "text": "Software project at the end of the sprint",
    "title": "",
    "type": 20,
    "updateddate": 1453997600000,
    "visibility": "",
    "accountentityid": "4_1758145925"
},
{
    "annotation": "",
    "baseid": "4_1758145925_954283860282997757_1758145925",
    "cameramodelentityid": "",
    "commentcount": 2,
    "commententityid": "",
    "createddate": 1427979522000,
    "description": "",
    "entityid": "4_1758145925_954283860282997757_1758145925",
    "favouritecount": 0,
    "iscommentable": 1,
    "isfavourited": 0,
    "islikeable": 1,
    "islikes": 0,
    "isshared": 0,
    "istruncated": 0,
    "latitude": 0,
    "likecount": 7,
    "longitude": 0,
    "originalcrosspostid": 0,
    "originalpostid": 0,
    "originalposturl": "",
    "personentityid": "4_1758145925_9db243b0fe3818a570b25d80125931fd",
    "personfilerelativepath": "",
    "personfileurl": "https://scontent.cdninstagram.com/vp/c880ee6e29389ff4461b62a6ff9ed497/5C9169BB/t51.2885-19/s150x150/13108977_278179932527659_274844554_a.jpg",
    "personfullname": "Alex Hamilton",
    "personusername": "alexdigime",
    "postentityid": "",
    "postid": "954283860282997757_1758145925",
    "postreplycount": 0,
    "posturl": "https://www.instagram.com/p/0-TB1rDnv9/",
    "rawtext": "",
    "referenceentityid": "4_1758145925",
    "referenceentitytype": 15,
    "sharecount": 0,
    "socialnetworkuserentityid": "4_1758145925",
    "source": "",
    "text": "Testing iphone 6 picture cropping",
    "title": "",
    "type": 20,
    "updateddate": 1427979522000,
    "visibility": "",
    "accountentityid": "4_1758145925"
}
]
""".data(using: .utf8)!
        do {
            let decoder = Post.decoder
            let posts = try decoder.decode([[String: AnyJSONType]].self, from: data)
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
{
    "islikes": 0,
    "type": 19,
    "annotation": "",
    "baseid": "12_41986181@N07_14468847071",
    "commentcount": 0,
    "createddate": 1403353049000,
    "description": "",
    "entityid": "12_41986181@N07_14468847071",
    "favouritecount": 0,
    "iscommentable": 1,
    "isfavourited": 0,
    "islikeable": 1,
    "isshared": 0,
    "istruncated": 0,
    "latitude": 0,
    "likecount": 0,
    "longitude": 0,
    "originalcrosspostid": "",
    "originalpostid": "",
    "originalposturl": "",
    "personentityid": "12_41986181@N07_41986181@N07",
    "personfilerelativepath": "",
    "personfileurl": "http://farm2.staticflickr.com/1664/buddyicons/41986181@N07.jpg",
    "personfullname": "",
    "personusername": "hamilton_alex",
    "postentityid": "",
    "postid": "14468847071",
    "postreplycount": 0,
    "posturl": "https://www.flickr.com/photos/41986181@N07/14468847071",
    "rawtext": "",
    "referenceentityid": "12_41986181@N07",
    "referenceentitytype": 15,
    "sharecount": 0,
    "socialnetworkuserentityid": "12_41986181@N07",
    "source": "",
    "tags": [],
    "text": "",
    "title": "DSC_0436",
    "updateddate": 1403730728000,
    "visibility": "",
    "accountentityid": "12_41986181@N07"
},
{
    "islikes": 0,
    "type": 19,
    "annotation": "",
    "baseid": "12_41986181@N07_14449116456",
    "commentcount": 0,
    "createddate": 1403353046000,
    "description": "",
    "entityid": "12_41986181@N07_14449116456",
    "favouritecount": 0,
    "iscommentable": 1,
    "isfavourited": 0,
    "islikeable": 1,
    "isshared": 0,
    "istruncated": 0,
    "latitude": 0,
    "likecount": 0,
    "longitude": 0,
    "originalcrosspostid": "",
    "originalpostid": "",
    "originalposturl": "",
    "personentityid": "12_41986181@N07_41986181@N07",
    "personfilerelativepath": "",
    "personfileurl": "http://farm2.staticflickr.com/1664/buddyicons/41986181@N07.jpg",
    "personfullname": "",
    "personusername": "hamilton_alex",
    "postentityid": "",
    "postid": "14449116456",
    "postreplycount": 0,
    "posturl": "https://www.flickr.com/photos/41986181@N07/14449116456",
    "rawtext": "",
    "referenceentityid": "12_41986181@N07",
    "referenceentitytype": 15,
    "sharecount": 0,
    "socialnetworkuserentityid": "12_41986181@N07",
    "source": "",
    "tags": [],
    "text": "",
    "title": "DSC_0389",
    "updateddate": 1403730728000,
    "visibility": "",
    "accountentityid": "12_41986181@N07"
},
{
    "islikes": 0,
    "type": 19,
    "annotation": "",
    "baseid": "12_41986181@N07_14285773357",
    "commentcount": 0,
    "createddate": 1403353044000,
    "description": "",
    "entityid": "12_41986181@N07_14285773357",
    "favouritecount": 0,
    "iscommentable": 1,
    "isfavourited": 0,
    "islikeable": 1,
    "isshared": 0,
    "istruncated": 0,
    "latitude": 0,
    "likecount": 0,
    "longitude": 0,
    "originalcrosspostid": "",
    "originalpostid": "",
    "originalposturl": "",
    "personentityid": "12_41986181@N07_41986181@N07",
    "personfilerelativepath": "",
    "personfileurl": "http://farm2.staticflickr.com/1664/buddyicons/41986181@N07.jpg",
    "personfullname": "",
    "personusername": "hamilton_alex",
    "postentityid": "",
    "postid": "14285773357",
    "postreplycount": 0,
    "posturl": "https://www.flickr.com/photos/41986181@N07/14285773357",
    "rawtext": "",
    "referenceentityid": "12_41986181@N07",
    "referenceentitytype": 15,
    "sharecount": 0,
    "socialnetworkuserentityid": "12_41986181@N07",
    "source": "",
    "tags": [],
    "text": "",
    "title": "DSC_0277",
    "updateddate": 1403730728000,
    "visibility": "",
    "accountentityid": "12_41986181@N07"
}
]
""".data(using: .utf8)!
        do {
            let decoder = Post.decoder
            let posts = try decoder.decode([[String: AnyJSONType]].self, from: data)
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
{
    "islikes": 1,
    "type": 6,
    "annotation": "",
    "baseid": "3_3075118228_846354880210108416",
    "commentcount": 0,
    "createddate": 1490621702000,
    "entityid": "3_3075118228_846354880210108416",
    "favouritecount": 2,
    "iscommentable": 0,
    "isfavourited": 1,
    "islikeable": 0,
    "isshared": 0,
    "istruncated": 0,
    "longitude": 0,
    "latitude": 0,
    "likecount": 0,
    "links": [],
    "originalcrosspostid": "",
    "originalpostid": "",
    "originalposturl": "",
    "personentityid": "3_3075118228_748196829788012544",
    "personfilerelativepath": "",
    "personfileurl": "https://pbs.twimg.com/profile_images/1046547444736163870/h2FIHLhF_normal.jpg",
    "personfullname": "Joana",
    "personusername": "CamilaxBay",
    "postentityid": "",
    "postid": "846354880210108416",
    "postreplycount": 0,
    "posturl": "https://twitter.com/CamilaxBay/status/846354880210108416",
    "rawtext": "",
    "referenceentityid": "3_3075118228",
    "referenceentitytype": 15,
    "sharecount": 1,
    "socialnetworkuserentityid": "3_3075118228",
    "source": "<a href=\\"http://twitter.com/download/iphone\\" rel=\\"nofollow\\">Twitter for iPhone</a>",
    "text": "This is beautiful just beautiful https://t.co/82sOmtgYEL",
    "title": "",
    "updateddate": 1490621702000,
    "viewcount": 0,
    "visibility": "",
    "accountentityid": "3_3075118228"
},
{
    "islikes": 1,
    "type": 6,
    "annotation": "",
    "baseid": "3_3075118228_846354865513160706",
    "commentcount": 0,
    "createddate": 1490621699000,
    "entityid": "3_3075118228_846354865513160706",
    "favouritecount": 49,
    "iscommentable": 0,
    "isfavourited": 1,
    "islikeable": 0,
    "isshared": 0,
    "istruncated": 0,
    "longitude": 0,
    "latitude": 0,
    "likecount": 0,
    "links": [],
    "originalcrosspostid": "",
    "originalpostid": "",
    "originalposturl": "",
    "personentityid": "3_3075118228_829924926983245824",
    "personfilerelativepath": "",
    "personfileurl": "https://pbs.twimg.com/profile_images/988735128779210753/Zy2IS6qJ_normal.jpg",
    "personfullname": "Simply Love TimmyXWZ",
    "personusername": "SimplyLoveTimmy",
    "postentityid": "",
    "postid": "846354865513160706",
    "postreplycount": 0,
    "posturl": "https://twitter.com/SimplyLoveTimmy/status/846354865513160706",
    "rawtext": "",
    "referenceentityid": "3_3075118228",
    "referenceentitytype": 15,
    "sharecount": 58,
    "socialnetworkuserentityid": "3_3075118228",
    "source": "<a href=\\"http://twitter.com\\" rel=\\"nofollow\\">Twitter Web Client</a>",
    "text": "24th ERC Chinese Top Ten Awards Ceremony Red Carpet [ ZZ answering fans' question ] CHINESE & ENG SUB Cr: 芒果之家 #许魏洲 #TimmyXu #xuweizhou https://t.co/NPe38rcK00",
    "title": "",
    "updateddate": 1490621699000,
    "viewcount": 0,
    "visibility": "",
    "accountentityid": "3_3075118228"
},
{
    "islikes": 1,
    "type": 6,
    "annotation": "",
    "baseid": "3_3075118228_846354820885757953",
    "commentcount": 0,
    "createddate": 1490621688000,
    "entityid": "3_3075118228_846354820885757953",
    "favouritecount": 25,
    "iscommentable": 0,
    "isfavourited": 1,
    "islikeable": 0,
    "isshared": 0,
    "istruncated": 0,
    "longitude": 0,
    "latitude": 0,
    "likecount": 0,
    "links": [],
    "originalcrosspostid": "",
    "originalpostid": "",
    "originalposturl": "",
    "personentityid": "3_3075118228_34713362",
    "personfilerelativepath": "",
    "personfileurl": "https://pbs.twimg.com/profile_images/991818020233404416/alrBF_dr_normal.jpg",
    "personfullname": "Bloomberg",
    "personusername": "business",
    "postentityid": "",
    "postid": "846354820885757953",
    "postreplycount": 0,
    "posturl": "https://twitter.com/business/status/846354820885757953",
    "rawtext": "",
    "referenceentityid": "3_3075118228",
    "referenceentitytype": 15,
    "sharecount": 65,
    "socialnetworkuserentityid": "3_3075118228",
    "source": "<a href=\\"http://snappytv.com\\" rel=\\"nofollow\\">SnappyTV.com</a>",
    "text": "U.S. markets see one of their worst opens in weeks https://www.bloomberg.com/news/articles/2017-03-26/wariness-engulfs-markets-as-trump-optimism-tested-markets-wrap #Daybreak https://t.co/ioYF5OMNOZ",
    "title": "",
    "updateddate": 1490621688000,
    "viewcount": 0,
    "visibility": "",
    "accountentityid": "3_3075118228"
}
]
""".data(using: .utf8)!
        do {
            let decoder = Post.decoder
            let posts = try decoder.decode([[String: AnyJSONType]].self, from: data)
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
{
    "islikes": 0,
    "type": 24,
    "annotation": "",
    "baseid": "9_71424481498761696_71424344061267394",
    "commentcount": 0,
    "createddate": 1343724899000,
    "entityid": "9_71424481498761696_71424344061267394",
    "favouritecount": 0,
    "iscommentable": 1,
    "isfavourited": 0,
    "islikeable": 1,
    "isshared": 0,
    "istruncated": 0,
    "latitude": 0,
    "likecount": 0,
    "longitude": 0,
    "originalcrosspostid": 0,
    "originalpostid": 0,
    "originalposturl": "http://www.youtube.com/watch/?v=5IuRzJRrRpQ",
    "personentityid": "9_71424481498761696_71424481498761696",
    "personfilerelativepath": "",
    "personfileurl": "",
    "personfullname": "Pascal Wheeler",
    "personusername": "pasalot",
    "postentityid": "",
    "postid": "71424344061267394",
    "postreplycount": "",
    "posturl": "https://www.pinterest.com/pin/71424344061267394/",
    "rawtext": "",
    "referenceentityid": "9_71424481498761696",
    "referenceentitytype": 15,
    "sharecount": 0,
    "socialnetworkuserentityid": "9_71424481498761696",
    "source": "",
    "text": "We love dwarf goats > Buttermilk \\"plays\\" with her \\"friends\\"",
    "title": "Fun",
    "updateddate": 1343724899000,
    "viewcount": "",
    "visibility": "",
    "accountentityid": "9_71424481498761696"
},
{
    "islikes": 0,
    "type": 24,
    "annotation": "",
    "baseid": "9_71424481498761696_71424344061267300",
    "commentcount": 0,
    "createddate": 1343722028000,
    "entityid": "9_71424481498761696_71424344061267300",
    "favouritecount": 0,
    "iscommentable": 1,
    "isfavourited": 0,
    "islikeable": 1,
    "isshared": 0,
    "istruncated": 0,
    "latitude": 0,
    "likecount": 0,
    "longitude": 0,
    "originalcrosspostid": 0,
    "originalpostid": 0,
    "originalposturl": "http://www.nobrow.net/2717",
    "personentityid": "9_71424481498761696_71424481498761696",
    "personfilerelativepath": "",
    "personfileurl": "",
    "personfullname": "Pascal Wheeler",
    "personusername": "pasalot",
    "postentityid": "",
    "postid": "71424344061267300",
    "postreplycount": "",
    "posturl": "https://www.pinterest.com/pin/71424344061267300/",
    "rawtext": "",
    "referenceentityid": "9_71424481498761696",
    "referenceentitytype": 15,
    "sharecount": 0,
    "socialnetworkuserentityid": "9_71424481498761696",
    "source": "",
    "text": "Nobrow – Hildafolk (2nd Edition)",
    "title": "For the kids",
    "updateddate": 1343722028000,
    "viewcount": "",
    "visibility": "",
    "accountentityid": "9_71424481498761696"
},
{
    "islikes": 0,
    "type": 24,
    "annotation": "",
    "baseid": "9_71424481498761696_71424344061166606",
    "commentcount": 0,
    "createddate": 1342684699000,
    "entityid": "9_71424481498761696_71424344061166606",
    "favouritecount": 0,
    "iscommentable": 1,
    "isfavourited": 0,
    "islikeable": 1,
    "isshared": 0,
    "istruncated": 0,
    "latitude": 0,
    "likecount": 0,
    "longitude": 0,
    "originalcrosspostid": 0,
    "originalpostid": 0,
    "originalposturl": "http://the-bath.tumblr.com/",
    "personentityid": "9_71424481498761696_71424481498761696",
    "personfilerelativepath": "",
    "personfileurl": "",
    "personfullname": "Pascal Wheeler",
    "personusername": "pasalot",
    "postentityid": "",
    "postid": "71424344061166606",
    "postreplycount": "",
    "posturl": "https://www.pinterest.com/pin/71424344061166606/",
    "rawtext": "",
    "referenceentityid": "9_71424481498761696",
    "referenceentitytype": 15,
    "sharecount": 0,
    "socialnetworkuserentityid": "9_71424481498761696",
    "source": "",
    "text": "Ubud Hanging Gardens Hotel, Bali  AMAZiNG",
    "title": "To experience",
    "updateddate": 1342684699000,
    "viewcount": "",
    "visibility": "",
    "accountentityid": "9_71424481498761696"
}
]
""".data(using: .utf8)!
        do {
            let decoder = Post.decoder
            let posts = try decoder.decode([[String: AnyJSONType]].self, from: data)
            XCTAssertNotNil(posts)
            XCTAssert(posts.count == 3, "Expected 3 Posts, got \(posts.count)")
        }
        catch {
            XCTFail("Unable to parse json to Pinterest posts array: \(error)")
        }
    }
}
