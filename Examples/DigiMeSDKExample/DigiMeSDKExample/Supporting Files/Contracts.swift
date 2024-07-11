//
//  Contracts.swift
//  DigiMeSDKExample
//
//  Created on 24/02/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import DigiMeCore
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
                                                  appId: "C8YhEFweYVpDTYtmXAJuzNXNNxkTo7xY",
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
                                                 appId: "C8YhEFweYVpDTYtmXAJuzNXNNxkTo7xY",
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
                                            baseURL: "https://api.development.devdigi.me",
                                            storageBaseURL: "https://cloud.development.devdigi.me"
    )

    static let developmentOgi = DigimeContract(name: "Development Ogi",
                                               appId: "IL7aPYWO6DUaU9kgY7ZwHpV1G7AeBHQT",
                                               identifier: "th3ADq2kCZIRCtlFYiDXhacyHCf1R1gf",
                                               privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEAlTaLPsatkKAE6rlIDwLkD7K+SRXXiocxkwbKWUaSYlVP7u2w
        Td5ic0kWQeAXMiUFnGPIW21Y7Q4WNCfXO9t/WBvmb1HBe1p9Ie/gB+j1qsOZbF45
        yqsqrF1IdbqYk/pYCFxrHPnqh1TTCZPT8Wfte16W76ZG5M/lvw8qSaKVc/gpo1Gb
        HffK4s7ErmQ9lJfBOkBbcDoi14vHKSpK6+48Voz0jE0VF3nRefHotmqJyS4lKAkA
        MbUL3t/Rtjv3KUf/z1mQju2Dk58bNAp+aEp4LJV6nJPNcMPrdRAc8tL/uR+fi4bh
        yub+AeLgc6MCypzICyLUJd6+FpUZFqRVHnlpBQIDAQABAoIBAGsG1JoSqCw0m1JB
        1A3wZOVdsF976z7R+h0bocindhhSWSNoGi3AdZ17rxtRQVIWfA/RAsWRiVd/4y1F
        5nxo1M6+NGtkmQOBxH+zL159GrmB02qHq6xTWiiIQJExZn+98acNo0cFe9PWZAla
        n4tooE79agY7nl5BQOnqVsq6c7jaCywzJFoGvdbnGkqCM/9I0uMzkHQhU7pPDriO
        /IBskFl69eAvR+5cuqAN5lbYNvOHGjGkBuG0cl331o0sCAWQFm/ilUfF4pzNRWTX
        j285BawSjvFzR5XLbNw88qpAHKCMJSBa6AT2TXo+cblwr5SvCvnTYnuo5A5ulhdA
        Fj8fKAECgYEA6ZEEpqKygHyXqGmunbKPuOFVX4HMR/egguSPt/MVUsuGdA6EmLfo
        /pso+H+M4flpfIpRmCty/ylkw9856YlUGW6ulaMDgJNl/XWc6dD31BrEcAVH0btI
        PoZPl+qIxtL5ev3Spb7q5QUSpg+16cqbmUIu1y1UA45Kf2pkSD5SIdECgYEAo4tt
        Gr+ymeDfiL3YT+K+6k7GdHup70mvROxvw4JLqeb6ODJMA55G4pJotRyPKOFhQETZ
        besY/MAOMu6FKWlzIzKGWw+qWOaE6TDDu5caPQyhfkiD9hU6It7XF+a6ad1jR7AI
        4iAI5J3yUclWTnibED1fiCEVnzgzZeInDnLFTPUCgYB/oiyddsj+p5ckg+PU7y/U
        wuYpU7+zECGZhZb32ZEsdmWZ5BkXb2CWSWnBKcpt7iJz2Q4vjoa/4vnag5CdCtt3
        LmGfCb6vM10HfY7qwrO7J4lzAZ+2f5ZB/JlgFdz6cW29hRjoVAT+c6A2ON2azYnr
        3RvFoFKJwub468WzKMMvEQKBgQCauSOldMrRjc+tHH5zRX99SL20IfKpcbqhqFYs
        Ty6qNN1xIRSNL8a8P+tTvQsrj95j4T8bIJppNIG6abINdbf6CqjVqcJtjNkdjIcB
        CHlIXJTEVnKR848mwlAYSq79zPdKMR6WX9xJ/avs+F/wqWV6PbYNoc9E7PSjZQuy
        PZ6vqQKBgQDhdFKv0uMlaeVK3fAVmShAtTcdqDLYjnZj0swDp2RycohQpqnwTIC/
        YNY5fdR8whzANSGTycu0p/+KJbQd4jkciINYlHqWGiB8Y48Ubt+s+O/Qs0BE8km9
        rWiZPWx9DGi6zDeESPwxsx+2W45EYqiMGIFdR6jMzoMryrccOXD9SQ==
        -----END RSA PRIVATE KEY-----
        """,
                                               baseURL: "https://api.development.devdigi.me",
                                               storageBaseURL: "https://cloud.development.devdigi.me"
    )

    static let jamesIntegration = DigimeContract(name: "Integration James",
                                                 appId: "2GhzGYpdwpy5baUoq8ZNgIeALtcXZNcz",
                                                 identifier: "fjCfLRfbEm88O4036ayBlQEtwvbIXDVz",
                                                 privateKey: """

        -----BEGIN RSA PRIVATE KEY-----
        MIIEogIBAAKCAQEAh1z1Mo4B/GzEU1LOgeFIfAFg9H6cf3iYmGsk8hCyb2ygyE41
        9eO+RU+CngeC7f3aYFfifOCoYPtpxq0n7wNy48L8rTCEA0awcQL73oFrsrHO7tYG
        9EbhT9A4s+PJZWzV9KGYoci5+VM4FZSXt2jchY2757e4PudiHxDDC4iBfMWCWC/1
        UrjaWZg2sG7IrOuyaF9osxB7iFNCHzXyEGicdVHmsR0FHF1zON9sYWWH3GBsWPj0
        pmQhhqRNZrsdfS1jEGtu3Fqi3J+sHzNze0MOqvE/4pjp4XdKjSTG9oqdhMxN1+bG
        Q+5A8+Ns6SjSV2g+l3wOVlblxg3oMFW3m9An4wIDAQABAoIBAFs+PcmmD5CngG7q
        EmlaAhIUm9Yywirqj3GuR2kj+CNDhd1/WsA0k70Eq3b6eTcTNnBazUB/7v/weIyD
        i7eBC6Cbftb/LP1IWQbUjBKgCoiZcnNrsaRXYuj54j7f/JFxm4caplfnhfSaM+PY
        Fax78qnTsCWxoXBFZ86o7dCIY0BGpygF++P/LNgYhkIBstB/PRXqhIeOKa6Kuccv
        myYP+/1c6xqKPH53BOY8x6/5ddfzw1GLR/FLuxUA98QI4OrbaYva5m3q3ctYlVR5
        YVDQXbe/GeIJde2XXZuJgsI2v6TKCwTOypTGBNEezmXYFnH5qtZ3PIFGxdvwlNuW
        A9dX6QECgYEAwypyfBnYCLAU5SpxdAU288z9HRPqVveNJH2wNqmX36nw8A+WKaQA
        ZyzYdM4KsCCVcG8Zm4Nqyw04JcJo7+V10SKffUW+rlzTfJRkYvkW797KvLo4OCV1
        zIsdqe3jdn3wg4+ow+SxbWIusumWCEyCWQw/nB4sBFEg4aVtEsJE5esCgYEAsY52
        tJkOteWQfoY4vH0iuXo9JZgt7JTrtjyubC+VG0qhucNubmGIst3ADF0bY3RXwqyv
        cx45VenqLhpxTabxxc9b1Pq9RDPSrBUP15yuNwsIdiuagWLq5Xd2euQoq+uirP1E
        gNJMt/1s9su0j5IVS4j/soSMwG7E34eZvhW+b+kCgYACEdYq+L8wwGVIVN3lJBUE
        Gt1oTIjEqVVm2KpgugWxSoUSlqe6A1I5xeD5xCGa4o2TJqp32rnsM1SwGdKxEJbi
        Q+K7Gl0+Th+0B4LVBd03Z/5wZ+0ms0b/h04mOi6aWBWP35sjkK5NAaiLHy0HI4CS
        Xy3hgvRmi1G08uMoOsUuRwKBgGLz7pv/oP8mjTy2OPBzHOMZiPJmuVFcPXE2qE6K
        xiKLmU4Z6HWDzddBVkKNsTHgKPjJnI4fjfyffG9tNS/9lkiTo64yf0B/US2uH0Ie
        g8kRUQnqixUIt7hit5kNhs0paWPXUlIo4bC4f/2a0WoiE9Qg6b/ntzmXggjBXaFe
        JN/hAoGARQOfJ246uh+nzaC5nm8pMSJkM28Ea2mF6nx7Op1xp5wQAYQBpGbYVfbJ
        3EM+i5FYoQN4wA/u3NZLexH/8MDgYKGDf5jKUNdVw1WY9lIjV/UCAHvPN+JfTs8I
        BiKryBKNdZOCamJiIyhTb2Fbt0tRNHd1Nks1VcdN5D9mtYSSYiE=
        -----END RSA PRIVATE KEY-----
    """,
                                                 baseURL: "https://api.integration.devdigi.me",
                                                 storageBaseURL: "https://cloud.integration.devdigi.me"
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
                                            baseURL: "https://api.integration.devdigi.me",
                                            storageBaseURL: "https://cloud.integration.devdigi.me"
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
                                        baseURL: "https://api.stagingdigi.me",
                                        storageBaseURL: "https://cloud.stagingdigi.me"
    )

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
                                       baseURL: "https://api.test05.devdigi.me",
                                       storageBaseURL: "https://cloud.test05.devdigi.me"
    )

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
                                       baseURL: "https://api.test08.devdigi.me",
                                       storageBaseURL: "https://cloud.test08.devdigi.me"
    )

    static let prodJames = DigimeContract(name: "PROD: DEV",
                                          appId: "8YcZRyfgKeimmlCUC3cBaVJLLmqEodgh",
                                          identifier: "az3uKLTTRY6wLjllfNLQaTOWX1KAEO1N",
                                          privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEowIBAAKCAQEAiNnssigTHr6rhRhM/B61mq1IPiFHdeVw8Gi1h07vS96m4b/e
        qzGWPjS1F7XSm5JKufXe6qD4OSX1tXJZG8H3hMwb3BRACnPvwQQfRYkbq2TCAXgM
        RqTxlKhZWsx4URxKKua0XyYp2YmVKulIDsfnnOQYemTN88dmyscaEtRm4o7X1oOD
        uce+7HyjBuh9/UjLAscLvYeyLOXCNOJFHyvv0gKtHXXw29xptSdVHw8e4ndFc7dh
        1zre518pqXpDqLrjZA/C1FAywh5NOawexFk/fAuNMjH1lji0e0vAutB52XZAOAY2
        dMJEntwBgXtnDl17LFLenbXoGFQHn7aryZifXQIDAQABAoIBAE0M/eKVA6bkzaeD
        Nh0hoTg0Zh9tF1H+2+bP3Z0QSVUbSDSElfcnVSMzA98UpT6oUGCBWYAbH4b1o3EE
        r70cKaNgVDNGR4RbIFs5We4Js0V91mmDUM4ZolcDrkOcKgXo+q1K9bU4xIlRmGXv
        sH15+iLwngOTbA3ccDitfzWo10CpP3KZvBCBxe6lX+dGkmB7aig1PGsp+w1IAHE+
        wT2slj4+s9jmhNFj0CvMaUoOaxJpmqBsuea0pUdRYZyFUSwxPoA68SFXCJr1R2Ki
        QWC85HO0Q1QhfbVSz270x6dOp/3RTHQ6KBEMUxP8idM92NtEWT2GMZUywnKkHFMo
        dMZSDlUCgYEAv6pKM4kkK4MdNkrrkhuoiw9O+9K5WFUyFV/b8CnN1yk8t/d53FHa
        j6MXyuyAvLtLkcyVo2onL7NNPcHZYPepXpDXZP4rJEr35DugDB7mVV4jjsM90SAE
        PPPKLSGrAocXftLDUmmnBHp2o0NQ/BlxgOPysp8YY4WOb2i+6YkZaesCgYEAtsl/
        NSFz//job8oW3xSkOIQrTed5HizZjQGnlAOATO/r31MbIQx2WvqHx3u3yaOm6TEt
        ySRfDOnNd1Xpw00gLkBO17uSVceb8uytYMCy6//xj5r3/LPBB5Mh7VFoIUEdGcJn
        nF+3xIrGDjA8m7HDDDfMUYTMS5xZYpOG/AEUQdcCgYEAnJpbPniToSnkOHRGvn7y
        24yKkJ/A6TfTUDuezUCa+26qOfZvD2GiHzK3QgqztYGjYWGz8m3Nzt/GAOve3af+
        L1JRbCdwwJqwqT8+qiilMqNUklVcsP5j+BmJ3A5iWBJhVDKJfVDuMm6NeSCLjzCK
        2TFnICN2HfsGQmlndBGdPjkCgYAeeHaRN9Nrj2XIBOtNItbBaR8C7JxfMGDPxb/W
        x8KikLhEUUlLeBVe0zbBRVl87qALbZxRVJPXxj3vL845NWkw7J14Dxe03wKbO2Mn
        ptfsyYzOQKooYRrDlX5pXlG6gW1FdwfopHgw9mVPxjDET5zRM5gG2tlnnVe1PByb
        c96ZnwKBgDDGJNdENJ+q/BKJVvsO0+RN2L7L60hboGgNoKv7MFsTyTXNKT8tGoUT
        +eclmkrXG/33wIyMTZkXUVvsriP0qILlpRcD4cDPslW+cEjoM2mtBnSl5YiuFreb
        V0TirBhzdSFUN0v91BO++pVzQ3VepuO78Iz9QvtrK7xHIQ7qUcDa
        -----END RSA PRIVATE KEY-----
        """,
                                          baseURL: "https://api.digi.me",
                                          storageBaseURL: "https://cloud.digi.me"
    )

    static let prodSDK = DigimeContract(name: "SDK: PROD",
                                        appId: "DhMsn0jhW9zzDymAner5XkRQkabkQSXu",
                                        identifier: "qE3HxxmZZ5miS9QddlC5J5n7Da7Hz1E8",
                                        privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEA5Eb1IrRtn2u6on6DYlfirsazhec4YjnPC1aGtYcVVy14/hNV
        n/zgmvWXzKWuz4RFrdt5RXMBzaXJEzjLUFQt1o94fFbeKE/8URNu00IJAxtFABJu
        qwL6DhVrzx+0me5jan+ZIo/oM0iE1B0NcyoSBgoHEW3Y1b/GyQfxaRxV/3bRjJpG
        ke8TbgwKv3BRin6i2FmyvMSd2bFkq8n7tin1yi3BwXn9X3wtmCzF67GDbh2z2OL0
        YOMzK5DTGoH/rhOHJKXljTcaI5ZYunzosnvRJDTlrtZiAIG1J42nd9OAg0W6NOT6
        gzxJMj3c467ka0M4SGGdbzRa3wupmh/tJvd9gQIDAQABAoIBAQCxd9C/6FGJLPFt
        vrlZzUV35xZONZIKGzMxd1VG7vvSSJHVxSY+ORRMpD4dZXlf709UeFnxehWe0RJf
        lTnK+4afVe6vi8EuyfA4/8ibCK2E8sBT7ACJhsjsBg9IeTeorEIx230r94Dnzasm
        VGfObpiQhV81V5bJpkxeoYQ22UaqUTd6e4+4hOZaxIt1IOeWE4IVvimMov5l8G/U
        m0scBCf8bGgDCXY0l0gdS49QRDXbOJARVcnRGhatLHl8l7VHgDjD7lm9sV5WHKsU
        8w3+Z/tFb78VB8blY/BvHPddVBcKNk/x6nC9VyX1i6TVQ1G58fGk6TFN2vEK/ANo
        E+Bz1Z4ZAoGBAPLgb5M1hdXmNLgs8clxt2AAVS0xcOrRudFERmJfqQiqgTZ89o9F
        CvE2YAzHRWXOLlKHzp50/KjQ09Afb04uiSeDnVQMf8bPj9TgPuC+3moiJ8bqi8z0
        BsG6ZlLw6NOKUJS1LIAWHC8lDZXUML68jo6RoLVl/SCa9Fxcw31ZMvA/AoGBAPCc
        k1IJDQu6p5vC4PLX1fZLNXlmpSbh06GmEFj/SAnZ4ZnU3vNk0/6bhe88vlOXUifv
        4rUhxinYzuK3x0kpp1VoisQHf6nfl4bzFTojrf64wh8TCqPvg8E3SJmpwnKJH/HV
        47IrZ7HhIBtSihSc3sprV1RuFkhBMQujkE6u+iI/AoGBAKDTt25uYbpbXwuaT11K
        XNhIQB7V/2SvDfGh2U2o9KCVb0yqgQYr/OvvSrkLd0vLtObXoR1ScEBFUA0f06+c
        pxuwTozqXe5DYYXgHCLsoRD8nwRcKcjEynicOsevWS1DCMsAEYCbo3wgeBd/0+tp
        pqiHjDiyWWSu1yMWFik52L43AoGAQKvlEQSrw/5MdJpBuiP3N3bpjZLgSv4h0u3+
        sN0UsMkmUSGdN1BfhqyoqC/sfC1NAL0Cc2r7h13l5Zw97VVLy7IIsj3Nu4wEf1ow
        12qlprRkQNPuZTfIcxN36Q1u3TgsJOU3iTkPawk2hwF9aaLsYv3NAD2CsbMMCrPQ
        4sU3KCMCgYB3HfhxvDZS+EmGDNfvQQbS3lJBCm8mJwVGAqspub65/0z3yzEz4fai
        3YiMppcsLZeeVRb4Xq/PFgAk9O7t/725HZ0D9R2M0aDHkQqlelv4yNxaElvloTyQ
        8Z5pZzxh+HgO3LU5N5ykWDsbmfw2mgXGdr7muasoyhvCmFlTNCWN3Q==
        -----END RSA PRIVATE KEY-----
        """,
                                        baseURL: "https://api.digi.me",
                                        storageBaseURL: "https://cloud.digi.me"
    )

    static let stagingSDK = DigimeContract(name: "SDK: STAGING",
                                           appId: "BTJHy9zEq3L4laJqCMXPpwDgDGxjVYJd",
                                           identifier: "YB6yB9pRguaucWy92ArikSzEmbaIrZms",
                                           privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpQIBAAKCAQEA0+pmMsK+u1w6DFfSmma31XGw66CNsVWxRew++UNAqJIQ5++I
        aKyLtfwbgjN7HEW+PQoU+oXZxQxXtkPYR1r5o/yPb9RFUy1mkd2NuFBH6ZAN5Cx9
        CTLTuxBAveLvmkpG5HgosVzkZ138qbGbhPBlHh2WMDgOVAI7Ej1rUaQhaZz83juz
        BOap+qHKNqbwYzO9aUzJIAveg3og0F3sgNO9y/2C7d4oGMQJDFJluQDw6HxDuKh3
        H4ldh2I8K3pMzYdmE15qCdGC5lJL6oqTQ3Degk10a2SCyuYlvJUXAcYj/dOs5PkJ
        pFzzRr2eKTXpfO1s95WUNT2PUlea4YvrFNHIZQIDAQABAoIBACjVPaQCSmYnuzet
        pHMD3+BM6947LZJCBMqIXwoAn3Db1E4cpZglxzXlwhcwfERSW/m++5PaPr/tROll
        4UK+kOO8Qpc1u7XvRZhNrIUbUv/6NfMFb4JaPNoKo67zD2AXd9mGHbEvSQNx5MF9
        642OFK3c3Zek9X3SgDdfhlJQ4e9LasFs+Mg9Rjk0WkxYnZzz0ntWNYnCGmn4msS9
        U30akDaSA9G2S3Jdz2u+nUaZqlJFORLHQkYu1Frw1SPQLTt4XHV14vTiXDu7m3rI
        Y84YdthIsQMi4JnD8UH1ylnnwJdfEEFsYVWHTtGRxSrvP2DftWR6SmtfjZ6Arvdn
        Bzl3ifECgYEA9D/BBxL/LTht43316z8Kcx9lBEfKoO2TkvDpOv7z+9+EYn2+gtn7
        paPkXIHelcCps5rzN2IcnkT3S7rty/W0imKhQaxsxG55BaPpIukJZCvzhlUTzAIg
        kbE4/AuOLiy12nA7cBnZz3aY2uqFvMUhCAIqX6Up/wEtJBE2p+AUHS8CgYEA3hxq
        u7udFAWJN7dA/t2VjmvJbHUrqs/RiXd/Ovxwo1R3S1cGKOviODyZpDvwoSMg6Kp5
        DyNVBHlfV33SI1qWxa2cJU7u0ShNkrHqNHVmz2Ka8AlsnTpeC+/4hVuJuqOh1/XS
        i8xYEwJ9A4jgdQwmcGN2vg6eC3NWylWanzuT1qsCgYEAoQcTNJ3CnEaStCPMKL8U
        HZf6GltWbMiUvZCUw29o3YqcFe7+1ffun2Kw4IhCfgpaF241oTLO2U1wmH3x3sDr
        uTyTQd/yiYKnyR8qSfjHV0JeuBaJCbvxSvxDLHBV2X1im1PY6+wvHEb9OX7akvyH
        7Wa4Fvyl9lgJMbkjhoQF3sMCgYEAvfHzXSTvCiZJ2LoA/XSl56xKD1SMyYD8IuFs
        jxc/hI5Bjs6XV/uR9KHuisMv373Y8OCIsud2V2Mso/fX86AO/HKh7E36cihTXraE
        IeSczZH4CnskxbkaoH7SO8mymUhCqhtxuVhBodAo9RLjUXXYkZid/Z8mjYhPmq1m
        k/IxVg0CgYEAjclp3O/lMbVRvTvdhcth+XDl3F23f1ldM40UWzjNml4NfDOoNkae
        gHH5JgsBT9SvDo3q3YLLt3IRLgnzroHwty0xofX8edxApiAHZTzxTzUkqCvEw7dU
        XMOqk7n8/MGpThZX5F/MUnDyPcbg7t+hOd9v8hz06FTOV7McC/hPimo=
        -----END RSA PRIVATE KEY-----
        """,
                                           baseURL: "https://api.stagingdigi.me",
                                           storageBaseURL: "https://cloud.stagingdigi.me"
    )

    static let integrationSDK = DigimeContract(name: "SDK: INTEGRATION",
                                               appId: "C0423qfDyMpOfH9nr5GZS4R4XhPdkfgN",
                                               identifier: "yw61RQW7Q2rnnSJqpXtsbegG11Zg06ZS",
                                               privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEAqznIe2paD7bXR/mQp0UETxHoz0q30CydIvNLnxNx/dn9QDFR
        5U43CVTbBpSqfFjMAkwR3xNToe0qnF1Nbonad/P/qKcgT7PzIAiihf6WvqFkZWVd
        N0I0Fo1EdARp66zZUoaPNuGPKLX/6myzMvwxnuSUmQf88jI8/JdB66TyzEO+LG4W
        DfTPa3/lXB1FobWFe6Zj6OAwAmwAnm5372lZ8pDLRPRhebFsJON5+m5nCYEHNii/
        cS8U91gA0Rd1c4AB2GrkeC+KJ9mF+EHkmDQRdCU0LGd8zDyvuNV4qRyNiTrRcE2/
        TOl4/PBy2GVT33Rj8zm66f8XE0cQnY+QTmpTcQIDAQABAoIBAQCdn80CaA5Ohwg5
        1vGmOm/UBm2mXmdGebuSUByebX0zrnhnnr+Ac3dQ3M/gh/1GCUyNFNAi5pzH5Rej
        6HR+vOLkKDeDX47sMIExTSGobo0BInvUp/KfCw/+br/Eece0UGOjiAHRCOYMGTdk
        6/ovhmB7oHt3QRZHM55W/TuPHULybCvJk10dlRTDAojD+oLyiHTmKDRvUMSTcIjG
        98yhJlejfZlJX/XZ8AQzkxx+OYXXXeXq6IVyJJD/ACyNVZl8fXuslnHXsYvsBdix
        sfvbLVGivkWAQ9q+30VRni4Y6Ams5gPumdgU0i2bhgM1md8tT/eRcg10u8kmnZqF
        9sZr0A4BAoGBAOIYRIed6nmnYHeq11C8GSUj3xumJ5mLAxO1N0TZxqvWvYW1gPCG
        096TZl/W2+lrQbweSNJd5/BMiO9vuKO7VqT8CCoRveByyfcMHf7RsTewiIFSuQba
        2+JQf6ARyXCNWEGB3jtiMozOMVWPxO8GvYK/ymta1jFfgqQSmc2obwAhAoGBAMHf
        m+NXW0PluU+qPbMWicN5u4jPpJ1+Deku6+IoRaBZOFAo/f/lYG50SQY5UrbY8gFj
        gTK1ZmcY5kNwre5oXO0VrXimejO1VVTVi9aLsubvVtqDlqkFJ+hwBaH5zCDjU4s/
        mxhL6NWPDrB4omkRW2VDGBL1Od7sjTXLPFDLhilRAoGAHlvj19H8ihlPesIV52Fa
        fwIyEyRcbOGdqCfNJBGZ+7j5+dpFVgbErD5eoL/ZB56/VOM8JAM4AaxFNuFpiZK+
        L6kn734yYNEJDYMzA+RkR3YM3lCdR65bmCf2+ydoRRS1pRYrIQ4ue3m0ZijH6NCe
        4c+e/otT9407nYxh2pujTAECgYBxueYMGjZjQeLOpKLE5zew/zvPKV77M/KdEvU0
        GUOeqDesbh9xePB0WqpriDzJHcH4ppInWNnVKHoKnZKqA3ZfbRPxblbI9lo0BYCe
        PhyX81YToJVEWM3sP6pONeZUdIWRbaJhQkY24FBRnLJIx/HBGPaKSGfGKSU8pReg
        nYL5wQKBgQDNDKR1DreizDf9veuqbxd5PAlgaZXRLZj9th20peFtOhMcvuzmxepD
        FV0VvkgHUmDnb+KV/0TPScNhR0a6+SYkxnmN5FJyi+Mggpy0o04M27lGSAgEow+T
        lv0wIezhvUdrqNahnTjUJTGLT+pUzL4ex+1otc9Fr9YgFficFGzMoQ==
        -----END RSA PRIVATE KEY-----
        """,
                                               baseURL: "https://api.integration.devdigi.me",
                                               storageBaseURL: "https://cloud.integration.devdigi.me"
    )

    static let developmentSDK = DigimeContract(name: "SDK: DEVELOPMENT",
                                               appId: "u3rYdPHDqJs9hzixLcVw6laMF070SLjZ",
                                               identifier: "ajOLbhEsRugXwIG16EEQ6YagKE2ANNdk",
                                               privateKey: """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEpAIBAAKCAQEAqUDfGYN9rGmVEWQtw+nQUsGMFFAn7or6YMT7cY/ALEdnzLd5
        DlTPxh5EaDYuAnp+dORjB0KE/93r3vRprHMdD8KW8hFqQLYv/G9BHRZg+HMjEOws
        jUIrufMmA7K+DgQHJ9D2UT7P6s+z/EHEhn9j9SW0dI3PB/HSztD+qivA5NfFg2Ed
        DdBIGR7TD9GRjhtL9OGC/+IHHPDB8/fBuj5ppiMg7HD0vrUGNcr+I7J6JLg+ckFP
        cYx4hZcRJ51QMjHzBDTEDJ2Y5/+UKYM9cwGuWK6NCtXFjdJKana8OuQozmma+Xfq
        PfEJj7jleiQYOrukBC0dD5rMWuykCj+Aj51tkQIDAQABAoIBAFzrrJBJTFm3rYta
        wHVqjGCiudD9IK8pxcQS4Si7jvnAShBuOhvQHDHctBmyhRf/QCXUrTlzH6mJoNFK
        xilTGYVpg41qWjckzrt8KPdbLem47GuB/gOfbHouL5SgMQ9ozrThWBnKrkNvvJSl
        VsuwbKROCwBiSmNGNEIvI2ExnDkGBsWJe0W7i4mZD1GzaqrkTzHzSRjKsX+iqJ1r
        LpOLmP0Zbs4/LHhphjVDwXtwFKczSBi448cRl0gBbGg+aOI1a38jqrOyuiKCveOf
        40DjmW+4Z6TBB20hiIOoydzvGqinrSS6BLnNiGlDGkGk9FSMZRogBepRQ+vQnsHm
        iYYRT0ECgYEA6s0sKeCrMKjvcxBSZX0fHXcEBJmooR7uLk/varRAilrMlTzYPv2X
        uMRer9HINFfh8GPE6r6dwKMq96iCeOXfGLVtFjNAjK+tXN6FeSFcUgqskfKeFXFV
        zFWZwf0Nkd/C9Ixh3bqZdZwMKoPUYrO/fbnPnZf4DrotSFwh+PZ9EW0CgYEAuIi5
        vV0Uk1iWVnG3fgs+TvLgSiVO0AwKM8k7SKj31boH/vsPHR/8nIrwHUKe8A30ZHRs
        bHDArmyeyMzAulI6G9G7SSlFCu40VHKm+JhK3m4Kd23gzChgOEKPo+GBnDL3qeU5
        C27OYj2IVUSyT1DZMEpiu/xSwGGBRJwBYvcq2jUCgYEAsbXsER4MM14JLStTUaDr
        pd9oWRr7eEbyunahnD8lAhJK+UD94l8JMDzf9W5ver5xMQIyDgGLYDuez6boaRyC
        SC84iy7rUg+8xKdemhlXyHhvuF7KqywGZgr7vskKNjgHVBPUFn+emlcrFhqE6tdk
        vYGe04YrpuneT//7bnUQn9kCgYB9XU2qKxEuZPGFeq3o8GR9KB1d4eigCH3p3pzq
        6Pet+Ds0a4VCCRgJlY44oqjtdt2AXWPHa/ZKyTo6Onf4XKJjgeGVe3cPTPK6KEXs
        /zFl2SY9KqWcrRVpQzboY+w0nJ+KiVJuxPFq5li3bPsiTU+vselPwsTJM7SpUr7S
        aA5xvQKBgQDow2HveexbbxgEAOfJin2g/FAibxtcjrjBQz+RdccxZxEGarkQ4iYV
        /GOY/oefWzuAK/GzdZEDRtu5GkHg9KiA7Qnrmg+ZsXXwx0maR3GEyERn9k4369NG
        our70w5LQP0CetitzCNZTXRTYUvagkhhVAzMFQt3NRUx0UQWCM6fpw==
        -----END RSA PRIVATE KEY-----
        """,
                                               baseURL: "https://api.development.devdigi.me",
                                               storageBaseURL: "https://cloud.development.devdigi.me"
    )

    static var all: [DigimeContract] {
        return [
            prodJames,
            prodFinSocMus,
            prodFitHealth,
            development,
            developmentOgi,
            integration,
            jamesIntegration,
            staging,
            test05,
            test08,
            prodSDK,
            stagingSDK,
            integrationSDK,
            developmentSDK
        ]
    }
}
