import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class PaymobService {
  static const String _apiKey =
      'ZXlKaGJHY2lPaUpJVXpVeE1pSXNJblI1Y0NJNklrcFhWQ0o5LmV5SmpiR0Z6Y3lJNklrMWxjbU5vWVc1MElpd2ljSEp2Wm1sc1pWOXdheUk2TVRBek1UWXdPU3dpYm1GdFpTSTZJakUzTkRZd05qQTRNakF1TWpZME1UZzJJbjAuejZ6MEN6aHdQUzkwU08xRTdsLWEtRmJsNFBGR3JGMGxXbjhRWUtqeFYwazNidDRJdFZjVUgwVzFwczJaRzNCdDZ2NmhFaTh4X3RjejJmbWk2czFyTUE=';
  static const String _merchantId = '1031609';
  static const String _integrationId = '5017893';
  static const String _iframeId = '908239';

  // Add payment status constants
  static const String PAYMENT_PENDING = 'PENDING';
  static const String PAYMENT_SUCCESS = 'SUCCESS';
  static const String PAYMENT_FAILED = 'FAILED';

  static Future<String> getAuthToken() async {
    try {
      final response = await http.post(
        Uri.parse('https://accept.paymob.com/api/auth/tokens'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'api_key': _apiKey,
        }),
      );

      print('Auth Response Status: ${response.statusCode}');
      print('Auth Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        throw Exception('Failed to get auth token: ${response.body}');
      }
    } catch (e) {
      print('Error in getAuthToken: $e');
      throw Exception('Error getting auth token: $e');
    }
  }

  static Future<String> getOrderId(
      String authToken, double amount, String courseTitle) async {
    try {
      final response = await http.post(
        Uri.parse('https://accept.paymob.com/api/ecommerce/orders'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'auth_token': authToken,
          'delivery_needed': false,
          'amount_cents': (amount * 100).round(),
          'currency': 'EGP',
          'items': [
            {
              'name': courseTitle,
              'amount_cents': (amount * 100).round(),
              'description': 'Course Payment',
              'quantity': 1
            }
          ]
        }),
      );

      print('Order Response Status: ${response.statusCode}');
      print('Order Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['id'].toString();
      } else {
        throw Exception('Failed to create order: ${response.body}');
      }
    } catch (e) {
      print('Error in getOrderId: $e');
      throw Exception('Error creating order: $e');
    }
  }

  static Future<String> getPaymentKey(String authToken, String orderId,
      String userEmail, String userPhone, double amount) async {
    try {
      final response = await http.post(
        Uri.parse('https://accept.paymob.com/api/acceptance/payment_keys'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'auth_token': authToken,
          'amount_cents': (amount * 100).round(),
          'expiration': 3600,
          'order_id': orderId,
          'billing_data': {
            'apartment': 'NA',
            'email': userEmail,
            'floor': 'NA',
            'first_name': 'NA',
            'street': 'NA',
            'building': 'NA',
            'phone_number': userPhone,
            'shipping_method': 'NA',
            'postal_code': 'NA',
            'city': 'NA',
            'country': 'EG',
            'last_name': 'NA',
            'state': 'NA'
          },
          'currency': 'EGP',
          'integration_id': _integrationId,
        }),
      );

      print('Payment Key Response Status: ${response.statusCode}');
      print('Payment Key Response Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        throw Exception('Failed to get payment key: ${response.body}');
      }
    } catch (e) {
      print('Error in getPaymentKey: $e');
      throw Exception('Error getting payment key: $e');
    }
  }

  static Future<void> launchPaymentFrame(String paymentKey) async {
    try {
      final iframeUrl =
          'https://accept.paymob.com/api/acceptance/iframes/$_iframeId?payment_token=$paymentKey';
      print('Launching URL: $iframeUrl');

      if (await canLaunchUrl(Uri.parse(iframeUrl))) {
        await launchUrl(
          Uri.parse(iframeUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw Exception('Could not launch payment frame');
      }
    } catch (e) {
      print('Error in launchPaymentFrame: $e');
      throw Exception('Error launching payment frame: $e');
    }
  }

  static Future<String> checkPaymentStatus(String orderId) async {
    try {
      print('Getting auth token for payment status check...');
      final authToken = await getAuthToken();

      print('Checking payment status for order: $orderId');
      final response = await http.get(
        Uri.parse(
            'https://accept.paymob.com/api/acceptance/transactions?order_id=$orderId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': authToken,
        },
      );

      print('Payment Status Response Code: ${response.statusCode}');
      print('Payment Status Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final transaction = data['results'][0];

          // تسجيل كل البيانات المهمة
          print('Full transaction data: $transaction');

          final success = transaction['success'] ?? false;
          final isPending = transaction['pending'] ?? false;
          final isVoided = transaction['is_voided'] ?? false;
          final isRefunded = transaction['is_refunded'] ?? false;
          final is3DSecure = transaction['is_3d_secure'] ?? false;
          final isCaptured = transaction['is_captured'] ?? false;
          final isAuth = transaction['is_auth'] ?? false;
          final amount = transaction['amount_cents'] ?? 0;

          print('Transaction details:');
          print('- Success: $success');
          print('- Pending: $isPending');
          print('- Voided: $isVoided');
          print('- Refunded: $isRefunded');
          print('- 3D Secure: $is3DSecure');
          print('- Captured: $isCaptured');
          print('- Auth: $isAuth');
          print('- Amount: $amount');

          // تحسين شروط نجاح الدفع
          if (success ||
              isCaptured ||
              isAuth ||
              (amount > 0 && !isVoided && !isRefunded && !isPending)) {
            return PAYMENT_SUCCESS;
          } else if (isPending) {
            return PAYMENT_PENDING;
          }
        }
      }
      return PAYMENT_FAILED;
    } catch (e) {
      print('Error checking payment status: $e');
      return PAYMENT_FAILED;
    }
  }

  static Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String courseTitle,
    required String userEmail,
    required String userPhone,
  }) async {
    try {
      print('Starting payment process...');
      print('Amount: $amount');
      print('Course: $courseTitle');
      print('Email: $userEmail');
      print('Phone: $userPhone');

      // Step 1: Get authentication token
      final authToken = await getAuthToken();
      print('Got auth token: $authToken');

      // Step 2: Create order
      final orderId = await getOrderId(authToken, amount, courseTitle);
      print('Got order ID: $orderId');

      // Step 3: Get payment key
      final paymentKey = await getPaymentKey(
        authToken,
        orderId,
        userEmail,
        userPhone,
        amount,
      );
      print('Got payment key: $paymentKey');

      // Step 4: Launch payment frame
      await launchPaymentFrame(paymentKey);

      // Step 5: Wait for payment completion
      print('Waiting for payment completion...');

      // إضافة تأخير قصير قبل بدء التحقق
      await Future.delayed(Duration(seconds: 3));

      final paymentResult = await waitForPaymentCompletion(orderId);
      print('Payment result: $paymentResult');

      if (paymentResult['status'] == PAYMENT_SUCCESS) {
        return {
          'status': PAYMENT_SUCCESS,
          'order_id': orderId,
          'message': 'تم الدفع بنجاح',
          'is_verified': true,
        };
      }

      return paymentResult;
    } catch (e) {
      print('Error in processPayment: $e');
      return {
        'status': PAYMENT_FAILED,
        'error': 'حدث خطأ أثناء عملية الدفع: $e',
        'is_verified': false,
      };
    }
  }

  static Future<Map<String, dynamic>> waitForPaymentCompletion(
      String orderId) async {
    int attempts = 0;
    const maxAttempts =
        30; // تقليل عدد المحاولات لكن زيادة وقت الانتظار بين كل محاولة
    const delaySeconds = 4; // زيادة وقت الانتظار بين المحاولات

    print('Starting to wait for payment completion for order: $orderId');

    while (attempts < maxAttempts) {
      print(
          'Checking payment status - Attempt ${attempts + 1} of $maxAttempts');

      await Future.delayed(Duration(seconds: delaySeconds));
      String status = await checkPaymentStatus(orderId);
      print('Payment status for order $orderId: $status');

      if (status == PAYMENT_SUCCESS) {
        print('Payment completed successfully for order: $orderId');
        return {
          'status': PAYMENT_SUCCESS,
          'order_id': orderId,
          'message': 'تم الدفع بنجاح',
          'is_verified': true,
        };
      }

      // إذا كانت العملية فاشلة، نحاول مرة أخرى
      attempts++;
    }

    // تحقق نهائي قبل اعتبار العملية فاشلة
    String finalStatus = await checkPaymentStatus(orderId);
    if (finalStatus == PAYMENT_SUCCESS) {
      return {
        'status': PAYMENT_SUCCESS,
        'order_id': orderId,
        'message': 'تم الدفع بنجاح',
        'is_verified': true,
      };
    }

    print('Payment verification timeout for order: $orderId');
    return {
      'status': PAYMENT_FAILED,
      'order_id': orderId,
      'error': 'لم نتمكن من التحقق من حالة الدفع',
      'is_verified': false,
    };
  }
}
