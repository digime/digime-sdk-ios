//
//  CommentTests.swift
//  DigiMeRepository_Tests
//
//  Created on 11/12/2018.
//  Copyright © 2018 digi.me Ltd. All rights reserved.
//

@testable import DigiMeSDK
import XCTest

class CommentTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Setup code here.
    }
    
    override func tearDown() {
        // Teardown code here.
        super.tearDown()
    }
    
    func testDecodeSingle() {
        
        let json =
            [
                "accountentityid": "1_1078609952155745",
                "appid": "",
                "baseid": "1_1078609952155745_1762515263765207_1762526430430757_2",
                "commentcount": 0,
                "commentid": "1762515263765207_1762526430430757",
                "commentreplyid": "",
                "createddate": 1500460822000,
                "updateddate": 1500460823000,
                "entityid": "1_1078609952155745_1762515263765207_1762526430430757_2",
                "likecount": 0,
                "link": "",
                "metaid": "",
                "personentityid": "1_1078609952155745_1078609952155745",
                "personfilerelativepath": "",
                "personfileurl": "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773841&hash=AeSWtZlUbqxh3FfO",
                "personfullname": "Alex Hamilton",
                "personusername": "Alex Hamilton",
                "privacy": 0,
                "referenceentityid": "1_1078609952155745_1078609952155745_1762515263765207",
                "referenceentitytype": 2,
                "socialnetworkuserentityid": "1_1078609952155745",
                "text": "Mmmm... 👌🏻😃"
                ] as [String: Any]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            let decoder = Comment.decoder
            let comment = try decoder.decode(Comment.self, from: data)
            
            var expectedDate = Date(timeIntervalSince1970: 1500460822000 / 1000)
            XCTAssert(comment.createdDate == expectedDate, "Expected createdDate: \(expectedDate) got \(comment.createdDate)")

            XCTAssert(comment.accountIdentifier == "1_1078609952155745", "Expected 'accountIdentifier': '1_1078609952155745' got \(comment.accountIdentifier)")
            XCTAssert(comment.identifier == "1_1078609952155745_1762515263765207_1762526430430757_2", "Expected 'identifier': '1_1078609952155745_1762515263765207_1762526430430757_2' got \(comment.identifier)")
            XCTAssert(comment.personEntityId == "1_1078609952155745_1078609952155745", "Expected 'personEntityId': '1_1078609952155745_1078609952155745' got \(comment.personEntityId)")
            XCTAssert(comment.baseId == "1_1078609952155745_1762515263765207_1762526430430757_2", "Expected 'baseId': '1_1078609952155745_1762515263765207_1762526430430757_2' got \(comment.baseId)")
            XCTAssert(comment.referenceEntityId == "1_1078609952155745_1078609952155745_1762515263765207", "Expected 'referenceEntityId': '1_1078609952155745_1078609952155745_1762515263765207' got \(comment.referenceEntityId)")
            XCTAssert(comment.commentId == "1762515263765207_1762526430430757", "Expected 'commentId': '1762515263765207_1762526430430757' got \(comment.commentId)")
            XCTAssert(comment.personUsername == "Alex Hamilton", "Expected 'personUsername': 'Alex Hamilton' got \(comment.personUsername)")

            XCTAssert(comment.referenceEntityType == 2, "Expected 'referenceEntityType': '2' got \(comment.referenceEntityType)")
            XCTAssert(comment.privacy == 0, "Expected 'privacy': '0' got \(comment.privacy)")

            // optionals
            if let optionalUpdatedDate = comment.updatedDate {
                expectedDate = Date(timeIntervalSince1970: 1500460823000 / 1000)
                XCTAssert(optionalUpdatedDate == expectedDate, "Expected updatedDate: \(expectedDate) got \(optionalUpdatedDate)")
            }
            if let optionalSocialNetworkUserEntityId = comment.socialNetworkUserEntityId {
                XCTAssert(optionalSocialNetworkUserEntityId == "1_1078609952155745", "Expected 'socialNetworkUserEntityId': '1_1078609952155745' got \(optionalSocialNetworkUserEntityId)")
            }
            if let optionalPersonFileUrl = comment.personFileUrl {
                XCTAssert(optionalPersonFileUrl == "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773841&hash=AeSWtZlUbqxh3FfO", "Expected 'personFileUrl': 'https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773841&hash=AeSWtZlUbqxh3FfO' got \(optionalPersonFileUrl)")
            }
            if let optionalPersonFullname = comment.personFullname {
                XCTAssert(optionalPersonFullname == "Alex Hamilton", "Expected 'personFullname': 'Alex Hamilton' got \(optionalPersonFullname)")
            }
            if let optionalText = comment.text {
                XCTAssert(optionalText == "Mmmm... 👌🏻😃", "Expected 'text': 'Mmmm... 👌🏻😃' got \(optionalText)")
            }
            if let optionalCommentCount = comment.commentCount {
                XCTAssert(optionalCommentCount == 0, "Expected 'commentCount': '0' got \(optionalCommentCount)")
            }
            if let optionalLikeCount = comment.likeCount {
                XCTAssert(optionalLikeCount == 0, "Expected 'likeCount': '0' got \(optionalLikeCount)")
            }
            if let optionalUserReaction = comment.userReaction {
                XCTAssertNotNil(optionalUserReaction)
            }
            if let optionalCommentReplyId = comment.commentReplyId {
                XCTAssertNotNil(optionalCommentReplyId)
            }
            if let optionalLink = comment.link {
                XCTAssertNotNil(optionalLink)
            }
            if let optionalMetaId = comment.metaId {
                XCTAssertNotNil(optionalMetaId)
            }
            if let optionalAppId = comment.appId {
                XCTAssertNotNil(optionalAppId)
            }
            if let optionalPersonFileRelativePath = comment.personFileRelativePath {
                XCTAssertNotNil(optionalPersonFileRelativePath)
            }
        }
        catch {
            XCTFail("Unable to parse json Comment: \(error)")
        }
    }
    
    func testFacebookComments() {
        let data = """
[
{
    "accountentityid": "1_1078609952155745",
    "appid": "",
    "baseid": "1_1078609952155745_1750489751634425_1751050398245027_2",
    "commentcount": 0,
    "commentid": "1750489751634425_1751050398245027",
    "commentreplyid": "",
    "createddate": 1499637890000,
    "entityid": "1_1078609952155745_1750489751634425_1751050398245027_2",
    "likecount": 1,
    "link": "",
    "metaid": "",
    "personentityid": "1_1078609952155745_1078609952155745",
    "personfilerelativepath": "",
    "personfileurl": "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773842&hash=AeSFl_EdXhASqt5v",
    "personfullname": "Alex Hamilton",
    "personusername": "Alex Hamilton",
    "privacy": 0,
    "referenceentityid": "1_1078609952155745_1078609952155745_1750489751634425",
    "referenceentitytype": 2,
    "socialnetworkuserentityid": "1_1078609952155745",
    "text": "Да, вчера делал вечернюю пробежку и увидел цветочек. Утром поехал и сфотографировал его"
},
{
    "accountentityid": "1_1078609952155745",
    "appid": "",
    "baseid": "1_1078609952155745_1750489751634425_1751463451537055_2",
    "commentcount": 0,
    "commentid": "1750489751634425_1751463451537055",
    "commentreplyid": "",
    "createddate": 1499673853000,
    "entityid": "1_1078609952155745_1750489751634425_1751463451537055_2",
    "likecount": 0,
    "link": "",
    "metaid": "",
    "personentityid": "1_1078609952155745_1078609952155745",
    "personfilerelativepath": "",
    "personfileurl": "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773842&hash=AeSFl_EdXhASqt5v",
    "personfullname": "Alex Hamilton",
    "personusername": "Alex Hamilton",
    "privacy": 0,
    "referenceentityid": "1_1078609952155745_1078609952155745_1750489751634425",
    "referenceentitytype": 2,
    "socialnetworkuserentityid": "1_1078609952155745",
    "text": "Утром сегодня проезжал мимо и уже нет цветочка, сволочи, затоптали..."
},
{
    "accountentityid": "1_1078609952155745",
    "appid": "",
    "baseid": "1_1078609952155745_1750489751634425_1752535564763177_2",
    "commentcount": 0,
    "commentid": "1750489751634425_1752535564763177",
    "commentreplyid": "",
    "createddate": 1499758989000,
    "entityid": "1_1078609952155745_1750489751634425_1752535564763177_2",
    "likecount": 2,
    "link": "",
    "metaid": "",
    "personentityid": "1_1078609952155745_1078609952155745",
    "personfilerelativepath": "",
    "personfileurl": "https://platform-lookaside.fbsbx.com/platform/profilepic/?asid=1078609952155745&height=200&width=200&ext=1546773842&hash=AeSFl_EdXhASqt5v",
    "personfullname": "Alex Hamilton",
    "personusername": "Alex Hamilton",
    "privacy": 0,
    "referenceentityid": "1_1078609952155745_1078609952155745_1750489751634425",
    "referenceentitytype": 2,
    "socialnetworkuserentityid": "1_1078609952155745",
    "text": "Ну, да. Увековечил его в истории... :-)"
}
]
""".data(using: .utf8)!
        do {
            let decoder = Comment.decoder
            let comments = try decoder.decode([Comment].self, from: data)
            XCTAssertNotNil(comments)
            XCTAssert(comments.count == 3, "Expected 3 Comments, got \(comments.count)")
        }
        catch {
            XCTFail("Unable to parse json to Facebook comments array: \(error)")
        }
    }
    
    func testInstagramComments() {
        let data = """
[
{
    "appid": "",
    "baseid": "4_1758145925_17844096295097236",
    "commentcount": 0,
    "commentid": "17844096295097236",
    "commentreplyid": "",
    "createddate": 1454000622000,
    "entityid": "4_1758145925_17844096295097236",
    "likecount": 0,
    "link": "",
    "metaid": "",
    "personentityid": "4_1758145925_9db243b0fe3818a570b25d80125931fd",
    "personfilerelativepath": "",
    "personfileurl": "",
    "personfullname": "",
    "personusername": "alexdigime",
    "privacy": 0,
    "referenceentityid": "4_1172539312144546244_1758145925",
    "referenceentitytype": 1,
    "socialnetworkuserentityid": "4_1758145925",
    "text": "7th",
    "updateddate": 1454000622000,
    "accountentityid": "4_1758145925"
},
{
    "appid": "",
    "baseid": "4_1758145925_17853811756001926",
    "commentcount": 0,
    "commentid": "17853811756001926",
    "commentreplyid": "",
    "createddate": 1453996702000,
    "entityid": "4_1758145925_17853811756001926",
    "likecount": 0,
    "link": "",
    "metaid": "",
    "personentityid": "4_1758145925_9db243b0fe3818a570b25d80125931fd",
    "personfilerelativepath": "",
    "personfileurl": "",
    "personfullname": "",
    "personusername": "alexdigime",
    "privacy": 0,
    "referenceentityid": "4_954283860282997757_1758145925",
    "referenceentitytype": 1,
    "socialnetworkuserentityid": "4_1758145925",
    "text": "Test message",
    "updateddate": 1453996702000,
    "accountentityid": "4_1758145925"
},
{
    "appid": "",
    "baseid": "4_1758145925_17853811894001926",
    "commentcount": 0,
    "commentid": "17853811894001926",
    "commentreplyid": "",
    "createddate": 1453997373000,
    "entityid": "4_1758145925_17853811894001926",
    "likecount": 0,
    "link": "",
    "metaid": "",
    "personentityid": "4_1758145925_9db243b0fe3818a570b25d80125931fd",
    "personfilerelativepath": "",
    "personfileurl": "",
    "personfullname": "",
    "personusername": "alexdigime",
    "privacy": 0,
    "referenceentityid": "4_954283860282997757_1758145925",
    "referenceentitytype": 1,
    "socialnetworkuserentityid": "4_1758145925",
    "text": "Second test comment",
    "updateddate": 1453997373000,
    "accountentityid": "4_1758145925"
}
]
""".data(using: .utf8)!
        do {
            let decoder = Comment.decoder
            let comments = try decoder.decode([Comment].self, from: data)
            XCTAssertNotNil(comments)
            XCTAssert(comments.count == 3, "Expected 3 Comments, got \(comments.count)")
        }
        catch {
            XCTFail("Unable to parse json to Instagram comments array: \(error)")
        }
    }
    
    func testFlickrComments() {
        let data = """
[
{
    "baseid": "12_41986181@N07_131427615-16779097468-72157655643160065",
    "commentid": "131427615-16779097468-72157655643160065",
    "commentreplyid": "",
    "createddate": 1436395156000,
    "entityid": "12_41986181@N07_131427615-16779097468-72157655643160065",
    "link": "https://www.flickr.com/photos/131432955@N05/16779097468/#comment72157655643160065",
    "personentityid": "12_41986181@N07_78517152@N06",
    "personfilerelativepath": "",
    "personfileurl": "http://farm5.staticflickr.com/4459/buddyicons/78517152@N06.jpg",
    "personfullname": "Tommy from Stanley DH9",
    "personusername": "Tommy from Stanley DH9",
    "privacy": 0,
    "referenceentityid": "12_16779097468",
    "referenceentitytype": 1,
    "socialnetworkuserentityid": "12_41986181@N07",
    "text": "I could actually live without a TV, it's music that I couldn't live without ;)",
    "accountentityid": "12_41986181@N07"
},
{
    "baseid": "12_41986181@N07_131427615-16779097468-72157656013896102",
    "commentid": "131427615-16779097468-72157656013896102",
    "commentreplyid": "",
    "createddate": 1437228563000,
    "entityid": "12_41986181@N07_131427615-16779097468-72157656013896102",
    "link": "https://www.flickr.com/photos/131432955@N05/16779097468/#comment72157656013896102",
    "personentityid": "12_41986181@N07_80797114@N06",
    "personfilerelativepath": "",
    "personfileurl": "http://farm9.staticflickr.com/8617/buddyicons/80797114@N06.jpg",
    "personfullname": "",
    "personusername": "Dean ( jamiedeanfilms@gmail.com )Website:https://w",
    "privacy": 0,
    "referenceentityid": "12_16779097468",
    "referenceentitytype": 1,
    "socialnetworkuserentityid": "12_41986181@N07",
    "text": "Love your fabulous work !",
    "accountentityid": "12_41986181@N07"
},
{
    "baseid": "12_41986181@N07_131427615-16779097468-72157655635239140",
    "commentid": "131427615-16779097468-72157655635239140",
    "commentreplyid": "",
    "createddate": 1437256162000,
    "entityid": "12_41986181@N07_131427615-16779097468-72157655635239140",
    "link": "https://www.flickr.com/photos/131432955@N05/16779097468/#comment72157655635239140",
    "personentityid": "12_41986181@N07_131432955@N05",
    "personfilerelativepath": "",
    "personfileurl": "http://farm4.staticflickr.com/3822/buddyicons/131432955@N05.jpg",
    "personfullname": "Dorothée Deppner",
    "personusername": "dorothée_deppner",
    "privacy": 0,
    "referenceentityid": "12_16779097468",
    "referenceentitytype": 1,
    "socialnetworkuserentityid": "12_41986181@N07",
    "text": "Thank you!",
    "accountentityid": "12_41986181@N07"
}
]
""".data(using: .utf8)!
        do {
            let decoder = Comment.decoder
            let comments = try decoder.decode([Comment].self, from: data)
            XCTAssertNotNil(comments)
            XCTAssert(comments.count == 3, "Expected 3 Comments, got \(comments.count)")
        }
        catch {
            XCTFail("Unable to parse json to Flickr comments array: \(error)")
        }
    }
}
