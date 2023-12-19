import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:starknet_flutter/starknet_flutter.dart';

class CryptoBalanceCellWidget extends StatelessWidget {
  final String name;
  final String symbolIconUrl;
  final double balance;
  final int offrampbalance;
  final int relayerbalance;
  final num fiatPrice;

  const CryptoBalanceCellWidget({
    Key? key,
    required this.name,
    required this.symbolIconUrl,
    required this.balance,
    required this.offrampbalance,
    required this.relayerbalance,
    required this.fiatPrice,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        // Image.network(
        //   symbolIconUrl,
        //   width: 35,
        //   height: 35,
        // ),
     Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Sasapay',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'KSH ${offrampbalance.truncateBalance()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(width: 35),
         Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Relayer/contract',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'USD ${relayerbalance}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(width: 65),
        // Expanded(
        //   child: Text(
        //     name,
        //     style: GoogleFonts.poppins(
        //       fontSize: 16,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        // ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Argent',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '\$${fiatPrice.truncateBalance(precision: 2).format()}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 14,
              ),
            ),
            // Text(
            //   'fiat price -> ${balance.truncateBalance()} ETH',
            //   maxLines: 1,
            //   overflow: TextOverflow.ellipsis,
            //   style: GoogleFonts.poppins(
            //     fontSize: 14,
            //   ),
            // ),
          ],
        ),
        
      ],
    );
  }
}
