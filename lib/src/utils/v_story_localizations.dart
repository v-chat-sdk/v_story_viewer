import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

/// Provides localized strings and formatting for the story viewer.
/// 
/// Supports multiple languages and RTL layouts with proper
/// text direction handling and gesture adaptation.
class VStoryLocalizations {
  /// The locale for this localization
  final Locale locale;
  
  /// Creates localizations for the specified locale
  const VStoryLocalizations({
    required this.locale,
  });
  
  /// Gets the default localizations for a locale
  static VStoryLocalizations of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return VStoryLocalizations(locale: locale);
  }
  
  /// Checks if the current locale is RTL
  bool get isRTL {
    final languageCode = locale.languageCode.toLowerCase();
    // Common RTL languages
    const rtlLanguages = {
      'ar', // Arabic
      'he', // Hebrew
      'fa', // Persian/Farsi
      'ur', // Urdu
      'yi', // Yiddish
      'ku', // Kurdish
      'ps', // Pashto
      'sd', // Sindhi
    };
    return rtlLanguages.contains(languageCode);
  }
  
  /// Gets the text direction for this locale
  TextDirection get textDirection {
    return isRTL ? TextDirection.rtl : TextDirection.ltr;
  }
  
  // ===== Localized UI Strings =====
  
  /// Reply button text
  String get reply {
    switch (locale.languageCode) {
      case 'ar':
        return 'رد';
      case 'he':
        return 'השב';
      case 'es':
        return 'Responder';
      case 'fr':
        return 'Répondre';
      case 'de':
        return 'Antworten';
      case 'it':
        return 'Rispondi';
      case 'pt':
        return 'Responder';
      case 'ru':
        return 'Ответить';
      case 'zh':
        return '回复';
      case 'ja':
        return '返信';
      case 'ko':
        return '답장';
      case 'hi':
        return 'जवाब दें';
      default:
        return 'Reply';
    }
  }
  
  /// Mute button text
  String get mute {
    switch (locale.languageCode) {
      case 'ar':
        return 'كتم';
      case 'he':
        return 'השתק';
      case 'es':
        return 'Silenciar';
      case 'fr':
        return 'Muet';
      case 'de':
        return 'Stumm';
      case 'it':
        return 'Silenzia';
      case 'pt':
        return 'Silenciar';
      case 'ru':
        return 'Отключить звук';
      case 'zh':
        return '静音';
      case 'ja':
        return 'ミュート';
      case 'ko':
        return '음소거';
      case 'hi':
        return 'म्यूट';
      default:
        return 'Mute';
    }
  }
  
  /// Unmute button text
  String get unmute {
    switch (locale.languageCode) {
      case 'ar':
        return 'إلغاء الكتم';
      case 'he':
        return 'בטל השתקה';
      case 'es':
        return 'Activar sonido';
      case 'fr':
        return 'Activer le son';
      case 'de':
        return 'Ton aktivieren';
      case 'it':
        return 'Riattiva audio';
      case 'pt':
        return 'Ativar som';
      case 'ru':
        return 'Включить звук';
      case 'zh':
        return '取消静音';
      case 'ja':
        return 'ミュート解除';
      case 'ko':
        return '음소거 해제';
      case 'hi':
        return 'अनम्यूट';
      default:
        return 'Unmute';
    }
  }
  
  /// Hide button text
  String get hide {
    switch (locale.languageCode) {
      case 'ar':
        return 'إخفاء';
      case 'he':
        return 'הסתר';
      case 'es':
        return 'Ocultar';
      case 'fr':
        return 'Masquer';
      case 'de':
        return 'Ausblenden';
      case 'it':
        return 'Nascondi';
      case 'pt':
        return 'Ocultar';
      case 'ru':
        return 'Скрыть';
      case 'zh':
        return '隐藏';
      case 'ja':
        return '非表示';
      case 'ko':
        return '숨기기';
      case 'hi':
        return 'छुपाएं';
      default:
        return 'Hide';
    }
  }
  
  /// Report button text
  String get report {
    switch (locale.languageCode) {
      case 'ar':
        return 'إبلاغ';
      case 'he':
        return 'דווח';
      case 'es':
        return 'Reportar';
      case 'fr':
        return 'Signaler';
      case 'de':
        return 'Melden';
      case 'it':
        return 'Segnala';
      case 'pt':
        return 'Denunciar';
      case 'ru':
        return 'Пожаловаться';
      case 'zh':
        return '举报';
      case 'ja':
        return '報告';
      case 'ko':
        return '신고';
      case 'hi':
        return 'रिपोर्ट';
      default:
        return 'Report';
    }
  }
  
  /// Share button text
  String get share {
    switch (locale.languageCode) {
      case 'ar':
        return 'مشاركة';
      case 'he':
        return 'שתף';
      case 'es':
        return 'Compartir';
      case 'fr':
        return 'Partager';
      case 'de':
        return 'Teilen';
      case 'it':
        return 'Condividi';
      case 'pt':
        return 'Compartilhar';
      case 'ru':
        return 'Поделиться';
      case 'zh':
        return '分享';
      case 'ja':
        return '共有';
      case 'ko':
        return '공유';
      case 'hi':
        return 'शेयर';
      default:
        return 'Share';
    }
  }
  
  /// Delete button text
  String get delete {
    switch (locale.languageCode) {
      case 'ar':
        return 'حذف';
      case 'he':
        return 'מחק';
      case 'es':
        return 'Eliminar';
      case 'fr':
        return 'Supprimer';
      case 'de':
        return 'Löschen';
      case 'it':
        return 'Elimina';
      case 'pt':
        return 'Excluir';
      case 'ru':
        return 'Удалить';
      case 'zh':
        return '删除';
      case 'ja':
        return '削除';
      case 'ko':
        return '삭제';
      case 'hi':
        return 'हटाएं';
      default:
        return 'Delete';
    }
  }
  
  /// View count text
  String viewCount(int count) {
    switch (locale.languageCode) {
      case 'ar':
        return '$count مشاهدة';
      case 'he':
        return '$count צפיות';
      case 'es':
        return '$count vistas';
      case 'fr':
        return '$count vues';
      case 'de':
        return '$count Aufrufe';
      case 'it':
        return '$count visualizzazioni';
      case 'pt':
        return '$count visualizações';
      case 'ru':
        return '$count просмотров';
      case 'zh':
        return '$count 次观看';
      case 'ja':
        return '$count 回視聴';
      case 'ko':
        return '조회수 $count회';
      case 'hi':
        return '$count बार देखा गया';
      default:
        if (count == 1) {
          return '$count view';
        }
        return '$count views';
    }
  }
  
  /// Loading text
  String get loading {
    switch (locale.languageCode) {
      case 'ar':
        return 'جاري التحميل...';
      case 'he':
        return 'טוען...';
      case 'es':
        return 'Cargando...';
      case 'fr':
        return 'Chargement...';
      case 'de':
        return 'Laden...';
      case 'it':
        return 'Caricamento...';
      case 'pt':
        return 'Carregando...';
      case 'ru':
        return 'Загрузка...';
      case 'zh':
        return '加载中...';
      case 'ja':
        return '読み込み中...';
      case 'ko':
        return '로딩 중...';
      case 'hi':
        return 'लोड हो रहा है...';
      default:
        return 'Loading...';
    }
  }
  
  /// Error message
  String get errorLoading {
    switch (locale.languageCode) {
      case 'ar':
        return 'خطأ في التحميل';
      case 'he':
        return 'שגיאה בטעינה';
      case 'es':
        return 'Error al cargar';
      case 'fr':
        return 'Erreur de chargement';
      case 'de':
        return 'Fehler beim Laden';
      case 'it':
        return 'Errore nel caricamento';
      case 'pt':
        return 'Erro ao carregar';
      case 'ru':
        return 'Ошибка загрузки';
      case 'zh':
        return '加载错误';
      case 'ja':
        return '読み込みエラー';
      case 'ko':
        return '로딩 오류';
      case 'hi':
        return 'लोडिंग त्रुटि';
      default:
        return 'Error loading';
    }
  }
  
  /// Tap to retry text
  String get tapToRetry {
    switch (locale.languageCode) {
      case 'ar':
        return 'اضغط لإعادة المحاولة';
      case 'he':
        return 'הקש כדי לנסות שוב';
      case 'es':
        return 'Toca para reintentar';
      case 'fr':
        return 'Appuyez pour réessayer';
      case 'de':
        return 'Tippen zum Wiederholen';
      case 'it':
        return 'Tocca per riprovare';
      case 'pt':
        return 'Toque para tentar novamente';
      case 'ru':
        return 'Нажмите, чтобы повторить';
      case 'zh':
        return '点击重试';
      case 'ja':
        return 'タップして再試行';
      case 'ko':
        return '다시 시도하려면 탭하세요';
      case 'hi':
        return 'पुनः प्रयास के लिए टैप करें';
      default:
        return 'Tap to retry';
    }
  }
  
  // ===== Date/Time Formatting =====
  
  /// Formats a timestamp for display
  String formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inSeconds < 60) {
      return _getJustNowText();
    } else if (difference.inMinutes < 60) {
      return _formatMinutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return _formatHoursAgo(difference.inHours);
    } else if (difference.inDays < 7) {
      return _formatDaysAgo(difference.inDays);
    } else {
      return _formatFullDate(dateTime);
    }
  }
  
  String _getJustNowText() {
    switch (locale.languageCode) {
      case 'ar':
        return 'الآن';
      case 'he':
        return 'עכשיו';
      case 'es':
        return 'Ahora';
      case 'fr':
        return 'Maintenant';
      case 'de':
        return 'Jetzt';
      case 'it':
        return 'Ora';
      case 'pt':
        return 'Agora';
      case 'ru':
        return 'Сейчас';
      case 'zh':
        return '刚刚';
      case 'ja':
        return 'たった今';
      case 'ko':
        return '방금';
      case 'hi':
        return 'अभी';
      default:
        return 'Just now';
    }
  }
  
  String _formatMinutesAgo(int minutes) {
    switch (locale.languageCode) {
      case 'ar':
        return minutes == 1 ? 'منذ دقيقة' : 'منذ $minutes دقائق';
      case 'he':
        return minutes == 1 ? 'לפני דקה' : 'לפני $minutes דקות';
      case 'es':
        return minutes == 1 ? 'hace 1 minuto' : 'hace $minutes minutos';
      case 'fr':
        return minutes == 1 ? 'il y a 1 minute' : 'il y a $minutes minutes';
      case 'de':
        return minutes == 1 ? 'vor 1 Minute' : 'vor $minutes Minuten';
      case 'it':
        return minutes == 1 ? '1 minuto fa' : '$minutes minuti fa';
      case 'pt':
        return minutes == 1 ? 'há 1 minuto' : 'há $minutes minutos';
      case 'ru':
        return '$minutes ${_getRussianMinuteForm(minutes)} назад';
      case 'zh':
        return '$minutes分钟前';
      case 'ja':
        return '$minutes分前';
      case 'ko':
        return '$minutes분 전';
      case 'hi':
        return '$minutes मिनट पहले';
      default:
        return minutes == 1 ? '1 minute ago' : '$minutes minutes ago';
    }
  }
  
  String _formatHoursAgo(int hours) {
    switch (locale.languageCode) {
      case 'ar':
        return hours == 1 ? 'منذ ساعة' : 'منذ $hours ساعات';
      case 'he':
        return hours == 1 ? 'לפני שעה' : 'לפני $hours שעות';
      case 'es':
        return hours == 1 ? 'hace 1 hora' : 'hace $hours horas';
      case 'fr':
        return hours == 1 ? 'il y a 1 heure' : 'il y a $hours heures';
      case 'de':
        return hours == 1 ? 'vor 1 Stunde' : 'vor $hours Stunden';
      case 'it':
        return hours == 1 ? '1 ora fa' : '$hours ore fa';
      case 'pt':
        return hours == 1 ? 'há 1 hora' : 'há $hours horas';
      case 'ru':
        return '$hours ${_getRussianHourForm(hours)} назад';
      case 'zh':
        return '$hours小时前';
      case 'ja':
        return '$hours時間前';
      case 'ko':
        return '$hours시간 전';
      case 'hi':
        return '$hours घंटे पहले';
      default:
        return hours == 1 ? '1 hour ago' : '$hours hours ago';
    }
  }
  
  String _formatDaysAgo(int days) {
    switch (locale.languageCode) {
      case 'ar':
        return days == 1 ? 'أمس' : 'منذ $days أيام';
      case 'he':
        return days == 1 ? 'אתמול' : 'לפני $days ימים';
      case 'es':
        return days == 1 ? 'ayer' : 'hace $days días';
      case 'fr':
        return days == 1 ? 'hier' : 'il y a $days jours';
      case 'de':
        return days == 1 ? 'gestern' : 'vor $days Tagen';
      case 'it':
        return days == 1 ? 'ieri' : '$days giorni fa';
      case 'pt':
        return days == 1 ? 'ontem' : 'há $days dias';
      case 'ru':
        return days == 1 ? 'вчера' : '$days ${_getRussianDayForm(days)} назад';
      case 'zh':
        return days == 1 ? '昨天' : '$days天前';
      case 'ja':
        return days == 1 ? '昨日' : '$days日前';
      case 'ko':
        return days == 1 ? '어제' : '$days일 전';
      case 'hi':
        return days == 1 ? 'कल' : '$days दिन पहले';
      default:
        return days == 1 ? 'yesterday' : '$days days ago';
    }
  }
  
  String _formatFullDate(DateTime dateTime) {
    // Use intl package for proper date formatting
    try {
      final formatter = intl.DateFormat.yMMMd(locale.toString());
      return formatter.format(dateTime);
    } catch (e) {
      // Fallback to default format
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
  
  // Helper methods for Russian pluralization
  String _getRussianMinuteForm(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'минуту';
    } else if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'минуты';
    } else {
      return 'минут';
    }
  }
  
  String _getRussianHourForm(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'час';
    } else if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'часа';
    } else {
      return 'часов';
    }
  }
  
  String _getRussianDayForm(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return 'день';
    } else if ([2, 3, 4].contains(count % 10) && ![12, 13, 14].contains(count % 100)) {
      return 'дня';
    } else {
      return 'дней';
    }
  }
}

/// Extension for easy access to localizations
extension VStoryLocalizationsExtension on BuildContext {
  /// Gets the localizations for this context
  VStoryLocalizations get storyLocalizations => VStoryLocalizations.of(this);
  
  /// Gets whether the current locale is RTL
  bool get isRTL => storyLocalizations.isRTL;
  
  /// Gets the text direction for the current locale
  TextDirection get textDirection => storyLocalizations.textDirection;
}