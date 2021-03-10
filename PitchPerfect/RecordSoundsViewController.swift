//
//  RecordSoundsViewController.swift
//  PitchPerfect
//
//  Created by Ygor Santos on 03/02/21.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    
    enum Constants {
        static let RecordingInProgressLabel = "Recording in progress"
        static let TapToRecordLabel = "Tap to Record"
        static let ViewControllerIdentifier = "stopRecording"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopRecordingButton.isEnabled = false
    }
    
    @IBAction func recordAudio(_ sender: Any) {
        configureIdleUi(false)
        
        guard let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true).first else {
                return
            }
        
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        
        guard let filePath = URL(string: pathArray.joined(separator: "/")) else {
                return
            }
        
        let session = AVAudioSession.sharedInstance()
        
        
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        
        try? audioRecorder = AVAudioRecorder(url: filePath, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    @IBAction func stopRecording(_ sender: Any) {
        configureIdleUi(true)
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: Constants.ViewControllerIdentifier, sender: audioRecorder.url)
        } else {
            print("Recording was not successfull")
        }
    }
    
    func configureIdleUi(_ enabled: Bool) {
        recordButton.isEnabled = enabled
        stopRecordingButton.isEnabled = !enabled
        
        recordingLabel.text = enabled ? Constants.TapToRecordLabel : Constants.RecordingInProgressLabel
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
           if segue.identifier == Constants.ViewControllerIdentifier,
              let playSoundsVC = segue.destination as? PlaySoundsViewController,
              let recordedAudioURL = sender as? URL {
               playSoundsVC.recordedAudioURL = recordedAudioURL
           }
       }
}

