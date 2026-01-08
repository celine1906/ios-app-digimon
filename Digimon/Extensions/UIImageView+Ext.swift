//
//  UIImageView+Ext.swift
//  Digimon
//
//  Created by Regina Celine Adiwinata on 07/01/26.
//

import UIKit

extension UIImageView {
    private static var taskKey = 0
    
    private var currentTask: URLSessionDataTask? {
        get {
            return objc_getAssociatedObject(self, &UIImageView.taskKey) as? URLSessionDataTask
        }
        set {
            objc_setAssociatedObject(self, &UIImageView.taskKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func setImage(
        from urlString: String?,
        placeholder: UIImage? = UIImage(systemName: "photo")
    ) {
        currentTask?.cancel()
        currentTask = nil

        self.image = placeholder

        guard
            let urlString,
            let url = URL(string: urlString)
        else { return }

        let newTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard
                let self,
                let data,
                error == nil,
                let image = UIImage(data: data)
            else { return }

            DispatchQueue.main.async {
                self.image = image
                self.currentTask = nil
            }
        }

        currentTask = newTask
        newTask.resume()
    }
    
    func cancelImageLoad() {
        currentTask?.cancel()
        currentTask = nil
    }
}
