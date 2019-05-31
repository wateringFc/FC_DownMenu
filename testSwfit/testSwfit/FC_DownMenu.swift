//
//  FC_DownMenu.swift
//  testSwfit
//
//  Created by FC on 2019/5/29.
//  Copyright © 2019年 JKB. All rights reserved.
//

import UIKit

/// 屏幕宽
let kScreenW : CGFloat = UIScreen.main.bounds.size.width
/// 屏幕高
let kScreenH : CGFloat = UIScreen.main.bounds.size.height
/// 设置闭包别名
typealias selectDataBlock = ((String, Int, Int) -> Void)

class FC_DownMenu: UIView {
    /// 处理选中的数据闭包
    var handleSelectDataBlock: selectDataBlock?
    /// 存放每个Button对应下的TableView数据
    lazy var menuDataArray = NSMutableArray()
    /// 数据源
    fileprivate var tableDataArray: NSArray?
    /** cell高度 */
    fileprivate let KTableViewCellH: CGFloat = 45
    /** 最大显示数 */
    fileprivate let KMaxCellNum: CGFloat =  8
    /** 标记值 */
    fileprivate let KTitleButTag: Int = 1000
    /// 原始高度
    fileprivate var selfOriginalHeight: CGFloat = 0
    /// 列表最大高度
    fileprivate var tableViewMaxHeight: CGFloat = 0
    /// 临时按钮
    fileprivate var tempButton = UIButton()
    /// 列表是否打开，默认为否
    fileprivate var isViewOpen: Bool = false
    /// 标题文字数组
    fileprivate var titleArray = NSArray()
    /// 是否可以滑动tableview
    fileprivate var isScrollEnabled: Bool?{
        didSet{
            tableView.isScrollEnabled = isScrollEnabled!
        }
    }
    /// 按钮数组
    fileprivate lazy var buttonArray = NSMutableArray()
    /// 列表
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(x: 0, y: self.height, width: kScreenW, height: 0), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.backgroundColor = UIColor.white
        tableView.separatorStyle = .none
        return tableView
    }()
    /// 遮罩视图
    fileprivate lazy var maskBgView: UIView = {
        let maskBgView = UIView(frame: CGRect(x: 0, y: 40, width: kScreenW, height: kScreenH - self.frame.origin.y))
        maskBgView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        maskBgView.isHidden = true
        maskBgView.isUserInteractionEnabled = true
        return maskBgView
    }()
    
    
    init(frame: CGRect, titleArr: NSArray) {
        super.init(frame: frame)
        tableViewMaxHeight = KTableViewCellH * KMaxCellNum
        selfOriginalHeight = frame.size.height
        titleArray = titleArr
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 私有方法
extension FC_DownMenu {
    
    /// 设置UI
    fileprivate func setupUI() {
        // 蒙版添加手势
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(maskBgViewTapClick))
        maskBgView.addGestureRecognizer(tap)
        // 添加视图
        addSubview(maskBgView)
        addSubview(tableView)
        // 注册cell
        tableView.register(DownMenuCell.self, forCellReuseIdentifier: "DownMenuCell")
        // 添加标题按钮
        let butW: CGFloat = kScreenW/CGFloat(titleArray.count)
        for i in 0..<titleArray.count {
            let selectBut = UIButton(type: .custom)
            selectBut.frame = CGRect(x: CGFloat(i) * butW, y: 0, width: butW, height: self.height)
            selectBut.setTitle(titleArray[i] as? String, for: .normal)
            selectBut.setTitleColor(.black, for: .normal)
            selectBut.tag = KTitleButTag + i
            selectBut.addTarget(self, action: #selector(titleButtonClick(titleButton:)), for: .touchUpInside)
            selectBut.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            selectBut.setImage(UIImage(named: "fold"), for: .normal)
            selectBut.setImage(UIImage(named: "unfold"), for: .selected)
            selectBut.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0)
            addSubview(selectBut)
            // 添加到数组
            buttonArray.add(selectBut)
        }
    }
}

// MARK: - 事件响应
extension FC_DownMenu {
    
    /// 点击蒙版,收起列表
    @objc func maskBgViewTapClick() {
        takeBackTableView()
    }
    
