import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_nhan_su/models/app_data.dart';
import 'package:quan_ly_nhan_su/main.dart';

void main() {
  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider(
      create: (_) => AppData(),
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
}
