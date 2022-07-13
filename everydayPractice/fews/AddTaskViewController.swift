//
//  AddTaskViewController.swift
//  fews
//
//  Created by  오정아 on 2022/07/07.
//

protocol AddTaskViewDelegate: AnyObject { //AddTaskViewDelegate 생성
    func sendData(str: GoalStruct)
}

import UIKit

class AddTaskViewController: UIViewController {

    @IBOutlet weak var addTitleTextField: UITextField!
    var settingTime: Int = 0
    
    weak var delegate: AddTaskViewDelegate? //AddTaskViewDelegate 객체 생성
    
    override func viewDidLoad() { //START
        super.viewDidLoad()
    }
    @IBAction func tapTimerButton(_ sender: UIButton) {
        if sender.tag == 1 {
            settingTime = 5*60
        }
        else if sender.tag == 2 {
            settingTime = 10*60
        }
        else {
            settingTime = 15*60
        }
    }
    @IBAction func tapcancelButton(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil) //이전 뷰로 돌아가기
    }
    @IBAction func tapDotTimerButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "분을 입력하세요", message: "", preferredStyle: .alert)
        //UIAlertController 생성, title : Alert 제목, message : 제목 밑에 나오는 텍스트,preferredStyle : .alert 알림창으로 뿅 등장
        let registerButton = UIAlertAction(title: "등록", style: .default, handler: { [weak self] _ in //💛💛weak self???
            //Alert에서 할 등록 액션 버튼 생성
            guard let setTime = alert.textFields?[0].text else { return } //텍스트필드 값이 유효하면 title에 저장 (옵셔널 바인딩=안정성)
            self?.settingTime = Int(setTime)! * 60
        })
        let cancleButton = UIAlertAction(title: "취소", style: .cancel, handler: nil) //Alert의 취소 버튼
        alert.addAction(cancleButton) //alert에 액션 추가
        alert.addAction(registerButton)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "분을 입력해주세요."
        }) //configurationHandler : alert를 display하기 전에 Textfield를 구성하기 위한 코드, textField의 placeholder를 쓰겠단 의미
        self.present(alert, animated: true, completion: nil) //present가 정상적으로 실행된 후 completion : nil = 아무것도 안하겠다
        
    }
    @IBAction func tapAddButton(_ sender: UIButton) {
        guard let strTask = addTitleTextField.text else { return }
        
        let goal = GoalStruct(title: strTask, timer: settingTime, achievetimer: settingTime, timerOnOff: false)
        
        self.delegate?.sendData(str: goal) //델리게이트 메서드, 아규먼트 전달
        self.presentingViewController?.dismiss(animated: true, completion: nil) //이전 뷰로 돌아가기
    }
}
