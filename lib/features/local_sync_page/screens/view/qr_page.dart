import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lanternchat/core/router/router_provider.dart';
import 'package:lanternchat/features/auth/provider/auth_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/constant_strings.dart';
import '../../../../shared/widgets/circular_user_avatar.dart';
import '../../../../shared/widgets/online_status.dart';

class QrCodePage extends ConsumerWidget {
  const QrCodePage({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final currentUser = ref.read(currentUserProvider);

    final avtarRadius = 40.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('QR code'), leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: OnlineUserPresence(uid: currentUser.uid, showOnlyDot: true),
      ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              final String shareMessage =
                  "Hey! 👋\n\nAdd me on LanternChat.\nMy User ID: ${currentUser.uid}\nSearch this ID in the app to connect with me.\n https://github.com/AshwaniDev101/Flutter-LanternChat";
              SharePlus.instance.share(ShareParams(text: shareMessage));
            },
            icon: Icon(Icons.share),
          ),
          // IconButton(onPressed: () {}, icon: Icon(Icons.more_vert_rounded)),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Card(

                    color: Colors.white,

                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 20 + avtarRadius, 20, 20),
                      child: Column(
                        children: [
                          // SizedBox(height: avtarRadius,),
                          Text(currentUser.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade800)),
                          Text("LanternChat Contact", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade800)),
                          // SizedBox(height: 10,),
                          Container(
                            color: Colors.white,
                            height: 200,
                            width: 200,
                            child: QrImageView(data: "${ConstantString.appName}/${currentUser.uid}"),
                            // child: Image.network(
                            //   'https://www.freepnglogos.com/uploads/qr-code-png/qr-code-file-bangla-mobile-code-0.png',
                            // ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    top: -avtarRadius,
                    child: CircularUserAvatar(imageUrl: currentUser.photoURL, radius: avtarRadius),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'Your QR code is private. If you share it with someone, they can scan it with their LanternChat Camera to add you as a contact',
              ),
            ),

            ElevatedButton(
              onPressed: () {
                context.push(AppRoute.qrScan);
              },
              child: Text("Scan QR"),
            ),
          ],
        ),
      ),

      // body: DefaultTabController(
      //   length: 2,
      //   // initialIndex: 1,
      //   // A scrollable widgets MUST know its size in the non-scroll direction.
      //   child: Column(
      //     children: [
      //       TabBar(
      //         tabs: [
      //           Tab(child: Text("QR CODE")),
      //           Tab(child: Text("SCAN CODE")),
      //         ],
      //       ),
      //       Expanded(child: TabBarView(children: [ShowQrTab(), ScanQrTab()])),
      //     ],
      //   ),
      // ),
    );
  }
}
