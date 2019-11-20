//
//  orderDrinkTVC.swift
//  ExOrderDrink
//
//  Created by 張哲禎 on 2019/11/14.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit

class orderDrinkTVC: UITableViewController, UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate {
    @IBOutlet weak var tfName: UITextField!
    @IBOutlet weak var tfDrink: UITextField!
    @IBOutlet weak var smSugar: UISegmentedControl!
    @IBOutlet weak var smTemp: UISegmentedControl!
    @IBOutlet weak var smSize: UISegmentedControl!
    @IBOutlet weak var lbQuantity: UILabel!
    @IBOutlet weak var lbTotalPrice: UILabel!
    @IBOutlet weak var lbOrderDetail: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    
    let drinkPickerView = UIPickerView()
    let toolBar = UIToolbar()
    var drinkArray = [String]()
    var priceArray = [Int]()
    var drinkPriceArray = [String:Int]()
    var drink:String?
    var price:Int?
    var quantity = 0
    var percentSugar = "正常"
    var temp = "正常"
    var size = "大杯"
    var order:DrinkOrder?
    var isEdit = false
    var iQun = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tfDrink.inputView = drinkPickerView
        tfDrink.inputAccessoryView = toolBar
        drinkPickerView.delegate = self
        drinkPickerView.dataSource = self
        pickViewAddToolBar()
        loading.stopAnimating()
        
