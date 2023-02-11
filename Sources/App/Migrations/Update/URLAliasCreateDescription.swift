//
// Created by Oleg on 11.02.23.
//

import Foundation
import Fluent


struct URLAliasCreateDescription: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(URLAlias.schema)
            .field("description", .string)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(URLAlias.schema)
            .deleteField("description")
            .update()
    }
}
