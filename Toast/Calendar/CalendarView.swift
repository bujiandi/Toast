//
//  CalendarView.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/10/23.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

let oneDaySecond:Double = 24 * 3600

open class CalendarView: UIControl {
    
    open var selectTime:TimeInterval = Date().timeIntervalSince1970
    
    private func changeYearOffset(_ v:Int) {
        let calendar = Calendar.current

        let (year, month) = self.current
        var dateComp = DateComponents.init(calendar: calendar, timeZone: calendar.timeZone, year: year + v, month: month + 1)
        
        current = (year + v, month)
        // 拿到当前月的最后一天 (下月1号 - 24小时)
        let time = calendar.date(from: dateComp)!.timeIntervalSince1970 - oneDaySecond
        dateComp = calendar.dateComponents([.weekday], from: Date(timeIntervalSince1970: time))
        
        // 根据星期补日历最后一行日期
        beginTime = time + Double(7 - dateComp.weekday! + 1 - 6 * 7) * oneDaySecond

        datesContainer.reloadData()
    }
    @objc private func onTap(_ tap:UITapGestureRecognizer) {
        var point = tap.location(in: datesContainer.scrollView)
        for (_, cell) in datesContainer.visiableCells {
            if !cell.frame.contains(point) { continue }
            point.y -= cell.frame.minY
            for view in cell.subviews {
                if !view.frame.contains(point) { continue }
                let dateCell = view as! DateCell
                dateCell.isSelected = true
                selectTime = dateCell.time
                selectCell?.isSelected = false
                selectCell = dateCell
                sendActions(for: .valueChanged)
            }
            break
        }
    }
    
    @objc private func onPrev() {
        changeYearOffset(-1)
    }
    
    @objc private func onNext() {
        changeYearOffset(1)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if newSuperview == nil { return }
        createUI()
    }
    
    private var current:(year:Int, month:Int) = (0, 0) {
        didSet {
            if let yearBar = _yearBar {
                let (year, month) = current
                DispatchQueue.main.async {
                    
                    UIView.animate(withDuration: 1) {
                        UIView.setAnimationCurve(.easeInOut)
                        let english = ["January","February","March","April","May","June","July","August","September","October","November","December"]
                        let chinese = ["一月","二月","三月","四月","五月","六月","七月","八月","九月","十月","十一月","十二月"]

                        yearBar.yearLabel.text = "\(year)"
                        yearBar.monthLabel1.text = chinese[month - 1]
                        yearBar.monthLabel2.text = english[month - 1]

                        yearBar.layoutIfNeeded()
                    }
                }
            }
        }
    }
    private func createUI() {
        if _weekBar != nil { return }
        
        let year = YearBar()
        let week = WeekBar()
        let date = DatesContainer(frame: bounds)
        
        _yearBar = year
        _weekBar = week
        _datesContainer = date
        
        let calendar = Calendar.current
        let selectDate = Date(timeIntervalSince1970: selectTime)
        var dateComp = calendar.dateComponents([.year, .month], from: selectDate)
        
        // 得到当前年月
        current = (dateComp.year!, dateComp.month!)

        dateComp.month = dateComp.month! + 1
        // 拿到当前月的最后一天 (下月1号 - 24小时)
        let time = calendar.date(from: dateComp)!.timeIntervalSince1970 - oneDaySecond
        dateComp = calendar.dateComponents([.weekday], from: Date(timeIntervalSince1970: time))
        
        // 根据星期补日历最后一行日期
        beginTime = time + Double(7 - dateComp.weekday! + 1 - 6 * 7) * oneDaySecond

        
        addSubviews([year, week, date]) {
            $0 += year.anchor.top      == self.anchor.top
            $0 += year.anchor.width    == week.anchor.width
            $0 += year.anchor.centerX  == week.anchor.centerX
            $0 += week.anchor.leading  == self.anchor.leading
            $0 += week.anchor.trailing == self.anchor.trailing
            $0 += week.anchor.top      == year.anchor.bottom
            $0 += year.anchor.height   == week.anchor.height
            $0 += date.anchor.top      == week.anchor.bottom
            $0 += date.anchor.centerX  == week.anchor.centerX
            $0 += date.anchor.width    == week.anchor.width
            $0 += date.anchor.height   == week.anchor.height * 6
            $0 += date.anchor.bottom   == self.anchor.bottom
        }
        
        year.prevButton.addTarget(self, action: #selector(onPrev), for: .touchUpInside)
        year.nextButton.addTarget(self, action: #selector(onNext), for: .touchUpInside)
        
        let size = week.systemLayoutSizeFitting(UIScreen.main.bounds.size, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .fittingSizeLevel)
        
        date.cellHeight = size.height
        date.offsetY = -size.height
        date.delegate = self
        date.reloadData()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(onTap(_:)))
        date.addGestureRecognizer(tap)
        _tap = tap
    }
    
    private weak var _tap:UITapGestureRecognizer?
    open var tap:UITapGestureRecognizer {
        createUI()
        return _tap!
    }
    
    private weak var _yearBar:YearBar?
    open var yearBar:YearBar {
        createUI()
        return _yearBar!
    }
    
    private weak var _weekBar:WeekBar?
    open var weekBar:WeekBar {
        createUI()
        return _weekBar!
    }

    private weak var _datesContainer:DatesContainer?
    open var datesContainer:DatesContainer {
        createUI()
        return _datesContainer!
    }
    
    open lazy var beginTime:TimeInterval = Date().timeIntervalSince1970

    private lazy var queue = DispatchQueue(label: "Toast.CalendarView")
    
    private weak var selectCell:DateCell?
}
extension CalendarView: LoopViewDelegate {
    
