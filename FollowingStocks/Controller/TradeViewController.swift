//
//  MovingPortfolioViewController.swift
//  FollowingStocks
//
//  Created by Bruno W on 25/09/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import UIKit

class TradeViewController: UIViewController {
    
    //MARK: Properties
    var accessedBy : UIViewController!
    var paper: Paper!
    var quote: Quote!
    var trade: Trade!
    var operation: Trade.OperationType!
    let moneyDelegate = MoneyTextFieldDelegate(prefix: "")
    var activeField: UITextField!
    var keyboardHeight: CGFloat!
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()
    
    //MARK: Outlets
    @IBOutlet weak var paperTextField: UITextField!
    @IBOutlet weak var quantityTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var tradeButton: UIButton!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var navigatioBar: UINavigationBar!
    @IBOutlet weak var searchButton: UIButton!
    // Constraints
    @IBOutlet weak var constraintContentHeight: NSLayoutConstraint!
    
    //MARK: Life`s cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(type(of: self)) - viewDidLoad")
        configureUI()
        setUpTextFieldsDelegate()
        setUpUITapGestureRecognizer()
        fillUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //subscriberToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(type(of: self)) - viewWillDisappear")
        //unSubscriberToKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("\(type(of: self)) - viewDidDisappear")
    }

    // MARK: Actions
    @IBAction func searchAction(_ sender: Any) {
        print("\(type(of: self)) - performSegue")
        performSegue(withIdentifier: Constants.SegueId.tradeToSearch, sender: nil)
    }
    
    @IBAction func stepperValueChange(_ sender: UIStepper) {
        quantityTextField.text = Int(sender.value).description
    }
    
    @IBAction func unwindToTradeViewController(_ sender: UIStoryboardSegue) {
        print("\(type(of: self)) - unwindToTradeViewController")
        let vc = sender.source as! SearchViewController
        paper = vc.paper
        self.paperTextField.text = paper.symbol
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        print("\(type(of: self)) - cancelAction")
        if paper != nil, !isPaperStoraged() {
            DataController.sharedInstance().viewContext.delete(paper)
        }
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func DateAction(_ sender: Any) {
        getDate()
    }
    
    @IBAction func tradeAction (_ sender: UIButton){
        
        let quantity = Int16((quantityTextField.text! as NSString).intValue)
        let price = (self.priceTextField.text! as NSString).doubleValue
        
        guard validateFields(), validateQuantity(quantity: quantity) else {
            return
        }

        setTrade(price: price, quantity: quantity)
        
        print(trade)
        print(paper)
    
        do{
            try DataController.sharedInstance().viewContext.save()
            performSegue(withIdentifier: Constants.SegueId.unwindToDetail, sender: nil)
            dismiss(animated: true, completion: nil)
        } catch {
            fatalError("\(type(of: self)) - tradeAction: Could not save to core date")
        }
        
    }
    
    //MARK: PrepareForSegue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("\(type(of: self)) - prepareforSegue")
        if segue.identifier == Constants.SegueId.unwindToDetail{
            //Do nothing. At return to Detail, a reload occurs.
        } else {
            if let searchVC = segue.destination as? SearchViewController{
                searchVC.isToFillField = true
            }
        }
    }
    
    //MARK: Helpers
    func setUpTextFieldsDelegate() {
        quantityTextField.delegate = self
        priceTextField.delegate = moneyDelegate
        dateTextField.delegate = self
    }
    
    func setUpUITapGestureRecognizer() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func isPaperStoraged() -> Bool {
        var returnBool : Bool = false
        if paper.isPortfolio || paper.isFollowed {
            returnBool = true
        }
        return returnBool
    }
    
    func isPaperSelected() -> Bool {
        return !self.paperTextField.text!.isEmpty
    }
    
    func isQuantityValid() -> Bool {
        return Int(self.quantityTextField.text!)! > 0
    }
    
    func isPriceValid() -> Bool {
        return Float(self.priceTextField.text!)! > 0
    }
    
    func setTrade(price: Double, quantity: Int16) {
        
        switch operation! {
        case .sale:
            if quantity > paper.quantity {
                return
            } else if quantity == paper.quantity {
                paper.quantity -= quantity
                paper.isPortfolio = false
            } else {
                paper.quantity -= quantity
            }
            break
            
        case .purchase:
            paper.averageCost = averageCost(quantityA: paper.quantity, costA: paper.averageCost, quantityB: quantity, costB: price)
            paper.quantity += quantity
            paper.isPortfolio = true
        }
        
        trade = Trade(context: DataController.sharedInstance().viewContext)
        trade.date = dateFormatter.date(from: self.dateTextField.text!)
        trade.operation = operation.rawValue
        trade.price = price
        trade.quantity = quantity
        
        trade.paper = paper
    }
    
    func averageCost(quantityA : Int16, costA: Double, quantityB: Int16, costB: Double) -> Double{
        let response = (( Double(quantityA) * costA) + (Double(quantityB) * costB)) / ( Double(quantityA) + Double(quantityB))
        return response
    }
    
    //MARK : UI
    func fillUI(){
        paperTextField.text = paper?.symbol
        quantityTextField.text = "0"
        priceTextField.text = String(format: "%.02f", paper?.quote?.price ?? 0)
        dateTextField.text = dateFormatter.string(from: Date())
        self.tradeButton.setTitle(operation.rawValue, for: .normal)
    }
    
    fileprivate func configureUI() {
        if let settedSource = accessedBy, settedSource.isKind(of: DetailViewController2.self) {
            searchButton.isHidden = true
        }
    }
    
    func validateFields() -> Bool {
        guard isPaperSelected() else {
            Alerts.message(view: self, title: "Paper was not selected!", message: "\nPlease, inform Paper.")
            return false
        }
        
        guard isQuantityValid() else {
            Alerts.message(view: self, title: "Invalid quantity!", message: "\nPlease, inform Quantity.")
            return false
        }
        
        guard isPriceValid() else {
            Alerts.message(view: self, title: "Invalid price!", message: "\nPlease, inform Price.")
            return false
        }
        
        return true
    }
    
    func validateQuantity (quantity : Int16) -> Bool {
        switch operation! {
        case .sale:
            if quantity > paper.quantity {
                Alerts.message(view: self, title: "The quantity exceeded the limit!", message: "This paper have only \(paper.quantity). Choose this quantity or less!")
                return false
            }
            break
        case .purchase: break
        }
        return true
    }
}

