//
//  ViewController.swift
//  Chillzie
//
//  Created by Anthony Dotterer on 1/26/19.
//  Copyright © 2019 Chillzie. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: Properties
    @IBOutlet weak var beverageTextField: UITextField!
    @IBOutlet weak var roomTempTextField: UITextField!
    @IBOutlet weak var idealTempTextField: UITextField!
    
    @IBOutlet weak var chillButton: UIButton!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var progressView: ProgressView!
    
    var startDate: NSDate? = nil
    var targetDate: NSDate? = nil
    
    var timer = Timer()
    var noiseTimer = Timer()
    
    var timerStarted = false
    var alarmPlaying = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        updateChillTimeLabel()
    }
    
    @IBAction func testService() {
        // get a date
        let alarm = (NSDate.init() as Date) + TimeInterval(60)
        setPushNotificationAlarm(alarm: alarm, beverage: "TEST")
    }
    
    func setPushNotificationAlarm(alarm: Date, beverage: String) {
        
        // format date
        let formatter = DateFormatter()
        // initially set the format based on your datepicker date / server String
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss xxxx"
        let alarmStr = formatter.string(from: alarm as Date)
        
        print("Date")
        print(alarmStr)
        
        //get the token in NSUserDefaults
        guard let storedToken = UserDefaults.standard.string(forKey: "deviceToken") else {
            print("No stored token; no push request sent")
            return
        }
        print("StoredToken")
        print(storedToken)
        
        
        // setup our request
        let url = URL(string: "https://rest.coolzie.com/alarm")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let parameters: [String: Any] = [
            "token_hex": storedToken,
            "alarm": alarmStr,
            "beverage": beverage
        ]
        request.httpBody = parameters.percentEscaped().data(using: .utf8)
        
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print(error)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                    print(response.debugDescription)
                    return
            }
            
            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                let data = data,
                let string = String(data: data, encoding: .utf8) {
                    print("!!!!!!!respons")
                    print(string)
            }
        }
        task.resume()
    }

    @IBAction func beverageButtonTouched() {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "beverageTableViewController") as! BeverageTableViewController
        
        vc.completionHandler =  { (beverage: Beverage) in
            self.beverageTextField.text = beverage.name
            self.idealTempTextField.text = String(beverage.temp)
            
            self.updateChillTimeLabel()
        }
        
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func tempLabelsChanged(_ sender: Any) {
        updateChillTimeLabel()
    }
    
    func updateChillTimeLabel() {
        let chillTimeSeconds = getChillTime()
        
        if chillTimeSeconds > 0 {
            let seconds = chillTimeSeconds % 60
            let minutes = chillTimeSeconds / 60
            
            var msg = ""
            if minutes > 0 {
                msg = "\(minutes) mins "
            }
            if seconds > 0 {
                msg = "\(msg)\(seconds) secs"
            }
            
            print("Setting chill time to '\(msg)'")
            timeLabel.text = "Time: \(msg)"
            
        } else {
            timeLabel.text = "Enter temps."
        }
    }
    
    // seconds duration or -1 for invalid
    func getChillTime() -> Int {
        let startTemp = Double(roomTempTextField.text ?? "70") ?? 70
        let targetTemp = Double(idealTempTextField.text ?? "52") ?? 52
        
        var chillTimeSeconds: Int = -1
        if startTemp > targetTemp {
            // its about 1 minute per degree
            chillTimeSeconds = Int(ceil((startTemp - targetTemp) * 60))
            
            // extra minute for target temperatures greater than 60 degrees
            if (targetTemp > 60) {
                chillTimeSeconds += 60
            }
            
        }
        return chillTimeSeconds
    }
    
    @IBAction func chillzieButtonTouched(_ sender: Any) {
        if timerStarted || alarmPlaying {
            timer.invalidate();
            
            timerStarted = false
            alarmPlaying = false
            
            chillButton.setTitle("Chill!", for: .normal)
        } else {
            calculateTargetDate()
            runTimer()
            setPushNotificationAlarm(alarm: targetDate! as Date, beverage: self.beverageTextField.text ?? "Beverage")
            
            timerStarted = true
            alarmPlaying = false
            
            chillButton.setTitle("Stop!", for: .normal)
        }
    }
    
    func calculateTargetDate() {
        let seconds = getChillTime()
        
        startDate = NSDate.init()
        targetDate = startDate!.addingTimeInterval(TimeInterval(seconds))
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
        
        updateTimer() // run for the first time
    }
    
    @objc func updateTimer() {
        let seconds = updateProgressTimer()
        
        if seconds <= 0 {
            timer.invalidate()
            
            timerStarted = false
            alarmPlaying = true
            
            playAlarmNoise()
            runNoiseTimer()
        }
    }
    
    func updateProgressTimer() -> Double {
        let seconds = targetDate!.timeIntervalSinceNow
        let timeStr = timeString(time: seconds)
        
        let total = targetDate!.timeIntervalSince(startDate! as Date)
        let from = (seconds + 1) / total
        let to = seconds / total
        progressView.animateProgressView(from: from, to: to, text: timeStr)
        
        return seconds
    }
    
    func runNoiseTimer() {
        noiseTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: (#selector(ViewController.updateNoiseTimer)), userInfo: nil, repeats: true)
        
        updateNoiseTimer() // run for the first time
    }
    
    @objc func updateNoiseTimer() {
        if alarmPlaying {
            playAlarmNoise()
        } else {
            noiseTimer.invalidate()
        }
    }
    
    func playAlarmNoise() {
        AudioServicesPlayAlertSound(1005)  // Calendar Alarm
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
}

extension Dictionary {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}

