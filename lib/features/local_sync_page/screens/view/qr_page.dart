import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';


class QrCodePage extends ConsumerWidget {
  const QrCodePage({super.key});

  @override
  Widget build(BuildContext context, ref) {


    final avtarRadius = 40.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('QR code'), leading: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),

      ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {

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
                          Text("User Name", style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey.shade800)),
                          Text("LanternChat Contact", style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey.shade800)),
                          // SizedBox(height: 10,),
                          Container(
                            color: Colors.white,
                            height: 200,
                            width: 200,
                            child: QrImageView(data: "919.9191.029"),
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
                    child: CircleAvatar()
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
                // context.push(AppRoute.qrScan);
              },
              child: Text("Scan QR"),
            ),
          ],
        ),
      ),


    );
  }
}
