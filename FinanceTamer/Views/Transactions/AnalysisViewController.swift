//  AnalysisViewController.swift
//  FinanceTamer

import UIKit

final class AnalysisViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var direction: Direction!

    private let startDatePicker = UIDatePicker()
    private let endDatePicker = UIDatePicker()
    private let amountLabel = UILabel()
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let transactionsService = TransactionsService.shared
    private let categoriesService = CategoriesService()

    private var startDate = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    private var endDate = Date()

    private var rawTransactions: [Transaction] = []
    private var transactions: [Transaction] = []
    private var totalAmount: Decimal = 0
    private var sortOption: SortOption = .byDate

    private var categories: [Category] = []
    private var tableHeightConstraint: NSLayoutConstraint?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        Task { await loadData() }
    }

    private func setupUI() {
        view.backgroundColor = UIColor(named: "BackgroundColor") ?? UIColor(hex: "#F2F2F7")
        navigationController?.navigationBar.isHidden = true

        let titleLabel = UILabel()
        titleLabel.text = "Анализ"
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textColor = .label

        let sortButton = UIButton(type: .system)
        sortButton.setImage(UIImage(systemName: "arrow.up.arrow.down"), for: .normal)
        sortButton.tintColor = UIColor(named: "ClockColor") ?? .systemPurple
        sortButton.addTarget(self, action: #selector(showSortOptions), for: .touchUpInside)

        let topBar = UIStackView(arrangedSubviews: [titleLabel, sortButton])
        topBar.axis = .horizontal
        topBar.distribution = .equalSpacing
        topBar.alignment = .center

        configureDatePickers()

        amountLabel.font = .systemFont(ofSize: 17)
        amountLabel.textAlignment = .right
        amountLabel.textColor = .label

        let filtersStack = UIStackView(arrangedSubviews: [
            labeled("Начало", startDatePicker),
            labeled("Конец", endDatePicker),
            labeled("Сумма", amountLabel)
        ])
        filtersStack.axis = .vertical
        filtersStack.spacing = 12
        filtersStack.layer.cornerRadius = 10
        filtersStack.backgroundColor = .white
        filtersStack.isLayoutMarginsRelativeArrangement = true
        filtersStack.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)

        let tableHeaderLabel = UILabel()
        tableHeaderLabel.text = "ОПЕРАЦИИ"
        tableHeaderLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        tableHeaderLabel.textColor = .secondaryLabel

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TransactionCell.self, forCellReuseIdentifier: "TransactionCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.sectionHeaderHeight = 0
        tableView.insetsContentViewsToSafeArea = false
        tableView.layoutMargins = .zero
        tableView.directionalLayoutMargins = .zero
        tableView.contentInset = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
        tableView.tableHeaderView = nil

        let tableContainer = UIView()
        tableContainer.translatesAutoresizingMaskIntoConstraints = false
        tableContainer.backgroundColor = .white
        tableContainer.layer.cornerRadius = 10
        tableContainer.clipsToBounds = true
        tableContainer.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: tableContainer.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: tableContainer.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: tableContainer.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: tableContainer.bottomAnchor),
            tableContainer.widthAnchor.constraint(equalToConstant: 370)
        ])

        tableHeightConstraint = tableContainer.heightAnchor.constraint(equalToConstant: 0)
        tableHeightConstraint?.isActive = true

        let contentStack = UIStackView(arrangedSubviews: [filtersStack, tableHeaderLabel, tableContainer])
        contentStack.axis = .vertical
        contentStack.spacing = 16

        let mainStack = UIStackView(arrangedSubviews: [topBar, contentStack])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mainStack.widthAnchor.constraint(equalToConstant: 370),
            mainStack.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor)
        ])
    }

    private func configureDatePickers() {
        [startDatePicker, endDatePicker].forEach {
            $0.locale = Locale(identifier: "ru_RU")
            $0.datePickerMode = .date
            $0.preferredDatePickerStyle = .compact
            $0.calendar = Calendar(identifier: .gregorian)
        }

        startDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        endDatePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
    }

    private func labeled(_ title: String, _ view: UIView) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.font = .systemFont(ofSize: 17)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)

        let stack = UIStackView(arrangedSubviews: [label, view])
        stack.axis = .horizontal
        stack.spacing = 12
        return stack
    }

    @objc private func dateChanged() {
        let newStart = startDatePicker.date
        let newEnd = endDatePicker.date

        if newStart > newEnd {
            endDatePicker.setDate(newStart, animated: true)
            endDate = newStart
            startDate = newStart
        } else {
            startDate = newStart
            endDate = newEnd
        }

        Task { await loadData() }
    }

    @objc private func showSortOptions() {
        let alert = UIAlertController(title: "Сортировать по", message: nil, preferredStyle: .actionSheet)

        SortOption.allCases.forEach { option in
            alert.addAction(UIAlertAction(title: option.rawValue, style: .default) { _ in
                self.sortOption = option
                self.applySort()
            })
        }

        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }

    private func loadData() async {
        do {
            self.categories = try await categoriesService.categories(for: direction)
            let all = try await transactionsService.transactions(accountId: 1, from: startDate, to: endDate)
            let ids = Set(categories.map { $0.id })
            let filtered = all.filter { ids.contains($0.categoryId) }

            rawTransactions = filtered
            applySort()
        } catch {
            print("Ошибка загрузки: \(error)")
        }
    }

    private func applySort() {
        switch sortOption {
        case .byDate:
            transactions = rawTransactions.sorted { $0.transactionDate > $1.transactionDate }
        case .byAmount:
            transactions = rawTransactions.sorted { $0.amount > $1.amount }
        }

        totalAmount = transactions.reduce(0) { $0 + $1.amount }
        amountLabel.text = "\(totalAmount.formatted()) \(CurrencyManager.shared.selectedCurrency)"
        tableView.reloadData()
        updateTableHeight()
    }

    private func updateTableHeight() {
        let rowHeight: CGFloat = 66
        let totalHeight = rowHeight * CGFloat(transactions.count)
        tableHeightConstraint?.constant = totalHeight
        view.layoutIfNeeded()
    }

    // MARK: - UITableView

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        transactions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TransactionCell", for: indexPath) as? TransactionCell else {
            return UITableViewCell()
        }
        cell.configure(with: transactions[indexPath.row], totalAmount: totalAmount, categories: categories)

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        66
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNormalMagnitude
    }
}

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexSanitized.hasPrefix("#") {
            hexSanitized.remove(at: hexSanitized.startIndex)
        }

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
}
