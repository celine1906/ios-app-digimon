//
//  TabBarController.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 06/01/26.
//

import UIKit

class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    private func setupTabs() {
        let listVC = DigimonListViewController()

        let favoriteVC = FavoriteDigimonViewController()

        let listNav = UINavigationController(rootViewController: listVC)
        let favoriteNav = UINavigationController(rootViewController: favoriteVC)

        listNav.tabBarItem = UITabBarItem(
            title: "List",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet")
        )

        favoriteNav.tabBarItem = UITabBarItem(
            title: "Favorite",
            image: UIImage(systemName: "heart")
            selectedImage: UIImage(systemName: "heart.fill")
        )

        viewControllers = [listNav, favoriteNav]

        tabBar.tintColor = .systemBlue
    }
}
