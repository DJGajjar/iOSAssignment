//
//  FacilitiesCell.swift
//  iOSAssignment
//
//  Created by Darshan Jolapara on 29/06/23.
//

import UIKit

class FacilitiesCell: UICollectionViewCell {

    //MARK: IBOutlet
    
    @IBOutlet var viewBack: UIView!
    @IBOutlet var lblFacilitiesName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        viewBack.layer.cornerRadius = 20.0
    }

}
