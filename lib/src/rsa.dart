import 'dart:convert';
import 'dart:typed_data';

import 'package:asn1lib/asn1lib.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/signers/rsa_signer.dart';

/// Author: quanke (woquanke.com)
/// Date: 2019/4/22
///
class RsaKeyParser {
  RSAPublicKey parsePublic(String key) {
    List<String> rows = key.split('\n');
    String header = rows.first;

    if (header == '-----BEGIN RSA PUBLIC KEY-----') {
      return _parsePublic(_parseSequence(rows));
    }

    if (header == '-----BEGIN PUBLIC KEY-----') {
      return _parsePublic(_pkcs8PublicSequence(_parseSequence(rows)));
    }

    throw UnsupportedError('PEMKey($key) is unsupported');
  }

  RSAPrivateKey parsePrivate(String key) {
    List<String> rows = key.split('\n');
    String header = rows.first;

    if (header == '-----BEGIN RSA PRIVATE KEY-----') {
      return _parsePrivate(_parseSequence(rows));
    }

    if (header == '-----BEGIN PRIVATE KEY-----') {
      return _parsePrivate(_pkcs8PrivateSequence(_parseSequence(rows)));
    }

    throw UnsupportedError('PEMKey($key) is unsupported');
  }

  RSAPublicKey _parsePublic(ASN1Sequence sequence) {
    BigInt modulus = (sequence.elements[0] as ASN1Integer).valueAsBigInteger;
    BigInt exponent = (sequence.elements[1] as ASN1Integer).valueAsBigInteger;

    return RSAPublicKey(modulus, exponent);
  }

  RSAPrivateKey _parsePrivate(ASN1Sequence sequence) {
    BigInt modulus = (sequence.elements[1] as ASN1Integer).valueAsBigInteger;
    BigInt exponent = (sequence.elements[3] as ASN1Integer).valueAsBigInteger;
    BigInt p = (sequence.elements[4] as ASN1Integer).valueAsBigInteger;
    BigInt q = (sequence.elements[5] as ASN1Integer).valueAsBigInteger;

    return RSAPrivateKey(modulus, exponent, p, q);
  }

  ASN1Sequence _parseSequence(List<String> rows) {
    String keyText = rows
        .skipWhile((String row) => row.startsWith('-----BEGIN'))
        .takeWhile((String row) => !row.startsWith('-----END'))
        .map((String row) => row.trim())
        .join('');

    Uint8List keyBytes = Uint8List.fromList(base64.decode(keyText));
    ASN1Parser asn1Parser = ASN1Parser(keyBytes);

    return asn1Parser.nextObject() as ASN1Sequence;
  }

  ASN1Sequence _pkcs8PublicSequence(ASN1Sequence sequence) {
    ASN1Object object = sequence.elements[1];
    List<int> bytes = object.valueBytes().sublist(1);
    ASN1Parser parser = ASN1Parser(Uint8List.fromList(bytes));

    return parser.nextObject() as ASN1Sequence;
  }

  ASN1Sequence _pkcs8PrivateSequence(ASN1Sequence sequence) {
    ASN1Object object = sequence.elements[2];
    Uint8List bytes = object.valueBytes();
    ASN1Parser parser = ASN1Parser(bytes);

    return parser.nextObject() as ASN1Sequence;
  }
}

class RsaSigner {
  RsaSigner(RSASigner rsaSigner, RSAPrivateKey privateKey)
      : _rsaSigner = rsaSigner,
        _privateKey = privateKey;

  final RSASigner _rsaSigner;
  final RSAPrivateKey _privateKey;

  List<int> sign(List<int> message) {
    _rsaSigner
      ..reset()
      ..init(true, PrivateKeyParameter<RSAPrivateKey>(_privateKey));
    RSASignature signature =
        _rsaSigner.generateSignature(Uint8List.fromList(message));
    return signature.bytes;
  }

  static RsaSigner sha1Rsa(String privateKey) {
    return RsaSigner(Signer('SHA-1/RSA') as RSASigner,
        RsaKeyParser().parsePrivate(privateKey));
  }

  static RsaSigner sha256Rsa(String privateKey) {
    return RsaSigner(Signer('SHA-256/RSA') as RSASigner,
        RsaKeyParser().parsePrivate(privateKey));
  }
}

class RsaVerifier {
  RsaVerifier(RSASigner rsaSigner, RSAPublicKey publicKey)
      : _rsaSigner = rsaSigner,
        _publicKey = publicKey;

  final RSASigner _rsaSigner;
  final RSAPublicKey _publicKey;

  bool verify(List<int> message, List<int> signature) {
    _rsaSigner
      ..reset()
      ..init(false, PublicKeyParameter<RSAPublicKey>(_publicKey));
    return _rsaSigner.verifySignature(Uint8List.fromList(message),
        RSASignature(Uint8List.fromList(signature)));
  }

  static RsaVerifier sha1Rsa(String publicKey) {
    return RsaVerifier(Signer('SHA-1/RSA') as RSASigner,
        RsaKeyParser().parsePublic(publicKey));
  }

  static RsaVerifier sha256Rsa(String publicKey) {
    return RsaVerifier(Signer('SHA-256/RSA') as RSASigner,
        RsaKeyParser().parsePublic(publicKey));
  }
}
