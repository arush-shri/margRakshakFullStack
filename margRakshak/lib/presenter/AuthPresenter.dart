import 'package:marg_rakshak/model/AuthModel.dart';

class AuthPresenter{
  final model = AuthModel();

  Future<void> signIn({required String mail, required String passwd})async {
    await model.mailSignIn(mail: mail, passwd: passwd);
  }

  Future<void> mailSignUp({required String mail, required String passwd})async {
    await model.mailSignUp(mail: mail, passwd: passwd);
  }

  Future<void> googleSignIn() async{
    await model.googleSignIn();
  }

  Future<void> signOut() async{
    await model.signOut();
  }
}