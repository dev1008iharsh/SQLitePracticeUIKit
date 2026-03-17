# 📱 Team Member Directory (SQLite-Powered)

A high-performance, offline-first iOS application built with **Swift** and **UIKit**. This project demonstrates a professional approach to local data persistence using **SQLite (GRDB)**, focusing on memory optimization, clean architecture, and data portability.

---

## 🚀 Key Features

* **Full CRUD Lifecycle:** Create, Read, and Delete team member profiles (Name, Age, and Profile Photo) directly in a local SQLite database.
* **100% Programmatic UI:** Developed entirely without Storyboards or XIBs using **Auto Layout constraints** for maximum performance and scalability.
* **Storage Optimization:** Implemented **0.1 (10%) JPEG image compression** before saving to the database to ensure the `.sqlite` file remains lightweight and the UI stays responsive.
* **Modern Image Picking:** Integrated **PHPickerViewController** (iOS 14+) for a privacy-focused image selection experience without needing full gallery permissions.
* **Data Portability (Export/Import):** Seamlessly share your database file via the iOS Share Sheet or replace it entirely using the system Document Picker.

---

## 🏗️ Technical Architecture

This project follows a **Clean Architecture** pattern by separating concerns:

1.  **ViewControllers:** Handles user interaction and UI updates.
2.  **DatabaseManager (Singleton):** A dedicated engine that manages the connection to the SQLite file using **GRDB.swift**.
3.  **User Model:** A `Codable` and `PersistableRecord` struct that maps Swift objects directly to SQLite tables.



---

## 📤 Import & Export Functionality

This app provides a robust system for managing your data:

* **Export:** Generates the live `db.sqlite` file from the app's sandbox, allowing users to back up data or move it to other devices (Compatible with Android/Desktop SQLite viewers).
* **Import:** Allows users to pick an external `.sqlite` file. The app safely closes the existing connection, replaces the file, and re-initializes the UI automatically.

---

## 🛠️ Tech Stack & Tools

* **Language:** Swift 6
* **Framework:** UIKit (Programmatic)
* **Database Engine:** [GRDB.swift](https://github.com/groue/GRDB.swift)
* **Image Handling:** PhotosUI (PHPicker)
* **File Management:** UniformTypeIdentifiers & UIDocumentPicker

---

## 📸 Screenshots

| Home Screen | Add Member | Import/Export |
| :--- | :--- | :--- |
| ![List View](https://via.placeholder.com/200x400?text=List+View) | ![Add Member](https://via.placeholder.com/200x400?text=Add+Member) | ![Share Sheet](https://via.placeholder.com/200x400?text=Share+Sheet) |

---

## 🏁 How to Run

1.  Clone this repository.
2.  Add **GRDB.swift** via Swift Package Manager (SPM): `https://github.com/groue/GRDB.swift`.
3.  Ensure you select the `GRDB` library during setup.
4.  Build and run on any iOS 15.0+ simulator or device.

---

## #️⃣ Hashtags
#iOSDevelopment #SwiftLang #UIKit #iOSDeveloper #MobileAppDevelopment #Swift6 #ProgrammaticUI #AppleDeveloper #Xcode #SQLite #GRDB #LocalDatabase #MobileDatabase #DataPersistence #DatabaseManagement #SQL #OfflineFirst #RelationalDatabase #CleanArchitecture #SoftwareEngineering #SingletonPattern #CodingBestPractices #AppOptimization #JuniorDeveloper #SeniorDeveloperInsights #CodeRefactoring #TechInnovation #ComputerScience
