//
//  UIImageView+Ext.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 07/01/26.
//

import UIKit

extension UIImageView {
    func setImage(from urlString: String?, into imageView: UIImageView, task: inout URLSessionDataTask?) {
        task?.cancel()
        
        guard let urlString = urlString, let url = URL(string: urlString) else {
            imageView.image = UIImage(systemName: "photo")
            return
        }
        imageView.image = UIImage(systemName: "photo")
    
        let newTask = URLSession.shared.dataTask(with: url) { [weak imageView] data, _, error in
            guard let imageView = imageView,
                  let data = data,
                  error == nil,
                  let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        task = newTask
        newTask.resume()
    }
}
