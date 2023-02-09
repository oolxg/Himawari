import Vapor

func routes(_ app: Application) throws {
    try app.register(collection: AliasController())
    try app.register(collection: RedirectController())
}
