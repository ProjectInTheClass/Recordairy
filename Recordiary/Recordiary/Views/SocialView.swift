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
    @StateObject private var viewModel = SocialViewModel()
    @StateObject private var profile = Profile(userName: "사용자 이름") // 초기 값 설정
    
    var body: some View {
        ZStack {
            Color(hex: "#FFF8E1").ignoresSafeArea()
            ScrollView{
                VStack(alignment: .leading, spacing: 20) {
                    // 내 프로필 섹션
                    SectionHeader(title: "내 프로필")
                    RoundedRectangle(cornerRadius: 21)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .frame(height: 88) // 높이 지정
                        .overlay(profileSection())
                    
                    // 코드로 친구 추가 섹션
                    SectionHeader(title: "코드로 친구 추가")
                    RoundedRectangle(cornerRadius: 21)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                        .frame(height: 88) // 높이 지정
                        .overlay(addFriendSection())
                    
                    // 친구 리스트 섹션
                    SectionHeader(title: "친구 리스트")
                    ForEach(Array(viewModel.friends.enumerated()), id: \.offset) { index, friend in
                        RoundedRectangle(cornerRadius: 21)
                            .fill(Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            .frame(height: 88) // 높이 지정
                            .overlay(friendRow(friend: friend, index: index))
                    }
                    Spacer()
                }
                .padding(16)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isProfileEditModalPresented) {
            ProfileEditModal(isPresented: $isProfileEditModalPresented, profile: profile)
                .presentationDetents([.large]) //  대형 디텐트
        }
        .sheet(isPresented: $isGuestBookModalPresented) {
            GuestBookModal(isPresented: $isGuestBookModalPresented)
                .presentationDetents([.large]) // 대형 디텐트
        }
    }
    
    private func profileSection() -> some View {
        HStack(spacing: 16) {
            if let image = profile.profileImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
            } else {
                Circle()
                    .fill(Color(hex: "#E0E0E0"))
                    .frame(width: 56, height: 56)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.gray)
                    )
            }
            
            Text(profile.userName)
                .font(.headline)
                .foregroundColor(.black)
            
            Spacer()
            
            Button(action: { isProfileEditModalPresented = true }) {
                RectButton(iconName: "gear")
            }
            
            Button(action: { isGuestBookModalPresented = true }) {
                RectButton(iconName: "envelope")
            }
        }
        .padding()
    }
    
    private func addFriendSection() -> some View {
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
    
    private func friendRow(friend: String, index: Int) -> some View {
        HStack(spacing: 16) {
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
                RectButton(iconName: "arrowshape.turn.up.right")
            }
        }
        .padding()
    }
}


private struct SectionHeader: View {
    let title: String
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(Color(hex: "#2C3E50"))
                .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 상단 정렬
        }
        .frame(height: 30) // 제목 박스 높이
        .background(
            Rectangle()
                .fill(Color.clear) // 투명 배경
                .frame(height: 30) // 구분선 높이
                .overlay(
                    Rectangle()
                        .fill(Color(hex: "#2C3E50")) // 구분선 색상
                        .frame(height: 0.33),
                    alignment: .bottom // 하단에만 구분선 추가
                )
        )
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
                .font(.system(size: 24))
                .frame(width: 56, height: 56)
                .foregroundColor(.white)
        }
    }
}

private struct RectButton: View {
    let iconName: String
    
    var body: some View {
        Image(systemName: iconName)
            .font(.system(size: 32))
            .frame(width: 56, height: 56)
            .foregroundColor(.white)
            .background(Color(hex: "#6DAFCF"))
            .cornerRadius(21)
    }
}

// 방명록 모달
struct GuestBookModal: View {
    @StateObject private var playbackViewModel = AudioPlaybackViewModel()
    @Binding var isPresented: Bool
    
    @State private var guestBookEntries: [GuestBookEntry] = [
        GuestBookEntry(name: "지나가는 나그네", message: "가구 내놔라",profileImageName: "p1"),
        GuestBookEntry(name: "팽현숙", message: "답장좀요",profileImageName: "p2"),
        GuestBookEntry(name: "치즈", message: "우리집이 더 나음",profileImageName: "p3"),
        GuestBookEntry(name: "김철수", message: "오늘도 좋은 하루 되세요!",profileImageName: "p4"),
        GuestBookEntry(name: "이유진", message: "오랜만에 방명록 남겨요 😊",profileImageName: "p5"),
        GuestBookEntry(name: "햇님", message: "여기 너무 예쁘네요!",profileImageName: "p6"),
        GuestBookEntry(name: "별빛", message: "따뜻한 일기가 느껴져요.",profileImageName: "p7"),
        GuestBookEntry(name: "고구마", message: "친구 방명록은 처음이네요~",profileImageName: "p8"),
        GuestBookEntry(name: "하늘색", message: "좋은 소식 있으면 알려주세요!",profileImageName: "p9"),

    ]

    
    var body: some View {
        CustomModal{
            VStack(spacing: 16) {
                HStack {
                    Button(action: { isPresented = false }) {
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
                
                ScrollView {
                    VStack(spacing: 12) { // 블록 간격을 동일하게
                        ForEach(guestBookEntries) { entry in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color(hex: "#E0E0E0"))
                                    .frame(width: 56, height: 56)
                                    .overlay(
                                        Image(entry.profileImageName)
                                            .resizable()
                                            .scaledToFill()
                                            .clipShape(Circle())
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
                                    let audioURL = URL(string: "https://example.com/audio5.mp3")!
                                    ReusablePlayButton(viewModel: playbackViewModel, audioURL: audioURL)
                                }
                                Button(action: { /* 답장 */ }) {
                                    RectButton(iconName: "arrowshape.turn.up.right")
                                }
                            }
                            .frame(height: 88) // 각 블록 높이 고정
                            .padding(.horizontal, 12) // 전체 패딩 정리
                            .background(Color.white)
                            .cornerRadius(21)
                            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.vertical, 8) // 상하 여백만 적용
                }

               /* ScrollView {
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
                                    let audioURL = URL(string: "https://example.com/audio5.mp3")!
                                    ReusablePlayButton(viewModel: playbackViewModel, audioURL: audioURL)
                                }
                                
                                Button(action: { /* 답장 */ }) {
                                    RectButton(iconName: "arrowshape.turn.up.right")
                                }
                            }
                            .padding(.horizontal)
                            .background(Color.white)
                            .cornerRadius(21)
                        }
                    }
                }*/
                .padding(.horizontal)
            }
            .padding(.horizontal)
        }
        .background(Color(hex: "#FFFDF7").ignoresSafeArea())
    }
}

