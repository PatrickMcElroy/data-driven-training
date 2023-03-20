//
//  ContentView.swift
//  data-driven-training
//
//  Created by Patrick McElroy on 3/10/23.
//

import SwiftUI
import Firebase

struct ContentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var text: String = ""
    @State private var dataTypes = ["test"]
    

    var body: some View {
        NavigationView {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(alignment: .center) {
                        ForEach(dataTypes, id: \.self) { name in
                            DataType(name: name)
                        }
                        .onAppear{
                            loadData()
                        }
                    }
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .frame(width: UIScreen.main.bounds.width - 40, height: 100)
                            .shadow(radius: 10)
                            .padding(15)
                        TextField("New data type", text: $text, onCommit: {
                            dataTypes.append(text)
                            let db = Firestore.firestore()
                            db.collection("users").document(UIDevice.current.identifierForVendor?.uuidString ?? "UNK").collection("workouts").document(text).setData(["name": text])
                         })
                            .font(.headline)
                            .foregroundColor(Color.gray)
                            .offset(x: 0.5*UIScreen.main.bounds.width - 50)
                    }
                }
            }
            .background(Color.clear)
            .navigationBarTitle("data types")
        }
        
    }
    func loadData() {

            // Get a reference to the database
            let db = Firestore.firestore()
        db.collection("users").document(UIDevice.current.identifierForVendor?.uuidString ?? "UNK").collection("workouts").addSnapshotListener { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    // Convert the snapshot to an array of MyData objects
                    dataTypes = []
                    for document in querySnapshot!.documents {
                        if let type = document["name"] as? String {
                            dataTypes.append(type)
                        }
                    }
                }
            }
    }
}

struct DataType: View {
    let name: String
    @State private var showingAlert = false
    
    var body: some View {
            ZStack {
                NavigationLink(destination: DataView()) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.white)
                        .frame(width: UIScreen.main.bounds.width - 40, height: 100)
                        .shadow(radius: 10)
                        .padding(15)
                }
                .zIndex(0)
                
                Button(action: {
                    showingAlert = true
                }) {
                    Image(systemName: "trash")
                            .font(.system(size: 25))
                            .foregroundColor(.black)
                }
                .alert(isPresented: $showingAlert) {
                            Alert(title: Text("Are you sure you want to delete this data type?"), message: Text(""), primaryButton: .destructive(Text("Delete")) {
                                let db = Firestore.firestore()
                                let collectionRef = db.collection("users").document(UIDevice.current.identifierForVendor?.uuidString ?? "UNK").collection("workouts")
                                collectionRef.getDocuments() { (querySnapshot, error) in
                                    if let error = error {
                                        print("Error deleting documents: \(error.localizedDescription)")
                                    } else {
                                        for document in querySnapshot!.documents {
                                            if document["name"] as! String == name {
                                                document.reference.delete()
                                            }
                                        }
                                        print("Documents deleted.")
                                    }
                                }
                            }, secondaryButton: .cancel())
                }
                .offset(x: -0.5*UIScreen.main.bounds.width + 60)
                .zIndex(1)

                Text(name)
                    .font(.headline)
                    .foregroundColor(Color.black)
                    
                Image(systemName: "chevron.right")
                    .foregroundColor(.black)
                    .font(.title)
                    .offset(x: 0.5*UIScreen.main.bounds.width - 50) // Adjust the position of the arrow icon
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
