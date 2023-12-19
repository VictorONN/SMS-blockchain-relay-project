// ignore_for_file: prefer_const_declarations

import 'package:account_connect/services/apis.dart';
import 'package:starknet/starknet.dart';

final provider = JsonRpcProvider.infuraGoerliTestnet;
final contractAddress =
    '0x05f37f5cd15bd9a956dda9f9f40aeac2c31e6dbc9942e85b811d783e4a6558f0';
final secretAccountAddress =
    "0x00ce7b8175e1aed7e087f44e63051c053cda012d5f63fdd1e95e82489925ff41";
final secretAccountPrivateKey =
    "0x06a1b5d41b7e5fee4310fda61d7c1b11e039f4681424cc89e1e8bfffe1ed9926";
final signerAccount = getAccount(
  accountAddress: Felt.fromHexString(secretAccountAddress),
  privateKey: Felt.fromHexString(secretAccountPrivateKey),
  nodeUri: infuraGoerliTestnetUri,
);

//  late usersigneraccount;
Account? usersigneraccount;

Future<int> getUserBalance(phone) async {
  usersigneraccount = await ApiService().getUserInfo(phone).then((value) {
    if (value != null) {
      return getAccount(
        accountAddress: Felt.fromHexString(value.address),
        privateKey: Felt.fromHexString(value.privateKey),
        nodeUri: infuraGoerliTestnetUri,
      );
    } else {}
  });
  final result = await provider.call(
    request: FunctionCall(
        contractAddress: Felt.fromHexString(contractAddress),
        entryPointSelector: getSelectorByName("view_user_balance"),
        calldata: [Felt.fromHexString(usersigneraccount.toString())],),
    blockId: BlockId.latest,
  );
  return result.when(
    result: (result) => result[0].toInt(),
    error: (error) => throw Exception("Failed to get counter value"),
  );
}

Future<String> sendUserTokens(String amount) async {
  print('deposit Tokens.....');

  final res = await signerAccount.execute(functionCalls: [
    FunctionCall(
      contractAddress: Felt.fromHexString(contractAddress),
      entryPointSelector: getSelectorByName('user_send'),
      calldata: [
        Felt.fromIntString(amount),
        Felt.fromHexString("usersigneraccount")
      ],
    )
  ]);

  print(res.when(
    result: (result) => result.toString(),
    error: (error) => throw Exception(error),
  ));

  final txHash = res.when(
    result: (result) => result.transaction_hash,
    error: (err) => throw Exception("Failed to execute"),
  );
  print('Sending Tokens transaction result:$txHash');
  return txHash;
  // return waitForAcceptance(transactionHash: txHash, provider: provider);
}

Future<String> withdrawUserTokens(String amount) async {
  final res = await signerAccount.execute(functionCalls: [
    FunctionCall(
      contractAddress: Felt.fromHexString(contractAddress),
      entryPointSelector: getSelectorByName('user_withdraw'),
      calldata: [Felt.fromIntString(amount)],
    )
  ]);

  print(res.when(
    result: (result) => result.toString(),
    error: (error) => throw Exception(error),
  ));

  final txHash = res.when(
    result: (result) => result.transaction_hash,
    error: (err) => throw Exception("Failed to execute"),
  );
  print('Withdrawing Tokens transaction result:$txHash');
  return txHash;
  // return waitForAcceptance(transactionHash: txHash, provider: provider);
}

Future<int> getTotalBalance() async {
  final result = await provider.call(
    request: FunctionCall(
        contractAddress: Felt.fromHexString(contractAddress),
        entryPointSelector: getSelectorByName("view_total_balance"),
        calldata: []),
    blockId: BlockId.latest,
  );
  return result.when(
    result: (result) => result[0].toInt(),
    error: (error) => throw Exception("Failed to get counter value"),
  );
}

Future<int> getRelayerBalance() async {
  final result = await provider.call(
    request: FunctionCall(
        contractAddress: Felt.fromHexString(contractAddress),
        entryPointSelector: getSelectorByName("view_relayer_balance"),
        calldata: [Felt.fromHexString(secretAccountAddress)]),
    blockId: BlockId.latest,
  );
  return result.when(
    result: (result) => result[0].toInt(),
    error: (error) => throw Exception("Failed to get counter value"),
  );
}

Future<String> regesteringRelayer(String amount) async {
  print('regstering relayer.....');

  final res = await signerAccount.execute(functionCalls: [
    FunctionCall(
      contractAddress: Felt.fromHexString(contractAddress),
      entryPointSelector: getSelectorByName('register'),
      calldata: [Felt.fromIntString(amount)],
    )
  ]);

  print(res.when(
    result: (result) => result.toString(),
    error: (error) => throw Exception(error),
  ));

  final txHash = res.when(
    result: (result) => result.transaction_hash,
    error: (err) => throw Exception("Failed to execute"),
  );
  print('regester relayer transaction result:$txHash');
  return txHash;
  // return waitForAcceptance(transactionHash: txHash, provider: provider);
}

Future<String> depositRelayerTokens(String amount) async {
  print('deposit Tokens.....');

  final res = await signerAccount.execute(functionCalls: [
    FunctionCall(
      contractAddress: Felt.fromHexString(contractAddress),
      entryPointSelector: getSelectorByName('relayer_withdraw'),
      calldata: [Felt.fromIntString(amount)],
    )
  ]);

  print(res.when(
    result: (result) => result.toString(),
    error: (error) => throw Exception(error),
  ));

  final txHash = res.when(
    result: (result) => result.transaction_hash,
    error: (err) => throw Exception("Failed to execute"),
  );
  print('Withdrawing Tokens transaction result:$txHash');
  return txHash;
  // return waitForAcceptance(transactionHash: txHash, provider: provider);
}

Future<String> transferRelayerTokens(
    String amount, String senderAddress, String receiverAddress) async {
  print('Trasfering  Tokens.....');

  final res = await signerAccount.execute(functionCalls: [
    FunctionCall(
      contractAddress: Felt.fromHexString(contractAddress),
      entryPointSelector: getSelectorByName('relayer_withdraw'),
      calldata: [
        Felt.fromIntString(amount),
        Felt.fromHexString(senderAddress),
        Felt.fromHexString(receiverAddress)
      ],
    )
  ]);

  print(res.when(
    result: (result) => result.toString(),
    error: (error) => throw Exception(error),
  ));

  final txHash = res.when(
    result: (result) => result.transaction_hash,
    error: (err) => throw Exception("Failed to execute"),
  );
  print('Transfer Tokens transaction result:$txHash');
  return txHash;
  // return waitForAcceptance(transactionHash: txHash, provider: provider);
}

Future<String> withdrawRelayerTokens(String amount) async {
  print('withdrawing Tokens.....');

  final res = await signerAccount.execute(functionCalls: [
    FunctionCall(
      contractAddress: Felt.fromHexString(contractAddress),
      entryPointSelector: getSelectorByName('withdraw'),
      calldata: [Felt.fromIntString(amount)],
    )
  ]);

  print(res.when(
    result: (result) => result.toString(),
    error: (error) => throw Exception(error),
  ));

  final txHash = res.when(
    result: (result) => result.transaction_hash,
    error: (err) => throw Exception("Failed to execute"),
  );
  print('withdrawing Tokens transaction result:$txHash');
  return txHash;
  // return waitForAcceptance(transactionHash: txHash, provider: provider);
}
