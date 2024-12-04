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
        GeometryReader { geometry in
            ZStack {
                Color(hex: "#FFF8E1").ignoresSafeArea()

                VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
                    SectionHeader(title: "내 프로필", geometry: geometry)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .overlay(profileSection(geometry: geometry))
                        .padding(.horizontal, geometry.size.width * 0.05)

                    SectionHeader(title: "코드로 친구 추가", geometry: geometry)
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .overlay(addFriendSection(geometry: geometry))
                        .padding(.horizontal, geometry.size.width * 0.05)

                    SectionHeader(title: "친구 리스트", geometry: geometry)
                    ForEach(friends, id: \.self) { friend in
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .overlay(friendRow(friend: friend, geometry: geometry))
                            .padding(.horizontal, geometry.size.width * 0.05)
                    }
                    Spacer()
                }
            }
            .navigationTitle("소셜")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isProfileEditModalPresented) {
                ProfileEditModal(isPresented: $isProfileEditModalPresented)
            }
            .sheet(isPresented: $isGuestBookModalPresented) {
                GuestBookModal(isPresented: $isGuestBookModalPresented)
            }
        }
    }

    private func profileSection(geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.04) {
            Circle()
                .fill(Color(hex: "#E0E0E0"))
                .frame(width: geometry.size.width * 0.16, height: geometry.size.width * 0.16)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: geometry.size.width * 0.08))
                        .foregroundColor(.gray)
                )

            Text("사용자 이름")
                .font(.headline)
                .foregroundColor(.black)

            Spacer()

            Button(action: { isProfileEditModalPresented = true }) {
                CircleButton(iconName: "gearshape.fill", geometry: geometry)
            }

            Button(action: { isGuestBookModalPresented = true }) {
                CircleButton(iconName: "envelope.fill", geometry: geometry)
            }
        }
        .padding()
    }

    private func addFriendSection(geometry: GeometryProxy) -> some View {
        HStack {
            TextField("코드를 입력하세요", text: .constant(""))
                .padding()
                .background(Color(hex: "#F9F9F9"))
                .cornerRadius(8)
                .font(.body)
                .frame(height: geometry.size.height * 0.05)

            Button(action: { /* 친구 추가 액션 */ }) {
                CircleButton(iconName: "magnifyingglass", geometry: geometry)
            }
        }
        .padding()
    }

    private func friendRow(friend: String, geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.04) {
            Circle()
                .fill(Color(hex: "#E0E0E0"))
                .frame(width: geometry.size.width * 0.12, height: geometry.size.width * 0.12)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: geometry.size.width * 0.06))
                        .foregroundColor(.gray)
                )

            Text(friend)
                .font(.body)
                .foregroundColor(.black)

            Spacer()

            Button(action: { /* 친구 방으로 이동 */ }) {
                CircleButton(iconName: "arrow.right", geometry: geometry)
            }
        }
        .padding()
    }
}

private struct SectionHeader: View {
    let title: String
    let geometry: GeometryProxy

    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(Color(hex: "#6DAFCF"))
            .padding(.horizontal, geometry.size.width * 0.05)
            .padding(.top, geometry.size.height * 0.02)
    }
}

private struct CircleButton: View {
    let iconName: String
    let geometry: GeometryProxy

    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#6DAFCF"))
                .frame(width: geometry.size.width * 0.12, height: geometry.size.width * 0.12)
            Image(systemName: iconName)
                .resizable()
                .frame(width: geometry.size.width * 0.06, height: geometry.size.width * 0.06)
                .foregroundColor(.white)
        }
    }
}

struct GuestBookModal: View {
    @Binding var isPresented: Bool

    @State private var guestBookEntries: [GuestBookEntry] = [
        GuestBookEntry(name: "친구1", message: "가구 내놔라"),
        GuestBookEntry(name: "친구2", message: "답장좀요"),
        GuestBookEntry(name: "친구3", message: "우리집이 더 나음")
    ]

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: geometry.size.height * 0.02) {
                // 닫기 버튼
                HStack {
                    Button(action: { isPresented = false }) {
                        Circle()
                            .fill(Color(hex: "#E0E0E0"))
                            .frame(width: geometry.size.width * 0.1)
                            .overlay(
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                            )
                    }
                    Spacer()
                }
                .padding()

                ScrollView {
                    VStack(spacing: geometry.size.height * 0.02) {
                        ForEach(guestBookEntries) { entry in
                            HStack(spacing: geometry.size.width * 0.04) {
                                Circle()
                                    .fill(Color(hex: "#E0E0E0"))
                                    .frame(width: geometry.size.width * 0.12)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.gray)
                                            .font(.system(size: geometry.size.width * 0.06))
                                    )

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.message)
                                        .font(.subheadline)
                                        .foregroundColor(.black)
                                    Text(entry.name)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                Button(action: { /* 재생 */ }) {
                                    CircleButton(iconName: "play.fill", geometry: geometry)
                                }

                                Button(action: { /* 답장 */ }) {
                                    CircleButton(iconName: "arrowshape.turn.up.right.fill", geometry: geometry)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .background(Color(hex: "#FFFDF7").ignoresSafeArea())
        }
    }
}


