import Fluent
import FluentPostgresDriver
import Vapor

// configures your application
public func configure(_ app: Application) throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.databases.use(.postgres(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "HimawariUser",
        password: Environment.get("DATABASE_PASSWORD") ?? "12345678",
        database: Environment.get("DATABASE_NAME") ?? "HimawariDB"
    ), as: .psql)

    try runMigrations(app)
    // register routes
    try routes(app)
}

public func runMigrations(_ app: Application) throws {
    app.migrations.add(CreateURLAliasTable())
    app.migrations.add(CreateVisitTable())
    app.migrations.add(AddURLAliasMaxVisitsCount())
    
    if app.environment == .testing {
        try app.autoRevert().wait()
    }
    
    try app.autoMigrate().wait()
}
