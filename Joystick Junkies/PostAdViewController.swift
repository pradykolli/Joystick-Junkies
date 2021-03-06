//
//  PostAdViewController.swift
//  Joystick Junkies
//
//  Created by Student on 3/9/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import Parse

class PostAdViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIPickerViewDataSource,UIPickerViewDelegate {
    
    @IBOutlet weak var EndDate: UIDatePicker!
    

    
    var Genres = ["Action","Thriller","Kids","Racing","Puzzles"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Genres.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Genres[row]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gameGenre.isHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    
    @IBOutlet weak var selectedImage: UIImageView!
    @IBOutlet weak var gameName: UITextField!
    @IBOutlet weak var gameGenre: UITextField!
    @IBOutlet weak var gamePrice: UITextField!
    @IBOutlet weak var descriptionLBL: UITextView!
    @IBOutlet weak var basebidLBL: UITextField!
    
    
    
    
    @IBAction func uploadImages(_ sender: Any) {
        
        let picker = UIImagePickerController()
         picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker:UIImagePickerController, didFinishPickingMediaWithInfo: [String:Any]) {
        print(didFinishPickingMediaWithInfo)
        var selectedImage:UIImage?
        
        
        if let editedImage = didFinishPickingMediaWithInfo["UIImagePickerControllerEditedImage"] as? UIImage {
            print(editedImage.size)
            selectedImage = editedImage
        }
        
        if let originalImage = didFinishPickingMediaWithInfo["UIImagePickerControllerOriginalImage"] as? UIImage {
            print(originalImage.size)
            selectedImage = originalImage
        }
        
        if let finalImage = selectedImage {
            
            dismiss(animated: true, completion: nil)
            self.selectedImage.image = finalImage
            
        }
        
    }
    
    
    private func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        gameGenre.text = Genres[row]
    }
    
    @IBAction func PostBTN(_ sender: UIButton) {
        if gameName.text! != ""{
            print("end date : \(EndDate.date)")
            
            AppDelegate.model.games.append(gameName.text!)
            
            let Game = PFObject(className: "Game")
            let Genre = PFObject(className: "Genre")
            Game["Name"] = gameName.text!
            Game["Price"] = Int(gamePrice.text!)
            Genre["Genre"] = gameGenre.text!
            Game["EndTime"] = EndDate.date
            Game["BaseBid"] = Int(basebidLBL.text!)
            Game["Time"] = Date()
            Game["Description"] = descriptionLBL.text!
            let PNGImage = UIImagePNGRepresentation(self.selectedImage.image!)
            Game["UploadedImage"] = PFFile(name: self.gameName.text!, data: PNGImage!)
            Game["SellerInfo"] = PFUser.current()
            
            
            let query = PFQuery(className: "Genre")
            query.whereKey("Genre", equalTo: self.gameGenre.text!)
            do {
                print("done")
                let obj = try query.getFirstObject()
                
                Game["GenreID"] = obj
                
                Game.saveInBackground(block: { (success, error) -> Void in
                    if success {
                     self.performSegue(withIdentifier: "AddItem", sender: self)
                        print("Success")
                    } else {
                        print("-----------------\(String(describing: error))")
                        
                    }
                    
                })
                
            } catch {
                print(error)
                
                Genre.saveInBackground(block: { (success,error) -> Void in
                    if success {
                        let query = PFQuery(className: "Genre")
                        query.whereKey("Genre", equalTo: self.gameGenre.text!)
                        do {
                            let obj = try query.getFirstObject()
                            
                            Game["GenreID"] = obj
                        } catch {
                            print(error)
                        }
                        
                        Game.saveInBackground(block: { (success, error) -> Void in
                            if success {
                                    self.performSegue(withIdentifier: "AddItem", sender: self)
                                print("Success")
                            } else {
                                print("-----------------\(String(describing: error))")
                                
                            }
                            
                        })
                    }else {
                        print("-----------------\(String(describing: error))")
                    }
                })
            }
            
        }
        
        
        
    }
    
    


}