struct GuestBookEntry: Identifiable {
    let id = UUID()
    let name: String
    let message: String
}

struct ProfileEditModal: View {
    @Binding var isPresented: Bool

    @State private var userName: String = UserDefaults.standard.string(forKey: "UserName") ?? "사용자 이름"
    @State private var profileImage: UIImage? = {
        if let imageData = UserDefaults.standard.data(forKey: "ProfileImage") {
            return UIImage(data: imageData)
        }
        return nil
    }()
    @State private var isImagePickerPresented: Bool = false
    @State private var isDiaryPublic: Bool = UserDefaults.standard.bool(forKey: "IsDiaryPublic")
    @State private var friendCode: String = UserDefaults.standard.string(forKey: "FriendCode") ?? "1234-5678"
    @State private var accountInfo: String = UserDefaults.standard.string(forKey: "AccountInfo") ?? "연결된 계정 정보"

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 16) {
                // 닫기 버튼
                HStack {
                    Button(action: { isPresented = false }) {
                        Circle()
                            .fill(Color(hex: "#E0E0E0"))
                            .frame(width: 36, height: 36)
                            .overlay(
                                Image(systemName: "xmark")
                                    .foregroundColor(.white)
                            )
                    }
                    Spacer()
                }
                .padding()

                // 프로필 정보 섹션
                VStack(alignment: .leading, spacing: 16) {
                    Text("기본 정보")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#6DAFCF"))

                    HStack(spacing: 16) {
                        Button(action: { isImagePickerPresented = true }) {
                            if let profileImage = profileImage {
                                Image(uiImage: profileImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color(hex: "#6DAFCF"), lineWidth: 2)
                                    )
                            } else {
                                Circle()
                                    .fill(Color(hex: "#E0E0E0"))
                                    .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.gray)
                                    )
                            }
                        }

                        TextField("이름", text: $userName)
                            .padding()
                            .background(Color(hex: "#F9F9F9"))
                            .cornerRadius(8)
                    }

                    Button(action: saveProfile) {
                        Text("수정 완료")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "#6DAFCF"))
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)

                // 일기 공개 여부
                VStack(alignment: .leading, spacing: 16) {
                    Text("일기 공개 여부 설정")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#6DAFCF"))

                    Toggle("음성 일기 친구에게 공개", isOn: $isDiaryPublic)
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#6DAFCF")))
                        .onChange(of: isDiaryPublic) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "IsDiaryPublic")
                        }
                }
                .padding(.horizontal)

                // 친구 코드
                VStack(alignment: .leading, spacing: 16) {
                    Text("내 친구 코드")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#6DAFCF"))

                    Text(friendCode)
                        .font(.body)
                        .padding()
                        .background(Color(hex: "#F9F9F9"))
                        .cornerRadius(8)
                        .disabled(true)
                    Spacer()
                }
                .padding(.horizontal)

                // 계정 정보
                VStack(alignment: .leading, spacing: 16) {
                    Text("계정")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#6DAFCF"))

                    Text(accountInfo)
                        .font(.body)
                        .padding()
                        .background(Color(hex: "#F9F9F9"))
                        .cornerRadius(8)
                        .disabled(true)
                    Spacer()
                }
                .padding(.horizontal)

                Spacer()
            }
            .background(Color(hex: "#FFFDF7").ignoresSafeArea())
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.hidden)
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $profileImage) { selectedImage in
                    saveProfileImage(selectedImage)
                }
            }
        }
    }

    private func saveProfile() {
        UserDefaults.standard.set(userName, forKey: "UserName")
        print("사용자 이름 저장됨: \(userName)")
    }

    private func saveProfileImage(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "ProfileImage")
            profileImage = image
            print("프로필 이미지 저장됨")
        }
    }
}

