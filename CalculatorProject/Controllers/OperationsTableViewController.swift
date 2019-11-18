//
//  OperationsTableViewController.swift
//  CalculatorProject
//
//  Created by Charlie Sarano on 11/18/19.
//  Copyright © 2019 Sarano. All rights reserved.
//

import UIKit
import Firebase

class OperationsTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var operationsTable: UITableView!
    
    let ref = Database.database().reference(withPath: "operations")
    
    var completedOperations: [OperationObject] = []
    
    
    override func viewDidLoad() {
        // Here is where we set the table data source, delegate,
        // and then we retrieve the ten most recent operations from firebase
        
        // Can we just use basic table view cells, probably not
        
        // We also need to add this class as a
        // responder to Firebase events
        
        // We need to serapate observing a childAdded, this will
        
        ref.queryOrdered(byChild: "timestamp").queryLimited(toFirst: 10).observe(.childAdded, with: { snapshot in
            var dict: Dictionary<String, Any> = snapshot.value as! Dictionary
            let operationObject = OperationObject(operation: dict["operation"] as! String, timestamp: dict["timestamp"] as! Double)
            self.completedOperations.append(operationObject)
            // This makes sure any new items are in the correct order
            // in future implementations, I would have tried to simplify this to save on performance
            self.completedOperations.sort()
            
            self.operationsTable.reloadData()
        })
        
        operationsTable.dataSource = self
        operationsTable.delegate = self
        
        operationsTable.register(UINib(nibName: "OperationsTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        
        // Here we will stop listening for Firebase updates
        self.dismiss(animated: true, completion: nil)
    }
    
    // We don't want to show more than 10 items
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(10, completedOperations.count)
    }
    
    // returns the custom cell we created
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? OperationsTableViewCell {
            cell.operationLabel.text = completedOperations[indexPath.row].operation
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    // sets the table cells to fill out table
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return operationsTable.frame.size.height / 10
    }
    
    
}
