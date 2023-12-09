//
//  LoginViewController.swift
//  Babycare
//
//  Created by User on 12/05/23.
//

import UIKit
import Firebase
import FirebaseDatabase

class LoginViewController: BaseViewController {
    
    class func present(){
        let vc: LoginViewController = UIStoryboard.init(storyboard: .Main).initVC()
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

    @IBOutlet weak var emailView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var doRemeber: UISwitch!
    
    var email: String = ""
    var password: String = ""
    lazy var databaseRef: DatabaseReference? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        emailView.text = (PrefUtil.instance.get(forKey: PrefKeys.EMAIL) as? String?) ?? ""
        passwordView.text = (PrefUtil.instance.get(forKey: PrefKeys.PASSWORD) as? String?) ?? ""
    }
    
    @IBAction func onLoginButtonPressed(_ sender: Any) {
        if(validate()){
            login()
        }
    }
    
    @IBAction func onRegisterPressed(_ sender: Any) {
        RegisterViewController.present(parent: self)
    }
    
    
    func validate() -> Bool{
        email = (emailView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if(email.isEmpty){
            showToast(message: "Please enter email!")
            return false
        }
        password = (passwordView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if(password.isEmpty){
            showToast(message: "Please enter password!")
            return false
        }
        return true
    }
}

extension LoginViewController{
    func login(){
        self.view.showLoader()
        databaseRef?.child("Users").observe(.value, with: { snapshot in
            guard let children = snapshot.children.allObjects as? [DataSnapshot] else {
                self.showToast(message: "Some error occurred!")
                self.view.removeLoader()
                return 
            }
            
            children.forEach { snap in
                let user: RegisterModel? = try? JSONDecoder().decode(RegisterModel.self, from: snap.valueToJSON)
                if(user?.email == self.email && user?.password == self.password){
                    self.gotoMainViewController(user!)
                }
            }
            self.showToast(message: "Wrong email or password!")
            self.view.removeLoader()
        }, withCancel: { error in
            self.showToast(message: "Some error occurred!")
            self.view.removeLoader()
        })
    }
    
    func gotoMainViewController(_ user: RegisterModel){
        if(doRemeber.isOn){
            PrefUtil.instance.put(value: email, forKey: PrefKeys.EMAIL)
            PrefUtil.instance.put(value: password, forKey: PrefKeys.PASSWORD)
        }
        
        if let encodedUser = try? JSONEncoder().encode(user){
            PrefUtil.instance.put(value: true, forKey: PrefKeys.IS_USER_LOGGED_IN)
            PrefUtil.instance.put(value: encodedUser, forKey: PrefKeys.USER_OBJECT)
        }
        self.view.removeLoader()
        MainViewController.present()
    }
}
