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
    // ThisDigimeContract allows SDK user to read user's social,
    // financial and music data from the past 3 months.
    
    static let prodFinSocMus = DigimeContract(name: "PROD: Social, Music, Financial",
                                              appId: "6bKMA1Sz8EopMY1a2GwMvFkaqbOmRcN8",
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
    
    // ThisDigimeContract allows SDK user to read user's medical
    // and fitness data from the past 3 months.
    static let prodFitHealth = DigimeContract(name: "PROD: Health & Fitness",
                                              appId: "6bKMA1Sz8EopMY1a2GwMvFkaqbOmRcN8",
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
                                              timeRanges: [TimeRange.last(amount: 4, unit: .month)]
    )
    
    static let prodWriteContract = DigimeContract(name: "Upload data",
                                                  appId: "6bKMA1Sz8EopMY1a2GwMvFkaqbOmRcN8",
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
        """
    )
    
    static let prodReadContract = DigimeContract(name: "Read uploaded data",
                                                 appId: "6bKMA1Sz8EopMY1a2GwMvFkaqbOmRcN8",
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
        """
    )
    
    // applicationId: QGgBnPQOJBe6JqEAkgZ3t4y7PulaR66V
    static let prodAppleHealth = DigimeContract(name: "Apple Health",
                                                appId: "6bKMA1Sz8EopMY1a2GwMvFkaqbOmRcN8",
                                                identifier: "MuwUjwbeTo7NYMs9Q8M5u5HHbYboFIOJ",
                                                privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEAsykpwDc7e+ePh0IrT9VQcULB8jvWD82Q4vD/SZ3xydCpLOnd
        e9bFmME4L+F5l07WdDE2RbcuYLu5DF5ZQwUFo064ATsBORdd2DiETQzbhm0pzbWI
        wtF82/DL2YjvXUujZBSD42n2oWGr/1PBNloZACNBp1NvgkMdHGuFjXWueV4pX9wW
        sJCehP++0uDh2bs/F5upFwUZshGLMDLx3nvj8oax0/ukgZxE97l7KzICw+5Hn0l2
        7pHNWii6X0boxH1zUcQnc6avYaukQgAqE634ugOAVdS5QH0o6tdtDDFlW+hmse76
        3zz5Nh+BeCyMvBGt9pHdu9is2idiE+h6G8T7EwIDAQABAoIBAH0E6GF9KUEZIQrd
        naOj0vJ2ByiloIZ+h/AVA8+3K5YMyUDSIP/dqx0hF7gxuste9D84aArV/ML7u/Fp
        lRgzVO/UaopRRlU0fQP4zDmIE1gGrPkjCEAKNvqzWUx/Rajwsx+PQUlcFAIhSght
        xZHL5U43TAUbL+DSPGosjZFc4VdGtuwwhmFhBWIyHf0BpAqm7FPQvrDhV97WgsAQ
        nkOyRQduv3tf2BQJsz2sj2sn7fJZ4CXtf0o4TSBmPxYXQhlrjZnfXyKIj7f2rAEc
        bl4pT2lvW6deLL3PGwzjYaEB4G9HIIt45SCig7wwjEfrdieCBg2ue++usl8Ss5YQ
        k4bpBsECgYEA1tAgqZ6WT3Pod0J0n1s/79lWFF29kCRMTstaicNAF1sbvj/ISm86
        f6RWhRxpmaP60saYBDjftNMl8IILUVq60cwUQOpBCdkTNfp91BsindH0Jj6y8Htc
        hSA/mimgSoc1UFv9/uCzj8H44AdfLjg+eP4pKWRkhfznHPNMPKPSHisCgYEA1YMV
        iWgwDhGyw4zAtsVENdBTC+dWlICL1os0iK8aV61F4KV309vfGV0meeCGqd4k1nOK
        1rBHfo+Lpa2MbE5YE3xvHeZYWx/QI/xzctGbjr/aHyQhj0ql10qc7/Jgu0IbJAZP
        SxJmXhBULASWHkHy4cQOGaC5zLqx+w12/pL+irkCgYEAiDMkUoezxCK4pU0khpmj
        u16w3m7lL0xkeZ0kBa8fpu9kcsccJl3J2H6JQRLXvcuj0BqM7jhlVtB+ALVjmayO
        QVFFEje1DxpsvM/bEi42T5x8Ufd1G1cMPXhJ+2QjNr3txsrdC8rK7v5M3zatWa/d
        pHd5/72govfMTaXRk61HH0sCgYBCNBgceBrWcfRtIBqtUXN6ADOP8FZvS4CQsK9E
        Zo8Tep29L3F9VqLRuYlxpwX6a/AeMsttEFHK03WolKyC9LPort/BdKgW8UFXtzKQ
        +p9yXtiiaVCinrHXlMIewJfv2GqT/ATgMT9ekU+YKn/lt+s4x9LbbXPPIGCJiL5J
        54hXuQKBgQCBmGjS+Sxjp9GBg7SZxow0YTaWEm+FrF3AyQZa9kTg2aGW35gvfUTU
        qkhvhk+xX5EHnXNXvFZ2uiaPHjv5S7PDiznjGvfjcQX6KDcPq4+NptLC8cE3jpXi
        MReto8gQbA5eMe8fIVT/YsNhtPcIxwo42Vk573lE8wzKQ5jkrD+WBA==
        -----END RSA PRIVATE KEY-----
        """,
                                                timeRanges: [TimeRange.last(amount: 4, unit: .month)]
    )
    
    static let development = DigimeContract(name: "Development",
                                            appId: "IL7aPYWO6DUaU9kgY7ZwHpV1G7AeBHQT",
                                            identifier: "jKsCqdBbgm4HnAv08GXfPxlTluGl7qfa",
                                            privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEAhFUxeHsrjakMdNFKj+zrypk8/a3aJv4VWNaH912OuWWZYeid
        rCzdhqTXKqpB+5Ji6vwHJWvOvuWlQwCi4FfI9RITsEOwkOhrafh4we90w4oaKWFp
        Wr9F6onawwSuz6eV83LpcWevYCoV3b2t2BS1B1lLJ2JkPptHBJzB/CzXkIRkhjfu
        04H7TbSSWTy2W0KI/Qn70HW1cQi+c2sfffHIss0dN/U7aiL94s2D3s1C3wxjYO/j
        NtwhY7izbgqBc/jol7u8C+uoo5XZz+ccE/wghC9sDfkwifpDct9WJVAm47EoKKBV
        LkvaVSUghfbj0vrYAtJxWjw+N365jjalx+KoKwIDAQABAoIBAFy0LdbgOm+f6IkB
        gUF4UOp6FT8FhpjgUGYOy+tfkDeS1DPBuItAVuQXIGDUKysorsE9U2hEsO4MhIx+
        qpuNA8ujIUXO9adeGrl/BmGd9WdynMc2ZY7cBge7ERSjeC8ikKqeaqk2YKZ2dSEE
        2v9P6k2+oSZzCBTPxJ2Xj1GwvEaRX0zyHduR4no/vdqtsO1w1XvgamegoBNkfIQc
        6/nj3mYTT8rKh+ULyc+FDDatSlvFJDFWPAT4iiWI+y67oshrffqmtzj8yl/P72Xy
        SuiM0qHaAf3ideCrgHmvflqYJ1s86zJy0Jw9TdAqGe/WpvDV3Nx//BBI8AqC0Jev
        oxrBrskCgYEA6j0oKMKjfo+EPAyqGmvIUs3gbl8Z/kD8csp4VQYIinD6sGlYSACz
        9KpCazqbIz7yKb4dd3YRPrxa/Ayrim6lvNoHJ1gYaJvx49U4K414T0D3sS5QXwb6
        GDr37qxx4ra6YQWbny/UxG4GvuVeC6IBZdaF9EZpybs43INPUn6Y9U8CgYEAkKBu
        AmCyVhEnKfv37tPfNdQ33VMNcPafiTuBdUShI2RpW2o5+RANWF7cyUYowt+wPJPW
        O6AdL8IkL0b4NoaO9cxG9n7/f9DkveEz5nTAUlflQZLnOIcXYYQ3oayLN7HBSOqR
        HUoJif+KxGaqJeguROkb2I+7acQPKBwMbeMgIGUCgYEA6MYDrZXW8YNfbmlLdVwc
        w6TR3fzmENO1y8FHGX8YZ7NkfIEDePIx4vZ7cKHZ34nDDxZdpASRmJ2HcSiKI9RX
        IbgtGb0i7HnkRHv0CNvabi/qtYmH1xdQ21lmXynBNwJNbvMqtmPK9bU9QOEgt0C0
        UOaBUcHTiORj2kcnQZyLFmMCgYAphMTQDe5kYtw5Y0pT16MWkuvOr88GBObbwKdz
        gNY5kNPmGGK4K3GJUwJTDb8Z4pl3aoFv8JEwaq10nQ0YqhxUV+ZvURoMGW3xTLtX
        h2DGwtDfuEqEodOGfSxzT1NQE8mHIz+xhtWiNigiJc7mvva5dao2y1xkCpLHUvYG
        fdN1OQKBgQCNVgLK25pHPRREuYdF5TpIJKiWLVPIxHS1s7hUI/1WGVMQVSKwiKyS
        z8NMGwXzaT1gw7IxEUFReGLUpn4q9R/u7p/UEp4HqyPR8FEU7C/y0XKXfJ9gSXMk
        QqWza7DXTdfpmwyl4IqvFKuFq1MhfVLaO3KZk5EWki00fq2EhoHAsQ==
        -----END RSA PRIVATE KEY-----
        """,
                                            baseURL: "https://api.development.devdigi.me"
    )
    
    static let integration = DigimeContract(name: "Integration",
                                            appId: "8xQSl0XkCfa434LqNC7NwJdvc38qEWGz",
                                            identifier: "D661QwcBCIYr1Hj0Sgavg9hX9y2PC2rX",
                                            privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEAhFUxeHsrjakMdNFKj+zrypk8/a3aJv4VWNaH912OuWWZYeid
        rCzdhqTXKqpB+5Ji6vwHJWvOvuWlQwCi4FfI9RITsEOwkOhrafh4we90w4oaKWFp
        Wr9F6onawwSuz6eV83LpcWevYCoV3b2t2BS1B1lLJ2JkPptHBJzB/CzXkIRkhjfu
        04H7TbSSWTy2W0KI/Qn70HW1cQi+c2sfffHIss0dN/U7aiL94s2D3s1C3wxjYO/j
        NtwhY7izbgqBc/jol7u8C+uoo5XZz+ccE/wghC9sDfkwifpDct9WJVAm47EoKKBV
        LkvaVSUghfbj0vrYAtJxWjw+N365jjalx+KoKwIDAQABAoIBAFy0LdbgOm+f6IkB
        gUF4UOp6FT8FhpjgUGYOy+tfkDeS1DPBuItAVuQXIGDUKysorsE9U2hEsO4MhIx+
        qpuNA8ujIUXO9adeGrl/BmGd9WdynMc2ZY7cBge7ERSjeC8ikKqeaqk2YKZ2dSEE
        2v9P6k2+oSZzCBTPxJ2Xj1GwvEaRX0zyHduR4no/vdqtsO1w1XvgamegoBNkfIQc
        6/nj3mYTT8rKh+ULyc+FDDatSlvFJDFWPAT4iiWI+y67oshrffqmtzj8yl/P72Xy
        SuiM0qHaAf3ideCrgHmvflqYJ1s86zJy0Jw9TdAqGe/WpvDV3Nx//BBI8AqC0Jev
        oxrBrskCgYEA6j0oKMKjfo+EPAyqGmvIUs3gbl8Z/kD8csp4VQYIinD6sGlYSACz
        9KpCazqbIz7yKb4dd3YRPrxa/Ayrim6lvNoHJ1gYaJvx49U4K414T0D3sS5QXwb6
        GDr37qxx4ra6YQWbny/UxG4GvuVeC6IBZdaF9EZpybs43INPUn6Y9U8CgYEAkKBu
        AmCyVhEnKfv37tPfNdQ33VMNcPafiTuBdUShI2RpW2o5+RANWF7cyUYowt+wPJPW
        O6AdL8IkL0b4NoaO9cxG9n7/f9DkveEz5nTAUlflQZLnOIcXYYQ3oayLN7HBSOqR
        HUoJif+KxGaqJeguROkb2I+7acQPKBwMbeMgIGUCgYEA6MYDrZXW8YNfbmlLdVwc
        w6TR3fzmENO1y8FHGX8YZ7NkfIEDePIx4vZ7cKHZ34nDDxZdpASRmJ2HcSiKI9RX
        IbgtGb0i7HnkRHv0CNvabi/qtYmH1xdQ21lmXynBNwJNbvMqtmPK9bU9QOEgt0C0
        UOaBUcHTiORj2kcnQZyLFmMCgYAphMTQDe5kYtw5Y0pT16MWkuvOr88GBObbwKdz
        gNY5kNPmGGK4K3GJUwJTDb8Z4pl3aoFv8JEwaq10nQ0YqhxUV+ZvURoMGW3xTLtX
        h2DGwtDfuEqEodOGfSxzT1NQE8mHIz+xhtWiNigiJc7mvva5dao2y1xkCpLHUvYG
        fdN1OQKBgQCNVgLK25pHPRREuYdF5TpIJKiWLVPIxHS1s7hUI/1WGVMQVSKwiKyS
        z8NMGwXzaT1gw7IxEUFReGLUpn4q9R/u7p/UEp4HqyPR8FEU7C/y0XKXfJ9gSXMk
        QqWza7DXTdfpmwyl4IqvFKuFq1MhfVLaO3KZk5EWki00fq2EhoHAsQ==
        -----END RSA PRIVATE KEY-----
        """,
                                            baseURL: "https://api.integration.devdigi.me"
    )
    
    static let staging = DigimeContract(name: "Staging",
                                        appId: "lFrMvUSnWLRB0WkzKpW45y9USpA3Uygh",
                                        identifier: "VNQr2gCQqGmtUzoVVzZIxw5cBooWKBQQ",
                                        privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEAhFUxeHsrjakMdNFKj+zrypk8/a3aJv4VWNaH912OuWWZYeid
        rCzdhqTXKqpB+5Ji6vwHJWvOvuWlQwCi4FfI9RITsEOwkOhrafh4we90w4oaKWFp
        Wr9F6onawwSuz6eV83LpcWevYCoV3b2t2BS1B1lLJ2JkPptHBJzB/CzXkIRkhjfu
        04H7TbSSWTy2W0KI/Qn70HW1cQi+c2sfffHIss0dN/U7aiL94s2D3s1C3wxjYO/j
        NtwhY7izbgqBc/jol7u8C+uoo5XZz+ccE/wghC9sDfkwifpDct9WJVAm47EoKKBV
        LkvaVSUghfbj0vrYAtJxWjw+N365jjalx+KoKwIDAQABAoIBAFy0LdbgOm+f6IkB
        gUF4UOp6FT8FhpjgUGYOy+tfkDeS1DPBuItAVuQXIGDUKysorsE9U2hEsO4MhIx+
        qpuNA8ujIUXO9adeGrl/BmGd9WdynMc2ZY7cBge7ERSjeC8ikKqeaqk2YKZ2dSEE
        2v9P6k2+oSZzCBTPxJ2Xj1GwvEaRX0zyHduR4no/vdqtsO1w1XvgamegoBNkfIQc
        6/nj3mYTT8rKh+ULyc+FDDatSlvFJDFWPAT4iiWI+y67oshrffqmtzj8yl/P72Xy
        SuiM0qHaAf3ideCrgHmvflqYJ1s86zJy0Jw9TdAqGe/WpvDV3Nx//BBI8AqC0Jev
        oxrBrskCgYEA6j0oKMKjfo+EPAyqGmvIUs3gbl8Z/kD8csp4VQYIinD6sGlYSACz
        9KpCazqbIz7yKb4dd3YRPrxa/Ayrim6lvNoHJ1gYaJvx49U4K414T0D3sS5QXwb6
        GDr37qxx4ra6YQWbny/UxG4GvuVeC6IBZdaF9EZpybs43INPUn6Y9U8CgYEAkKBu
        AmCyVhEnKfv37tPfNdQ33VMNcPafiTuBdUShI2RpW2o5+RANWF7cyUYowt+wPJPW
        O6AdL8IkL0b4NoaO9cxG9n7/f9DkveEz5nTAUlflQZLnOIcXYYQ3oayLN7HBSOqR
        HUoJif+KxGaqJeguROkb2I+7acQPKBwMbeMgIGUCgYEA6MYDrZXW8YNfbmlLdVwc
        w6TR3fzmENO1y8FHGX8YZ7NkfIEDePIx4vZ7cKHZ34nDDxZdpASRmJ2HcSiKI9RX
        IbgtGb0i7HnkRHv0CNvabi/qtYmH1xdQ21lmXynBNwJNbvMqtmPK9bU9QOEgt0C0
        UOaBUcHTiORj2kcnQZyLFmMCgYAphMTQDe5kYtw5Y0pT16MWkuvOr88GBObbwKdz
        gNY5kNPmGGK4K3GJUwJTDb8Z4pl3aoFv8JEwaq10nQ0YqhxUV+ZvURoMGW3xTLtX
        h2DGwtDfuEqEodOGfSxzT1NQE8mHIz+xhtWiNigiJc7mvva5dao2y1xkCpLHUvYG
        fdN1OQKBgQCNVgLK25pHPRREuYdF5TpIJKiWLVPIxHS1s7hUI/1WGVMQVSKwiKyS
        z8NMGwXzaT1gw7IxEUFReGLUpn4q9R/u7p/UEp4HqyPR8FEU7C/y0XKXfJ9gSXMk
        QqWza7DXTdfpmwyl4IqvFKuFq1MhfVLaO3KZk5EWki00fq2EhoHAsQ==
        -----END RSA PRIVATE KEY-----
        """,
                                        baseURL: "https://api.stagingdigi.me")
    
    static let test05 = DigimeContract(name: "Test 05",
                                       appId: "k72eyl1CMG1A29lv1qNVlrFedIufXjpV",
                                       identifier: "6rYrM1oiNoYegyuMz6HWp492s1DcOjZV",
                                       privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEAlUHoAbnnkdsTcvNIS7OQG5mBeMctEj68Xt1+GpB70kmJiZBd
        1GWoaaMrLI7yCdp3pCI8VikiVG9HQloqpCbFcOUpMAlrohiTS3pObHXzsQ7sSLfv
        ixArm24jZaVksiTnVM3vwCNaH9TPcOut+Oud6Q7OpJzmmvXgjLPZfg1q9ym8QlgI
        ++W1PLKPLcTGOJiHkZCFVqJ6NGLky2ZjgqPQDzDn4OwZjsg2u0Hoebw+D1XHmX50
        /2CS9IgYPVQO1LPLPy6A0GpkMQPq0r9T609uypCs8hqSFrET6N3LD4O6CCvQuQo+
        wweIQ00g919p2rYzrpMKdBnRCSiVG42ufNIPTwIDAQABAoIBAQCGdfkslO2o2FON
        Gt3mVL1eH8wjoktYRGwuihswkzj5GIZvBz+AOJSflf8vBRfHCKj/lFgGxsfGiPkJ
        LXF8r/Du44NXYyUzwi/vrx83VotS1r7GQ+3ouYiPXYlF6NnuIpDENUHnNfHa+zxl
        3eu8c4aujkhaw35720WPe/ZTOINEZU04d2Q2OJNX+1M1QF7xWLt/yYbbq27sxo3/
        yF0WX9KTs+D747kqtjwRtlBIPNEGJmbh3YoNX8sIxWiVFTNRd2KbvOJnIQHIecYW
        mqBanTCe/o9kCgkBH168UeWPoJL7S4acTOLFrUJjwyQlIeFS1sz8UpN9Ejtxrd6z
        SArFA8QBAoGBAO/mJyqM/5oqoNjX6P7qmIGcsSSjudDxERHOoMOzE7c9Al6JF378
        Kp1S9/yilTxMJowDrDdC057Uzft0/16taCFh7ciR2C0KaoyOcVj8FhweDrOoZi02
        hIy5sLbX2iG4Kqpf7T7z3aCA8ENDEFJntjOqVADBCFLuAp6XVGyL9uMxAoGBAJ9G
        YvknUOeFcsqFgTlIfG3qTjZ+zAg0PbpDBeFyVYEUM02cWq/gzkW0YnjR9jHloezg
        UAnvJyQ79h4OIiU7gdQ9aT5my3tgVvsgOcLsvKx2vovwYEDAXPQf11I7zGknfrae
        IL/m9bL1ie01dlSwOXHZpp48jFJhu77fE/D9snp/AoGAcGKTyp1PSPvbanqLjpB8
        bYvoeM+yxy2H3527NrL384nDSGJU/YpItHcf8dyAqUTLciBuV10ZInlzHfALimEW
        PT1RVfrtGPyeOcapVxSRjw6NuKCVbWzy37JGFQI+EDnk0vgpfqpkE0MUS45pYRFx
        C/cpb0j/C0qxM3aVeFyBhqECgYEAnvWBi8Y4UYh3AzZwvLniLVS90FeFy95PiNih
        Qtp4CYYemaOlQojrdNfNu2VY/319uMo6N1/uQZRyUpaqb1xPe4H6ymOPS0fgJ2uH
        GkppFvq/uywg9B7H5oDsxc6WeJAJP7rbVorrxjqV+B72RRlHi5+8UYp+RS3zUVCU
        N10LRoMCgYAQgmYQ1of3iAr3Ufh9LrH9y+5sWmf0a5a5jTpG8XXejuENmvG59Hm3
        K4EClxv5oBbGfrJw2LcYeF+RM1OYxhp1bH2IAkO6gnc5JR8QPHHIAE1LyEak0rtI
        dct4TnSvBnSMUn+Sm/k/vnCGUeP606SDLKGZ9DMqWZo0JTTXAVCSnA==
        -----END RSA PRIVATE KEY-----
        """,
                                       baseURL: "https://api.test05.devdigi.me")
    
    static let test08 = DigimeContract(name: "Test 08",
                                       appId: "7vEZe7EzcLlMMsiaUh0R5VzfxkfiKmul",
                                       identifier: "Hfk43VZvOC63Xge7RvYEV8DbTesvvUcD",
                                       privateKey: """
         -----BEGIN RSA PRIVATE KEY-----
         MIIEowIBAAKCAQEA3KuceCOnvXKN6nKS0EiDnfQcJeiml4LXW30mztfAnomtGPt2
         LcIdHXqPvWzwxrbVSkkffGOV15e08ZcaphgJJRoX7ld8nRIvvti2JIOnIRy7dJsC
         AlNlXRGBC7dr2cq2JptdnHk+BPfYCd4AiIHiwvnRhuFKnQYvaGdjOrMmgkpCNp3Y
         9JRTtImuZXKry9GcXOzeWam4YJX9tVd4KmHoS2WbV63dFVCfc80NpYkIAI3WzgHc
         D9Gy1gexLZpOiLRIS1nMsM0UM7UbH7feQhbMfHeZ8mFBDLp7e/qgDs52aL+cSKsM
         5x41Q2U6BuK2S1dO5AMkWYtVIgCk6XHOcxeIPwIDAQABAoIBAQDDvKVqG5ZqgPZJ
         A6AeiHPW4/Uj2x4KPtDwIi8OQmplNhIImuTU6d4Ri+l8SOm6GetPnVUEbQE43yRt
         N2837RIPivm3PHsYiE05p9jIws64nFfasrQxg+/hgelJj0VnRlwUGrQKW7Ebjwxe
         lEE81JlkAVxNnAEnD5l1rl9ibg62eapcRbHjhPPJfPnwj5AG4A6WCM6FNbPZa4iC
         AH6/L+2TREEu31SmEOHiSr8Mm35226+rYrCOG9fbA72VZp1/1v1me2QMK18eVT0I
         Eb85wt6xaHoNLbKdo7K5us9ZwpMJ4tp4bGcGWgBdlaJVKwUIdgM7g5peQVVqwpu6
         YT3SXjyBAoGBAPAxVx67lWeOJwwIsDzKdjrJZRpOi5upu9nSRMMloDpAsbATX/z7
         HUHMA5zlFwLO6PqAiH3Kmr37eCEQkHW4iDA6T0VAsGQsRzIuUG2nY0PmhRMumFhp
         lNYRq017tHw+h2JYmK7KLa+D1/7EMVxbQ5YdaRyonu1uRtbQrvVkPDAxAoGBAOsx
         Xdi1gRnZr5RVfteKQtG9a/L6jvejbOaLZfzoOdi6CQh5+Z/jo9afMBzjoQ6Af0tI
         IFeFMN7gCnXzM6cBKFqpp5v2IVLR8siGhWf+IRRpvLb4UGelHBjgN+zKyrkyzrXc
         8l0LRGA63bcVC9AMmZ2JQOOx/9F/cbIRGCOkWxNvAoGASn6jDI8VSWbXSW4waspI
         XPc1ejE+L2s3Ldl/Jh83UJncAkYgETA45L1HqZOLzX0q2PagXpNF5wJlQawHgdtX
         sc2D5HCpxIfPFQs0Oq4dpWOLhmV/Lnyggrw8Ku3hDl++UYw03pEqFjOH/CYRQRm1
         HovEm/TYRb9cDSfv+3+5AyECgYA/vwKjsRZLzl+zgbS+cOAJfyDaG6VSY34pwpCj
         CsJbBplaLc1F0+pdSoo82kmV56gY3HS/o/8J+Yl8TK2sTzkD0cX3FLAVhYgbZ7KS
         7CNFKB+ZLBaG8Q57g5JE4PYvWiEC097w7xPaTTo43EB2ZGPieggXbvBadQN48v8q
         8eopiwKBgEmRn2ECCM2up7tzlZ1tbhowfqXm7J6X/YLTcOW0gtRF+42kI+cednhi
         Bf5DAr1PGG684oOdtdkXXeFMRSjoLQgZrqYdBslPFTfv/3fWGkotM27V7a5OMa9L
         GA1havNDAwGR0cLJDeg5xP1gzVrAKVKakCnq6v8ntQpjcIK7f7el
         -----END RSA PRIVATE KEY-----
         """,
                                       baseURL: "https://api.test08.devdigi.me")
}
