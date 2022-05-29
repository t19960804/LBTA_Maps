//
//  SelectLocationView.swift
//  LBTA_Maps
//
//  Created by t19960804 on 5/29/22.
//

import SwiftUI

struct SelectLocationView: View {
    //參考Parent View的資料源, 避免Parent and Child之間的資料不同步
    @Binding var isSelecting: Bool
    
    var body: some View {
        VStack {
            Button {
                isSelecting = false
            } label: {
                Text("Dismiss")
            }
        }
        .navigationBarHidden(true)
    }
}
