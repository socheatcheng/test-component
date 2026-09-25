// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:url_launcher/url_launcher.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Fake Bank',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
//         useMaterial3: true,
//       ),
//       home: const FakeBankPage(),
//     );
//   }
// }

// class FakeBankPage extends StatefulWidget {
//   const FakeBankPage({super.key});

//   @override
//   State<FakeBankPage> createState() => _FakeBankPageState();
// }

// class _FakeBankPageState extends State<FakeBankPage> {
//   static const String _successLink =
//       'https://link-uat.khemranexus.com/payment?requestId=7b40a961-7d62-4943-b3c8-c149784a81df&status=success';
//   static const String _failLink =
//       'https://link-uat.khemranexus.com/payment?requestId=7b40a961-7d62-4943-b3c8-c149784a81df&status=fail';

//   bool _isLaunchingSuccess = false;
//   bool _isLaunchingFail = false;

//   Uri? _incomingLink;

//   @override
//   void initState() {
//     super.initState();
//     _handleIncomingLinks();
//   }

//   void _handleIncomingLinks() {
//     ServicesBinding.instance.defaultBinaryMessenger.setMessageHandler(
//       'flutter/navigation',
//       (ByteData? message) async {
//         if (message == null) return null;
//         final String route = const StringCodec().decodeMessage(message) ?? '';
//         final uri = Uri.tryParse(route);
//         if (uri != null && uri.scheme == 'fakebank') {
//           _onDeepLink(uri);
//         }
//         return null;
//       },
//     );
//   }

//   /// Called whenever a fakebank:// deep link arrives (cold or warm start).
//   void _onDeepLink(Uri uri) {
//     debugPrint('Received deep link from Khemra: $uri');
//     if (mounted) {
//       setState(() => _incomingLink = uri);
//     }
//   }

//   Future<void> _launchDeepLink(String url, {required bool isSuccess}) async {
//     final uri = Uri.parse(url);

//     debugPrint('Payment ${isSuccess ? "Successful" : "Failed"}');
//     debugPrint('URL: $url');
//     debugPrint('Opening Khemra app...');

//     setState(() {
//       if (isSuccess) {
//         _isLaunchingSuccess = true;
//       } else {
//         _isLaunchingFail = true;
//       }
//     });

//     try {
//       bool launched = false;
//       launched = await launchUrl(uri, mode: LaunchMode.externalNonBrowserApplication);

//       if (!launched && mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Could not open the link. Please try again.'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint('ERROR launching deep link: $e');
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to open Khemra app: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           if (isSuccess) {
//             _isLaunchingSuccess = false;
//           } else {
//             _isLaunchingFail = false;
//           }
//         });
//       }
//     }
//   }

//   Future<void> _onPaymentSuccessful() =>
//       _launchDeepLink(_successLink, isSuccess: true);

//   Future<void> _onPaymentFailed() =>
//       _launchDeepLink(_failLink, isSuccess: false);

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isBusy = _isLaunchingSuccess || _isLaunchingFail;
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Fake Bank'),
//         backgroundColor: theme.colorScheme.inversePrimary,
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 32),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               // ── Incoming deep-link banner (shown when Khemra opened this app)
//               if (_incomingLink != null) ...[
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.indigo.shade50,
//                     border: Border.all(color: Colors.indigo.shade200),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const Text(
//                         '📲 Opened by Khemra',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 14,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Text(
//                         'Link: $_incomingLink',
//                         style: const TextStyle(fontSize: 12),
//                       ),
//                       if (_incomingLink!.queryParameters.isNotEmpty) ...[
//                         const SizedBox(height: 4),
//                         Text(
//                           'Params: ${_incomingLink!.queryParameters}',
//                           style: const TextStyle(fontSize: 12),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//               ],

//               // ── Payment Successful button ──────────────────────────────
//               FilledButton.icon(
//                 onPressed: isBusy ? null : _onPaymentSuccessful,
//                 icon: _isLaunchingSuccess
//                     ? const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       )
//                     : const Icon(Icons.check_circle_outline),
//                 label: const Text('Payment Successful'),
//                 style: FilledButton.styleFrom(
//                   backgroundColor: Colors.green,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   textStyle: const TextStyle(fontSize: 16),
//                 ),
//               ),
//               const SizedBox(height: 12),

//               // ── Payment Failed button ────────────────────────────────
//               FilledButton.icon(
//                 onPressed: isBusy ? null : _onPaymentFailed,
//                 icon: _isLaunchingFail
//                     ? const SizedBox(
//                         width: 18,
//                         height: 18,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.white,
//                         ),
//                       )
//                     : const Icon(Icons.cancel_outlined),
//                 label: const Text('Payment Failed'),
//                 style: FilledButton.styleFrom(
//                   backgroundColor: Colors.red,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   textStyle: const TextStyle(fontSize: 16),
//                 ),
//               ),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:id_scanner/id_scanner.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fake Bank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
        ),
        useMaterial3: true,
      ),
      home: const FakeBankPage(),
    );
  }
}

class FakeBankPage extends StatefulWidget {
  const FakeBankPage({super.key});

  @override
  State<FakeBankPage> createState() => _FakeBankPageState();
}

class _FakeBankPageState extends State<FakeBankPage> {
  KhemraScanResult? _result;
  bool _isScanning = false;

  Future<void> _openScanner() async {
    setState(() {
      _isScanning = true;
    });

    try {
      final result = await Navigator.of(context).push<KhemraScanResult>(
        MaterialPageRoute(
          builder: (_) => const KhemraScannerScreen(),
        ),
      );

      if (!mounted) return;

      if (result != null) {
        setState(() {
          _result = result;
        });

        debugPrint('Scanner result: $result');
      }
    } catch (e, stackTrace) {
      debugPrint('Scanner error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scanner failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isScanning = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fake Bank'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.document_scanner_outlined,
                size: 80,
              ),

              const SizedBox(height: 24),

              const Text(
                'ID Card Scanner',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Scan a Cambodian ID card using the reusable scanner component.',
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              FilledButton.icon(
                onPressed: _isScanning ? null : _openScanner,
                icon: _isScanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.camera_alt_outlined),
                label: Text(
                  _isScanning ? 'Opening Scanner...' : 'Scan ID Card',
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),

              const SizedBox(height: 24),

              if (_result != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border.all(
                      color: Colors.green.shade200,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Scan Result',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _result.toString(),
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
