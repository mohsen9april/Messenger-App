//
//  ContentView.swift
//  Messenger App
//
//  Created by Mohsen Abdollahi on 7/8/20.
//  Copyright © 2020 Mohsen Abdollahi. All rights reserved.
//

import SwiftUI
import Firebase

struct ContentView: View {
    
    @State var name = ""
    
    var body: some View {
        
        NavigationView {
            
            ZStack {
                Color.orange
                VStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .padding(.top ,12)
                    
                    TextField("Name" , text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    
                    if self.name != "" {
                        
                        NavigationLink(destination: MsgPage(name: self.name) ) {
                            HStack {
                                Text("Join")
                                Image(systemName: "arrow.right.circle.fill")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                
                            }
                        }.frame(width: 100, height: 54)
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(27)
                            .padding(.bottom, 15)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                
            }.edgesIgnoringSafeArea(.all)
        }.animation(.default)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}



// Second / Message Page :

struct MsgPage : View {
    
    var name = ""
    @ObservedObject var msg = observer()
    @State var typedmsg = ""
    
    var body: some View {
        
        NavigationView {
            VStack{
                
                List(msg.msgs) { index in
                    
//                    Text("\(index.name)")
//                    Text("\(index.msg)")
                    
                    if index.name == self.name {
                        
                        MessageRow(user: index.name, message: "\(index.msg)", isMyMessage: true)
                        
                    } else {
                        
                        MessageRow(user: index.name, message: index.msg, isMyMessage: false)
                    }
                }
                
                HStack{
                    TextField("Enter your Message", text: $typedmsg)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: {
                        //Action
                        self.msg.addMsg(msg: self.typedmsg, user: self.name)
                        self.typedmsg = ""
                    }, label: {
                        Text("Send")
                    })
                }.padding()
                
                
            }
            .navigationBarTitle("Chats" , displayMode: .automatic)
        }
    }
}

struct datatype: Identifiable {
    var id: String
    var name: String
    var msg: String
}

struct MessageRow : View {
    
    var user = ""
    var message : String = ""
    var isMyMessage = false
    

    var body: some View {
        
        HStack{
            
            if isMyMessage {
                Spacer()
                VStack(alignment: .trailing){
                    Text("\(user)")
                    Text(message)
                }.background(Color.red).cornerRadius(6)
                
            } else {
                
                VStack(alignment: .leading){
                    Text("\(user)")
                    Text(message).background(Color.green).cornerRadius(6)
                }
                Spacer()
                
            }
        }
    }
}

class  observer : ObservableObject {
    
    @Published var msgs = [datatype]()
    
    
    init() {
        let db = Firestore.firestore()
        db.collection("msgs").addSnapshotListener { (snap, err) in
            if err != nil {
                print(err?.localizedDescription as Any)
                return
            }
            
            for i in snap!.documentChanges {
                if i.type == .added {
                    let name = i.document.get("name") as! String
                    let msg = i.document.get("msg") as! String
                    let id = i.document.documentID
                    
                    self.msgs.append(datatype(id: id, name: name, msg: msg))
                }
            }
        }
    }
    
    
    func addMsg(msg: String, user: String) {
        
        let db = Firestore.firestore()
        db.collection("msgs").addDocument(data: ["msg": msg, "name": user]) { (err) in
            if err != nil {
                print(err?.localizedDescription as Any)
                return
            }
            print("Success")
        }
    }
  
}
