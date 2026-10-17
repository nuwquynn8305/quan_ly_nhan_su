import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:quan_ly_nhan_su/models/app_data.dart';
import 'package:quan_ly_nhan_su/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest({AppData? appData}) {
    return ChangeNotifierProvider(
      create: (_) => appData ?? AppData(),
      child: const QuanLyNhanSuApp(),
    );
  }

  testWidgets('Chuyển tab Quản lý Nhân viên và hiển thị danh sách', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Chuyển sang Tab Nhân viên
    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pumpAndSettle();

    // Kiểm tra hiển thị nhân viên mẫu ở đầu danh sách
    expect(find.text('Lê Hoàng Cường'), findsOneWidget);
    expect(find.text('Nguyễn Văn An'), findsOneWidget);
    expect(find.text('Tổng số nhân viên: 5'), findsOneWidget);

    // Thử tìm kiếm theo tên
    await tester.enterText(find.byType(TextField).first, 'Bích');
    await tester.pumpAndSettle();

    expect(find.text('Trần Thị Bích'), findsOneWidget);
    expect(find.text('Nguyễn Văn An'), findsNothing);
    expect(find.text('Hiển thị: 1'), findsOneWidget);
  });

  testWidgets('Chuyển tab Quản lý Chức vụ, hiển thị danh sách và kiểm tra cảnh báo xóa', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Chuyển sang Tab Chức vụ
    await tester.tap(find.byIcon(Icons.badge_outlined));
    await tester.pumpAndSettle();

    // Kiểm tra hiển thị 3 chức vụ mẫu
    expect(find.text('Giám đốc'), findsOneWidget);
    expect(find.text('Trưởng phòng'), findsOneWidget);
    expect(find.text('Nhân viên'), findsWidgets);
    expect(find.text('Tổng số chức vụ: 3'), findsOneWidget);

    // Bấm nút xóa chức vụ Giám đốc (đang có NV01 giữ) -> phải hiển thị cảnh báo
    final deleteButtons = find.byIcon(Icons.delete_outline);
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('Cảnh báo gỡ chức vụ'), findsOneWidget);
    expect(find.text('Gỡ gán & Xóa'), findsOneWidget);

    // Bấm Gỡ gán & Xóa
    await tester.tap(find.text('Gỡ gán & Xóa'));
    await tester.pumpAndSettle();

    // Số chức vụ còn 2
    expect(find.text('Tổng số chức vụ: 2'), findsOneWidget);
    expect(find.text('Giám đốc'), findsNothing);
  });

  testWidgets('Dashboard và Gán chức vụ, xóa NV xóa luôn bản ghi trong phanCong', (tester) async {
    final appData = AppData();
    await tester.pumpWidget(createWidgetUnderTest(appData: appData));
    await tester.pumpAndSettle();

    // 1. Kiểm tra Dashboard: Thẻ thống kê từ .length của các Map và Biểu đồ
    expect(find.text('Tổng Quan Nhân Sự (Dashboard)'), findsOneWidget);
    expect(find.text('Tổng Nhân Viên'), findsOneWidget);
    expect(find.text('Tổng Chức Vụ'), findsOneWidget);
    expect(find.text('Đã Phân Công'), findsOneWidget);
    expect(find.text('Chưa Phân Công'), findsOneWidget);
    expect(find.text('Biểu đồ phân bổ theo Giới tính'), findsOneWidget);
    expect(find.text('Biểu đồ số NV theo Chức vụ'), findsOneWidget);

    // 2. Chuyển sang Tab Gán chức vụ
    await tester.tap(find.byIcon(Icons.assignment_ind_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Gán Chức Vụ'), findsOneWidget);
    expect(find.text('Phân công chức vụ cho nhân viên'), findsOneWidget);
    expect(find.text('Gán'), findsOneWidget);
    expect(find.text('Đã gán: 5/5'), findsOneWidget);

    // Gỡ chức vụ của một nhân viên bằng nút gỡ nhanh
    final removeAssignButtons = find.byIcon(Icons.person_remove_outlined);
    expect(removeAssignButtons, findsWidgets);
    await tester.tap(removeAssignButtons.first);
    await tester.pumpAndSettle();

    // Kiểm tra số lượng phân công giảm còn 4/5
    expect(find.text('Đã gán: 4/5'), findsOneWidget);
    expect(appData.phanCong.length, 4);

    // 3. Kiểm tra: Khi xóa NV -> xóa luôn bản ghi trong phanCong
    expect(appData.phanCong.containsKey('NV02'), true);
    appData.xoaNhanVien('NV02');
    expect(appData.phanCong.containsKey('NV02'), false);
    expect(appData.danhSachNhanVien.any((nv) => nv.id == 'NV02'), false);
  });

  testWidgets('Settings: Switch dark mode, chọn màu CircleAvatar, Slider cỡ chữ', (tester) async {
    final appData = AppData();
    await tester.pumpWidget(createWidgetUnderTest(appData: appData));
    await tester.pumpAndSettle();

    // Chuyển sang Tab Cài đặt (Tab 5)
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Cài đặt Giao diện'), findsOneWidget);
    expect(find.text('Chế độ nền tối (Dark Mode)'), findsOneWidget);
    expect(find.text('Màu sắc chủ đạo'), findsOneWidget);
    expect(find.text('Kích thước chữ'), findsOneWidget);

    // 1. Thử bật Switch Dark mode
    expect(appData.isDarkMode, false);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(appData.isDarkMode, true);

    // 2. Thử chọn màu sắc (ví dụ: Xanh lá)
    expect(find.text('Xanh lá'), findsOneWidget);
    await tester.tap(find.text('Xanh lá'));
    await tester.pumpAndSettle();
    expect(appData.primaryColor, Colors.green);

    // 3. Thử điều chỉnh Slider cỡ chữ
    final sliderFinder = find.byType(Slider);
    expect(sliderFinder, findsOneWidget);
    await tester.tap(sliderFinder);
    await tester.pumpAndSettle();

    // 4. Cuộn xuống và bấm nút Khôi phục cài đặt mặc định
    await tester.drag(find.byType(ListView).last, const Offset(0, -400));
    await tester.pumpAndSettle();

    final resetButton = find.text('Khôi phục cài đặt mặc định');
    expect(resetButton, findsOneWidget);
    await tester.tap(resetButton);
    await tester.pumpAndSettle();

    expect(appData.isDarkMode, false);
    expect(appData.primaryColor, Colors.indigo);
    expect(appData.fontSizeScale, 1.0);
  });

  testWidgets('Chức năng mở rộng: Tính lương, Xuất CSV, Bộ lọc & Sắp xếp', (tester) async {
    final appData = AppData();
    await tester.pumpWidget(createWidgetUnderTest(appData: appData));
    await tester.pumpAndSettle();

    // Kiểm tra tính toán lương & quỹ lương
    expect(appData.tinhTongQuyLuong(), greaterThan(0));
    final nv01 = appData.getNhanVienById('NV01');
    expect(nv01, isNotNull);
    expect(appData.tinhLuongNhanVien(nv01!), equals(40000000.0)); // Giám đốc: (10tr * 3.5) + 5tr = 40tr

    // Kiểm tra xuất CSV
    final csv = appData.xuatDanhSachCSV();
    expect(csv.contains('Mã NV,Họ và Tên'), true);
    expect(csv.contains('Nguyễn Văn An'), true);

    // Mở Tab Quản lý nhân viên để thử Bộ lọc & Sắp xếp
    await tester.tap(find.byIcon(Icons.people_outline));
    await tester.pumpAndSettle();

    // Mở Dialog Xuất CSV
    await tester.tap(find.byIcon(Icons.file_download_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Xuất Danh Sách CSV'), findsOneWidget);
    expect(find.text('Sao chép CSV'), findsOneWidget);

    await tester.tap(find.text('Đóng'));
    await tester.pumpAndSettle();

    // Mở Bộ lọc & Sắp xếp
    await tester.tap(find.byIcon(Icons.filter_list));
    await tester.pumpAndSettle();

    expect(find.text('Bộ lọc & Sắp xếp'), findsOneWidget);
    // Chọn lọc Nữ
    await tester.tap(find.text('Nữ'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Áp dụng bộ lọc'), warnIfMissed: false);
    await tester.pumpAndSettle();

    // Danh sách còn 2 người (Trần Thị Bích, Võ Thị Hồng)
    expect(find.text('Hiển thị: 2'), findsOneWidget);
    expect(find.text('Trần Thị Bích'), findsOneWidget);
    expect(find.text('Võ Thị Hồng'), findsOneWidget);
    expect(find.text('Nguyễn Văn An'), findsNothing);
  });
}
