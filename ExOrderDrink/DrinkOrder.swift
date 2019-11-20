//
//  DrinkOrder.swift
//  ExOrderDrink
//
//  Created by 張哲禎 on 2019/11/15.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import Foundation

struct DrinkOrder:Codable {
    var name:String?
    var drink:String?
    var price:String?
    var quantity:String?
    var percentSugar:String
    var temp:String
    var size:String
}

struct DrinkOrderData:Codable {
    var data:DrinkOrder
}


