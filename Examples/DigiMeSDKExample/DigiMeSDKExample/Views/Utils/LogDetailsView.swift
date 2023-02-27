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
		JSONTreeView(json ?? JSON())
			.navigationTitle("Log Details")
	}
}

struct LogDetailsView_Previews: PreviewProvider {
	static var entry = TestLogs.dataset.first!
    static var previews: some View {
		LogDetailsView(entry: entry)
    }
}
