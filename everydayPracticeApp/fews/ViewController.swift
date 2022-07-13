//
//  ViewController.swift
//  fews
//
//  Created by  오정아 on 2022/07/07.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AddTaskViewDelegate, SettingViewDelegate {
    
    var goalArray = [GoalStruct]() {
        didSet {
            saveData()
            calToTalGoalTime()
        }
    }
    func tapSwitch(str: String) {
        if str == "On" {
            soundStatus = true
        }else {
            soundStatus = false
        }
        
    }
    
    func sendData(str: GoalStruct) {
        let stc = GoalStruct(title: str.title, timer: str.timer, achievetimer: str.achievetimer, timerOnOff: str.timerOnOff)
        self.goalArray.append(stc)
        self.tableView.reloadData()
    }

    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var timeLabel: UILabel!
    
    var timer: DispatchSourceTimer?
    var timerStatus: Bool = false
    var timerIndex: Int?
    var achieveLevel: Double?
    var achieveSum: Int = 0
    var totalSum: Int = 0
    var soundStatus: Bool = true
    var showTime: String?
    var cell:CustomTableViewCell?
    let userNotiCenter = UNUserNotificationCenter.current()
    
    override func viewDidLoad() { //START
        super.viewDidLoad()
        initSet()
        getTodayDate()
        loadData()
        self.tableView.delegate = self //tableView 델리게이트, 데이터 소스 채택
        self.tableView.dataSource = self
        self.tableView.dragInteractionEnabled = true
        self.tableView.dragDelegate = self
        self.tableView.dropDelegate = self
        timerSet()
    }
    private func calToTalGoalTime() {
        totalSum = 0
        if goalArray.count == 0 {
            //
        } else {
            for index in 0...goalArray.count-1 {
                totalSum += goalArray[index].achievetimer //총 목표시간 더하기
            }
        }
    }
    private func calAchievement() {
        achieveSum = 0
        for index in 0...goalArray.count-1 {
            achieveSum += goalArray[index].achievetimer - goalArray[index].timer
        }
        achieveLevel = Double(achieveSum) / Double(totalSum)
        let str = String(format: "%.0f", achieveLevel!*100)
        
        goalLabel.text = "오늘의 성취도 : \(str) %"
    }
    private func checkTime() {
        goalArray[timerIndex!].timer -= 1
        let showmin = goalArray[timerIndex!].timer / 60
        let showsec = goalArray[timerIndex!].timer % 60
        cell!.timeLabel.text = "\(showmin):\(showsec)"
        if goalArray[timerIndex!].timer == 0 {
            timer?.suspend()
            timerStatus = false
            cell!.timeLabel.text = ""
            let attributedString = NSMutableAttributedString(string: cell!.titleLabel.text!)
            attributedString.addAttribute(.foregroundColor, value: UIColor.black, range: NSRange(location: 0, length: goalArray[timerIndex!].title.count))
            cell!.titleLabel.attributedText = attributedString
        }
    }
    private func saveData() {
        let data = self.goalArray.map {
            [
                "title" : $0.title,
                "timer" : $0.timer,
                "achievetimer": $0.achievetimer,
                "timerOnOff" : $0.timerOnOff
            ]
        }
        let userDefaults = UserDefaults.standard
        userDefaults.setValue(data, forKey: "goalList")
    }
    private func loadData() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "goalList") as? [[String : Any]] else {
            return }
        self.goalArray = data.compactMap {
            guard let title = $0["title"] as? String else { return nil }
            guard let timer = $0["timer"] as? Int else { return nil }
            guard let achievetimer = $0["achievetimer"] as? Int else { return nil }
            guard let timerOnOff = $0["timerOnOff"] as? Bool else { return nil }
            
            return GoalStruct(title: title, timer: timer, achievetimer: achievetimer, timerOnOff: timerOnOff)
        }
    }
    private func getTodayDate() { //오늘 날짜 불러와 셋팅
        let calendar = Calendar.current
        let now = Date()
        guard let date = calendar.date(bySettingHour: 24, minute: 0, second: 0, of: now) else {return}
        let initialTime = Timer(fireAt: date, interval: 0, target: self, selector: #selector(initSet), userInfo: nil, repeats: false)
        RunLoop.main.add(initialTime, forMode: RunLoop.Mode.common)
    }
    @objc func initSet() {
        let formatter = DateFormatter()
        formatter.dateStyle = .long //2022년 7월 7일
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "MM월 dd일 EEEEE"
        let str = formatter.string(from: Date())
        todayLabel.text = str + "요일"
        
        for i in 0..<goalArray.count {
            goalArray[i].timer = goalArray[i].achievetimer
            
        }
    }
    @IBAction func tapSettingView(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingViewController") as? SettingViewController else { return }
        vc.delegate = self //vc의 대리자가 나임을 알려줌
        vc.switchBool = soundStatus
        self.present(vc, animated: true, completion: nil) //vc뷰로 전환
    }
    @IBAction func tapAddTask(_ sender: UIButton) { //습관 추가 버튼 액션 함수
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddTaskViewController") as? AddTaskViewController else { return }
        vc.modalPresentationStyle = .fullScreen
        vc.delegate = self //vc의 대리자가 나임을 알려줌
        self.present(vc, animated: true, completion: nil) //vc뷰로 전환
    }
    override func viewDidLayoutSubviews(){ //tableview 높이 리사이징
        var maxHeight = tableView.contentSize.height*2
        if maxHeight > 45*10 {
            maxHeight = 45*10 //셀 10개 길이로 뷰높이 제한
        }
        tableView.frame = CGRect(x: tableView.frame.origin.x, y: tableView.frame.origin.y, width: tableView.frame.size.width, height: maxHeight)
    }
    private func timerSet() { //초 타이머
        if timer == nil {
            //Timer 생성자의 queue에는 원하는 작업이 UI와 관련되어 있다면 Main을 할당
            timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
            //바로 실행되어야 한다면 deadline에 .now()만 할당하면 되고, 3초 후에 실행되어야 한다면 .now() + 3 을 할당
            timer?.schedule(deadline: .now(), repeating: 1) //1초마다 반복
            //Timer와 함께 연동될 EventHandler를 할당
            timer?.setEventHandler(handler: {
                self.checkTime()
            })
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.goalArray.count //테이블뷰에 반환할 행의 갯수
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //셀 추가시 호출
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath) as! CustomTableViewCell
        let stc = self.goalArray[indexPath.row]
        cell.titleLabel.text = stc.title
        cell.backgroundColor = .darkGray
        cell.titleLabel.font = UIFont.systemFont(ofSize: 24, weight: .heavy)
        cell.selectionStyle = .none
        return cell //셀이 테이블 뷰의 특정 위치(indexpath)에 삽입할 데이터 소스를 요청
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.goalArray.remove(at: indexPath.row) //배열에서 데이터 삭제
        tableView.deleteRows(at: [indexPath], with: .automatic) //뷰에서 행 삭제
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let moveCell = self.goalArray[sourceIndexPath.row]
        self.goalArray.remove(at: sourceIndexPath.row)
        self.goalArray.insert(moveCell, at: destinationIndexPath.row)
    }
}
extension ViewController: UITableViewDelegate { //cell 선택(터치)시 작동 메서드
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
        UIDevice.vibrate()
        timerIndex = indexPath.row
        if timerStatus == false {
            timerStatus = true
            timer?.resume()
            if soundStatus == true {
                UIDevice.sound()
            }
        } else if timerStatus == true {
            timerStatus = false
            timer?.suspend()
            cell!.timeLabel.text = "" //라벨 unvisible
            calAchievement()
        }
    }
}
extension ViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        return [UIDragItem(itemProvider: NSItemProvider())]
    }
}
extension ViewController: UITableViewDropDelegate {
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
    }
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        if session.localDragSession != nil {
            return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
            return UITableViewDropProposal(operation: .cancel, intent: .unspecified)
    }
}
extension UIDevice {
    static func vibrate() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
    }
    static func sound() {
        AudioServicesPlaySystemSound(1104)
    }
}
