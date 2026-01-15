import Vapor

struct AppLoggerMiddleware: Middleware {
    func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        let start = Date()
        request.logger.info("[\(request.method)] \(request.url.path) started")
        
        return next.respond(to: request).map { response in
            let duration = Date().timeIntervalSince(start)
            request.logger.info("[\(request.method)] \(request.url.path) finished in \(String(format: "%.3f", duration))s with status \(response.status.code)")
            return response
        }
    }
}