//MARK: - UITextFieldDelegate
extension TradeViewController: UITextFieldDelegate{
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let invalidCharacters = CharacterSet(charactersIn: "0123456789").inverted
        return string.rangeOfCharacter(from: invalidCharacters) == nil
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
        activeField = nil
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        activeField = textField
        if activeField == dateTextField{
            dismissKeyboard()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
}

//MARK: - Functions when KeyBoard Appears and Disappears
extension TradeViewController {
    
    func subscriberToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unSubscriberToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(_ notification : Notification){
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyboardY = self.view.frame.size.height - keyboardSize.cgRectValue.height
        
        let editingTextFieldY : CGFloat! = self.activeField?.superview?.frame.origin.y
        
        if editingTextFieldY > keyboardY - 80 {
            view.frame.origin.y -= (editingTextFieldY - (keyboardY - 80))
        }
    }
    
    @objc func keyboardWillHide(){
        view.frame.origin.y = 0
    }
    
    func getKeyboardHeight(_ notification : Notification) -> CGFloat{
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}

//MARK: - DatePicker on Alert
extension TradeViewController{
    
    func getDate() {
        let message = "\n\n\n\n\n\n\n"
        let alert = UIAlertController(title: "Select Date", message: message, preferredStyle: .alert)
        alert.isModalInPopover = true
        
        
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: 260, height: 150))
        datePicker.datePickerMode = .date
        
        datePicker.maximumDate = Date()
        
        alert.view.addSubview(datePicker)
        datePicker.frame.origin.y += 40
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.dateTextField.text = self.dateFormatter.string(from: datePicker.date)
        })
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
