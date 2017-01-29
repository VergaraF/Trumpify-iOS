//
//  ViewController.swift
//  Trumpify
//
//  Created by Fabian Vergara on 2017-01-28.
//  Copyright © 2017 fvergara. All rights reserved.
//

import UIKit
import SpeechKit
import Alamofire


class ViewController: UIViewController, SKTransactionDelegate, UITextViewDelegate {
    
    enum SKSState {
        case idle
        case listening
        case processing
    }
    //USER INTERFACE
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var inputTextbox: UITextView!
    @IBOutlet var sendButton  : UIButton!
    
    @IBOutlet var bottomConstraint: NSLayoutConstraint!
    var appJustRun = true
    
    let serverURL = "http://fvergara.ddns.net:5000/"
    
    var AI = AIInteractionViewController()
    
    var language: String!
    var recognitionType: String!
    var progressiveResults: Bool!
    var endpointer: SKTransactionEndOfSpeechDetection!
    
    var skSession:SKSession?
    var skTransaction:SKTransaction?
    
    var state = SKSState.idle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextbox.delegate = self
        recognitionType = SKTransactionSpeechTypeDictation
        endpointer = .short
        language = LANGUAGE
        progressiveResults = false
        
        state = .idle
        skTransaction = nil
        
        appJustRun = true
        inputTextbox.text = "Press the microphone to record your voice. Your input will be displayed here to confirm our app got it correctly. Then, if everything seems correct, tap Send to perform our magic and have Trump answer to your sentence!. You can also type your sentence here directly without having to record your voice."
        
        // Create a session
        skSession = SKSession(url: URL(string: SKSServerUrl), appToken: SKSAppKey)
        
        if (skSession == nil) {
            let alertView = UIAlertController(title: "SpeechKit", message: "Failed to initialize SpeechKit session.", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default) { (action) in }
            alertView.addAction(defaultAction)
            present(alertView, animated: true, completion: nil)
            return
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardNotification(notification:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)

        
        loadEarcons()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let duration:TimeInterval = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIViewAnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIViewAnimationOptions = UIViewAnimationOptions(rawValue: animationCurveRaw)
            if (endFrame?.origin.y)! >= UIScreen.main.bounds.size.height {
                self.bottomConstraint?.constant = 100
            } else {
                self.bottomConstraint?.constant = endFrame?.size.height ?? 0.0
            }
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }

    func loadEarcons() {
        let startEarconPath = Bundle.main.path(forResource: "sk_start", ofType: "pcm")
        let stopEarconPath = Bundle.main.path(forResource: "sk_stop", ofType: "pcm")
        let errorEarconPath = Bundle.main.path(forResource: "sk_error", ofType: "pcm")
        let audioFormat = SKPCMFormat()
        audioFormat.sampleFormat = .signedLinear16
        audioFormat.sampleRate = 16000
        audioFormat.channels = 1
        
        
        
        skSession?.startEarcon = SKAudioFile(url: URL(fileURLWithPath: startEarconPath!), pcmFormat: audioFormat)
        skSession?.endEarcon = SKAudioFile(url: URL(fileURLWithPath: stopEarconPath!), pcmFormat: audioFormat)
        skSession?.errorEarcon = SKAudioFile(url: URL(fileURLWithPath: errorEarconPath!), pcmFormat: audioFormat)
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
        inputTextbox.text = recognition.text
        appJustRun = false
        
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
        inputTextbox.text = "Something went wrong with your audio. Make sure you have internet connection (data) and good reception. Try to speak louder and clear. Please try again."
        
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"  // Recognizes enter key in keyboard
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        let stringToSend = inputTextbox!.text.replacingOccurrences(of: " ", with: "%20")
        print("String to send " + stringToSend)
        if !appJustRun{
            Alamofire.request(serverURL + "trump/" + stringToSend).responseString { response in
               // print(response.request)
                print("Success: \(response.result.isSuccess)")
                print("Response String: \(response.result.value)")
                
                if !self.appJustRun && response.result.value != nil{
                    self.inputTextbox.text = response.result.value!
                    self.AI.string = response.result.value!
                    self.performSegue(withIdentifier: "TrumpTalksSegue", sender: self)
                }

            }
        }else{
            inputTextbox.text = inputTextbox.text + ".\n\n Enter something valid."
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "TrumpTalksSegue"{
            let vc = segue.destination as! AIInteractionViewController
            print(inputTextbox.text)
            vc.string = inputTextbox.text
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if appJustRun{
            inputTextbox.text = ""
            appJustRun = false
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}

