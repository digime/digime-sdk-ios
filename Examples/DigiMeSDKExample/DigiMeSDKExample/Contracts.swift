//
//  Contracts.swift
//  DigiMeSDKExample
//
//  Created on 24/02/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation

enum Contracts {
    // This contract allows SDK user to read user's social,
    // financial and music data from the past 3 months.
    static let finSocMus = Contract(name: "Social, Music & Financial",
                                    identifier: "DGLxRJiTjKZJvvtDB6timfzw4DHiQwek",
                                    privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEAiM7QAmRiK322Npd0loxxxhIuLZVbc+2JRt7GRgTBG1RoaQ8e
        0DrOVI8xz7XHe6PduoVs+TqZwYPEngGLq1f4+gZuyqeMOpUC5YFGs8QYro9UwJmG
        bKf6ez4uYCMIFroKxRmnP0GrsDEjrvYksmJdQoq3Hg4wT6ZoQeQ2iNy4Z8Y5Jpb8
        9Yuh1kb4vh5y4RJPmWui6yoOclovPOvFal2VmaDz1mgUbOfT5tbkEyKavm3u95d+
        +hcEl9cOrke0G/aq9H2TSWTDqoqq0BKIDYRmGjhzsIB/xHPEqLkuTy3Or5AqRMSu
        70U0R02bF7YjgZ4Ixka3AbE9ZBel2PtmeS6h0QIDAQABAoIBABn7pXf+1sJJ0vSV
        WVhKfkVPKKQRrNfcsmjaYK/lsUNeiaICdCi6MnvO4nf/n051NeR5+NNw9MjTHOGh
        i4RUZf4egKZOogxyRqWOIv57bPCiWkdmISi70o/bpHUv0hZ26Rq8H46dC12gR5Ww
        PBIBKpM7w0GbEkPeaAizrkPaH8/dhXb2Hzkj5X5xrxsq1O8pI/VpSvGDXuJYF8U1
        LOV8d1xJJLS0eHJvfe/5GSIIqEeJsXAzgs7yVOU9YhV0tgLh//lz4jj7xsvfpVOF
        ScefjsgusJecB60+19OBTls/mfADVxG85wXkuCbO0QDPE9ZR2FLyzOcOLMLizWmF
        o617A80CgYEA8q6VfWr3GMQfENW0PAhP+odqNglc8B4/N40ExzX54p0xFz/qtVZw
        7jnPwo+EF5CRz4IwRWw/h10JqrJb85j77oLT/ADRy8+0Zhgp+bo278zxSTodiBhv
        xoa2J3GeiLoed3QCwfp+MEE/gnRclK6SZs3skhBO/0cjvfRD4ulhR9MCgYEAkFDQ
        Md/JpcFStyqpw8s+syIlSYfvyV8MLWcIqMvG9auJKNVmtAhA9lipEy0Tot6DG8d8
        7EtTFKzCa+0jJoNEY+STCRBibyGZgkCGEvHOnab7gPZCu5bnJ/BW3JFhLagAveEG
        2epF2k1xyhQ91zE1aXnsRwFSXlc1QyS4jwknrUsCgYEAw57vabW7kP8me4+IRYv9
        zFkzyHMrs3LuSn0mCN79mypS1Ab1z07qoV2Al7jQJZ6nqrmq54smepsIm8xCSs5a
        5hwXfN+8PaokJNf9ngv5FLwDE6ABBh+Mml8kng78WAKPZILjZjHhXkx6QVJC/qbp
        5GzB8curoiNaMFiiEFtHy3kCgYBmvADZ4FOuWedGWWqs5TznTMF6jPjYQ39putVh
        RF+Id+qWVQRd2RpVxFvoOMinwvtWhTabCCxGpY1qQ1AolH3VFtzNMQrBzgt3u/M1
        /Ul21W5pKeXroMtBlUhgkGW7mMOeaFj2PF4pv8PndW1oibFaOt9G1NwMKMzT1YpE
        2OGT7QKBgB7eLeoem83FmRsdSHX5LqcQL2K/9YRED1OuCCbIIzlRrgXtWFWp3fFv
        ojU7Mub4TWjHLClgifeyJ2rc35gRn7+QWcYgeUjEdncdiAgB914eP81JKeRzufe1
        wpFeXUa88GKAnNy0Rng81omO6kRDW5Bz8ppQbvnjKnUJgu2seSR0
        -----END RSA PRIVATE KEY-----
        """,
                                    timeRanges: [TimeRange.last(amount: 3, unit: .month)]
    )
    
    // This contract allows SDK user to read user's medical
    // and fitness data from the past 3 months.
    static let fitHealth = Contract(name: "Health & Fitness",
                                    identifier: "iB6siPdN5j6yVvv0PYMLiSBqSiq8SAG4",
                                    privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEAiKbIKoTmPrFWiOaGuuUjJXSBUWj/LOC3fhzSF/M7O0C9GP9+
        TGooxS98o6zLPHHkbRDktT1nh5cEagS6vjeCrcrcwlWPGmMMRb1LVE1fIurnzzSb
        /VTogHsKM6Rltzkdd2AFM39q3ALdYi7MiVRlyVWwcr8z8HlM/1XSuX8e26HDt3so
        oITZ3cZbw/P3cgSlDrk6k0knTB7l1v3tb/ulp9wp6k27DK1pbEriWtLeWGvoB8UC
        I/eC9O8clw/nUvMETf2ne18BVBTjQs37NDiNynAyLtDzJuCrsO0KP4LarXn8zoya
        R7Hl7Y+zjQYitupjEupSrlPcshu+UgiTXXBbvQIDAQABAoIBACqGlKY+w5RhBcgG
        zYjeBAkE77WRElA6AoB5oZwYcqdm5zIfWIOZSeTLeWNKQ9kkrGyQpEwOtuhIQ/Rm
        UmMdzUoeZoMHs0gH6OrPFOFATsoEBm3CNoUo5k4NfEhD8e+KE7Rxqkyza2LadWC3
        palbHW4Bf67F9/jvFtojMDfP6p94h1yt0Bi4AMa9Ba0mxN16tRQYaOpMxJK2Eh3l
        6+4dlD2/78T2oRlRkaLN+KO6zr5u2l5j3fS0PnVA9HtkY5aPZVsRrW4q5sARfQmP
        fiIKpNXpSKcZr7NaH5zC95gL3Jd40l2E2oxpXrm8BAQHo5sJViWOK+OuNCnsvD9Q
        io4rtxUCgYEA+/OWoDgnIYh2GnKeDcJN0/GHcjeon0V/Yv6VnfdC66OUjF++rqcl
        zU0A60apPRNFzw9Cjhl9T4GC+2Y0jskzlen5Q7slYvdAu3k0CT6qc8ZKzNBAG09I
        0Oxu+sQ07yxQT3zP8+C2tD9IdmVADdMPNL8r/ny1QlAEKzy+PKit5LMCgYEAitjn
        GKZSbfPpaR5EoN5ZvG4/8Pe0LU5MzrkgjWDHQeoEvm3ScJnDXva2gpYlgcYdNpDG
        rqB/W5yADZrvqv5RvU/7zDlS0wGo7Ld7Za7NPX52+j63hMWbtWBU/E1IXSjahoql
        NuLYqVnkzvj1cfsAwnfjt0tjSKek/zGZF5kHVc8CgYEA1UrE1ERVVD0LBp7LkQhS
        DL/nE1ltJdCW4/50OPOPMp8b7a5MZdzY0rGCuqrqMOs06PKZPGT1wa35bcx7Z/mK
        8znNLHqtTtfUdCFKXR0w/av7vOH7s2LuWPgfh6k8ytFv96rI/UPaSENem+RhUpK/
        x76jhuCaLlZBAT1+Kyn9dKMCgYBJaxQXxqrDlTwQ535miextZObOpkxRwJuAnAeI
        emoignnrr+qcu9HA/zfWqUo/6uA7oCZO5HMzn/deOlUM19mk/wwoGw+en7wRH5xS
        UjIYmCyVemBUBqGlMMD/gGYJTLbweZOPCDiEpBIHF0HB+XWXXwm8PFLNckge4L0Q
        60wjpQKBgFeMyC/mTX0OwiKz24MsaAr/NJN6beKKb3tntuz3VsJ/b774klaSHWzK
        Sgg3BZfcey+FLXWYiONXgoxXEZ9Y+Onsg8ZsQrfY/rUBdIzi0w80y1mijBDamoa6
        unJYbtDxQhgcarKzuDOfr6lIzdxQFeviTf8+SaCfTAIgEZOX9x2b
        -----END RSA PRIVATE KEY-----
        """,
                                    timeRanges: [TimeRange.between(from: Date.from(year: 2017, month: 1, day: 1)!, to: Date.from(year: 2018, month: 3, day: 18)!)]
    )
    
