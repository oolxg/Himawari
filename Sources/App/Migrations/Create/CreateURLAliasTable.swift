//
// Created by Oleg on 09.02.23.
//

import Foundation
import Fluent

struct CreateURLAliasTable: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(URLAlias.schema)
            .id()
            .field("alias", .string, .required)
            .unique(on: "alias")
            .field("destination", .string, .required)
            .field("valid_until", .datetime)
            .field("is_active", .bool, .required)
            .field("visits", .array(of: .uuid))
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(URLAlias.schema).delete()
    }
}
