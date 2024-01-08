//
//  MypageService.swift
//  GAM
//
//  Created by Juhyeon Byun on 1/8/24.
//

import Foundation
import Moya

internal protocol MypageServiceProtocol {
    func getPortfolio(completion: @escaping (NetworkResult<Any>) -> (Void))
}

final class MypageService: BaseService {
    static let shared = MypageService()
    private lazy var provider = GamMoyaProvider<MypageRouter>(isLoggingOn: true)
    
    private override init() {}
}

extension MypageService: MypageServiceProtocol {
    
    // [GET] 포트폴리오 리스트 조회
    
    func getPortfolio(completion: @escaping (NetworkResult<Any>) -> (Void)) {
        self.provider.request(.getPortfolio) { result in
            switch result {
            case .success(let response):
                let statusCode = response.statusCode
                let data = response.data
                let networkResult = self.judgeStatus(by: statusCode, data, PortfolioResponseDTO.self)
                completion(networkResult)
            case .failure(let error):
                debugPrint(error)
            }
        }
    }
}
