import 'package:flutter/material.dart';

/// Shared black, white, and silver palette for the GlamFit customer app.
/// Legacy names remain as aliases so existing screens keep their behavior.
class AppColors {
  static const Color blushPink = Color(0x00000000);
  static const Color lightPink = Color(0x1AFFFFFF);
  static const Color rosePink = Color(0x40FFFFFF);
  static const Color roseRed = Color(0xFFF5F5F5);
  static const Color deepRose = Color(0xFFD4D4D4);
  static const Color champagneGold = Color(0xFFD4D4D4);
  static const Color champagneLight = Color(0xFFEAEAEA);
  static const Color champagneDark = Color(0xFF999999);

  static const Color goldLight = Color(0x1AFFFFFF);
  static const Color goldSoft = Color(0x40FFFFFF);
  static const Color goldShimmer = Color(0xFFEAEAEA);
  static const Color metallicGold = Color(0xFF999999);
  static const Color darkGoldLine = Color(0x33FFFFFF);

  static const Color textBlack = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFFE0E0E0);
  static const Color textMid = Color(0xFFB0B0B0);
  static const Color textSoft = Color(0xFF888888);
  static const Color dustyRose = rosePink;
  static const Color champagneMid = champagneGold;
  static const Color charcoal = textBlack;
  static const Color darkGray = textDark;
  static const Color softGray = textMid;
  static const Color mediumGray = textMid;
  static const Color dimGray = textSoft;

  static const Color scaffoldBg = Color(0x00000000);
  static const Color surfaceBg = Color(0xFF171717);
  static const Color cardBg = Color(0xFF171717);
  static const Color cardDark = Color(0xFF111111);
  static const Color darkSurface = Color(0xFF222222);
  static const Color glassWhite = Color(0x18FFFFFF);
  static const Color glassBorder = Color(0x40FFFFFF);
  static const Color glassHighlight = Color(0x24FFFFFF);

  static const Color primary = Color(0xFFF5F5F5);
  static const Color primaryLight = Color(0xFFD4D4D4);
  static const Color primaryDark = Color(0xFFBDBDBD);
  static const Color primarySurface = Color(0x1AFFFFFF);
  static const Color accent = primary;
  static const Color accentLight = primaryLight;
  static const Color accentDark = primaryDark;

  static const Color white = Color(0x20FFFFFF);
  static const Color ivory = Color(0x20FFFFFF);
  static const Color frostedWhite = Color(0x28FFFFFF);
  static const Color cream = Color(0xFF101010);
  static const Color offWhite = Color(0x20FFFFFF);
  static const Color forest = Color(0xFF111111);
  static const Color lightGray = Color(0x35FFFFFF);
  static const Color midnightNavy = Color(0xFF111111);
  static const Color deepPurple = Color(0xFFBDBDBD);
  static const Color darkViolet = Color(0xFFBDBDBD);
  static const Color eucalyptus = Color(0xFFD4D4D4);

  // Status distinctions stay accessible through labels, with restrained gray tones.
  static const Color success = Color(0xFFE5E5E5);
  static const Color successLight = Color(0x1AE5E5E5);
  static const Color warning = Color(0xFFBDBDBD);
  static const Color warningLight = Color(0x1ABDBDBD);
  static const Color error = Color(0xFFFFFFFF);
  static const Color errorLight = Color(0x1AFFFFFF);
  static const Color info = Color(0xFFB0B0B0);
  static const Color infoLight = Color(0x1AB0B0B0);
  static const Color statusPending = warning;
  static const Color statusApproved = success;
  static const Color statusRejected = error;
  static const Color statusAwaitingPayment = warning;
  static const Color statusConfirmed = success;
  static const Color statusReady = info;
  static const Color statusRented = textDark;
  static const Color statusReturned = info;
  static const Color statusCompleted = success;
  static const Color statusCancelled = textSoft;
  static const Color statusOverdue = error;

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFD4D4D4)],
  );
  static const LinearGradient goldButtonGradient = primaryGradient;
  static const LinearGradient champagneGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF080808), Color(0xFF171717), Color(0xFF0B0B0B)],
  );
  static const LinearGradient splashGradient = champagneGradient;
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x20FFFFFF), Color(0x0DFFFFFF)],
  );
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF171717), Color(0xFF090909)],
  );
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF333333), Color(0xFF111111)],
  );
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0x24FFFFFF), Color(0x0DFFFFFF)],
  );
  static const LinearGradient navGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xDD202020), Color(0xCC101010)],
  );
  static const LinearGradient bannerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF292929), Color(0xFF111111)],
  );
}