    public func loopViewCreateCell(_ loopView: LoopView) -> UIView {
        return WeekCell()
    }
    
    public func loopViewUpdate(_ loopView: LoopView, cell: UIView, forRow row: Int) {
        let cell = cell as! WeekCell
        let beginTime = self.beginTime

        cell.time = beginTime + Double(row) * 7 * oneDaySecond
        let today = Date().timeIntervalSince1970
        for dateCell in cell.cells {
            dateCell.isSelected = selectTime >= dateCell.time && selectTime - dateCell.time < oneDaySecond
            dateCell.isToday = today >= dateCell.time && today - dateCell.time < oneDaySecond
            if dateCell.isSelected { selectCell = dateCell }
        }
        
        // 拿到中间周的中间天的日期
        let scrollView = datesContainer.scrollView
        let cells = datesContainer.visiableCells
        
        let calendar = Calendar.current

        for (index, cell) in cells {
            var frame = cell.frame
            frame.origin.y -= scrollView.contentOffset.y
            // 找到屏幕中间那一行
            if !frame.contains(scrollView.center) { continue }
            
            let time = beginTime + Double(index * 7 + 3) * oneDaySecond
            let date = Date(timeIntervalSince1970: time)
            var comp = calendar.dateComponents([.year, .month], from: date)
            
            // 更新当前年月
            self.current = (comp.year!, comp.month!)
            break
        }
        
        var dateComp = DateComponents(calendar: calendar, timeZone: calendar.timeZone, year: current.year, month: current.month)
        
        let begin = calendar.date(from: dateComp)!.timeIntervalSince1970
        dateComp.month = dateComp.month! + 1
        let over = calendar.date(from: dateComp)!.timeIntervalSince1970
        
        for (_, view) in cells {
            for (i, v) in view.subviews.enumerated() {
                let cell = v as! DateCell
                // 每一Cell(天)的起始日期
                let highlight = cell.time >= begin && cell.time < over
                cell.set(highlight: highlight, by: i)
            }
        }

    }
/*
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let calendar = Calendar.current

        // 拿到滚动终点将偏移的行数
        let lineHeight = datesContainer.cellHeight + datesContainer.cellInterval
        let offset = targetContentOffset.pointee
        if let (index, _) = datesContainer.visiableCells.first {
            
            let time = beginTime + Double(index * 7) * oneDaySecond
            let date = Date(timeIntervalSince1970: time + 4 * oneDaySecond)
            var dateComp = calendar.dateComponents([.year, .month], from: date)
            
            // 更新当前年月
            self.current = (dateComp.year!, dateComp.month!)
            dateComp.month = dateComp.month! + 1
            
            let lastDay = calendar.date(from: dateComp)!.timeIntervalSince1970 - oneDaySecond
            dateComp = calendar.dateComponents([.weekday], from: Date(timeIntervalSince1970: lastDay))
            
            // 根据星期补日历最后一行日期
            let firstTime = lastDay + Double(7 - dateComp.weekday! + 1 - 6 * 7) * oneDaySecond

            print(Date(timeIntervalSince1970: firstTime + 8 * 3600))
            let changeLine = CGFloat((firstTime - time) / (oneDaySecond * 7))
            let changeY = changeLine * lineHeight //- frame.minY
            
            scrollView.setContentOffset(CGPoint(x: offset.x, y: changeY), animated: true)
        }
    }
*/
}
