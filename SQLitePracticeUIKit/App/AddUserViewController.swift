//
//  AddUserViewController.swift
//  SQLitePracticeUIKit
//
//  Created by Harsh on 17/03/26.
//

import UIKit
import GRDB
import PhotosUI

/// This screen allows the user to create a new profile with an image, name, and age.
final class AddUserViewController: UIViewController {

    // MARK: - UI Elements
    
    /// Profile Image view where the user can see their selected photo.
    private let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .secondarySystemBackground
        iv.layer.cornerRadius = 50 // Makes the image circular
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.isUserInteractionEnabled = true // Allows tap gestures
        iv.image = UIImage(systemName: "person.crop.circle.badge.plus") // Default icon
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    /// Text field for the user to type their name.
    private let nameField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    /// Text field for the user to type their age.
    private let ageField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Age"
        tf.borderStyle = .roundedRect
        tf.keyboardType = .numberPad // Shows number-only keyboard
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI() // Initialize the UI
    }

    // MARK: - UI Setup
    
    /// Adds UI elements to the view and sets up Auto Layout constraints.
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "New Profile"

        // Navigation Buttons
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(didTapSave))

        // Add subviews to the main view
        view.addSubview(profileImageView)
        view.addSubview(nameField)
        view.addSubview(ageField)

        // Setup Tap Gesture for the profile image
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapImage))
        profileImageView.addGestureRecognizer(tap)

        // Auto Layout Constraints: Defining where things go on the screen
        NSLayoutConstraint.activate([
            // Profile Image: Center Top
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),

            // Name Field: Below Image
            nameField.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 40),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            // Age Field: Below Name Field
            ageField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 20),
            ageField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ageField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    // MARK: - Actions
    
    /// Opens the modern PHPicker to select a photo from the gallery.
    @objc private func didTapImage() {
        print("DEBUG 📸: User is picking an image")
        var config = PHPickerConfiguration()
        config.filter = .images // Show only photos
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    /// Closes the screen without saving.
    @objc private func cancel() {
        print("DEBUG: Cancelled by user")
        dismiss(animated: true)
    }

    /// Validates inputs, compresses the image, and saves data to SQLite.
    @objc private func didTapSave() {
        // 1. Validation: Ensure name is not empty and age is a valid number
        guard let name = nameField.text, !name.isEmpty,
              let ageText = ageField.text, let age = Int(ageText) else {
            print("DEBUG: Validation failed")
            return
        }
        
        // 2. Prepare Image Data: Compress image to save space (10% quality)
        var imageData: Data?
        if let image = profileImageView.image {
            // Using our helper function from User model
            imageData = User.compressImage(image)
        }
        
        // 3. Create the User object
        let newUser = User(name: name, age: age, profileImageData: imageData)
        
        // 4. Save to Database
        do {
            // Using our shared manager to write into the database
            try DatabaseManager.shared.dbQueue?.write { db in
                try newUser.insert(db) // Insert the row into the table
            }
            print("DEBUG ✅: User saved to database successfully!")
            dismiss(animated: true) // Go back to Home Screen
        } catch {
            print("❌ Save Error: \(error.localizedDescription)")
        }
    }
}

// MARK: - PHPickerViewControllerDelegate

extension AddUserViewController: PHPickerViewControllerDelegate {
    
    /// Handles the result of the image picker.
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true) // Close the picker
        
        // Get the selected image provider
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        // Load the image asynchronously
        provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
            // UI updates must happen on the Main Thread
            DispatchQueue.main.async {
                if let selectedImage = image as? UIImage {
                    self?.profileImageView.image = selectedImage
                    print("DEBUG: Image updated on screen")
                }
            }
        }
    }
}
