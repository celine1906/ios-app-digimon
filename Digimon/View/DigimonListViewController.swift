//
//  DigimonListViewController.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 06/01/26.
//

import UIKit
import Combine

class DigimonListViewController: UIViewController {
    private let viewModel = DigimonListViewModel()
    private var cancellables = Set<AnyCancellable>()
    private var displayedDigimons: [DigimonModel] = []

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Digimon List"
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search Digimon"
        sb.translatesAutoresizingMaskIntoConstraints = false
        sb.searchBarStyle = .minimal
        return sb
    }()
    
    private lazy var filterButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "line.3.horizontal.decrease.circle"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(filterTapped), for: .touchUpInside)
        return btn
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

    private lazy var loadingFooter: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60))
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        view.addSubview(indicator)
        NSLayoutConstraint.activate([
            indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
        return view
    }()
    
    private let emptyStateContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emptyStateStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading Digimon..."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        tableView.register(DigimonCell.self, forCellReuseIdentifier: "DigimonCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        searchBar.delegate = self
        
        setupEmptyState()
        bindViewModel()
        Task { [weak self] in
            await self?.viewModel.fetchInitial()
        }

        setupUI()
    }
    
    private func setupEmptyState() {
        emptyStateStack.addArrangedSubview(loadingIndicator)
        emptyStateStack.addArrangedSubview(emptyStateLabel)
        emptyStateContainer.addSubview(emptyStateStack)
        
        NSLayoutConstraint.activate([
            emptyStateStack.centerXAnchor.constraint(equalTo: emptyStateContainer.centerXAnchor),
            emptyStateStack.centerYAnchor.constraint(equalTo: emptyStateContainer.centerYAnchor)
        ])
        
        tableView.backgroundView = emptyStateContainer
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }

                switch state {
                case .loading:
                    if self.displayedDigimons.isEmpty {
                        self.tableView.tableFooterView = nil
                        self.loadingIndicator.startAnimating()
                        self.emptyStateLabel.text = "Loading Digimon..."
                        self.emptyStateContainer.isHidden = false
                    } else {
                        self.tableView.tableFooterView = self.loadingFooter
                        self.emptyStateContainer.isHidden = true
                    }

                case .loaded(let digimons):
                    self.tableView.tableFooterView = nil
                    self.loadingIndicator.stopAnimating()
                    self.displayedDigimons = digimons
                    
                    if digimons.isEmpty && !self.viewModel.searchText.isEmpty {
                        self.emptyStateLabel.text = "No Digimon found"
                        self.emptyStateContainer.isHidden = false
                    } else if digimons.isEmpty {
                        self.emptyStateLabel.text = "Loading Digimon..."
                        self.emptyStateContainer.isHidden = false
                    } else {
                        self.emptyStateContainer.isHidden = true
                    }
                    
                    self.tableView.reloadData()

                case .error(let error):
                    self.tableView.tableFooterView = nil
                    self.loadingIndicator.stopAnimating()
                    print("Error:", error.localizedDescription)
                    self.showError(error)
                }
            }
            .store(in: &cancellables)
        
        viewModel.$activeFilters
            .receive(on: DispatchQueue.main)
            .sink { [weak self] filters in
                let hasFilters = !filters.levels.isEmpty || !filters.types.isEmpty || !filters.attributes.isEmpty || !filters.fields.isEmpty
                self?.filterButton.tintColor = hasFilters ? .systemRed : .systemBlue
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(searchContainer)
        searchContainer.addSubview(searchBar)
        searchContainer.addSubview(filterButton)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            searchContainer.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            searchContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            searchBar.topAnchor.constraint(equalTo: searchContainer.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: searchContainer.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: filterButton.leadingAnchor, constant: -8),
            searchBar.bottomAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            
            filterButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            filterButton.trailingAnchor.constraint(equalTo: searchContainer.trailingAnchor, constant: -16),
            filterButton.widthAnchor.constraint(equalToConstant: 44),
            filterButton.heightAnchor.constraint(equalToConstant: 44),
            
            tableView.topAnchor.constraint(equalTo: searchContainer.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func filterTapped() {
        let filterVC = FilterViewController(viewModel: viewModel)
        let nav = UINavigationController(rootViewController: filterVC)
        present(nav, animated: true)
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

extension DigimonListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        displayedDigimons.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "DigimonCell",
            for: indexPath
        ) as! DigimonCell

        cell.configure(with: displayedDigimons[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let threshold = displayedDigimons.count - 2
        
        if indexPath.row >= threshold && viewModel.searchText.isEmpty && !viewModel.hasActiveFilters {
            Task { [weak self] in
                await self?.viewModel.loadNextPage()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let digimon = displayedDigimons[indexPath.row]

        let detailVC = DigimonDetailViewController(
            href: digimon.href,
            cachedDetail: digimon.cachedDetail
        )

        navigationController?.pushViewController(detailVC, animated: true)
    }

}

extension DigimonListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText = searchText
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
