//
//  DigimonDetailViewController.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 07/01/26.
//

import UIKit
import Combine

final class DigimonDetailViewController: UIViewController {

    private let viewModel: DigimonDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    init(href: String, cachedDetail: DigimonDetail?) {
        self.viewModel = DigimonDetailViewModel(
            href: href,
            cachedDetail: cachedDetail
        )
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    
    private let basicInfoCard = UIView()
    private let basicInfoStack = UIStackView()

    private let fieldsCard = UIView()
    private let fieldsTitleLabel = UILabel()
    private let fieldsContainer = UIView()

    private let descriptionCard = UIView()
    private let descriptionTitleLabel = UILabel()
    private let descriptionLabel = UILabel()
    
    private let skillsCard = UIView()
    private let skillsTitleLabel = UILabel()
    private let skillsStack = UIStackView()

    private let priorEvolutionsCard = UIView()
    private let priorEvolutionsTitleLabel = UILabel()
    private let priorEvolutionsStack = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        setupUI()
        bindViewModel()

        Task { await viewModel.load() }
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        imageView.contentMode = .scaleAspectFit
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        nameLabel.font = .systemFont(ofSize: 28, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.numberOfLines = 0

        setupBasicInfoCard()
        
        setupFieldsCard()
        
        setupDescriptionCard()

        setupSkillsCard()

        setupPriorEvolutionsCard()

        contentStack.addArrangedSubview(imageView)
        contentStack.addArrangedSubview(nameLabel)
        contentStack.addArrangedSubview(basicInfoCard)
        contentStack.addArrangedSubview(fieldsCard)
        contentStack.addArrangedSubview(descriptionCard)
        contentStack.addArrangedSubview(skillsCard)
        contentStack.addArrangedSubview(priorEvolutionsCard)
    }
    
    private func setupBasicInfoCard() {
        basicInfoCard.backgroundColor = .secondarySystemBackground
        basicInfoCard.layer.cornerRadius = 12
        basicInfoCard.translatesAutoresizingMaskIntoConstraints = false
        
        basicInfoStack.axis = .vertical
        basicInfoStack.spacing = 12
        basicInfoStack.translatesAutoresizingMaskIntoConstraints = false
        
        basicInfoCard.addSubview(basicInfoStack)
        
        NSLayoutConstraint.activate([
            basicInfoStack.topAnchor.constraint(equalTo: basicInfoCard.topAnchor, constant: 16),
            basicInfoStack.leadingAnchor.constraint(equalTo: basicInfoCard.leadingAnchor, constant: 16),
            basicInfoStack.trailingAnchor.constraint(equalTo: basicInfoCard.trailingAnchor, constant: -16),
            basicInfoStack.bottomAnchor.constraint(equalTo: basicInfoCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupFieldsCard() {
        fieldsCard.backgroundColor = .secondarySystemBackground
        fieldsCard.layer.cornerRadius = 12
        fieldsCard.translatesAutoresizingMaskIntoConstraints = false
        
        fieldsTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        fieldsTitleLabel.text = "Fields"
        fieldsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        fieldsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        fieldsCard.addSubview(fieldsTitleLabel)
        fieldsCard.addSubview(fieldsContainer)
        
        NSLayoutConstraint.activate([
            fieldsTitleLabel.topAnchor.constraint(equalTo: fieldsCard.topAnchor, constant: 16),
            fieldsTitleLabel.leadingAnchor.constraint(equalTo: fieldsCard.leadingAnchor, constant: 16),
            fieldsTitleLabel.trailingAnchor.constraint(equalTo: fieldsCard.trailingAnchor, constant: -16),
            
            fieldsContainer.topAnchor.constraint(equalTo: fieldsTitleLabel.bottomAnchor, constant: 12),
            fieldsContainer.leadingAnchor.constraint(equalTo: fieldsCard.leadingAnchor, constant: 16),
            fieldsContainer.trailingAnchor.constraint(equalTo: fieldsCard.trailingAnchor, constant: -16),
            fieldsContainer.bottomAnchor.constraint(equalTo: fieldsCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupDescriptionCard() {
        descriptionCard.backgroundColor = .secondarySystemBackground
        descriptionCard.layer.cornerRadius = 12
        descriptionCard.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        descriptionTitleLabel.text = "Description"
        descriptionTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.font = .systemFont(ofSize: 15)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionCard.addSubview(descriptionTitleLabel)
        descriptionCard.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionTitleLabel.topAnchor.constraint(equalTo: descriptionCard.topAnchor, constant: 16),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: descriptionCard.leadingAnchor, constant: 16),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: descriptionCard.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionCard.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionCard.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: descriptionCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupSkillsCard() {
        skillsCard.backgroundColor = .secondarySystemBackground
        skillsCard.layer.cornerRadius = 12
        skillsCard.translatesAutoresizingMaskIntoConstraints = false
        
        skillsTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        skillsTitleLabel.text = "Skills"
        skillsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        skillsStack.axis = .vertical
        skillsStack.spacing = 12
        skillsStack.translatesAutoresizingMaskIntoConstraints = false
        
        skillsCard.addSubview(skillsTitleLabel)
        skillsCard.addSubview(skillsStack)
        
        NSLayoutConstraint.activate([
            skillsTitleLabel.topAnchor.constraint(equalTo: skillsCard.topAnchor, constant: 16),
            skillsTitleLabel.leadingAnchor.constraint(equalTo: skillsCard.leadingAnchor, constant: 16),
            skillsTitleLabel.trailingAnchor.constraint(equalTo: skillsCard.trailingAnchor, constant: -16),
            
            skillsStack.topAnchor.constraint(equalTo: skillsTitleLabel.bottomAnchor, constant: 12),
            skillsStack.leadingAnchor.constraint(equalTo: skillsCard.leadingAnchor, constant: 16),
            skillsStack.trailingAnchor.constraint(equalTo: skillsCard.trailingAnchor, constant: -16),
            skillsStack.bottomAnchor.constraint(equalTo: skillsCard.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupPriorEvolutionsCard() {
        priorEvolutionsCard.backgroundColor = .secondarySystemBackground
        priorEvolutionsCard.layer.cornerRadius = 12
        priorEvolutionsCard.translatesAutoresizingMaskIntoConstraints = false
        
        priorEvolutionsTitleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        priorEvolutionsTitleLabel.text = "Prior Evolutions"
        priorEvolutionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        priorEvolutionsStack.axis = .vertical
        priorEvolutionsStack.spacing = 12
        priorEvolutionsStack.translatesAutoresizingMaskIntoConstraints = false
        
        priorEvolutionsCard.addSubview(priorEvolutionsTitleLabel)
        priorEvolutionsCard.addSubview(priorEvolutionsStack)
        
        NSLayoutConstraint.activate([
            priorEvolutionsTitleLabel.topAnchor.constraint(equalTo: priorEvolutionsCard.topAnchor, constant: 16),
            priorEvolutionsTitleLabel.leadingAnchor.constraint(equalTo: priorEvolutionsCard.leadingAnchor, constant: 16),
            priorEvolutionsTitleLabel.trailingAnchor.constraint(equalTo: priorEvolutionsCard.trailingAnchor, constant: -16),
            
            priorEvolutionsStack.topAnchor.constraint(equalTo: priorEvolutionsTitleLabel.bottomAnchor, constant: 12),
            priorEvolutionsStack.leadingAnchor.constraint(equalTo: priorEvolutionsCard.leadingAnchor, constant: 16),
            priorEvolutionsStack.trailingAnchor.constraint(equalTo: priorEvolutionsCard.trailingAnchor, constant: -16),
            priorEvolutionsStack.bottomAnchor.constraint(equalTo: priorEvolutionsCard.bottomAnchor, constant: -16)
        ])
    }

    private func updateUI(with detail: DigimonDetail) {
        title = "Digimon"
        nameLabel.text = detail.name

        if let imageURL = detail.images?.first?.href {
            imageView.setImage(from: imageURL)
        }

        setupBasicInfo(detail)

        setupFieldsWithWrapping(detail.fields)

        if let description = detail.descriptions?.first(where: { $0.language.lowercased().contains("en") })?.description {
            descriptionLabel.text = description
            descriptionCard.isHidden = false
        } else {
            descriptionCard.isHidden = true
        }

        setupSkills(detail.skills)
       
        setupPriorEvolutions(detail.priorEvolutions)
    }
    
    private func setupBasicInfo(_ detail: DigimonDetail) {
        basicInfoStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        if let xAntibody = detail.xAntibody {
            basicInfoStack.addArrangedSubview(createInfoRow(
                label: "X-Antibody",
                value: xAntibody ? "Yes" : "No"
            ))
        }

        if let levels = detail.levels, !levels.isEmpty {
            let levelText = levels.map { $0.level }.joined(separator: ", ")
            basicInfoStack.addArrangedSubview(createInfoRow(label: "Level", value: levelText))
        }
       
        if let types = detail.types, !types.isEmpty {
            let typeText = types.map { $0.type }.joined(separator: ", ")
            basicInfoStack.addArrangedSubview(createInfoRow(label: "Type", value: typeText))
        }
        
        if let attributes = detail.attributes, !attributes.isEmpty {
            let attributeText = attributes.map { $0.attribute }.joined(separator: ", ")
            basicInfoStack.addArrangedSubview(createInfoRow(label: "Attribute", value: attributeText))
        }
        
        if let releaseDate = detail.releaseDate, !releaseDate.isEmpty {
            basicInfoStack.addArrangedSubview(createInfoRow(label: "Release Date", value: releaseDate))
        }
    }
    
    private func createInfoRow(label: String, value: String) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let labelView = UILabel()
        labelView.text = label
        labelView.font = .systemFont(ofSize: 14, weight: .semibold)
        labelView.textColor = .secondaryLabel
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        
        let valueView = UILabel()
        valueView.text = value
        valueView.font = .systemFont(ofSize: 15)
        valueView.numberOfLines = 0
        valueView.textAlignment = .right
        valueView.translatesAutoresizingMaskIntoConstraints = false
        valueView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        container.addSubview(labelView)
        container.addSubview(valueView)
        
        NSLayoutConstraint.activate([
            labelView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            labelView.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            labelView.topAnchor.constraint(greaterThanOrEqualTo: container.topAnchor),
            labelView.bottomAnchor.constraint(lessThanOrEqualTo: container.bottomAnchor),
            
            valueView.leadingAnchor.constraint(equalTo: labelView.trailingAnchor, constant: 12),
            valueView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            valueView.topAnchor.constraint(equalTo: container.topAnchor),
            valueView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func setupFieldsWithWrapping(_ fields: [DigimonField]?) {
        fieldsContainer.subviews.forEach { $0.removeFromSuperview() }
        
        guard let fields, !fields.isEmpty else {
            fieldsCard.isHidden = true
            return
        }
        
        fieldsCard.isHidden = false
        
        let itemsPerRow = 3
        var currentRow: UIStackView?
        var itemsInCurrentRow = 0
        var previousRow: UIStackView?
        
        for (index, field) in fields.enumerated() {
            if itemsInCurrentRow == 0 {
                let rowStack = UIStackView()
                rowStack.axis = .horizontal
                rowStack.spacing = 12
                rowStack.alignment = .top
                rowStack.distribution = .fillEqually
                rowStack.translatesAutoresizingMaskIntoConstraints = false
                
                fieldsContainer.addSubview(rowStack)
                
                NSLayoutConstraint.activate([
                    rowStack.leadingAnchor.constraint(equalTo: fieldsContainer.leadingAnchor),
                    rowStack.trailingAnchor.constraint(equalTo: fieldsContainer.trailingAnchor)
                ])
                
                if let previous = previousRow {
                    rowStack.topAnchor.constraint(equalTo: previous.bottomAnchor, constant: 12).isActive = true
                } else {
                    rowStack.topAnchor.constraint(equalTo: fieldsContainer.topAnchor).isActive = true
                }
                
                if index >= fields.count - itemsPerRow {
                    rowStack.bottomAnchor.constraint(equalTo: fieldsContainer.bottomAnchor).isActive = true
                }
                
                currentRow = rowStack
                previousRow = rowStack
            }
            
            let itemStack = UIStackView()
            itemStack.axis = .vertical
            itemStack.alignment = .center
            itemStack.spacing = 6
            
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
            
            if let imageURL = field.image {
                imageView.setImage(from: imageURL)
            }
            
            let label = UILabel()
            label.font = .systemFont(ofSize: 13)
            label.textColor = .label
            label.text = field.field
            label.textAlignment = .center
            label.numberOfLines = 2
            
            itemStack.addArrangedSubview(imageView)
            itemStack.addArrangedSubview(label)
            
            currentRow?.addArrangedSubview(itemStack)
            
            itemsInCurrentRow += 1
            
            if itemsInCurrentRow >= itemsPerRow {
                itemsInCurrentRow = 0
                currentRow = nil
            }
        }
        
        if let lastRow = currentRow, itemsInCurrentRow > 0 {
            let remainingSlots = itemsPerRow - itemsInCurrentRow
            for _ in 0..<remainingSlots {
                let spacer = UIView()
                lastRow.addArrangedSubview(spacer)
            }
            lastRow.bottomAnchor.constraint(equalTo: fieldsContainer.bottomAnchor).isActive = true
        }
    }
    
    private func setupSkills(_ skills: [DigimonSkill]?) {
        skillsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let skills, !skills.isEmpty else {
            skillsCard.isHidden = true
            return
        }
        
        skillsCard.isHidden = false
        
        for skill in skills {
            let skillContainer = UIView()
            skillContainer.backgroundColor = .tertiarySystemBackground
            skillContainer.layer.cornerRadius = 8
            skillContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let skillNameLabel = UILabel()
            skillNameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
            skillNameLabel.text = skill.skill
            skillNameLabel.numberOfLines = 0
            skillNameLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let skillDescLabel = UILabel()
            skillDescLabel.font = .systemFont(ofSize: 14)
            skillDescLabel.text = skill.description
            skillDescLabel.numberOfLines = 0
            skillDescLabel.textColor = .secondaryLabel
            skillDescLabel.translatesAutoresizingMaskIntoConstraints = false
            
            skillContainer.addSubview(skillNameLabel)
            skillContainer.addSubview(skillDescLabel)
            
            NSLayoutConstraint.activate([
                skillNameLabel.topAnchor.constraint(equalTo: skillContainer.topAnchor, constant: 12),
                skillNameLabel.leadingAnchor.constraint(equalTo: skillContainer.leadingAnchor, constant: 12),
                skillNameLabel.trailingAnchor.constraint(equalTo: skillContainer.trailingAnchor, constant: -12),
                
                skillDescLabel.topAnchor.constraint(equalTo: skillNameLabel.bottomAnchor, constant: 4),
                skillDescLabel.leadingAnchor.constraint(equalTo: skillContainer.leadingAnchor, constant: 12),
                skillDescLabel.trailingAnchor.constraint(equalTo: skillContainer.trailingAnchor, constant: -12),
                skillDescLabel.bottomAnchor.constraint(equalTo: skillContainer.bottomAnchor, constant: -12)
            ])
            
            skillsStack.addArrangedSubview(skillContainer)
        }
    }
    
    private func setupPriorEvolutions(_ priorEvolutions: [DigimonPriorEvolutions]?) {
        priorEvolutionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        guard let priorEvolutions, !priorEvolutions.isEmpty else {
            priorEvolutionsCard.isHidden = true
            return
        }
        
        priorEvolutionsCard.isHidden = false
        
        for evolution in priorEvolutions {
            let evolutionContainer = UIView()
            evolutionContainer.backgroundColor = .tertiarySystemBackground
            evolutionContainer.layer.cornerRadius = 8
            evolutionContainer.translatesAutoresizingMaskIntoConstraints = false
            
            let evolutionImageView = UIImageView()
            evolutionImageView.contentMode = .scaleAspectFit
            evolutionImageView.setImage(from: evolution.image)
            evolutionImageView.translatesAutoresizingMaskIntoConstraints = false
            
            let evolutionNameLabel = UILabel()
            evolutionNameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
            evolutionNameLabel.text = evolution.digimon
            evolutionNameLabel.numberOfLines = 0
            evolutionNameLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let conditionLabel = UILabel()
            conditionLabel.font = .systemFont(ofSize: 13)
            conditionLabel.text = evolution.condition ?? "No condition"
            conditionLabel.numberOfLines = 0
            conditionLabel.textColor = .secondaryLabel
            conditionLabel.translatesAutoresizingMaskIntoConstraints = false
            
            evolutionContainer.addSubview(evolutionImageView)
            evolutionContainer.addSubview(evolutionNameLabel)
            evolutionContainer.addSubview(conditionLabel)
            
            NSLayoutConstraint.activate([
                evolutionImageView.leadingAnchor.constraint(equalTo: evolutionContainer.leadingAnchor, constant: 12),
                evolutionImageView.centerYAnchor.constraint(equalTo: evolutionContainer.centerYAnchor),
                evolutionImageView.widthAnchor.constraint(equalToConstant: 60),
                evolutionImageView.heightAnchor.constraint(equalToConstant: 60),
                evolutionImageView.topAnchor.constraint(greaterThanOrEqualTo: evolutionContainer.topAnchor, constant: 12),
                evolutionImageView.bottomAnchor.constraint(lessThanOrEqualTo: evolutionContainer.bottomAnchor, constant: -12),
                
                evolutionNameLabel.leadingAnchor.constraint(equalTo: evolutionImageView.trailingAnchor, constant: 12),
                evolutionNameLabel.trailingAnchor.constraint(equalTo: evolutionContainer.trailingAnchor, constant: -12),
                evolutionNameLabel.topAnchor.constraint(equalTo: evolutionContainer.topAnchor, constant: 12),
                
                conditionLabel.leadingAnchor.constraint(equalTo: evolutionImageView.trailingAnchor, constant: 12),
                conditionLabel.trailingAnchor.constraint(equalTo: evolutionContainer.trailingAnchor, constant: -12),
                conditionLabel.topAnchor.constraint(equalTo: evolutionNameLabel.bottomAnchor, constant: 4),
                conditionLabel.bottomAnchor.constraint(equalTo: evolutionContainer.bottomAnchor, constant: -12)
            ])
            
            priorEvolutionsStack.addArrangedSubview(evolutionContainer)
        }
    }

    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }

                switch state {
                case .loading:
                    print("Loading detail...")

                case .loaded(let detail):
                    self.updateUI(with: detail)

                case .error(let error):
                    self.showError(error)
                }
            }
            .store(in: &cancellables)
    }

    private func showError(_ error: NetworkError) {
        let alert = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
