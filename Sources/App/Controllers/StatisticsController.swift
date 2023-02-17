//
// Created by Oleg on 10.02.23.
//

import Foundation
import Vapor
import Fluent


struct StatisticsController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get("stat", ":aliasID", use: getVisitsForAlias)
        routes.get("stat", use: getVisits)
    }
    
    func getVisitsForAlias(req: Request) async throws -> [Visit] {
        guard let aliasID = req.parameters.get("aliasID", as: UUID.self) else {
            throw Abort(.notFound)
        }
        
        guard let alias = try await URLAlias.find(aliasID, on: req.db) else {
            throw Abort(.notFound)
        }

        let showOnlySuccessful = req.query["showOnlySuccessful"] as Bool? ?? false

        let visits: [Visit]

        if showOnlySuccessful {
            visits = try await alias.$visits.query(on: req.db)
                    .filter(\.$isSuccessful == true)
                    .sort(\.$createdAt, .descending)
                    .all()
        } else {
            visits = try await alias.$visits.get(on: req.db)
                    .sorted(by: { $0.createdAt! > $1.createdAt! })
        }

        for visit in visits {
            _ = try await visit.$parentAlias.get(on: req.db)
        }
        
        return visits
    }
    
    func getVisits(req: Request) async throws -> [Visit] {
        let limit = req.query["limit"] as Int? ?? 100
        let offset = req.query["offset"] as Int? ?? 0
        let showOnlySuccessful = req.query["showOnlySuccessful"] as Bool? ?? false
        
        let visits: [Visit]

        if showOnlySuccessful {
            visits = try await Visit.query(on: req.db)
                    .filter(\.$isSuccessful == true)
                    .limit(limit)
                    .offset(offset)
                    .sort(\.$createdAt, .descending)
                    .all()
        } else {
            visits = try await Visit.query(on: req.db)
                    .limit(limit)
                    .offset(offset)
                    .sort(\.$createdAt, .descending)
                    .all()
        }
        
        for visit in visits {
            _ = try await visit.$parentAlias.get(on: req.db)
        }
        
        return visits
    }
}
