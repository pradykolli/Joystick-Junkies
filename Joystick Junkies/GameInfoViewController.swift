//
//  GameInfoViewController.swift
//  Joystick Junkies
//
//  Created by Student on 3/9/18.
//  Copyright © 2018 student. All rights reserved.
//

import UIKit
import Parse

class GameInfoViewController: UIViewController {

    
    var game:PFObject?
    
    @IBOutlet weak var LatestBid: UILabel!
    @IBOutlet weak var BaseBidLBL: UILabel!
    @IBOutlet weak var GenreLBL: UILabel!
    @IBOutlet weak var PriceLBL: UILabel!
    @IBOutlet weak var GameNameLBL: UILabel!
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var descriptionTV: UITextView!
    @IBOutlet weak var TimeLBL: UILabel!
    @IBOutlet weak var bidBTN: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        let image = game!["UploadedImage"] as! PFFile
        do {
            img.image = try UIImage(data: image.getData())
        } catch {
            print("error image fetching in game info view controller")
        }
        GameNameLBL.text = game!["Name"] as? String
        descriptionTV.text = game!["Description"] as! String
        PriceLBL.text = "\(game!["Price"]!)"
        GenreLBL.text = "Action"
        BaseBidLBL.text = "\(game!["BaseBid"]!)"
        let genreid = (game?.object(forKey: "GenreID") as! PFObject)
        let query = PFQuery(className: "Genre")
        query.whereKey("objectId", equalTo: genreid.objectId)
        query.findObjectsInBackground{
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                self.GenreLBL.text = objects?.first!["Genre"] as? String
            } else {
                print("error in games info view controller")
            }
        }
        
        
        

    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        if PFUser.current() == nil {
            self.bidBTN.isHidden = true
            self.navigationItem.rightBarButtonItem?.title = "";
            self.navigationItem.rightBarButtonItem?.isEnabled = false
        }else{
            self.bidBTN.isHidden = false
            self.navigationItem.rightBarButtonItem?.title = "Logout";
            self.navigationItem.rightBarButtonItem?.isEnabled = true
        }
        let image = game!["UploadedImage"] as! PFFile
        do {
            img.image = try UIImage(data: image.getData())
        } catch  {
            print("error image fetching in game info view controller")
        }
        var timer = Timer()
        let endDate = game!["EndTime"] as! Date
        var interval = endDate.timeIntervalSince(Date())
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            interval = interval - 1
            self.TimeLBL.text = self.timeString(time: interval)
        })
        
        GameNameLBL.text = game!["Name"] as? String
        descriptionTV.text = game!["Description"] as! String
        PriceLBL.text = "\(game!["Price"]!)"
        GenreLBL.text = "Action"
        BaseBidLBL.text = "\(game!["BaseBid"]!)"
        if let bid = game!["LatestBid"] {
                LatestBid.text = "\(game!["LatestBid"]!)"
        }
        let genreid = (game?.object(forKey: "GenreID") as! PFObject)
        let query = PFQuery(className: "Genre")
        query.whereKey("objectId", equalTo: genreid.objectId)
        query.findObjectsInBackground{
            (objects: [PFObject]?, error: Error?) -> Void in
            if error == nil {
                self.GenreLBL.text = objects?.first!["Genre"] as? String
            } else {
                print("error in games info view controller")
            }
        }
    }
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        if( hours > 0 || minutes > 0 || seconds > 0 ){
            return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
        }
        else{
            bidBTN.isHidden = true
            return "Bidding Closed"
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBOutlet weak var latestBidTF: UITextField!
    
    @IBAction func LogoutBTNClicked(_ sender: Any) {
        PFUser.logOut()
        self.present(UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController, animated: true)
    }
    
    @IBAction func bidBTN(_ sender: Any) {
       // print(LatestBid.text)
        
        let bidAmount = Int((latestBidTF.text?.trimmingCharacters(in: [" "]))!)!
        if let bid = game!["LatestBid"] {
            if bidAmount > Int(bid as! Int) && bidAmount > game!["BaseBid"] as! Int {
                game!["LatestBid"] = bidAmount
                LatestBid.text = "\(String(describing: bidAmount))"
                latestBidTF.text = ""
            }
            
        }else{
            
            if bidAmount > game!["BaseBid"] as! Int {
                game!["LatestBid"] = bidAmount
                LatestBid.text = "\(String(describing: bidAmount))"
                latestBidTF.text = ""
            }

        }
        game?.saveInBackground(block: { (success, error) -> Void in
            if success {
                print("Success in saving lastest bid")
            } else {
                print("-----------------\(String(describing: error))")
                
            }
            
        })
        
        

    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destination as! SellerDescriptionViewController
        if  game?.object(forKey: "SellerInfo")  != nil {
            let seller = (game?.object(forKey: "SellerInfo") as! PFObject).objectId
                let profileQuery:PFQuery = PFUser.query()!
                do {
                    let data = try profileQuery.getObjectWithId(seller!)
                 //   print(data)
                       vc.data.append("\(data["firstName"]!)")
                     vc.data.append("\(data["lastName"]!)")
                    vc.data.append("\(data["username"]!)")
                    vc.data.append("\(data["contactNumber"]!)")
                }catch {
                     print("error while getting user info")
                }

        }else {
            
            vc.data.append("no data")
            vc.data.append("no data")
            vc.data.append("no data")
            vc.data.append("no data")
            
        }
        
      
    }
 

}
