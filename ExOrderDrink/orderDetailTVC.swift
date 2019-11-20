//
//  orderDetailTVC.swift
//  ExOrderDrink
//
//  Created by 張哲禎 on 2019/11/15.
//  Copyright © 2019 張哲禎. All rights reserved.
//

import UIKit

class orderDetailTVC: UITableViewController {
    var orders = [DrinkOrder]()
    var order : DrinkOrder?
    var isEdit = false

    @IBOutlet weak var loading: UIActivityIndicatorView!
    override func viewDidAppear(_ animated: Bool) {
        let urlStr = "https://sheetdb.io/api/v1/t97ksdy5pk7b2".addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)!
        if let url = URL(string: urlStr){
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                let decoder = JSONDecoder()
                if let data = data,let orders = try? decoder.decode([DrinkOrder].self, from: data){
                    self.orders = orders
                    DispatchQueue.main.async {
                        self.loading.stopAnimating()
                        self.tableView.reloadData()
                    }
                }
            }
            task.resume()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return orders.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderCellId", for: indexPath) as! orderCell
        let order = orders[indexPath.row]
        cell.lbName.text = "訂購者：\(order.name!)"
        cell.lbDrink.text = "訂購飲料：\(order.drink!)"
        cell.lbQuantity.text = "訂購數量：\(order.quantity!)"
        cell.lbIce.text = "冰塊：\(order.temp)"
        cell.lbSugar.text = "甜度：\(order.percentSugar)"
        cell.lbTotalPrice.text = "總金額：\(String(Int(order.price!)! * Int(order.quantity!)!))"
        
        if order.temp.contains("正常") || order.temp.contains("少冰"){
            cell.lbIce.backgroundColor = UIColor.blue
            cell.lbIce.textColor = UIColor.white
        }
        return cell
    }

//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        self.order = self.orders[indexPath.row]
        let edit = UIContextualAction(style: .normal, title: "修改") { (action, view, bool) in
            self.isEdit = true
            self.performSegue(withIdentifier: "detailToOrder", sender: self)
        }
        edit.backgroundColor = .gray
        let delete = UIContextualAction(style: .normal, title: "刪除") { (action, view, bool) in
            let controller = UIAlertController(title: "確認刪除該筆資料", message: nil, preferredStyle: .alert)
            let ok = UIAlertAction(title: "確定", style: .default) { (alert) in
                self.orders.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                deleteData(self.order!)
            }
            let cancel = UIAlertAction(title: "取消", style: .cancel) { (alert) in
            }
            controller.addAction(ok)
            controller.addAction(cancel)
            self.present(controller,animated:true)
        }
        delete.backgroundColor = .red
        let swipeAction = UISwipeActionsConfiguration(actions: [delete,edit])
        swipeAction.performsFirstActionWithFullSwipe = false
        return swipeAction
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailToOrder" {
            let orderDrinkTVC = segue.destination as! orderDrinkTVC
            orderDrinkTVC.isEdit = isEdit
            orderDrinkTVC.order = order
        }else {
            order = orders[tableView.indexPathForSelectedRow!.row]
            let detailVC = segue.destination as! DetailVC
            detailVC.order = order
        }
    }
}
func deleteData(_ order:DrinkOrder){
    if let urlStr = "https://sheetdb.io/api/v1/t97ksdy5pk7b2/name/\(order.name!)".addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed) ,let url = URL(string: urlStr){
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let orderData = try? JSONEncoder().encode(order)
        let task = URLSession.shared.uploadTask(with: request, from: orderData!) { (retData, response, error) in
            //            傳回的json檔是Dictionary,去確認"deleted"對應的次數是否為1,就知道該筆資料是否刪除
            if let retData = retData,let deleteNumber = try? JSONDecoder().decode([String:Int].self, from: retData),deleteNumber["deleted"] == 1 {
            }else {
                print("沒東西被刪")
            }
        }
        task.resume()
    }else {
     print("連線失敗")
    }
}