/*import SwiftUI


struct SocialView: View {
    @State private var isProfileEditModalPresented = false
    @State private var isGuestBookModalPresented = false
    @State private var friends: [String] = ["친구1", "친구2", "친구3"]

    var body: some View {
        ZStack {
            Color(hex: "#FFF8E1").ignoresSafeArea() // 배경 색상

            VStack(alignment: .leading, spacing: 20) {
                // 내 프로필 섹션
                Text("내 프로필")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#6DAFCF"))
                    .padding(.horizontal, 30)
                    .padding(.top, 16)
                Divider()
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .overlay(profileSection)
                    .padding(.horizontal)
                
                // 친구 추가 섹션
                Text("코드로 친구 추가")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#6DAFCF"))
                    .padding(.horizontal, 30)
                    .padding(.top, 16)
                Divider()
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    .overlay(addFriendSection)
                    .padding(.horizontal)
                
            
                
                // 친구 리스트 섹션
                VStack(alignment: .leading, spacing: 16) {
                    Text("친구 리스트")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#6DAFCF"))
                        .padding(.horizontal)
                    Divider()
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
                .padding(.horizontal)

                Spacer()
            }
        }
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

            HStack(spacing: 16) {
                Circle()
                    .fill(Color(hex: "#E0E0E0"))
                    .frame(width: 44, height: 44)
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
        .padding()
    }

    private var addFriendSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            HStack {
                TextField("코드를 입력하세요", text: .constant(""))
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
                    .background(Color(hex: "#F9F9F9"))
                    .cornerRadius(8)
                    .font(.body)

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
        .padding()
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
        .presentationDetents([.large]) // 중형 & 대형 디텐트
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
    @Binding var isPresented: Bool

    @State private var userName: String = UserDefaults.standard.string(forKey: "UserName") ?? "사용자 이름"
    @State private var profileImage: UIImage? = {
        if let imageData = UserDefaults.standard.data(forKey: "ProfileImage") {
            return UIImage(data: imageData)
        }
        return nil
    }()

    @State private var friendCode: String = UserDefaults.standard.string(forKey: "FriendCode") ?? "1234-5678"
    @State private var accountInfo: String = UserDefaults.standard.string(forKey: "AccountInfo") ?? "연결된 계정 정보"
    @State private var isDiaryPublic: Bool = UserDefaults.standard.bool(forKey: "IsDiaryPublic")
    @State private var isImagePickerPresented: Bool = false

    var body: some View {
        VStack(spacing: 24) {
            // 닫기 버튼
            HStack {
                Button(action: {
                    isPresented = false // 모달 닫기
                }) {
                    Circle()
                        .fill(Color(hex: "#E0E0E0"))
                        .frame(width: 36, height: 36)
                        .overlay(
                            Image(systemName: "xmark")
                                .font(.system(size: 18))
                                .foregroundColor(.white)
                        )
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 16)

            // 기본 정보 섹션
            VStack(alignment: .leading, spacing: 16) {
                Text("기본 정보")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#6DAFCF"))

                HStack(spacing: 16) {
                    Button(action: {
                        isImagePickerPresented = true // 사진 첨부 열기
                    }) {
                        if let profileImage = profileImage {
                            Image(uiImage: profileImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color(hex: "#6DAFCF"), lineWidth: 2)
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(hex: "#E0E0E0"))
                                .frame(width: 80, height: 80)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(.gray)
                                        .padding(16)
                                )
                        }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        TextField("이름", text: $userName)
                            .font(.title3)
                            .padding(8)
                            .background(Color(hex: "#F9F9F9"))
                            .cornerRadius(8)

                        Button(action: {
                            saveProfile()
                        }) {
                            Text("수정 완료")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color(hex: "#6DAFCF"))
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(.horizontal)

            // 일기 공개 설정
            VStack(alignment: .leading, spacing: 8) {
                Text("일기 공개 여부 설정")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#6DAFCF"))

                Toggle("음성 일기 친구에게 공개", isOn: $isDiaryPublic)
                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#6DAFCF")))
                    .onChange(of: isDiaryPublic) { newValue in
                        UserDefaults.standard.set(newValue, forKey: "IsDiaryPublic")
                    }
            }
            .padding(.horizontal)

            // 친구 코드 섹션
            VStack(alignment: .leading, spacing: 8) {
                Text("내 친구 코드")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#6DAFCF"))

                TextField("", text: $friendCode)
                    .disabled(true)
                    .font(.body)
                    .padding()
                    .background(Color(hex: "#F9F9F9"))
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            // 계정 정보 섹션
            VStack(alignment: .leading, spacing: 8) {
                Text("계정")
                    .font(.headline)
                    .foregroundColor(Color(hex: "#6DAFCF"))

                TextField("", text: $accountInfo)
                    .disabled(true)
                    .font(.body)
                    .padding()
                    .background(Color(hex: "#F9F9F9"))
                    .cornerRadius(8)
            }
            .padding(.horizontal)

            Spacer()
        }
        .background(Color(hex: "#FFFDF7").ignoresSafeArea())
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.hidden)
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $profileImage) { selectedImage in
                saveProfileImage(selectedImage)
            }
        }
    }

    // 프로필 저장
    private func saveProfile() {
        UserDefaults.standard.set(userName, forKey: "UserName")
        print("사용자 이름 저장됨: \(userName)")
    }

    // 프로필 이미지 저장
    private func saveProfileImage(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "ProfileImage")
            profileImage = image
            print("프로필 이미지 저장됨")
        }
    }
}
*/
// ImagePicker: 이미지 선택기 구현
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var onImagePicked: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.editedImage] as? UIImage {
                parent.image = uiImage
                parent.onImagePicked(uiImage)
            } else if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
                parent.onImagePicked(uiImage)
            }
            picker.dismiss(animated: true)
        }
    }
}

