//
//  AddDetailViewController.swift
//  Babycare
//
//  Created by User on 14/05/23.
//

import UIKit
import FirebaseDatabase

class AddDetailViewController: BaseViewController {
    
    class func present(parent: UIViewController, _ data: Codable? = nil){
        let vc: AddDetailViewController = AddDetailViewController.loadFromNib()
        vc.modalPresentationStyle = .fullScreen
        vc.data = data
        if let nav = parent.navigationController {
            nav.pushViewController(vc, animated: true)
        } else{
            parent.present(vc, animated: true)
        }
    }
    
    @IBOutlet weak var backButton: UIImageView!
    
    @IBOutlet weak var screenTitle: UILabel!
    
    @IBOutlet weak var typeTitle: UILabel!
    @IBOutlet weak var typeChooserView: OptionChooserView!
    
    @IBOutlet weak var quantityTitle: UILabel!
    @IBOutlet weak var quantityStackView: UIStackView!
    @IBOutlet weak var quantityView: UITextField!
    @IBOutlet weak var feedUnitTypeLabel: UILabel!
    
    @IBOutlet weak var unitTypeTitle: UILabel!
    @IBOutlet weak var unitChooserView: OptionChooserView!
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var time: UILabel!
    
    var data: Codable? = nil
    lazy var databaseRef: DatabaseReference? = nil
    
    var type: String = ""
    var quantity: String = ""
    var unit: String = ""
    var startDate: String = ""
    var startTime: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        screenTitle.text = getScreenTitle()
        typeTitle.text = getTypeTitle()
        
        typeChooserView.options = getTypeOptions()
        typeChooserView.optionType = .TYPE
        typeChooserView.delegate = self
        
        unitChooserView.options = ["ML", "DROP", "TABLET"]
        unitChooserView.optionType = .UNIT
        unitChooserView.delegate = self
        
        quantityTitle.isHidden = data is SleepModel || data is DiaperModel
        quantityStackView.isHidden = data is SleepModel || data is DiaperModel
        feedUnitTypeLabel.isHidden = !(data is FeedModel)
        
        unitTypeTitle.isHidden = !(data is MedicineModel)
        unitChooserView.isHidden = !(data is MedicineModel)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        type = typeChooserView.options.first ?? ""
        unit = unitChooserView.options.first ?? ""
        
        backButton.onTap {
            self.onBackPressed()
        }
        
        date.onTap {
            DatePickerDialog().show("Pick a date", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .date) { date in
                    if let dt = date {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd MMM yyyy"
                        self.date.textColor = UIColor.black
                        self.date.text = formatter.string(from: dt)
                        self.startDate = self.date.text ?? ""
                    }
                }
        }
        
        time.onTap {
            DatePickerDialog().show("Choose time", doneButtonTitle: "Done", cancelButtonTitle: "Cancel", datePickerMode: .time) { date in
                    if let dt = date {
                        let formatter = DateFormatter()
                        formatter.dateFormat = "HH:MM"
                        self.time.textColor = UIColor.black
                        self.time.text = formatter.string(from: dt)
                        self.startTime = self.time.text ?? ""
                    }
                }
        }
    }
    
    private func onBackPressed(){
        if let nav = self.navigationController{
            nav.popViewController(animated: true)
        } else{
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func onSubmit(_ sender: Any) {
        if(validate()){
            submitData()
        }
    }
    
    private func validate() -> Bool{
        quantity = quantityView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        if(data is FeedModel || data is MedicineModel){
            if(quantity.isEmpty){
                showToast(message: "Please enter quantity!")
                return false;
            }
        }
        
        if(startDate.isEmpty){
            showToast(message: "Please choose start date!")
            return false;
        }
        
        if(startTime.isEmpty){
            showToast(message: "Please choose start time!")
            return false;
        }
        
        return true;
    }
    
}

extension AddDetailViewController: OptionChooserViewDelegate {
    func onOptionChoosen(option: String, optionType: OptionType) {
        if(optionType == .TYPE){
            type = option
        } else{
            unit = option
        }
    }
}

extension AddDetailViewController{
    
    private func getScreenTitle() -> String{
        switch(data){
        case is FeedModel:
            return "Feed"
        case is DiaperModel:
            return "Diaper"
        case is SleepModel:
            return "Sleep"
        default:
            return "Add Medicine Log"
        }
    }
    
    private func getTypeTitle() -> String{
        switch(data){
        case is FeedModel:
            return "Milk Type"
        case is DiaperModel:
            return "Select Type"
        case is SleepModel:
            return "Sleep Type"
        default:
            return "Body's Medicine"
        }
    }
    
    private func getTypeOptions() -> [String]{
        switch(data){
        case is FeedModel:
            return ["Formula Milk", "Cow Milk"];
        case is DiaperModel:
            return ["Pee", "Poo", "Both"];
        case is SleepModel:
            return ["Light Sleep", "Deep Sleep"];
        default:
            return ["Vitamin A", "OPV"];
        }
    }
}

extension AddDetailViewController{
    
    private func submitData(){
        self.view.showLoader()
        let key = String.randomString(length: 30)
        databaseRef?.child(getFirebaseTableName()).child(key).setValue(getData(key).dict) { error, ref in
            self.view.showLoader()
            if(error != nil){
                self.showToast(message: "Some error occurred!")
            }
            self.showToast(message: "Success!")
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
                self.onBackPressed()
            }
        }
    }
    
    private func getFirebaseTableName() -> String{
        switch(data){
        case is FeedModel:
            return "FeedRecords"
        case is DiaperModel:
            return "DiaperRecords"
        case is SleepModel:
            return "SleepRecords"
        default:
            return "MedicineRecords"
        }
    }
    
    private func getData(_ key: String) -> Codable{
        var user: RegisterModel? = nil
        if let data = PrefUtil.instance.get(forKey: PrefKeys.USER_OBJECT) as? Data{
            user = try? JSONDecoder().decode(RegisterModel.self, from: data)
        }
        
        let email = user?.email ?? ""
        
        switch(data){
        case is FeedModel:
            return FeedModel(key: key, email: email, milkType: type, quantity: quantity, mDate: startDate, mTime: startTime)
        case is DiaperModel:
            return DiaperModel(key: key, email: email, changeDiaperType: type, mDate: startDate, mTime: startTime)
        case is SleepModel:
            return SleepModel(key: key, email: email, sleepType: type, mDate: startDate, mTime: startTime)
        default:
            return MedicineModel(key: key, email: email, medicineType: type, quantity: quantity, medicineUnit: unit, mDate: startDate, mTime: startTime)
        }
    }
}
