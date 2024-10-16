//
//  ContentView.swift
//  recc
//
//  Created by 권동민 on 10/16/24.
//


import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            
            CalendarView()  // 달력 보기
                .tabItem {
                    Image(systemName: "calendar")
                    Text("달력")
                }
            HomeView()  // HomeView에서 녹음 기능을 포함
                .tabItem {
                    Image(systemName: "house")
                    Text("마이 홈")
                }
            
            FriendsView()  // 친구 목록 보기
                .tabItem {
                    Image(systemName: "person.2")
                    Text("친구네")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
