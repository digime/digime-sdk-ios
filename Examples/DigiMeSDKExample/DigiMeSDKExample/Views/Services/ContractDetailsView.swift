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
    var contracts: [DigimeContract]
    
    init(selectedContract: Binding<DigimeContract>, contracts: [DigimeContract]) {
        _selectedContract = selectedContract
        self.contracts = contracts
	}
    
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

#Preview {
    let selectedContract = Contracts.prodFinSocMus
    let contracts = [Contracts.prodFinSocMus, Contracts.prodFitHealth]
    return NavigationView {
        ContractDetailsView(selectedContract: .constant(selectedContract), contracts: contracts)
    }
}
