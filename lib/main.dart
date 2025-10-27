import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'data/services/api_service.dart';
import 'data/services/local_db_service.dart';
import 'data/repository/todo_repository.dart';
import 'logic/blocs/todo_bloc.dart';
import 'logic/blocs/todo_event.dart';
import 'logic/cubits/connectivity_cubit.dart';
import 'logic/cubits/theme_cubit.dart';
import 'logic/cubits/theme_state.dart';
import 'presentation/screens/todo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final local = LocalDbService();
  final api = ApiService();
  final repo = TodoRepository(api: api, db: local);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ConnectivityCubit()),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(
          create:
              (ctx) => TodoBloc(
                repo: repo,
                connectivityCubit: ctx.read<ConnectivityCubit>(),
              )..add(const LoadTodos()),
        ),
      ],
      child: const AppRoot(),
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, AppTheme>(
      builder: (context, theme) {
        final baseLight = ThemeData.light();
        final baseDark = ThemeData.dark();

        return MaterialApp(
          title: 'Offline Todo',
          debugShowCheckedModeBanner: false,

          theme: baseLight.copyWith(
            textTheme: GoogleFonts.ptSansTextTheme(baseLight.textTheme),
          ),

          darkTheme: baseDark.copyWith(
            textTheme: GoogleFonts.ptSansTextTheme(baseDark.textTheme),
          ),

          themeMode: theme == AppTheme.dark ? ThemeMode.dark : ThemeMode.light,

          home: const TodoScreen(),
        );
      },
    );
  }
}
