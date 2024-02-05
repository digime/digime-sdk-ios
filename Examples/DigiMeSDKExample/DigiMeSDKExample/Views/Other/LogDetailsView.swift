//
//  LogDetailsView.swift
//  DigiMeSDKExample
//
//  Created on 20/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct LogDetailsView: View {
	var entry: LogEntry
	var json: JSON?
	var errorMessage: String?
	
	init(entry: LogEntry) {
		self.entry = entry
		
		if let jsonDictionary = entry.dictionary as? JSON {
			json = jsonDictionary
		}
	}

    var body: some View {
        if let jsonDictionary = json {
            // Convert the JSON dictionary to an array of key-value pairs
            let keyValuePairs = jsonDictionary.map { (key: $0.key, value: $0.value) }
            JSONTreeView(keyValuePairs)
                .navigationTitle("Log Details")
        } 
        else {
            // Handle the case where json is nil (e.g., show an error message or an empty view)
            Text("No JSON data available")
                .navigationTitle("Log Details")
        }
    }
}

struct LogDetailsView_Previews: PreviewProvider {
	static var entry = TestLogs.dataset.first!
    static var previews: some View {
		LogDetailsView(entry: entry)
    }
}
