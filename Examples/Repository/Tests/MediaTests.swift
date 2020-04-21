//
//  MediaTests.swift
//  DigiMeRepository_Tests
//
//  Created on 12/12/2018.
//  Copyright © 2018 digi.me Limited. All rights reserved.
//

@testable import DigiMeSDK
import XCTest

class MediaTests: XCTestCase {
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
                "type": 0,
                "mediaid": "1416030955080308",
                "baseid": "10_1416030955080308",
                "cameramodelentityid": "",
                "commentcount": 1,
                "createddate": 1474494435000,
                "displayshorturl": "",
                "displayurlindexend": 0,
                "displayurlindexstart": 0,
                "entityid": "10_1416030955080308",
                "filter": "",
                "imagefileentityid": "",
                "imagefilerelativepath": "",
                "imagefileurl": "https://scontent.xx.fbcdn.net/v/t31.0-8/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=6cd825d241ecd389f5049fd4f4bc7c9d&oe=5CB12644",
                "resources": [
                    [
                        "aspectratio": [
                            "accuracy": 43.466666666666676,
                            "actual": "1174:375",
                            "closest": "2:1"
                        ],
                        "height": 750,
                        "mimetype": "image/jpeg",
                        "resize": "fit",
                        "type": 0,
                        "url": "https://scontent.xx.fbcdn.net/v/t31.0-8/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=6cd825d241ecd389f5049fd4f4bc7c9d&oe=5CB12644",
                        "width": 2348
                    ],
                    [
                        "aspectratio": [
                            "accuracy": 43.425076452599384,
                            "actual": "1024:327",
                            "closest": "2:1"
                        ],
                        "height": 654,
                        "mimetype": "image/jpeg",
                        "resize": "fit",
                        "type": 0,
                        "url": "https://scontent.xx.fbcdn.net/v/t31.0-8/q81/s2048x2048/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=f902d1621b5144c12791f80ecf0903f0&oe=5CAC2740",
                        "width": 2048
                    ],
                    [
                        "aspectratio": [
                            "accuracy": 43.50000000000001,
                            "actual": "313:100",
                            "closest": "2:1"
                        ],
                        "height": 600,
                        "mimetype": "image/jpeg",
                        "resize": "fit",
                        "type": 0,
                        "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/p600x600/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=bb4b89d2dcdb0d3e10e245cb083eded9&oe=5CABE864",
                        "width": 1878
                    ],
                    [
                        "aspectratio": [
                            "accuracy": 43.54166666666666,
                            "actual": "751:240",
                            "closest": "2:1"
                        ],
                        "height": 480,
                        "mimetype": "image/jpeg",
                        "resize": "fit",
                        "type": 0,
                        "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/p480x480/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=621740572400deaab63a4173703a54d0&oe=5CA4474D",
                        "width": 1502
                    ],
                    [
                        "aspectratio": [
                            "accuracy": 43.59375000000001,
                            "actual": "1001:320",
                            "closest": "2:1"
                        ],
                        "height": 320,
                        "mimetype": "image/jpeg",
                        "resize": "fit",
                        "type": 0,
                        "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/q84/p320x320/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=6e510f602bbd1fd8bf1d9053c0a37d98&oe=5C641C7A",
                        "width": 1001
                    ],
                    [
                        "aspectratio": [
                            "accuracy": 43.51851851851851,
                            "actual": "169:54",
                            "closest": "2:1"
                        ],
                        "height": 540,
                        "mimetype": "image/jpeg",
                        "resize": "fit",
                        "type": 0,
                        "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/q84/p180x540/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=0527420cf7095bdb458eb3aba60507f5&oe=5CA5CB31",
                        "width": 1690
                    ],
                    [
                        "aspectratio": [
                            "accuracy": 43.46153846153846,
                            "actual": "407:130",
                            "closest": "2:1"
                        ],
                        "height": 130,
                        "mimetype": "image/jpeg",
                        "resize": "fit",
                        "type": 0,
                        "url": "https://scontent.xx.fbcdn.net/v/t1.0-0/q84/p130x130/14344233_1416030955080308_5639116713383824619_n.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=404f1dd8f2d42430c90739918665f3d5&oe=5CAFD67F",
                        "width": 407
                    ],
                    [
                        "aspectratio": [
                            "accuracy": 43.55555555555555,
                            "actual": "704:225",
                            "closest": "2:1"
                        ],
                        "height": 225,
                        "mimetype": "image/jpeg",
                        "resize": "fit",
                        "type": 0,
                        "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/q84/p75x225/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=d363092f9bd485c8fc00aa4540b1ec8f&oe=5C6A6AFB",
                        "width": 704
                    ],
                ],
                "interestscore": 0,
                "itemlicenceentityid": "",
                "latitude": 0,
                "likecount": 9,
                "link": "https://www.facebook.com/photo.php?fbid=1416030955080308&set=a.750155571667853&type=3",
                "locationentityid": "",
                "longitude": 0,
                "mediaalbumname": "Timeline Photos",
                "mediaobjectid": "1416030955080308",
                "mediaobjectlikeid": "",
                "name": "Highland Scotland. 17 photos stitched panorama low res image.",
                "originatortype": 1,
                "personentityid": "1_1078609952155745_1078609952155745",
                "personfilerelativepath": "",
                "personfileurl": "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773881&hash=AeRdwgqyUdXmD7LS",
                "personfullname": "Alex Hamilton",
                "personusername": "Alex Hamilton",
                "postentityid": "1_1078609952155745_1078609952155745_1416032851746785",
                "tagcount": 0,
                "taggedpeoplecount": 0,
                "updateddate": 1474494435000
                ] as [String: Any]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = PostMedia.decoder
            let media = try decoder.decode(PostMedia.self, from: data)
            
            var expectedDate = Date(timeIntervalSince1970: 1474494435000 / 1000)
            XCTAssert(media.createdDate == expectedDate, "Expected 'createdDate': \(expectedDate) got \(media.createdDate)")
            expectedDate = Date(timeIntervalSince1970: 1474494435000 / 1000)
            XCTAssert(media.updatedDate == expectedDate, "Expected 'updatedDate': \(expectedDate) got \(media.updatedDate)")
            
            XCTAssert(media.accountIdentifier == "1_1078609952155745", "Expected 'accountentityid': '1_1078609952155745' got \(media.accountIdentifier)")
            XCTAssert(media.type.rawValue == 0, "Expected 'type': '0' got \(media.type)")
            XCTAssert(media.mediaIdentifier == "1416030955080308", "Expected 'mediaid': '1416030955080308' got \(media.mediaIdentifier)")
            XCTAssert(media.baseIdentifier == "10_1416030955080308", "Expected 'baseid': '10_1416030955080308' got \(media.baseIdentifier)")
            XCTAssert(media.commentCount == 1, "Expected 'commentcount': '1' got \(media.commentCount)")
            XCTAssert(media.displayUrlIndexEnd == 0, "Expected 'displayurlindexend': '0' got \(media.displayUrlIndexEnd)")
            XCTAssert(media.displayUrlIndexStart == 0, "Expected 'displayurlindexstart': '0' got \(media.displayUrlIndexStart)")
            XCTAssert(media.identifier == "10_1416030955080308", "Expected 'entityid': '10_1416030955080308' got \(media.identifier)")
            XCTAssert(media.interestScore == 0, "Expected 'interestscore': '0' got \(media.interestScore)")
            XCTAssert(media.likeCount == 9, "Expected 'likecount': '9' got \(media.likeCount)")
            XCTAssert(media.link == "https://www.facebook.com/photo.php?fbid=1416030955080308&set=a.750155571667853&type=3", "Expected 'link': 'https://www.facebook.com/photo.php?fbid=1416030955080308&set=a.750155571667853&type=3' got \(media.link)")
            XCTAssert(media.mediaAlbumName == "Timeline Photos", "Expected 'mediaalbumname': 'Timeline Photos' got \(media.mediaAlbumName)")
            XCTAssert(media.mediaObjectIdentifier == "1416030955080308", "Expected 'mediaobjectid': '1416030955080308' got \(media.mediaObjectIdentifier)")
            XCTAssert(media.name == "Highland Scotland. 17 photos stitched panorama low res image.", "Expected 'name': 'Highland Scotland. 17 photos stitched panorama low res image.' got \(media.name)")
            XCTAssert(media.originatorType == 1, "Expected 'originatortype': '1' got \(media.originatorType)")
            XCTAssert(media.personIdentifier == "1_1078609952155745_1078609952155745", "Expected 'personentityid': '1_1078609952155745_1078609952155745' got \(media.personIdentifier)")
            XCTAssert(media.personFileUrl == "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773881&hash=AeRdwgqyUdXmD7LS", "Expected 'personfileurl': 'https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773881&hash=AeRdwgqyUdXmD7LS' got \(media.personFileUrl)")
            XCTAssert(media.personFullname == "Alex Hamilton", "Expected 'personfullname': 'Alex Hamilton' got \(media.personFullname)")
            XCTAssert(media.personUsername == "Alex Hamilton", "Expected 'personusername': 'Alex Hamilton' got \(media.personUsername)")
            XCTAssert(media.resources.count == 8, "Expected 'resources' count '8', got \(media.resources.count)")
            
            // optionals
            if let optionalLatitude = media.latitude {
                XCTAssert(optionalLatitude == 0, "Expected 'latitude': '0' got \(optionalLatitude)")
            }
            if let optionalLongitude = media.longitude {
                XCTAssert(optionalLongitude == 0, "Expected 'longitude': '0' got \(optionalLongitude)")
            }
            if let optionalPostIdentifier = media.postIdentifier {
                XCTAssert(optionalPostIdentifier == "1_1078609952155745_1078609952155745_1416032851746785", "Expected 'postentityid': '1_1078609952155745_1078609952155745_1416032851746785' got \(optionalPostIdentifier)")
            }
            if let optionalTagCount = media.tagCount {
                XCTAssert(optionalTagCount == 0, "Expected 'tagcount': '0' got \(optionalTagCount)")
            }
            if let optionalTaggedPeopleCount = media.taggedPeopleCount {
                XCTAssert(optionalTaggedPeopleCount == 0, "Expected 'taggedpeoplecount': '0' got \(optionalTaggedPeopleCount)")
            }
            if let optionalImageFileUrl = media.imageFileUrl {
                XCTAssert(optionalImageFileUrl == "https://scontent.xx.fbcdn.net/v/t31.0-8/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=6cd825d241ecd389f5049fd4f4bc7c9d&oe=5CB12644", "Expected 'imagefileurl': 'https://scontent.xx.fbcdn.net/v/t31.0-8/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=6cd825d241ecd389f5049fd4f4bc7c9d&oe=5CB12644' got \(optionalImageFileUrl)")
            }
            if let optionalFilter = media.filter {
                XCTAssertNotNil(optionalFilter)
            }
            if let optionalFilter = media.filter {
                XCTAssertNotNil(optionalFilter)
            }
            if let optionalCameraModelIdentifier = media.cameraModelIdentifier {
                XCTAssertNotNil(optionalCameraModelIdentifier)
            }
            if let optionalPersonFileRelativePath = media.personFileRelativePath {
                XCTAssertNotNil(optionalPersonFileRelativePath)
            }
            if let optionalMediaObjectLikeIdentifier = media.mediaObjectLikeIdentifier {
                XCTAssertNotNil(optionalMediaObjectLikeIdentifier)
            }
            if let optionalLocationIdentifier = media.locationIdentifier {
                XCTAssertNotNil(optionalLocationIdentifier)
            }
            if let optionalItemLicenceIdentifier = media.itemLicenceIdentifier {
                XCTAssertNotNil(optionalItemLicenceIdentifier)
            }
            if let optionalImageFileIdentifier = media.imageFileIdentifier {
                XCTAssertNotNil(optionalImageFileIdentifier)
            }
            if let optionalImageFileRelativePath = media.imageFileRelativePath {
                XCTAssertNotNil(optionalImageFileRelativePath)
            }
            if let optionalDisplayShortUrl = media.displayShortUrl {
                XCTAssertNotNil(optionalDisplayShortUrl)
            }
        }
        catch {
            XCTFail("Unable to parse json Post: \(error)")
        }
    }
    
    func testFacebookMedia() {
        let data = """
[
{
    "accountentityid": "1_1078609952155745",
    "type": 0,
    "mediaid": "1416030955080308",
    "baseid": "10_1416030955080308",
    "cameramodelentityid": "",
    "commentcount": 1,
    "createddate": 1474494435000,
    "displayshorturl": "",
    "displayurlindexend": 0,
    "displayurlindexstart": 0,
    "entityid": "10_1416030955080308",
    "filter": "",
    "imagefileentityid": "",
    "imagefilerelativepath": "",
    "imagefileurl": "https://scontent.xx.fbcdn.net/v/t31.0-8/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=6cd825d241ecd389f5049fd4f4bc7c9d&oe=5CB12644",
    "resources": [
        {
            "aspectratio": {
                "accuracy": 43.466666666666676,
                "actual": "1174:375",
                "closest": "2:1"
            },
            "height": 750,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-8/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=6cd825d241ecd389f5049fd4f4bc7c9d&oe=5CB12644",
            "width": 2348
        },
        {
            "aspectratio": {
                "accuracy": 43.425076452599384,
                "actual": "1024:327",
                "closest": "2:1"
            },
            "height": 654,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-8/q81/s2048x2048/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=f902d1621b5144c12791f80ecf0903f0&oe=5CAC2740",
            "width": 2048
        },
        {
            "aspectratio": {
                "accuracy": 43.50000000000001,
                "actual": "313:100",
                "closest": "2:1"
            },
            "height": 600,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/p600x600/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=bb4b89d2dcdb0d3e10e245cb083eded9&oe=5CABE864",
            "width": 1878
        },
        {
            "aspectratio": {
                "accuracy": 43.54166666666666,
                "actual": "751:240",
                "closest": "2:1"
            },
            "height": 480,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/p480x480/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=621740572400deaab63a4173703a54d0&oe=5CA4474D",
            "width": 1502
        },
        {
            "aspectratio": {
                "accuracy": 43.59375000000001,
                "actual": "1001:320",
                "closest": "2:1"
            },
            "height": 320,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/q84/p320x320/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=6e510f602bbd1fd8bf1d9053c0a37d98&oe=5C641C7A",
            "width": 1001
        },
        {
            "aspectratio": {
                "accuracy": 43.51851851851851,
                "actual": "169:54",
                "closest": "2:1"
            },
            "height": 540,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/q84/p180x540/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=0527420cf7095bdb458eb3aba60507f5&oe=5CA5CB31",
            "width": 1690
        },
        {
            "aspectratio": {
                "accuracy": 43.46153846153846,
                "actual": "407:130",
                "closest": "2:1"
            },
            "height": 130,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t1.0-0/q84/p130x130/14344233_1416030955080308_5639116713383824619_n.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=404f1dd8f2d42430c90739918665f3d5&oe=5CAFD67F",
            "width": 407
        },
        {
            "aspectratio": {
                "accuracy": 43.55555555555555,
                "actual": "704:225",
                "closest": "2:1"
            },
            "height": 225,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/q84/p75x225/14362680_1416030955080308_5639116713383824619_o.jpg?_nc_cat=102&_nc_ht=scontent.xx&oh=d363092f9bd485c8fc00aa4540b1ec8f&oe=5C6A6AFB",
            "width": 704
        }
    ],
    "interestscore": 0,
    "itemlicenceentityid": "",
    "latitude": 0,
    "likecount": 9,
    "link": "https://www.facebook.com/photo.php?fbid=1416030955080308&set=a.750155571667853&type=3",
    "locationentityid": "",
    "longitude": 0,
    "mediaalbumname": "Timeline Photos",
    "mediaobjectid": "1416030955080308",
    "mediaobjectlikeid": "",
    "name": "Highland Scotland. 17 photos stitched panorama low res image.",
    "originatortype": 1,
    "personentityid": "1_1078609952155745_1078609952155745",
    "personfilerelativepath": "",
    "personfileurl": "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773881&hash=AeRdwgqyUdXmD7LS",
    "personfullname": "Alex Hamilton",
    "personusername": "Alex Hamilton",
    "postentityid": "1_1078609952155745_1078609952155745_1416032851746785",
    "tagcount": 0,
    "taggedpeoplecount": 0,
    "updateddate": 1474494435000
},
{
    "accountentityid": "1_1078609952155745",
    "type": 0,
    "mediaid": "1416028295080574",
    "baseid": "10_1416028295080574",
    "cameramodelentityid": "",
    "commentcount": 0,
    "createddate": 1474493933000,
    "displayshorturl": "",
    "displayurlindexend": 0,
    "displayurlindexstart": 0,
    "entityid": "10_1416028295080574",
    "filter": "",
    "imagefileentityid": "",
    "imagefilerelativepath": "",
    "imagefileurl": "https://scontent.xx.fbcdn.net/v/t31.0-8/14409439_1416028295080574_3458432885421425219_o.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=84c41639ceb501972b0ed64c64fdd7bb&oe=5C671124",
    "resources": [
        {
            "aspectratio": {
                "accuracy": 87.22466960352422,
                "actual": "1024:681",
                "closest": "4:3"
            },
            "height": 1362,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-8/14409439_1416028295080574_3458432885421425219_o.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=84c41639ceb501972b0ed64c64fdd7bb&oe=5C671124",
            "width": 2048
        },
        {
            "aspectratio": {
                "accuracy": 87.26562499999999,
                "actual": "481:320",
                "closest": "4:3"
            },
            "height": 960,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-8/p960x960/14409439_1416028295080574_3458432885421425219_o.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=6956717de14e46f9f776d9db3cf16c8f&oe=5C97CEF1",
            "width": 1443
        },
        {
            "aspectratio": {
                "accuracy": 87.29166666666666,
                "actual": "541:360",
                "closest": "4:3"
            },
            "height": 720,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-8/p720x720/14409439_1416028295080574_3458432885421425219_o.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=18835bf284d864b36d045bc50e3b4b7b&oe=5C6A54E8",
            "width": 1082
        },
        {
            "aspectratio": {
                "accuracy": 87.24999999999999,
                "actual": "451:300",
                "closest": "4:3"
            },
            "height": 600,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/p600x600/14409439_1416028295080574_3458432885421425219_o.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=30a4607c674b18c2734a273883aef5be&oe=5CAD4B04",
            "width": 902
        },
        {
            "aspectratio": {
                "accuracy": 87.34374999999999,
                "actual": "721:480",
                "closest": "4:3"
            },
            "height": 480,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/p480x480/14409439_1416028295080574_3458432885421425219_o.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=4e27fbc2b9549a8415244e8bd47db4b7&oe=5C65D62D",
            "width": 721
        },
        {
            "aspectratio": {
                "accuracy": 87.26562499999999,
                "actual": "481:320",
                "closest": "4:3"
            },
            "height": 320,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t1.0-0/p320x320/14355124_1416028295080574_3458432885421425219_n.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=12c4ed5f0636c26091090b4fa14c3ca9&oe=5C68C07C",
            "width": 481
        },
        {
            "aspectratio": {
                "accuracy": 87.36111111111111,
                "actual": "811:540",
                "closest": "4:3"
            },
            "height": 540,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/p180x540/14409439_1416028295080574_3458432885421425219_o.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=e1ccaaa6ac178175953801bcddabf996&oe=5C958021",
            "width": 811
        },
        {
            "aspectratio": {
                "accuracy": 87.5,
                "actual": "3:2",
                "closest": "4:3"
            },
            "height": 130,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t1.0-0/p130x130/14355124_1416028295080574_3458432885421425219_n.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=4a7ac5685feeb75bf99be076f8ff620b&oe=5C63709B",
            "width": 195
        },
        {
            "aspectratio": {
                "accuracy": 87.33333333333333,
                "actual": "338:225",
                "closest": "4:3"
            },
            "height": 225,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t1.0-0/p75x225/14355124_1416028295080574_3458432885421425219_n.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=de3eec2c1d7c719ce3339c16c28eb2b4&oe=5C9D2D2C",
            "width": 338
        }
    ],
    "interestscore": 0,
    "itemlicenceentityid": "",
    "latitude": 0,
    "likecount": 2,
    "link": "https://www.facebook.com/photo.php?fbid=1416028295080574&set=a.1416027295080674&type=3",
    "locationentityid": "",
    "longitude": 0,
    "mediaalbumname": "National Three Peaks Challenge",
    "mediaobjectid": "1416028295080574",
    "mediaobjectlikeid": "",
    "name": "",
    "originatortype": 1,
    "personentityid": "1_1078609952155745_1078609952155745",
    "personfilerelativepath": "",
    "personfileurl": "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773881&hash=AeRdwgqyUdXmD7LS",
    "personfullname": "Alex Hamilton",
    "personusername": "Alex Hamilton",
    "postentityid": "1_1078609952155745_1078609952155745_1416028268413910",
    "tagcount": 0,
    "taggedpeoplecount": 0,
    "updateddate": 1474493962000
},
{
    "accountentityid": "1_1078609952155745",
    "type": 0,
    "mediaid": "1416028268413910",
    "baseid": "10_1416028268413910",
    "cameramodelentityid": "",
    "commentcount": 0,
    "createddate": 1474493930000,
    "displayshorturl": "",
    "displayurlindexend": 0,
    "displayurlindexstart": 0,
    "entityid": "10_1416028268413910",
    "filter": "",
    "imagefileentityid": "",
    "imagefilerelativepath": "",
    "imagefileurl": "https://scontent.xx.fbcdn.net/v/t31.0-8/14361281_1416028268413910_4401027552556636763_o.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=c5a8d596770c23e46b36026339cf5f91&oe=5C6D3EA3",
    "resources": [
        {
            "aspectratio": {
                "accuracy": 87.22466960352422,
                "actual": "1024:681",
                "closest": "4:3"
            },
            "height": 1362,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-8/14361281_1416028268413910_4401027552556636763_o.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=c5a8d596770c23e46b36026339cf5f91&oe=5C6D3EA3",
            "width": 2048
        },
        {
            "aspectratio": {
                "accuracy": 87.26562499999999,
                "actual": "481:320",
                "closest": "4:3"
            },
            "height": 960,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-8/q81/p960x960/14361281_1416028268413910_4401027552556636763_o.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=94e117f1b2172b600ba6676b261e4182&oe=5C9F5C09",
            "width": 1443
        },
        {
            "aspectratio": {
                "accuracy": 87.29166666666666,
                "actual": "541:360",
                "closest": "4:3"
            },
            "height": 720,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-8/q81/p720x720/14361281_1416028268413910_4401027552556636763_o.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=15c5446bd95899d5f0849bcc95814e2c&oe=5CAAC610",
            "width": 1082
        },
        {
            "aspectratio": {
                "accuracy": 87.24999999999999,
                "actual": "451:300",
                "closest": "4:3"
            },
            "height": 600,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/p600x600/14361281_1416028268413910_4401027552556636763_o.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=9e4be7524346bb0f65177bd16ced07f1&oe=5CA31683",
            "width": 902
        },
        {
            "aspectratio": {
                "accuracy": 87.34374999999999,
                "actual": "721:480",
                "closest": "4:3"
            },
            "height": 480,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/p480x480/14361281_1416028268413910_4401027552556636763_o.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=2597a835f5f84c86e2e3a3dfb9e2dd0a&oe=5C9B50AA",
            "width": 721
        },
        {
            "aspectratio": {
                "accuracy": 87.26562499999999,
                "actual": "481:320",
                "closest": "4:3"
            },
            "height": 320,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t1.0-0/p320x320/14370125_1416028268413910_4401027552556636763_n.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=a99c1489cb9f4e1667bc11b7326eeb42&oe=5CA4A340",
            "width": 481
        },
        {
            "aspectratio": {
                "accuracy": 87.36111111111111,
                "actual": "811:540",
                "closest": "4:3"
            },
            "height": 540,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t31.0-0/p180x540/14361281_1416028268413910_4401027552556636763_o.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=07293c19b46401ea4e199f38e4f88ff3&oe=5CB14DA6",
            "width": 811
        },
        {
            "aspectratio": {
                "accuracy": 87.5,
                "actual": "3:2",
                "closest": "4:3"
            },
            "height": 130,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t1.0-0/p130x130/14370125_1416028268413910_4401027552556636763_n.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=50a45093e8eb9b9ca14ad76f49318f0e&oe=5C6C73A7",
            "width": 195
        },
        {
            "aspectratio": {
                "accuracy": 87.33333333333333,
                "actual": "338:225",
                "closest": "4:3"
            },
            "height": 225,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://scontent.xx.fbcdn.net/v/t1.0-0/p75x225/14370125_1416028268413910_4401027552556636763_n.jpg?_nc_cat=110&_nc_ht=scontent.xx&oh=10456b297ffdce233fb4e8e99b69e3a5&oe=5CA1B010",
            "width": 338
        }
    ],
    "interestscore": 0,
    "itemlicenceentityid": "",
    "latitude": 0,
    "likecount": 3,
    "link": "https://www.facebook.com/photo.php?fbid=1416028268413910&set=a.1416027295080674&type=3",
    "locationentityid": "",
    "longitude": 0,
    "mediaalbumname": "National Three Peaks Challenge",
    "mediaobjectid": "1416028268413910",
    "mediaobjectlikeid": "",
    "name": "",
    "originatortype": 1,
    "personentityid": "1_1078609952155745_1078609952155745",
    "personfilerelativepath": "",
    "personfileurl": "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773881&hash=AeRdwgqyUdXmD7LS",
    "personfullname": "Alex Hamilton",
    "personusername": "Alex Hamilton",
    "postentityid": "1_1078609952155745_1078609952155745_1416028268413910",
    "tagcount": 0,
    "taggedpeoplecount": 0,
    "updateddate": 1474493962000
}
]
""".data(using: .utf8)!
        do {
            let decoder = PostMedia.decoder
            let media = try decoder.decode([PostMedia].self, from: data)
            XCTAssertNotNil(media)
            XCTAssert(media.count == 3, "Expected 3 Media, got \(media.count)")
        }
        catch {
            XCTFail("Unable to parse json to Facebook media array: \(error)")
        }
    }
    
    func testInstagramMedia() {
        let data = """
[
{
    "baseid": "4_951523491193977104_1758145925",
    "cameramodelentityid": "",
    "commentcount": 0,
    "commententityid": "",
    "createddate": 1427650461000,
    "description": "",
    "displayshorturl": "",
    "displayurlindexend": 0,
    "displayurlindexstart": 0,
    "entityid": "4_951523491193977104_1758145925",
    "filter": "Normal",
    "interestscore": 0,
    "itemlicenceentityid": "",
    "latitude": 0,
    "likecount": 5,
    "link": "https://www.instagram.com/p/00fZLoDnkQ/",
    "locationentityid": "",
    "longitude": 0,
    "mediaalbumname": "",
    "mediaid": "951523491193977104_1758145925",
    "mediaobjectid": "",
    "mediaobjectlikeid": "",
    "name": "Longer.. amcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non habent claritatem insitam; est usus legentis in iis qui facit eoru",
    "originatortype": 2,
    "personentityid": "4_1758145925_9db243b0fe3818a570b25d80125931fd",
    "personfilerelativepath": "",
    "personfileurl": "https://scontent.cdninstagram.com/vp/c880ee6e29389ff4461b62a6ff9ed497/5C9169BB/t51.2885-19/s150x150/13108977_278179932527659_274844554_a.jpg",
    "personfullname": "Alex Hamilton",
    "personusername": "alexdigime",
    "postentityid": "4_1758145925_951523491193977104_1758145925",
    "tagcount": 0,
    "taggedpeoplecount": 0,
    "type": 0,
    "resources": [
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 150,
            "mimetype": "image/jpeg",
            "type": 0,
            "url": "https://scontent.cdninstagram.com/vp/eccae8a512bc1254aec9486b1039606f/5CADB455/t51.2885-15/e15/s150x150/11033066_1606761162894838_901861971_n.jpg",
            "width": 150
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 320,
            "mimetype": "image/jpeg",
            "type": 0,
            "url": "https://scontent.cdninstagram.com/vp/16b788934e77640b7e08364e96f3cc2c/5CA537D1/t51.2885-15/e15/s320x320/11033066_1606761162894838_901861971_n.jpg",
            "width": 320
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 640,
            "mimetype": "image/jpeg",
            "type": 0,
            "url": "https://scontent.cdninstagram.com/vp/97143ac88e8c98cf3dc9d74906959b12/5CAED81B/t51.2885-15/e15/11033066_1606761162894838_901861971_n.jpg",
            "width": 640
        }
    ],
    "updateddate": 1427650461000,
    "accountentityid": "4_1758145925"
},
{
    "baseid": "4_951523164793239809_1758145925",
    "cameramodelentityid": "",
    "commentcount": 0,
    "commententityid": "",
    "createddate": 1427650422000,
    "description": "",
    "displayshorturl": "",
    "displayurlindexend": 0,
    "displayurlindexstart": 0,
    "entityid": "4_951523164793239809_1758145925",
    "filter": "Normal",
    "interestscore": 0,
    "itemlicenceentityid": "",
    "latitude": 0,
    "likecount": 0,
    "link": "https://www.instagram.com/p/00fUbpDnkB/",
    "locationentityid": "",
    "longitude": 0,
    "mediaalbumname": "",
    "mediaid": "951523164793239809_1758145925",
    "mediaobjectid": "",
    "mediaobjectlikeid": "",
    "name": "Short text",
    "originatortype": 2,
    "personentityid": "4_1758145925_9db243b0fe3818a570b25d80125931fd",
    "personfilerelativepath": "",
    "personfileurl": "https://scontent.cdninstagram.com/vp/c880ee6e29389ff4461b62a6ff9ed497/5C9169BB/t51.2885-19/s150x150/13108977_278179932527659_274844554_a.jpg",
    "personfullname": "Alex Hamilton",
    "personusername": "alexdigime",
    "postentityid": "4_1758145925_951523164793239809_1758145925",
    "tagcount": 0,
    "taggedpeoplecount": 0,
    "type": 0,
    "resources": [
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 150,
            "mimetype": "image/jpeg",
            "type": 0,
            "url": "https://scontent.cdninstagram.com/vp/5385a5abdf7b4d5b7eae07650720427b/5C9D25BF/t51.2885-15/e15/s150x150/10808699_796754797069176_215681053_n.jpg?_nc_ht=scontent.cdninstagram.com",
            "width": 150
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 320,
            "mimetype": "image/jpeg",
            "type": 0,
            "url": "https://scontent.cdninstagram.com/vp/beb276ccd24f2dc787c7ba11f69309d3/5CB01219/t51.2885-15/e15/s320x320/10808699_796754797069176_215681053_n.jpg?_nc_ht=scontent.cdninstagram.com",
            "width": 320
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 640,
            "mimetype": "image/jpeg",
            "type": 0,
            "url": "https://scontent.cdninstagram.com/vp/b17ce5ef9819fec1043ea39b9157ffb0/5C9250D1/t51.2885-15/e15/10808699_796754797069176_215681053_n.jpg?_nc_ht=scontent.cdninstagram.com",
            "width": 640
        }
    ],
    "updateddate": 1427650422000,
    "accountentityid": "4_1758145925"
},
{
    "baseid": "4_949960927246973054_1758145925",
    "cameramodelentityid": "",
    "commentcount": 0,
    "commententityid": "",
    "createddate": 1427464188000,
    "description": "",
    "displayshorturl": "",
    "displayurlindexend": 0,
    "displayurlindexstart": 0,
    "entityid": "4_949960927246973054_1758145925",
    "filter": "Normal",
    "interestscore": 0,
    "itemlicenceentityid": "",
    "latitude": 0,
    "likecount": 1,
    "link": "https://www.instagram.com/p/0u8G4jDnh-/",
    "locationentityid": "",
    "longitude": 0,
    "mediaalbumname": "",
    "mediaid": "949960927246973054_1758145925",
    "mediaobjectid": "",
    "mediaobjectlikeid": "",
    "name": "Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non habent claritatem insitam; est usus legentis in iis qui facit eorum claritatem. Investigationes demonstraverunt lectores legere me lius quod ii legunt saepius. Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum. Mirum est notare quam littera gothica, quam nunc putamus parum claram, anteposuerit litterarum formas humanitatis per seacula quarta decima et quinta decima. Eodem modo typi, qui nunc nobis videntur parum clari, fiant sollemnes in futurum. Lorem ipsum dolor sit amet, consectetuer adipiscing elit, sed diam nonummy nibh euismod tincidunt ut laoreet dolore magna aliquam erat volutpat. Ut wisi enim ad minim veniam, quis nostrud exerci tation ullamcorper suscipit lobortis nisl ut aliquip ex ea commodo consequat. Duis autem vel eum iriure dolor in hendrerit in vulputate velit esse molestie consequat, vel illum dolore eu feugiat nulla facilisis at vero eros et accumsan et iusto odio dignissim qui blandit praesent luptatum zzril delenit augue duis dolore te feugait nulla facilisi. Nam liber tempor cum soluta nobis eleifend option congue nihil imperdiet doming id quod mazim placerat facer possim assum. Typi non habent claritatem insitam; est usus legentis in iis qui facit eorum claritatem. Investigationes demonstraverunt lectores legere me lius quod ii legunt saepius. Claritas est etiam processus dynamicus, qui sequitur mutationem consuetudium lectorum. Mirum est notare quam littera gothica, quam nunc putamus parum claram, anteposuerit litterarum formas humanitatis",
    "originatortype": 2,
    "personentityid": "4_1758145925_9db243b0fe3818a570b25d80125931fd",
    "personfilerelativepath": "",
    "personfileurl": "https://scontent.cdninstagram.com/vp/c880ee6e29389ff4461b62a6ff9ed497/5C9169BB/t51.2885-19/s150x150/13108977_278179932527659_274844554_a.jpg",
    "personfullname": "Alex Hamilton",
    "personusername": "alexdigime",
    "postentityid": "4_1758145925_949960927246973054_1758145925",
    "tagcount": 0,
    "taggedpeoplecount": 0,
    "type": 0,
    "resources": [
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 150,
            "mimetype": "image/jpeg",
            "type": 0,
            "url": "https://scontent.cdninstagram.com/vp/82654dc7a0c121556e4290c89d94a147/5CA0A476/t51.2885-15/e15/s150x150/11055836_680706128721480_1238264905_n.jpg?_nc_ht=scontent.cdninstagram.com",
            "width": 150
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 320,
            "mimetype": "image/jpeg",
            "type": 0,
            "url": "https://scontent.cdninstagram.com/vp/cb28c2c428d0ff1d0a357644a0f17c97/5C8B90F2/t51.2885-15/e15/s320x320/11055836_680706128721480_1238264905_n.jpg?_nc_ht=scontent.cdninstagram.com",
            "width": 320
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 640,
            "mimetype": "image/jpeg",
            "type": 0,
            "url": "https://scontent.cdninstagram.com/vp/2bff1eccf76c22811230dabe75e7f322/5C91ED38/t51.2885-15/e15/11055836_680706128721480_1238264905_n.jpg?_nc_ht=scontent.cdninstagram.com",
            "width": 640
        }
    ],
    "updateddate": 1427464188000,
    "accountentityid": "4_1758145925"
}
]
""".data(using: .utf8)!
        do {
            let decoder = PostMedia.decoder
            let media = try decoder.decode([PostMedia].self, from: data)
            XCTAssertNotNil(media)
            XCTAssert(media.count == 3, "Expected 3 Media, got \(media.count)")
        }
        catch {
            XCTFail("Unable to parse json to Instagram media array: \(error)")
        }
    }
    
    func testFlickrMedia() {
        let data = """
[
{
    "baseid": "12_5893511508",
    "commentcount": 67,
    "createddate": 1327129075000,
    "description": "",
    "displayshorturl": "",
    "displayurlindexend": 0,
    "displayurlindexstart": 0,
    "entityid": "12_5893511508",
    "filter": "",
    "imagefileentityid": "",
    "imagefilerelativepath": "",
    "imagefileurl": "",
    "interestscore": 0,
    "itemlicenceentityid": "",
    "itemlicence": {
        "itemlicenceid": "0",
        "name": "All Rights Reserved",
        "url": ""
    },
    "likecount": 292,
    "link": "https://www.flickr.com/photos/46143044@N07/5893511508",
    "location": {},
    "mediaalbumname": "Favourites",
    "mediaalbumentityid": "12_41986181@N07_41986181@N07_7",
    "mediaid": "5893511508",
    "mediaobjectid": "",
    "mediaobjectlikeid": "",
    "name": "Abandoned Ranch House Milky Way",
    "originatortype": 8,
    "personentityid": "12_41986181@N07_46143044@N07",
    "personfilerelativepath": "",
    "personfileurl": "http://farm3.staticflickr.com/2869/buddyicons/46143044@N07.jpg",
    "personfullname": "",
    "personusername": "Eric Hines Photography",
    "postentityid": "12_41986181@N07_5893511508",
    "resources": [
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 75,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm6.staticflickr.com/5266/5893511508_9ca2529405_s.jpg",
            "width": 75
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 150,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm6.staticflickr.com/5266/5893511508_9ca2529405_q.jpg",
            "width": 150
        },
        {
            "aspectratio": {
                "accuracy": 88.0597014925373,
                "actual": "100:67",
                "closest": "4:3"
            },
            "height": 67,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm6.staticflickr.com/5266/5893511508_9ca2529405_t.jpg",
            "width": 100
        },
        {
            "aspectratio": {
                "accuracy": 87.5,
                "actual": "3:2",
                "closest": "4:3"
            },
            "height": 160,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm6.staticflickr.com/5266/5893511508_9ca2529405_m.jpg",
            "width": 240
        },
        {
            "aspectratio": {
                "accuracy": 87.32394366197182,
                "actual": "320:213",
                "closest": "4:3"
            },
            "height": 213,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm6.staticflickr.com/5266/5893511508_9ca2529405_n.jpg",
            "width": 320
        },
        {
            "aspectratio": {
                "accuracy": 87.38738738738738,
                "actual": "500:333",
                "closest": "4:3"
            },
            "height": 333,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm6.staticflickr.com/5266/5893511508_9ca2529405.jpg",
            "width": 500
        },
        {
            "aspectratio": {
                "accuracy": 87.58782201405151,
                "actual": "640:427",
                "closest": "4:3"
            },
            "height": 427,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm6.staticflickr.com/5266/5893511508_9ca2529405_z.jpg",
            "width": 640
        },
        {
            "aspectratio": {
                "accuracy": 87.55490483162518,
                "actual": "1024:683",
                "closest": "4:3"
            },
            "height": 683,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm6.staticflickr.com/5266/5893511508_9ca2529405_b.jpg",
            "width": 1024
        }
    ],
    "taggedpeople": [],
    "type": 0,
    "updateddate": 1327129075000,
    "videofileentityid": "",
    "videofilerelativepath": "",
    "videofileurl": "",
    "accountentityid": "12_41986181@N07"
},
{
    "baseid": "12_7921362244",
    "commentcount": 0,
    "createddate": 1346679630000,
    "description": "",
    "displayshorturl": "",
    "displayurlindexend": 0,
    "displayurlindexstart": 0,
    "entityid": "12_7921362244",
    "filter": "",
    "imagefileentityid": "",
    "imagefilerelativepath": "",
    "imagefileurl": "",
    "interestscore": 0,
    "itemlicenceentityid": "",
    "itemlicence": {
        "itemlicenceid": "0",
        "name": "All Rights Reserved",
        "url": ""
    },
    "likecount": 0,
    "link": "https://www.flickr.com/photos/41986181@N07/7921362244",
    "location": {
        "city": "Magagnosc, Provence-Alpes-Cote d'Azur, France",
        "country": "France",
        "latitude": "43.681",
        "longitude": "6.957",
        "name": "Magagnosc",
        "state": "Provence-Alpes-Cote d'Azur, France"
    },
    "mediaalbumname": "",
    "mediaalbumentityid": "12_41986181@N07_",
    "mediaid": "7921362244",
    "mediaobjectid": "",
    "mediaobjectlikeid": "",
    "name": "I - 115 Avenue Auguste Renoir, 06520, Grasse, France",
    "originatortype": 8,
    "personentityid": "12_41986181@N07_41986181@N07",
    "personfilerelativepath": "",
    "personfileurl": "http://farm2.staticflickr.com/1664/buddyicons/41986181@N07.jpg",
    "personfullname": "",
    "personusername": "hamilton_alex",
    "postentityid": "12_41986181@N07_7921362244",
    "resources": [
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 75,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8305/7921362244_468dab265d_s.jpg",
            "width": 75
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 150,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8305/7921362244_468dab265d_q.jpg",
            "width": 150
        },
        {
            "aspectratio": {
                "accuracy": 86.20689655172413,
                "actual": "100:87",
                "closest": "4:3"
            },
            "height": 87,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8305/7921362244_468dab265d_t.jpg",
            "width": 100
        },
        {
            "aspectratio": {
                "accuracy": 85.71428571428572,
                "actual": "8:7",
                "closest": "1:1"
            },
            "height": 210,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8305/7921362244_468dab265d_m.jpg",
            "width": 240
        },
        {
            "aspectratio": {
                "accuracy": 86.0215053763441,
                "actual": "320:279",
                "closest": "4:3"
            },
            "height": 279,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8305/7921362244_468dab265d_n.jpg",
            "width": 320
        },
        {
            "aspectratio": {
                "accuracy": 85.81235697940505,
                "actual": "500:437",
                "closest": "4:3"
            },
            "height": 437,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8305/7921362244_468dab265d.jpg",
            "width": 500
        },
        {
            "aspectratio": {
                "accuracy": 85.86762075134168,
                "actual": "640:559",
                "closest": "4:3"
            },
            "height": 559,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8305/7921362244_468dab265d_z.jpg",
            "width": 640
        },
        {
            "aspectratio": {
                "accuracy": 85.95988538681948,
                "actual": "400:349",
                "closest": "4:3"
            },
            "height": 698,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8305/7921362244_468dab265d_c.jpg",
            "width": 800
        },
        {
            "aspectratio": {
                "accuracy": 85.90604026845638,
                "actual": "512:447",
                "closest": "4:3"
            },
            "height": 894,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8305/7921362244_468dab265d_b.jpg",
            "width": 1024
        },
        {
            "aspectratio": {
                "accuracy": 85.89835361488906,
                "actual": "1600:1397",
                "closest": "4:3"
            },
            "height": 1397,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8305/7921362244_1077eacb94_h.jpg",
            "width": 1600
        },
        {
            "aspectratio": {
                "accuracy": 85.90604026845638,
                "actual": "512:447",
                "closest": "4:3"
            },
            "height": 1788,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8305/7921362244_bb947b9904_k.jpg",
            "width": 2048
        },
        {
            "aspectratio": {
                "accuracy": 85.90604026845638,
                "actual": "512:447",
                "closest": "4:3"
            },
            "height": 1788,
            "mimetype": "image/png",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8305/7921362244_5716752b0e_o.png",
            "width": 2048
        }
    ],
    "taggedpeople": [],
    "type": 0,
    "updateddate": 1403730729000,
    "videofileentityid": "",
    "videofilerelativepath": "",
    "videofileurl": "",
    "accountentityid": "12_41986181@N07"
},
{
    "baseid": "12_7923050590",
    "commentcount": 0,
    "createddate": 1346694034000,
    "description": "",
    "displayshorturl": "",
    "displayurlindexend": 0,
    "displayurlindexstart": 0,
    "entityid": "12_7923050590",
    "filter": "",
    "imagefileentityid": "",
    "imagefilerelativepath": "",
    "imagefileurl": "",
    "interestscore": 0,
    "itemlicenceentityid": "",
    "itemlicence": {
        "itemlicenceid": "0",
        "name": "All Rights Reserved",
        "url": ""
    },
    "likecount": 0,
    "link": "https://www.flickr.com/photos/41986181@N07/7923050590",
    "location": {
        "city": "Magagnosc, Provence-Alpes-Cote d'Azur, France",
        "country": "France",
        "latitude": "43.681",
        "longitude": "6.957",
        "name": "Magagnosc",
        "state": "Provence-Alpes-Cote d'Azur, France"
    },
    "mediaalbumname": "",
    "mediaalbumentityid": "12_41986181@N07_",
    "mediaid": "7923050590",
    "mediaobjectid": "",
    "mediaobjectlikeid": "",
    "name": "II - 115 Avenue Auguste Renoir, 06520, Grasse, France",
    "originatortype": 8,
    "personentityid": "12_41986181@N07_41986181@N07",
    "personfilerelativepath": "",
    "personfileurl": "http://farm2.staticflickr.com/1664/buddyicons/41986181@N07.jpg",
    "personfullname": "",
    "personusername": "hamilton_alex",
    "postentityid": "12_41986181@N07_7923050590",
    "resources": [
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 75,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8307/7923050590_a21cd8056c_s.jpg",
            "width": 75
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 150,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8307/7923050590_a21cd8056c_q.jpg",
            "width": 150
        },
        {
            "aspectratio": {
                "accuracy": 86.36363636363635,
                "actual": "25:11",
                "closest": "2:1"
            },
            "height": 44,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8307/7923050590_a21cd8056c_t.jpg",
            "width": 100
        },
        {
            "aspectratio": {
                "accuracy": 85.71428571428572,
                "actual": "16:7",
                "closest": "2:1"
            },
            "height": 105,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8307/7923050590_a21cd8056c_m.jpg",
            "width": 240
        },
        {
            "aspectratio": {
                "accuracy": 85.71428571428572,
                "actual": "16:7",
                "closest": "2:1"
            },
            "height": 140,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8307/7923050590_a21cd8056c_n.jpg",
            "width": 320
        },
        {
            "aspectratio": {
                "accuracy": 85.84474885844749,
                "actual": "500:219",
                "closest": "2:1"
            },
            "height": 219,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8307/7923050590_a21cd8056c.jpg",
            "width": 500
        },
        {
            "aspectratio": {
                "accuracy": 85.71428571428572,
                "actual": "16:7",
                "closest": "2:1"
            },
            "height": 280,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8307/7923050590_a21cd8056c_z.jpg",
            "width": 640
        },
        {
            "aspectratio": {
                "accuracy": 85.71428571428572,
                "actual": "16:7",
                "closest": "2:1"
            },
            "height": 350,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8307/7923050590_a21cd8056c_c.jpg",
            "width": 800
        },
        {
            "aspectratio": {
                "accuracy": 85.71428571428572,
                "actual": "16:7",
                "closest": "2:1"
            },
            "height": 448,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8307/7923050590_a21cd8056c_b.jpg",
            "width": 1024
        },
        {
            "aspectratio": {
                "accuracy": 85.71428571428572,
                "actual": "16:7",
                "closest": "2:1"
            },
            "height": 700,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8307/7923050590_c2565cdfad_h.jpg",
            "width": 1600
        },
        {
            "aspectratio": {
                "accuracy": 85.71428571428572,
                "actual": "16:7",
                "closest": "2:1"
            },
            "height": 896,
            "mimetype": "image/jpeg",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8307/7923050590_162d403f4a_k.jpg",
            "width": 2048
        },
        {
            "aspectratio": {
                "accuracy": 85.71428571428572,
                "actual": "16:7",
                "closest": "2:1"
            },
            "height": 896,
            "mimetype": "image/png",
            "resize": "fit",
            "type": 0,
            "url": "https://farm9.staticflickr.com/8307/7923050590_bd0afb7966_o.png",
            "width": 2048
        }
    ],
    "taggedpeople": [],
    "type": 0,
    "updateddate": 1403730730000,
    "videofileentityid": "",
    "videofilerelativepath": "",
    "videofileurl": "",
    "accountentityid": "12_41986181@N07"
}
]
""".data(using: .utf8)!
        do {
            let decoder = PostMedia.decoder
            let media = try decoder.decode([PostMedia].self, from: data)
            XCTAssertNotNil(media)
            XCTAssert(media.count == 3, "Expected 3 Media, got \(media.count)")
        }
        catch {
            XCTFail("Unable to parse json to Flickr media array: \(error)")
        }
    }
    
    func testTwitterMedia() {
        let data = """
[
{
      "type":0,
      "baseid":"3_3075118228_665112695931166720",
      "cameramodelentityid":"",
      "commentcount":0,
      "commententityid":"",
      "createddate":1447430428000,
      "description":"",
      "displayshorturl":"https://t.co/rHvOK6zehk",
      "displayurlindexend":124,
      "displayurlindexstart":101,
      "entityid":"3_3075118228_665112695931166720",
      "filter":"",
      "imagefileentityid":"",
      "imagefilerelativepath":"",
      "imagefileurl":"https://pbs.twimg.com/media/CTr0eRiUYAAO3gQ.jpg",
      "interestscore":0,
      "itemlicenceentityid":"",
      "latitude":0,
      "likecount":0,
      "link":"pic.twitter.com/rHvOK6zehk",
      "locationentityid":"",
      "longitude":0,
      "mediaalbumname":"",
      "mediaid":"665112695931166720",
      "mediaobjectid":"665112695931166720",
      "mediaobjectlikeid":"",
      "name":"Oh Mog! What a Calamity. #ChristmasIsForSharing Buy the book by Judith Kerr: https://t.co/SY7wlbjtx2 https://t.co/rHvOK6zehk",
      "originatortype":5,
      "personentityid":"3_3075118228_80685646",
      "personfilerelativepath":"",
      "personfileurl":"https://pbs.twimg.com/profile_images/1061769373965320193/H_zQJUsY_normal.jpg",
      "personfullname":"Sainsbury's",
      "personusername":"sainsburys",
      "postentityid":"3_3075118228_665197548286545920",
      "resources":[
         {
            "aspectratio":{
               "accuracy":100,
               "actual":"1:1",
               "closest":"1:1"
            },
            "height":150,
            "mimetype":"image/jpeg",
            "resize":"crop",
            "type":0,
            "url":"https://pbs.twimg.com/media/CTr0eRiUYAAO3gQ.jpg:thumb",
            "width":150
         },
         {
            "aspectratio":{
               "accuracy":100,
               "actual":"2:1",
               "closest":"2:1"
            },
            "height":512,
            "mimetype":"image/jpeg",
            "resize":"fit",
            "type":0,
            "url":"https://pbs.twimg.com/media/CTr0eRiUYAAO3gQ.jpg:medium",
            "width":1024
         },
         {
            "aspectratio":{
               "accuracy":100,
               "actual":"2:1",
               "closest":"2:1"
            },
            "height":512,
            "mimetype":"image/jpeg",
            "resize":"fit",
            "type":0,
            "url":"https://pbs.twimg.com/media/CTr0eRiUYAAO3gQ.jpg:large",
            "width":1024
         },
         {
            "aspectratio":{
               "accuracy":100,
               "actual":"2:1",
               "closest":"2:1"
            },
            "height":340,
            "mimetype":"image/jpeg",
            "resize":"fit",
            "type":0,
            "url":"https://pbs.twimg.com/media/CTr0eRiUYAAO3gQ.jpg:small",
            "width":680
         }
      ],
      "tagcount":0,
      "taggedpeoplecount":0,
      "updateddate":1447430428000,
      "videofileentityid":"",
      "videofilerelativepath":null,
      "videofileurl":null,
      "accountentityid":"3_3075118228"
},
{
      "type":0,
      "baseid":"3_3075118228_664820252572692480",
      "cameramodelentityid":"",
      "commentcount":0,
      "commententityid":"",
      "createddate":1447340476000,
      "description":"",
      "displayshorturl":"https://t.co/I57LuOGPbl",
      "displayurlindexend":138,
      "displayurlindexstart":115,
      "entityid":"3_3075118228_664820252572692480",
      "filter":"",
      "imagefileentityid":"",
      "imagefilerelativepath":"",
      "imagefileurl":"https://pbs.twimg.com/media/CTnqf1IUsAAHH1E.jpg",
      "interestscore":0,
      "itemlicenceentityid":"",
      "latitude":0,
      "likecount":0,
      "link":"pic.twitter.com/I57LuOGPbl",
      "locationentityid":"",
      "longitude":0,
      "mediaalbumname":"",
      "mediaid":"664820252572692480",
      "mediaobjectid":"664820252572692480",
      "mediaobjectlikeid":"",
      "name":"Is it my imagination, or does Archers National Park have the most gathering of stars? @NikonUSA #arches #starfield https://t.co/I57LuOGPbl",
      "originatortype":5,
      "personentityid":"3_3075118228_3002047546",
      "personfilerelativepath":"",
      "personfileurl":"https://pbs.twimg.com/profile_images/642352313600860162/X6irxO6g_normal.jpg",
      "personfullname":"Dave Black",
      "personusername":"daveblackphoto",
      "postentityid":"3_3075118228_664820260214673410",
      "resources":[
         {
            "aspectratio":{
               "accuracy":86.53846153846155,
               "actual":"20:13",
               "closest":"16:9"
            },
            "height":650,
            "mimetype":"image/jpeg",
            "resize":"fit",
            "type":0,
            "url":"https://pbs.twimg.com/media/CTnqf1IUsAAHH1E.jpg:medium",
            "width":1000
         },
         {
            "aspectratio":{
               "accuracy":100,
               "actual":"1:1",
               "closest":"1:1"
            },
            "height":150,
            "mimetype":"image/jpeg",
            "resize":"crop",
            "type":0,
            "url":"https://pbs.twimg.com/media/CTnqf1IUsAAHH1E.jpg:thumb",
            "width":150
         },
         {
            "aspectratio":{
               "accuracy":86.53846153846155,
               "actual":"20:13",
               "closest":"16:9"
            },
            "height":442,
            "mimetype":"image/jpeg",
            "resize":"fit",
            "type":0,
            "url":"https://pbs.twimg.com/media/CTnqf1IUsAAHH1E.jpg:small",
            "width":680
         },
         {
            "aspectratio":{
               "accuracy":86.53846153846155,
               "actual":"20:13",
               "closest":"16:9"
            },
            "height":650,
            "mimetype":"image/jpeg",
            "resize":"fit",
            "type":0,
            "url":"https://pbs.twimg.com/media/CTnqf1IUsAAHH1E.jpg:large",
            "width":1000
         }
      ],
      "tagcount":0,
      "taggedpeoplecount":0,
      "updateddate":1447340476000,
      "videofileentityid":"",
      "videofilerelativepath":null,
      "videofileurl":null,
      "accountentityid":"3_3075118228"
},
{
      "type":0,
      "baseid":"3_3075118228_710422139237756928",
      "cameramodelentityid":"",
      "commentcount":0,
      "commententityid":"",
      "createddate":1458212812000,
      "description":"",
      "displayshorturl":"https://t.co/H8O1nse3Gf",
      "displayurlindexend":57,
      "displayurlindexstart":34,
      "entityid":"3_3075118228_710422139237756928",
      "filter":"",
      "imagefileentityid":"",
      "imagefilerelativepath":"",
      "imagefileurl":"https://pbs.twimg.com/media/CdvtK_HW8AAETFB.jpg",
      "interestscore":0,
      "itemlicenceentityid":"",
      "latitude":0,
      "likecount":0,
      "link":"pic.twitter.com/H8O1nse3Gf",
      "locationentityid":"",
      "longitude":0,
      "mediaalbumname":"",
      "mediaid":"710422139237756928",
      "mediaobjectid":"710422139237756928",
      "mediaobjectlikeid":"",
      "name":"Nikon d5. Testing multiphoto post https://t.co/H8O1nse3Gf",
      "originatortype":5,
      "personentityid":"3_3075118228_3075118228",
      "personfilerelativepath":"",
      "personfileurl":"https://pbs.twimg.com/profile_images/998493072747999232/A-cfMrC__normal.jpg",
      "personfullname":"Alex Hamilton",
      "personusername":"alexdigime",
      "postentityid":"3_3075118228_710422143436247040",
      "resources":[
         {
            "aspectratio":{
               "accuracy":100,
               "actual":"1:1",
               "closest":"1:1"
            },
            "height":150,
            "mimetype":"image/jpeg",
            "resize":"crop",
            "type":0,
            "url":"https://pbs.twimg.com/media/CdvtK_HW8AAETFB.jpg:thumb",
            "width":150
         },
         {
            "aspectratio":{
               "accuracy":97.5609756097561,
               "actual":"80:41",
               "closest":"2:1"
            },
            "height":492,
            "mimetype":"image/jpeg",
            "resize":"fit",
            "type":0,
            "url":"https://pbs.twimg.com/media/CdvtK_HW8AAETFB.jpg:medium",
            "width":960
         },
         {
            "aspectratio":{
               "accuracy":97.42120343839542,
               "actual":"680:349",
               "closest":"2:1"
            },
            "height":349,
            "mimetype":"image/jpeg",
            "resize":"fit",
            "type":0,
            "url":"https://pbs.twimg.com/media/CdvtK_HW8AAETFB.jpg:small",
            "width":680
         },
         {
            "aspectratio":{
               "accuracy":97.5609756097561,
               "actual":"80:41",
               "closest":"2:1"
            },
            "height":492,
            "mimetype":"image/jpeg",
            "resize":"fit",
            "type":0,
            "url":"https://pbs.twimg.com/media/CdvtK_HW8AAETFB.jpg:large",
            "width":960
         }
      ],
      "tagcount":0,
      "taggedpeoplecount":0,
      "updateddate":1458212812000,
      "videofileentityid":"",
      "videofilerelativepath":null,
      "videofileurl":null,
      "accountentityid":"3_3075118228"
}
]
""".data(using: .utf8)!
        do {
            let decoder = PostMedia.decoder
            let media = try decoder.decode([PostMedia].self, from: data)
            XCTAssertNotNil(media)
            XCTAssert(media.count == 3, "Expected 3 Media, got \(media.count)")
        }
        catch {
            XCTFail("Unable to parse json to Twitter media array: \(error)")
        }
    }
    
    func testPinterestMedia() {
        let data = """
[
{
    "baseid": "9_71424344060462614",
    "cameramodelentityid": "",
    "commentcount": 0,
    "commententityid": "",
    "createddate": 1333121181000,
    "description": "",
    "displayshorturl": "",
    "displayurlindexend": 0,
    "displayurlindexstart": 0,
    "entityid": "9_71424344060462614",
    "filter": "",
    "imagefileentityid": "",
    "imagefilerelativepath": "",
    "imagefileurl": "https://i.pinimg.com/originals/ae/cc/e3/aecce3d021372d2f34f7a9ea8d1f248f.jpg",
    "resources": [
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 30,
            "mimetype": "image/jpeg",
            "resize": "crop",
            "type": 0,
            "url": "https://i.pinimg.com/30x30/ae/cc/e3/aecce3d021372d2f34f7a9ea8d1f248f.jpg",
            "width": 30
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 136,
            "mimetype": "image/jpeg",
            "resize": "crop",
            "type": 0,
            "url": "https://i.pinimg.com/136x136/ae/cc/e3/aecce3d021372d2f34f7a9ea8d1f248f.jpg",
            "width": 136
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 70,
            "mimetype": "image/jpeg",
            "resize": "crop",
            "type": 0,
            "url": "https://i.pinimg.com/70x70/ae/cc/e3/aecce3d021372d2f34f7a9ea8d1f248f.jpg",
            "width": 70
        },
        {
            "aspectratio": {
                "accuracy": 90.45226130653268,
                "actual": "320:199",
                "closest": "16:9"
            },
            "height": 398,
            "mimetype": "image/jpeg",
            "resize": "crop",
            "type": 0,
            "url": "https://i.pinimg.com/originals/ae/cc/e3/aecce3d021372d2f34f7a9ea8d1f248f.jpg",
            "width": 640
        }
    ],
    "interestscore": 0,
    "itemlicenceentityid": "",
    "latitude": 0,
    "likecount": 0,
    "link": "https://www.pinterest.com/pin/71424344060462614/",
    "locationentityid": "",
    "longitude": 0,
    "mediaalbumname": "Cool Stuff",
    "mediaid": "71424344060462614",
    "mediaobjectid": "71424344060462614",
    "mediaobjectlikeid": "",
    "name": "#WorldBackupDay is March 31st! Is your online social life worth saving? Should we add Pinterest to SocialSafe?",
    "originatortype": 0,
    "personentityid": "9_71424481498761696_71424481498761696",
    "personfilerelativepath": "",
    "personfileurl": "https://i.pinimg.com/280x280_RS/8a/c7/29/8ac72969ee72028cf54cf03f1479be7c.jpg",
    "personfullname": "Pascal Wheeler",
    "personusername": "pasalot",
    "postentityid": "9_71424481498761696_71424344060462614",
    "tagcount": 0,
    "taggedpeoplecount": 0,
    "type": 0,
    "updateddate": 1333121181000,
    "videofileentityid": "",
    "videofilerelativepath": "",
    "videofileurl": "",
    "accountentityid": "9_71424481498761696"
},
{
    "baseid": "9_71424344060462601",
    "cameramodelentityid": "",
    "commentcount": 0,
    "commententityid": "",
    "createddate": 1333120772000,
    "description": "",
    "displayshorturl": "",
    "displayurlindexend": 0,
    "displayurlindexstart": 0,
    "entityid": "9_71424344060462601",
    "filter": "",
    "imagefileentityid": "",
    "imagefilerelativepath": "",
    "imagefileurl": "https://i.pinimg.com/originals/5e/a2/ea/5ea2ea67f6ff0705c49fc963c8a8bd29.jpg",
    "resources": [
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 30,
            "mimetype": "image/jpeg",
            "resize": "crop",
            "type": 0,
            "url": "https://i.pinimg.com/30x30/5e/a2/ea/5ea2ea67f6ff0705c49fc963c8a8bd29.jpg",
            "width": 30
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 136,
            "mimetype": "image/jpeg",
            "resize": "crop",
            "type": 0,
            "url": "https://i.pinimg.com/136x136/5e/a2/ea/5ea2ea67f6ff0705c49fc963c8a8bd29.jpg",
            "width": 136
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 70,
            "mimetype": "image/jpeg",
            "resize": "crop",
            "type": 0,
            "url": "https://i.pinimg.com/70x70/5e/a2/ea/5ea2ea67f6ff0705c49fc963c8a8bd29.jpg",
            "width": 70
        },
        {
            "aspectratio": {
                "accuracy": 85.9857482185273,
                "actual": "640:421",
                "closest": "4:3"
            },
            "height": 421,
            "mimetype": "image/jpeg",
            "resize": "crop",
            "type": 0,
            "url": "https://i.pinimg.com/originals/5e/a2/ea/5ea2ea67f6ff0705c49fc963c8a8bd29.jpg",
            "width": 640
        }
    ],
    "interestscore": 0,
    "itemlicenceentityid": "",
    "latitude": 0,
    "likecount": 0,
    "link": "https://www.pinterest.com/pin/71424344060462601/",
    "locationentityid": "",
    "longitude": 0,
    "mediaalbumname": "Glorious Food",
    "mediaid": "71424344060462601",
    "mediaobjectid": "71424344060462601",
    "mediaobjectlikeid": "",
    "name": "Green Chile Macaroni and Cheese",
    "originatortype": 0,
    "personentityid": "9_71424481498761696_71424481498761696",
    "personfilerelativepath": "",
    "personfileurl": "https://i.pinimg.com/280x280_RS/8a/c7/29/8ac72969ee72028cf54cf03f1479be7c.jpg",
    "personfullname": "Pascal Wheeler",
    "personusername": "pasalot",
    "postentityid": "9_71424481498761696_71424344060462601",
    "tagcount": 0,
    "taggedpeoplecount": 0,
    "type": 0,
    "updateddate": 1333120772000,
    "videofileentityid": "",
    "videofilerelativepath": "",
    "videofileurl": "",
    "accountentityid": "9_71424481498761696"
},
{
    "baseid": "9_71424344060462576",
    "cameramodelentityid": "",
    "commentcount": 0,
    "commententityid": "",
    "createddate": 1333120345000,
    "description": "",
    "displayshorturl": "",
    "displayurlindexend": 0,
    "displayurlindexstart": 0,
    "entityid": "9_71424344060462576",
    "filter": "",
    "imagefileentityid": "",
    "imagefilerelativepath": "",
    "imagefileurl": "https://i.pinimg.com/originals/46/d5/1d/46d51d0dab540f8ad954296e62a6b436.jpg",
    "resources": [
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 30,
            "mimetype": "image/jpeg",
            "resize": "crop",
            "type": 0,
            "url": "https://i.pinimg.com/30x30/46/d5/1d/46d51d0dab540f8ad954296e62a6b436.jpg",
            "width": 30
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 136,
            "mimetype": "image/jpeg",
            "resize": "crop",
            "type": 0,
            "url": "https://i.pinimg.com/136x136/46/d5/1d/46d51d0dab540f8ad954296e62a6b436.jpg",
            "width": 136
        },
        {
            "aspectratio": {
                "accuracy": 100,
                "actual": "1:1",
                "closest": "1:1"
            },
            "height": 70,
            "mimetype": "image/jpeg",
            "resize": "crop",
            "type": 0,
            "url": "https://i.pinimg.com/70x70/46/d5/1d/46d51d0dab540f8ad954296e62a6b436.jpg",
            "width": 70
        },
        {
            "aspectratio": {
                "accuracy": 29.090909090909093,
                "actual": "16:55",
                "closest": "1:1"
            },
            "height": 2750,
            "mimetype": "image/jpeg",
            "resize": "crop",
            "type": 0,
            "url": "https://i.pinimg.com/originals/46/d5/1d/46d51d0dab540f8ad954296e62a6b436.jpg",
            "width": 800
        }
    ],
    "interestscore": 0,
    "itemlicenceentityid": "",
    "latitude": 0,
    "likecount": 0,
    "link": "https://www.pinterest.com/pin/71424344060462576/",
    "locationentityid": "",
    "longitude": 0,
    "mediaalbumname": "Cool Stuff",
    "mediaid": "71424344060462576",
    "mediaobjectid": "71424344060462576",
    "mediaobjectlikeid": "",
    "name": "#WorldBackupDay is March 31st! Great time to check out one of my apps: http://socialsafe.net (it backs up your Facebook, Twitter, LinkedIn & other accounts) :)",
    "originatortype": 0,
    "personentityid": "9_71424481498761696_71424481498761696",
    "personfilerelativepath": "",
    "personfileurl": "https://i.pinimg.com/280x280_RS/8a/c7/29/8ac72969ee72028cf54cf03f1479be7c.jpg",
    "personfullname": "Pascal Wheeler",
    "personusername": "pasalot",
    "postentityid": "9_71424481498761696_71424344060462576",
    "tagcount": 0,
    "taggedpeoplecount": 0,
    "type": 0,
    "updateddate": 1333120345000,
    "videofileentityid": "",
    "videofilerelativepath": "",
    "videofileurl": "",
    "accountentityid": "9_71424481498761696"
}
]
""".data(using: .utf8)!
        do {
            let decoder = PostMedia.decoder
            let media = try decoder.decode([PostMedia].self, from: data)
            XCTAssertNotNil(media)
            XCTAssert(media.count == 3, "Expected 3 Media, got \(media.count)")
        }
        catch {
            XCTFail("Unable to parse json to Pinterest media array: \(error)")
        }
    }
}
