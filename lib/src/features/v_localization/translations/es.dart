/// Spanish translations
const Map<String, String> esTranslations = {
  // Action Labels
  'reply': 'Responder a la historia...',
  'send': 'Enviar',
  'close': 'Cerrar',
  'share': 'Compartir',
  'save': 'Guardar',
  'delete': 'Eliminar',
  'report': 'Reportar',
  'mute': 'Silenciar',
  'unmute': 'Activar sonido',
  'pause': 'Pausar',
  'play': 'Reproducir',
  'retry': 'Reintentar',

  // Time Formatting
  'just_now': 'Ahora',
  'minutes_ago': 'Hace {count}m',
  'hours_ago': 'Hace {count}h',
  'days_ago': 'Hace {count}d',
  'seconds_ago': 'Hace {count}s',
  'weeks_ago': 'Hace semanas',
  'months_ago': 'Hace {count}mo',
  'years_ago': 'Hace {count}a',

  // Error Messages
  'error_loading': 'Error al cargar la historia',
  'error_network': 'Error de red',
  'error_permission': 'Permiso denegado',
  'error_generic': 'Ocurrió un error',
  'error_timeout': 'Se agotó el tiempo de espera. Por favor, intenta de nuevo.',
  'error_not_found': 'Historia no encontrada o eliminada.',
  'error_custom': 'Error al cargar la historia personalizada',
  'error_unknown': 'Error desconocido',

  // Error Headers & States
  'error_header': 'Error',
  'error_max_retries': 'Se alcanzó el máximo de reintentos',
  'error_retrying': 'Reintentando...',
  'error_retries_left': 'Reintentos restantes: {count}',

  // Validation Errors
  'error_invalid_index': 'Índice {index} fuera de rango. Válido: 0-{max}',
  'error_story_not_found': 'Historia "{storyId}" no encontrada en grupo "{groupId}"',
  'error_empty_stories': 'El grupo de historias no puede estar vacío',
  'error_duplicate_ids': 'El grupo de historias contiene IDs duplicados',
  'error_empty_id': 'El grupo de historias contiene una historia con ID vacío',
  'error_empty_groups': 'Los grupos de historias no pueden estar vacíos',
  'error_invalid_group_index': 'Índice de grupo inicial fuera de rango',
  'error_invalid_story_index': 'Índice de historia inicial fuera de rango',

  // Media Type Errors
  'error_text_empty': 'La historia de texto no puede estar vacía',
  'error_invalid_platform_file': 'VPlatformFile debe tener una fuente de medios válida',
  'error_unknown_story_type': 'Tipo de historia desconocido, actualiza la aplicación a la última versión',
  'error_web_file_ops': 'Las operaciones de archivo no son compatibles en web. Usa VPlatformFile.assetsPath directamente.',
  'error_web_bytes_ops': 'Las operaciones de archivo no son compatibles en web. Usa VPlatformFile.bytes directamente.',

  // Controller Validation
  'error_text_controller': 'VTextController requiere VTextStory',
  'error_image_controller': 'VImageController requiere VImageStory',
  'error_video_controller': 'VVideoController requiere VVideoStory',
  'error_custom_controller': 'VCustomController requiere VCustomStory',

  // Progress Bar Errors
  'error_bar_count': 'barCount debe ser mayor que 0',
  'error_bar_index': 'Índice fuera de rango: {index}',

  // Cache Configuration Errors
  'error_max_age': 'maxAge debe ser positivo',
  'error_stale_duration': 'staleDuration debe ser positivo',
  'error_stale_max_age': 'staleDuration debe ser >= maxAge',
  'error_cache_max_retries': 'maxRetries debe ser no negativo',
  'error_empty_story_id': 'storyId no debe estar vacío',
  'error_empty_url': 'url no debe estar vacío',
  'error_negative_bytes': 'downloadedBytes debe ser no negativo',
  'error_base_delay': 'baseDelay debe ser positivo',
  'error_negative_attempt': 'attempt debe ser no negativo',

  // Context Menu Actions
  'action_copy_caption': 'Copiar leyenda',
  'action_view_details': 'Ver detalles',

  // Voice Input States
  'voice_ready': 'Listo',
  'voice_initializing': 'Inicializando...',
  'voice_listening': 'Escuchando...',
  'voice_processing': 'Procesando...',
  'voice_recognized': 'Reconocido',
  'voice_error': 'Error',

  // Gesture Labels
  'gesture_slow': 'Lento',
  'gesture_normal': 'Normal',
  'gesture_fast': 'Rápido',
  'gesture_very_fast': 'Muy rápido',

  // Direction Labels
  'direction_left': 'Izquierda',
  'direction_right': 'Derecha',
  'direction_up': 'Arriba',
  'direction_down': 'Abajo',
  'direction_none': 'Ninguno',

  // Tooltips & Accessibility
  'tooltip_mute_video': 'Silenciar video',
  'tooltip_unmute_video': 'Activar sonido del video',
  'tooltip_more_options': 'Más opciones',
  'tooltip_close_viewer': 'Cerrar visor de historias',
  'tooltip_show_keyboard': 'Mostrar teclado',
  'tooltip_show_emoji': 'Mostrar selector de emojis',
  'tooltip_close_emoji': 'Cerrar selector de emojis',
  'tooltip_gesture_controls': 'Controles de gestos del visor de historias',

  // Placeholder & Hint Text
  'placeholder_no_emojis': 'Sin emojis recientes',
  'placeholder_message': 'Enviar un mensaje',
  'placeholder_search': 'Buscar',
  'placeholder_voice_text': 'Tu texto de voz aquí',

  // Engagement Indicators
  'engagement_views': '{count} visualizaciones',
  'engagement_reactions': '{count} reacciones',
  'engagement_shares': '{count} compartidos',
  'engagement_comments': '{count} comentarios',

  // Caption Display
  'caption_show_more': 'Mostrar más',

  // Story Types
  'story_type_text': 'Texto',
  'story_type_image': 'Imagen',
  'story_type_video': 'Video',
  'story_type_custom': 'Personalizado',
  'story_type_unknown': 'Desconocido',

  // Size Formatting
  'size_bytes': '{size} B',
  'size_kilobytes': '{size} KB',
  'size_megabytes': '{size} MB',
  'size_unknown': 'Desconocido',
};
