//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController,CLLocationManagerDelegate,ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "352370f6accac57a80316005cb92f0a2"
    

    //TODO: Declare instance variables here
    let  locationManager = CLLocationManager()
    let weatherDataModel = WeatherDataModel()
    
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String:String])
    {
        Alamofire.request(url,method:.get,parameters:parameters).responseJSON{
            response in
            if  response.result.isSuccess{
                print("Veriyi aldık")
                
                let jsonData : JSON = JSON(response.result.value!)
                print(jsonData)
                
                self.updateWeatherData(json: jsonData)
            }
            else{
                
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Bağlantı sorunu"
                
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json: JSON){
        
        if let tempResult = json["main"]["temp"].double {
            self.weatherDataModel.tempereture = Int(tempResult - 273.15)
            self.weatherDataModel.city = json["name"].stringValue
            self.weatherDataModel.condition = json["weather"][0]["id"].intValue
            var id = json["weather"][0]["id"].intValue
            print(id)
            self.weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition:id)
            
            updateUIWithWeatherData()
        }
        else{
            cityLabel.text = "Hava durumu alınamadı"
        }
        
    }

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
   func updateUIWithWeatherData()
   {
    cityLabel.text = weatherDataModel.city
    temperatureLabel.text = String(weatherDataModel.tempereture)
    weatherIcon.image = UIImage(named:weatherDataModel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
           locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("longitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            let longitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            
            let params : [String:String] = ["lat":latitude,"lon":longitude,"appid":APP_ID]
            
            getWeatherData(url: WEATHER_URL,parameters: params)
        }
        
       
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Lokasyon alınamadı"
    }
    

    //MARK: - Change City Delegate methods
    /***************************************************************/
    func userEnteredANewCityName(city: String) {
        let params : [String:String] = ["q":city,"appid":APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }
    
    //Write the userEnteredANewCityName Delegate method here:
    

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


