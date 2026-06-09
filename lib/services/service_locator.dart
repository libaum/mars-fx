import 'package:get_it/get_it.dart';
import 'package:mars_fx/data/exchange_rate_repository.dart';
import 'package:mars_fx/data/exchange_rate_service.dart';
import 'package:mars_fx/data/local_storage_service.dart';
import 'package:mars_fx/logic/currency_list_manager.dart';
import 'package:mars_fx/logic/settings_manager.dart';
import 'package:mars_fx/theme/theme_manager.dart';

final getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Storage must be first (async init)
  getIt.registerSingleton<LocalStorageService>(
    await LocalStorageService.getInstance(),
  );

  getIt.registerSingleton<ExchangeRateService>(ExchangeRateService());

  getIt.registerSingleton<ExchangeRateRepository>(
    ExchangeRateRepository(
      getIt<ExchangeRateService>(),
      getIt<LocalStorageService>(),
    ),
  );

  getIt.registerSingleton<ThemeManager>(ThemeManager());
  getIt.registerSingleton<SettingsManager>(SettingsManager());

  getIt.registerSingleton<CurrencyListManager>(CurrencyListManager());
}
