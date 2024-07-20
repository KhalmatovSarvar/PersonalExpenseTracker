import UIKit

public struct ImageWrapper: Codable {
    public let image: UIImage

    public enum CodingKeys: String, CodingKey {
        case image
    }

    public init(image: UIImage) {
        self.image = image
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let data = try container.decode(Data.self, forKey: CodingKeys.image)
        guard let image = UIImage(data: data) else {
            throw DecodingError.dataCorruptedError(forKey: .image, in: container, debugDescription: "Failed to decode image data")
        }
        self.image = image
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        guard let data = image.pngData() else {
            throw EncodingError.invalidValue(image, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Failed to encode image"))
        }
        try container.encode(data, forKey: CodingKeys.image)
    }
}
