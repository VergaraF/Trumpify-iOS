//
//  ViewController.swift
//  Trumpify
//
//  Created by Fabian Vergara on 2017-01-28.
//  Copyright © 2017 fvergara. All rights reserved.
//

import UIKit
import SpeechKit
//import Alamofire


class ViewController: UIViewController, SKTransactionDelegate, UITextFieldDelegate {
    
    enum SKSState {
        case idle
        case listening
        case processing
    }
    //USER INTERFACE
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var inputTextbox: UITextView!
    @IBOutlet var sendButton  : UIButton!
    
    
    var language: String!
    var recognitionType: String!
    var progressiveResults: Bool!
    var endpointer: SKTransactionEndOfSpeechDetection!
    
    var skSession:SKSession?
    var skTransaction:SKTransaction?
    
    var state = SKSState.idle

   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        recognitionType = SKTransactionSpeechTypeDictation
        endpointer = .short
        language = LANGUAGE
        progressiveResults = false
        
        state = .idle
        skTransaction = nil
        
        // Create a session
        skSession = SKSession(url: URL(string: SKSServerUrl), appToken: SKSAppKey)
        
        if (skSession == nil) {
            let alertView = UIAlertController(title: "SpeechKit", message: "Failed to initialize SpeechKit session.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default) { (action) in }
            alertView.addAction(defaultAction)
            present(alertView, animated: true, completion: nil)
            return
        }
        
        loadEarcons()
    }

    func loadEarcons() {
        let startEarconPath = Bundle.main.path(forResource: "sk_start", ofType: "pcm")
        let stopEarconPath = Bundle.main.path(forResource: "sk_stop", ofType: "pcm")
        let errorEarconPath = Bundle.main.path(forResource: "sk_error", ofType: "pcm")
        let audioFormat = SKPCMFormat()
        audioFormat.sampleFormat = .signedLinear16
        audioFormat.sampleRate = 16000
        audioFormat.channels = 1
        
        skSession!.startEarcon = SKAudioFile(url: URL(fileURLWithPath: startEarconPath!), pcmFormat: audioFormat)
        skSession!.endEarcon = SKAudioFile(url: URL(fileURLWithPath: stopEarconPath!), pcmFormat: audioFormat)
        skSession!.errorEarcon = SKAudioFile(url: URL(fileURLWithPath: errorEarconPath!), pcmFormat: audioFormat)
    }
    
    @IBAction func recordListener(_ sender: Any) {
        switch state {
            case .idle:
                recognize()
            case .listening:
                stopRecording()
            case .processing:
                cancel()
        }
    }
    
    func recognize() {
        // Start listening to the user.
        
        recordButton.setImage(UIImage(named: "mic-on.png"), for: UIControlState())
        
        let options = NSMutableDictionary()
        if(progressiveResults!) {
            options.setValue(SKTransactionResultDeliveryProgressive, forKey: SKTransactionResultDeliveryKey);
        }
        
        skTransaction = skSession!.recognize(withType: recognitionType,
                                             detection: endpointer,
                                             language: language,
                                             options: nil,
                                             delegate: self)
    }
    
    func stopRecording() {
        // Stop recording the user.
        skTransaction!.stopRecording()
        
        // Disable the button until we received notification that the transaction is completed.
         recordButton.isEnabled = false
    }
    
    func cancel() {
        // Cancel the Reco transaction.
        // This will only cancel if we have not received a response from the server yet.
        skTransaction!.cancel()
    }
    
    // MARK: - SKTransactionDelegate
    
    func transactionDidBeginRecording(_ transaction: SKTransaction!) {
        print("transactionDidBeginRecording")
        
        state = .listening
       // startPollingVolume()
        recordButton.setTitle("Listening..", for: UIControlState())
    }
    
    func transactionDidFinishRecording(_ transaction: SKTransaction!) {
        print("transactionDidFinishRecording")
        
        state = .processing
      //  stopPollingVolume()
        recordButton.setTitle("Processing..", for: UIControlState())
    }
    
    func transaction(_ transaction: SKTransaction!, didReceive recognition: SKRecognition!) {
        print(String(format: "didReceiveRecognition: %@", arguments: [recognition.text]))
    }
    
    func transaction(_ transaction: SKTransaction!, didReceiveServiceResponse response: [AnyHashable : Any]!) {
        print(String(format: "didReceiveServiceResponse: %@", arguments: [response]))
    }
    
    func transaction(_ transaction: SKTransaction!, didFinishWithSuggestion suggestion: String) {
        print("didFinishWithSuggestion")
        
        state = .idle
        resetTransaction()
    }
    
    func transaction(_ transaction: SKTransaction!, didFailWithError error: Error!, suggestion: String) {
        print(String(format: "didFailWithError: %@. %@", arguments: [error.localizedDescription, suggestion]))
        
        // Something went wrong. Ensure that your credentials are correct.
        // The user could also be offline, so be sure to handle this case appropriately.
        
        state = .idle
        resetTransaction()
    }
    
    func resetTransaction() {
        OperationQueue.main.addOperation({
            self.skTransaction = nil
            self.recordButton.setTitle("", for: UIControlState())
            self.recordButton.isEnabled = true
            self.recordButton.setImage(UIImage(named: "mic-off.png"), for: UIControlState())
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        inputTextbox.resignFirstResponder()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputTextbox.resignFirstResponder()
        return true
    }


}

