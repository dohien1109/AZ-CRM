//
//  AddContactControllerLH.swift
//  AZ CRM
//
//  Created by vmio vmio on 10/14/19.
//  Copyright © 2019 AZCRM. All rights reserved.
//


import UIKit
import Alamofire
import IQKeyboardManagerSwift
import SVProgressHUD

class AddContactControllerLH: BaseViewController {

    @IBOutlet weak var malhLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var nameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var cvuTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var mailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var didongTextField: SkyFloatingLabelTextField!

    @IBOutlet weak var didongkhacTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var noteTextField: SkyFloatingLabelTextField!
    
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var heightNavigationView: NSLayoutConstraint!
    @IBOutlet weak var topButton: NSLayoutConstraint!
    @IBOutlet weak var heightTitle: NSLayoutConstraint!
    @IBOutlet weak var topButtonRight: NSLayoutConstraint!
    @IBOutlet weak var makhLabel: UILabel!
    
    fileprivate var returnKeyHandler : IQKeyboardReturnKeyHandler!
    var makh: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationView.dropShadow()
        
        do {
            if let entity = try AppDelegate.context.fetch(Entity.fetchRequest()) as? [Entity] {
                heightNavigationView.constant = CGFloat(entity.last!.heightNavigation)
                topButton.constant = CGFloat(entity.last!.heightTopButton)
                heightTitle.constant = CGFloat(entity.last!.heightTitle)
                topButtonRight.constant = CGFloat(entity.last!.heightTopButtonRight)
            }
        } catch let error {
            print(error.localizedDescription)
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dissmisTextField))
        view.addGestureRecognizer(tap)
        
        nameTextField.becomeFirstResponder()
        returnKeyHandler = IQKeyboardReturnKeyHandler(controller: self)
        returnKeyHandler.lastTextFieldReturnKeyType = UIReturnKeyType.done
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = CGFloat(15)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        do {
            if let urlRegister = try AppDelegate.context.fetch(CompanyCode.fetchRequest()) as? [CompanyCode] {
                let param: Parameters = ["method": "contactcode","seckey": urlRegister.last!.seckey!]
                
                Alamofire.request(urlRegister.last!.data!, method: .post, parameters: param, encoding: JSONEncoding.default).responseJSON { (response) in
                    switch response.result {
                    case .success(let value):
                        if let valueString = response.result.value as? [String: Any] {
                            let valueCode = valueString["data"] as? String
                            self.malhLabel.text = valueCode
                        }
                        print(value)
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    @objc func dissmisTextField() {
        view.endEditing(true)
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func makhAlertButton(_ sender: UIButton) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAlertAZSoft(Api: .customers) { [unowned self] (info) in
            self.makhLabel.text = info?.customer[1] ?? ""
            self.makh = Int(info!.customer[0])
        }
        
        let heightAlert:NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.notAnAttribute, multiplier: 1, constant: self.view.frame.height * 0.80)
        alert.view.addConstraint(heightAlert)
        
        alert.addAction(title: "Cancel", style: .cancel)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func datePickerViewButon(_ sender: UIButton) {
        
        let today = Date()
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd/MM/yyyy"
        let todayString = dateFormat.string(from: today)
        self.dateLabel.text = todayString
        
        let alert = UIAlertController(title: "Ngày sinh", message: nil, preferredStyle: .actionSheet)
        
        alert.addDatePicker(mode: .date, date: Date(), minimumDate: nil, maximumDate: nil) { (date) in
            
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "dd/MM/yyyy"
            let dateOfBirth = dateFormat.string(from: date)
            
            self.dateLabel.text = dateOfBirth
            print(dateOfBirth)
            Log(date)
        }
        
        alert.addAction(title: "Done",color: .red, style: .default)
        
        alert.addAction(title: "Cancel",color: .red , style: .cancel) { _ in
            self.dateLabel.text = " "
        }
        
        present(alert, animated: true  , completion: nil)
    }
    
    @IBAction func addContactButton(_ sender: Any) {
        if nameTextField.text != " ", didongTextField.text != " " {
            //Lấy dữ liệu từ coreData
            do {
                if let entity = try AppDelegate.context.fetch(Entity.fetchRequest()) as? [Entity] {
                    if let urlRegister = try AppDelegate.context.fetch(CompanyCode.fetchRequest()) as? [CompanyCode] {
                    let  param: Parameters = ["method": "contactaddorupdate","themmoi":true,"makh": makh ?? 0,"manv": entity.last!.manv!, "maso":"\(malhLabel.text ?? "")","hoten":"\(nameTextField.text ?? "")","didong":"\(didongTextField.text ?? "")","didongkhac":"\(didongkhacTextField.text ?? "")","email":"\(mailTextField.text ?? "")","chucvu":"\(cvuTextField.text ?? "")","ghichu":"\(noteTextField.text ?? "")","ngaysinh":"\(dateLabel.text ?? "")", "seckey": urlRegister.last!.seckey!]
                    addContact(param: param)
                    }
                }
            } catch  {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        } else {
            let alert = UIAlertController(title: "Cần nhập đủ dữ liệu", message: nil, preferredStyle: .alert)
            alert.addAction(title: "Ok", style: .cancel)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func addContact(param: Parameters) {
        do {
            if let urlRegister = try AppDelegate.context.fetch(CompanyCode.fetchRequest()) as? [CompanyCode] {
                Alamofire.request(urlRegister.last!.data!, method: .post, parameters: param, encoding: JSONEncoding.default).responseJSON { (response) in
                    switch response.result {
                    case .success( _):
                        if let valueString =  response.result.value as? [String: Any]  {
                            if let message = valueString["msg"] as? String {
                                if message == "ok" {
                                    SVProgressHUD.show()
                                    SVProgressHUD.setStatus("Thành công")
                                    SVProgressHUD.dismiss(withDelay: 1, completion: {
                                        self.dismiss(animated: true, completion: nil)
                                    })
                                } else {
                                    let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
                                    let openAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                                    alert.addAction(openAction)
                                    self.present(alert, animated: true, completion: nil)
                                    print("thieu")
                                }
                            }
                        }
                        break
                    case .failure( _):
                        break
                    }
                }
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
