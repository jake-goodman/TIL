import FluentPostgreSQL
import Vapor
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(FluentPostgreSQLProvider())
    try services.register(AuthenticationProvider())
    
    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    /// middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)
    
    // Configure a PostgreSQL database
    let config = PostgreSQLDatabaseConfig(hostname: "localhost", port: 5432, username: "Jake", database: "aeosdev", password: nil, transport: .cleartext)
    let postgres = PostgreSQLDatabase(config: config)
    
    /// Register the configured PostgreSQL database to the database config.
    var databases = DatabasesConfig()
    databases.add(database: postgres, as: .psql)
    services.register(databases)
    
    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: Acronym.self, database: .psql)
    migrations.add(model: User.self, database: .psql)
    migrations.add(model: Category.self, database: .psql)
    migrations.add(model: AcronymsCategoryPivot.self, database: .psql)
    migrations.add(model: Token.self, database: .psql)
    
    services.register(migrations)
    
    User.Public.defaultDatabase = .psql // Set up model with databse used. This is normally done in a migration, but we will use the standard User migration for this
    
}
