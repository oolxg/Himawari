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

    @Children(for: \.$alias)
    var visits: [Visit]

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(alias: String, destination: String, validUntil: Date? = nil, isActive: Bool = true, maxVisitsCount: Int? = nil) {
        self.alias = alias
        self.destination = destination
        self.validUntil = validUntil
        self.isActive = isActive
        self.maxVisitsCount = maxVisitsCount
    }
}
