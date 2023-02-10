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
    
    func isValidURL() -> Bool {
        let urlString = self
        let pat = #"([\w-]+\.)+[\w-]+(/[\w- ;,./?%&=]*)?"#
        let regex = try! NSRegularExpression(pattern: pat, options: [])
        
        let matches = regex.numberOfMatches(in: urlString, options: [], range: NSMakeRange(0, urlString.utf16.count))
        return urlString.hasPrefix("http") && matches == 1
    }
}
