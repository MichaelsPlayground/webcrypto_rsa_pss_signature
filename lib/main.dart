import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart' as flFramework;
import 'package:flutter/src/widgets/basic.dart' as flPadding;
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:hex/hex.dart';

import "package:pointycastle/export.dart";
import 'package:webcrypto/webcrypto.dart';

/* in pubspec.yaml eintragen:
  pointycastle: ^3.1.1
  dargon2_flutter: ^2.1.0
 */

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

    //_completeRunOwnEcdh();
    //_completeRunOwn();

    printC('webcrypto: AES CBC String encryption with PBKDF2 derived key\n');

    final plaintext = 'The quick brown fox jumps over the lazy dog';
    printC('plaintext: ' + plaintext);
    final password = 'secret password';

    // encryption
    printC('\n* * * Encryption * * *');
    String ciphertextBase64 = await aesCbcPbkdf2EncryptToBase64Wc(password, plaintext);
    printC('ciphertext (Base64): ' + ciphertextBase64);
    printC(
        'output is (Base64) salt : (Base64) iv : (Base64) ciphertext');

    printC('\n* * * Decryption * * *');
    var ciphertextDecryptionBase64 = ciphertextBase64;
    printC('ciphertext (Base64): ' + ciphertextDecryptionBase64);
    printC(
        'input is (Base64) salt : (Base64) iv : (Base64) ciphertext');
    var decryptedtext = await aesCbcPbkdf2DecryptFromBase64Wc(password, ciphertextDecryptionBase64);
    printC('plaintext:  ' + decryptedtext);
    
    return '';
  }

  void runYourSecondDartCode() {
    printC('execute additional code');
  }

  Future<String> aesGcmPbkdf2EncryptToBase64Wc(String password, String plaintext) async {
    var plaintextUint8 = createUint8ListFromString(plaintext);
    var passphrase = createUint8ListFromString(password);
    final PBKDF2_ITERATIONS = 15000;
    final key = await Pbkdf2SecretKey.importRawKey(passphrase);
    final salt = generateSalt32ByteWc();
    final derivedBits = await key.deriveBits(256, Hash.sha256, salt, PBKDF2_ITERATIONS);
    final nonce = generateNonce12ByteWc();
    AesGcmSecretKey aesGcmSecretKey = await AesGcmSecretKey.importRawKey(derivedBits);
    Uint8List ciphertext = await aesGcmSecretKey.encryptBytes(plaintextUint8, nonce);
    String ciphertextBase64 = base64Encoding(ciphertext);
    String nonceBase64 = base64Encoding(nonce);
    String saltBase64 = base64Encoding(salt);
    return saltBase64 +
        ':' +
        nonceBase64 +
        ':' +
        ciphertextBase64;
  }

  Future<String> aesGcmPbkdf2DecryptFromBase64Wc(String password, String data) async {
    var parts = data.split(':');
    var salt = base64.decode(parts[0]);
    var nonce = base64.decode(parts[1]);
    var ciphertext = base64.decode(parts[2]);
    var passphrase = createUint8ListFromString(password);
    final PBKDF2_ITERATIONS = 15000;
    final key = await Pbkdf2SecretKey.importRawKey(passphrase);
    final derivedBits = await key.deriveBits(256, Hash.sha256, salt, PBKDF2_ITERATIONS);
    AesGcmSecretKey aesGcmSecretKey = await AesGcmSecretKey.importRawKey(derivedBits);
    Uint8List decryptedtext = await aesGcmSecretKey.decryptBytes(ciphertext, nonce);
    return new String.fromCharCodes(decryptedtext);
  }

  Future<String> aesCbcPbkdf2EncryptToBase64Wc(String password, String plaintext) async {
    var plaintextUint8 = createUint8ListFromString(plaintext);
    var passphrase = createUint8ListFromString(password);
    final PBKDF2_ITERATIONS = 15000;
    final key = await Pbkdf2SecretKey.importRawKey(passphrase);
    final salt = generateSalt32ByteWc();
    final derivedBits = await key.deriveBits(256, Hash.sha256, salt, PBKDF2_ITERATIONS);
    final iv = generateIv16ByteWc();
    AesCbcSecretKey aesCbcSecretKey = await AesCbcSecretKey.importRawKey(derivedBits);
    Uint8List ciphertext = await aesCbcSecretKey.encryptBytes(plaintextUint8, iv);
    String ciphertextBase64 = base64Encoding(ciphertext);
    String ivBase64 = base64Encoding(iv);
    String saltBase64 = base64Encoding(salt);
    return saltBase64 +
        ':' +
        ivBase64 +
        ':' +
        ciphertextBase64;
  }

  Future<String> aesCbcPbkdf2DecryptFromBase64Wc(String password, String data) async {
    var parts = data.split(':');
    var salt = base64.decode(parts[0]);
    var iv = base64.decode(parts[1]);
    var ciphertext = base64.decode(parts[2]);
    var passphrase = createUint8ListFromString(password);
    final PBKDF2_ITERATIONS = 15000;
    final key = await Pbkdf2SecretKey.importRawKey(passphrase);
    final derivedBits = await key.deriveBits(256, Hash.sha256, salt, PBKDF2_ITERATIONS);
    AesCbcSecretKey aesCbcSecretKey = await AesCbcSecretKey.importRawKey(derivedBits);
    Uint8List decryptedtext = await aesCbcSecretKey.decryptBytes(ciphertext, iv);
    return new String.fromCharCodes(decryptedtext);
  }

  String aesGcmPbkdf2EncryptToBase64Pc(String password, String plaintext) {
    var plaintextUint8 = createUint8ListFromString(plaintext);
    var passphrase = createUint8ListFromString(password);
    final PBKDF2_ITERATIONS = 5000;
    final salt = generateSalt32Byte();
    KeyDerivator derivator =
        new PBKDF2KeyDerivator(new HMac(new SHA256Digest(), 64));
    Pbkdf2Parameters params = new Pbkdf2Parameters(salt, PBKDF2_ITERATIONS, 32);
    derivator.init(params);
    final key = derivator.process(passphrase);
    final nonce = generateRandomNonce();
    final cipher = GCMBlockCipher(AESFastEngine());
    var aeadParameters =
        AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0));
    cipher.init(true, aeadParameters);
    var ciphertextWithTag = cipher.process(plaintextUint8);
    var ciphertextWithTagLength = ciphertextWithTag.lengthInBytes;
    var ciphertextLength =
        ciphertextWithTagLength - 16; // 16 bytes = 128 bit tag length
    var ciphertext =
        Uint8List.sublistView(ciphertextWithTag, 0, ciphertextLength);
    var gcmTag = Uint8List.sublistView(
        ciphertextWithTag, ciphertextLength, ciphertextWithTagLength);
    final saltBase64 = base64.encode(salt);
    final nonceBase64 = base64.encode(nonce);
    final ciphertextBase64 = base64.encode(ciphertext);
    final gcmTagBase64 = base64.encode(gcmTag);
    return saltBase64 +
        ':' +
        nonceBase64 +
        ':' +
        ciphertextBase64 +
        ':' +
        gcmTagBase64;
  }

  String aesGcmPbkdf2DecryptFromBase64Pc(String password, String data) {
    var parts = data.split(':');
    var salt = base64.decode(parts[0]);
    var nonce = base64.decode(parts[1]);
    var ciphertext = base64.decode(parts[2]);
    var gcmTag = base64.decode(parts[3]);
    var bb = BytesBuilder();
    bb.add(ciphertext);
    bb.add(gcmTag);
    var ciphertextWithTag = bb.toBytes();
    var passphrase = createUint8ListFromString(password);
    final PBKDF2_ITERATIONS = 5000;
    KeyDerivator derivator =
        new PBKDF2KeyDerivator(new HMac(new SHA256Digest(), 64));
    Pbkdf2Parameters params = new Pbkdf2Parameters(salt, PBKDF2_ITERATIONS, 32);
    derivator.init(params);
    final key = derivator.process(passphrase);
    final cipher = GCMBlockCipher(AESFastEngine());
    var aeadParameters =
        AEADParameters(KeyParameter(key), 128, nonce, Uint8List(0));
    cipher.init(false, aeadParameters);
    return new String.fromCharCodes(cipher.process(ciphertextWithTag));
  }

  Uint8List generateSalt32ByteWc() {
    final salt = Uint8List(32);
    fillRandomBytes(salt);
    return salt;
  }

  Uint8List generateNonce12ByteWc() {
    final nonce = Uint8List(12);
    fillRandomBytes(nonce);
    return nonce;
  }

  Uint8List generateIv16ByteWc() {
    final nonce = Uint8List(16);
    fillRandomBytes(nonce);
    return nonce;
  }

  Uint8List generateSalt32Byte() {
    final _sGen = Random.secure();
    final _seed =
        Uint8List.fromList(List.generate(32, (n) => _sGen.nextInt(255)));
    SecureRandom sec = SecureRandom("Fortuna")..seed(KeyParameter(_seed));
    return sec.nextBytes(32);
  }

  Uint8List generateRandomNonce() {
    final _sGen = Random.secure();
    final _seed =
        Uint8List.fromList(List.generate(32, (n) => _sGen.nextInt(255)));
    SecureRandom sec = SecureRandom("Fortuna")..seed(KeyParameter(_seed));
    return sec.nextBytes(12);
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
