import 'package:get/get.dart';
import '../modules/auth/login_view.dart';
import '../modules/home/home_view.dart';
import '../modules/profile/profile_view.dart';
import '../modules/history/history_view.dart';
import '../modules/goals/goals_view.dart';
import '../modules/fasting/fasting_view.dart'; 
import '../modules/beverage/beverage_view.dart';
part 'app_routes.dart';


class AppPages {
  static const INITIAL = Routes.LOGIN;

  static final routes = [
    GetPage(name: Routes.LOGIN, page: () => LoginView()),
    GetPage(name: Routes.HOME, page: () => HomeView()),
    GetPage(name: Routes.PROFILE, page: () => ProfileView()),
    GetPage(name: Routes.HISTORY, page: () => HistoryView()),
    GetPage(name: Routes.GOALS, page: () => GoalsView()),
    GetPage(name: Routes.FASTING, page: () => FastingView()), 
    GetPage(name: Routes.BEVERAGE, page: () => BeverageView()),
  ];
}