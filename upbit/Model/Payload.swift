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
    let query_hash: String?
    let query_hash_alg: String?

    init(access_key: String, nonce: String, query_hash: String? = nil, query_hash_alg: String? = nil) {
        self.access_key = access_key
        self.nonce = nonce
        self.query_hash = query_hash
        self.query_hash_alg = query_hash_alg
    }
}
