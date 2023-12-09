//
//  SplashViewController.swift
//  Babycare
//
//  Created by User on 12/05/23.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2.5) {
            self.handleLoginOrHome()
        }
    }
    
    func handleLoginOrHome(){
        let isLoggedIn = PrefUtil.instance.get(forKey: PrefKeys.IS_USER_LOGGED_IN) as? Bool ?? false
        if(isLoggedIn){
            // goto main
            MainViewController.present()
        } else{
            // goto login
            LoginViewController.present()
        }
    }
}
