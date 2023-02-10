//
// Created by Oleg on 09.02.23.
//

import Foundation
import Fluent
import Vapor

final class Visit: Model, Content {
    static let schema = "visits"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "alias_id")
    var parentAlias: URLAlias

    @Field(key: "ip")
    var ip: String?

    @Field(key: "user_agent")
    var userAgent: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    @Timestamp(key: "updated_at", on: .update)
    var updatedAt: Date?

    init() { }

    init(aliasID: UUID, ip: String?, userAgent: String?) {
        self.$parentAlias.id = aliasID
        self.ip = ip
        self.userAgent = userAgent
    }
}
