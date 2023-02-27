//
//  ContractDetailsView.swift
//  DigiMeSDKExample
//
//  Created on 21/02/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import SwiftUI

struct ContractDetailsView: View {
	@Binding var selectedContract: DigimeContract

	init(contract: Binding<DigimeContract>) {
		_selectedContract = contract
	}
	
	private var contracts = [Contracts.finSocMus, Contracts.fitHealth]
	var body: some View {
		VStack {
			List {
				ForEach(contracts) { contract in
					Button {
						selectedContract = contract
					} label: {
						HStack {
							Text(contract.name)
							Spacer()
							if selectedContract.id == contract.id {
								Image(systemName: "checkmark")
							}
						}
					}
				}
			}
			.listStyle(InsetGroupedListStyle())
		}
	}
}

struct ContractDetailsView_Previews: PreviewProvider {
	static var previews: some View {
		NavigationView {
			ContractDetailsView(contract: .constant(Contracts.finSocMus))
		}
	}
}
