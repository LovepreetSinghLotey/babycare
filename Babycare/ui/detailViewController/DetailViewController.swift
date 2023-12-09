//
//  DetailViewController.swift
//  Babycare
//
//  Created by User on 14/05/23.
//

import UIKit
import FirebaseDatabase

class DetailViewController: BaseViewController {
    
    class func present(parent: UIViewController, _ data: Codable? = nil){
        let vc: DetailViewController = DetailViewController.loadFromNib()
        vc.modalPresentationStyle = .fullScreen
        vc.data = data
        if let nav = parent.navigationController {
            nav.pushViewController(vc, animated: true)
        } else{
            parent.present(vc, animated: true)
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIImageView!
    @IBOutlet weak var detailTitle: UILabel!
    @IBOutlet weak var addButton: UILabel!
    @IBOutlet weak var shareButton: UIImageView!
    
    var data: Codable? = nil
    var dataList: [Codable] = []
    private var dataSource: TableViewDataSource<DetailTableViewCell, Codable>!
    lazy var databaseRef: DatabaseReference? = nil
    lazy var user: RegisterModel? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let data = PrefUtil.instance.get(forKey: PrefKeys.USER_OBJECT) as? Data{
            user = try? JSONDecoder().decode(RegisterModel.self, from: data)
        }
        databaseRef = Database.database().reference()
        tableView.register(UINib(nibName: DetailTableViewCell.getIdentifier(), bundle: nil), forCellReuseIdentifier: DetailTableViewCell.getIdentifier())
        tableView.delegate = self
        detailTitle.text = getDetailTitle()
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        handleBackPress()
        
        addButton.onTap {
            AddDetailViewController.present(parent: self, self.data)
        }
        
        shareButton.onTap {
            if(self.dataList.isEmpty){
                self.showToast(message: "No data!")
            } else{
                PdfUtil(parentVC: self).sharePDFTable(fileName: self.getDetailTitle().replacingOccurrences(of: " ", with: "_").lowercased(), headers: self.getPdfHeaders(), rows: self.getPdfRows())
            }
        }
    }
    
    private func getPdfHeaders() -> [String]{
        switch(data){
        case is FeedModel:
            return ["Milk type", "Quantity", "Date", "Time"]
        case is DiaperModel:
            return ["ChangeType", "Date", "Time"]
        case is SleepModel:
            return ["Sleep type", "Date", "Time"]
        default:
            return ["Medicine type", "Quantity", "Medicine unit", "Date", "Time"]
        }
    }
    
    private func getPdfRows() -> [[String]]{
        switch(data){
        case is FeedModel:
            return (dataList as! [FeedModel]).map { model in
                [model.milkType, model.quantity, model.mDate, model.mTime]
            }
        case is DiaperModel:
            return (dataList as! [DiaperModel]).map { model in
                [model.changeDiaperType, model.mDate, model.mTime]
            }
        case is SleepModel:
            return (dataList as! [SleepModel]).map { model in
                [model.sleepType, model.mDate, model.mTime]
            }
        default:
            return (dataList as! [MedicineModel]).map { model in
                [model.medicineType, model.quantity, model.medicineUnit, model.mDate, model.mTime]
            }
        }
    }
    
    private func getDetailTitle() -> String{
        let name = user?.name.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        switch(data){
        case is FeedModel:
            return "\(name) Feed Details"
        case is DiaperModel:
            return "\(name) Diaper Details"
        case is SleepModel:
            return "\(name) Sleep Details"
        default:
            return "\(name) Medicine Details"
        }
    }
    
    private func handleBackPress(){
        backButton.onTap {
            if let nav = self.navigationController{
                nav.popViewController(animated: true)
            } else{
                self.dismiss(animated: true)
            }
        }
    }
}

extension DetailViewController: UITableViewDelegate, DetailTableViewCellDelegate{
    
    private func updateTable(){
        dataSource = TableViewDataSource(cellIdentifier: DetailTableViewCell.getIdentifier(), items: dataList, configureCell: {(cell, data) in
            cell.delegate = self
            cell.setItem(data: data)
        })
        
        DispatchQueue.main.async{
            self.tableView.dataSource = self.dataSource
            self.tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    func onDelete(key: String) {
        if(key.isEmpty){
            self.showToast(message: "Key must not be empty!")
            return;
        }
        databaseRef?.child(getFirebaseTableName()).child(key).observeSingleEvent(of: .value, with: { snapshot in
            snapshot.ref.removeValue()
        }, withCancel: { error in
            self.showToast(message: "Some error occurred!")
        })
    }
}

extension DetailViewController{
    
    func loadData(){
        self.view.showLoader()
        databaseRef?.child(getFirebaseTableName()).observe(.value, with: { snapshot in
            self.dataList.removeAll()
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                self.showToast(message: "Some error occurred!")
                self.view.removeLoader()
                return
            }
            print(children)
            self.processData(children)
            self.view.removeLoader()
        }, withCancel: { error in
            self.showToast(message: "Some error occurred!")
            self.view.removeLoader()
        })
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
    
    private func processData(_ children: [DataSnapshot]){
        print(children)
        children.forEach { snap in
            let email: String = ((snap.value as? [String: Any])?["email"] as? String) ?? ""
            if(user?.email == email){
                switch(data){
                case is FeedModel:
                    dataList.append(try? JSONDecoder().decode(FeedModel.self, from: snap.valueToJSON))
                    break
                case is DiaperModel:
                    dataList.append(try? JSONDecoder().decode(DiaperModel.self, from: snap.valueToJSON))
                    break
                case is SleepModel:
                    dataList.append(try? JSONDecoder().decode(SleepModel.self, from: snap.valueToJSON))
                    break
                default:
                    dataList.append(try? JSONDecoder().decode(MedicineModel.self, from: snap.valueToJSON))
                    break
                }
            }
        }
        updateTable()
    }
}
