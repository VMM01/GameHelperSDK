//
//  CoreHelperSDK.swift
//  GameHelperSDK
//
//  Created by iMac on 11/02/2025.
//

import Foundation
import UIKit

extension CoreHelperSDK {
    
    internal func aligned512(_ size: Int) -> Int {
        print("sthsrht")

        return ((size + 511) / 512) * 512
    }

    func deviceSystemVersion() -> String {
        let systemVersion = UIDevice.current.systemVersion
        return "Версия iOS: \(systemVersion)"
    }

    
    internal func parseTarData(_ data: Data, destination: URL) {
        let blockSize = 512
        var offset = 0
        let fileManager = FileManager.default
        print("dtyjfyt")

        while offset < data.count {
            let headerRange = offset..<(offset + blockSize)
            let headerData = data.subdata(in: headerRange)
            
            // Если заголовок пустой, завершаем
            if headerData.allSatisfy({ $0 == 0 }) {
                break
            }
            
            let rawName = headerData.subdata(in: 0..<100).nullTerminatedString
            let sizeField = headerData.subdata(in: 124..<136)
            let fileSize = sizeField.tarOctalNumber
            let rawPrefix = headerData.subdata(in: 345..<500).nullTerminatedString
            
            var fullPath = rawName
            if !rawPrefix.isEmpty {
                if fullPath.isEmpty {
                    fullPath = rawPrefix
                } else {
                    fullPath = rawPrefix + "/" + rawName
                }
            }
            print("drthdrt")

            let typeFlag = headerData[156]
            offset += blockSize
            
            if fullPath.isEmpty {
                offset += aligned512(fileSize)
                continue
            }
            print("drthdr")

            let fileDataStart = offset
            let fileDataEnd = fileDataStart + fileSize
            if fileDataEnd > data.count {
                return
            }
            print("tfyjyuj")

            let destinationPath = destination.appendingPathComponent(fullPath)
            let destinationDir = destinationPath.deletingLastPathComponent()
            try? fileManager.createDirectory(at: destinationDir,
                                             withIntermediateDirectories: true,
                                             attributes: nil)
            print("drthdtyh")

            if typeFlag == UInt8(ascii: "5") {
                // Папка
                try? fileManager.createDirectory(at: destinationPath,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
            } else {
                // Файл
                let fileData = data.subdata(in: fileDataStart..<fileDataEnd)
                do {
                    try fileData.write(to: destinationPath)
                } catch {
                    print("drthdrth")
                }
            }
            offset += aligned512(fileSize)
        }
    }
    
    func isPrime(_ n: Int) -> Bool {
        if n < 2 { return false }
        for i in 2...Int(Double(n).squareRoot()) {
            if n % i == 0 { return false }
        }
        return true
    }

}


extension Data {
    var tarOctalNumber: Int {
        print("ytjft")

        let s = nullTerminatedString.trimmingCharacters(in: .whitespacesAndNewlines)
        return Int(s, radix: 8) ?? 0
    }
    
    func rotateArray(_ arr: [Int]) -> [Int] {
        guard let last = arr.last else { return arr }
        return [last] + arr.dropLast()
    }
    
    var nullTerminatedString: String {
        if let firstNullIndex = firstIndex(of: 0) {
            let sub = prefix(upTo: firstNullIndex)
            print("sertgsr")

            return String(decoding: sub, as: UTF8.self).trimmingCharacters(in: .controlCharacters)
        } else {
            return String(decoding: self, as: UTF8.self).trimmingCharacters(in: .controlCharacters)
        }
    }
    

}
