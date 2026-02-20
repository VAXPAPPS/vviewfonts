import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'package:venom_config/venom_config.dart';

import 'core/colors/vaxp_colors.dart';
import 'core/venom_layout.dart';

import 'data/datasources/fontconfig_ffi_datasource.dart';
import 'data/datasources/favorites_local_datasource.dart';
import 'data/repositories/font_repository_impl.dart';

import 'application/font_list/font_list_bloc.dart';
import 'application/font_list/font_list_event.dart';
import 'application/font_preview/font_preview_bloc.dart';
import 'application/favorites/favorites_bloc.dart';
import 'application/favorites/favorites_event.dart';

import 'presentation/pages/home_page.dart';

Future<void> main() async {
  // Initialize Flutter bindings first to ensure the binary messenger is ready
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Venom Config System
  await VenomConfig().init();

  // Initialize VaxpColors listeners
  VaxpColors.init();

  // Initialize window manager for desktop controls
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    minimumSize: Size(900, 600),
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    title: 'View Fonts',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  // Setup data layer
  final fontDatasource = FontconfigFfiDatasource();
  final favoritesDatasource = FavoritesLocalDatasource();
  final fontRepository = FontRepositoryImpl(
    fontDatasource: fontDatasource,
    favoritesDatasource: favoritesDatasource,
  );

  runApp(VaxpApp(fontRepository: fontRepository));
}

class VaxpApp extends StatelessWidget {
  final FontRepositoryImpl fontRepository;

  const VaxpApp({super.key, required this.fontRepository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<FontListBloc>(
          create: (_) =>
              FontListBloc(repository: fontRepository)..add(LoadFonts()),
        ),
        BlocProvider<FontPreviewBloc>(create: (_) => FontPreviewBloc()),
        BlocProvider<FavoritesBloc>(
          create: (_) =>
              FavoritesBloc(repository: fontRepository)..add(LoadFavorites()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'View Fonts',
        home: const ViewFontsHome(),
      ),
    );
  }
}

class ViewFontsHome extends StatelessWidget {
  const ViewFontsHome({super.key});

  @override
  Widget build(BuildContext context) {
    return VenomScaffold(title: "View Fonts", body: const HomePage());
  }
}
