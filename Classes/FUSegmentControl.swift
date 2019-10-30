import UIKit

@objc class FUSegmentControl: UIControl {
    
    @objc enum segmentStyle: Int {
        case rectangle
        case rounded
    }
    
    @objc enum SelectionStyle: Int {
        case full
        case fullWithCorner
        case underLine
    }
    
    var buttons = [UIButton]()
    private var scrollView = UIScrollView()
    
    var selector = UIView()
    var toIndex: Int?
    @objc var selectorSegmentIndex: Int = 0 {
        didSet {
            lastSegmentIndex = oldValue
            if isAniamte {
                didSelected()
            }
        }
    }
    
    @objc var lastSegmentIndex: Int = 0
    
    @objc var disableIndex: [Int] = []
    
    @IBInspectable
    var buttonPadding: CGFloat = 0
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.clear
    
    @IBInspectable
    var commaSeparatedButtonTitles: String = ""
    
    @IBInspectable
    var textColor: UIColor = UIColor.gray
    
    @IBInspectable
    var selectorColor: UIColor = UIColor.black
    
    @IBInspectable
    var selectorFont: String = "PingFangSC-Semibold"
    
    @IBInspectable
    var selectorTextColor: UIColor = UIColor.white
    
    @IBInspectable
    var fontSize: CGFloat = 17
    
    @IBInspectable
    var selectedFontSize: CGFloat = 0
    
    @IBInspectable
    var font: String = "PingFangSC-Regular"
    
    var isAniamte: Bool = true
    
    @IBInspectable
    var isFill: Bool = true
    
    @IBInspectable
    var leftPadding: CGFloat = 16
    
    @IBInspectable
    var rightPadding: CGFloat = 16
    
    @IBInspectable
    var buttonLeftPadding: CGFloat = 0
    
    @IBInspectable
    var buttonRightPadding: CGFloat = 0
    
    @IBInspectable
    var selectionStyle: SelectionStyle = .underLine
    
    @IBInspectable
    var selectionHeight: CGFloat = 1
    
    @IBInspectable
    var selectionViewInset: CGFloat = 0
    
    @IBInspectable
    var style: segmentStyle = .rectangle
    
    @objc var indexImages: Dictionary<Int, UIImage> = [:]
    
    private var isDraw: Bool = false
    
    private func updateView() {
        
        switch style {
        case .rectangle: break
        case .rounded:
            layer.cornerRadius = frame.height / 2
            layer.masksToBounds = true
        }
        
        buttons.removeAll()
        scrollView = UIScrollView()
        subviews.forEach{ $0.removeFromSuperview() }
        
        let buttonTitles = commaSeparatedButtonTitles.components(separatedBy: ",")
        var scrollViewWidth: CGFloat = 0
        var buttonPositionX: CGFloat = 0 + leftPadding
        
        for buttonTitle in buttonTitles {
            
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.titleLabel?.font = UIFont(name: font, size: fontSize)
            button.setTitleColor(textColor, for: .normal)
            button.setTitleColor(textColor.withAlphaComponent(0.16), for: .disabled)
            button.titleLabel?.sizeToFit()
            button.titleLabel?.textAlignment = .center
            button.titleLabel?.numberOfLines = 0
            button.backgroundColor = .clear
            button.contentHorizontalAlignment = .center
            button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
            button.contentEdgeInsets = UIEdgeInsets(top: 0, left: buttonLeftPadding, bottom: 0, right: buttonLeftPadding)
            button.sizeToFit()
            
            button.frame.origin.x = buttonPositionX
            
            if isFill {
                button.frame.size.width = (frame.width - leftPadding - rightPadding - CGFloat(buttonTitles.count - 1) * buttonPadding) / CGFloat(buttonTitles.count)
            } else {
                scrollViewWidth += button.frame.width
            }
            
            button.frame.size.height = self.frame.height
            button.frame.origin.y = 0
            buttonPositionX += button.frame.width + buttonPadding
            
            scrollView.addSubview(button)
            buttons.append(button)
        }
        
        if selectorSegmentIndex >= buttons.count {
            selectorSegmentIndex = 0
        }
        
        if isFill {
            scrollView.contentSize.width = scrollView.frame.width
        } else {
            scrollView.contentSize.width = scrollViewWidth + leftPadding + rightPadding
        }
        
        addSubview(scrollView)
        
        buttons[0].setTitleColor(selectorTextColor, for: .normal)
        
        var selectorWidth: CGFloat = 0
        var selectorStartPosition: CGFloat = 0
        
        selectorWidth = buttons[selectorSegmentIndex].frame.width
        selectorStartPosition = buttons[selectorSegmentIndex].frame.origin.x
        
        switch selectionStyle {
        case .full:
            selector = UIView(frame: CGRect(x: selectorStartPosition,
                                            y: selectionViewInset,
                                            width: selectorWidth,
                                            height: frame.height - selectionViewInset * 2))
        case .fullWithCorner:
            selector = UIView(frame: CGRect(x: selectorStartPosition,
                                            y: selectionViewInset,
                                            width: selectorWidth,
                                            height: frame.height - selectionViewInset * 2))
            selector.layer.cornerRadius = (frame.height - selectionViewInset * 2) / 2
        case .underLine:
            selector = UIView(frame: CGRect(x: selectorStartPosition,
                                            y: self.frame.height - selectionHeight,
                                            width: selectorWidth,
                                            height: selectionHeight))
            selector.layer.cornerRadius = 1
        }
        
        for (_, image) in indexImages.enumerated() {
            if buttons.count > image.key {
                let imageFrame = CGRect(x: buttons[image.key].frame.maxX - 18, y: 2, width: 16, height: 16)
                let imageView = UIImageView(frame: imageFrame)
                imageView.image = image.value
                scrollView.addSubview(imageView)
            }
        }
        
        selector.clipsToBounds = true
        selector.backgroundColor = selectorColor
        
        scrollView.insertSubview(selector, at: 0)
    }
    
