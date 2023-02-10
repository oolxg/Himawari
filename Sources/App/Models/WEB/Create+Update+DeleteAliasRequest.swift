//
// Created by Oleg on 09.02.23.
//

import Foundation
import Vapor

struct CreateAliasRequest: Content {
    let alias: String?
    let destination: String
    let validUntil: Date?
    let maxVisitsCount: Int?

    init(alias: String? = nil, destination: String, validUntil: Date? = nil, maxVisitsCount: Int? = nil) {
        self.alias = alias
        self.destination = destination
        self.validUntil = validUntil
        self.maxVisitsCount = maxVisitsCount
    }
}

struct UpdateAliasRequest: Content {
    let aliasID: UUID
    let validUntil: Date?
    let isActive: Bool?
    let maxVisitsCount: Int?

    init(aliasID: UUID, validUntil: Date? = nil, isActive: Bool? = nil, maxVisitsCount: Int? = nil) {
        self.aliasID = aliasID
        self.validUntil = validUntil
        self.isActive = isActive
        self.maxVisitsCount = maxVisitsCount
    }
}

struct  DeleteAliasRequest: Content {
    let aliasID: UUID
}
