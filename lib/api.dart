import 'dart:async';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:payparkingv4/app_update.dart';
import 'package:retry/retry.dart';

Future checkUpdate(String version) async {
  var url = Uri.parse(AppUpdateVersion.urlCICheckUpdate + "app_update/CheckUpdate");

  print('Sending version: $version'); // Log the version being sent

  try {
    final response = await retry(
          () => http.post(
        url,
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json", // This tells the server to expect JSON
            },
        body: jsonEncode({'version': version}),
      ).timeout(Duration(seconds: 5)),
      retryIf: (e) => e is http.ClientException || e is TimeoutException,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}'); // Log the response for debugging

    if (response.statusCode == 200) {
      var decodedResponse = jsonDecode(response.body);

      // Check if 'version' exists in the response
      if (decodedResponse is Map && decodedResponse.containsKey('version')) {
        return decodedResponse['version'];  // Return only the version number
      } else {
        throw Exception('Version key not found in response');
      }
    } else {
      throw Exception('Failed to check for update: ${response.statusCode}');
    }
  } catch (e) {
    print('Error occurred: $e');
    return null;
  }
}


// void showErrorDialog(String message) {
//   showDialog(
//     context: context,  // Ensure you have access to context
//     builder: (context) {
//       return AlertDialog(
//         title: Text("Error"),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//             },
//             child: Text("OK"),
//           ),
//         ],
//       );
//     },
//   );
// }

