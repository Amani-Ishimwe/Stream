import App
import Vapor

@main
struct AppMain {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        
        // Use the modern async initializer
        let app = try await Application.make(env)
        
        do {
            // This matches your 'configure' function which is now async
            try await configure(app)
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }
        
        try await app.execute()
        try await app.asyncShutdown()
    }
}

