//
//  ColorOptionsViewController.swift
//  OfflineFiles
//
//  Created by Giridharan on 04/04/24.
//

import UIKit
import CoreData

protocol ColorOptionsDelegate: AnyObject {
    func didSelectColor()
}


class ColorOptionsViewController: UIViewController {

    @IBOutlet weak var colorSelectionTableView: UITableView!
    
    
    let colors: [(UIColor, String)] = [(.red, "Red"), (.blue, "Blue"), (.green, "Green"), (.yellow, "Yellow")]
    
    var colorIndex = Int()
    
    weak var delegate: ColorOptionsDelegate?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
        let nib = UINib(nibName: "TagTableViewCell", bundle: nil)
        colorSelectionTableView.register(nib, forCellReuseIdentifier: "TagTableViewCell")
        
        colorSelectionTableView.delegate = self
        colorSelectionTableView.dataSource = self
        
    }
}


extension ColorOptionsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagTableViewCell", for: indexPath) as! TagTableViewCell
        let (color, name) = colors[indexPath.row]
        cell.configure(with: color, name: name)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (color, _) = colors[indexPath.row]
        DatabaseHelper.instance.saveColorForFolder(at: colorIndex, color: color)
        delegate?.didSelectColor()
        dismiss(animated: true)
 
    }
  
}



