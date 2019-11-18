//
//  ViewController.swift
//  CalculatorProject
//
//  Created by Charlie Sarano on 11/17/19.
//  Copyright © 2019 Sarano. All rights reserved.
//

import UIKit
import Firebase

class CalculatorViewController: UIViewController {
    
    @IBOutlet weak var divisionOperator: UIButton!
    @IBOutlet weak var additionOperator: UIButton!
    @IBOutlet weak var subtractionOperator: UIButton!
    @IBOutlet weak var multiplicationOperator: UIButton!
    @IBOutlet weak var squareOperator: UIButton!
    
    @IBOutlet weak var resultLabel: UILabel!
    
    var currentOperator: String = ""
    var previousOperand: Double = 0.0
    
    enum CalculatorStage {
        case noOperation
        case firstOperand
        case withOperator
        case secondOperand
    }
    
    var curStage: CalculatorStage = .noOperation
    
    let ref = Database.database().reference(withPath: "operations")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the vieww
        
        squareOperator.setTitle("x\u{00B2}", for: .normal)
        
        for view in self.view.subviews {
            if let btn = view as? UIButton {
                btn.layer.cornerRadius = (btn.frame.size.width / 3.0)
                
            }
        }
    }
    
    // This function responds to all the buttons that
    // have digits or the decinmal, and the behavior changes
    // based on what operand the digit may be added to
    // or if its starting a new operand

    @IBAction func onDigitorDecimalPress(_ sender: Any) {
        if let btn = sender as? UIButton,
            let newDigit = btn.titleLabel?.text {
            
            var resultText = ""
            if curStage == .noOperation {
                if newDigit == "." {
                    resultText = "0."
                    curStage = .firstOperand
                } else if newDigit == "0" && self.resultLabel.text == "0" {
                    return
                } else {
                    resultText = newDigit
                    curStage = .firstOperand
                }
            } else if curStage == .firstOperand {
                if newDigit == "." && self.resultLabel.text?.contains(".") ?? true {
                    return
                }
                
                resultText = self.resultLabel.text ?? ""
                resultText.append(newDigit)
                
            } else if curStage == .withOperator {
                curStage = .secondOperand
                
                resetOperatorButtons()
                
                if newDigit == "." {
                    resultText = "0."
                } else if newDigit == "0" && self.resultLabel.text == "0" {
                    return
                } else {
                
                    resultText = newDigit
                }
                
            } else {
                // this is the second operand
                if newDigit == "." && self.resultLabel.text?.contains(".") ?? true {
                    return
                }
                
                resultText = self.resultLabel.text ?? ""
                resultText.append(newDigit)
            }
            
            // Any changes to UI have to happen on the main thread
            DispatchQueue.main.async {
                self.resultLabel.text = resultText
            }
            
        }
        
    }
    
    // Function that responds to the function buttons in orange
    @IBAction func onOperationPressed(_ sender: Any) {
        // set the current operation, and then reset
        // the state of any operators that may have been pressed
        if let btn = sender as? UIButton {
            currentOperator = btn.titleLabel!.text!
            
            previousOperand = Double(self.resultLabel.text!) as! Double
            
            curStage = .withOperator
            
            DispatchQueue.main.async {
                // Changing the button to make it obvious what operator we're working with
                btn.backgroundColor = .white
                btn.setTitleColor(.orange, for: .normal)
                
                // Here's where we reset the buttons and make sure that they are the right color
                if btn != self.multiplicationOperator {
                    self.multiplicationOperator.setTitleColor(.white, for: .normal)
                    self.multiplicationOperator.backgroundColor = .orange
                }
                if btn != self.divisionOperator {
                    self.divisionOperator.setTitleColor(.white, for: .normal)
                    self.divisionOperator.backgroundColor = .orange
                }
                if btn != self.additionOperator {
                    self.additionOperator.setTitleColor(.white, for: .normal)
                        
                    self.additionOperator.backgroundColor = .orange
                }
                if btn != self.subtractionOperator {
                    self.subtractionOperator.setTitleColor(.white, for: .normal)
                    self.subtractionOperator.backgroundColor = .orange
                }
            }
        }
    }
    
    // Once the equal button is pressed, we write the
    // value to firebase
    @IBAction func finishOperation(_ sender: Any) {
        // Calculate result of operation
        if currentOperator == "" {
            return
        }
        
        resetOperatorButtons()
        
        var currentOperand =  Double(self.resultLabel.text!) as! Double
        
        var result = 0.0
        var resultString = ""
        
        switch currentOperator {
        case "+":
            result = previousOperand + currentOperand
        case "-":
            result = previousOperand - currentOperand
        case "x":
            result = previousOperand * currentOperand
        case "÷":
            if currentOperand == 0 {
                // we need to do some error handling
            }
            result = previousOperand / currentOperand
        default:
            // we should never reach this case
            print("Something went very wrong")
        }
        
        var operation = ""
        
        if floor(previousOperand) == previousOperand {
            operation = operation + String(Int(previousOperand))
        } else {
            operation = operation + String(previousOperand)
        }
        
        if sender as! UIButton == squareOperator {
            
            operation.append("\u{00B2}")
        } else {
            operation = operation + " " + currentOperator + " " +  (self.resultLabel.text ?? "0")
        }
        
        let timestamp = -Date().timeIntervalSince1970
        
        if floor(result) == result {
            // the result is an int
            resultString = String(Int(result))
            operation = operation + " = " + String(Int(result))
            
        } else {
            resultString = String(result)
            operation = operation + " = " + String(result)
        }
        
        // Any changes to UI need to be on main thread
        DispatchQueue.main.async {
            self.resultLabel.text = resultString
        }
        
        curStage = .noOperation
        
        // writing the result of the operation with a timestamp for
        // retrieving ten most recent versions
        
        // The timestamp must be negative to use Firebase to get the
        // the timestamps in Descending order
        let newOpRef = ref.childByAutoId()
        
        newOpRef.setValue(["operation":operation, "timestamp":timestamp])
    }
    
    @IBAction func onPlusMinusPressed(_ sender: Any) {
        // Negate the current value, essentially if the first character
        // is a dash, we remove it
        
        // We only do this when we are entering an established operand
        if curStage != .withOperator {
            if var currentVal = resultLabel.text {
                if currentVal != "0" {
                    if currentVal.contains("-") {
                        currentVal.removeFirst()
                        resultLabel.text = currentVal
                    } else {
                        resultLabel.text = "-" + currentVal
                    }
                }
                    
            }
        }
    }
    
    
    // The iPhone calculator app includes a percent button
    // I originally thought this was a mod function, it
    // turns out it just divides things by 100 to represent a percent as a decimal
    // I thought this was completely unnecessary
    // So I replaced it with a squaring function to add more functionality
    @IBAction func onSquarePressed(_ sender: Any) {
        currentOperator = "x"
        previousOperand = Double(self.resultLabel.text ?? "0")!
        self.finishOperation(sender)
    }
    
    
    @IBAction func onClearPressed(_ sender: Any) {
        // we reset any value in the label to be zero
        // and reset the operation
        resultLabel.text = "0"
        curStage = .noOperation
        
    }
    
    func resetOperatorButtons() {
        DispatchQueue.main.async {
            self.multiplicationOperator.setTitleColor(.white, for: .normal)
            self.multiplicationOperator.backgroundColor = .orange
            
            self.divisionOperator.setTitleColor(.white, for: .normal)
            self.divisionOperator.backgroundColor = .orange
            
            self.additionOperator.setTitleColor(.white, for: .normal)
            self.additionOperator.backgroundColor = .orange
            
            self.subtractionOperator.setTitleColor(.white, for: .normal)
            self.subtractionOperator.backgroundColor = .orange
        }
    }
    
    
    @IBAction func showPreviousOperations(_ sender: Any) {
        
        // Display operations table modally
        let operationsVC = storyboard?.instantiateViewController(identifier: "operations")
        
        self.present(operationsVC!, animated: true, completion: nil)
        
    }
}

