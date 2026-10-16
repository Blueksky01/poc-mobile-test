import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onClearFilter;

  const EmptyStateView({
    super.key,
    this.title = 'ไม่พบข้อมูลพนักงาน',
    this.message = 'ลองเปลี่ยนคำค้นหา หรือรีเซ็ตตัวกรองแผนกเพื่อดูรายการทั้งหมด',
    this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            if (onClearFilter != null) ...[
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: onClearFilter,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('ล้างการค้นหาและตัวกรอง'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).primaryColor,
                  side: BorderSide(color: Theme.of(context).primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
