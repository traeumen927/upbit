//
//  Payload.swift
//  upbit
//
//  Created by 홍정연 on 3/7/25.
//

import SwiftJWT

// MARK: JWT Payload
struct Payload: Claims {
    let access_key: String
    let nonce: String
}

