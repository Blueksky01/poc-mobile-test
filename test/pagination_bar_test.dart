import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mypoc1/components/pagination_bar.dart';

void main() {
  testWidgets('PaginationBar displays correct page info and responds to tap', (WidgetTester tester) async {
    int selectedPage = 1;
    bool previousTapped = false;
    bool nextTapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PaginationBar(
            currentPage: 2,
            totalPages: 5,
            totalItems: 48,
            startIndex: 11,
            endIndex: 20,
            onPageChanged: (page) => selectedPage = page,
            onPrevious: () => previousTapped = true,
            onNext: () => nextTapped = true,
          ),
        ),
      ),
    );

    // ควรแสดงข้อความสรุปรายการ
    expect(find.text('แสดง 11 - 20 จาก 48 รายการ (หน้า 2 จาก 5)'), findsOneWidget);

    // ควรแสดงปุ่มหน้า 1, 2, 3, 4, 5
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    // กดเลือกหน้าที่ 3
    await tester.tap(find.text('3'));
    await tester.pump();
    expect(selectedPage, 3);

    // กดปุ่มย้อนกลับ
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pump();
    expect(previousTapped, true);

    // กดปุ่มถัดไป
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pump();
    expect(nextTapped, true);
  });

  testWidgets('PaginationBar handles ellipses and jump-to-page dialog when totalPages > 5', (WidgetTester tester) async {
    int selectedPage = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PaginationBar(
            currentPage: 1,
            totalPages: 10,
            totalItems: 100,
            startIndex: 1,
            endIndex: 10,
            onPageChanged: (page) => selectedPage = page,
          ),
        ),
      ),
    );

    // ควรแสดงจุดไข่ปลา (...)
    expect(find.text('...'), findsOneWidget);

    // กดจุดไข่ปลาเพื่อเปิด Dialog ไปยังหน้าที่ต้องการ
    await tester.tap(find.text('...'));
    await tester.pumpAndSettle();

    expect(find.text('ไปยังหน้า'), findsOneWidget);
    expect(find.text('ระบุหมายเลขหน้าระหว่าง 1 ถึง 10'), findsOneWidget);

    // กรอกหมายเลขหน้า 7 แล้วกดยืนยัน
    await tester.enterText(find.byType(TextField), '7');
    await tester.tap(find.text('ตกลง'));
    await tester.pumpAndSettle();

    expect(selectedPage, 7);
  });
}
