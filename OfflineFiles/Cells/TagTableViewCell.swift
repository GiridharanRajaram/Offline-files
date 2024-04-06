//
//  TagTableViewCell.swift
//  OfflineFiles
//
//  Created by Giridharan on 04/04/24.
//

import UIKit





class TagTableViewCell: UITableViewCell {

    @IBOutlet weak var colorCircleView: UIView!
    
    @IBOutlet weak var colorNameLbl: UILabel!
    
    @IBOutlet weak var backroundView: UIView!
    
  
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        colorCircleView.layer.cornerRadius = 10
        colorCircleView.clipsToBounds = true
        backroundView.layer.cornerRadius = 10

    }
   
 
       
       func configure(with color: UIColor, name: String) {
           colorCircleView.backgroundColor = color
           colorNameLbl.text = name
       }
    
}
