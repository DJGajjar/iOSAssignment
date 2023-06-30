//
//  ViewController.swift
//  iOSAssignment
//
//  Created by Darshan Jolapara on 28/06/23.
//

import UIKit

private let reuseIdentifier = "FacilitiesCell"

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // MARK: IBOutlet
    @IBOutlet var facilitiesCollection: UICollectionView!
    @IBOutlet var tblFacilitiesOption: UITableView!
    @IBOutlet var viewShadow: UIView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    
    // MARK: Variable
    var arrFacilitiesList: [FacilitiesModel] = []
    var arrFacilitiesData: [FacilitiesList] = []
    var arrExclusionData: [ExclusionsList] = []
    var arrSelectOptionID: [FacilitiesSelectOption] = []
    
    var selectedCell = [IndexPath]()
    var selectFacilities: Int = -1
    
    var strFacilitiesSelect: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        getFacilitiesDataCallAPI()
    }
    
    func getFacilitiesDataCallAPI() {
        
        self.setupLayout()
            
        viewShadow.layer.shadowColor = UIColor.gray.cgColor
        viewShadow.layer.shadowOffset = CGSizeMake(4, 6)
        viewShadow.layer.shadowOpacity = 0.6
        viewShadow.layer.shadowRadius = 4
        viewShadow.clipsToBounds = false
        viewShadow.layer.masksToBounds = false
        
        self.tblFacilitiesOption.register(UINib(nibName: "FacilitiesOptionCell", bundle: nil), forCellReuseIdentifier: "FacilitiesOptionCell")
        
        activityIndicatorView.startAnimating()
        
        APIServiceModel.shared.adAssignmentList() { [weak self] (json, statusCode) in
            guard statusCode != NSURLErrorCancelled, let weakSelf = self else { return }
            if json != nil, let dict = json as? NSDictionary {
                weakSelf.activityIndicatorView.stopAnimating()
                weakSelf.activityIndicatorView.isHidden = true
               let facilitiesDict = FacilitiesModel(dict: dict)
                weakSelf.arrFacilitiesList.append(facilitiesDict)
                weakSelf.arrFacilitiesData.append(contentsOf: facilitiesDict.arrFacilities)
                weakSelf.arrExclusionData.append(contentsOf: facilitiesDict.arrExclusions)
                
                weakSelf.viewShadow.isHidden = false
                weakSelf.tblFacilitiesOption.isHidden = false
                weakSelf.facilitiesCollection.isHidden = false
                
                weakSelf.facilitiesCollection.reloadData()
            } else if statusCode == 403 {
                print("Status: \(statusCode)")
                weakSelf.activityIndicatorView.stopAnimating()
                weakSelf.activityIndicatorView.isHidden = true
               
                weakSelf.facilitiesCollection.isHidden = true
                weakSelf.tblFacilitiesOption.isHidden = true
                
                weakSelf.showAPICallErrorMsg()
            } else {
                weakSelf.activityIndicatorView.stopAnimating()
                weakSelf.activityIndicatorView.isHidden = true
                
                weakSelf.facilitiesCollection.isHidden = true
                weakSelf.tblFacilitiesOption.isHidden = true
                
                weakSelf.showAPICallErrorMsg()
            }
        }
    }
    
    func setupLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 136, height: 60)
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                
        facilitiesCollection.register(UINib(nibName: "FacilitiesCell", bundle: nil), forCellWithReuseIdentifier: "FacilitiesCell")
        facilitiesCollection.collectionViewLayout = layout
        facilitiesCollection.showsHorizontalScrollIndicator = false
        facilitiesCollection.reloadData()
    }
    
    func showAPICallErrorMsg() {
        let alert = UIAlertController(title: "Alert", message: "Something went wrong. Please try again later.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

    // MARK: UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrFacilitiesData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! FacilitiesCell
        
        if selectedCell.contains(indexPath) {
            cell.viewBack.backgroundColor = #colorLiteral(red: 1, green: 0.3568627451, blue: 0.4431372549, alpha: 1)
            cell.viewBack.layer.applyCornerRadiusShadow(color: #colorLiteral(red: 1, green: 0.3568627451, blue: 0.4431372549, alpha: 1),
                                                        alpha: 0.38,
                                                        x: 0, y: 3,
                                                        blur: 10,
                                                        spread: 0,
                                                        cornerRadiusValue: 20)
        }
        else {
            cell.viewBack.backgroundColor = #colorLiteral(red: 0.9623864293, green: 0.9687970281, blue: 0.9719694257, alpha: 1)
        }
        
        cell.lblFacilitiesName.text = arrFacilitiesData[indexPath.row].name
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? FacilitiesCell {
            
            if !selectedCell.isEmpty {
                selectedCell.remove(at: 0)
            }
            
            selectFacilities = indexPath.row
            
            selectedCell.append(indexPath)
            
            strFacilitiesSelect = arrFacilitiesData[indexPath.row].facility_id
            
            cell.viewBack.backgroundColor = #colorLiteral(red: 1, green: 0.3568627451, blue: 0.4431372549, alpha: 1)
            
            cell.viewBack.layer.applyCornerRadiusShadow(color: #colorLiteral(red: 1, green: 0.3568627451, blue: 0.4431372549, alpha: 1),
                                        alpha: 0.38,
                                        x: 0, y: 3,
                                        blur: 10,
                                        spread: 0,
                                        cornerRadiusValue: 20)
            
            self.tblFacilitiesOption.reloadData()
            self.tblFacilitiesOption.isHidden = false
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? FacilitiesCell {
            if selectedCell.contains(indexPath) {
                selectedCell.remove(at: selectedCell.firstIndex(of: indexPath)!)
                cell.viewBack.backgroundColor = #colorLiteral(red: 0.9623864293, green: 0.9687970281, blue: 0.9719694257, alpha: 1)
                cell.viewBack.layer.shadowOpacity = 0.0
            }
        }
    }
        
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let label = UILabel(frame: CGRect.zero)
        label.text = arrFacilitiesData[indexPath.row].name
        label.sizeToFit()
        return CGSize(width: label.frame.width + 20, height: 60)
    }
}

