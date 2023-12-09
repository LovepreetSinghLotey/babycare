//
//  OptionChooserView.swift
//  Babycare
//
//  Created by User on 14/05/23.
//

import UIKit

enum OptionType{
    case TYPE
    case UNIT
}

protocol OptionChooserViewDelegate: AnyObject {
    func onOptionChoosen(option: String, optionType: OptionType)
}

@IBDesignable class OptionChooserView: UIView, ChipViewDelegate {
    
    @IBInspectable var options: [String] = []
    var selectedOptions: [String] = []
    var chipViews: [ChipView] = []
    var stackView: UIStackView!
    @IBInspectable var spacing: CGFloat = 8
    var optionType: OptionType = .TYPE
    weak var delegate: OptionChooserViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    convenience init(options: [String]) {
        self.init(frame: .zero)
        self.options = options
        setupView()
    }
    
    override func layoutSubviews() {
        setupView()
    }
    
    private func setupView() {
        if(!options.isEmpty){
            selectedOptions.append(options.first ?? "")
        }
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = spacing
        stackView.distribution = .fillEqually
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        addChips()
    }

    
    private func addChips() {
        for option in options {
            let chipView = ChipView(option: option)
            chipView.isSelected = selectedOptions.contains(option)
            chipView.delegate = self
            chipViews.append(chipView)
            stackView.addArrangedSubview(chipView)
        }
    }
    
    func setSelectedOption(_ option: String) {
        selectedOptions.removeAll()
        selectedOptions.append(option)
        for chipView in chipViews {
            chipView.isSelected = selectedOptions.contains(chipView.option)
        }
    }
    
    func didSelectChip(_ chipView: ChipView) {
        setSelectedOption(chipView.option)
        delegate?.onOptionChoosen(option: chipView.option, optionType: optionType)
    }
}
