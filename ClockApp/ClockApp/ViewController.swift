//
//  ViewController.swift
//  ClockApp
//
//  Created by Billy Conway on 2/8/25.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    //  IBOutlets
    @IBOutlet weak var liveClockLabel: UILabel!      // Label to show live clock
    @IBOutlet weak var countdownLabel: UILabel!      // Label to show countdown
    @IBOutlet weak var datePicker: UIDatePicker!       // Picker to choose timer duration
    @IBOutlet weak var actionButton: UIButton!         // Button to start/stop timer or music
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    // Properties
    var clockTimer: Timer?         // Timer to update the live clock
    var countdownTimer: Timer?     // Timer for the countdown
    var remainingTime: TimeInterval = 0
    var audioPlayer: AVAudioPlayer?
    var isPlayingMusic = false     // Track if music is playing
    
    // Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the date picker as a countdown timer.
        datePicker.datePickerMode = .countDownTimer
        
        // Start the live clock timer.
        clockTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                          target: self,
                                          selector: #selector(updateClock),
                                          userInfo: nil,
                                          repeats: true)
        updateClock() // Initial update
        countdownLabel.text = "Time Remaining:"
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundImageView.frame = view.bounds
    }
    
    //  Clock & Background Update
    @objc func updateClock() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
        liveClockLabel.text = formatter.string(from: now)
        
        // Update the background image based on the time.
        updateBackgroundImage(for: now)
    }
    
    func updateBackgroundImage(for date: Date) {
        let hour = Calendar.current.component(.hour, from: date)
        // Use "morning" image for hours before 12, and "evening" image for 12 and after.
        let imageName = (hour < 12) ? "morning" : "evening"
       
        backgroundImageView.image = UIImage(named: imageName)
    }
    
    //  Button Action
    @IBAction func actionButtonTapped(_ sender: UIButton) {
        if countdownTimer == nil && !isPlayingMusic {
            // Start the countdown timer.
            remainingTime = datePicker.countDownDuration
            if remainingTime <= 0 { return }
            
            // Disable the date picker while the countdown is running.
            datePicker.isEnabled = false
            
            // Start the countdown timer.
            countdownTimer = Timer.scheduledTimer(timeInterval: 1.0,
                                                  target: self,
                                                  selector: #selector(updateCountdown),
                                                  userInfo: nil,
                                                  repeats: true)
        } else if isPlayingMusic {
            // If music is playing, stop it and reset the UI.
            audioPlayer?.stop()
            isPlayingMusic = false
            actionButton.setTitle("Start Timer", for: .normal)
            datePicker.isEnabled = true
        }
    }
    
    //  Countdown Timer
    @objc func updateCountdown() {
        if remainingTime > 0 {
            remainingTime -= 1
            countdownLabel.text = "Time Remaining:   \(formattedTime(from: remainingTime))"
        } else {
            // Timer has ended.
            countdownTimer?.invalidate()
            countdownTimer = nil
            countdownLabel.text = "00:00:00"
            
            // Play the audio clip.
            playMusic()
            
            // Change button text to allow stopping the music.
            actionButton.setTitle("Stop Music", for: .normal)
        }
    }
    
    func formattedTime(from seconds: TimeInterval) -> String {
        let hrs = Int(seconds) / 3600
        let mins = (Int(seconds) % 3600) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d:%02d", hrs, mins, secs)
    }
    
    //  Play Music
    func playMusic() {
        // Ensure that the audio file (e.g. "music.mp3") is added to your project.
        guard let path = Bundle.main.path(forResource: "music", ofType:"mp3") else {
            print("Music file not found")
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            isPlayingMusic = true
        } catch {
            print("Error playing music: \(error.localizedDescription)")
        }
    }
}
