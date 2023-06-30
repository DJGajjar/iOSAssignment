//
//  FacilitiesOptionCell.swift
//  iOSAssignment
//
//  Created by Darshan Jolapara on 29/06/23.
//

import UIKit

class FacilitiesOptionCell: UITableViewCell {

    //MARK: IBOutlet
    
    @IBOutlet var imgFacilities: UIImageView!
    @IBOutlet var imgCheck: UIImageView!
    
    @IBOutlet var lblOptionName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
