//
//  FriendsView.swift
//  recc
//
//  Created by 권동민 on 10/16/24.
//


import SwiftUI

struct FriendsView: View {
    let friends = ["친구1", "친구2", "친구3"]

    var body: some View {
        NavigationView {
            List(friends, id: \.self) { friend in
                Text(friend)
            }
            .navigationTitle("친구 목록")
        }
    }
}

struct FriendsView_Previews: PreviewProvider {
    static var previews: some View {
        FriendsView()
    }
}
