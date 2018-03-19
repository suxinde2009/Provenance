//  Converted to Swift 4 by Swiftify v4.1.6640 - https://objectivec2swift.com/
//
//  JSButton.swift
//  Controller
//
//  Created by James Addyman on 29/03/2013.
//  Copyright (c) 2013 James Addyman. All rights reserved.
//

import UIKit

protocol JSButtonDelegate : class {
    func buttonPressed(_ button: JSButton)
    func buttonReleased(_ button: JSButton)
}

class JSButton: UIView {
    private(set) var titleLabel: UILabel!

    var backgroundImage: UIImage? {
        didSet {
            backgroundImage = backgroundImage?.withRenderingMode(.alwaysTemplate)
        }
    }

    var backgroundImagePressed: UIImage? {
        didSet {
            backgroundImagePressed = backgroundImagePressed?.withRenderingMode(.alwaysTemplate)
        }
    }
    
    var titleEdgeInsets: UIEdgeInsets {
        didSet {
            setNeedsLayout()
        }
    }
    
    override var tintColor: UIColor? {
        didSet {
            if PVSettingsModel.shared.buttonTints {
                backgroundImageView?.tintColor = tintColor
            } else {
                backgroundImageView?.tintColor = UIColor.white
            }
        }
    }

    var pressed = false
    weak var delegate: JSButtonDelegate?

    private var backgroundImageView: UIImageView!

    func setEnabled(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
    }

    override init(frame: CGRect) {
        titleEdgeInsets = .zero
        super.init(frame: frame)

        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        titleEdgeInsets = .zero
        super.init(coder: aDecoder)

        commonInit()
    }

    func commonInit() {
        backgroundImageView = UIImageView(image: backgroundImage)
        backgroundImageView.frame = bounds
        backgroundImageView.contentMode = .center
        backgroundImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImageView.layer.shadowColor = UIColor.black.cgColor
        backgroundImageView.layer.shadowRadius = 4.0
        backgroundImageView.layer.shadowOpacity = 0.75
        backgroundImageView.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        addSubview(backgroundImageView)

        titleLabel = UILabel()
        titleLabel.backgroundColor = UIColor.clear
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        titleLabel.shadowColor = UIColor.black
        titleLabel.shadowOffset = CGSize(width: 0, height: 1)
        titleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        titleLabel.frame = bounds
        titleLabel.textAlignment = .center
        titleLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(titleLabel)

        addObserver(self as NSObject, forKeyPath: "pressed", options: .new, context: nil)
        addObserver(self as NSObject, forKeyPath: "backgroundImage", options: .new, context: nil)
        addObserver(self as NSObject, forKeyPath: "backgroundImagePressed", options: .new, context: nil)
        pressed = false
        tintColor = nil
    }

    deinit {
        removeObserver(self as NSObject, forKeyPath: "pressed")
        removeObserver(self as NSObject, forKeyPath: "backgroundImage")
        removeObserver(self as NSObject, forKeyPath: "backgroundImagePressed")
        delegate = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundImageView?.frame = bounds
        
        if let titleLabel = titleLabel {
            titleLabel.frame = bounds
            var frame = titleLabel.frame
            frame.origin.x += titleEdgeInsets.left
            frame.origin.y += titleEdgeInsets.top
            frame.size.width -= titleEdgeInsets.right
            frame.size.height -= titleEdgeInsets.bottom
            titleLabel.frame = frame
        }
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "pressed") || (keyPath == "backgroundImage") || (keyPath == "backgroundImagePressed") {
            if pressed {
                backgroundImageView?.image = backgroundImagePressed
            }
            else {
                backgroundImageView?.image = backgroundImage
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.buttonPressed(self)
        pressed = true
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }

        let point = touch.location(in: superview)
        let touchArea = CGRect(x: point.x - 10, y: point.y - 10, width: 20, height: 20)

        var pressed: Bool = self.pressed
        if !pressed {
            pressed = true
            delegate?.buttonPressed(self)
        }
        
        if !touchArea.intersects(frame) {
            if pressed {
                pressed = false
                delegate?.buttonReleased(self)
            }
        }

        self.pressed = pressed
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.buttonReleased(self)
        pressed = false
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.buttonReleased(self)
        pressed = false
    }
}