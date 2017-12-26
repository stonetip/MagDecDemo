
import UIKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate {
    
    let locMgr = CLLocationManager()
    var updating = false
    
    var currentLat: Double = 0.0
    var currentLon: Double = 0.0
    
    @IBOutlet weak var lblLatValue: UILabel!
    @IBOutlet weak var lblLonValue: UILabel!
    @IBOutlet weak var lblDeclValue: UILabel!
    @IBOutlet weak var lblDegValue: UILabel!
    @IBOutlet weak var lblCourseValue: UILabel!
    @IBOutlet weak var lblTrueNorthValue: UILabel!
    @IBOutlet weak var lblHeadingAccuracyValue: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trackLocation(nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(5)) {
            
            CheckDecData(lat: self.currentLat, lon: self.currentLon)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func trackLocation (_ sender: Any!){
        
        if CLLocationManager.authorizationStatus() == .notDetermined {
            // you have 2 choices
            // 1. requestAlwaysAuthorization
            // 2. requestWhenInUseAuthorization
            self.locMgr.requestWhenInUseAuthorization()
        }
        
        
        if self.updating {return}
        if self.locMgr.delegate == nil { self.locMgr.delegate = self }
        
        print("starting")
        
        // self.locMgr.headingFilter = 0.1
        self.locMgr.headingOrientation = .portrait
        self.locMgr.headingFilter = kCLHeadingFilterNone
        self.updating = true
        
        self.locMgr.startUpdatingHeading()
        
        self.locMgr.desiredAccuracy = kCLLocationAccuracyBest // The accuracy of the location data
        self.locMgr.distanceFilter = 1 // The minimum distance (measured in meters) a device must move horizontally before an update event is generated.
        self.locMgr.startUpdatingLocation()
        
        
        CheckDecData(lat: self.currentLat, lon: self.currentLon)
    }
    
    
    @IBAction func stopLocationTracking (_ sender: Any!){
        
        print("stopping")
        
        self.locMgr.stopUpdatingHeading()
        self.locMgr.stopUpdatingLocation()
        self.updating = false
        
        lblLatValue.text = String(format: "%.1f", 0)
        lblLonValue.text = String(format: "%.6f", 0)
        lblDeclValue.text = String(format: "%.6f", 0)
        lblDegValue.text = String(format: "%.f", 0)
        
    }
    
    // error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        self.stopLocationTracking(nil)
    }
    
    // location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            return
        }
        
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        
        currentLat = lat
        currentLon = lon
        
        lblLatValue.text = String(format: "%.6f", lat)
        lblLonValue.text = String(format: "%.6f", lon)
        
        let course = location.course
        
        lblCourseValue.text = String(format: "%.1f", course)
    }
    
    // heading
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        let headingAccuracy = newHeading.headingAccuracy
        
        lblHeadingAccuracyValue.text = String(format: "%.6f", headingAccuracy)
        
        let currentHeading = newHeading.magneticHeading
        
        if let storedDecData = UserDefaults.standard.value(forKey:"decData") as? Data {
            
            let retrievedDecData = try! PropertyListDecoder().decode(DecInfo.self, from: storedDecData)
            
            var currentHeadingAdj = currentHeading + retrievedDecData.dec
            
            if(currentHeadingAdj >= 360)
            {
                currentHeadingAdj = currentHeadingAdj - 360
            }
            
            lblDegValue.text = String(format: "%.1f", currentHeadingAdj)
            lblDeclValue.text = String(format: "%.1f", retrievedDecData.dec)
        }
        else{
            
            lblDegValue.text = String(format: "%.1f", currentHeading)
            lblDeclValue.text = "---"
        }
        
        let trueHeading = newHeading.trueHeading

        lblTrueNorthValue.text = String(format: "%.1f", trueHeading)
    }
}
