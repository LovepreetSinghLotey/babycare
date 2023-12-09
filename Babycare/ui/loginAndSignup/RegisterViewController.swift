//
//  RegisterViewController.swift
//  Babycare
//
//  Created by User on 12/05/23.
//

import UIKit
import FirebaseStorage
import FirebaseDatabase

class RegisterViewController: BaseViewController {
    
    class func present(parent: UIViewController){
        let vc: RegisterViewController = UIStoryboard(storyboard: .Main).initVC()
        vc.modalPresentationStyle = .fullScreen
        parent.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBOutlet weak var nameView: UITextField!
    @IBOutlet weak var emailView: UITextField!
    @IBOutlet weak var passwordView: UITextField!
    @IBOutlet weak var userImageView: UIView!
    @IBOutlet weak var userImage: UIImageView!
    
    var name: String = ""
    var email: String = ""
    var password: String = ""
    
    var data: Data? = nil
    
    lazy var storageRef: StorageReference? = nil
    lazy var databaseRef: DatabaseReference? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storageRef = Storage.storage().reference()
        databaseRef = Database.database().reference()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        passwordView.isSecureTextEntry = true
        userImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onProfileTapped)))
    }
    
    @IBAction func onRegisterButtonPressed(_ sender: Any) {
        if(validate()){
            uploadUserImage()
        }
    }
    
    func validate() -> Bool{
        name = (nameView.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if(name.isEmpty){
            showToast(message: "Please enter name!")
            return false
        }
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

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @objc func onProfileTapped(){
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        DispatchQueue.main.async {
            guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            }
            
            self.dismiss(animated: true, completion: nil)
            self.userImage.image = selectedImage
            self.data = selectedImage.jpegData(compressionQuality: 0.1)!
        }
    }
}

extension RegisterViewController{
    
    func uploadUserImage(){
        if(data == nil){
            showToast(message: "Please choose a profile picture!")
            return;
        }
        self.view.showLoader()
        let imageName = "\(String.randomString(length: 30)).jpg"
        let imageRef = storageRef?.child("images/\(imageName)")
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        imageRef?.putData(data!, metadata: metadata) { (metadata, error) in
            guard let metadata = metadata else {
                self.view.removeLoader()
                self.showToast(message: "Some error occurred!")
                return
            }
            imageRef?.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    self.view.removeLoader()
                    self.showToast(message: "Some error occurred!")
                  return
                }
                self.register(downloadURL.absoluteString)
              }
        }
    }
    
    func register(_ imageUrl: String){
        let registerModel = RegisterModel(name: name, email: email, password: password, image: imageUrl).dict as? [String: String] ?? [:]
        let nameValue: String = name.replacingOccurrences(of: " ", with: "")
        let ref = databaseRef?.child("Users").child(nameValue)
        ref?.updateChildValues(registerModel){ (error: Error?, ref: DatabaseReference?) in
            if error != nil {
                self.view.removeLoader()
                self.showToast(message: "Some error occurred!")
            } else {
                self.view.removeLoader()
                self.showToast(message: "Account created successfully!")
                self.logout()
            }
        }
    }
}
