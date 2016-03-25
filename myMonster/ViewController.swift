//
//  ViewController.swift
//  myMonster
//
//  Created by Ron Lipkin on 3/16/16.
//  Copyright © 2016 rolp. All rights reserved.
//

import UIKit
import AVFoundation

//to do: Fix monster images to consistent size

class ViewController: UIViewController {
    
    @IBOutlet weak var monsterImg: MonsterImg!
    @IBOutlet weak var foodImg: DragImg!
    @IBOutlet weak var heartImg: DragImg!
    @IBOutlet weak var dumbellImg: DragImg!
    @IBOutlet weak var penalty1Img: UIImageView!
    @IBOutlet weak var penalty2Img: UIImageView!
    @IBOutlet weak var penalty3Img: UIImageView!
    @IBOutlet weak var restartBtn: UIButton!
    
    let DIM_ALPHA: CGFloat = 0.2
    let OPAQUE: CGFloat = 1.0
    let MAX_PENALTIES = 3
    
    var penalties = 0
    var timer: NSTimer!
    var monsterHappy = false
    var currentItem: UInt32 = 0
    
    var musicPlayer: AVAudioPlayer!
    var sfxBite: AVAudioPlayer!
    var sfxHeart: AVAudioPlayer!
    var sfxDeath: AVAudioPlayer!
    var sfxSkull: AVAudioPlayer!
    var sfxRoar: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        foodImg.dropTarget = monsterImg
        heartImg.dropTarget = monsterImg
        dumbellImg.dropTarget = monsterImg
        foodImg.alpha = DIM_ALPHA
        foodImg.userInteractionEnabled = false
        dumbellImg.alpha = DIM_ALPHA
        dumbellImg.userInteractionEnabled = false
        
        penalty1Img.alpha = DIM_ALPHA
        penalty2Img.alpha = DIM_ALPHA
        penalty3Img.alpha = DIM_ALPHA
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewController.itemDroppedOnCharacter(_:)), name: "onTargetDropped", object: nil)
        do {
            let resourcePath = NSBundle.mainBundle().pathForResource("cave-music", ofType: "mp3")!
            let url = NSURL(fileURLWithPath: resourcePath )
            try musicPlayer = AVAudioPlayer(contentsOfURL: url)
            
            try sfxBite = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("bite", ofType: "wav")!))
            try sfxHeart = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("heart", ofType: "wav")!))
            try sfxDeath = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("death", ofType: "wav")!))
            try sfxSkull = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("skull", ofType: "wav")!))
            try sfxRoar = AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource("roar", ofType: "mp3")!))
            
            musicPlayer.prepareToPlay()
            musicPlayer.play()
            
            sfxBite.prepareToPlay()
            sfxHeart.prepareToPlay()
            sfxDeath.prepareToPlay()
            sfxSkull.prepareToPlay()
            sfxRoar.prepareToPlay()
            
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
        startTimer()
    }
    
    func itemDroppedOnCharacter(notif: AnyObject) {
        monsterHappy = true
        startTimer()
        
        dumbellImg.alpha = DIM_ALPHA
        dumbellImg.userInteractionEnabled = false
        foodImg.alpha = DIM_ALPHA
        foodImg.userInteractionEnabled = false
        heartImg.alpha = DIM_ALPHA
        heartImg.userInteractionEnabled = false
        
        if currentItem == 0 {
            sfxHeart.play()
        } else if currentItem == 1 {
            sfxBite.play()
        } else {
            sfxRoar.play()
        }
    }

    func startTimer() {
        if timer != nil {
            timer.invalidate()
        }
        
        
        timer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: #selector(ViewController.changeGameState), userInfo: nil, repeats: true)
    }
    
    func changeGameState() {
        
        var rand = arc4random_uniform(3)
        
        if !monsterHappy{
            penalties += 1
            sfxSkull.play()
            
            if penalties == 1 {
                penalty1Img.alpha = OPAQUE
                penalty2Img.alpha = DIM_ALPHA
            } else if penalties == 2 {
                penalty2Img.alpha = OPAQUE
                penalty3Img.alpha = DIM_ALPHA
            } else if penalties >= 3 {
                penalty3Img.alpha = OPAQUE
                rand = UInt32(2);
            } else {
                penalty1Img.alpha = DIM_ALPHA
                penalty2Img.alpha = DIM_ALPHA
                penalty3Img.alpha = DIM_ALPHA
            }
            
            if penalties >= MAX_PENALTIES {
                gameOver()
            }
        }
        
        
        if rand == 0 {
            foodImg.alpha = DIM_ALPHA
            foodImg.userInteractionEnabled = false
            dumbellImg.alpha = DIM_ALPHA
            dumbellImg.userInteractionEnabled = false
            heartImg.alpha = OPAQUE
            heartImg.userInteractionEnabled = true
        } else if rand == 1 {
            heartImg.alpha = DIM_ALPHA
            heartImg.userInteractionEnabled = false
            dumbellImg.alpha = DIM_ALPHA
            dumbellImg.userInteractionEnabled = false
            foodImg.alpha = OPAQUE
            foodImg.userInteractionEnabled = true
        } else if rand == 2 {
            heartImg.alpha = DIM_ALPHA
            foodImg.alpha  = DIM_ALPHA
            heartImg.userInteractionEnabled = false
            foodImg.userInteractionEnabled = false
            dumbellImg.alpha = OPAQUE
            dumbellImg.userInteractionEnabled = true
        }
        
        currentItem = rand
        monsterHappy = false

    }
    
    func gameOver() {
        timer.invalidate()
        monsterImg.playDeathAnimation()
        sfxDeath.play()
        restartBtn.hidden = false
    }
    
    func restartGame() {
        penalty1Img.alpha = DIM_ALPHA
        penalty2Img.alpha = DIM_ALPHA
        penalty3Img.alpha = DIM_ALPHA
        heartImg.alpha = OPAQUE
        heartImg.userInteractionEnabled = true
        startTimer()
        penalties = 0
        currentItem = 0
        restartBtn.hidden = true
        monsterImg.playRestartAnimation()
        NSTimer.scheduledTimerWithTimeInterval(0.9, target: monsterImg, selector: Selector("playIdleAnimation"), userInfo: nil, repeats: false)
        
    }

    @IBAction func onRestartTapped(sender: AnyObject) {
        restartGame()
    }
    
}

