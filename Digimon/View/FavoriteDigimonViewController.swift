//
//  FavoriteDigimonViewController.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 06/01/26.
//

import UIKit
import Combine

class FavoriteDigimonViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    private var favoriteDigimons: [DigimonModel] = []
    private let network = NetworkService()
    private var isLoading = false

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "My Favorite Digimon"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 120
        tv.backgroundColor = .clear
        return tv
    }()
    
    private let emptyStateStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let emptyImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "heart.slash")
        iv.tintColor = .secondaryLabel
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "No favorite Digimon yet"
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()
    
    private let emptySubLabel: UILabel = {
        let label = UILabel()
        label.text = "Tap the heart icon on any Digimon detail to add them here"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        tableView.register(DigimonCell.self, forCellReuseIdentifier: "DigimonCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        setupUI()
        observeFavoriteChanges()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadFavorites()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        emptyStateStack.addArrangedSubview(emptyImageView)
        emptyStateStack.addArrangedSubview(emptyLabel)
        emptyStateStack.addArrangedSubview(emptySubLabel)
        view.addSubview(emptyStateStack)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateStack.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateStack.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            emptyStateStack.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -32),
            
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        
        emptyStateStack.isHidden = true
    }
    
    private func observeFavoriteChanges() {
        FavoriteManager.shared.favoritesDidChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadFavorites()
            }
            .store(in: &cancellables)
    }
    
    private func loadFavorites() {
        guard !isLoading else { return }
        
        let favorites = FavoriteManager.shared.getFavorites()
        
        if favorites.isEmpty {
            favoriteDigimons = []
            tableView.reloadData()
            updateEmptyState()
            return
        }
        
        isLoading = true
        loadingIndicator.startAnimating()
        emptyStateStack.isHidden = true
        
        Task {
            var loadedDigimons: [DigimonModel] = []
            
            for favorite in favorites {
                do {
                    let detail: DigimonDetail = try await network.request(
                        .getDigimonDetail(urlString: favorite.href)
                    )
                    
                    var digimon = DigimonModel(
                        id: detail.id,
                        name: detail.name,
                        href: favorite.href,
                        image: detail.images?.first?.href ?? ""
                    )
                    digimon.cachedDetail = detail
                    loadedDigimons.append(digimon)
                    
                } catch {
                    print("Failed to load favorite: \(error)")
                }
            }
            
            await MainActor.run {
                self.favoriteDigimons = loadedDigimons
                self.tableView.reloadData()
                self.isLoading = false
                self.loadingIndicator.stopAnimating()
                self.updateEmptyState()
            }
        }
    }
    
    private func updateEmptyState() {
        let isEmpty = favoriteDigimons.isEmpty
        emptyStateStack.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
}

extension FavoriteDigimonViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        favoriteDigimons.count
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: "DigimonCell",
            for: indexPath
        ) as! DigimonCell
        
        cell.configure(with: favoriteDigimons[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let digimon = favoriteDigimons[indexPath.row]
        
        let detailVC = DigimonDetailViewController(
            href: digimon.href,
            cachedDetail: digimon.cachedDetail
        )
        
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let digimon = favoriteDigimons[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Remove") { [weak self] _, _, completion in
            FavoriteManager.shared.removeFavorite(id: digimon.id)
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "heart.slash.fill")
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
