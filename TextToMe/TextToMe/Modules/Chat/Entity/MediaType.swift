import Foundation

enum MediaType {
    case image
    case video
    case audio

    var fileExtension: String {
        switch self {
        case .image: return "jpg"
        case .video: return "mov"
        case .audio: return "m4a"
        }
    }

    var mimeType: String {
        switch self {
        case .image: return "image/jpeg"
        case .video: return "video/quicktime"
        case .audio: return "audio/m4a"
        }
    }
}
