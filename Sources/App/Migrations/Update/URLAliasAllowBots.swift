//
// Created by Oleg on 17.02.23.
//

import Foundation
import Fluent

struct URLAliasAllowBots: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(URLAlias.schema)
            .field("allow_bots", .bool, .required, .sql(.default(false)))
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(URLAlias.schema)
            .deleteField("allow_bots")
            .update()
    }
}
