//
//  ViewController.swift
//  Babycare
//
//  Created by User on 10/05/23.
//

import UIKit

class MainViewController: BaseViewController {
    
    class func present(){
        let vc: MainViewController = UIStoryboard.init(storyboard: .Main).initVC()
        vc.modalPresentationStyle = .fullScreen
        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.setNavigationBarHidden(true, animated: false)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return
        }
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    @IBOutlet weak var feedView: UIView!
    @IBOutlet weak var diaperView: UIView!
    @IBOutlet weak var sleepView: UIView!
    @IBOutlet weak var medicineView: UIView!
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        feedView.onTap {
            DetailViewController.present(parent: self, FeedModel(key: "", email: "", milkType: "", quantity: "", mDate: "", mTime: ""))
        }
        
        diaperView.onTap {
            DetailViewController.present(parent: self, DiaperModel(key: "", email: "", changeDiaperType: "", mDate: "", mTime: ""))
        }
        
        sleepView.onTap {
            DetailViewController.present(parent: self, SleepModel(key: "", email: "", sleepType: "", mDate: "", mTime: ""))
        }
        
        medicineView.onTap {
            DetailViewController.present(parent: self, MedicineModel(key: "", email: "", medicineType: "", quantity: "", medicineUnit: "", mDate: "", mTime: ""))
        }
        
        handleUserImage()
    }
    
    private func handleUserImage(){
        var user: RegisterModel?
        if let data = PrefUtil.instance.get(forKey: PrefKeys.USER_OBJECT) as? Data{
            user = try? JSONDecoder().decode(RegisterModel.self, from: data)
        }
        
        if let url = URL(string: user?.image ?? "https://www.google.com/url?sa=i&url=https%3A%2F%2Funsplash.com%2Fs%2Fphotos%2Fcute-baby&psig=AOvVaw3bLXVii1PUPMiVV6TQyJjB&ust=1684258804237000&source=images&cd=vfe&ved=0CBEQjRxqFwoTCMD775Dv9_4CFQAAAAAdAAAAABAJ") {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async { /// execute on main thread
                    self.image.image = UIImage(data: data)
                }
            }
            
            task.resume()
        }
    }

    @IBAction func onLogout(_ sender: Any) {
        self.view?.showLoader()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2){
            self.view.removeLoader()
            self.logout()
        }
    }
}

