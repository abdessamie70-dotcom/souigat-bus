import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/driver_model.dart';
import '../theme/app_colors.dart';

class PdfReportService {
  static const List<String> monthNames = [
    '',
    'جانفي',
    'فيفري',
    'مارس',
    'أفريل',
    'ماي',
    'جوان',
    'جويلية',
    'أوت',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر'
  ];

  static const List<String> weekdayArabic = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static String _getDayName(int year, int month, int day) {
    final dt = DateTime(year, month, day);
    return weekdayArabic[dt.weekday - 1];
  }

  static String _cleanBusPlate(String plate) {
    if (plate.contains('(')) {
      return plate.split('(').first.trim();
    }
    return plate.trim();
  }

  /// Load Arabic fonts (first tries bundled local asset, falls back to GoogleFonts)
  static Future<pw.ThemeData> _loadTheme() async {
    pw.Font? regular;
    pw.Font? bold;

    try {
      final regData = await rootBundle.load('assets/fonts/Amiri-Regular.ttf');
      regular = pw.Font.ttf(regData);
    } catch (_) {}

    try {
      final boldData = await rootBundle.load('assets/fonts/Amiri-Bold.ttf');
      bold = pw.Font.ttf(boldData);
    } catch (_) {}

    // Fallbacks if bundle is not ready
    try {
      regular ??= await PdfGoogleFonts.amiriRegular();
      bold ??= await PdfGoogleFonts.amiriBold();
    } catch (_) {}

    return pw.ThemeData.withFont(
      base: regular,
      bold: bold,
    );
  }

