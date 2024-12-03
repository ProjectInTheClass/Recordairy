//
//  SocialView.swift
//  Recordiary
//
//  Created by 김민아 on 11/5/24.
//

import SwiftUI

struct SocialView: View {
    @State private var isProfileEditModalPresented = false
    @State private var isGuestBookModalPresented = false
    @State private var friends: [String] = ["친구1", "친구2", "친구3"]

    var body: some View {
        VStack(spacing: 20) {
            // 내 프로필 섹션
            profileSection
                .padding(.horizontal)
                .padding(.top, 16) // 상단 네비게이션 바로 아래 여백
            
            Divider()

            // 친구 추가 섹션
            addFriendSection
                .padding(.horizontal)

            Divider()

            // 친구 리스트 섹션
            friendListSection
                .padding(.horizontal)

            Spacer()
        }
        .background(Color(hex: "#FFF8E1").ignoresSafeArea()) // 배경 색상
        .navigationTitle("소셜")
        .navigationBarTitleDisplayMode(.inline) // 제목 위치 조정
        .sheet(isPresented: $isProfileEditModalPresented) {
            ProfileEditModal(isPresented: $isProfileEditModalPresented)
        }
        .sheet(isPresented: $isGuestBookModalPresented) {
            GuestBookModal(isPresented: $isGuestBookModalPresented)
        }
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("내 프로필")
                .font(.headline)
                .foregroundColor(Color(hex: "#6DAFCF"))

            HStack(spacing: 16) {
                Circle()
                    .fill(Color(hex: "#E0E0E0"))
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.gray)
                    )

                Text("사용자 이름")
                    .font(.headline)
                    .foregroundColor(.black)

                Spacer()

