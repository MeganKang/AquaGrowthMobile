//
//  individual_plant_viewmodel.swift
//  AquaGrowthMobile
//
//  Created by Noah Jacinto on 2/28/24.
//
//New change
import Foundation
import FirebaseAuth
import FirebaseFirestore

class individualplant_viewmodel: ObservableObject {
    @Published var plant_id = ""
    @Published var led = 0
    @Published var moisture = 0
    @Published var humidity = 0
    @Published var fahrenheit = 0
    @Published var heatIndex = 0
    @Published var currentDay = ""
    @Published var lightIndex = 0
    
    init(){
        
        self.currentDay = formatDate(Date(), format:  "yyyy-MM-dd")
    }
    
    func SavedSensorInformation() {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        let sensorData = [
            "status": led,
            "moisture": moisture,
            "humidity": humidity,
            "temperature": fahrenheit,
            "heat": heatIndex,
            "light": lightIndex,
            "timestamp": Date().timeIntervalSince1970
        ] as [String : Any]
        
        
        
        // Call the updated addSensorData method
        

        addSensorData(db: db, userId: uid, data: sensorData)
        updateLastSensorData(db: db, userId: uid, data: sensorData)
    }
    
    func updateLastSensorData(db: Firestore, userId: String, data: [String: Any]) {
        let plantCollectionRef = db.collection("users")
            .document(userId)
            .collection("plants")
            .document(self.plant_id)
        
        let lastSensorDataRef = plantCollectionRef.collection("lastDaily")
        
        for (key, value) in data {
            // Each sensor's data is stored in its own document, named by the key
            let sensorData = lastSensorDataRef.document(key)
            // Assuming all data values are of a type that can be directly stored in Firestore
            sensorData.setData([key: value]) { error in
                if let error = error {
                    print("Error adding data for \(key): \(error)")
                } else {
                    print("Successfully added data for \(key)")
                }
            }
        }
    }
    
    func addSensorData(db: Firestore, userId: String, data: [String: Any]) {
        let currentDate = Date() + 1
        let timestamp = Date().timeIntervalSince1970
        
        let dailyId = formatDate(currentDate, format: "yyyy-MM-dd")
        let weeklyId = formatDate(currentDate, format: "yyyy-'W'ww")
        let monthlyId = formatDate(currentDate, format: "yyyy-MM")
        
        let plantCollectionRef = db.collection("users")
            .document(userId)
            .collection("plants")
            .document(self.plant_id)
            .collection("monthly")
            .document(monthlyId)
            .collection(weeklyId)
            .document(dailyId)

        // Set the document with the data including timestamp
        plantCollectionRef.setData(["timestamp" : Date().timeIntervalSince1970]) { error in
            if let error = error {
                print("Error adding sensor data: \(error)")
            } else {
                print("Successfully added sensor data")
            }
        }
        
        // Iterate over each key-value pair in the data dictionary
        for (key, value) in data {
            let sensorDataRef = plantCollectionRef.collection(key)
            // Each sensor's data is stored in its own document, named by the key
            let sensorData = sensorDataRef.document(UUID().uuidString)
            // Assuming all data values are of a type that can be directly stored in Firestore
            let sensorDataDocument = [
                String(timestamp) : value,
                key: value
            ]
            
            sensorData.setData(sensorDataDocument) { error in
                if let error = error {
                    print("Error adding data for \(key): \(error)")
                } else {
                    print("Successfully added data for \(key)")
                }
            }
        }
    }
    
//    func addSensorData(db: Firestore, userId: String, data: [String: Any]) {
//        let currentDate = Date()
//        let timestamp = currentDate.timeIntervalSince1970
//        
//        let dailyId = formatDate(currentDate, format: "yyyy-MM-dd")
//        let weeklyId = formatDate(currentDate, format: "yyyy-'W'ww")
//        let monthlyId = formatDate(currentDate, format: "yyyy-MM")
//        
//        let plantCollectionRef = db.collection("users")
//            .document(userId)
//            .collection("plants")
//            .document(self.plant_id)
//            .collection("monthly")
//            .document(monthlyId)
//            .collection(weeklyId)
//            .document(dailyId)
//
//        //        plantCollectionRef.setData(["timestamp" : Date().timeIntervalSince1970]) { error in
//            if let error = error {
//                print("Error adding sensor data: \(error)")
//            } else {
//                print("Successfully added sensor data")
//            }
//        }
//        
//        // Iterate over each key-value pair in the data dictionary
//        for (key, value) in data {
//            let sensorDataRef = plantCollectionRef.collection("sensorData")
//            // Each sensor's data is stored in its own document, named by the key
//            let sensorData = sensorDataRef.document(UUID().uuidString)
//            // Assuming all data values are of a type that can be directly stored in Firestore
//            let sensorDataDocument = [
//                "sensor_name": key,
//                "timestamp": timestamp,
//                key: value
//            ]
//            sensorData.setData(sensorDataDocument) { error in
//                if let error = error {
//                    print("Error adding data for \(key): \(error)")
//                } else {
//                    print("Successfully added data for \(key)")
//                }
//            }
//        }
//    }


    
    
