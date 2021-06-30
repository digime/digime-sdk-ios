//
//  ViewController.swift
//  DigiMeSDKExample
//
//  Created on 04/06/2021.
//  Copyright © 2021 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import UIKit

class ViewController: UIViewController {

    private var sdk: DigiMeSDK?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let privateKey = """
MIIEowIBAAKCAQEAjmBHCOA8hmmBc0Y6Gj61yZn9dQawtsS7s8/iZ/x2o/uHVp8L
XRVUvMXYpiG5uXMReUNQNcsS6ggNt9fpQT08g5QrtF/sXM0RAut9yxNQ6J9QDPua
r4cN0gD13+BSzNaPpVSDhSRSINiQL1JNxGawIEn7VOMuBdGeLNXB9scQfH8S8ikE
4xsB5GFEg7kkMf7svE8ZTVAbgGubkn5sqt++JilGe+ivQKcGodr/Aag2azVbsowK
BkIf/REY9bQUltfFsFqIlh4VOXhHL1tfDSjhJYz5pmpK/KgUZ1S3X4xhj+ttFO7+
yS6t8H7YfEwC4oZTNH2Y0jT6tloLxWvsiRs8BQIDAQABAoIBAEkk8zl/IfkX2PZk
3NLA5tm0r/7gOgcbmSbupO0xSa5DOatpuAfRPqBgsEXhS64XjKGU0G9ibcwn6QxK
8z2d/SnIBI/9O8wNWjD61Lxwpv9rYU/aLwUASDxcW/TxJPixPkj82ziaiUrwl1qI
WQWOj+t2tpVMxUceArob8zMZ38FlLBnnfY7hf0JAf5WkfOOIuYYfuYtC0gi+VVOj
9eL+/sExMtzEkZ+noBC2IGRhvmrRJbBi6XuGP3y0AAFvXBrbljLEaSeUIewIoW4d
YCYBj7kE93/Mp+zozfTTgRPIj9wrMlF/05fBwRvsYDKpXlimVXijXSu0fBGq/BkK
CaffqN0CgYEA47RAE+mtFkwEFqJYsvpHUf7h+BCx+05a3GnNbr1uQDortZt01dGp
hV5IBnDM2ri2YpymEC3lmReR/qpJ5hx7U8NubDJWYhFF689T36F6Oppitb5zvhha
/5B05kvytOfrOU/cQ1ykVFpnD/bMxPnmOfALFB16D0FZEbmeuuHsLLcCgYEAoBGP
7KUo/IuN1betz42jkaett0aDu2R/BsDJzEMgl971ZE5CDyCW4DxjLMwthb1u24MA
x3BNil0voFEnD9t3hyykXZEEsNYyc8bGpWOnu8aM3sg/fA2yPQ6FMyDVQANJhLfh
TyGmzZJPcILuLQV1xPvIVvxq/oKVSJL9U3Vm2SMCgYAieS2iViRwVb3gt196aU3W
6iHH7q8jfu9eo14IwAErFCN98TU1EfL6UBXTc8xv6LskHtc9Z9V04g6mYZ2iivlY
6yOSmeReIINXeiIWn1nj+W+sWFMpmoJcYsBwBVuPa/U+zgpo4GO4qZ8k2ZaS08q5
RtBGkVfja19Swal4Xa/l7QKBgDyJp9cmN7Qby46yoyfGN8CUnByerJ+oyGnza962
3JLTnhdLiaxS9PzlmdSNfAICvPSEPT0wegMEb0jAqHdU14XmGlvQxudiez5SRTqz
z/Iyi4COV4RBYdG5tiK6HizRkXKCYNIetgk1dpnkytN4JyxS1Vggqw6KsI78GJcB
5d3lAoGBAJIWbWNSVKTisg1AfFtIWqMcO88MBwsVxTYKPPS9j5rX7Qd5ACK0vhT/
wtEHEfBLVfL+dCrCpgjLOb18ZXpFM2LuX1+mB347D3d5k8OnHY0hrfZZI5x8hQFT
8qdZvr3DcDEu1meFXfqqTYAIdWgVZy/3dy8WK2f09pSMvjBdrgm5
"""
        let contractId = "Fe22Tpl7mdHNiwmtU59AFkEKyNgkoj0C"
        let appId = "TorHETnMcNrvutirInlMMRg0GrkPATiV"

        let config = Configuration(appId: appId, contractId: contractId, privateKey: privateKey)

        sdk = DigiMeSDK(configuration: config)
        sdk?.authorize(readOptions: nil) { _ in
//            self.sdk?.readAccounts { result in
//
//            }
            
            self.sdk?.readFiles(downloadHandler: { result in
                print("Download handler: \(result)")
            }, completion: { result in
                print("Download compelted: \(result)")
            })
        }
    }
}
