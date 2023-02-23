//
//  anisette_testApp.swift
//  anisette-test
//
//  Created by naturecodevoid on 2/22/23.
//

import SwiftUI

@main
struct anisette_testApp: App {
    @State var XAppleIMDLU = ""
    @State var XMmeDeviceId = ""
    @State var dsId: UInt64 = 0
    
    var body: some Scene {
        WindowGroup {
            VStack {
                List {
                    HStack {
                        Text("X-Apple-I-MD-LU")
                        TextField("X-Apple-I-MD-LU", text: $XAppleIMDLU)
                    }
                    HStack {
                        Text("X-Mme-Device-Id")
                        TextField("X-Mme-Device-Id", text: $XMmeDeviceId)
                    }
                    HStack {
                        Text("dsId")
                        TextField("", value: $dsId, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                    }
                    Button("Run") {
                        // MARK: - Swift reimplementation of Dadoum's Obj-C since I don't understand Obj-C
                        let body = [
                            "Header": [String: Any](),
                            "Request": [String: Any](),
                        ]
                        
                        var request = URLRequest(url: URL(string: "https://gsa.apple.com/grandslam/MidService/startMachineProvisioning")!)
                        request.httpMethod = "POST"
                        request.httpBody = try! PropertyListSerialization.data(fromPropertyList: body, format: .xml, options: 0)
                        request.setValue("<MacBookPro17,1> <macOS;12.2.1;21D62> <com.apple.AuthKit/1 (com.apple.dt.Xcode/3594.4.19)>", forHTTPHeaderField: "X-Mme-Client-Info")
                        request.setValue("text/x-xml-plist", forHTTPHeaderField: "Content-Type")
                        request.setValue("akd/1.0 CFNetwork/978.0.7 Darwin/18.7.0", forHTTPHeaderField: "User-Agent")
                        request.setValue("*/*", forHTTPHeaderField: "Accept")
                        request.setValue(XAppleIMDLU, forHTTPHeaderField: "X-Apple-I-MD-LU")
                        request.setValue(XMmeDeviceId, forHTTPHeaderField: "X-Mme-Device-Id")
                        
                        let formatter = DateFormatter()
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        formatter.calendar = Calendar(identifier: .gregorian)
                        formatter.timeZone = TimeZone(identifier: "UTC")
                        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                        let dateString = formatter.string(from: Date())
                        request.setValue(dateString, forHTTPHeaderField: "X-Apple-I-Client-Time")
                        request.setValue(Locale.current.identifier, forHTTPHeaderField: "X-Apple-Locale")
                        request.setValue(TimeZone.current.abbreviation(), forHTTPHeaderField: "X-Apple-I-TimeZone")
                        
                        URLSession.shared.dataTask(with: request) { data, response, error in
                            let plist = try! PropertyListSerialization.propertyList(from: data!, format: nil) as! Dictionary<String, Dictionary<String, Any>>
                            let spim = plist["Response"]!["spim"] as! String
                            print("spim: \(spim)")
                            let spimData = spim.data(using: .utf8)
                            
                            // MARK: - Calling StoreServices
                            var outCPIM = NSData()
                            var outCPIMPointer = AutoreleasingUnsafeMutablePointer<NSData?>(&outCPIM) // TODO: fix warning?
                            
                            var outSession = UInt32()
                            var outSessionPointer: UnsafeMutablePointer<UInt32>? = UnsafeMutablePointer<UInt32>(&outSession) // TODO: fix warning?
                            
                            var out = SSVAnisetteProvisioningStart(dsId, spimData, outCPIMPointer, outSessionPointer)
                            print("out: \(out)")
                            print("outCPIM: \(String(data: Data(referencing: outCPIM), encoding: String.Encoding.utf8))")
                            print("outSession: \(outSession)")
                        }.resume()
                    }
                    .buttonStyle(.bordered)
                }
            }
            .padding()
        }
    }
}
