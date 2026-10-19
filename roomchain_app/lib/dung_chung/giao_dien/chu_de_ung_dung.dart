import 'package:flutter/material.dart';

import 'bang_mau.dart';
import 'kieu_chu.dart';
import 'kich_thuoc.dart';

abstract final class ChuDeUngDung {
  static ThemeData get sang {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: BangMau.chinh,
          brightness: Brightness.light,
        ).copyWith(
          primary: BangMau.chinh,
          onPrimary: BangMau.nenThe,
          surface: BangMau.nenThe,
          onSurface: BangMau.chuChinh,
          error: BangMau.loi,
          outline: BangMau.vien,
        );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(KichThuoc.boNut),
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: BangMau.nen,
      textTheme: const TextTheme(
        headlineLarge: KieuChu.tieuDeLon,
        headlineSmall: KieuChu.tieuDeTrang,
        titleLarge: KieuChu.tieuDeMuc,
        titleMedium: KieuChu.tieuDeThe,
        bodyLarge: KieuChu.noiDung,
        bodyMedium: KieuChu.noiDung,
        bodySmall: KieuChu.chuPhu,
        labelLarge: KieuChu.noiDungDam,
        labelMedium: KieuChu.nhan,
        labelSmall: KieuChu.chuNho,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: BangMau.nenThe,
        foregroundColor: BangMau.chuChinh,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: KieuChu.tieuDeThe,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BangMau.chinh,
          foregroundColor: BangMau.nenThe,
          minimumSize: const Size(48, KichThuoc.caoNut),
          elevation: 0,
          shape: shape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, KichThuoc.caoNut),
          shape: shape,
          side: const BorderSide(color: BangMau.chinh),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BangMau.nenThe,
        contentPadding: const EdgeInsets.all(14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KichThuoc.boONhap),
          borderSide: const BorderSide(color: BangMau.vien),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KichThuoc.boONhap),
          borderSide: const BorderSide(color: BangMau.vien),
        ),
      ),
      cardTheme: CardThemeData(
        color: BangMau.nenThe,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KichThuoc.boThe),
          side: const BorderSide(color: BangMau.vien),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: BangMau.nenThe,
        selectedItemColor: BangMau.chinh,
        unselectedItemColor: BangMau.chuPhu,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(fontSize: 11),
        unselectedLabelStyle: TextStyle(fontSize: 11),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: BangMau.nenThe,
        shape: shape,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      dividerTheme: const DividerThemeData(color: BangMau.vien, thickness: 1),
      iconTheme: const IconThemeData(
        color: BangMau.chuPhu,
        size: KichThuoc.bieuTuong,
      ),
    );
  }
}
