//
//  MyHomeView.swift
//  Recordiary
//
//  Created by 김민아 on 11/5/24.
//

import SwiftUI

struct MyHomeView: View {
    @StateObject private var libraryViewModel = LibraryViewModel() // LibraryViewModel 사용
    @StateObject private var storageViewModel = StorageViewModel() // StorageViewModel 추가
    @State private var isLibrarySheetPresented = false // 모달 시트 상태
    @State private var isStorageSheetPresented = false // 보관함 모달 상태

    // 상태 변수
    @State private var showReaction = false // Reaction 표시 여부
    @State private var showRectangle = false // 사각형 표시 여부
    @State private var isPlaying = false // 재생 상태 저장

    var body: some View {
        ZStack {
            Color(hex: "#FFF8E1").ignoresSafeArea() // 배경색
            /*
            // 테스트용 버튼
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            NavigationLink(destination: LoginView()) {
                                Text("로그인 페이지로 이동")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "#6DAFCF"))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)

                            NavigationLink(destination: RegisterView()) {
                                Text("회원가입 페이지로 이동")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color(hex: "#6DAFCF"))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.bottom, 50) // 화면 하단 여백
                        
                        Spacer()
                    }
             */

            // 우측 상단 버튼들
            VStack(spacing: 16) {
                Button(action: { isLibrarySheetPresented = true }) {
                    Image(systemName: "cart")
                        .font(.system(size: 24))
                        .frame(width: 56, height: 56)
                        .background(Color.white)
                        .cornerRadius(21)
                        .shadow(color: Color(hex: "#6DAFCF"), radius: 0, x: 0, y: 4)
                }
                .sheet(isPresented: $isLibrarySheetPresented) {
                    CustomModal {
                        LibraryModalContent(isPresented: $isLibrarySheetPresented, viewModel: libraryViewModel)
                    }
                }

                Button(action: { isStorageSheetPresented = true }) {
                    Image(systemName: "tray")
                        .font(.system(size: 24))
                        .frame(width: 56, height: 56)
                        .background(Color.white)
                        .cornerRadius(21)
                        .shadow(color: Color(hex: "#6DAFCF"), radius: 0, x: 0, y: 4)
                }
                .sheet(isPresented: $isStorageSheetPresented) {
                    CustomModal {
                        StorageModalContent(isPresented: $isStorageSheetPresented, viewModel: storageViewModel)
                    }
                }
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

            // 중앙 녹음 버튼 및 관련 UI
            VStack {
                Spacer()

                if showRectangle {
                    rectangleView // 사각형 뷰
                } else if showReaction {
                    Image("radiobutton-reaction")
                        .resizable()
                        .frame(width: 328, height: 114)
                        .offset(y: -25) // 버튼 위로 25픽셀
                        .transition(.opacity)
                }

                // 녹음 버튼
                Button(action: handleRadioButtonTap) {
                    Image(
                        libraryViewModel.isRecording ? "radiobutton-recording" : "radiobutton-enabled"
                    )
                    .resizable()
                    .frame(width: 100, height: 100)
                }
                .padding(.bottom, 24)
            }
        }
    }

    // 사각형 뷰
    private var rectangleView: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 사각형 내부 콘텐츠
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        // 제목 박스
                        VStack(alignment: .leading) {
                            Text("음성 듣기")
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
                                        .fill(Color(hex: "#6DAFCF")) // 구분선 색상
                                        .frame(height: 0.33),
                                    alignment: .bottom // 하단에만 구분선 추가
                                )
                        )
                        Spacer()
                        Button(action: handleNextButtonTap) {
                            HStack(spacing: 4) {
                                Text("다음")
                                    .font(.system(size: 16, weight: .semibold))
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(Color(hex: "#999999"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(hex: "#FFFDF7"))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                    ZStack {
                        Button(action: { isPlaying.toggle() }) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: "#6DAFCF"))
                                    .frame(width: 56, height: 56)
                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    SectionView(title: "감정 추출 결과", content: "행복", hasContentBox: false, contentBoxStyle: .highlighted)
                    SectionView(title: "키워드 요약", content: "행복, 즐거움, 만족", hasContentBox: true, contentBoxStyle: .regular)
                    SectionView(title: "텍스트", content: "오늘은 정말 즐거운 하루였습니다.", hasContentBox: true, contentBoxStyle: .regular)
                }
                .padding(16)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 21)
                .fill(Color(hex: "#FFFDF7"))
                .shadow(color: .black.opacity(0.1), radius: 4, x: 2, y: 2)
        )
        .frame(width: 327, height: 381)
        .offset(y: -25)
        .transition(.opacity)
    }

    // 녹음 버튼 동작
    private func handleRadioButtonTap() {
        withAnimation {
            if showRectangle {
                showRectangle = false
                showReaction = true
            } else if showReaction {
                showReaction = false
                showRectangle = true
            } else {
                showReaction = true
            }
        }
        libraryViewModel.toggleRecording()
    }

    // "다음" 버튼 동작
    private func handleNextButtonTap() {
        withAnimation {
            showRectangle = false
            showReaction = false
        }
        libraryViewModel.isRecording = false // 녹음 종료
    }
}

