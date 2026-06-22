/// Centralized API endpoint path constants.
///
/// All paths are relative to the base URL (e.g. /api/v1).
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh-token';
  static const String logout = '/auth/logout';

  // Users
  static const String myProfile = '/users/me';
  static const String users = '/users'; // + /{userId}
  static String userById(String userId) => '/users/$userId';
  static String userReviews(String userId) => '/users/$userId/reviews';

  // Listings
  static const String listings = '/listings';
  static String listingById(String listingId) => '/listings/$listingId';
  static String closeListing(String listingId) =>
      '/listings/$listingId/close';
  static const String myListings = '/me/listings';

  // Listing images
  static String listingImages(String listingId) =>
      '/listings/$listingId/images';
  static String coverImage(String listingId, String imageId) =>
      '/listings/$listingId/images/$imageId/cover';
  static String imageOrder(String listingId) =>
      '/listings/$listingId/images/order';
  static String deleteImage(String listingId, String imageId) =>
      '/listings/$listingId/images/$imageId';

  // Upvotes
  static String upvote(String listingId) => '/listings/$listingId/upvote';

  // Comments
  static String comments(String listingId) =>
      '/listings/$listingId/comments';
  static String commentById(String commentId) => '/comments/$commentId';

  // Conversations
  static String conversations(String listingId) =>
      '/listings/$listingId/conversations';
  static const String myConversations = '/me/conversations';
  static String conversationById(String conversationId) =>
      '/conversations/$conversationId';
  static String messages(String conversationId) =>
      '/conversations/$conversationId/messages';
  static String markRead(String conversationId) =>
      '/conversations/$conversationId/messages/read';

  // Rental requests
  static String rentalRequests(String listingId) =>
      '/listings/$listingId/rental-requests';
  static const String myRentalRequests = '/me/rental-requests';
  static String rentalRequestById(String requestId) =>
      '/rental-requests/$requestId';
  static String acceptRequest(String requestId) =>
      '/rental-requests/$requestId/accept';
  static String rejectRequest(String requestId) =>
      '/rental-requests/$requestId/reject';
  static String cancelRequest(String requestId) =>
      '/rental-requests/$requestId/cancel';
  static String startRequest(String requestId) =>
      '/rental-requests/$requestId/start';
  static String completeRequest(String requestId) =>
      '/rental-requests/$requestId/complete';

  // Deposits
  static String depositByRequest(String requestId) =>
      '/rental-requests/$requestId/deposit';
  static String markDepositPaid(String depositId) =>
      '/deposits/$depositId/mark-paid';
  static String refundDeposit(String depositId) =>
      '/deposits/$depositId/refund';

  // Reviews
  static String reviews(String requestId) =>
      '/rental-requests/$requestId/reviews';

  // Notifications
  static const String myNotifications = '/me/notifications';
  static const String unreadCount = '/me/notifications/unread-count';
  static String markNotificationRead(String notificationId) =>
      '/me/notifications/$notificationId/read';
  static const String markAllNotificationsRead =
      '/me/notifications/read-all';

  // Reference data
  static const String categories = '/categories';
  static const String tags = '/tags';
  static const String schools = '/schools';
  static const String areas = '/areas';
}
