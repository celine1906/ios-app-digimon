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

    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Search Digimon"
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    private let tableView: UITableView = {
        let tv = UITableView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.separatorStyle = .none
        tv.rowHeight = UITableView.automaticDimension
        tv.estimatedRowHeight = 120
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
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "Loading Digimon..."
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        tableView.register(DigimonCell.self, forCellReuseIdentifier: "DigimonCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundView = emptyStateLabel
        
        searchBar.delegate = self

        bindViewModel()
        Task { [weak self] in
            await self?.viewModel.fetchInitial()
        }

        setupUI()
    }
    
    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }

                switch state {
                case .loading:
                    if self.displayedDigimons.isEmpty {
                        // Initial loading
                        self.tableView.tableFooterView = self.loadingFooter
                    } else {
                        // Pagination loading
                        self.tableView.tableFooterView = self.loadingFooter
                    }

                case .loaded(let digimons):
                    self.tableView.tableFooterView = nil
                    self.displayedDigimons = digimons
                    self.tableView.reloadData()

                case .error(let error):
                    self.tableView.tableFooterView = nil
                    print("Error:", error.localizedDescription)
                    self.showError(error)
                }
            }
            .store(in: &cancellables)
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(searchBar)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        // Trigger load saat sudah dekat dengan bottom (2 items dari bawah)
        let threshold = displayedDigimons.count - 2
        
        if indexPath.row >= threshold {
            Task { [weak self] in
                await self?.viewModel.loadNextPage()
            }
        }
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