struct GuestBookEntry: Identifiable {
    let id = UUID()
    let name: String
    let message: String
    let profileImageName: String // 프로필 이미지 이름
}


struct ProfileEditModal: View {
    @Binding var isPresented: Bool
    @ObservedObject var profile: Profile // 공유된 프로필 객체
    
    @State private var navigateToLogin = false
    @State private var showLogoutAlert = false // 로그아웃 확인용
    
    // 프로필 정보
    @State private var newName: String
    @State private var newProfileImage: UIImage?
    @State private var isImagePickerPresented = false
    
    init(isPresented: Binding<Bool>, profile: Profile) {
        self._isPresented = isPresented
        self.profile = profile
        self._newName = State(initialValue: profile.userName)
        self._newProfileImage = State(initialValue: profile.profileImage)
    }
    
    // 일기 공개 여부
    @State private var isDiaryPublic: Bool = UserDefaults.standard.bool(forKey: "IsDiaryPublic")
    
    // 친구 코드 & 계정 정보
    @State private var friendCode: String = UserDefaults.standard.string(forKey: "FriendCode") ?? "1234-5678"
    @State private var accountInfo: String = UserDefaults.standard.string(forKey: "AccountInfo") ?? "연결된 계정 정보"
    
    var body: some View {
        CustomModal{
            VStack(spacing: 16) {
                // 닫기 버튼
                HStack {
                    Button(action: { isPresented = false }) {
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
                
                // ScrollView로 스크롤 가능하도록 변경
                ScrollView {
                    VStack(spacing: 16) {
                        // 기본 정보 섹션
                        profileSection
                        
                        // 일기 공개 여부 섹션
                        settingSection(title: "일기 공개 여부 설정") {
                            ZStack{
                                RoundedRectangle(cornerRadius: 21)
                                    .fill(.white)
                                    .frame(height: 63)
                                Toggle("음성 일기 친구에게 공개", isOn: $isDiaryPublic)
                                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "#6DAFCF")))
                                    .onChange(of: isDiaryPublic) { newValue in
                                        UserDefaults.standard.set(newValue, forKey: "IsDiaryPublic")
                                    }
                                    .padding(.horizontal)
                            }
                        }
                        
                        // 내 친구 코드 섹션
                        settingSection(title: "내 친구 코드") {
                            Text(friendCode)
                                .font(.body)
                                .padding()
                                .background(.white)
                                .cornerRadius(8)
                            
                        }
                        
                        
                        // 계정 정보 섹션
                        settingSection(title: "계정") {
                            Text(accountInfo)
                                .font(.body)
                                .padding()
                                .background(.white)
                                .cornerRadius(8)
                        }
                    }
                    // 로그아웃 버튼
                    Button(action: { showLogoutAlert = true }) {
                        Text("로그아웃")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
            }
            
        }
    }
    
    private func saveChanges() {
        profile.userName = newName
        profile.profileImage = newProfileImage
        isPresented = false
    }
    
    private func handleLogout() {
        print("로그아웃 처리")
        UserDefaults.standard.removeObject(forKey: "UserName")
        UserDefaults.standard.removeObject(forKey: "ProfileImage")
        UserDefaults.standard.removeObject(forKey: "FriendCode")
        UserDefaults.standard.removeObject(forKey: "AccountInfo")
        UserDefaults.standard.removeObject(forKey: "IsDiaryPublic")
    }
    
    // 섹션 생성 공통 뷰
    private func settingSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack{
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color(hex: "#6DAFCF"))
                    .frame(maxWidth: .infinity, alignment: .leading) // 왼쪽 상단 정렬
            }
            .frame(height: 30) // 제목 박스 높이
            .background(
                Rectangle()
                    .fill(Color.clear) // 투명 배경
                    .frame(height: 30) // 구분선 높이
                    .overlay(
                        Rectangle()
                            .fill(Color(hex: "#2C3E50")) // 구분선 색상
                            .frame(height: 0.33),
                        alignment: .bottom // 하단에만 구분선 추가
                    )
            )
            content()
        }
        .padding(.horizontal)
    }
    
    private var profileSection: some View {
        settingSection(title: "기본 정보") {
            HStack(spacing: 16) {
                Button(action: { isImagePickerPresented = true }) {
                    if let newProfileImage = newProfileImage {
                        Image(uiImage: newProfileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
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
                    TextField("이름", text: $newName)
                        .padding(8)
                        .background(Color(hex: "#F9F9F9"))
                        .cornerRadius(8)
                    Button(action: saveChanges) {
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
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker(image: $newProfileImage) { image in
                newProfileImage = image
            }
        }
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

