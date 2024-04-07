//
//  UtilityFunctions.swift
//  OfflineFiles
//
//  Created by Giridharan on 07/04/24.
//


import Foundation
import UIKit

class UtilityFunctions {
    
    // Function to show an empty folder label in a specified view
    func showEmptyFolderLabel(inView view: UIView, title: String) {
        let label = UILabel()
        label.text = title
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 22)
        label.sizeToFit()
        label.center = view.center
        label.tag = 100
        view.addSubview(label)
    }

    // Function to hide the empty folder label from the specified view
    func hideEmptyFolderLabel(fromView view: UIView) {
        if let label = view.viewWithTag(100) as? UILabel {
            label.removeFromSuperview()
        }
    }
}

