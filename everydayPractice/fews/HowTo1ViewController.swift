//
//  HowTo1ViewController.swift
//  fews
//
//  Created by  오정아 on 2022/07/12.
//

import UIKit

class HowTo1ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "HowTo2ViewController") as? HowTo2ViewController else { return }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: false, completion: nil) //vc뷰로 전환
    }
}
