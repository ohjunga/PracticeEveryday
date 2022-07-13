//
//  SettingViewController.swift
//  fews
//
//  Created by  오정아 on 2022/07/07.
//

import UIKit

protocol SettingViewDelegate: AnyObject {
    func tapSwitch(str: String)
}

class SettingViewController: UIViewController {
    
    @IBOutlet weak var btnHowToUse: UIButton!
    @IBOutlet weak var mySwicth: UISwitch!
    
    weak var delegate: SettingViewDelegate?
    var switchStr: String?
    var switchBool: Bool = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setSwitchStatus(swt: switchBool)
        btnHowToUse.titleLabel?.font = UIFont.systemFont(ofSize: 19)
    }
    
    @IBAction func tapCancelButton(_ sender: UIButton) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    @IBAction func tapSettingSwitch(_ sender: UISwitch) {
        if sender.isOn {
            switchStr = "On"
            switchBool = true
        } else {
            switchStr = "Off"
            switchBool = false
        }
        self.delegate?.tapSwitch(str: switchStr!)
    }
    private func setSwitchStatus(swt : Bool) {
        self.mySwicth.setOn(swt, animated: true)
        print("switch status: \(mySwicth.isOn)")
    }
    @IBAction func tapHowToUse(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "HowTo1ViewController") as? HowTo1ViewController else { return }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil) //vc뷰로 전환
    }
}
