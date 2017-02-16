//
//  ViewController.swift
//  MQTTChatExample
//
//  Created by Piotr Tobolski on 15.02.2017.
//  Copyright © 2017 none. All rights reserved.
//

import UIKit
import Moscapsule

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textField: UITextField!
    var mqttConfig: MQTTConfig! = nil
    var mqttClient: MQTTClient! = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = ""
        textField.becomeFirstResponder()
        
        mqttConfig = MQTTConfig(clientId: "cid\(arc4random())", host: "tobol.eu", port: 1883, keepAlive: 60)
        mqttConfig.onConnectCallback = { returnCode in
            self.append(text: "Connect: \(returnCode)")
        }
        mqttConfig.onDisconnectCallback = { reasonCode in
            self.append(text: "Disconnect: \(reasonCode)")
        }
//        mqttConfig.onPublishCallback = { messageId in
//            self.append(text: "Publish: \(messageId)")
//        }
//        mqttConfig.onMessageCallback = { mqttMessage in
//            self.append(text: "Message: \(mqttMessage)")
//        }
        mqttConfig.onSubscribeCallback = { messageId, grantedQos in
            self.append(text: "Subscribe: \(messageId), \(grantedQos)")
        }
        mqttConfig.onUnsubscribeCallback = { messageId in
            self.append(text: "Unsubscribe: \(messageId)")
        }

        mqttConfig.onMessageCallback = { mqttMessage in
            self.append(text: "Received: \(mqttMessage.payloadString ?? "\(mqttMessage)")")
        }

        mqttClient = MQTT.newConnection(mqttConfig)

        mqttClient.subscribe("temp/random", qos: 2)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        textView.text = ""
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, text.characters.count > 0 {
            mqttClient.publish(string: text, topic: "temp/random", qos: 2, retain: false)
            append(text: "Sent: \(text)")
            textField.text = ""
        }
        return false
    }

    func append(text: String) {
        DispatchQueue.main.async {
            self.textView.text = self.textView.text.appending("\n").appending(text)
            let stringLength = self.textView.text.characters.count
            self.textView.scrollRangeToVisible(NSRange(location: stringLength - 1, length: 0))
        }
    }
}

