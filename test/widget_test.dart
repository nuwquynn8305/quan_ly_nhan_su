import 'package:flutter_test/flutter_test.dart';
import 'package:quan_ly_nhan_su/main.dart';

void main() {
  testWidgets('App renders correctly smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QuanLyNhanSuApp());
    expect(find.text('Trang chủ'), findsWidgets);
    expect(find.text('Nhân viên'), findsWidgets);
    expect(find.text('Chức vụ'), findsWidgets);
  });
}
