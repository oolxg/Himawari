//
// Created by Oleg on 09.02.23.
//

import Foundation
import Fluent

struct AddURLAliasMaxVisitsCount: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        database.schema(URLAlias.schema)
            .field("max_visits_count", .int)
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(URLAlias.schema)
            .deleteField("max_visits_count")
            .update()
    }
}
