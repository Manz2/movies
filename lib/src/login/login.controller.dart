import 'package:movies/src/login/login_model.dart';

class LoginController {
  final LoginModel _model;
  LoginController() : _model = LoginModel(password: "", mail: "");
  LoginModel get model => _model;
}
