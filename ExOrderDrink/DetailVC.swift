//
//  DetailVC.swift
//  ExOrderDrink
//
//  Created by 張哲禎 on 2019/11/17.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {
    var order:DrinkOrder?
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var print: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let order = order {
            let font = label.font
            font?.withSize(60)
            label.font = font
            label.textColor = UIColor.blue
            label.text = "訂購者\(order.name!)"
            let text = "飲料名稱：\(order.drink!)\n\n訂購杯數：\(order.quantity!)\n\n飲料大小：\(order.size)\n\n飲料冰塊：\(order.temp)\n\n飲料甜度：\(order.percentSugar)"
            print.text = text
        }
    }
}
