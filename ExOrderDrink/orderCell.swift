//
//  orderCell.swift
//  ExOrderDrink
//
//  Created by 張哲禎 on 2019/11/16.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit

class orderCell: UITableViewCell {
    
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbDrink: UILabel!
    @IBOutlet weak var lbQuantity: UILabel!
    @IBOutlet weak var lbIce: UILabel!
    @IBOutlet weak var lbSugar: UILabel!
    @IBOutlet weak var lbTotalPrice: UILabel!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
