//
//  ScopeObjectTypesGridView.swift
//  DigiMeSDKExample
//
//  Created on 11/05/2023.
//  Copyright © 2023 digi.me Limited. All rights reserved.
//

import DigiMeSDK
import SwiftUI

struct ScopeObjectTypesGridView: View {
    let objectTypes: [ServiceObjectType]
    let iconSize: CGFloat = 30
    let spacing: CGFloat = 10
    
    var body: some View {
        let screenWidth = UIScreen.main.bounds.width
        let columns = (Int(floor(screenWidth / (iconSize + spacing)))) - 1
        let rows = Int(ceil(Double(objectTypes.count) / Double(columns)))
        let totalHeight = CGFloat(rows) * (iconSize + spacing) - spacing
        
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(0..<rows, id: \.self) { rowIndex in
                HStack(alignment: .top, spacing: spacing) {
                    ForEach(0..<columns, id: \.self) { colIndex in
                        if rowIndex * columns + colIndex < objectTypes.count {
                            ScopeObjectTypeIconView(name: objectTypes[rowIndex * columns + colIndex].name ?? "", size: iconSize)
                        }
                        else {
                            Spacer()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: max(totalHeight, 0))
    }
}

struct ScopeObjectTypesGridView_Previews: PreviewProvider {
    static let data = [
        ServiceObjectType(identifier: 1, name: "Media"),
        ServiceObjectType(identifier: 2, name: "Post"),
        ServiceObjectType(identifier: 7, name: "Comment"),
        ServiceObjectType(identifier: 10, name: "Like"),
        ServiceObjectType(identifier: 12, name: "Media Album"),
        ServiceObjectType(identifier: 15, name: "Social Network User"),
        ServiceObjectType(identifier: 19, name: "Profile"),
    ]
    static var previews: some View {
        ScopeObjectTypesGridView(objectTypes: data)
    }
}
