import Vapor
import FluentPostgreSQL
import Authentication

final class User: Codable {
    var id: UUID?
    var name: String
    var username: String
    var password: String
    
    init(name: String, username: String, password: String) {
        self.name = name
        self.username = username
        self.password = password
    }
    
    final class Public: Codable {
        var id: UUID?
        var name: String
        var username: String
        
        init(name: String, username: String) {
            self.name = name
            self.username = username
        }
    }
}

extension User: PostgreSQLUUIDModel {}
extension User: Migration {}
extension User: Content {}
extension User: Parameter {}

extension User {
    var acronyms: Children<User, Acronym> {
        return children(\.creatorID)
    }
}

extension User: BasicAuthenticatable {
    static let usernameKey: UsernameKey = \User.username
    static let passwordKey: PasswordKey = \User.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

extension User.Public: PostgreSQLUUIDModel {
    static let entity = User.entity
    // In Fluent, table names are inferred from class name. We want Public model to have same table name as standard user so when we perform a query it uses the right table. Setting the 'entity' property overrides table name.
}
extension User.Public: Content {}
extension User.Public: Parameter {}




