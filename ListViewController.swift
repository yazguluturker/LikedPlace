//
//  ListViewController.swift
//  LikedPlace
//
//  Created by Yazgülü Türker on 27.05.2022.
//

import UIKit
//Harita
import MapKit
//Kullanıcı konumu
import CoreLocation
import CoreData

class ListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{

    @IBOutlet weak var tableView: UITableView!
    var idArray = [UUID]()
    var titleArray = [String]()
    var choosenTitle = ""
    var chosenTitleId : UUID?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action:#selector(addButtonClicked))
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newPlace"), object: nil)
    }
    
    @objc func getData ()
    {
        //Database process
        let appDelegate = UIApplication.shared.delegate as!AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        //Tüm veritabanından veri getirme işlemlerinde ortak
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Places")
        request.returnsObjectsAsFaults = false
       
        //Getirdiğin verilerle yapılacak işlemler
        do
        {
        let results = try context.fetch(request)
            
            if results.count>0
            {
                
                idArray.removeAll(keepingCapacity: false)
                titleArray.removeAll(keepingCapacity: false)
                
            for result in results as! [NSManagedObject]
            {
            
                if let id = result.value(forKey: "id") as? UUID
                {
                    idArray.append(id)
                }
                if let string = result.value(forKey: "title") as? String
                {
                    titleArray.append(string)
                }
                
            }
            }
        }
        catch
        {
            print("error")
        }
        
    }
    @objc func addButtonClicked ()
    
    {
        choosenTitle = ""
        performSegue(withIdentifier: "toViewController", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        
        return titleArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        //Hangi satrıdaysa onun onun titlesini yazdırır
        cell.textLabel?.text = titleArray[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        choosenTitle = titleArray[indexPath.row]
        chosenTitleId = idArray[indexPath.row]
        performSegue(withIdentifier: "toViewController", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toViewController"
        {
            let destinationVC = segue.destination as! ViewController
            destinationVC.selectedTitle = choosenTitle
            destinationVC.selectedTitleID = chosenTitleId
        }
        
    }

    
}
