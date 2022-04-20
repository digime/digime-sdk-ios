//
//  Contracts.swift
//  RNExample
//
//  Created on 18/04/2022.
//  Copyright © 2022 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import Foundation

struct DigimeContract {
  let name: String?
  let identifier: String
  let privateKey: String
  let timeRanges: [TimeRange]?
}

enum Contracts {
  static let appId = "6bKMA1Sz8EopMY1a2GwMvFkaqbOmRcN8"
  static let appleHealth = DigimeContract(name: "Apple Health",
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
                                          timeRanges: [TimeRange.last(amount: 4, unit: .month)])
}