    @objc func setImageForIndex(_ index: Int, image: UIImage) {
        indexImages[index] = image
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        if !isDraw {
            isDraw = true
            loadItems()
        }
    }
    
    @objc func loadItems() {
        updateView()
        
        scrollView.frame = bounds
        scrollView.contentSize.height = 1
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        
        didSelected()
        
        if let toIndex = toIndex {
            UIView.animate(withDuration: 0.2, animations: {
                self.buttons[self.selectorSegmentIndex].setTitleColor(self.textColor, for: .normal)
                
                var selectorWidth: CGFloat = 0
                var selectorStartPosition: CGFloat = 0
                
                selectorWidth = self.buttons[toIndex].frame.width
                selectorStartPosition = self.buttons[toIndex].frame.origin.x
                
                self.selector.frame.size.width = selectorWidth
                self.selector.frame.origin.x = selectorStartPosition
                self.buttons[toIndex].setTitleColor(self.selectorTextColor, for: .normal)
            }) { _ in
                self.selectorSegmentIndex = toIndex
                self.toIndex = nil
            }
            self.buttons[toIndex].isUserInteractionEnabled = false
        }
    }
    
    @objc func buttonTapped(sender: UIButton) {
        
        for (buttonIndex, btn) in buttons.enumerated() {
            if btn == sender {
                selectorSegmentIndex = buttonIndex
            }
        }
        
        sendActions(for: .valueChanged)
    }
    
    func didSelected() {
        
        for (buttonIndex, btn) in buttons.enumerated() {
            
            btn.isUserInteractionEnabled = false
            btn.setTitleColor(textColor, for: .normal)
            btn.titleLabel?.font = UIFont(name: font, size: fontSize)
            
            if disableIndex.contains(buttonIndex) {
                btn.isEnabled = false
            }
            
            if buttonIndex == selectorSegmentIndex {
                
                var selectorWidth: CGFloat = 0
                var selectorStartPosition: CGFloat = 0
                
                selectorWidth = btn.frame.width
                selectorStartPosition = btn.frame.origin.x
                
                UIView.animate(withDuration: 0.2, animations: {
                    self.selector.frame.size.width = selectorWidth
                    self.selector.frame.origin.x = selectorStartPosition
                }, completion: { _ in
                    for button in self.buttons {
                        button.isUserInteractionEnabled = true
                    }
                })
                btn.setTitleColor(selectorTextColor, for: .normal)
                btn.titleLabel?.font = UIFont(name: selectorFont, size: selectedFontSize == 0 ? fontSize:selectedFontSize)
                
                if btn.frame.minX < scrollView.contentOffset.x {
                    scrollView.setContentOffset(CGPoint(x: btn.frame.minX, y: scrollView.contentOffset.y), animated: true)
                } else if btn.frame.maxX > scrollView.contentOffset.x + scrollView.frame.width {
                    scrollView.setContentOffset(CGPoint(x: btn.frame.maxX - scrollView.frame.width, y: scrollView.contentOffset.y), animated: true)
                }
            }
        }
    }
}

extension FUSegmentControl: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        scrollView.contentOffset.y = 0
    }
}
