import 'package:Talab/utils/login/lib/login_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:Talab/utils/login/lib/login_system.dart';

class AppleLogin extends LoginSystem {
  OAuthCredential? credential;
  OAuthProvider? oAuthProvider;

  @override
  void init() async {}

  Future<UserCredential?> login() async {
  try {
    emit(MProgress());

    final appleIdCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    print("Apple ID Token: ${appleIdCredential.identityToken}");
    print("Apple Auth Code: ${appleIdCredential.authorizationCode}");

    if (appleIdCredential.identityToken == null ||
        appleIdCredential.authorizationCode == null) {
      emit(MFail("Missing Apple token or code"));
      return null;
    }

    final oAuthProvider = OAuthProvider('apple.com');

    final credential = oAuthProvider.credential(
      idToken: appleIdCredential.identityToken,
      accessToken: appleIdCredential.authorizationCode,
    );

    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    if (userCredential.additionalUserInfo?.isNewUser == true) {
      final givenName = appleIdCredential.givenName ?? "";
      final familyName = appleIdCredential.familyName ?? "";

      await userCredential.user?.updateDisplayName("$givenName $familyName");
      await userCredential.user?.reload();
    }

    emit(MSuccess());
    return userCredential;
  } catch (e) {
    print("apple error catch***${e.toString()}");
    emit(MFail(e));
    return null;
  }
}


  @override
  void onEvent(MLoginState state) {
    print("Login state is $state");
  }
}
