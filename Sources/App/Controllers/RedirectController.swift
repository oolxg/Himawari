//
// Created by Oleg on 09.02.23.
//

import Foundation
import Vapor
import Fluent

struct RedirectController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        routes.get(":alias", use: redirect)
    }

    func redirect(req: Request) async throws -> Response {
        guard let aliasStr = req.parameters.get("alias") else {
            throw Abort(.notFound)
        }

        guard let alias = try await URLAlias.query(on: req.db).filter(\.$alias == aliasStr).first() else {
            throw Abort(.notFound)
        }
        
        // header is needed if service used via Cloudflare proxy
        let ip = req.headers["CF-Connecting-IP"].first ?? req.remoteAddress?.ipAddress
        let ua = req.headers.first(name: .userAgent)
        
        let visit = Visit(aliasID: alias.id!, ip: ip, userAgent: ua)

        let userAgent = req.headers.first(name: .userAgent) ?? ""
        let isCrawlerOrBot = userAgent.contains("bot") || userAgent.contains("crawler") || userAgent.contains("spider")
        if !alias.allowBots && isCrawlerOrBot {
            try await visit.save(on: req.db)
            throw Abort(.notFound)
        }

        if let validUntil = alias.validUntil, validUntil < Date() {
            try await visit.save(on: req.db)
            throw Abort(.notFound)
        }

        if !alias.isActive {
            try await visit.save(on: req.db)
            throw Abort(.notFound)
        }

        let visitsCount = try await alias.$visits.get(on: req.db).count

        if let maxVisitsCount = alias.maxVisitsCount, visitsCount >= maxVisitsCount {
            try await visit.save(on: req.db)
            throw Abort(.notFound)
        }

        visit.isSuccessful = true
        try await visit.save(on: req.db)
        
        return req.redirect(to: alias.destination)
    }
}
