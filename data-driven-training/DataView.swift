//
//  DataView.swift
//  data-driven-training
//
//  Created by Patrick McElroy on 3/10/23.
//

import SwiftUI
import Firebase

struct DataView: View {
    @Environment(\.presentationMode) var presentationMode
    let name: String = ""
    @State private var text: String = ""
    @State private var dataTypes = ["test"]
    
    var body: some View {
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
        .navigationBarTitle("data")
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "arrow.left")
                .foregroundColor(.black)
                .imageScale(.large)
        })
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
