import Vapor

class CategoriesController: RouteCollection {
    
    func boot(router: Router) throws {
        let categoriesRoute = router.grouped("api", "categories")
        categoriesRoute.post(use: createHandler)
        categoriesRoute.get(use: getAllHandler)
        categoriesRoute.get(Category.parameter, use: getHandler)
    }
    
    // Create
    func createHandler(_ req: Request) throws -> Future<Category> {
        let category = try req.content.decode(Category.self)
        return category.save(on: req)
    }
    
    // Get All
    func getAllHandler(_ req: Request) throws -> Future<[Category]> {
        return Category.query(on: req).all()
    }
    
    // Get
    func getHandler(_ req: Request) throws -> Future<Category>{
        return try req.parameters.next(Category.self)
    }
    
}