extension ViewController : UITableViewDataSource {
    
    //MARK:- Table View Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrFacilitiesData.count > 0 {
            return arrFacilitiesData[selectFacilities].arrOptions.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:FacilitiesOptionCell = self.tblFacilitiesOption.dequeueReusableCell(withIdentifier: "FacilitiesOptionCell") as! FacilitiesOptionCell
                
        cell.selectionStyle = .none
                
        if arrFacilitiesData.count > 0 {
            cell.lblOptionName.text = arrFacilitiesData[selectFacilities].arrOptions[indexPath.row].name
            cell.imgFacilities.image = UIImage(named: arrFacilitiesData[selectFacilities].arrOptions[indexPath.row].icon)
            
            for i in 0..<arrSelectOptionID.count {
                if arrSelectOptionID[i].options_id == arrFacilitiesData[selectFacilities].arrOptions[indexPath.row].id {
                    cell.imgCheck.isHidden = false
                    cell.imgCheck.image = UIImage(named: "Check")
                    break
                }else {
                    cell.imgCheck.isHidden = true
                }
            }
        }
        
        return cell
    }
}

extension ViewController : UITableViewDelegate {
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let strFacilityID: String = arrFacilitiesData[selectFacilities].facility_id
        let strFacilityOptionID: String = arrFacilitiesData[selectFacilities].arrOptions[indexPath.row].id
        
        var isValidation: Bool = false
        var isSelectOption: Bool = false
        var isCheckCondition: Bool = false
        
        if arrSelectOptionID.count > 0 {
            for item in 0..<arrSelectOptionID.count {
                if strFacilityID == arrSelectOptionID[item].facility_id {
                    arrSelectOptionID.remove(at: item)
                    break
                }
            }
            
            
            
            for i in 0..<arrSelectOptionID.count {
                let strSFacilityID: String = arrSelectOptionID[i].facility_id
                let strSFacilityOptionID: String = arrSelectOptionID[i].options_id
                
                if isValidation == true {
                    break
                }
                                
                for j in 0..<arrExclusionData.count {
                    if isValidation == true {
                        break
                    }
                    
                    isSelectOption = false
                    
                    for k in 0..<arrExclusionData[j].arrExclusionSublist.count {
                        let strExcFacilityID: String = arrExclusionData[j].arrExclusionSublist[k].facility_id
                        let strExcFacilityOptionID: String = arrExclusionData[j].arrExclusionSublist[k].options_id
                        
                        if strSFacilityID == strExcFacilityID && strSFacilityOptionID == strExcFacilityOptionID {
                            print("True Value")
                            isSelectOption = true
                            isCheckCondition = true
                        }else if isSelectOption == true {
                            if strFacilityID == strExcFacilityID && strFacilityOptionID == strExcFacilityOptionID {
                                isCheckCondition = true
                                let alert = UIAlertController(title: "Alert", message: "You can not select this option. Please select other.", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
                                
                                isValidation = true
                                break
                            }else if isSelectOption == true && strFacilityID == strFacilitiesSelect {
                                isCheckCondition = true
                                arrSelectOptionID.append(FacilitiesSelectOption(facility_id: strFacilityID, options_id: strFacilityOptionID))
                                self.tblFacilitiesOption.reloadData()
                                break
                            }
                            else {
                                print("Add Value in array")
                                isCheckCondition = true
                                if strFacilityID == strExcFacilityID {
                                    arrSelectOptionID.append(FacilitiesSelectOption(facility_id: strFacilityID, options_id: strFacilityOptionID))
                                    self.tblFacilitiesOption.reloadData()
                                }
                                break
                            }
                        }else {
                            break
                        }
                    }
                }
            }
        }else {
            if strFacilitiesSelect == arrFacilitiesData[0].facility_id {
                arrSelectOptionID.append(FacilitiesSelectOption(facility_id: strFacilityID, options_id: strFacilityOptionID))
                self.tblFacilitiesOption.reloadData()
            }else {
                let alert = UIAlertController(title: "Alert", message: "Please select the first facilities of the property type", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "Okay", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension CALayer {
    func applyCornerRadiusShadow(
        color: UIColor = .black,
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 2,
        blur: CGFloat = 4,
        spread: CGFloat = 0,
        cornerRadiusValue: CGFloat = 0)
    {
        cornerRadius = cornerRadiusValue
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
