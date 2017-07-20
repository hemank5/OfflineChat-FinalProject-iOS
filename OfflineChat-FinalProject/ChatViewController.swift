//
//  ChatViewController.swift
//  OfflineChat-FinalProject
//
//  Created by Hemank Narula on 6/4/17.
//  Copyright © 2017 Hemank Narula. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let chatService = ChatManager()
    var messages = [[String:String]]()
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var connectionLabel: UILabel!
    
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBAction func onSendMessage(_ sender: Any) {
        if messageTextField.text != nil && messageTextField.text != ""{
            
            // Grab message and clear text field
            let messageText = messageTextField.text!
            messageTextField.text = ""
            
            // Send  message out
            chatService.sendText(messageText)
            
            // Adding message to tableView
            let messageData:[String:String] = ["Sender": "You", "Message": messageText]
            messages.append(messageData)
            tableView.reloadData()
            
            // Scrolling to the bottom of messages
            scrollToNewMessage()
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        chatService.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 45.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        // Setting up keyboard dismissal when tapped on screen while the keyboard is up
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ChatViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        if messages.count > 1{
            scrollToNewMessage()
            
        }
        
    }
    
    
    // MARK: TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatCell") as! ChatCell
        let messageData = messages[indexPath.row]
        
        let sender = messageData["Sender"]
        if sender == "You"{
            cell.sender.textAlignment = NSTextAlignment.right
            cell.message.textAlignment = NSTextAlignment.right
        }
        else{
            cell.sender.textAlignment = NSTextAlignment.left
            cell.message.textAlignment = NSTextAlignment.left
        }
        cell.sender.text = sender
        cell.message.text = messageData["Message"]
        return cell
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func scrollToNewMessage(){
        tableView.scrollToRow(
            at: IndexPath(row: self.messages.count - 1, section: 0),
            at: UITableViewScrollPosition.bottom,
            animated: true)
    }
    
    
    
}

extension ChatViewController : ChatServiceDelegate {
    
    func connectedDevicesChanged(_ manager: ChatManager, connectedDevices: [String]) {
        OperationQueue.main.addOperation {
            self.connectionLabel.text = "Connections: \(connectedDevices)"
        }
    }
    
    func messageReceived(_ manager: ChatManager, message: String, sender: String){
        OperationQueue.main.addOperation {
            let messageData:[String:String] = ["Sender": sender, "Message": message]
            self.messages.append(messageData)
            self.tableView.reloadData()
            self.scrollToNewMessage()
        }
    }
    
}
