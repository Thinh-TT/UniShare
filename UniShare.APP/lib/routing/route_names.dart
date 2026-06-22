/// Named route path constants used by GoRouter.
class RouteNames {
  RouteNames._();

  // Auth
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';

  // Home tab
  static const String home = '/home';

  // Search tab
  static const String search = '/search';

  // Post tab
  static const String createListing = '/post/create';
  static const String manageImages = '/post/manage-images';

  // Chat tab
  static const String conversations = '/chat';

  // Profile tab
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String myListings = '/profile/my-listings';
  static const String myRequests = '/profile/my-requests';

  // Sub-routes (pushed onto stacks)
  static const String listingDetail = 'listings/:listingId';
  static const String comments = 'comments';
  static const String rentalRequest = 'request';
  static const String editListing = 'listings/:listingId/edit';
  static const String chatDetail = ':conversationId';
  static const String requestDetail = 'requests/:requestId';

  // Top-level routes for deep linking
  static const String notifications = '/notifications';
  static const String publicProfile = '/users/:userId';
}
