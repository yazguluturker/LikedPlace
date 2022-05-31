//
//  ViewController.swift
//  LikedPlace
//
//  Created by Yazgülü Türker on 27.05.2022.
//

import UIKit
import MapKit
import CoreData


class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var choosenLatitude = Double()
    var choosenLongitude = Double()
    var selectedTitleID :UUID?
    var selectedTitle = ""
    var annotationTitle = ""
    var annotationSubtitle = ""
    var annotationLatitude = Double()
    var annotationLongitude = Double()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //Haria delegasyonu
        mapView.delegate = self
        //Kullanıcının konumunun delegasyonu
        locationManager.delegate = self
        //Konumu en iyi şekilde tahmin eder
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //Konum ne zaman kullanılsın
        locationManager.requestWhenInUseAuthorization()
        
        //Kullanıcının konumu kullanılmaya başladı.
        locationManager.startUpdatingLocation()
        
        let hideGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(hideGestureRecognizer)
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(choosenLocation))
        gestureRecognizer.minimumPressDuration = 2
        mapView.addGestureRecognizer(gestureRecognizer)
        
        if selectedTitle != ""
        {
            //Core Data
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            //Seçili id'yi getirir.
            let idString = selectedTitleID!.uuidString
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Places")
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString)
            
            fetchRequest.returnsObjectsAsFaults = false
            
            
            do{
            let results = try context.fetch(fetchRequest)
                
                if results.count>0
                {
                    for result in results as! [NSManagedObject]
                    {
                        if let title = result.value(forKey: "title") as? String
                        {
                           annotationTitle = title
                            
                            if let subtitle = result.value(forKey: "subtitle") as? String
                            {
                                 annotationSubtitle = subtitle
                                if let latitude = result.value(forKey: "latitude") as? Double
                                {
                                    
                                    annotationLatitude = latitude
                                    
                                    
                                    if let longitude = result.value(forKey: "longitude") as? Double
                                    {
                                        annotationLongitude = longitude
                                        
                                        let annotation = MKPointAnnotation()
                                        
                                        annotation.title = annotationTitle
                                        annotation.subtitle = annotationSubtitle
                                        
                                        let cordinate = CLLocationCoordinate2D(latitude: annotationLatitude, longitude: annotationLongitude)
                                        annotation.coordinate = cordinate
                                        
                                        mapView.addAnnotation(annotation)
                                        nameText.text = annotationTitle
                                        commentText.text = annotationSubtitle
                                        
                                        //Konum almayı durdurdu.
                                        locationManager.stopUpdatingLocation()
                                        
                                        //Seçilen konumu yakınlaştırıyor
                                        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                                        let region = MKCoordinateRegion(center: cordinate, span: span)
                                        
                                        mapView.setRegion(region, animated: true)
                                                                            
                                    }
                                }
                            }
                        }
                       
                        
                        

                    }
                }
                
                
                
            }
            catch
            {
                print("error")
            }
            
            
            
        }
    
        else
        {
            //Add new Data
        }
        
        
        
    }
    
    @objc func hideKeyboard ()
    {
        view.endEditing(true)

    }

    
    @objc func choosenLocation(gestureRecognizer:UILongPressGestureRecognizer)
    {
        
        if gestureRecognizer.state == .began
        {
            //Dokunulan noktayı aldı
            let touchedPoint = gestureRecognizer.location(in: self.mapView)
            //dokunulan noktayı coordinatlara çevirecek
            let touchedCoordinates = self.mapView.convert(touchedPoint, toCoordinateFrom: self.mapView)
            
             choosenLatitude = touchedCoordinates.latitude
             choosenLongitude = touchedCoordinates.longitude
            
            //Pinleme yani annotation yapacağız.
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = touchedCoordinates
            annotation.title = nameText.text
            annotation.subtitle = commentText.text
            self.mapView.addAnnotation(annotation)
            
        }
        
    }
    
    //Konum alındığında yapılacaklar
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if selectedTitle == ""
        {
        //Konum enlem ve boylam cinsinden alındı
        let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)
        //Haritayı yakınlaştırma seviyesi
        let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        
        let region =  MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        }
    }
    
    //Özelleştirilmiş pin yaptık. Pine tıklayınca bilgi detay gösteren
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //Kullanıcının yerini pinle göstermeye çalışırsa nil döndürür.
        if annotation is MKUserLocation
        {
            return nil
        }
        var reuseId  = "myAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
     
        if pinView == nil
        {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = UIColor.black
            
            //i harfini gösteren kod
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button
        }
        
        else
        {
            pinView?.annotation = annotation
        }
        return pinView
    }
    
    //i harfine basılıp basılmadığını kontrol eder.
    
    //Navigasyonu çalıştırır.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if selectedTitle != ""
        {
            let requestLocation = CLLocation(latitude: annotationLatitude, longitude: annotationLongitude)
            
            CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
                //closure
                
                if let placemark = placemarks
                {
                if placemark.count>0
                {
                    let newPlacemark = MKPlacemark(placemark: placemark[0])
                    let item = MKMapItem(placemark: newPlacemark)
                    item.name = self.annotationTitle
                    let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                    item.openInMaps(launchOptions:launchOptions)
                }
                }
            }
        }
    }
    
    
    
    @IBAction func saveButtonClicked(_ sender: Any)
    {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
            
        if nameText.text != "" && commentText.text != ""
        {
            
            newPlace.setValue(nameText.text, forKey: "title")
            newPlace.setValue(commentText.text, forKey: "subtitle")
            newPlace.setValue(choosenLatitude, forKey: "latitude")
            newPlace.setValue(choosenLongitude, forKey: "longitude")
            newPlace.setValue(UUID(), forKey: "id")
            
            
            do
            {
            try context.save()
                print("success")
            }
            catch
            {
                print("error")
            }
            
            //Bütün app'e mesaj gönderir.
            NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object: nil)
            //Bir önceki view controller'a geri götürür
            navigationController?.popViewController(animated: true)
        }
        
        else
        {
            //AlertController oluşturduk.
            let alert = UIAlertController(title: "Error", message: "Name or comment or point cannot be empty ", preferredStyle: UIAlertController.Style.alert)
            
            //alert diyerek VC verdik true diyerek animasyonlu gösterildi completion ise gösterildikten sonra bir işlem yapılmasını istiyor musun? nil (hayır)
            let okButton = UIAlertAction(title: "OK", style: UIAlertAction.Style.default)
            alert.addAction(okButton)
            
            self.present(alert, animated: true, completion:nil)
        }
    }
    
}