struct LibraryModalContent: View {
    @Binding var isPresented: Bool // 모달 상태 바인딩
    @ObservedObject var viewModel: LibraryViewModel // ViewModel 참조
    let columns = [GridItem(.flexible()), GridItem(.flexible())] // 한 줄에 두 개의 아이템

    var body: some View {
        VStack(spacing: 16) {
            // 검색창과 닫기 버튼
            HStack {
                // 닫기 버튼
                Button(action: {
                    isPresented = false // 모달 닫기
                }) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "#E0E0E0"))
                            .frame(width: 44, height: 44) // 닫기 버튼 크기
                        Image(systemName: "xmark")
                            .font(.system(size: 20))
                            .foregroundColor(.white)
                    }
                }

                Spacer()

                // 검색창
                TextField("검색어를 입력하세요", text: $viewModel.searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.leading, 8)
            }
            .padding(.horizontal)

            // 필터 버튼
            HStack(spacing: 8) {
                Button(action: {
                    viewModel.filterMode = .all
                }) {
                    Text("전체")
                        .font(.headline)
                        .foregroundColor(viewModel.filterMode == .all ? .white : .black)
                        .frame(width: 70, height: 35)
                        .background(viewModel.filterMode == .all ? Color(hex: "#6DAFCF") : Color(hex: "#E0E0E0"))
                        .cornerRadius(8)
                }

                Button(action: {
                    viewModel.filterMode = .unowned
                }) {
                    Text("미보유")
                        .font(.headline)
                        .foregroundColor(viewModel.filterMode == .unowned ? .white : .black)
                        .frame(width: 70, height: 35)
                        .background(viewModel.filterMode == .unowned ? Color(hex: "#6DAFCF") : Color(hex: "#E0E0E0"))
                        .cornerRadius(8)
                }

                Spacer()
            }
            .padding(.horizontal)

            // 가구 정보 그리드
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.filteredItems, id: \.id) { item in
                        VStack(alignment: .leading, spacing: 8) { // 왼쪽 정렬
                            // 가구 이미지
                            Rectangle()
                                .fill(.white)
                                .frame(height: 108)
                                .overlay(
                                    Image(systemName: "photo") // 기본 이미지는 SF Symbol로 대체
                                        .resizable()
                                        .scaledToFit()
                                        .foregroundColor(Color(hex: "#E0E0E0"))
                                        .padding(16)
                                )
                            
                            // 가구 이름
                            Text(item.display_name)
                                .font(.system(size: 16, weight: .bold)) // 볼드
                                .foregroundColor(viewModel.isOwned(item: item) ? .white : .black)

                            // 보유 수량
                            if viewModel.isOwned(item: item) {
                                Text("보유: \(item.quantity)")
                                    .font(.system(size: 14, weight: .semibold)) // 세미볼드
                                    .foregroundColor(.white)
                            } else {
                                Text("미보유")
                                    .font(.system(size: 14, weight: .semibold)) // 세미볼드
                                    .foregroundColor(.black)
                            }
                        }
                        .padding() // 내부 여백
                        .background(
                            viewModel.isOwned(item: item) ? Color(hex: "#6DAFCF") : Color(hex: "#E0E0E0")
                        )
                        .cornerRadius(21)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 2, y: 2)
                    }
                }
                .padding()
            }
        }
        .background(Color(hex: "#FFFDF7").ignoresSafeArea()) // 모달 배경색
        .presentationDetents([.medium, .large]) // 중형 & 대형 디텐트 설정
        .presentationDragIndicator(.hidden) // 기본 드래그 인디케이터 숨기기
    }
}