  /// Generate complete, pixel-perfect Driver Monthly Statement PDF
  static Future<Uint8List> generateDriverReportPdf({
    required DriverModel driver,
    required int month,
    required int year,
  }) async {
    final theme = await _loadTheme();
    final pdf = pw.Document(theme: theme);

    final int daysInMonth = DateTime(year, month + 1, 0).day;
    final int workDays = driver.workDaysCount;
    final int restDays = driver.restDaysCount;
    final int absenceDays = driver.absenceDaysCount;
    final String cleanPlate = _cleanBusPlate(driver.assignedBus);

    // Color definitions
    const pdfDarkBlue = PdfColor.fromInt(0xFF1E3A8A);
    const pdfRoyalBlue = PdfColor.fromInt(0xFF2563EB);
    const pdfTextPrimary = PdfColor.fromInt(0xFF0F172A);
    const pdfTextSecondary = PdfColor.fromInt(0xFF475569);
    const pdfBorder = PdfColor.fromInt(0xFFCBD5E1);
    const pdfBgLight = PdfColor.fromInt(0xFFF8FAFC);
    const pdfGreen = PdfColor.fromInt(0xFF15803D);
    const pdfAmber = PdfColor.fromInt(0xFFB45309);
    const pdfRed = PdfColor.fromInt(0xFFB91C1C);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        theme: theme,
        build: (pw.Context context) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // 1. Header with Company Info and Period Badge
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'مؤسسة سويقات أبو طالب',
                          style: pw.TextStyle(
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                            color: pdfDarkBlue,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'إدارة نقل المسافرين والأسطول - ولاية أدرار',
                          style: const pw.TextStyle(
                            fontSize: 10,
                            color: pdfTextSecondary,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'كشف الحساب والعمل الشهري للسائق',
                          style: pw.TextStyle(
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                            color: pdfTextPrimary,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: pw.BoxDecoration(
                            color: pdfDarkBlue,
                            borderRadius: pw.BorderRadius.circular(6),
                          ),
                          child: pw.Text(
                            '${monthNames[month]} $year',
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'تاريخ الاستخراج: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
                          style: const pw.TextStyle(
                            fontSize: 8,
                            color: pdfTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 8),
                pw.Divider(color: pdfBorder, thickness: 0.8),
                pw.SizedBox(height: 8),

                // 2. Driver Information Grid
                pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: pw.BoxDecoration(
                    color: pdfBgLight,
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: pdfBorder, width: 0.8),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Row(
                        children: [
                          _buildPdfInfoItem('اسم السائق:', driver.name),
                          _buildPdfInfoItem('الحافلة المسندة:', cleanPlate),
                          _buildPdfInfoItem('رقم الهاتف:', driver.phone),
                        ],
                      ),
                      pw.SizedBox(height: 6),
                      pw.Row(
                        children: [
                          _buildPdfInfoItem('رخصة السياقة:', driver.licenseType),
                          _buildPdfInfoItem('نظام المناوبة:', driver.currentPattern.title),
                          _buildPdfInfoItem('أجر اليومية:', '${driver.dailyWage.toInt()} دج'),
                        ],
                      ),
                      if (driver.loanAmount > 0) ...[
                        pw.SizedBox(height: 6),
                        pw.Row(
                          children: [
                            _buildPdfInfoItem('إجمالي المستحق:', '${driver.grossMonthlyWages.toInt()} دج'),
                            _buildPdfInfoItem('سلفة / قرض مخصوم:', '-${driver.loanAmount.toInt()} دج'),
                            _buildPdfInfoItem('المستحق الصافي:', '${driver.netMonthlyWages.toInt()} دج'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                pw.SizedBox(height: 8),

                // 3. Financial Summary Bar
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: pw.BoxDecoration(
                    color: pdfDarkBlue,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                    children: [
                      _buildPdfStatItem('أيام العمل', '$workDays يوم', PdfColors.green300),
                      _buildPdfStatItem('أيام الراحة', '$restDays يوم', PdfColors.amber300),
                      _buildPdfStatItem('أيام الغياب', '$absenceDays يوم', PdfColors.red300),
                      if (driver.loanAmount > 0)
                        _buildPdfStatItem('خصم سلفة', '-${driver.loanAmount.toInt()} دج', PdfColors.orange300),
                      _buildPdfStatItem('المستحق الصافي', '${driver.netMonthlyWages.toInt()} دج', PdfColors.white, isBold: true),
                    ],
                  ),
                ),

                pw.SizedBox(height: 10),

                // 4. Monthly Attendance Detail Table (2 Balanced Parallel Columns)
                pw.Text(
                  'تفصيل الحضور واليوميات لشهر ${monthNames[month]}:',
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                    color: pdfTextPrimary,
                  ),
                ),
                pw.SizedBox(height: 5),

                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Column 1: Days 1 to 16
                      pw.Expanded(
                        child: _buildDaysTable(
                          driver: driver,
                          year: year,
                          month: month,
                          startDay: 1,
                          endDay: (daysInMonth / 2).ceil(),
                          pdfBorder: pdfBorder,
                          pdfGreen: pdfGreen,
                          pdfAmber: pdfAmber,
                          pdfRed: pdfRed,
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      // Column 2: Days 17 to end of month
                      pw.Expanded(
                        child: _buildDaysTable(
                          driver: driver,
                          year: year,
                          month: month,
                          startDay: (daysInMonth / 2).ceil() + 1,
                          endDay: daysInMonth,
                          pdfBorder: pdfBorder,
                          pdfGreen: pdfGreen,
                          pdfAmber: pdfAmber,
                          pdfRed: pdfRed,
                        ),
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 10),

                // 5. Signatures and Official Seal
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: pdfBorder, width: 0.8),
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        children: [
                          pw.Text(
                            'توقيع السائق المعني:',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 25),
                          pw.Text('........................................', style: const pw.TextStyle(fontSize: 8, color: pdfTextSecondary)),
                        ],
                      ),
                      pw.Column(
                        children: [
                          pw.Text(
                            'توقيع وختم الإدارة:',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 25),
                          pw.Text('........................................', style: const pw.TextStyle(fontSize: 8, color: pdfTextSecondary)),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 6),
                pw.Center(
                  child: pw.Text(
                    'وثيقة إدارية رسمية معتمدة من منظومة سويقات لنقل المسافرين والأسطول',
                    style: const pw.TextStyle(fontSize: 8, color: pdfTextSecondary),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfInfoItem(String label, String value) {
    return pw.Expanded(
      child: pw.Row(
        children: [
          pw.Text(
            label,
            style: const pw.TextStyle(fontSize: 8, color: PdfColor.fromInt(0xFF64748B)),
          ),
          pw.SizedBox(width: 4),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
                color: const PdfColor.fromInt(0xFF0F172A),
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfStatItem(String label, String value, PdfColor valColor, {bool isBold = false}) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: isBold ? 11 : 9.5,
            fontWeight: pw.FontWeight.bold,
            color: valColor,
          ),
        ),
        pw.SizedBox(height: 1),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey300),
        ),
      ],
    );
  }

  static pw.Widget _buildDaysTable({
    required DriverModel driver,
    required int year,
    required int month,
    required int startDay,
    required int endDay,
    required PdfColor pdfBorder,
    required PdfColor pdfGreen,
    required PdfColor pdfAmber,
    required PdfColor pdfRed,
  }) {
    final List<pw.TableRow> rows = [];

    // Header row
    rows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE2E8F0)),
        children: [
          _cell('اليوم', isHeader: true),
          _cell('اليومية', isHeader: true),
          _cell('الحالة', isHeader: true),
          _cell('الأجر', isHeader: true),
        ],
      ),
    );

    for (int day = startDay; day <= endDay; day++) {
      final dayName = _getDayName(year, month, day);
      final AttendanceStatus status = driver.monthlyAttendance[day] ?? AttendanceStatus.work;

      PdfColor statusColor;
      switch (status) {
        case AttendanceStatus.work:
          statusColor = pdfGreen;
          break;
        case AttendanceStatus.rest:
          statusColor = pdfAmber;
          break;
        case AttendanceStatus.absence:
          statusColor = pdfRed;
          break;
      }

      final String wageStr = status == AttendanceStatus.work ? '${driver.dailyWage.toInt()} دج' : '0 دج';
      final bool isEven = day % 2 == 0;

      rows.add(
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: isEven ? const PdfColor.fromInt(0xFFF8FAFC) : PdfColors.white,
          ),
          children: [
            _cell('يوم $day'),
            _cell(dayName),
            _cell(status.arabicLabel, textColor: statusColor, isBold: true),
            _cell(wageStr),
          ],
        ),
      );
    }

    return pw.Table(
      border: pw.TableBorder.all(color: pdfBorder, width: 0.5),
      children: rows,
    );
  }

  static pw.Widget _cell(String text, {bool isHeader = false, PdfColor? textColor, bool isBold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2.5, horizontal: 4),
      child: pw.Center(
        child: pw.Text(
          text,
          style: pw.TextStyle(
            fontSize: isHeader ? 8 : 7.5,
            fontWeight: isHeader || isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: textColor ?? (isHeader ? const PdfColor.fromInt(0xFF1E293B) : const PdfColor.fromInt(0xFF334155)),
          ),
        ),
      ),
    );
  }

  /// Trigger native print flow (opens native Android Print Preview / Save as PDF)
  static Future<void> printDriverReport({
    required BuildContext context,
    required DriverModel driver,
    required int month,
    required int year,
  }) async {
    try {
      final pdfBytes = await generateDriverReportPdf(
        driver: driver,
        month: month,
        year: year,
      );

      final cleanName = driver.name.replaceAll(' ', '_');
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'كشف_حساب_${cleanName}_${month}_$year.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر فتح نافذة الطباعة: $e'),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Trigger native download / export flow (shares PDF so user can save to downloads, drive, or apps)
  static Future<void> downloadDriverReport({
    required BuildContext context,
    required DriverModel driver,
    required int month,
    required int year,
  }) async {
    try {
      final pdfBytes = await generateDriverReportPdf(
        driver: driver,
        month: month,
        year: year,
      );

      final cleanName = driver.name.replaceAll(' ', '_');
      final fileName = 'كشف_سائق_${cleanName}_${month}_$year.pdf';

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: fileName,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تصدير كشف السائق "${driver.name}" بنجاح'),
            backgroundColor: AppColors.accentGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر تحميل كشف السائق: $e'),
            backgroundColor: AppColors.accentRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
