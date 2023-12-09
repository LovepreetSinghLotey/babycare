//
//  FeedTableViewCell.swift
//  Babycare
//
//  Created by User on 14/05/23.
//

import UIKit

protocol DetailTableViewCellDelegate: NSObjectProtocol {
    func onDelete(key: String)
}

class DetailTableViewCell: UITableViewCell {
    
    class func getIdentifier() -> String{
        "DetailTableViewCell"
    }
    
    @IBOutlet weak var moduleImage: UIImageView!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    
    lazy var data: Any? = nil
    weak var delegate: DetailTableViewCellDelegate!
    
    func setItem(data: Any){
        self.data = data
        moduleImage.image = getModuleImage()
        type.text = getTypeText()
        quantity.text = getQuantityAndUnitText()
        
        if let dataJson = (data as! Encodable).dict{
            date.text = (dataJson["mDate"] as? String?) ?? ""
            time.text = (dataJson["mTime"] as? String?) ?? ""
        }
    }
    
    func getModuleImage() -> UIImage{
        switch(data){
        case is FeedModel:
            return UIImage(named: "feed")!
        case is DiaperModel:
            return UIImage(named: "diaper")!
        case is SleepModel:
            return UIImage(named: "sleep")!
        default:
            return UIImage(named: "medicine")!
        }
    }
    
    func getTypeText() -> String{
        switch(data){
        case is FeedModel:
            return (data as? FeedModel)?.milkType ?? ""
        case is DiaperModel:
            return (data as? DiaperModel)?.changeDiaperType ?? ""
        case is SleepModel:
            return (data as? SleepModel)?.sleepType ?? ""
        default:
            return (data as? MedicineModel)?.medicineType ?? ""
        }
    }
    
    func getQuantityAndUnitText() -> String{
        switch(data){
        case is FeedModel:
            return "\((data as? FeedModel)?.quantity ?? "") ml"
        case is DiaperModel:
            return ""
        case is SleepModel:
            return ""
        default:
            return "\((data as? MedicineModel)?.quantity ?? "") \(((data as? MedicineModel)?.medicineUnit ?? "").lowercased())"
        }
    }
    
    @IBAction func onDelete(_ sender: Any) {
        if let key = (data as! Encodable).dict?["key"] as? String{
            delegate?.onDelete(key: key)
        }
    }
    
}
