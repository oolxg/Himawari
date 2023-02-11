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
    let description: String?

    init(
        alias: String? = nil,
        destination: String,
        validUntil: Date? = nil,
        maxVisitsCount: Int? = nil,
        description: String? = nil
    ) {
        self.alias = alias
        self.destination = destination
        self.validUntil = validUntil
        self.maxVisitsCount = maxVisitsCount
        self.description = description
    }
}

struct UpdateAliasRequest: Content {
    let aliasID: UUID
    let validUntil: Date?
    let isActive: Bool?
    let maxVisitsCount: Int?
    let newDestination: String?
    let description: String?

    init(
        aliasID: UUID,
        validUntil: Date? = nil,
        isActive: Bool? = nil,
        maxVisitsCount: Int? = nil,
        newDestination: String? = nil,
        description: String? = nil
    ) {
        self.aliasID = aliasID
        self.validUntil = validUntil
        self.isActive = isActive
        self.maxVisitsCount = maxVisitsCount
        self.newDestination = newDestination
        self.description = description
    }
}

struct  DeleteAliasRequest: Content {
    let aliasID: UUID
}
