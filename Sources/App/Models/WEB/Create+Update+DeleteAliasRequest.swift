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
}

struct UpdateAliasRequest: Content {
    let aliasID: UUID
    let validUntil: Date?
    let isActive: Bool?
    let maxVisitsCount: Int?
}

struct DeleteAliasRequest: Content {
    let aliasID: UUID
}
