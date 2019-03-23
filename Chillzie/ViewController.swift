//
//  ViewController.swift
//  Chillzie
//
//  Created by Anthony Dotterer on 1/26/19.
//  Copyright © 2019 Chillzie. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var minutesTextField: UITextField!
    @IBOutlet weak var secondsTextField: UITextField!
    
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
            timerStarted = true
            alarmPlaying = false
            
            chillButton.setTitle("Stop!", for: .normal)
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
        timeLabel.text = timeStr
        
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

