import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<AppTheme> {
  static const _key = 'app_theme';
  ThemeCubit() : super(AppTheme.light) {
    _load();
  }

  Future<void> _load() async {
    final sp = await SharedPreferences.getInstance();
    final s = sp.getString(_key) ?? 'light';
    emit(s == 'dark' ? AppTheme.dark : AppTheme.light);
  }

  Future<void> toggle() async {
    final next = state == AppTheme.light ? AppTheme.dark : AppTheme.light;
    emit(next);
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_key, next == AppTheme.dark ? 'dark' : 'light');
  }
}
