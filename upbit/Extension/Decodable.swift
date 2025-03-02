//
//  Decodable.swift
//  upbit
//
//  Created by 홍정연 on 3/2/25.
//

import Foundation

extension Decodable {
    // MARK: parse Binary Data
    static func parseData(_ data: Data) -> Self? {
        do {
            let decoder = JSONDecoder()
            let decodedData = try decoder.decode(Self.self, from: data)
            return decodedData
        } catch {
            return nil
        }
    }
}