    // Helper function to format dates
    func formatDate(_ date: Date, format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func fetchLatestDailyMoisture(completion: @escaping (Int?) -> Void) {
        let db = Firestore.firestore()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion(nil)
            return
        }
        
        // Reference to 'lastDaily' document within the 'plants' collection
        let lastDailyDocumentRef = db.collection("users")
            .document(uid)
            .collection("plants")
            .document(self.plant_id)
            .collection("lastDaily")
            .document("moisture")
        
        // Get the document directly
        lastDailyDocumentRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
            } else if let document = documentSnapshot, document.exists {
                // Document exists, extract the moisture value
                if let moisture = document.data()?["moisture"] as? Int {
                    completion(moisture)
                    print("Latest daily moisture set to \(moisture)")
                } else {
                    completion(nil)
                    print("Moisture data is not valid")
                }
            } else {
                completion(nil)
                print("Document does not exist")
            }
        }
    }
    
    
    func fetchLatestDailyTemperature(completion: @escaping (Int?) -> Void) {
        let db = Firestore.firestore()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion(nil)
            return
        }
        
        // Reference to 'lastDaily' document within the 'plants' collection
        let lastDailyDocumentRef = db.collection("users")
            .document(uid)
            .collection("plants")
            .document(self.plant_id)
            .collection("lastDaily")
            .document("temperature")
        
        // Get the document directly
        lastDailyDocumentRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
            } else if let document = documentSnapshot, document.exists {
                // Document exists, extract the moisture value
                if let temperature = document.data()?["temperature"] as? Int {
                    completion(temperature)
                    print("Latest daily temperature set to \(temperature)")
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

    func fetchLatestDailyHumidity(completion: @escaping (Int?) -> Void) {
        let db = Firestore.firestore()
        
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion(nil)
            return
        }
        
        // Reference to 'lastDaily' document within the 'plants' collection
        let lastDailyDocumentRef = db.collection("users")
            .document(uid)
            .collection("plants")
            .document(self.plant_id)
            .collection("lastDaily")
            .document("humidity")
        
        // Get the document directly
        lastDailyDocumentRef.getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error getting document: \(error)")
                completion(nil)
            } else if let document = documentSnapshot, document.exists {
                // Document exists, extract the moisture value
                if let humidity = document.data()?["humidity"] as? Int {
                    completion(humidity)
                    print("Latest daily humidity set to \(humidity)")
                } else {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }

    private func updatePlantParameters(with data: [String: Any]) {
        self.led = data["status"] as? Int ?? self.led
        self.moisture = data["moisture"] as? Int ?? self.moisture
        self.humidity = data["humidity"] as? Int ?? self.humidity
        self.fahrenheit = data["temperature"] as? Int ?? self.fahrenheit
        self.heatIndex = data["heat"] as? Int ?? self.heatIndex
        
        print(self.led)
        print(self.moisture)
        print(self.humidity)
        print(self.fahrenheit)
        print(self.heatIndex)
        
    }
    
    func setFavorite() {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        let documentRef = db.collection("users")
            .document(uid)
            .collection("plants")
            .document(self.plant_id)

        // Fetch the current value of the 'favorite' field
        documentRef.getDocument { document, error in
            if let error = error {
                return
            }

            guard let document = document, document.exists else {
                return
            }
            print(document)
            // Get the current value of the 'favorite' field
            if let currentFavoriteValue = document.data()?["favorite"] as? Int {
                if currentFavoriteValue == 1 {
                    // Toggle the 'favorite' field value to 0
                    documentRef.setData(["favorite": 0], merge: true)
                } else {
                    // Toggle the 'favorite' field value to 1
                    documentRef.setData(["favorite": 1], merge: true)
                    }
            }
        }
    }
    
    func fetchFavoriteStatus(completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            completion(false)
            return
        }
        
        let documentRef = db.collection("users")
            .document(uid)
            .collection("plants")
            .document(self.plant_id)
        
        documentRef.getDocument { document, error in
            if let error = error {
                print("Error fetching favorite status: \(error)")
                completion(false)
                return
            }
            
            guard let document = document, document.exists else {
                print("Document does not exist")
                completion(false)
                return
            }
            
            // Get the current value of the 'favorite' field
            if let currentFavoriteValue = document.data()?["favorite"] as? Int {
                completion(currentFavoriteValue == 1)
            } else {
                completion(false)
            }
        }
    }

}
