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
        let createRequest = try req.content.decode(CreateAliasRequest.self)
        
        if let aliasURL = createRequest.alias,
           try await URLAlias.query(on: req.db).filter(\.$alias == aliasURL).first() != nil {
            throw Abort(.conflict, reason: "Alias already exists")
        }

        var aliasString = createRequest.alias ?? String.randomString(length: 3)

        while try await URLAlias.query(on: req.db).filter(\.$alias == aliasString).first() != nil {
            aliasString = String.randomString(length: 3)
        }

        guard createRequest.destination.isValidURL() else {
            throw Abort(.badRequest, reason: "Invalid destination URL")
        }
        
        if let validUntil = createRequest.validUntil, validUntil < Date() {
            throw Abort(.badRequest, reason: "Invalid validUntil date")
        }

        guard createRequest.maxVisitsCount == nil || createRequest.maxVisitsCount! > 0 else {
            throw Abort(.badRequest, reason: "Invalid maxVisitsCount value")
        }

        let alias = URLAlias(
            alias: aliasString,
            destination: createRequest.destination,
            validUntil: createRequest.validUntil,
            maxVisitsCount: createRequest.maxVisitsCount,
            description: createRequest.description,
            allowBots: createRequest.allowBots ?? false
        )

        try await alias.save(on: req.db)
        
        return alias
    }
    
    func update(req: Request) async throws -> HTTPStatus {
        let updateRequest = try req.content.decode(UpdateAliasRequest.self)

        guard updateRequest.hasUpdates else {
            throw Abort(.badRequest, reason: "Nothing to update")
        }

        if let alias = try await URLAlias.find(updateRequest.aliasID, on: req.db) {
            if let url = updateRequest.newDestination, !url.isValidURL() {
                throw Abort(.badRequest, reason: "Invalid destination URL")
            }

            alias.validUntil = updateRequest.validUntil
            alias.isActive = updateRequest.isActive ?? alias.isActive
            alias.maxVisitsCount = updateRequest.maxVisitsCount
            alias.destination = updateRequest.newDestination ?? alias.destination
            alias.description = updateRequest.description ?? alias.description
            alias.allowBots = updateRequest.allowBots ?? alias.allowBots
            try await alias.update(on: req.db)
            return .ok
        }
        
        return .notFound
    }
    
    func delete(req: Request) async throws -> HTTPStatus {
        let deleteRequest = try req.content.decode(DeleteAliasRequest.self)
        
        if let alias = try await URLAlias.query(on: req.db).filter(\.$id == deleteRequest.aliasID).first() {
            try await alias.$visits.get(on: req.db).delete(force: true, on: req.db)
            try await alias.delete(on: req.db)
            return .ok
        }

        return .notFound
    }
}
