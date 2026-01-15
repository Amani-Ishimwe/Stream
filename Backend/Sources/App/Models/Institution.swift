import Fluent
import Vapor

final class Institution: Model, Content {
    static let schema = "institutions"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "type")
    var type: String // "BANK" or "MOBILE_MONEY"

    @Field(key: "icon_symbol")
    var iconSymbol: String // SF Symbol name for frontend

    @Field(key: "primary_color_hex")
    var primaryColorHex: String

    @Field(key: "is_active")
    var isActive: Bool

    init() { }

    init(id: UUID? = nil, name: String, type: String, iconSymbol: String, primaryColorHex: String, isActive: Bool = true) {
        self.id = id
        self.name = name
        self.type = type
        self.iconSymbol = iconSymbol
        self.primaryColorHex = primaryColorHex
        self.isActive = isActive
    }
}
