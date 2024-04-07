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


enum CustomColor: CaseIterable {
    case Red
    case Blue
    case Green
    case Yellow
    case Orange
    case Purple
    case Cyan
    
    var uiColor: UIColor {
        switch self {
        case .Red: return .red
        case .Blue: return .blue
        case .Green: return .green
        case .Yellow: return .yellow
        case .Orange: return .orange
        case .Purple: return .purple
        case .Cyan: return .cyan
        }
    }
}


class ColorOptionsViewController: UIViewController {
    
    @IBOutlet weak var colorSelectionTableView: UITableView!
    
    
    let colors: [(UIColor, String)] = CustomColor.allCases.map { ($0.uiColor, "\($0)") }
    
    var colorIndex = Int()
    
    weak var delegate: ColorOptionsDelegate?
    
    @IBOutlet weak var cancel: UIButton!
    
    var folderColor: UIColor?
    
    override func viewDidLayoutSubviews() {
       
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "TagTableViewCell", bundle: nil)
        colorSelectionTableView.register(nib, forCellReuseIdentifier: "TagTableViewCell")
        
        colorSelectionTableView.delegate = self
        colorSelectionTableView.dataSource = self
        
        if let folder = DatabaseHelper.instance.fetchFolders()?[colorIndex],
           let colorData = folder.value(forKey: "color") as? Data,
           let color = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            folderColor = color
        }
        
        
    }
    
    
    @IBAction func dismissBtnAction(_ sender: Any) {
        self.dismiss(animated: true)
        
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
        
        if let folderColor = folderColor, color.isEqual(folderColor) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let (color, _) = colors[indexPath.row]
        if let folderColor = folderColor, color.isEqual(folderColor) {
            DatabaseHelper.instance.saveColorForFolder(at: colorIndex, color: .clear)
        } else {
            DatabaseHelper.instance.saveColorForFolder(at: colorIndex, color: color)
        }
        delegate?.didSelectColor()
        dismiss(animated: true)
        
    }
    
    
    
}



