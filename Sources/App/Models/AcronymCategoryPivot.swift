import Vapor
import Foundation
import FluentPostgreSQL

final class AcronymsCategoryPivot: PostgreSQLUUIDPivot {
    var id: UUID?
    var acronymID: Acronym.ID
    var categoryID: Category.ID
    
    typealias Left = Acronym
    typealias Right = Category
    
    static let leftIDKey: LeftIDKey = \AcronymsCategoryPivot.acronymID
    static let rightIDKey
        : RightIDKey = \AcronymsCategoryPivot.categoryID
    
    init(_ acronymID: Acronym.ID, _ categoryID: Category.ID) {
        self.acronymID = acronymID
        self.categoryID = categoryID
    }
}

extension AcronymsCategoryPivot: Migration {}
