import UIKit

final class ChatCell: UITableViewCell {
    static let reuseId = "ChatCell"

    private let nameLabel = UILabel()
    private let messageLabel = UILabel()
    private let avatarImageView = UIImageView()
    private let dateLabel = UILabel()
    private let avatarColors: [UIColor] = [
        .systemRed, .systemBlue, .systemGreen, .systemOrange,
        .systemPink, .systemTeal, .systemIndigo, .systemPurple
    ]

    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with chat: ChatPreview, currentUser: String) {
        // Название
        if chat.type == "dialog" {
            if let other = chat.members.first(where: { $0 != currentUser }) {
                nameLabel.text = truncateName(other)
            } else {
                nameLabel.text = truncateName(chat.name)
            }
        } else {
            nameLabel.text = truncateName(chat.name)
        }

        messageLabel.text = chat.lastMessage

        if let date = chat.lastMessageDate {
            dateLabel.text = format(date: date)
        } else {
            dateLabel.text = ""
        }

        // Аватар
        if let urlString = chat.avatarURL, let url = URL(string: urlString) {
            URLSession.shared.dataTask(with: url) { data, _, _ in
                if let data = data, let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.avatarImageView.image = image
                    }
                }
            }.resume()
        } else {
            let color = generateColor(for: chat.id)
            let size = CGSize(width: 40, height: 40)
            let renderer = UIGraphicsImageRenderer(size: size)
            let image = renderer.image { ctx in
                ctx.cgContext.setFillColor(color.cgColor)
                ctx.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            }
            avatarImageView.image = image
        }

    }

    private func truncateName(_ name: String) -> String {
        name.count > 8 ? "\(name.prefix(8))..." : name
    }

    private func format(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }

    private func setup() {
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = .label
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail

        messageLabel.font = UIFont.systemFont(ofSize: 14)
        messageLabel.textColor = .gray
        messageLabel.numberOfLines = 1
        messageLabel.lineBreakMode = .byTruncatingTail

        dateLabel.font = UIFont.systemFont(ofSize: 12)
        dateLabel.textColor = .gray
        dateLabel.textAlignment = .right

        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.setWidth(40)
        avatarImageView.setHeight(40)

        [nameLabel, messageLabel, avatarImageView, dateLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }

        NSLayoutConstraint.activate([
            avatarImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            nameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: avatarImageView.leadingAnchor, constant: -12),

            messageLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            messageLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(lessThanOrEqualTo: avatarImageView.leadingAnchor, constant: -12),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: -8),
            dateLabel.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func generateColor(for chatId: String) -> UIColor {
        let index = abs(chatId.hashValue) % avatarColors.count
        return avatarColors[index]
    }

}
