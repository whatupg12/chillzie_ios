//
//  ViewController.swift
//  Chillzie
//
//  Created by Anthony Dotterer on 1/26/19.
//  Copyright © 2019 Chillzie. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var minutesTextField: UITextField!
    @IBOutlet weak var secondsTextField: UITextField!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    var targetDate: NSDate? = nil
    var timer = Timer()
    var timerStarted = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func chillzieButtonTouched(_ sender: Any) {
        if timerStarted {
            timer.invalidate();
            timerStarted = false
        } else {
            calculateTargetDate()
            runTimer()
            timerStarted = true
        }
    }
    
    func requestAlarm() {
        let url = URL(string: "https://example.com/post")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    func calculateTargetDate() {
        let minutesValue = Int(minutesTextField.text ?? "0") ?? 0
        let secondsValue = Int(secondsTextField.text ?? "0") ?? 0
        
        let seconds = secondsValue + 60 * minutesValue
        
        targetDate = NSDate.init(timeIntervalSinceNow: TimeInterval(seconds))
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(ViewController.updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        let seconds = targetDate!.timeIntervalSinceNow
        timeLabel.text = timeString(time: seconds)
        
        if seconds <= 0 {
            timer.invalidate()
        }
    }
    
    func timeString(time:TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = Int(time) / 60 % 60
        let seconds = Int(time) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
}

