import UIKit

final class MessageCell: UITableViewCell {
    static let reuseId = "MessageCell"

    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private let timestampLabel = UILabel()
    private let avatarImageView = UIImageView()
    private let mediaImageView = UIImageView()

    private var leadingConstraint: NSLayoutConstraint?
    private var trailingConstraint: NSLayoutConstraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with message: Message, currentUser: String) {
        let isMine = message.sender == currentUser
        print("🟨 DEBUG: message.sender = \(message.sender), currentUser = \(currentUser), isMine = \(isMine)")


        leadingConstraint?.isActive = false
        trailingConstraint?.isActive = false

        if isMine {
            trailingConstraint?.isActive = true
            avatarImageView.isHidden = true

            bubbleView.backgroundColor = .systemYellow
            messageLabel.textColor = .black
            timestampLabel.textColor = .darkGray

            messageLabel.textAlignment = .right
            timestampLabel.textAlignment = .right
        } else {
            leadingConstraint?.isActive = true
            avatarImageView.isHidden = false

            bubbleView.backgroundColor = UIColor(red: 204/255, green: 153/255, blue: 0/255, alpha: 1) // тёмно-жёлтый
            messageLabel.textColor = .white
            timestampLabel.textColor = .lightText

            messageLabel.textAlignment = .left
            timestampLabel.textAlignment = .left
        }



        // Содержимое
        if message.isDeleted {
            messageLabel.text = "сообщение удалено"
            messageLabel.font = .italicSystemFont(ofSize: 15)
        } else if message.isMedia {
            if let url = message.mediaURL, url.hasSuffix(".m4a") {
                messageLabel.text = "[голосовое сообщение]"
            } else {
                messageLabel.text = "[медиафайл]"
            }
            messageLabel.font = .systemFont(ofSize: 16, weight: .medium)
        } else {
            messageLabel.text = message.text
            messageLabel.font = .systemFont(ofSize: 16)
        }

        // Медиа (фото)
        if message.isMedia, let urlStr = message.mediaURL, let url = URL(string: urlStr) {
            messageLabel.isHidden = true
            mediaImageView.isHidden = false

            URLSession.shared.dataTask(with: url) { data, _, _ in
                guard let encrypted = data,
                      let decrypted = MediaService.shared.decryptMedia(from: encrypted, chatId: message.id),
                      let image = UIImage(data: decrypted) else {
                    DispatchQueue.main.async {
                        self.mediaImageView.image = UIImage(systemName: "xmark.circle")
                    }
                    return
                }
                DispatchQueue.main.async {
                    self.mediaImageView.image = image
                }
            }.resume()
        } else {
            mediaImageView.isHidden = true
            messageLabel.isHidden = false
        }

        // Время
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        timestampLabel.text = formatter.string(from: message.timestamp)
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear

        contentView.addSubview(avatarImageView)
        contentView.addSubview(bubbleView)
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(timestampLabel)
        bubbleView.addSubview(mediaImageView)

        [avatarImageView, bubbleView, messageLabel, timestampLabel, mediaImageView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        // Avatar
        avatarImageView.setWidth(32)
        avatarImageView.setHeight(32)
        avatarImageView.layer.cornerRadius = 16
        avatarImageView.clipsToBounds = true
        avatarImageView.image = UIImage(named: "defaultAvatar")
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.pinBottom(to: contentView, 8)
        avatarImageView.pinLeft(to: contentView, 8)

        // Bubble
        bubbleView.layer.cornerRadius = 18
        bubbleView.clipsToBounds = true
        bubbleView.setWidth(mode: .lsOE, 0.75 * UIScreen.main.bounds.width)
        bubbleView.pinTop(to: contentView, 8)
        bubbleView.pinBottom(to: timestampLabel.topAnchor, 4)

        // Создаём и храним constraints
        leadingConstraint = bubbleView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8)
        trailingConstraint = bubbleView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)

        // Message
        messageLabel.numberOfLines = 0
        messageLabel.pinTop(to: bubbleView, 10)
        messageLabel.pinBottom(to: bubbleView, 10)
        messageLabel.pinLeft(to: bubbleView, 14)
        messageLabel.pinRight(to: bubbleView, 14)

        // Timestamp
        timestampLabel.font = .systemFont(ofSize: 12)
        timestampLabel.pinBottom(to: contentView, 4)
        timestampLabel.pinLeft(to: bubbleView)
        timestampLabel.pinRight(to: bubbleView)

        // Media
        mediaImageView.contentMode = .scaleAspectFill
        mediaImageView.clipsToBounds = true
        mediaImageView.layer.cornerRadius = 10
        mediaImageView.pinTop(to: bubbleView, 8)
        mediaImageView.pinLeft(to: bubbleView, 8)
        mediaImageView.pinRight(to: bubbleView, 8)
        mediaImageView.setHeight(160)
    }
}
