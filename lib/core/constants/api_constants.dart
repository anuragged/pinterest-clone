/// API configuration constants.
/// Replace the placeholder keys with your actual API keys.
class ApiConstants {
  ApiConstants._();

  // Pexels API
  static const String pexelsBaseUrl = 'https://api.pexels.com/v1';
  static const String pexelsApiKey = '2STteFgvjIpv5h2U9Ef6hiQwSriYRFgukhOll3OpV6kk3DpGRkpdZCHo'; // Replace with your key
  static const int pexelsPerPage = 20;

  // Unsplash fallback
  static const String unsplashBaseUrl = 'https://api.unsplash.com';
  static const String unsplashAccessKey = 'YOUR_UNSPLASH_ACCESS_KEY'; // Fallback only

  // Clerk Auth
  static const String clerkPublishableKey = 'YOUR_CLERK_PUBLISHABLE_KEY';

  // Timeouts
  static const int connectTimeout = 10000; // ms
  static const int receiveTimeout = 15000; // ms

  // Pagination
  static const int feedPageSize = 20;
  static const int searchPageSize = 20;
  static const int relatedPinsPageSize = 10;

  // Prefetch threshold (70% of list)
  static const double prefetchThreshold = 0.7;

  // Cache
  static const int maxCachedImages = 200;
  static const int maxCachedSearchHistory = 20;
}
