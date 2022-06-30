//
//  ViewController.swift
//  QuotesGenerator
//
//  Created by  이재훈 on 2022/06/30.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var quoteLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    // 구조체 배열
    let quotes = [
        Quote(contents: "게으름은 피곤하기 전에 쉬는 습관일 뿐.", name: "쥘 르나르"),
        Quote(contents: "작은 계획을 세우지 말라; 작은 계획에는 사람의 피를 끓게할 마법의 힘이 없다... 큰 계획을 세우고, 소망을 원대히 하여 일하라.", name: "다니엘 H.번햄"),
        Quote(contents: "당신의 노력을 존중하라. 당신 자신을 존중하라. 자존감은 자제력을 낳는다. 이 둘을 모두 겸비하면, 진정한 힘을 갖게 된다.", name: "클린트 이스트우드"),
        Quote(contents: "약간의 운동만 필요한 게 아니라면, 금이 있는 곳을 파라.", name: "존 M.카포지"),
        Quote(contents: "열정없이 사느니 차라리 죽는게 낫다.", name: "커트 코베인"),
        Quote(contents: "당신이 어떤 위험을 감수하냐를 보면, 당신이 무엇을 가치있게 여기는지 알 수 있다.", name: "자넷 윈터슨"),
        Quote(contents: "인생이 끝날까 두려워하지마라. 당신의 인생이 시작조차 하지 않을 수 있음을 두려워하라.", name: "그레이스 한센")
    ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func tapQuoteGeneratorButton(_ sender: Any) {
        let random = Int(arc4random_uniform(7)) //0~6사이의 난수를 랜덤하게 저장
        let quote = quotes[random]
        self.quoteLabel.text = quote.contents
        self.nameLabel.text = quote.name
    }
}

