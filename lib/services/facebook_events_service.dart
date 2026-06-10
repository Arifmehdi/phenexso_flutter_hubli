import 'package:facebook_app_events/facebook_app_events.dart';
import 'package:flutter/foundation.dart';

class FacebookEventsService {
  static final FacebookAppEvents _facebookAppEvents = FacebookAppEvents();

  static Future<void> logViewContent({
    required String id,
    required String type,
    required String currency,
    required double price,
  }) async {
    try {
      await _facebookAppEvents.logViewContent(
        id: id,
        type: type,
        currency: currency,
        price: price,
      );
      debugPrint('FB Event: ViewContent - $id');
    } catch (e) {
      debugPrint('FB Event Error: $e');
    }
  }

  static Future<void> logAddToCart({
    required String id,
    required String type,
    required String currency,
    required double price,
  }) async {
    try {
      await _facebookAppEvents.logAddToCart(
        id: id,
        type: type,
        currency: currency,
        price: price,
      );
      debugPrint('FB Event: AddToCart - $id');
    } catch (e) {
      debugPrint('FB Event Error: $e');
    }
  }

  static Future<void> logAddToWishlist({
    required String id,
    required String type,
    required String currency,
    required double price,
  }) async {
    try {
      await _facebookAppEvents.logAddToWishlist(
        id: id,
        type: type,
        currency: currency,
        price: price,
      );
      debugPrint('FB Event: AddToWishlist - $id');
    } catch (e) {
      debugPrint('FB Event Error: $e');
    }
  }

  static Future<void> logInitiatedCheckout({
    required double totalPrice,
    required String currency,
    required String contentType,
    required String contentId,
    required int numItems,
  }) async {
    try {
      await _facebookAppEvents.logInitiatedCheckout(
        totalPrice: totalPrice,
        currency: currency,
        contentType: contentType,
        contentId: contentId,
        numItems: numItems,
      );
      debugPrint('FB Event: InitiatedCheckout - $contentId');
    } catch (e) {
      debugPrint('FB Event Error: $e');
    }
  }

  static Future<void> logPurchase({
    required double amount,
    required String currency,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _facebookAppEvents.logPurchase(
        amount: amount,
        currency: currency,
        parameters: parameters,
      );
      debugPrint('FB Event: Purchase - $amount $currency');
    } catch (e) {
      debugPrint('FB Event Error: $e');
    }
  }

  static Future<void> logSearch({
    required String contentType,
    required String contentId,
    required String searchText,
    required bool success,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'fb_mobile_search',
        parameters: {
          'fb_content_type': contentType,
          'fb_content_id': contentId,
          'fb_search_string': searchText,
          'fb_success': success ? 1 : 0,
        },
      );
      debugPrint('FB Event: Search - $searchText');
    } catch (e) {
      debugPrint('FB Event Error: $e');
    }
  }

  static Future<void> logAddPaymentInfo({
    required bool success,
  }) async {
    try {
      await _facebookAppEvents.logEvent(
        name: 'fb_mobile_add_payment_info',
        parameters: {
          'fb_success': success ? 1 : 0,
        },
      );
      debugPrint('FB Event: AddPaymentInfo - $success');
    } catch (e) {
      debugPrint('FB Event Error: $e');
    }
  }
}
