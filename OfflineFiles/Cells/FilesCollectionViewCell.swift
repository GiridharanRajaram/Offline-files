//
//  FilesCollectionViewCell.swift
//  OfflineFiles
//
//  Created by Giridharan on 31/03/24.
//

import UIKit

class FilesCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var pickImage: UIImageView!
    
    @IBOutlet weak var fileNameLbl: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

        pickImage.layer.cornerRadius = 10
    }
    
    func configure(with image: UIImage?, isDocument: Bool, fileName : String) {
//            if isDocument {
//                if let docImage = image {
//                    let borderedImage = addBorder(to: docImage, withColor: .gray, thickness: 0.1)
                    pickImage.image = image
                    fileNameLbl.text = fileName
//                }
//            } else {
//                if let image = image {
//                    pickImage.image = resizeImage(image, newSize: CGSize(width: 120, height: 120), cornerRadius: 8)
//                    fileNameLbl.text = fileName
//                }
        }
        
   

}
