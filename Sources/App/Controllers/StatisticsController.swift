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
        
        return try await alias.$visits.get(on: req.db)
    }
    
    func getVisits(req: Request) async throws -> [Visit] {
        let limit = req.query["limit"] as Int? ?? 100
        let offset = req.query["offset"] as Int? ?? 0
        
        return try await Visit.query(on: req.db)
            .limit(limit)
            .offset(offset)
            .sort(\.$createdAt, .descending)
            .all()
    }
}
