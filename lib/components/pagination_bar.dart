import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int startIndex;
  final int endIndex;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.startIndex,
    required this.endIndex,
    required this.onPageChanged,
    this.onPrevious,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (totalItems == 0) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // แถวปุ่มเปลี่ยนหน้าและปุ่มนำทาง
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ปุ่มย้อนกลับ (หน้าก่อนหน้า)
                _buildNavButton(
                  icon: Icons.chevron_left_rounded,
                  tooltip: 'หน้าก่อนหน้า',
                  isEnabled: currentPage > 1,
                  onTap: onPrevious,
                ),
                const SizedBox(width: 8),

                // ปุ่มหมายเลขหน้า
                ..._buildPageNumbers(context),

                const SizedBox(width: 8),
                // ปุ่มถัดไป (หน้าถัดไป)
                _buildNavButton(
                  icon: Icons.chevron_right_rounded,
                  tooltip: 'หน้าถัดไป',
                  isEnabled: currentPage < totalPages,
                  onTap: onNext,
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ข้อความสรุปจำนวนรายการ
            Text(
              'แสดง $startIndex - $endIndex จาก $totalItems รายการ (หน้า $currentPage จาก $totalPages)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String tooltip,
    required bool isEnabled,
    required VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isEnabled ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isEnabled ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? const Color(0xFF334155) : const Color(0xFF94A3B8),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers(BuildContext context) {
    final widgets = <Widget>[];

    if (totalPages <= 5) {
      for (int i = 1; i <= totalPages; i++) {
        widgets.add(_buildPageButton(i));
        if (i < totalPages) widgets.add(const SizedBox(width: 6));
      }
      return widgets;
    }

    // กรณีจำนวนหน้าทั้งหมดมากกว่า 5 หน้า
    List<int> pages;
    bool showLeftDots = false;
    bool showRightDots = false;

    if (currentPage <= 3) {
      pages = [1, 2, 3];
      showRightDots = true;
    } else if (currentPage >= totalPages - 2) {
      pages = [totalPages - 2, totalPages - 1, totalPages];
      showLeftDots = true;
    } else {
      pages = [currentPage];
      showLeftDots = true;
      showRightDots = true;
    }

    if (showLeftDots) {
      widgets.add(_buildPageButton(1));
      widgets.add(const SizedBox(width: 6));
      widgets.add(_buildEllipsis(context));
      widgets.add(const SizedBox(width: 6));
    }

    for (int i = 0; i < pages.length; i++) {
      widgets.add(_buildPageButton(pages[i]));
      if (i < pages.length - 1) widgets.add(const SizedBox(width: 6));
    }

    if (showRightDots) {
      widgets.add(const SizedBox(width: 6));
      widgets.add(_buildEllipsis(context));
      widgets.add(const SizedBox(width: 6));
      widgets.add(_buildPageButton(totalPages));
    }

    return widgets;
  }

  Widget _buildPageButton(int pageNumber) {
    final isSelected = pageNumber == currentPage;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onPageChanged(pageNumber),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFCBD5E1),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            '$pageNumber',
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : const Color(0xFF334155),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEllipsis(BuildContext context) {
    return InkWell(
      onTap: () => _showJumpToPageDialog(context),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 36,
        alignment: Alignment.center,
        child: const Text(
          '...',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  void _showJumpToPageDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('ไปยังหน้า', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ระบุหมายเลขหน้าระหว่าง 1 ถึง $totalPages'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '1 - $totalPages',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () {
                final page = int.tryParse(controller.text.trim());
                if (page != null && page >= 1 && page <= totalPages) {
                  Navigator.pop(dialogContext);
                  onPageChanged(page);
                }
              },
              child: const Text('ตกลง'),
            ),
          ],
        );
      },
    );
  }
}
