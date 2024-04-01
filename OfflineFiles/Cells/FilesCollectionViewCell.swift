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

    }
    
    func configure(with image: UIImage?, isDocument: Bool, fileName : String) {
            if isDocument {
                if let docImage = image {
                    let borderedImage = addBorder(to: docImage, withColor: .gray, thickness: 0.1)
                    pickImage.image = borderedImage
                    fileNameLbl.text = fileName
                }
            } else {
                if let image = image {
                    pickImage.image = resizeImage(image, newSize: CGSize(width: 120, height: 120), cornerRadius: 8)
                    fileNameLbl.text = fileName
                }
            }
        }
        
    private func resizeImage(_ image: UIImage, newSize: CGSize, cornerRadius: CGFloat) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { context in
            let roundedRect = CGRect(origin: .zero, size: newSize)
            let roundedPath = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
            roundedPath.addClip()
            image.draw(in: roundedRect)
        }
        return resizedImage
    }

    func addBorder(to image: UIImage, withColor color: UIColor, thickness: CGFloat) -> UIImage {
        let borderWidth = thickness * UIScreen.main.scale
        let newSize = CGSize(width: image.size.width + 2 * borderWidth, height: image.size.height + 2 * borderWidth)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        defer { UIGraphicsEndImageContext() }
        
        let borderRect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        let imageRect = CGRect(x: borderWidth, y: borderWidth, width: image.size.width, height: image.size.height)
        
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(borderRect)
        
        image.draw(in: imageRect)
        
        return UIGraphicsGetImageFromCurrentImageContext()!
    }

}
