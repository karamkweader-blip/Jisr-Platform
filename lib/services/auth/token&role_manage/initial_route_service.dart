import 'package:jisr_platform/routes/app_routes.dart';
import 'package:jisr_platform/services/auth/token&role_manage/auth_service.dart';

class InitialRouteService {
  final AuthService _authService = AuthService();

  Future<String> getInitialRoute() async {
    final token = await _authService.getToken();
    final role = await _authService.getRole();
// print(token);
// print(role);

    if (token == null || token.isEmpty) {
      return Routes.login;
    }

    if (role == 'student') {
      return Routes.studentHome;
    }

    if (role == 'company') {
      return Routes.companyMain;
    }

    return Routes.login;
  }
}