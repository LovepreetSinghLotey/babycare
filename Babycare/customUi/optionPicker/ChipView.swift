//
//  ChipView.swift
//  Babycare
//
//  Created by User on 14/05/23.
//

import UIKit

class ChipView: UIView {
    
    var option: String
    var isSelected: Bool = false {
        didSet {
            updateUI()
        }
    }
    var delegate: ChipViewDelegate?
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.nunito(size: 14)
        label.textColor = UIColor.white
        return label
    }()
    
    init(option: String) {
        self.option = option
        super.init(frame: .zero)
        setupView()
        updateUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        layer.cornerRadius = 16
        clipsToBounds = true
        backgroundColor = .white
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onChipTap)))
        addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -4),
        ])
    }
    
    private func updateUI() {
        titleLabel.text = option
        titleLabel.textColor = isSelected ? UIColor.white : UIColor.black
        backgroundColor = isSelected ? UIColor(named: "darkBlue")! : UIColor.white
    }
    
    @objc private func onChipTap() {
        isSelected = !isSelected
        if(isSelected){
            delegate?.didSelectChip(self)
        }
    }
}

protocol ChipViewDelegate {
    func didSelectChip(_ chipView: ChipView)
}
