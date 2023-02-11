//
// Created by Oleg on 11.02.23.
//

import Foundation
import Fluent
import SQLKit

struct UpdateVisitAddIsSuccessful: Migration {
    func prepare(on database: Database) -> EventLoopFuture<Void> {
        let defaultValue = SQLColumnConstraintAlgorithm.default(true)

        return database.schema(Visit.schema)
            .field("is_successful", .bool, .required, .sql(defaultValue))
            .update()
    }

    func revert(on database: Database) -> EventLoopFuture<Void> {
        database.schema(Visit.schema)
            .deleteField("is_successful")
            .update()
    }
}
