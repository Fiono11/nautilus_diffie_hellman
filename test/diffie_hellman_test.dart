import 'package:nanodart/nanodart.dart';
import 'package:nautilus_diffie_hellman/diffie_hellman.dart';

Future<void> main() async {
  /// Generating a random seed
  String senderSeed = NanoSeeds.generateSeed();
  // Getting private key at index-0 of this seed
  String senderPrivateKey = NanoKeys.seedToPrivate(senderSeed, 0);
  // Getting public key from this private key
  String senderPubKey = NanoKeys.createPublicKey(senderPrivateKey);
  // Getting address (nano_, ban_) from this pubkey
  String senderAddress =
      NanoAccounts.createAccount(NanoAccountType.NANO, senderPubKey);

  // Generating a random seed
  String receiverSeed = NanoSeeds.generateSeed();
  // Getting private key at index-0 of this seed
  String receiverPrivateKey = NanoKeys.seedToPrivate(receiverSeed, 0);
  // Getting public key from this private key
  String receiverPubKey = NanoKeys.createPublicKey(receiverPrivateKey);
  // Getting address (nano_, ban_) from this pubkey
  String receiverAddress =
      NanoAccounts.createAccount(NanoAccountType.NANO, receiverPubKey);

  var message = "message";
  var encrypted_message =
      DiffieHellman.encrypt(message, senderAddress, receiverPrivateKey);
  var decrypted_message = DiffieHellman.decrypt(
      encrypted_message, receiverAddress, senderPrivateKey);

  assert(message == decrypted_message);
}
