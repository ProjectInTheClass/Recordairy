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
                    RoundedRectangle(cornerRadius: 21)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .overlay(profileSection(geometry: geometry))
                        .padding(.horizontal, geometry.size.width * 0.05)
                    
                    SectionHeader(title: "코드로 친구 추가", geometry: geometry)
                    RoundedRectangle(cornerRadius: 21)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .overlay(addFriendSection(geometry: geometry))
                        .padding(.horizontal, geometry.size.width * 0.05)
                    
                    SectionHeader(title: "친구 리스트", geometry: geometry)
                    ForEach(friends, id: \.self) { friend in
                        RoundedRectangle(cornerRadius: 21)
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
                CustomModal {
                    ProfileEditModal(isPresented: $isProfileEditModalPresented)
                }
            }
            .sheet(isPresented: $isGuestBookModalPresented) {
                CustomModal {
                    GuestBookModal(isPresented: $isGuestBookModalPresented)
                }
            }
            /*
             .sheet(isPresented: $isProfileEditModalPresented) {
             GeometryReader { geometry in
             CustomModal {
             ProfileEditModal(isPresented: $isProfileEditModalPresented)
             }
             .presentationDetents([.fraction(detentHeight(for: geometry))])
             }
             }
             .sheet(isPresented: $isGuestBookModalPresented) {
             GeometryReader { geometry in
             CustomModal {
             GuestBookModal(isPresented: $isGuestBookModalPresented)
             }
             .presentationDetents([.fraction(detentHeight(for: geometry))])
             }
             }*/
            
        }
    }
    
    private func detentHeight(for geometry: GeometryProxy) -> CGFloat {
        let safeAreaTop = geometry.safeAreaInsets.top
        let totalHeight = geometry.size.height
        let navigationBarHeight: CGFloat = 44 // 네비게이션바 기본 높이
        return (totalHeight - (safeAreaTop + navigationBarHeight)) / totalHeight
    }
    
    
    private func profileSection(geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.04) {
            Circle()
                .fill(Color(hex: "#E0E0E0"))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                )
            
            Text("사용자 이름")
                .font(.headline)
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: { isProfileEditModalPresented = true }) {
                CircleButton(iconName: "gearshape.fill")
            }
            
            Button(action: { isGuestBookModalPresented = true }) {
                CircleButton(iconName: "envelope.fill")
            }
        }
        .padding()
    }
    
    private func addFriendSection(geometry: GeometryProxy) -> some View {
        HStack {
            TextField("코드를 입력하세요", text: .constant(""))
                .padding()
                .background(Color(hex: "#F9F9F9"))
                .cornerRadius(21)
                .font(.body)
            
            Button(action: { /* 친구 추가 액션 */ }) {
                CircleButton(iconName: "magnifyingglass")
            }
        }
        .padding()
    }
    
    private func friendRow(friend: String, geometry: GeometryProxy) -> some View {
        HStack(spacing: geometry.size.width * 0.04) {
            Circle()
                .fill(Color(hex: "#E0E0E0"))
                .frame(width: 56, height: 56)
                .overlay(
                    Image(systemName: "person.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.gray)
                )
            
            Text(friend)
                .font(.body)
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: { /* 친구 방으로 이동 */ }) {
                CircleButton(iconName: "arrow.right")
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
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "#6DAFCF"))
                .frame(width: 56, height: 56)
            Image(systemName: iconName)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
        }
    }
}

// 방명록 모달
struct GuestBookModal: View {
    @Binding var isPresented: Bool
    
    @State private var guestBookEntries: [GuestBookEntry] = [
        GuestBookEntry(name: "친구1", message: "가구 내놔라"),
        GuestBookEntry(name: "친구2", message: "답장좀요"),
        GuestBookEntry(name: "친구3", message: "우리집이 더 나음")
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { isPresented = false }) {
                    Circle()
                        .fill(Color(hex: "#E0E0E0"))
                        .frame(width: 56, height: 56)
                        .overlay(
                            Image(systemName: "xmark")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                        )
                }
                Spacer()
            }
            .padding()
            
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(guestBookEntries) { entry in
                        HStack(spacing: 16) {
                            Circle()
                                .fill(Color(hex: "#E0E0E0"))
                                .frame(width: 56, height: 56)
                                .overlay(
                                    Image(systemName: "person.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.gray)
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
                                CircleButton(iconName: "play.fill")
                            }
                            
                            Button(action: { /* 답장 */ }) {
                                CircleButton(iconName: "arrowshape.turn.up.right.fill")
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(21)
                    }
                }
            }
            .padding()
        }
        .background(Color(hex: "#FFFDF7").ignoresSafeArea())
        .presentationDetents([.large])
        .presentationDragIndicator(.hidden)
    }
}

