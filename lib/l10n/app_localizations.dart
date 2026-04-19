import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App
      'app_title': 'NAS Media Manager',

      // Login
      'login': 'Login',
      'username': 'Username',
      'password': 'Password',
      'please_enter_username': 'Please enter username',
      'please_enter_password': 'Please enter password',
      'login_failed': 'Login failed',
      'select_user': 'Select User',
      'no_saved_users': 'No saved users',
      'cancel': 'Cancel',
      'notice': 'Notice',
      'ok': 'OK',
      'admin_account_hint': 'Admin: admin / admin123\nOther users: username / 123',

      // Home
      'materials': 'Materials',
      'trash': 'Trash',
      'settings': 'Settings',
      'select_view_user': 'Select View User',
      'me': ' (Me)',
      'confirm_delete_items': 'Delete {count} items?',
      'delete_moved_to_trash': 'Deleted items will be moved to trash',
      'delete': 'Delete',
      'copy_items_to': 'Copy {count} items to',
      'no_other_users': 'No other users',
      'move_items_to': 'Move {count} items to',
      'select_target_folder': 'Select target folder ({username})',
      'images': 'Images',
      'videos': 'Videos',
      'copying_to': 'Copying to {username}...',
      'copy_success': 'Copy Success',
      'copied_to': 'Copied to {username}',

      // Trash
      'confirm_restore_items': 'Restore {count} items?',
      'restore': 'Restore',
      'permanently_delete_items': 'Permanently delete {count} items?',
      'action_cannot_be_undone': 'This action cannot be undone!',
      'delete_permanently': 'Delete Permanently',
      'items_selected': '{count} items selected',
      'failed_to_load': 'Failed to load',
      'retry': 'Retry',
      'trash_is_empty': 'Trash is empty',

      // Settings
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'server': 'Server',
      'api_address': 'API Address',
      'cache': 'Cache',
      'clear_cache': 'Clear Cache',
      'confirm_clear_cache': 'Are you sure you want to clear all cache?',
      'clear': 'Clear',
      'clear_success': 'Clear Success',
      'cache_cleared': 'Cache has been cleared',
      'clear_failed': 'Clear Failed',
      'management': 'Management',
      'user_management': 'User Management',
      'system_stats': 'System Stats',
      'operation_logs': 'Operation Logs',
      'backup_management': 'Backup Management',
      'ai_settings': 'AI Settings',
      'account': 'Account',
      'logout': 'Logout',
      'about': 'About',
      'version': 'Version',
      'language': 'Language',
      'select_language': 'Select Language',
      'english': 'English',
      'chinese': '中文',

      // Material Detail
      'save': 'Save',
      'save_failed': 'Save Failed',
      'screenshot': 'Screenshot',
      'screenshot_selected': 'Screenshot selected: ',
      'basic_info': 'Basic Info',
      'title': 'Title',
      'description': 'Description',
      'usage_status': 'Usage Status',
      'viral_status': 'Viral Status',
      'file_info': 'File Info',
      'file_name': 'File Name',
      'size': 'Size',
      'type': 'Type',
      'upload_time': 'Upload Time',
      'download_video': 'Download Video',
      'download_image': 'Download Image',
      'ai_generate': 'AI Generate',
      'translate': 'Translate',
      'copy': 'Copy',
      'notice_feature_unavailable': 'Notice',
      'video_screenshot_web_unavailable': 'Video screenshot feature is not available in Web version, please use the native App version',
      'generate_failed': 'Generate Failed',
      'please_enter_content': 'Please enter content first',
      'select_translation_direction': 'Select Translation Direction',
      'chinese_to_english': 'Chinese → English',
      'english_to_chinese': 'English → Chinese',
      'translate_failed': 'Translation Failed',
      'download_success': 'Download Success',
      'save_success': 'Save Success',
      'video_saved_to_album': 'Video has been saved to album',
      'image_saved_to_album': 'Image has been saved to album',
      'save_to_album_failed': 'Failed to save to album',
      'download_failed': 'Download Failed',
      'go_to_settings': 'Go to Settings',
      'copied': 'Copied',
      'content_copied_to_clipboard': 'Content has been copied to clipboard',

      // Material Status
      'unused': 'Unused',
      'used': 'Used',
      'viral_candidate': 'Viral Candidate',
      'not_viral': 'Not Viral',
      'monitoring': 'Monitoring',
      'viral': 'Viral',

      // Admin - AI Settings
      'only_admin_can_modify_ai_settings': 'Only admin can modify AI settings',
      'save_success': 'Save Success',
      'save_failed_with_error': 'Save failed: {error}',
      'success': 'Success',
      'error': 'Error',
      'api_config': 'API Configuration',
      'api_address': 'API Address',
      'api_key': 'API Key',
      'model_name': 'Model Name',
      'prompt_config': 'Prompt Configuration',
      'title_generation_prompt': 'Title Generation Prompt',
      'description_generation_prompt': 'Description Generation Prompt',
      'safety_rules': 'Safety Rules',
      'replacement_words': 'Replacement Words',
      'replacement_words_format_hint': 'Format: JSON array, e.g. [{"original":"sensitive1","replacement":"replace1"},{"original":"sensitive2","replacement":"replace2"}]',
      'prompts': 'Prompts',
      'safety_rules_tab': 'Safety Rules',
      'replacements': 'Replacements',

      // Admin - Backup
      'backup_created_success': 'Backup created successfully',
      'backup_created_failed': 'Backup creation failed: {error}',
      'confirm_delete_backup': 'Confirm Delete',
      'confirm_delete_backup_message': 'Are you sure you want to delete backup {backupId}?',
      'delete_success': 'Delete Success',
      'delete_failed': 'Delete failed: {error}',
      'backup_management': 'Backup Management',
      'no_backups': 'No backups',
      'unknown': 'Unknown',

      // Admin - Logs
      'login': 'Login',
      'logout': 'Logout',
      'upload_material': 'Upload Material',
      'update_material': 'Update Material',
      'delete_material': 'Delete Material',
      'create_user': 'Create User',
      'delete_user': 'Delete User',
      'batch_delete': 'Batch Delete',
      'batch_restore': 'Batch Restore',
      'batch_copy': 'Batch Copy',
      'batch_move': 'Batch Move',
      'unknown_action': 'Unknown',
      'operation_logs': 'Operation Logs',
      'no_logs': 'No logs',
      'user_id': 'User ID: {userId}',
      'target_type': 'Target Type: {targetType}',
      'target_id': 'Target ID: {targetId}',
      'details': 'Details: {details}',

      // Admin - Stats
      'system_stats': 'System Stats',
      'overview': 'Overview',
      'users': 'Users',
      'files': 'Files',
      'total_storage': 'Total Storage',
      'user_storage_details': 'User Storage Details',

      // Admin - User Management
      'user_management': 'User Management',
      'create_user': 'Create User',
      'create': 'Create',
      'creation_failed': 'Creation Failed',
      'delete_user_confirm': 'Delete user "{username}"?',
      'user_media_transfer_to_admin': 'This user\'s media will be transferred to admin',
      'delete_failed': 'Delete Failed',
      'current': 'Current',
      'admin_role': 'Admin',
      'user_role': 'User',

      // Video/Image
      'video': 'Video',
      'image': 'Image',
      'video_material': 'Video Material',

      // Home - Upload
      'uploading': 'Uploading...',
      'select_upload_method': 'Select Upload Method',
      'choose_from_gallery': 'Choose from Gallery',
      'take_photo': 'Take Photo',
      'choose_file': 'Choose File',
      'upload_successful': 'Upload Successful',
      'upload_failed': 'Upload Failed',
      'copy_successful': 'Copy Successful',
      'copy_failed': 'Copy Failed',
      'move_successful': 'Move Successful',
      'move_failed': 'Move Failed',
      'moving_to': 'Moving to {username}...',
      'no_items': 'No items',
      'media': 'Media',
    },
    'zh': {
      // App
      'app_title': 'NAS 素材管理',

      // Login
      'login': '登录',
      'username': '用户名',
      'password': '密码',
      'please_enter_username': '请输入用户名',
      'please_enter_password': '请输入密码',
      'login_failed': '登录失败',
      'select_user': '选择用户',
      'no_saved_users': '暂无保存的用户',
      'cancel': '取消',
      'notice': '提示',
      'ok': '确定',
      'admin_account_hint': 'admin账户: admin / admin123\n其他用户: 用户名 / 123',

      // Home
      'materials': '素材',
      'trash': '垃圾箱',
      'settings': '设置',
      'select_view_user': '选择查看用户',
      'me': ' (我)',
      'confirm_delete_items': '确认删除 {count} 项？',
      'delete_moved_to_trash': '删除的素材将移到垃圾箱',
      'delete': '删除',
      'copy_items_to': '复制 {count} 项到',
      'no_other_users': '暂无其他用户',
      'move_items_to': '移动 {count} 项到',
      'select_target_folder': '选择目标文件夹（{username}）',
      'images': '图片',
      'videos': '视频',
      'copying_to': '复制到 {username}...',
      'copy_success': '复制成功',
      'copied_to': '已复制到 {username}',

      // Trash
      'confirm_restore_items': '确认恢复 {count} 项？',
      'restore': '恢复',
      'permanently_delete_items': '永久删除 {count} 项？',
      'action_cannot_be_undone': '此操作不可恢复！',
      'delete_permanently': '永久删除',
      'items_selected': '已选择 {count} 项',
      'failed_to_load': '加载失败',
      'retry': '重试',
      'trash_is_empty': '垃圾箱为空',

      // Settings
      'appearance': '外观',
      'dark_mode': '深色模式',
      'server': '服务器',
      'api_address': 'API 地址',
      'cache': '缓存',
      'clear_cache': '清除缓存',
      'confirm_clear_cache': '确定要清除所有缓存吗？',
      'clear': '清除',
      'clear_success': '清除成功',
      'cache_cleared': '缓存已清除',
      'clear_failed': '清除失败',
      'management': '管理',
      'user_management': '用户管理',
      'system_stats': '系统统计',
      'operation_logs': '操作日志',
      'backup_management': '备份管理',
      'ai_settings': 'AI 设置',
      'account': '账户',
      'logout': '退出登录',
      'about': '关于',
      'version': '版本',
      'language': '语言',
      'select_language': '选择语言',
      'english': 'English',
      'chinese': '中文',

      // Material Detail
      'save': '保存',
      'save_failed': '保存失败',
      'screenshot': '截图',
      'screenshot_selected': '已选择截图：',
      'basic_info': '基本信息',
      'title': '标题',
      'description': '描述',
      'usage_status': '使用状态',
      'viral_status': '爆款状态',
      'file_info': '文件信息',
      'file_name': '文件名',
      'size': '大小',
      'type': '类型',
      'upload_time': '上传时间',
      'download_video': '下载视频',
      'download_image': '下载图片',
      'ai_generate': 'AI生成',
      'translate': '翻译',
      'copy': '复制',
      'notice_feature_unavailable': '提示',
      'video_screenshot_web_unavailable': '视频截图功能在Web版本中暂不可用，请使用原生App版本',
      'generate_failed': '生成失败',
      'please_enter_content': '请先输入内容',
      'select_translation_direction': '选择翻译方向',
      'chinese_to_english': '中文 → 英文',
      'english_to_chinese': '英文 → 中文',
      'translate_failed': '翻译失败',
      'download_success': '下载成功',
      'save_success': '保存成功',
      'video_saved_to_album': '视频已保存到相册',
      'image_saved_to_album': '图片已保存到相册',
      'save_to_album_failed': '保存到相册失败',
      'download_failed': '下载失败',
      'go_to_settings': '去设置',
      'copied': '已复制',
      'content_copied_to_clipboard': '内容已复制到剪贴板',

      // Material Status
      'unused': '未使用',
      'used': '已使用',
      'viral_candidate': '爆款备选',
      'not_viral': '非爆款',
      'monitoring': '待观察',
      'viral': '爆款',

      // Admin - AI Settings
      'only_admin_can_modify_ai_settings': '只有管理员可以修改AI设置',
      'save_success': '保存成功',
      'save_failed_with_error': '保存失败: {error}',
      'success': '成功',
      'error': '错误',
      'api_config': 'API配置',
      'api_address': 'API 地址',
      'api_key': 'API 密钥',
      'model_name': '模型名称',
      'prompt_config': '提示词配置',
      'title_generation_prompt': '标题生成提示词',
      'description_generation_prompt': '描述生成提示词',
      'safety_rules': '安全规则',
      'replacement_words': '替换词',
      'replacement_words_format_hint': '格式: JSON数组，例如 [{"original":"敏感词1","replacement":"替换词1"},{"original":"敏感词2","replacement":"替换词2"}]',
      'prompts': '提示词',
      'safety_rules_tab': '安全规则',
      'replacements': '替换词',

      // Admin - Backup
      'backup_created_success': '备份创建成功',
      'backup_created_failed': '备份创建失败: {error}',
      'confirm_delete_backup': '确认删除',
      'confirm_delete_backup_message': '确定要删除备份 {backupId} 吗？',
      'delete_success': '删除成功',
      'delete_failed': '删除失败: {error}',
      'backup_management': '备份管理',
      'no_backups': '暂无备份',
      'unknown': '未知',

      // Admin - Logs
      'login': '登录',
      'logout': '退出',
      'upload_material': '上传素材',
      'update_material': '更新素材',
      'delete_material': '删除素材',
      'create_user': '创建用户',
      'delete_user': '删除用户',
      'batch_delete': '批量删除',
      'batch_restore': '批量恢复',
      'batch_copy': '批量复制',
      'batch_move': '批量移动',
      'unknown_action': '未知',
      'operation_logs': '操作日志',
      'no_logs': '暂无日志',
      'user_id': '用户ID: {userId}',
      'target_type': '目标类型: {targetType}',
      'target_id': '目标ID: {targetId}',
      'details': '详情: {details}',

      // Admin - Stats
      'system_stats': '系统统计',
      'overview': '概览',
      'users': '用户',
      'files': '文件',
      'total_storage': '总存储',
      'user_storage_details': '用户存储详情',

      // Admin - User Management
      'user_management': '用户管理',
      'create_user': '创建用户',
      'create': '创建',
      'creation_failed': '创建失败',
      'delete_user_confirm': '删除用户 "{username}"？',
      'user_media_transfer_to_admin': '该用户的素材将转移给管理员',
      'delete_failed': '删除失败',
      'current': '当前',
      'admin_role': '管理员',
      'user_role': '用户',

      // Video/Image
      'video': '视频',
      'image': '图片',
      'video_material': '视频素材',

      // Home - Upload
      'uploading': '上传中...',
      'select_upload_method': '选择上传方式',
      'choose_from_gallery': '从相册选择',
      'take_photo': '拍照',
      'choose_file': '选择文件',
      'upload_successful': '上传成功',
      'upload_failed': '上传失败',
      'copy_successful': '复制成功',
      'copy_failed': '复制失败',
      'move_successful': '移动成功',
      'move_failed': '移动失败',
      'moving_to': '移动到 {username}...',
      'no_items': '暂无内容',
      'media': '素材',
    },
  };

  String translate(String key, {Map<String, String>? params}) {
    String? value = _localizedValues[locale.languageCode]?[key];
    if (value == null) {
      return key;
    }
    if (params != null) {
      params.forEach((paramKey, paramValue) {
        value = value!.replaceAll('{$paramKey}', paramValue);
      });
    }
    return value!;
  }

  String get appTitle => translate('app_title');
  String get login => translate('login');
  String get username => translate('username');
  String get password => translate('password');
  String get pleaseEnterUsername => translate('please_enter_username');
  String get pleaseEnterPassword => translate('please_enter_password');
  String get loginFailed => translate('login_failed');
  String get selectUser => translate('select_user');
  String get noSavedUsers => translate('no_saved_users');
  String get cancel => translate('cancel');
  String get notice => translate('notice');
  String get ok => translate('ok');
  String get adminAccountHint => translate('admin_account_hint');

  String get materials => translate('materials');
  String get trash => translate('trash');
  String get settings => translate('settings');
  String get selectViewUser => translate('select_view_user');
  String get me => translate('me');
  String confirmDeleteItems(int count) => translate('confirm_delete_items', params: {'count': count.toString()});
  String get deleteMovedToTrash => translate('delete_moved_to_trash');
  String get delete => translate('delete');
  String copyItemsTo(int count) => translate('copy_items_to', params: {'count': count.toString()});
  String get noOtherUsers => translate('no_other_users');
  String moveItemsTo(int count) => translate('move_items_to', params: {'count': count.toString()});
  String selectTargetFolder(String username) => translate('select_target_folder', params: {'username': username});
  String get images => translate('images');
  String get videos => translate('videos');
  String copyingTo(String username) => translate('copying_to', params: {'username': username});
  String get copySuccess => translate('copy_success');
  String copiedTo(String username) => translate('copied_to', params: {'username': username});

  String confirmRestoreItems(int count) => translate('confirm_restore_items', params: {'count': count.toString()});
  String get restore => translate('restore');
  String permanentlyDeleteItems(int count) => translate('permanently_delete_items', params: {'count': count.toString()});
  String get actionCannotBeUndone => translate('action_cannot_be_undone');
  String get deletePermanently => translate('delete_permanently');
  String itemsSelected(int count) => translate('items_selected', params: {'count': count.toString()});
  String get failedToLoad => translate('failed_to_load');
  String get retry => translate('retry');
  String get trashIsEmpty => translate('trash_is_empty');

  String get appearance => translate('appearance');
  String get darkMode => translate('dark_mode');
  String get server => translate('server');
  String get apiAddress => translate('api_address');
  String get cache => translate('cache');
  String get clearCache => translate('clear_cache');
  String get confirmClearCache => translate('confirm_clear_cache');
  String get clear => translate('clear');
  String get clearSuccess => translate('clear_success');
  String get cacheCleared => translate('cache_cleared');
  String get clearFailed => translate('clear_failed');
  String get management => translate('management');
  String get userManagement => translate('user_management');
  String get systemStats => translate('system_stats');
  String get operationLogs => translate('operation_logs');
  String get backupManagement => translate('backup_management');
  String get aiSettings => translate('ai_settings');
  String get account => translate('account');
  String get logout => translate('logout');
  String get about => translate('about');
  String get version => translate('version');
  String get language => translate('language');
  String get selectLanguage => translate('select_language');
  String get english => translate('english');
  String get chinese => translate('chinese');

  String get save => translate('save');
  String get saveFailed => translate('save_failed');
  String get screenshot => translate('screenshot');
  String get screenshotSelected => translate('screenshot_selected');
  String get basicInfo => translate('basic_info');
  String get title => translate('title');
  String get description => translate('description');
  String get usageStatus => translate('usage_status');
  String get viralStatus => translate('viral_status');
  String get fileInfo => translate('file_info');
  String get fileName => translate('file_name');
  String get size => translate('size');
  String get type => translate('type');
  String get uploadTime => translate('upload_time');
  String get downloadVideo => translate('download_video');
  String get downloadImage => translate('download_image');
  String get aiGenerate => translate('ai_generate');
  String get translateText => translate('translate');
  String get copy => translate('copy');
  String get noticeFeatureUnavailable => translate('notice_feature_unavailable');
  String get videoScreenshotWebUnavailable => translate('video_screenshot_web_unavailable');
  String get generateFailed => translate('generate_failed');
  String get pleaseEnterContent => translate('please_enter_content');
  String get selectTranslationDirection => translate('select_translation_direction');
  String get chineseToEnglish => translate('chinese_to_english');
  String get englishToChinese => translate('english_to_chinese');
  String get translateFailed => translate('translate_failed');
  String get downloadSuccess => translate('download_success');
  String get saveSuccess => translate('save_success');
  String get videoSavedToAlbum => translate('video_saved_to_album');
  String get imageSavedToAlbum => translate('image_saved_to_album');
  String get saveToAlbumFailed => translate('save_to_album_failed');
  String get downloadFailed => translate('download_failed');
  String get goToSettings => translate('go_to_settings');
  String get copied => translate('copied');
  String get contentCopiedToClipboard => translate('content_copied_to_clipboard');

  String get unused => translate('unused');
  String get used => translate('used');
  String get viralCandidate => translate('viral_candidate');
  String get notViral => translate('not_viral');
  String get monitoring => translate('monitoring');
  String get viral => translate('viral');

  String get onlyAdminCanModifyAiSettings => translate('only_admin_can_modify_ai_settings');
  String get saveSuccessMsg => translate('save_success');
  String saveFailedWithError(String error) => translate('save_failed_with_error', params: {'error': error});
  String get success => translate('success');
  String get error => translate('error');
  String get apiConfig => translate('api_config');
  String get apiKey => translate('api_key');
  String get modelName => translate('model_name');
  String get promptConfig => translate('prompt_config');
  String get titleGenerationPrompt => translate('title_generation_prompt');
  String get descriptionGenerationPrompt => translate('description_generation_prompt');
  String get safetyRules => translate('safety_rules');
  String get replacementWords => translate('replacement_words');
  String get replacementWordsFormatHint => translate('replacement_words_format_hint');
  String get prompts => translate('prompts');
  String get safetyRulesTab => translate('safety_rules_tab');
  String get replacements => translate('replacements');

  String get backupCreatedSuccess => translate('backup_created_success');
  String backupCreatedFailed(String error) => translate('backup_created_failed', params: {'error': error});
  String get confirmDeleteBackup => translate('confirm_delete_backup');
  String confirmDeleteBackupMessage(String backupId) => translate('confirm_delete_backup_message', params: {'backupId': backupId});
  String get deleteSuccessMsg => translate('delete_success');
  String deleteFailed(String error) => translate('delete_failed', params: {'error': error});
  String get noBackups => translate('no_backups');
  String get unknown => translate('unknown');

  String get uploadMaterial => translate('upload_material');
  String get updateMaterial => translate('update_material');
  String get deleteMaterial => translate('delete_material');
  String get createUser => translate('create_user');
  String get deleteUser => translate('delete_user');
  String get batchDelete => translate('batch_delete');
  String get batchRestore => translate('batch_restore');
  String get batchCopy => translate('batch_copy');
  String get batchMove => translate('batch_move');
  String get unknownAction => translate('unknown_action');
  String get noLogs => translate('no_logs');
  String userId(String userId) => translate('user_id', params: {'userId': userId});
  String targetType(String targetType) => translate('target_type', params: {'targetType': targetType});
  String targetId(String targetId) => translate('target_id', params: {'targetId': targetId});
  String details(String details) => translate('details', params: {'details': details});

  String get video => translate('video');
  String get image => translate('image');
  String get videoMaterial => translate('video_material');
  String get uploading => translate('uploading');
  String get overview => translate('overview');
  String get users => translate('users');
  String get files => translate('files');
  String get totalStorage => translate('total_storage');
  String get userStorageDetails => translate('user_storage_details');
  String get createUser => translate('create_user');
  String get create => translate('create');
  String get creationFailed => translate('creation_failed');
  String deleteUserConfirm(String username) => translate('delete_user_confirm', params: {'username': username});
  String get userMediaTransferToAdmin => translate('user_media_transfer_to_admin');
  String get deleteFailed => translate('delete_failed');
  String get current => translate('current');
  String get adminRole => translate('admin_role');
  String get userRole => translate('user_role');
  String get selectUploadMethod => translate('select_upload_method');
  String get chooseFromGallery => translate('choose_from_gallery');
  String get takePhoto => translate('take_photo');
  String get chooseFile => translate('choose_file');
  String get uploadSuccessful => translate('upload_successful');
  String get uploadFailed => translate('upload_failed');
  String get copySuccessful => translate('copy_successful');
  String get copyFailed => translate('copy_failed');
  String get moveSuccessful => translate('move_successful');
  String get moveFailed => translate('move_failed');
  String movingTo(String username) => translate('moving_to', params: {'username': username});
  String get noItems => translate('no_items');
  String get media => translate('media');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
