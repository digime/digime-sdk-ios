//
//  MediaTests.swift
//  DigiMeRepository_Tests
//
//  Created on 12/12/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

@testable import DigiMeSDK
import XCTest

class MediaTests: XCTest {
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
//    
//    func testInstagramMedia() {
//        let data = """
//[
//]
//""".data(using: .utf8)!
//        do {
//            let decoder = PostMedia.decoder
//            let media = try decoder.decode([PostMedia].self, from: data)
//            XCTAssertNotNil(media)
//            XCTAssert(media.count == 3, "Expected 3 Media, got \(media.count)")
//        }
//        catch {
//            XCTFail("Unable to parse json to Instagram media array: \(error)")
//        }
//    }
//    
//    func testFlickrMedia() {
//        let data = """
//[
//]
//""".data(using: .utf8)!
//        do {
//            let decoder = PostMedia.decoder
//            let media = try decoder.decode([PostMedia].self, from: data)
//            XCTAssertNotNil(media)
//            XCTAssert(media.count == 3, "Expected 3 Media, got \(media.count)")
//        }
//        catch {
//            XCTFail("Unable to parse json to Flickr media array: \(error)")
//        }
//    }
//    
//    func testTwitterMedia() {
//        let data = """
//[
//]
//""".data(using: .utf8)!
//        do {
//            let decoder = PostMedia.decoder
//            let media = try decoder.decode([PostMedia].self, from: data)
//            XCTAssertNotNil(media)
//            XCTAssert(media.count == 3, "Expected 3 Media, got \(media.count)")
//        }
//        catch {
//            XCTFail("Unable to parse json to Twitter media array: \(error)")
//        }
//    }
//    
//    func testPinterestMedia() {
//        let data = """
//[
//]
//""".data(using: .utf8)!
//        do {
//            let decoder = PostMedia.decoder
//            let media = try decoder.decode([PostMedia].self, from: data)
//            XCTAssertNotNil(media)
//            XCTAssert(media.count == 3, "Expected 3 Media, got \(media.count)")
//        }
//        catch {
//            XCTFail("Unable to parse json to Pinterest media array: \(error)")
//        }
//    }
}
