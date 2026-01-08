//
//  DigimonCardComponent.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 07/01/26.
//

import UIKit

final class DigimonCardView: UIView {

    private let thumbnail = UIImageView()
    private let nameLabel = UILabel()
    private let metaLabel = UILabel()
    private let fieldNameStack = UIStackView()
    private let fieldIconStack = UIStackView()
    private var currentImageTask: URLSessionDataTask?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) { fatalError() }
    
    private func setupUI() {
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 12
        clipsToBounds = true
        heightAnchor.constraint(greaterThanOrEqualToConstant: 120).isActive = true

        thumbnail.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        metaLabel.translatesAutoresizingMaskIntoConstraints = false
        fieldNameStack.translatesAutoresizingMaskIntoConstraints = false
        fieldIconStack.translatesAutoresizingMaskIntoConstraints = false

        thumbnail.contentMode = .scaleAspectFill
        thumbnail.clipsToBounds = true
        thumbnail.layer.cornerRadius = 8
        thumbnail.backgroundColor = .systemGray6

        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        metaLabel.font = .systemFont(ofSize: 13)
        metaLabel.textColor = .secondaryLabel
        metaLabel.numberOfLines = 0

        fieldNameStack.axis = .horizontal
        fieldNameStack.spacing = 8
        fieldNameStack.distribution = .fillProportionally

        fieldIconStack.axis = .horizontal
        fieldIconStack.spacing = 6

        addSubview(thumbnail)
        addSubview(nameLabel)
        addSubview(metaLabel)
        addSubview(fieldNameStack)
        addSubview(fieldIconStack)

        NSLayoutConstraint.activate([
            thumbnail.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            thumbnail.centerYAnchor.constraint(equalTo: centerYAnchor),
            thumbnail.widthAnchor.constraint(equalToConstant: 80),
            thumbnail.heightAnchor.constraint(equalToConstant: 80),

            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            nameLabel.leadingAnchor.constraint(equalTo: thumbnail.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),

            metaLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
            metaLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            metaLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),

            fieldNameStack.topAnchor.constraint(equalTo: metaLabel.bottomAnchor, constant: 8),
            fieldNameStack.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            fieldNameStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),

            fieldIconStack.topAnchor.constraint(equalTo: fieldNameStack.bottomAnchor, constant: 6),
            fieldIconStack.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            fieldIconStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }

    func configure(with viewModel: DigimonCardViewModel) {
        currentImageTask?.cancel()
        currentImageTask = nil
        
        nameLabel.text = viewModel.name
        
        thumbnail.setImage(from: viewModel.imageUrl)
        
        if let meta = viewModel.metaInfo, !meta.isEmpty {
            metaLabel.text = meta
            metaLabel.isHidden = false
        } else {
            metaLabel.isHidden = true
        }
        
        fieldNameStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        fieldIconStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if !viewModel.fields.isEmpty {
            viewModel.fields.forEach { field in
                let label = UILabel()
                label.text = field.name
                label.font = .systemFont(ofSize: 12)
                label.textColor = .secondaryLabel
                label.textColor = .secondaryLabel
                fieldNameStack.addArrangedSubview(label)
                
                if let iconUrl = field.iconUrl {
                    let imageView = UIImageView()
                    imageView.setImage(from: iconUrl)
                    imageView.contentMode = .scaleAspectFit
                    imageView.widthAnchor.constraint(equalToConstant: 24).isActive = true
                    imageView.heightAnchor.constraint(equalToConstant: 24).isActive = true
                    fieldIconStack.addArrangedSubview(imageView)
                }
            }
            fieldNameStack.isHidden = false
            fieldIconStack.isHidden = false
        } else {
            fieldNameStack.isHidden = true
            fieldIconStack.isHidden = true
        }
    }
}

final class DigimonLoadingCell: UITableViewCell {
    private let containerView = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)
    private let nameLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        containerView.backgroundColor = .secondarySystemBackground
        containerView.layer.cornerRadius = 12
        containerView.clipsToBounds = true
        
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        contentView.addSubview(containerView)
        containerView.addSubview(loadingIndicator)
        containerView.addSubview(nameLabel)
        
        containerView.pinToEdges(of: contentView, inset: UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16))
        
        NSLayoutConstraint.activate([
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),
            
            nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 104),
            nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            loadingIndicator.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            loadingIndicator.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8)
        ])
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    func configure(name: String) {
        nameLabel.text = name
        loadingIndicator.startAnimating()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        loadingIndicator.stopAnimating()
    }
}

struct DigimonCardViewModel {
    let name: String
    let imageUrl: String?
    let metaInfo: String?
    let fields: [FieldViewModel]
    
    struct FieldViewModel {
        let name: String
        let iconUrl: String?
    }
    
    init(from model: DigimonModel) {
        self.name = model.name
        self.imageUrl = model.image
        
        guard let detail = model.cachedDetail else {
            self.metaInfo = nil
            self.fields = []
            return
        }
        
        var metaParts: [String] = []
        if let level = detail.levels?.first?.level {
            metaParts.append(level)
        }
        if let type = detail.types?.first?.type {
            metaParts.append(type)
        }
        if let attribute = detail.attributes?.first?.attribute {
            metaParts.append(attribute)
        }
        self.metaInfo = metaParts.isEmpty ? nil : metaParts.joined(separator: " | ")
        
        self.fields = detail.fields?.map { field in
            FieldViewModel(name: field.field, iconUrl: field.image)
        } ?? []
    }
}

final class DigimonCell: UITableViewCell {
    private let cardView = DigimonCardView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.addSubview(cardView)
        cardView.pinToEdges(of: contentView, inset: UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 16))
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(with digimon: DigimonModel) {
        let viewModel = DigimonCardViewModel(from: digimon)
        cardView.configure(with: viewModel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

extension UIView {
    func pinToEdges(
        of view: UIView,
        inset: UIEdgeInsets = .zero
    ) {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: inset.top),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset.bottom)
        ])
    }
}
