//
// Created by Oleg on 09.02.23.
//

import Foundation
import Fluent


struct CreateVisitTable: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Visit.schema)
            .id()
            .field("alias_id", .uuid, .required, .references(URLAlias.schema, "id"))
            .field("ip", .string)
            .field("user_agent", .string)
            .field("created_at", .datetime, .required)
            .field("updated_at", .datetime, .required)
            .create()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Visit.schema).delete()
    }
}
