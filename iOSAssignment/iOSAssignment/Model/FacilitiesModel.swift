//
//  FacilitiesModel.swift
//  iOSAssignment
//
//  Created by Darshan Jolapara on 28/06/23.
//

import UIKit

class FacilitiesModel: NSObject {
    
    var arrFacilities: [FacilitiesList] = []
    var arrExclusions: [ExclusionsList] = []
        
    init(dict: NSDictionary) {
            
        if let arrFacilitiesDict = dict["facilities"] as? [NSDictionary] {
            for objA in arrFacilitiesDict {
                let objIns = FacilitiesList(dict: objA)
                arrFacilities.append(objIns)
            }
        }
        
        if let arrExclusionsDict = dict["exclusions"] as? [NSArray] {
            for objA in arrExclusionsDict {
                print("Value OD : \(objA)")
                let objIns = ExclusionsList(array: objA)
                arrExclusions.append(objIns)
            }
        }
    }
}

class FacilitiesList {
    let facility_id: String
    var name: String
    var arrOptions: [OptionList] = []
    
    init(dict: NSDictionary) {
        self.facility_id = dict.getStringValue(key: "facility_id")
        self.name = dict.getStringValue(key: "name")
        
        if let arrOptionsDict = dict["options"] as? [NSDictionary] {
            for objA in arrOptionsDict {
                let objIns = OptionList(dict: objA)
                arrOptions.append(objIns)
            }
        }
    }
}

class OptionList {
    var name: String
    var icon: String
    let id: String
    
    init(dict: NSDictionary) {
        self.name = dict.getStringValue(key: "name")
        self.icon = dict.getStringValue(key: "icon")
        self.id = dict.getStringValue(key: "id")
    }
}

class ExclusionsList {
    var arrExclusionSublist: [ExclusionsSubList] = []
    
    init(array: NSArray) {
        for objA in array {
            let objIns = ExclusionsSubList(dict: objA as! NSDictionary)
            arrExclusionSublist.append(objIns)
        }
    }
}

class ExclusionsSubList {
    let facility_id: String
    let options_id: String
    
    init(dict: NSDictionary) {
        self.facility_id = dict.getStringValue(key: "facility_id")
        self.options_id = dict.getStringValue(key: "options_id")
    }
}
