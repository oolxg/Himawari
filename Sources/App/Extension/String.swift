//
//  File.swift
//  
//
//  Created by Oleg on 09.02.23.
//

import Foundation

extension String {
    static func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
        return String((0..<length).map { _ in letters.randomElement()! })
    }

    func isURL() -> Bool {
        guard let url = URL(string: self) else { return false }

        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: url.absoluteString, options: [], range: NSRange(location: 0, length: url.absoluteString.utf16.count))
        return matches.count == 1
    }
}
