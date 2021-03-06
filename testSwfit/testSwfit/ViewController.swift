//
//  ViewController.swift
//  testSwfit
//
//  Created by FC on 2019/5/27.
//  Copyright © 2019年 JKB. All rights reserved.
//

import UIKit

class ViewController : UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        
        
        let menu = FC_DownMenu.init(frame: CGRect(x: 0, y: 88, width: kScreenW, height: 40), titleArr: ["价格", "销量", "时间"])
        menu.backgroundColor = UIColor.yellow
        let priceArr = ["不限", "0~10", "11~50", "51~100", "101~500", "501~800", "801~1000", "1001~2000", "20001~5000", ">5000"];
        let salesNumArr = ["全部","销量最高","销量最低"];
        let timeArr = ["全年", "今天", "7天内", "15天内", "1月内", "半年内"];
        menu.menuDataArray.add(priceArr)
        menu.menuDataArray.add(salesNumArr)
        menu.menuDataArray.add(timeArr)
        view.addSubview(menu)
        // 闭包回调选中内容
        menu.handleSelectDataBlock = { (contenStr , indexRow , butTag) in
            print("当前选择 = \(contenStr),  第 \(indexRow) 行,  按钮的tag = \(butTag)")
        }
        
    }
}
