//
//  FilterViewController.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 08/01/26.
//

import UIKit

class FilterViewController: UIViewController {
    
    private let viewModel: DigimonListViewModel
    private var selectedLevels: Set<String> = []
    private var selectedTypes: Set<String> = []
    private var selectedAttributes: Set<String> = []
    private var selectedFields: Set<String> = []
    
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    
    init(viewModel: DigimonListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Filter Digimon"
        
        selectedLevels = viewModel.activeFilters.levels
        selectedTypes = viewModel.activeFilters.types
        selectedAttributes = viewModel.activeFilters.attributes
        selectedFields = viewModel.activeFilters.fields
        
        setupNavigation()
        setupUI()
        populateFilters()
    }
    
    private func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Reset",
            style: .plain,
            target: self,
            action: #selector(resetFilters)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Apply",
            style: .done,
            target: self,
            action: #selector(applyFilters)
        )
    }
    
    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        contentStack.axis = .vertical
        contentStack.spacing = 24
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }
    
    private func populateFilters() {
        let allDigimons = viewModel.getAllDigimons()
        
        var levels: Set<String> = []
        var types: Set<String> = []
        var attributes: Set<String> = []
        var fields: Set<String> = []
        
        for digimon in allDigimons {
            if let detail = digimon.cachedDetail {
                detail.levels?.forEach { levels.insert($0.level) }
                detail.types?.forEach { types.insert($0.type) }
                detail.attributes?.forEach { attributes.insert($0.attribute) }
                detail.fields?.forEach { fields.insert($0.field) }
            }
        }
        
        if !levels.isEmpty {
            contentStack.addArrangedSubview(createSection(
                title: "Level",
                options: Array(levels).sorted(),
                selectedOptions: selectedLevels,
                color: .systemBlue,
                onToggle: { [weak self] option in
                    self?.toggleSelection(option: option, in: &self!.selectedLevels)
                }
            ))
        }
        
        if !types.isEmpty {
            contentStack.addArrangedSubview(createSection(
                title: "Type",
                options: Array(types).sorted(),
                selectedOptions: selectedTypes,
                color: .systemGreen,
                onToggle: { [weak self] option in
                    self?.toggleSelection(option: option, in: &self!.selectedTypes)
                }
            ))
        }
        
        if !attributes.isEmpty {
            contentStack.addArrangedSubview(createSection(
                title: "Attribute",
                options: Array(attributes).sorted(),
                selectedOptions: selectedAttributes,
                color: .systemOrange,
                onToggle: { [weak self] option in
                    self?.toggleSelection(option: option, in: &self!.selectedAttributes)
                }
            ))
        }
        
        if !fields.isEmpty {
            contentStack.addArrangedSubview(createSection(
                title: "Field",
                options: Array(fields).sorted(),
                selectedOptions: selectedFields,
                color: .systemPurple,
                onToggle: { [weak self] option in
                    self?.toggleSelection(option: option, in: &self!.selectedFields)
                }
            ))
        }
    }
    
    private func createSection(
        title: String,
        options: [String],
        selectedOptions: Set<String>,
        color: UIColor,
        onToggle: @escaping (String) -> Void
    ) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 12
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let countLabel = UILabel()
        let selectedCount = selectedOptions.count
        countLabel.text = selectedCount > 0 ? "\(selectedCount) selected" : "None"
        countLabel.font = .systemFont(ofSize: 14)
        countLabel.textColor = selectedCount > 0 ? color : .secondaryLabel
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Create grid layout for chips
        let chipsContainer = UIView()
        chipsContainer.translatesAutoresizingMaskIntoConstraints = false
        
        var chips: [(button: UIButton, option: String)] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        let spacing: CGFloat = 8
        let containerWidth = UIScreen.main.bounds.width - 64
        
        for option in options {
            let button = createChipButton(
                title: option,
                isSelected: selectedOptions.contains(option),
                color: color
            )
            button.addAction(UIAction { [weak self, weak button, weak countLabel] _ in
                guard let self = self, let button = button else { return }
                let newState = button.backgroundColor != color
                self.updateChipAppearance(button, isSelected: newState, color: color)
                onToggle(option)
                
                let count = self.getSelectionCount(for: title)
                countLabel?.text = count > 0 ? "\(count) selected" : "None"
                countLabel?.textColor = count > 0 ? color : .secondaryLabel
            }, for: .touchUpInside)
            
            let buttonSize = button.intrinsicContentSize
            
            if currentX + buttonSize.width > containerWidth && currentX > 0 {
                currentX = 0
                currentY += buttonSize.height + spacing
            }
            
            button.frame = CGRect(
                x: currentX,
                y: currentY,
                width: buttonSize.width,
                height: buttonSize.height
            )
            
            chipsContainer.addSubview(button)
            chips.append((button, option))
            
            currentX += buttonSize.width + spacing
        }
        
        let lastButton = chips.last?.button
        let containerHeight = (lastButton?.frame.maxY ?? 0)
        chipsContainer.heightAnchor.constraint(equalToConstant: max(containerHeight, 40)).isActive = true
        
        container.addSubview(titleLabel)
        container.addSubview(countLabel)
        container.addSubview(chipsContainer)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            
            countLabel.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            countLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            
            chipsContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            chipsContainer.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            chipsContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            chipsContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -16)
        ])
        
        return container
    }
    
    private func createChipButton(title: String, isSelected: Bool, color: UIColor) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1.5
        
        updateChipAppearance(button, isSelected: isSelected, color: color)
        
        return button
    }
    
    private func updateChipAppearance(_ button: UIButton, isSelected: Bool, color: UIColor) {
        UIView.animate(withDuration: 0.2) {
            if isSelected {
                button.backgroundColor = color
                button.setTitleColor(.white, for: .normal)
                button.layer.borderColor = color.cgColor
                button.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
            } else {
                button.backgroundColor = .clear
                button.setTitleColor(color, for: .normal)
                button.layer.borderColor = color.withAlphaComponent(0.3).cgColor
                button.transform = .identity
            }
        }
    }
    
    private func getSelectionCount(for title: String) -> Int {
        switch title {
        case "Level": return selectedLevels.count
        case "Type": return selectedTypes.count
        case "Attribute": return selectedAttributes.count
        case "Field": return selectedFields.count
        default: return 0
        }
    }
    
    private func toggleSelection(option: String, in set: inout Set<String>) {
        if set.contains(option) {
            set.remove(option)
        } else {
            set.insert(option)
        }
    }
    
    @objc private func resetFilters() {
        let alert = UIAlertController(
            title: "Reset Filters",
            message: "Are you sure you want to clear all filters?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            self?.selectedLevels.removeAll()
            self?.selectedTypes.removeAll()
            self?.selectedAttributes.removeAll()
            self?.selectedFields.removeAll()
            
            // Rebuild UI
            self?.contentStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            self?.populateFilters()
        })
        
        present(alert, animated: true)
    }
    
    @objc private func applyFilters() {
        viewModel.applyFilters(
            levels: selectedLevels,
            types: selectedTypes,
            attributes: selectedAttributes,
            fields: selectedFields
        )
        dismiss(animated: true)
    }
}