struct GuestBookEntry: Identifiable {
    let id = UUID()
    let name: String
    let message: String
}


struct ProfileEditModal: View {
    @Binding var isPresented: Bool
    @State private var navigateToLogin = false // 상태 변수 추가
    
    // 프로필 정보
    @State private var userName: String = UserDefaults.standard.string(forKey: "UserName") ?? "사용자 이름"
    @State private var profileImage: UIImage? = {
        if let imageData = UserDefaults.standard.data(forKey: "ProfileImage") {
            return UIImage(data: imageData)
        }
        return nil
    }()
    @State private var isImagePickerPresented: Bool = false
    
    // 일기 공개 여부
    @State private var isDiaryPublic: Bool = UserDefaults.standard.bool(forKey: "IsDiaryPublic")
    
    // 친구 코드 & 계정 정보
    @State private var friendCode: String = UserDefaults.standard.string(forKey: "FriendCode") ?? "1234-5678"
    @State private var accountInfo: String = UserDefaults.standard.string(forKey: "AccountInfo") ?? "연결된 계정 정보"
    
    var body: some View {
        CustomModal {
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
                .padding(.horizontal)
                
                // 기본 정보 섹션
                Section(title: "기본 정보") {
                    HStack(spacing: 16) {
                        // 프로필 사진
                        Button(action: { isImagePickerPresented = true }) {
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
                                Circle()
                                    .fill(Color(hex: "#E0E0E0"))
                                    .frame(width: 80, height: 80)
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .foregroundColor(.gray)
                                    )
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            // 이름 입력
                            TextField("이름", text: $userName)
                                .padding(8)
                                .background(Color(hex: "#F9F9F9"))
                                .cornerRadius(8)
                            
                            // 수정 완료 버튼
                            Button(action: saveProfile) {
                                Text("수정 완료")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(hex: "#6DAFCF"))
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                
                // 일기 공개 여부 섹션
                Section(title: "일기 공개 여부 설정") {
                    Toggle("음성 일기 친구에게 공개", isOn: $isDiaryPublic)
                        .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#6DAFCF")))
                        .onChange(of: isDiaryPublic) { newValue in
                            UserDefaults.standard.set(newValue, forKey: "IsDiaryPublic")
                        }
                }
                
                // 내 친구 코드 섹션
                Section(title: "내 친구 코드") {
                    Text(friendCode)
                        .font(.body)
                        .padding()
                        .background(Color(hex: "#F9F9F9"))
                        .cornerRadius(8)
                }
                
                // 계정 정보 섹션
                Section(title: "계정") {
                    Text(accountInfo)
                        .font(.body)
                        .padding()
                        .background(Color(hex: "#F9F9F9"))
                        .cornerRadius(8)
                }
                
                Spacer()
                
                
                // 로그아웃 버튼
                Button(action: {
                    navigateToLogin = true // 상태 변화로 화면 전환
                }) {
                    Text("로그아웃")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "#FFF0F0"))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
                // NavigationLink로 화면 전환 처리
                NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                    EmptyView()
                }
                
            }
            .padding()
            .sheet(isPresented: $isImagePickerPresented) {
                ImagePicker(image: $profileImage) { selectedImage in
                    saveProfileImage(selectedImage)
                }
            }
        }
    }
    
    // 프로필 저장 함수
    private func saveProfile() {
        UserDefaults.standard.set(userName, forKey: "UserName")
        print("사용자 이름 저장됨: \(userName)")
    }
    
    // 프로필 이미지 저장 함수
    private func saveProfileImage(_ image: UIImage) {
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "ProfileImage")
            profileImage = image
            print("프로필 이미지 저장됨")
        }
    }
    
    private func handleLogout() {
        print("로그아웃 버튼 클릭됨")
        UserDefaults.standard.removeObject(forKey: "UserName")
        UserDefaults.standard.removeObject(forKey: "ProfileImage")
        UserDefaults.standard.removeObject(forKey: "FriendCode")
        UserDefaults.standard.removeObject(forKey: "AccountInfo")
        UserDefaults.standard.removeObject(forKey: "IsDiaryPublic")
    }
}

struct Section<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color(hex: "#6DAFCF"))
            
            content
        }
        .padding(.horizontal)
    }
}

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

