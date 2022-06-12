import 'package:blake2b/blake2b_hash.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:nanodart/nanodart.dart';
import 'dart:typed_data';
import 'package:x25519/x25519.dart';
import 'package:encrypt/encrypt.dart';

Uint8List convertEd25519SecretKeyToCurve25519(Uint8List sk) {
  Uint8List d = new Uint8List(64);
  Uint8List o = new Uint8List(32);
  var i;

  cryptoHash(d, sk, 32);
  d[0] &= 248;
  d[31] &= 127;
  d[31] |= 64;

  for (i = 0; i < 32; i++) {
    o[i] = d[i];
  }

  for (i = 0; i < 64; i++) {
    d[i] = 0;
  }

  return o;
}

int cryptoHash(Uint8List out, Uint8List m, int n) {
  Uint8List input = new Uint8List(n);
  for (var i = 0; i < n; ++i) {
    input[i] = m[i];
  }

  var hash = Blake2bHash.hashWithDigestSize(512, input);
  for (var i = 0; i < 64; ++i) {
    out[i] = hash[i];
  }

  return 0;
}

class DiffieHellman {
  init() {
    Sodium.init();
  }

  static Encrypted encrypt(String message, String address, String privateKey) {
    String publicKey = NanoAccounts.extractPublicKey(address);

    Uint8List convertedPublicKey = Sodium.cryptoSignEd25519PkToCurve25519(
        NanoHelpers.hexToBytes(publicKey));
    Uint8List convertedPrivateKey =
        convertEd25519SecretKeyToCurve25519(NanoHelpers.hexToBytes(privateKey));

    var aliceSharedKey = X25519(convertedPrivateKey, convertedPublicKey);

    final key = Key(aliceSharedKey);
    final iv = IV.fromLength(16);

    final encrypter = Encrypter(AES(key));

    final encrypted = encrypter.encrypt(message, iv: iv);

    return encrypted;
  }

  static String decrypt(
      Encrypted encrypted, String address, String privateKey) {
    String publicKey = NanoAccounts.extractPublicKey(address);

    Uint8List convertedPublicKey = Sodium.cryptoSignEd25519PkToCurve25519(
        NanoHelpers.hexToBytes(publicKey));
    Uint8List convertedPrivateKey =
        convertEd25519SecretKeyToCurve25519(NanoHelpers.hexToBytes(privateKey));

    var bobSharedKey = X25519(convertedPrivateKey, convertedPublicKey);
    final key = Key(bobSharedKey);
    final encrypter = Encrypter(AES(key));
    final iv = IV.fromLength(16);
    final decrypted = encrypter.decrypt(encrypted, iv: iv);

    return decrypted;
  }
}
