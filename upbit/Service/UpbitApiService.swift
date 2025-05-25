//
//  UpbitApiService.swift
//  upbit
//
//  Created by 홍정연 on 2/25/25.
//

import Foundation
import Alamofire
import SwiftJWT
import CryptoKit

// MARK: Upbit에서 제공하는 코인관련 API Service(https://docs.upbit.com/reference/)
struct UpbitApiService {
    
    // MARK: Upbit Api의 BaseUrl
    static let baseURL: URL = {
        guard let url = URL(string: "https://api.upbit.com/v1") else {
            fatalError("유효하지 않은 base URL입니다.")
        }
        return url
    }()
    
    // MARK: plist파일에서 AccessKey추출(인증 가능한 요청시 필요)
    static let accessKey: String = {
        guard let path = Bundle.main.path(forResource: "ApiKey", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let apiKey = config["UPBIT_ACCESS_KEY"] as? String else {
            fatalError("ApiKey.plist 파일에서 UPBIT_ACCESS_KEY를 찾을 수 없습니다.")
        }
        return apiKey
    }()
    
    // MARK: plist파일에서 AccessKey추출(API 호출의 보안을 유지하기 위해 사용)
    static let secretKey: String = {
        guard let path = Bundle.main.path(forResource: "ApiKey", ofType: "plist"),
              let config = NSDictionary(contentsOfFile: path),
              let apiKey = config["UPBIT_SECRET_KEY"] as? String else {
            fatalError("ApiKey.plist 파일에서 UPBIT_SECRET_KEY를 찾을 수 없습니다.")
        }
        return apiKey
    }()
    
    // MARK: 요청 처리
    static func request<T: Decodable>(endpoint: EndPoint, method: HTTPMethod, completion: @escaping (Result<T, Error>) -> Void) {
        
        // MARK: 요청된 최종 endPoint URL
        let url = baseURL.appendingPathComponent(endpoint.path)
        
        print(url.absoluteString)
        
        // MARK: 요청 시도
        AF.request(url, method: method, parameters: endpoint.parameters, headers: endpoint.headers)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: T.self) { response in
                
                //                if let data = response.data, let dataString = String(data: data, encoding: .utf8) {
                //                    print("Response Data: \(dataString)")
                //                } else {
                //                    print("No response data.")
                //                }
                
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}

// MARK: - Place for Extension UpbitApiService for Endpoint
extension UpbitApiService {
    // MARK: 요청 EndPoint
    enum EndPoint {
        
        // MARK: 시세 종목 조회: 업비트에서 거래 가능한 종목 목록
        case marketAll(is_details:Bool?)
        
        // MARK: 종목별 종목 현재가 정보(ex. KRW-BTC, KRW-ETH, USDT-BTC)
        case ticker(markets: String)
        
        // MARK: 마켓별 종목 현재가 정보(ex. KRW, BTC, USDT)
        case tickerAll(quote_currencies: String)
        
        // MARK: 전체 계좌 조회
        case accounts
        
        // MARK: 주문 가능 정보
        case ordersChance(market: String)
        
        // MARK: 주문
        case orders(market: String, side: String, volume: String, price: String, ordType: String)
        
        // MARK: 요청 경로
        var path: String {
            switch self {
            case .marketAll:
                return "market/all"
                
            case .ticker:
                return "ticker"
                
            case .tickerAll:
                return "ticker/all"
                
            case .accounts:
                return "accounts"
                
            case .ordersChance:
                return "orders/chance"
                
            case .orders:
                return "orders"
            }
        }
        
        // MARK: 파라미터
        var parameters: Parameters? {
            switch self {
                
            case .marketAll(let isDetails):
                return ["is_details" : isDetails]
                
            case .ticker(let markets):
                return ["markets" : markets]
                
            case .tickerAll(let quote_currencies):
                return ["quote_currencies": quote_currencies]
                
            case .accounts:
                return nil
                
            case .ordersChance(let market):
                return ["market" : market]
                
            case .orders(let market, let side, let volume, let price, let ordType):
                return ["market" : market, "side" : side, "volume" : volume, "price" : price, "ord_type" : ordType]
            }
        }
        
        // MARK: 헤더
        var headers: HTTPHeaders? {
            switch self {
                // MARK: 인증이 필요 없는 요청
            case .marketAll, .ticker, .tickerAll:
                return nil
                
                // MARK: 인증이 필요한 요청
            case .accounts, .ordersChance, .orders:
                let jwt = self.generateJWT()
                return ["Authorization": "Bearer \(jwt)"]
            }
        }
        
        // MARK: 인증이 필요한 요청에 사용되는 Json Web Token 생성
        private func generateJWT() -> String {
            
            // MARK: 난수생성(number used once)
            let nonce = UUID().uuidString
            
            // MARK: 파라미터가 있는 경우
            if let parameters = self.parameters {
                let query = parameters
                    .sorted(by: { $0.key < $1.key })
                    .map { "\($0.key)=\($0.value)" }
                    .joined(separator: "&")
                
                let queryHash = SHA256.hash(data: Data(query.utf8)).map { String(format: "%02x", $0) }.joined()
                
                let payload = Payload(
                    access_key: UpbitApiService.accessKey,
                    nonce: nonce,
                    query_hash: queryHash,
                    query_hash_alg: "SHA256"
                )
                do {
                    var jwt = JWT(claims: payload)
                    return try jwt.sign(using: .hs256(key: .init(Data(secretKey.utf8))))
                } catch {
                    fatalError("JWT 생성 실패: \(error.localizedDescription)")
                }
            } else {
                // MARK: 파리미터가 없는경우, 기본 JWT 페이로드 생성
                let payload = Payload(access_key: accessKey, nonce: nonce)
                
                // MARK: JWT 생성
                do {
                    var jwt = JWT(claims: payload)
                    let jwtString = try jwt.sign(using: .hs256(key: .init(Data(secretKey.utf8))))
                    return jwtString
                } catch {
                    fatalError("Failed to generate JWT: \(error.localizedDescription)")
                }
            }
        }
    }
}



