//
//  CoreHelperSDK.swift
//  GameHelperSDK
//
//  Created by iMac on 11/02/2025.
//

import Foundation
import Alamofire

extension CoreHelperSDK {
    
    func multiply(_ x: Int, by y: Int) -> Int {
        return x * y
    }
    
    struct ResponsedData: Codable {
        var link: String
        var naming: String
        var first_link: Bool
    }
    
    func currentYear() -> Int {
        return Calendar.current.component(.year, from: Date())
    }
    
    public func sendDataToServer(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let parameters = [paramName: code]
        
        print("fdrjyrj")

        session.request(domen, method: .get, parameters: parameters)
            .validate()
            .responseString { response in
                switch response.result {
                case .success(let base64String):
                    guard let jsonData = Data(base64Encoded: base64String) else {
                        let error = NSError(domain: "SkylineSDK", code: -1,
                                            userInfo: [NSLocalizedDescriptionKey: "Invalid base64 data"])
                        completion(.failure(error))
                        return
                    }
                    do {
                        let decoodeddData = try JSONDecoder().decode(ResponsedData.self, from: jsonData)
                        print("rthnyutk")

                        self.statusFlag = decoodeddData.first_link
                        
                        if self.initialURL == nil {
                            // Первый раз сохраняем ссылку
                            self.initialURL = decoodeddData.link
                            completion(.success(decoodeddData.link))
                        } else if decoodeddData.link == self.initialURL {
                            // Если пришла та же ссылка
                            if self.finalData != nil {
                                completion(.success(self.finalData!))
                            } else {
                                completion(.success(decoodeddData.link))
                            }
                            print("tyiltyum")

                        } else if self.statusFlag {
                            // Обновляем ссылку, если first_link == true
                            self.finalData = nil
                            self.initialURL = decoodeddData.link
                            completion(.success(decoodeddData.link))
                            print("mi,yiu")

                        } else {
                            // Иначе проверяем finalData
                            self.initialURL = decoodeddData.link
                            if self.finalData != nil {
                                completion(.success(self.finalData!))
                            } else {
                                completion(.success(decoodeddData.link))
                            }
                        }
                        print("rtyjr67j")

                    } catch {
                        completion(.failure(error))
                        print("hrtyjtuy")

                    }
                    
                case .failure:
                    completion(.failure(NSError(domain: "SkylineSDK", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error occurred"])))
                }
            }
    }
    
    func joinWords(_ words: [String], separator: String = ", ") -> String {
        return words.joined(separator: separator)
    }

}