        if let asset = NSDataAsset(name: "迷克夏"), let content = String(data: asset.data, encoding: .utf8){
            let allArray = content.components(separatedBy: "\n")
            for i in 0..<allArray.count {
                if i % 2 == 0 {
                    drinkArray.append(allArray[i])
                } else {
                    priceArray.append(Int(allArray[i])!)
                }
            }
            for j in stride(from: 0, to: drinkArray.count, by: 1) {
                let drink = drinkArray[j]
                let price = priceArray[j]
                drinkPriceArray[drink] = price
            }
        }
        if isEdit{
            drink = order?.drink
            size = order!.size
            temp = order!.temp
            percentSugar = order!.percentSugar
            quantity = Int(order!.quantity!)!
            price = Int(order!.price!)
            title = "訂單修改"
            tfName.text = order?.name
            tfName.backgroundColor = UIColor.gray
            tfName.textColor = UIColor.white
            tfName.isUserInteractionEnabled = false
            
            for i in 0..<drinkArray.count{
                if order?.drink == drinkArray[i]{
                    drinkPickerView.selectRow(i, inComponent: 0, animated: true)
                    tfDrink.text = "\(drinkArray[i]) $: \(priceArray[i])"
                }
            }
            switch order?.percentSugar {
            case "正常":
                smSugar.selectedSegmentIndex = 0
            case "少糖":
                smSugar.selectedSegmentIndex = 1
            case "微糖":
                smSugar.selectedSegmentIndex = 2
            case "無糖":
                smSugar.selectedSegmentIndex = 3
            default:
                print("甜度錯誤")
            }
            switch order?.temp {
            case "正常":
                smTemp.selectedSegmentIndex = 0
            case "少冰":
                smTemp.selectedSegmentIndex = 1
            case "微冰":
                smTemp.selectedSegmentIndex = 2
            case "去冰":
                smTemp.selectedSegmentIndex = 3
            default:
                print("冰塊錯誤")
            }
            switch order?.size {
            case "大杯":
                smSize.selectedSegmentIndex = 0
            case "中杯":
                smSize.selectedSegmentIndex = 1
            default:
                print("size錯誤")
            }
            lbQuantity.text = order?.quantity
            quantity = Int(order!.quantity!)!
         
            if (drink?.contains("無糖"))!{
                smSugar.selectedSegmentIndex = 3
                smSugar.setEnabled(false, forSegmentAt: 0)
                smSugar.setEnabled(false, forSegmentAt: 1)
                smSugar.setEnabled(false, forSegmentAt: 2)
            }
        }
    }
    
    @IBAction func btOrder(_ sender: UIButton) {
        if isEdit{
//            sender.setTitle("確認修改", for: .normal)
            let newOrder = DrinkOrder(name:self.tfName.text!,drink: self.drink!, price: String(self.price!), quantity: String(self.quantity), percentSugar: self.percentSugar, temp: self.temp, size: self.size)
            let alertControl = UIAlertController(title: "是否確認修改", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default) { (alert) in
                self.loading.startAnimating()
                let newOrderDrinkData = DrinkOrderData(data: newOrder)
                let encoder = JSONEncoder()
                if let data = try? encoder.encode(newOrderDrinkData){
                    var request = URLRequest(url: URL(string: "https://sheetdb.io/api/v1/t97ksdy5pk7b2/name/\(self.order!.name!)")!)
                    request.httpMethod = "PUT"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    let task = URLSession.shared.uploadTask(with: request, from: data) { (data, response, error) in
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "orderDetailS", sender: nil)
                            self.loading.stopAnimating()
                        }
                    }
                    task.resume()
                }
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel) { (alert) in
            }
            alertControl.addAction(cancel)
            alertControl.addAction(ok)
            present(alertControl,animated: true)
            
        }
        if tfName.text == "" || price == nil ||  lbQuantity.text == "0" {
            let alertControl = UIAlertController(title: "請輸入完整資料", message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "確定", style: .default) { (alert) in
            }
            alertControl.addAction(alertAction)
            present(alertControl,animated:true)
        }else {
            let alertControl = UIAlertController(title: "是否確認訂購指定品項", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default) { (alert) in
                self.loading.startAnimating()
                let order = DrinkOrder(name:self.tfName.text!,drink: self.drink!, price: String(self.price!), quantity: String(self.quantity), percentSugar: self.percentSugar, temp: self.temp, size: self.size)
                let orderDrinkData = DrinkOrderData(data: order)
                let encoder = JSONEncoder()
                if let data = try? encoder.encode(orderDrinkData){
                    var request = URLRequest(url: URL(string: "https://sheetdb.io/api/v1/t97ksdy5pk7b2")!)
                    request.httpMethod = "post"
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    let task = URLSession.shared.uploadTask(with: request, from: data) { (data, response, error) in
                        DispatchQueue.main.async {
                            self.loading.stopAnimating()
                            self.performSegue(withIdentifier: "orderDetailS", sender: nil)
                        }
                    }
                    task.resume()
                }
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel) { (alert) in
            }
            alertControl.addAction(cancel)
            alertControl.addAction(ok)
            present(alertControl,animated: true)
        }
    }
    
    @IBAction func smSugar(_ sender: UISegmentedControl) {
        if drink != nil {
            if drink!.contains("無糖"){
                percentSugar = "無糖"
                sender.selectedSegmentIndex = 3
                sender.setEnabled(false, forSegmentAt: 0)
                sender.setEnabled(false, forSegmentAt: 1)
                sender.setEnabled(false, forSegmentAt: 2)
                return
            }
        }
        
        let selectIndex = sender.selectedSegmentIndex
        switch selectIndex {
        case 0:
            percentSugar = "正常"
        case 1:
            percentSugar = "少糖"
        case 2:
            percentSugar = "半糖"
        case 3:
            percentSugar = "無糖"
        default:
            percentSugar = ""
        }
        if price != 0 && quantity != 0 && price != nil {
            lbOrderDetail.text = "\(tfName.text!) 訂購 \(drink!)\(size)\(quantity)杯,甜度\(percentSugar)冰塊\(temp)"
        }
    }
    
    @IBAction func smTemp(_ sender: UISegmentedControl) {
        let selectIndex = sender.selectedSegmentIndex
        switch selectIndex {
        case 0:
            temp = "正常"
        case 1:
            temp = "少冰"
        case 2:
            temp = "微冰"
        case 3:
            temp = "去冰"
        default:
            temp = ""
        }
        if price != 0 && quantity != 0 && price != nil && quantity != nil{
            lbOrderDetail.text = "\(tfName.text!) 訂購 \(drink!)\(size)\(quantity)杯,甜度\(percentSugar)冰塊\(temp)"
        }
    }
    @IBAction func smSize(_ sender: UISegmentedControl) {
        let selectIndex = sender.selectedSegmentIndex
        switch selectIndex {
        case 0:
            if size.elementsEqual("中杯") {
                price! += 5
            }
            size = "大杯"
        case 1:
            if size.elementsEqual("大杯") {
                price! -= 5
            }
            size = "中杯"
        default:
            size = ""
        }
        if price != 0 && quantity != 0 && price != nil && quantity != nil{
            let totalPrice = price! * quantity
            lbTotalPrice.text = String(totalPrice)
            lbOrderDetail.text = "\(tfName.text!) 訂購 \(drink!)\(size)\(quantity)杯,甜度\(percentSugar)冰塊\(temp)"
        } else {
            lbTotalPrice.text = "0"
        }
    }
    
    @IBAction func spQuantity(_ sender: UIStepper) {
        let num = Double(lbQuantity.text ?? "") ?? 0.0
        var correctionValue = 0.0
        if iQun == 0{
            if sender.value ==  2.0 {
                correctionValue = 1
            }
            if sender.value ==  0.0 {
                correctionValue = -1
            }
            sender.value = num + correctionValue
            iQun += 1
        }
//        以上correctionValue修正值,是為了處理要修改飲料時,做stepper數量變更時,價格跟數量標示要一起動
//        此時stepper最小值必須調到小於0,才能讓使用者一開始點減少就能成功,但後續要做檢查
        
        quantity = Int(sender.value)
        lbQuantity.text = "\(Int(sender.value))"
//        if size.elementsEqual("中杯") {
//            price! -= 5
//        }
        if price != 0 && quantity > 0 && price != nil && quantity != nil{
            let totalPrice = price! * quantity
            lbTotalPrice.text = String(totalPrice)
            lbOrderDetail.text = "\(tfName.text!) 訂購 \(drink!)\(size)\(quantity)杯,甜度\(percentSugar)冰塊\(temp)"
        }else {
            lbTotalPrice.text = "0"
        }
    }
    
    @IBAction func didEndOnExit(_ sender: Any) {
    }
    @IBAction func closeActionSheet(_ sender: Any) {
        tfDrink.resignFirstResponder()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return drinkArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let drink = drinkArray[row]
        let price = String(priceArray[row])
        return drink + "  $:" + price
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        let drink = drinkArray[row]
//        let price = String(priceArray[row])
//        tfDrink.text = drink + "  $:" + price
//        self.view.endEditing(true)
    }
    func pickViewAddToolBar(){
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.blue
        toolBar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "確認", style: .done, target: self, action: #selector(self.doneAction))
        let randomButton = UIBarButtonItem(title: "隨機選擇", style: .plain, target: self, action: #selector(self.random))
        randomButton.tintColor = UIColor.red
        let cancelButton = UIBarButtonItem(title: "取消", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.closeView))
        let spaceLeftButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        toolBar.setItems([cancelButton,spaceLeftButton,randomButton,spaceLeftButton,doneButton], animated: false)

    }
    // 飲料選項按下確定事件
    @objc func doneAction() {
        let selectedRowForPicker = drinkPickerView.selectedRow(inComponent: 0)
        tfDrink.text = "\(drinkArray[selectedRowForPicker])  $:\(String(priceArray[selectedRowForPicker]))"
        price = priceArray[selectedRowForPicker]
        drink = drinkArray[selectedRowForPicker]
        
        if size.elementsEqual("中杯") {
            price! -= 5
        }
        
        if quantity != 0  && quantity != nil{
            let totalPrice = price! * quantity
            lbTotalPrice.text = String(totalPrice)
        }
        self.view.endEditing(true)
        
        if drink!.contains("無糖"){
            percentSugar = "無糖"
            smSugar.selectedSegmentIndex = 3
            smSugar.setEnabled(false, forSegmentAt: 0)
            smSugar.setEnabled(false, forSegmentAt: 1)
            smSugar.setEnabled(false, forSegmentAt: 2)
        } else {
            smSugar.selectedSegmentIndex = 0
            smSugar.setEnabled(true, forSegmentAt: 0)
            smSugar.setEnabled(true, forSegmentAt: 1)
            smSugar.setEnabled(true, forSegmentAt: 2)
        }
    }
    // 飲料選項按下取消事件
    @objc func closeView() {
        self.view.endEditing(true)
    }
    // 飲料選項按下隨機事件
    @objc func random(){
        let randomNumber = Int.random(in: 0..<drinkArray.count)
        tfDrink.text = "\(drinkArray[randomNumber])  $:\(String(priceArray[randomNumber]))"
        price = priceArray[randomNumber]
        drink = drinkArray[randomNumber]
        if size.elementsEqual("中杯") {
            price! -= 5
        }
        if quantity != 0  && quantity != nil {
            let totalPrice = price! * quantity
            lbTotalPrice.text = String(totalPrice)
        }
        self.view.endEditing(true)
        if drink!.contains("無糖"){
            percentSugar = "無糖"
            smSugar.selectedSegmentIndex = 3
            smSugar.setEnabled(false, forSegmentAt: 0)
            smSugar.setEnabled(false, forSegmentAt: 1)
            smSugar.setEnabled(false, forSegmentAt: 2)
        }else {
            smSugar.selectedSegmentIndex = 0
            smSugar.setEnabled(true, forSegmentAt: 0)
            smSugar.setEnabled(true, forSegmentAt: 1)
            smSugar.setEnabled(true, forSegmentAt: 2)
        }
    }
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 0
//    }

//    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        // #warning Incomplete implementation, return the number of rows
//        return 0
//    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

}
