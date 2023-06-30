//
//  FacilitiesOptionModel.swift
//  iOSAssignment
//
//  Created by Darshan Jolapara on 29/06/23.
//

import Foundation

struct FacilitiesSelectOption {

    var facility_id: String
    var options_id: String
    
    init(facility_id: String, options_id: String) {
        self.facility_id = facility_id
        self.options_id = options_id
    }
}