                Button(action: {
                    isProfileEditModalPresented = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#6DAFCF"))
                            .frame(width: 44, height: 44)
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                }

                Button(action: {
                    isGuestBookModalPresented = true
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#6DAFCF"))
                            .frame(width: 44, height: 44)
                        Image(systemName: "envelope.fill")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    private var addFriendSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("친구 코드로 친구 검색")
                .font(.headline)
                .foregroundColor(Color(hex: "#6DAFCF"))

            HStack {
                TextField("코드를 입력하세요", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(height: 44) // 높이 조정
                Button(action: {
                    // 친구 추가 액션
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#6DAFCF"))
                            .frame(width: 44, height: 44)
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }

    private var friendListSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("친구 리스트")
                .font(.headline)
                .foregroundColor(Color(hex: "#6DAFCF"))

            ForEach(friends, id: \.self) { friend in
                HStack(spacing: 16) {
                    Circle()
                        .fill(Color(hex: "#E0E0E0"))
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                        )

                    Text(friend)
                        .font(.body)
                        .foregroundColor(.black)

                    Spacer()

                    Button(action: {
                        // 친구 방으로 이동 액션
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color(hex: "#6DAFCF"))
                                .frame(width: 44, height: 44)
                            Image(systemName: "arrow.right")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            }
        }
    }
}


//방명록

struct GuestBookModal: View {
    @Binding var isPresented: Bool
    
    // 더미 데이터: 방명록 메시지 목록
    @State private var guestBookEntries: [GuestBookEntry] = [
        GuestBookEntry(name: "친구1", message: "가구 내놔라"),
        GuestBookEntry(name: "친구2", message: "답장좀요"),
        GuestBookEntry(name: "친구3", message: "우리집이 더 나음"),
        GuestBookEntry(name: "친구4", message: "왜 요새 안하냐"),
        GuestBookEntry(name: "친구5", message: "나도 시작함"),
        GuestBookEntry(name: "친구6", message: "일기 공개해줘~~")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            // 상단 닫기 버튼
            HStack {
                Button(action: {
                    isPresented = false // 모달 닫기
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E0E0E0"))
                            .frame(width: 44, height: 44)
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // 방명록 리스트
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(guestBookEntries) { entry in
                        HStack(spacing: 16) {
                            // 프로필 이미지
                            Circle()
                                .fill(Color(hex: "#E0E0E0"))
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray)
                                )
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(entry.message)
                                    .font(.subheadline)
                                    .foregroundColor(.black)
                                    .lineLimit(1) // 한 줄로 제한
                                Text(entry.name)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // 재생 버튼
                            Button(action: {
                                print("재생 버튼 클릭: \(entry.name)")
                            }) {
                                Circle()
                                    .fill(Color(hex: "#6DAFCF"))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "play.fill")
                                            .foregroundColor(.white)
                                    )
                            }
                            
                            // 답장 버튼
                            Button(action: {
                                print("답장 버튼 클릭: \(entry.name)")
                            }) {
                                Circle()
                                    .fill(Color(hex: "#E0E0E0"))
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        Image(systemName: "arrowshape.turn.up.right.fill")
                                            .foregroundColor(.gray)
                                    )
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(Color(hex: "#FFF8E1").ignoresSafeArea())
        .presentationDetents([.medium, .large]) // 중형 & 대형 디텐트
        .presentationDragIndicator(.hidden) // 기본 드래그 인디케이터 숨기기
    }
}

// 방명록 항목 데이터 모델
struct GuestBookEntry: Identifiable {
    let id = UUID()
    let name: String
    let message: String
}


//프로필 설정
struct ProfileEditModal: View {
    @Binding var isPresented: Bool // 모달 상태 바인딩
    @State private var username: String = "사용자 이름" // 사용자 이름
    @State private var isDiaryPublic: Bool = false // 일기 공개 여부
    
    var body: some View {
        VStack(spacing: 20) {
            // 상단 닫기 버튼
            HStack {
                Button(action: {
                    isPresented = false // 모달 닫기
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E0E0E0"))
                            .frame(width: 44, height: 44)
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // 기본 정보 섹션
            VStack(alignment: .leading, spacing: 16) {
                Text("기본 정보")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#6DAFCF"))
                
                HStack(spacing: 16) {
                    // 프로필 이미지
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(hex: "#E0E0E0"))
                        .frame(width: 64, height: 64)
                        .overlay(
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.gray)
                                .padding(8)
                        )
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // 사용자 이름
                        HStack {
                            TextField("이름 입력", text: $username)
                                .font(.headline)
                                .textFieldStyle(PlainTextFieldStyle())
                                .frame(height: 44)
                                .padding(.horizontal)
                                .background(Color(hex: "#F5F5F5"))
                                .cornerRadius(12)
                            
                            Button(action: {
                                print("수정 완료 클릭")
                            }) {
                                Text("수정 완료")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color(hex: "#6DAFCF"))
                                    .cornerRadius(12)
                            }
                        }
                        
                        // 프로필 사진 업데이트
                        Button(action: {
                            print("프로필 사진 업데이트 클릭")
                        }) {
                            Text("프로필 사진 업데이트")
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            
            Divider()
            
            // 일기 공개 여부 설정
            VStack(alignment: .leading, spacing: 16) {
                Text("일기 공개 여부 설정")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#6DAFCF"))
                
                Toggle("음성 일기 친구에게 공개", isOn: $isDiaryPublic)
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#6DAFCF")))
            }
            .padding(.horizontal, 16)
            
            Divider()
            
            // 내 친구 코드 섹션
            VStack(alignment: .leading, spacing: 16) {
                Text("내 친구코드")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#6DAFCF"))
                
                Text("1234-5678-ABCD")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding()
                    .background(Color(hex: "#F5F5F5"))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 16)
            
            Spacer()
        }
        .background(Color(hex: "#FFFDF7").ignoresSafeArea())
        .presentationDetents([.medium, .large]) // 시트 높이
        .presentationDragIndicator(.hidden) // 드래그 인디케이터 숨기기
    }
}

