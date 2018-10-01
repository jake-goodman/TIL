import Vapor
import Fluent

class AcronymsController: RouteCollection {
    
    func boot(router: Router) throws {
        let acronymsRoute = router.grouped("api", "acronyms")
        acronymsRoute.get(use: getAllHandler)
        acronymsRoute.get(Acronym.parameter, use: getHandler)
        acronymsRoute.get(Acronym.parameter, "creator", use: getCreatorHandler)
        acronymsRoute.get(Acronym.parameter, "categories", use: getCategoriesHandler)
        acronymsRoute.post(Acronym.parameter, "categories", Category.parameter, use: addCategoriesHandler)
        acronymsRoute.get("search", use: searchHandler)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let tokenAuthGroup = acronymsRoute.grouped(tokenAuthMiddleware)
        tokenAuthGroup.post(use: createHandler)
        tokenAuthGroup.delete(Acronym.parameter, use: deleteHandler)
        tokenAuthGroup.put(Acronym.parameter, use: updateHandler)
        
    }
    
    func getAllHandler(_ req: Request) throws -> Future<[Acronym]> {
        return Acronym.query(on: req).all()
    }
    
    func createHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.content.decode(AcronymCreateData.self).flatMap(to: Acronym.self) { acronymData in
            let user = try req.requireAuthenticated(User.self)
            let acronym = try Acronym(short: acronymData.short, long: acronymData.long, creatorID: user.requireID())
            return acronym.save(on: req)
        }
    }
    
    func getHandler(_ req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    //^  We make Acronym model conform to Paramter, so that we can have Vapor do haeavy lifting. Otherwise we would be responsible for passing in ID as param and checking for it to work etc.
    
    func deleteHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try req.parameters.next(Acronym.self).flatMap(to: HTTPStatus.self) { acronym in
            return acronym.delete(on: req).transform(to: .noContent)
        }
    }
    
    func updateHandler(_ req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(AcronymCreateData.self)) { acronym, acronymData in
            acronym.short = acronymData.short
            acronym.long = acronymData.long
            acronym.creatorID = try req.requireAuthenticated(User.self).requireID()
            return acronym.save(on: req)
        }
    }
    
    func getCreatorHandler(_ req: Request) throws -> Future<User> {
        return try req.parameters.next(Acronym.self).flatMap(to: User.self) { acronym in
            return acronym.creator.get(on: req)
        }
    }
    
    func getCategoriesHandler(_ req: Request) throws -> Future<[Category]> {
        return try req.parameters.next(Acronym.self).flatMap(to: [Category].self) { acronym in
            return try acronym.categories.query(on: req).all()
        }
    }
    
    func addCategoriesHandler(_ req: Request) throws -> Future<HTTPStatus> {
        return try flatMap(to: HTTPStatus.self, req.parameters.next(Acronym.self), req.parameters.next(Category.self)) { acronym, category in
            let pivot =  try AcronymsCategoryPivot(acronym.requireID(), category.requireID())
            return pivot.save(on: req).transform(to: .ok)
        }
    }
    
    
    func searchHandler(_ req: Request) throws -> Future<[Acronym]> {
        guard let searchTerm = req.query[String.self, at: "term"] else {
            throw Abort(.badRequest, reason: "Missing search term in reqeust")
        }
        
        //        return Acronym.query(on: req).filter(\.short == searchTerm).all() // Use this for single filter
        return Acronym.query(on: req).group(.or) { or in
            or.filter(\.short == searchTerm)
            or.filter(\.long == searchTerm)
            }.all()
    }
}

struct AcronymCreateData: Content {
    let short: String
    let long: String
}






























