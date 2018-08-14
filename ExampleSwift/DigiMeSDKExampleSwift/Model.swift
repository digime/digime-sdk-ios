//
//  Model.swift
//  DigiMeSDKExampleSwift
//
//  Created on 13/08/2018.
//  Copyright © 2018 digi.me. All rights reserved.
//

import Foundation

#if TIMING

enum ContractType: Int, EnumCollection {
    case oneoff = 0
    case ongoing
    
    var title: String {
        switch self {
        case .oneoff:
            return "One Off"
        case .ongoing:
            return "Ongoing"
        }
    }
}

enum GroupType: Int, EnumCollection {
    case social = 0
    case music
    case medical
    case government
    case fitness
    case finance
    
    var title: String {
        switch self {
        case .social:
            return "Social"
        case .music:
            return "Music"
        case .medical:
            return "Medical"
        case .government:
            return "Government"
        case .fitness:
            return "Fitness"
        case .finance:
            return "Finance"
        }
    }
    
    var ongoingProdContractId: String {
        switch self {
        case .social:
            return "YaoDpBkEEgSiZfm3BhkmysbfEWve5dDB"
        case .music:
            return "VhPpOkU9LPmygrOW0PdfrxmovoyGMfdg"
        case .medical:
            return "tqj6jsK08XSwZXYRJFfF63MKS59z2ZEC"
        case .government:
            return "bX22qjpnkmU7VJK50bHhiVYm3yWZwa6j"
        case .fitness:
            return "BvWqT8LssVaSijZbARgiy8T45Z0hOTiR"
        case .finance:
            return "Ey4Ri2sDsoV6kkOvGtmRV8abf4CYOOnZ"
        }
    }
    
    var ongoingDevContractId: String {
        switch self {
        case .social:
            return "Fe22Tpl7mdHNiwmtU59AFkEKyNgkoj0C"
        case .music:
            return "Ykb8xTqULDtnGhZfKrB1LeZjgTmwtTOx"
        case .medical:
            return "YNOUU21pDxZqMkKlzI1JLCHfvvGIjzEl"
        case .government:
            return "T8n81bS0Yffckd90GgpzS6o9MY9kN9Rm"
        case .fitness:
            return "WD5fqtPPmPQLGQBUIKQBJnvnnn46I9ht"
        case .finance:
            return "To0nNEn2X73PZvJ377Pukn3svsLVWHam"
        }
    }
    
    var oneoffProdContractId: String {
        switch self {
        case .social:
            return "jZTRerONwxJtUpyKldEeccRXmlhWdH3U"
        case .music:
            return "qQKfMQq1hYWCFQfnzRIeLlJzIolgOGOt"
        case .medical:
            return "Ltv3wSgeDGONEd7YV2hHGattRjjep2JR"
        case .government:
            return "cLo4sb9qheoHGsse7BW0I30Iqcq4BiHQ"
        case .fitness:
            return "eOszmNj6Rwo3ZDAYaB1dsMIrcLTkf8s7"
        case .finance:
            return "6Nb3UDFAuvCN8CzgtLqvF3LeWek5yDcb"
        }
    }
    
    var oneoffDevContractId: String {
        switch self {
        case .social:
            return "nNYA0XVHpziotlmhiPuQbEk4VTXKwYkd"
        case .music:
            return "mXOOSb7KYBVWLR7X4EAjlUXN3SZYxweJ"
        case .medical:
            return "Yy6usnGyo70atSglmGlfxWUGvS3qicwH"
        case .government:
            return "YCf4CylemGoTYrHbRhGcRtm41YSYW912"
        case .fitness:
            return "1diojLPlEQ4pNpiyNywPm6GHpzqt9gIz"
        case .finance:
            return "kgxxl3v32xCXCj0cPbJznEFNvSYHP8oV"
        }
    }
}

class ConsentAccessLoggingKeys: NSObject {
    static let timingDataGetAllFiles = "timingDataGetAllFiles"
    static let timingTotal = "timingTotal"
    static let debugAppId = "debugAppId"
    static let debugContractId = "debugContractId"
    static let debugPlatform = "debugPlatform"
    static let productionEnvironment = true
    static let productionAppId = "6vA0xfLk6AysMVCBXdFnpItZrAk0aJtR"
    static let developmentAppId = "6v0KE7p5SxF2ILb2ah2nZxhytzAMqvJN"
}
#endif


