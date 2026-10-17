import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nhan_su/models/app_data.dart';
import 'package:quan_ly_nhan_su/main.dart';

void main() {
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

    // Kiểm tra hiển thị nhân viên mẫu
    expect(find.text('Nguyễn Văn An'), findsOneWidget);
    expect(find.text('Trần Thị Bích'), findsOneWidget);
    expect(find.text('Tổng số nhân viên: 5'), findsOneWidget);

    // Thử tìm kiếm theo tên
    await tester.enterText(find.byType(TextField).first, 'Bích');
    await tester.pumpAndSettle();

    expect(find.text('Trần Thị Bích'), findsOneWidget);
    expect(find.text('Nguyễn Văn An'), findsNothing);
    expect(find.text('Kết quả: 1'), findsOneWidget);
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

    // 1. Kiểm tra Dashboard: Thẻ thống kê từ .length của các Map
    expect(find.text('Tổng Quan Nhân Sự (Dashboard)'), findsOneWidget);
    expect(find.text('Tổng Nhân Viên'), findsOneWidget);
    expect(find.text('Tổng Chức Vụ'), findsOneWidget);
    expect(find.text('Đã Phân Công'), findsOneWidget);
    expect(find.text('Chưa Phân Công'), findsOneWidget);

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
}