    /// 点击标题按钮
    @objc func titleButtonClick(titleButton: UIButton) {
    /// 第一步：旋转按钮图片
        // 获取到当前按钮下标值
        let index = titleButton.tag - KTitleButTag
        // 旋转角度
        let angle = 2 * CGFloat.pi
        for button in buttonArray as! [UIButton] {
            if button == titleButton {
                button.isSelected = !button.isSelected
                tempButton = button
                changeButtonObject(button: button, angle: angle)
            }else {
                button.isSelected = false
                changeButtonObject(button: button, angle: 0)
            }
        }
        
    /// 第二步：获取对应数据源(根据按钮选中与否)
        if  titleButton.isSelected {
            changeButtonObject(button: titleButton, angle: angle)
            // 取到对应的数组进行tableview数据源赋值
            let datas = menuDataArray[index]
            tableDataArray = datas as? NSArray
            
            // 是否可以滑动tableview
            if tableDataArray!.count > Int(KMaxCellNum) {
                isScrollEnabled = true
            }else {
                isScrollEnabled = false
            }
            // 刷新列表数据
            tableView.reloadData()
            // 根据数据源的个数来设置列表高度
            let tableViewHeight = CGFloat(tableDataArray!.count) * KTableViewCellH < tableViewMaxHeight ? CGFloat(tableDataArray!.count) * KTableViewCellH : tableViewMaxHeight
            // 弹出列表
            popTableViewHeight(tableViewH: tableViewHeight)
            // 设置列表状态为：打开
            isViewOpen = true
            
        }else {
            isViewOpen = false
            takeBackTableView()
        }
    }
}

// MARK: - 辅助方法
extension FC_DownMenu {
    
    /// 改变按钮图标的文字，旋转角度
    fileprivate func changeButtonObject(button: UIButton, angle: CGFloat) {
        UIView .animate(withDuration: 0.5) {
            button.imageView?.transform = .init(rotationAngle: angle)
        }
    }
    
    /// 弹出列表并设置高度
    fileprivate func popTableViewHeight(tableViewH: CGFloat) {
        // 显示遮罩层
        maskBgView.isHidden = false
        // 重新设置frame
        var rect = self.frame
        rect.size.height = kScreenH - self.y
        self.frame = rect
        // 展示动画持续时间
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: .curveEaseOut, animations: {
            self.tableView.frame = CGRect(x: 0, y: self.selfOriginalHeight, width: kScreenW, height: tableViewH)
            self.maskBgView.alpha = 1
        }) { (isBool) in }
    }
    
    /// 收起弹出的列表
    fileprivate func takeBackTableView() {
        for button in buttonArray as! [UIButton] {
            // 设置未选中
            button.isSelected = false
            // 按钮图标恢复初始值
            changeButtonObject(button: button, angle: 0)
        }
        // 重新设置frame
        var rect = self.frame
        rect.size.height = selfOriginalHeight
        self.frame = rect
        // 展示动画持续时间
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 5, options: .curveEaseOut, animations: {
            self.tableView.frame = CGRect(x: 0, y: self.selfOriginalHeight, width: kScreenW, height: 0)
            self.maskBgView.alpha = 0
            self.maskBgView.isHidden = true
        }) { (isBool) in }
    }
}

// MARK: - UITableViewDelegate/DataSource
extension FC_DownMenu: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownMenuCell") as! DownMenuCell
        cell.contentLb.text = tableDataArray?[indexPath.row] as? String
        let title = tempButton.titleLabel!.text
        
        if cell.contentLb.text == title {
            cell.isSelecteds = true
        }else {
            cell.isSelecteds = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableDataArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! DownMenuCell
        // 设置为选中
        cell.isSelecteds = true
        tempButton.setTitle(cell.contentLb.text, for: .normal)
        // 回调内容
        if handleSelectDataBlock != nil {
            handleSelectDataBlock!(cell.contentLb.text!, indexPath.row, tempButton.tag - KTitleButTag)
        }
        // 收起列表
        takeBackTableView()
    }
}


// MARK: - -----------------------------cell----------------------------------
class DownMenuCell: UITableViewCell {
    /// 选中图片
    fileprivate var selectImageView: UIImageView = {
        let selectImageView = UIImageView(frame: CGRect(x: 13, y: (44-15/2)/2, width: 25/2, height: 15/2))
        selectImageView.image = UIImage(named: "choice")
        return selectImageView
    }()
    
    /// 内容文字
    lazy var contentLb: UILabel = {
        let contentLb = UILabel(frame: CGRect(x: 40, y: 0, width: kScreenW - 40, height: 45))
        contentLb.font = UIFont.systemFont(ofSize: 14)
        contentLb.textColor = UIColor.black
        return contentLb
    }()
    
    /// 是否选中
    var isSelecteds: Bool = false {
        didSet{
            if isSelecteds {
                contentLb.textColor = UIColor.blue
                selectImageView.isHidden = false
            }else {
                contentLb.textColor = UIColor.black
                selectImageView.isHidden = true
            }
        }
    }
    
    fileprivate lazy var intervalView: UIView = {
        let intervalView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: 0.5))
        intervalView.backgroundColor = .gray
        return intervalView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectImageView.isHidden = true
        addSubview(selectImageView)
        addSubview(contentLb)
        addSubview(intervalView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
