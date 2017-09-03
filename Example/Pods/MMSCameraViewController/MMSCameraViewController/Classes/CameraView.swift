//
//  CameraView.swift
//  Pods
//
//  Created by William Miller on 9/3/16.
//
//

import UIKit
import AVFoundation

class CameraView: UIView {
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var snapBtn: UIButton!
    @IBOutlet weak var flashBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var unavailableLbl: UILabel!
    @IBOutlet weak var resumeSessionBtn: UIButton!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
                
    }
    
    func disableSnapButton() {
        guard snapBtn != nil else {
            return
        }
        snapBtn.isEnabled = false
    }
    
    func enableSnapButton() {
        guard snapBtn != nil else {
            return
        }
        snapBtn.isEnabled = true
    }
    
    func isSnapButtonEnabled() -> Bool {
        guard snapBtn != nil else {
            return false
        }
        return snapBtn.isEnabled
    }
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
    
}
