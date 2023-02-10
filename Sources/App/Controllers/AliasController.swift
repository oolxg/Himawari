//
// Created by Oleg on 09.02.23.
//

import Foundation
import Vapor
import Fluent


struct AliasController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let aliases = routes.grouped("api").grouped("v1")
        aliases.get(use: index)
        aliases.post(use: create)
        aliases.put(use: update)
        aliases.delete(use: delete)
    }
    
    func index(req: Request) async throws -> [URLAlias] {
        try await URLAlias.query(on: req.db).all()
    }
    
    func create(req: Request) async throws -> URLAlias {
        let aliasRequest = try req.content.decode(CreateAliasRequest.self)
        
        if let aliasURL = aliasRequest.alias,
           try await URLAlias.query(on: req.db).filter(\.$alias == aliasURL).first() != nil {
            throw Abort(.conflict, reason: "Alias already exists")
        }

        var aliasString = aliasRequest.alias ?? String.randomString(length: 3)

        while try await URLAlias.query(on: req.db).filter(\.$alias == aliasString).first() != nil {
            aliasString = String.randomString(length: 3)
        }

        guard aliasRequest.destination.isValidURL() else {
            throw Abort(.badRequest, reason: "Invalid destination URL")
        }
        
        if let validUntil = aliasRequest.validUntil, validUntil < Date() {
            throw Abort(.badRequest, reason: "Invalid validUntil date")
        }

        let alias = URLAlias(
            alias: aliasString,
            destination: aliasRequest.destination,
            validUntil: aliasRequest.validUntil,
            maxVisitsCount: aliasRequest.maxVisitsCount
        )

        try await alias.save(on: req.db)
        
        return alias
    }
    
    func update(req: Request) async throws -> HTTPStatus {
        let aliasRequest = try req.content.decode(UpdateAliasRequest.self)

        if aliasRequest.validUntil == nil && aliasRequest.isActive == nil && aliasRequest.maxVisitsCount == nil {
            throw Abort(.badRequest, reason: "Nothing to update")
        }

        if let alias = try await URLAlias.find(aliasRequest.aliasID, on: req.db) {
            alias.validUntil = aliasRequest.validUntil
            alias.isActive = aliasRequest.isActive ?? alias.isActive
            alias.maxVisitsCount = aliasRequest.maxVisitsCount
            try await alias.save(on: req.db)
            return .ok
        }
        
        return .notFound
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        let aliasRequest = try req.content.decode(DeleteAliasRequest.self)
        
        if let alias = try await URLAlias.query(on: req.db).filter(\.$id == aliasRequest.aliasID).first() {
            try await Visit.query(on: req.db).filter(\.$parentAlias.$id == alias.id!).delete()
            try await alias.delete(on: req.db)
            return .ok
        }

        return .notFound
    }
}
