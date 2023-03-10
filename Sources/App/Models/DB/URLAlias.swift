//
// Created by Oleg on 09.02.23.
//

import Foundation
import Fluent
import Vapor

final class URLAlias: Model, Content {
    static let schema = "url_aliases"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "alias")
    var alias: String

    @Field(key: "destination")
    var destination: String

    @Field(key: "valid_until")
    var validUntil: Date?

    @Field(key: "is_active")
    var isActive: Bool

    @Field(key: "max_visits_count")
    var maxVisitsCount: Int?

    @Field(key: "description")
    var description: String?

    // allow bots and crawlers
    @Field(key: "allow_bots")
    var allowBots: Bool

    @Children(for: \.$parentAlias)
    var visits: [Visit]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(alias: String, destination: String, validUntil: Date? = nil, isActive: Bool = true, maxVisitsCount: Int? = nil, description: String? = nil, allowBots: Bool = false) {
        self.alias = alias
        self.destination = destination
        self.validUntil = validUntil
        self.isActive = isActive
        self.maxVisitsCount = maxVisitsCount
        self.description = description
        self.allowBots = allowBots
    }
}