    static let writeContract = Contract(name: "Upload data",
                                        identifier: "V5cRNEhdXHWqDEM54tZNqBaElDQcfl4v",
                                        privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEAhMYMWNIeMK34g6uUjUyZlOFSfopWiAvpGH/YL3Gh41LR74MP
        3ikGrxS7BSxU7e8GfoJdk1DP1zl7oj0JV7F7P1GFY/R+SCuynp5TmQ9Ll0pCIkNj
        O2Za1jKV5EWMBOBeiZBWNOUFxaDXKdyuQHLEzxn6R3DYKWI9+a3WbHJH4zNj4o13
        BJsOlIk3N7dHxL73Ao0WlCzkd9b3Czlee4heRUm+oEht+5Ur+jmslotVJmRGOApv
        ffWkyez7uLefSk0p87E4H0I1bTtlLJAKRHj3Jgc6UdTgi6YageZRIBY5Gh50AWyK
        2aYBtTPHqbyAfa8O1HP71d4GcX6dwskRINae+wIDAQABAoIBAGSw4Uo2xwh51v7c
        D4N89PgQTQSEGw1/ot2ejq+kSHZiJ62xQkZj7Jq4aQCKVzo+TDmC2j5PSd/ZyyYF
        jeFASsyBIVzlXSOUaBicz59DFzt76F2dp1Kz0+2fXUdJat+D3I4MtSPWD6OJz8MC
        he+AWjsJY2HsdTIlPATuza9el5/4EIQpbMryKWlisY42jDz59bOHQv5brIgM839Z
        kBXa7FTJuhJ9m8CLMVVxS0Y7SOwVlN7LC0tJRvc9/v+Dc7OaALyufzc6e6ipm3iR
        6znGDzvtyYT36LQnXkeTRQP+bxKqpy1r2+JU3VkMRu3+4hfNnECiuWSXPgMTX3Od
        bzPfA/ECgYEAuPzH8xMSshxoRE4QpJAwYiAxhZsCP8NR5DSE2TfvPdTgXldjfMQt
        3YUbGimky7+47L1QWJM1IIiAt4XbcJthDBul+0UwbJCMN+/hDeSdncHsl/Mz3OiI
        NDtibFTw1iI5dfeAc2Z9K1pzk3tCfnZoLckDO9IlSRdy881fTR4mNHMCgYEAt74T
        GieHXDAzzmd/+8vgTkzdvBPBuNyV3hZ4xjAQ9t0CxdovQw00C9wIy7xUAtWewt43
        EB8TeWEpj/GY3DqeZkgBc6Md+3fJ/GbA1u4AhcFEODKKgcO4k2uBZH2pA9ZxAzW0
        MDlmVElyL0wUR3UrtqWtGMGOauVks/4Sfc2yUVkCgYBOl/dLqtrSmYcjHhesEya7
        SfpATW9TL+TnE/ktYLpghsUcz/wQ0ji6WQb+wpqlhjtHOdedCk4UGGq3jkOBQEKn
        JkgKzYaZWYB5c40mne7pS679j/KE9LaJmoFijWQVVk0bdaA5Z13ewXtBOakymZQB
        f9nD3LDCsRfBxYur9Bc/SQKBgAweCuB0ruaTfzcjeDtAzMAdLZpTqzjnwzJsRPa9
        AMFm/eHSa79+RWpqzmGxP9EYCWpMgVEc24nrsHP/uNb9Pqj8Iqxfm4CT+8wbcqg5
        9ercPgV+v8ejAq8mLdhUuSq5n6ZYilOL1YXFejRITiYQQhu/fVTenufJzQRZwxps
        0E+xAoGBAJvIS8Qpg6s1XJDgNvvbFP0ZkkAoQgCLHYIzvMusXN1PI9ZQUQXec0KZ
        9B/Nk99HD/jCHlONpL+pyGMH5KFP5D9Rx4uTMtv6dpX+4czdOxstonsq68WtgFkU
        xpt9yk2orvtaK/ZtMxiyhRzxW5EPrZkL9xSlfnIxd+M2f4Rqy/po
        -----END RSA PRIVATE KEY-----
        """,
                                        timeRanges: nil
    )
    
    static let readContract = Contract(name: "Read uploaded data",
                                       identifier: "slA5X9HyO2TnAxBIcRwf1VfpovcD1aQX",
                                       privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEAnHxDWyjjKXizE6Llo6yMI3xtHSjaPwF7hFQwChwSweqyvBpR
        rozDYKA9OX5yW5AsJYX2AJsPRiD16PdsMwgh/6hgDpPAaAWvwaPVc5oUG0V6I6L6
        apewv5dhE7HbSykIoDZqCpdmHaY4r0H8W8Gck8I3y0ocDuLTbSTfTMDj+9ZPACrw
        kfdh49ZsLDXCobNZvXh5LF1q00G4SD8cyhHTs9MpXCvWIZspawWlC6i8+UmbICw3
        YKcbYSRYTM90/impDWAYPHiyzJNwemgrnJ/M/GyOVLM7tlHuzU/K6ypu9oAjHANl
        L2DuDDjSZg9azTABSXVC1RbjXg+eOodHAqdblQIDAQABAoIBAGnbrf0HBdTSL+JC
        ujIk0ZBX5cBqGGmy6Qm1oeHU5+OCj3KsI0F/O9Qr0f8IyPej6hlgK/Bw9L4uIex9
        JBbJk6ZNEt4JmYlE/4Zw/D59pshkEaH16I0fHJQfJa6bDIwlsA4hgU606IF6JrJ4
        Yuz3ZqKWKgQ9mAmB7CDTZrOXcSK04dEe1t59ba8V56++iRu72avVhjvW87ZxgATN
        UJaQcVLxss0kA6ySP5j1w8VRf8jvNxWY0lPFSmJjaJrB2ovbS1u3vReTkdMbeErK
        cbfl2woGORyCELUEwTG7iI4usFGbgZuU1IVEGvm2zHLE0Jy92sH8N7Spw3/DYxnj
        Fax62AECgYEA1aEEaOjXOA12VlTG0G8OQffZyQzK634amwAQ0f4xpeVBb1Mcilo2
        G+Hf9V+ThSwYGndxtEN4YjFBuxUhjhig8od8ZFiSUPIBzFdtw3w1OHLg68kzTDPC
        +ftQoEgSkE1G3X0csKmr2nL9ibgdBtQCHcFoM5eMXzCmYaFeLCkhLpUCgYEAu4XJ
        5dsPfHE5AAQ6wKn15BflvynVCyf9iVF7O64KGfJaTlPPTMqyt4aNbIiKStTPStZk
        hV/GRqwI8ENjFPpDznIxTiZwkN1YPG2FT8HEAgf8H8826u4yBdEyGDrnvlKtxKli
        h5vdnHCsgaPhYMuDVDaI3/pgfVrWqszXBO7LOQECgYEAqyYiG06Xxk96xDWNRsYC
        fTVtZNZ75+kStaV61FI7QnaGUwMZ9XnKqdHvlGzrCiFGekXBcbMwSjK+P3zxch8n
        KscDEH2pU3JfoG9W/+uN09itfBmooF9D0PTYJmE3hiZzJNWsW5jDlvLTTzeTAbpu
        q5ocumCq1ERsuAEJKoYVEHUCgYANvLpSpV6YDi9Pyf+H16uUvw9slqLtw0s2gQqX
        D6PbzL5C2K7qADthaHD5z3LaEobxA42vm5mJ2dZ5y2X5xm+rMwBbqkM6yYxKOPe4
        JQi34V/d8K8kPLjbZjzWO5J4hdQHASWfq5JrgHGSua+sCJyhUbFrPwtMg5gQQRtL
        WDb5AQKBgEycWssIPCULSSEinr1AD3FMczrZsLlGJWITp3af7IqeI2UQ9Bm8XSxX
        Pbx/llXLPRze9YT857XcrM/8w/F14iQDq+6wOu1tCoriT006QnIjMKGoJftXipTO
        AFUT+vgwhNxAy5/JN536S0Atg3TCcOzppsFg0i0GCoyhBqY5OWyn
        -----END RSA PRIVATE KEY-----
        """,
                                       timeRanges: nil
    )
}
