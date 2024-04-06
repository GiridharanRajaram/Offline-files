//
//  FolderCollectionViewCell.swift
//  OfflineFiles
//
//  Created by Giridharan on 30/03/24.
//

import UIKit

class FolderCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var folderImageView: UIImageView!
    
    @IBOutlet weak var folderNameLbl: UILabel!
    
    @IBOutlet weak var tagColorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tagColorView.layer.cornerRadius = 5
        tagColorView.clipsToBounds = true
    }

}
