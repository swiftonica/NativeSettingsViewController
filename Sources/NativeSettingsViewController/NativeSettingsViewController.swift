import Foundation
import UIKit
import SPSettingsIcons

public struct NativeSettingsRow: Equatable {
    public let iconName: String
    public let title : String
    public let color: UIColor

    public static func aboutApp(_ title: String = "About App") -> NativeSettingsRow {
        return .init(
            iconName: "character.book.closed.fill",
            title: title,
            color: .systemRed
        )
    }
    
    public static func support(_ title: String = "Support") -> NativeSettingsRow {
        return .init(
            iconName: "bolt.fill",
            title: title,
            color: .systemYellow
        )
    }
    
    public static func custom(
        iconName: String,
        title: String,
        color: UIColor
    ) -> NativeSettingsRow {
        return .init(iconName: iconName, title: title, color: color)
    }
}

public struct NativeSettingsSection {
    public let headerTitle: String
    public let footerTitle: String
    public let rows: [NativeSettingsRow]
}

public protocol NativeSettingsViewControllerDataSource: AnyObject {
    func nativeSettingsViewController(
        _ viewController: NativeSettingsViewController
    ) -> [NativeSettingsSection]
    
    func nativeSettingsViewController(
        _ viewCOntroller: NativeSettingsViewController,
        shouldShowIndicator for: IndexPath
    ) -> Bool
    
    func nativeSettingsViewControllerShouldUseTitle(
        _ viewController: NativeSettingsViewController
    ) -> String
}

public extension NativeSettingsViewControllerDataSource {
    func nativeSettingsViewControllerShouldUseTitle(
        _ viewController: NativeSettingsViewController
    ) -> String {
        return ""
    }
}

public protocol NativeSettingsViewControllerDelegate: AnyObject {
    func nativeSettingsViewController(
        _ viewController: NativeSettingsViewController,
        didSelect row: NativeSettingsRow)
}

public class NativeSettingsViewController: UIViewController {
    
    public var delegate: NativeSettingsViewControllerDelegate?
    
    public init(dataSource: NativeSettingsViewControllerDataSource) {
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
        configureTableView()
        title = dataSource.nativeSettingsViewControllerShouldUseTitle(self)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        updateLayout(with: view.frame.size)
    }
    
    public override func viewWillTransition(
        to size: CGSize,
        with coordinator: UIViewControllerTransitionCoordinator
    ) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { _ in
            self.updateLayout(with: size)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    private let dataSource: NativeSettingsViewControllerDataSource
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
}

private extension NativeSettingsViewController {
    func updateLayout(with size: CGSize) {
        self.tableView.frame = .init(origin: .zero, size: size)
    }
    
    func configureTableView() {
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension NativeSettingsViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(
        _ tableView: UITableView,
        titleForFooterInSection section: Int
    ) -> String? {
        return dataSource.nativeSettingsViewController(self)[section].footerTitle
    }
    
    public func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int
    ) -> String? {
        return dataSource.nativeSettingsViewController(self)[section].headerTitle
    }
    
    public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return dataSource.nativeSettingsViewController(self)[section].rows.count
    }
    
    public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let model = dataSource.nativeSettingsViewController(self)[indexPath.section].rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if dataSource.nativeSettingsViewController(self, shouldShowIndicator: indexPath) {
            cell.accessoryType = .disclosureIndicator
        }
        cell.imageView?.image = UIImage.generateSettingsIcon(model.iconName, backgroundColor: model.color)
        cell.textLabel?.text = model.title
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.nativeSettingsViewController(
            self,
            didSelect: dataSource.nativeSettingsViewController(self)[indexPath.section].rows[indexPath.row]
        )
    }
}

