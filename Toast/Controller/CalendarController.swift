//
//  DateController.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/10/23.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

// MARK: - 日历代理
public protocol DateControllerDelegate {
    func minDate(dateController:DateController) -> Date?
    func maxDate(dateController:DateController) -> Date?
    
    func dateController(_ dc:DateController, updateBeginDate:Date)
    func dateController(_ dc:DateController, updateOverDate:Date)
    func dateController(_ dc:DateController, updateBeginDate:Date, updateOverDate:Date)
}

// MARK: - 日历控制器
open class DateController: UIViewController {

    open override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
    }
    
    
    open var visiableCells:[UIView] = []

    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        visiableCells.reserveCapacity(10)
        
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
