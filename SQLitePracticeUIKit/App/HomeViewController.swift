import UIKit
import GRDB
import UniformTypeIdentifiers

/// The main screen that displays a list of team members from SQLite.
final class HomeViewController: UIViewController {
    
    // MARK: - Properties
    
    /// Array to hold the user data fetched from the database
    private var users: [User] = []
    
    /// TableView to display the list. Using 'lazy' to initialize only when needed.
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .insetGrouped)
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        tv.dataSource = self
        tv.delegate = self
        return tv
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData() // Refresh the list every time this screen appears
    }
    
    // MARK: - UI Setup
    
    /// Configures the user interface, navigation bar, and constraints.
    private func setupUI() {
        title = "Team Members"
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        
        // 1. Create Navigation Bar Buttons
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        
        // Export button to share the database file
        let exportButton = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(didTapExport))
        
        // Import button to replace the database with a new file
        let importButton = UIBarButtonItem(title: "Import", style: .plain, target: self, action: #selector(didTapImport))
        
        // 2. Add buttons to the Navigation Bar
        navigationItem.rightBarButtonItems = [addButton, exportButton]
        navigationItem.leftBarButtonItem = importButton
        
        // 3. Setup TableView constraints
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - Data Logic
    
    /// Fetches all users from SQLite using GRDB and reloads the TableView.
    private func loadData() {
        do {
            // Using the shared DatabaseManager to read data
            try DatabaseManager.shared.dbQueue?.read { db in
                // Fetching users sorted by ID (newest first)
                self.users = try User.order(User.Columns.id.desc).fetchAll(db)
            }
            // Update the UI on the main thread
            tableView.reloadData()
        } catch {
            print("❌ Load Data Error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Actions
    
    /// Opens the Add User screen in full-screen mode.
    @objc private func didTapAdd() {
        let addVC = AddUserViewController()
        let nav = UINavigationController(rootViewController: addVC)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
    
    /// Opens a share sheet to export the current 'db.sqlite' file.
    @objc private func didTapExport() {
        print("DEBUG: Preparing database for export...")
        
        // Get the path to the database file in Documents directory
        let docsURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        let dbURL = docsURL.appendingPathComponent("db.sqlite")
        
        // Check if file exists before sharing
        if FileManager.default.fileExists(atPath: dbURL.path) {
            let activityVC = UIActivityViewController(activityItems: [dbURL], applicationActivities: nil)
            present(activityVC, animated: true)
        }
    }
    
    /// Opens the system document picker to select a .sqlite file for import.
    @objc private func didTapImport() {
        print("DEBUG: Opening Document Picker...")
        
        // Pick only database/data related files
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.data, .database], asCopy: true)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true)
    }
}

// MARK: - TableView Methods (DataSource & Delegate)
 
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    // 1. Sets the height of each row to create a spacious feel
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80 // Increases space for each cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // We use a standard cell but will customize its image layout
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "UserCell")
        let user = users[indexPath.row]
        
        cell.textLabel?.text = user.name
        cell.textLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        cell.detailTextLabel?.text = "Age: \(user.age)"
        cell.detailTextLabel?.textColor = .secondaryLabel
        
        // Setup Image
        let profileImage: UIImage
        if let data = user.profileImageData, let img = UIImage(data: data) {
            profileImage = img
        } else {
            profileImage = UIImage(systemName: "person.circle.fill")!
        }
        
        // 2. FIX for Squeezing: Create a fixed size for the image
        let size = CGSize(width: 50, height: 50)
        let renderer = UIGraphicsImageRenderer(size: size)
        let scaledImage = renderer.image { _ in
            profileImage.draw(in: CGRect(origin: .zero, size: size))
        }
        
        cell.imageView?.image = scaledImage
        cell.imageView?.contentMode = .scaleAspectFill
        cell.imageView?.layer.cornerRadius = 25 // Half of width/height for a perfect circle
        cell.imageView?.clipsToBounds = true
        
        return cell
    }
    
    /// Delete action remains the same
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let user = users[indexPath.row]
            do {
                try DatabaseManager.shared.dbQueue?.write { db in
                    _ = try user.delete(db)
                }
                users.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                print("DEBUG: User deleted successfully ✅")
            } catch {
                print("❌ Delete Error: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - Document Picker Delegate (Import Logic)

extension HomeViewController: UIDocumentPickerDelegate {
    
    /// Called when the user selects a file from the Document Picker.
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else { return }
        
        // Ask for confirmation before replacing data
        let alert = UIAlertController(title: "Import Data", message: "This will replace your existing members. Continue?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Import", style: .destructive, handler: { _ in
            self.processImport(from: selectedURL)
        }))
        
        present(alert, animated: true)
    }
    
    /// Replaces the current database file with the newly picked file.
    private func processImport(from sourceURL: URL) {
        do {
            let docsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let destinationURL = docsURL.appendingPathComponent("db.sqlite")
            
            // 1. Close the current database connection
            DatabaseManager.shared.dbQueue = nil
            
            // 2. Remove old file and copy the new one
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            
            // 3. Re-open connection and refresh UI
            DatabaseManager.shared.dbQueue = try DatabaseQueue(path: destinationURL.path)
            loadData()
            
            print("DEBUG: Import Successful ✅")
        } catch {
            print("❌ Import Process Error: \(error.localizedDescription)")
        }
    }
}
