//
//  CheckoutView.swift
//  CupcakeOrder
//
//  Created by Adam S on 2020-08-12.
//  Copyright © 2020 Adam S. All rights reserved.
//

import SwiftUI


//come back to solve alrt
//then do other problems
struct CheckoutView: View {
    @ObservedObject var order: Order
    
    //make an alert showing the user that their order went through
    //also present the details of that order
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    @State private var noInternet = false
    
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    Image("cupcakes")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width)
                    
                    Text("Your total is $\(self.order.cost, specifier: "%.2f")")
                        .font(.title)
                    
                    Button("Place Order") {
                        self.placeOrder()
                    }
                    .padding()
                }
            }
        }
        .navigationBarTitle("Check out", displayMode: .inline)
            
        .alert(isPresented: $showingConfirmation) {
            Alert(title: Text("Thank you!"), message: Text(confirmationMessage), dismissButton: .default(Text("OK")))
        }
      
        
        
    }
    
    
    func placeOrder() {
        //start by encoding the Order object into JSON
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            return
        }
        
        //create url to send data to server
        //initiate a request
        //set value to JSON, make a headerfield
        //were using POST here since were sending data
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") //??
        request.httpMethod = "POST"
        request.httpBody = encoded //??
        
        //handle the result here
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data{
                if let decodedOrder = try? JSONDecoder().decode(Order.self, from: data) {
                    self.confirmationMessage = "Your order for \(decodedOrder.quantity)x \(Order.types[decodedOrder.type].lowercased()) cupcakes is on its way!"
                    self.showingConfirmation = true
                } else {
                    print("Invalid response from server")
                }
            }
            else {
                self.noInternet = true
            }
           
        }.resume()
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(order: Order())
    }
}
