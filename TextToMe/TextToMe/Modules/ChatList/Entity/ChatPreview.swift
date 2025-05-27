import Foundation
import UIKit

struct ChatPreview {
    let id: String
    let name: String
    let lastMessage: String
    let lastMessageDate: Date?
    let type: String
    let members: [String] 
    let avatarURL: String?
}