struct StorageModalContent: View {
    @Binding var isPresented: Bool // 모달 상태 바인딩
    @ObservedObject var viewModel: StorageViewModel // 부모 뷰에서 전달된 ViewModel
    @State private var showAlert = false // 경고창 표시 여부
    @State private var itemToDelete: DiaryConnectedFurniture? // 삭제할 가구

    var body: some View {
        VStack(spacing: 16) {
            // 상단 버튼
            HStack {
                if !viewModel.showDetails {
                    // 닫기 버튼
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
                }
                Spacer()
            }
            .padding(.horizontal)

            // 콘텐츠
            if viewModel.showDetails, let furniture = viewModel.selectedFurniture {
                // 가구 상세 정보
                StorageFurnitureDetailView(
                    furniture: furniture,
                    onBack: { viewModel.backToList() } // 리스트로 돌아가기
                )
            } else {
                // 가구 리스트
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(viewModel.items) { item in
                            HStack(spacing: 16) {
                                Button(action: {
                                    viewModel.selectFurniture(item) // 가구 선택
                                }) {
                                    // 아이템 이미지 및 정보
                                    HStack(spacing: 16) {
                                        RoundedRectangle(cornerRadius: 21)
                                            .fill(Color(hex: "#E0E0E0"))
                                            .frame(width: 56, height: 56)
                                            .overlay(
                                                Image(systemName: "photo")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .foregroundColor(.gray)
                                                    .padding(8)
                                            )

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(item.furniture.display_name) // 가구 이름
                                                .font(.system(size: 15, weight: .semibold))
                                                .foregroundColor(.black)
                                            Text(item.diary.local_date) // 일기 작성 날짜
                                                .font(.system(size: 14, weight: .medium))
                                                .foregroundColor(.gray)
                                        }

                                        Spacer()
                                    }
                                }

                                // 우측 추가 및 삭제 버튼
                                HStack(spacing: 8) {
                                    Button(action: {
                                        // 추가 버튼: 현재 동작 없음
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 21)
                                                .fill(Color(hex: "#6DAFCF"))
                                                .frame(width: 56, height: 56)
                                            Image(systemName: "plus")
                                                .font(.system(size: 32))
                                                .foregroundColor(.white)
                                        }
                                    }

                                    Button(action: {
                                        // 삭제 버튼 동작
                                        itemToDelete = item
                                        showAlert = true
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 21)
                                                .fill(Color(hex: "#FF6F61"))
                                                .frame(width: 56, height: 56)
                                            Image(systemName: "trash")
                                                .font(.system(size: 32))
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                            }
                            .padding()
                            .background(Color.white) // 아이템 배경
                            .cornerRadius(21)
                            .frame(height: 88)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("\(itemToDelete?.furniture.display_name ?? "가구")를 삭제하시겠습니까?"),
                message: Text("삭제된 가구는 라이브러리에 추가되며,\n음성은 달력 탭에서 확인할 수 있습니다."),
                primaryButton: .destructive(Text("삭제"), action: {
                    if let item = itemToDelete {
                        viewModel.deleteItem(item) // 삭제
                        itemToDelete = nil // 초기화
                    }
                }),
                secondaryButton: .cancel(Text("취소"), action: {
                    itemToDelete = nil // 초기화
                })
            )
        }
    }
}



struct StorageFurnitureDetailView: View {
    let furniture: DiaryConnectedFurniture // 가구 정보
    let onBack: () -> Void   // 뒤로가기 동작

    var body: some View {
        VStack(spacing: 16) {
            // 상단 헤더: 이전 버튼
            HStack {
                Button(action: {
                    onBack() // 리스트로 돌아가기
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "#999999")) // 화살표 색
                        Text("이전")
                            .font(.system(size: 20, weight: .semibold)) // 글씨 크기 및 스타일
                            .foregroundColor(Color(hex: "#999999"))
                    }
                }
                Spacer()
            }
            .padding(.horizontal)

            // 상세 정보 콘텐츠
            FurnitureDetailContent(detailedFurniture: furniture)

            Spacer() // 하단 여백 추가로 상단 고정
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top) // 상단 정렬
        .background(Color(hex: "#FFFDF7").ignoresSafeArea()) // 배경 설정
    }
}
