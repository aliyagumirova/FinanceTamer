import UIKit

final class TransactionCell: UITableViewCell {
    
    private let iconView: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.backgroundColor = UIColor(named: "ImageBackgroundColor") ?? UIColor.systemGray6
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let commentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()
    
    private let amountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .label
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let percentLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .secondaryLabel
        label.textAlignment = .right
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()
    
    private let arrowImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = UIColor(named: "ArrowColor")?.withAlphaComponent(0.3) ?? UIColor.systemGray3
        imageView.contentMode = .scaleAspectFit
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func configure(with transaction: Transaction, totalAmount: Decimal, categories: [Category]) {
        let currency = CurrencyManager.shared.selectedCurrency
        amountLabel.text = "\(transaction.amount.formatted()) \(currency)"
        
        //Процент от общей суммы
        if totalAmount != 0 {
            let percent = (transaction.amount as NSDecimalNumber)
                .dividing(by: totalAmount as NSDecimalNumber)
                .multiplying(by: 100)
                .doubleValue
            
            if abs(percent) >= 0.1 {
                percentLabel.text = String(format: "%.1f%%", percent)
            } else {
                percentLabel.text = "<0.1%"
            }
        } else {
            percentLabel.text = ""
        }

        // Категория и комментарий
        let category = transaction.category
        iconView.text = String(category.emoji)
        nameLabel.text = category.name
        commentLabel.text = transaction.comment.isEmpty ? nil : transaction.comment
    }

    private func setupUI() {
        backgroundColor = .white
        selectionStyle = .none
        
        iconView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        let textStack = UIStackView(arrangedSubviews: [nameLabel, commentLabel])
        textStack.axis = .vertical
        textStack.spacing = 2
        textStack.alignment = .leading
        
        let leftStack = UIStackView(arrangedSubviews: [iconView, textStack])
        leftStack.axis = .horizontal
        leftStack.spacing = 12
        leftStack.alignment = .center
        
        let rightStack = UIStackView(arrangedSubviews: [amountLabel, percentLabel])
        rightStack.axis = .vertical
        rightStack.spacing = 2
        rightStack.alignment = .trailing
        rightStack.setContentHuggingPriority(.required, for: .horizontal)
        
        let mainStack = UIStackView(arrangedSubviews: [leftStack, rightStack, arrowImage])
        mainStack.axis = .horizontal
        mainStack.spacing = 8
        mainStack.alignment = .center
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(mainStack)
        
        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 14),
            mainStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -14),
            mainStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 66)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.layoutMargins = .zero
    }
}
