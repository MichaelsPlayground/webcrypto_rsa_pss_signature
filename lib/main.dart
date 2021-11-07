import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart' as flFramework;
import 'package:flutter/src/widgets/basic.dart' as flPadding;
import 'dart:convert';

import 'dart:typed_data';

import 'package:webcrypto/webcrypto.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Console'),
        ),
        body: MyWidget(),
      ),
    );
  }
}

// widget class
class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends flFramework.State<MyWidget> {
  // state variable
  String _textString = 'press the button "run the code"';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'console output',
          style: TextStyle(fontSize: 30),
        ),
        Expanded(
          flex: 1,
          child: new SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: flPadding.Padding(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                child: Text(_textString,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Courier',
                      color: Colors.black,
                    ))),
          ),
        ),
        Container(
          child: Row(
            children: <Widget>[
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  child: Text('clear console'),
                  onPressed: () {
                    clearConsole();
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  child: Text('extra Button'),
                  onPressed: () {
                    runYourSecondDartCode();
                  },
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  child: Text('run the code'),
                  onPressed: () async {
                    runYourMainDartCode();
                  },
                ),
              ),
              SizedBox(width: 10),
            ],
          ),
        ),
      ],
    );
  }

  void clearConsole() {
    setState(() {
      _textString = ''; // will add additional lines
    });
  }

  void printC(_newString) {
    setState(() {
      _textString = _textString + _newString + '\n';
    });
  }

  /* ### instructions ###
      place your code inside runYourMainDartCode and print it to the console
      using printC('your output to the console');
      clearConsole() clears the actual console
      place your code that needs to be executed additionally inside
      runYourSecondDartCode and start it with "extra Button"
   */
  Future<String> runYourMainDartCode() async {
    clearConsole();

    printC('webcrypto: RSA PSS padding String signature\n');

    final dataToSignString = 'The quick brown fox jumps over the lazy dog';
    Uint8List dataToSignBytes = createUint8ListFromString(dataToSignString);
    printC('dataToSign: ' + dataToSignString);

    // usually we would load the private and public key from a file or keystore
    // here we use hardcoded keys for demonstration - don't do this in real programs

    printC('\n* * * sign the plaintext with the RSA private key * * *');
    final privateKeyPem = loadRsaPrivateKeyPem();
    final privateKeyBytes = getBytesFromPEMString(privateKeyPem);
    RsaPssPrivateKey rsaPrivateKey =
        await RsaPssPrivateKey.importPkcs8Key(privateKeyBytes, Hash.sha256);
    //printC('used private key:\n' + privateKeyPem);
    String signatureBase64 =
        await rsaSignToBase64Wc(rsaPrivateKey, dataToSignBytes);
    printC('\nsignature (Base64): ' + signatureBase64);

    printC(
        '\n* * * verify the signature against the plaintext with the RSA public key * * *');
    final publicKeyPem = loadRsaPublicKeyPem();
    final publicKeyBytes = getBytesFromPEMString(publicKeyPem);
    RsaPssPublicKey rsaPublicKey =
        await RsaPssPublicKey.importSpkiKey(publicKeyBytes, Hash.sha256);
    //printC('used public key:\n' + publicKeyPem);
    bool signatureVerified = await rsaVerifiySignatureFromBase64Wc(
        rsaPublicKey, dataToSignBytes, signatureBase64);
    printC('\nsignature (Base64) verified: $signatureVerified');
    return '';
  }

  void runYourSecondDartCode() {
    printC('execute additional code');
  }

  // don't worry - it is a sample key
  String loadRsaPublicKeyPem() {
    return ('''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA8EmWJUZ/Osz4vXtUU2S+
0M4BP9+s423gjMjoX+qP1iCnlcRcFWxthQGN2CWSMZwR/vY9V0un/nsIxhZSWOH9
iKzqUtZD4jt35jqOTeJ3PCSr48JirVDNLet7hRT37Ovfu5iieMN7ZNpkjeIG/CfT
/QQl7R+kO/EnTmL3QjLKQNV/HhEbHS2/44x7PPoHqSqkOvl8GW0qtL39gTLWgAe8
01/w5PmcQ38CKG0oT2gdJmJqIxNmAEHkatYGHcMDtXRBpOhOSdraFj6SmPyHEmLB
ishaq7Jm8NPPNK9QcEQ3q+ERa5M6eM72PpF93g2p5cjKgyzzfoIV09Zb/LJ2aW2g
QwIDAQAB
-----END PUBLIC KEY-----''');
  }

  // don't worry - it is a sample key
  String loadRsaPrivateKeyPem() {
    return ('''-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDwSZYlRn86zPi9
e1RTZL7QzgE/36zjbeCMyOhf6o/WIKeVxFwVbG2FAY3YJZIxnBH+9j1XS6f+ewjG
FlJY4f2IrOpS1kPiO3fmOo5N4nc8JKvjwmKtUM0t63uFFPfs69+7mKJ4w3tk2mSN
4gb8J9P9BCXtH6Q78SdOYvdCMspA1X8eERsdLb/jjHs8+gepKqQ6+XwZbSq0vf2B
MtaAB7zTX/Dk+ZxDfwIobShPaB0mYmojE2YAQeRq1gYdwwO1dEGk6E5J2toWPpKY
/IcSYsGKyFqrsmbw0880r1BwRDer4RFrkzp4zvY+kX3eDanlyMqDLPN+ghXT1lv8
snZpbaBDAgMBAAECggEBAIVxmHzjBc11/73bPB2EGaSEg5UhdzZm0wncmZCLB453
XBqEjk8nhDsVfdzIIMSEVEowHijYz1c4pMq9osXR26eHwCp47AI73H5zjowadPVl
uEAot/xgn1IdMN/boURmSj44qiI/DcwYrTdOi2qGA+jD4PwrUl4nsxiJRZ/x7PjL
hMzRbvDxQ4/Q4ThYXwoEGiIBBK/iB3Z5eR7lFa8E5yAaxM2QP9PENBr/OqkGXLWV
qA/YTxs3gAvkUjMhlScOi7PMwRX9HsrAeLKbLuC1KJv1p2THUtZbOHqrAF/uwHaj
ygUblFaa/BTckTN7PKSVIhp7OihbD04bSRrh+nOilcECgYEA/8atV5DmNxFrxF1P
ODDjdJPNb9pzNrDF03TiFBZWS4Q+2JazyLGjZzhg5Vv9RJ7VcIjPAbMy2Cy5BUff
EFE+8ryKVWfdpPxpPYOwHCJSw4Bqqdj0Pmp/xw928ebrnUoCzdkUqYYpRWx0T7YV
RoA9RiBfQiVHhuJBSDPYJPoP34kCgYEA8H9wLE5L8raUn4NYYRuUVMa+1k4Q1N3X
Bixm5cccc/Ja4LVvrnWqmFOmfFgpVd8BcTGaPSsqfA4j/oEQp7tmjZqggVFqiM2m
J2YEv18cY/5kiDUVYR7VWSkpqVOkgiX3lK3UkIngnVMGGFnoIBlfBFF9uo02rZpC
5o5zebaDImsCgYAE9d5wv0+nq7/STBj4NwKCRUeLrsnjOqRriG3GA/TifAsX+jw8
XS2VF+PRLuqHhSkQiKazGr2Wsa9Y6d7qmxjEbmGkbGJBC+AioEYvFX9TaU8oQhvi
hgA6ZRNid58EKuZJBbe/3ek4/nR3A0oAVwZZMNGIH972P7cSZmb/uJXMOQKBgQCs
FaQAL+4sN/TUxrkAkylqF+QJmEZ26l2nrzHZjMWROYNJcsn8/XkaEhD4vGSnazCu
/B0vU6nMppmezF9Mhc112YSrw8QFK5GOc3NGNBoueqMYy1MG8Xcbm1aSMKVv8xba
rh+BZQbxy6x61CpCfaT9hAoA6HaNdeoU6y05lBz1DQKBgAbYiIk56QZHeoZKiZxy
4eicQS0sVKKRb24ZUd+04cNSTfeIuuXZrYJ48Jbr0fzjIM3EfHvLgh9rAZ+aHe/L
84Ig17KiExe+qyYHjut/SC0wODDtzM/jtrpqyYa5JoEpPIaUSgPuTH/WhO3cDsx6
3PIW4/CddNs8mCSBOqTnoaxh
-----END PRIVATE KEY-----''');
  }

  Uint8List getBytesFromPEMString(String pem) {
    var lines = LineSplitter.split(pem)
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.length < 2 ||
        !lines.first.startsWith('-----BEGIN') ||
        !lines.last.startsWith('-----END')) {
      throw ArgumentError('The given string does not have the correct '
          'begin/end markers expected in a PEM file.');
    }
    var base64 = lines.sublist(1, lines.length - 1).join('');
    return Uint8List.fromList(base64Decode(base64));
  }

  Future<String> rsaSignToBase64Wc(
      RsaPssPrivateKey privateKey, Uint8List messageByte) async {
    try {
      var signature = await privateKey.signBytes(
          messageByte, 32); // 32 byte  = 256 bit for SHA-256
      return base64Encoding(signature);
    } on Error {
      return '';
    }
  }

  Future<bool> rsaVerifiySignatureFromBase64Wc(RsaPssPublicKey publicKey,
      Uint8List messageByte, String signatureBase64) async {
    try {
      var signature = base64Decoding(signatureBase64);
      var verificationResult = await publicKey.verifyBytes(
          signature, messageByte, 32); // 32 byte  = 256 bit for SHA-256
      return verificationResult;
    } on Error {
      return false;
    }
  }

  Uint8List createUint8ListFromString(String s) {
    var ret = new Uint8List(s.length);
    for (var i = 0; i < s.length; i++) {
      ret[i] = s.codeUnitAt(i);
    }
    return ret;
  }

  String base64Encoding(Uint8List input) {
    return base64.encode(input);
  }

  Uint8List base64Decoding(String input) {
    return base64.decode(input);
  }
}
