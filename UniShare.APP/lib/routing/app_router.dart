import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/listings/presentation/screens/home_screen.dart';
import '../features/listings/presentation/screens/search_screen.dart';
import '../features/listings/presentation/screens/listing_detail_screen.dart';
import '../features/listings/presentation/screens/create_listing_screen.dart';
import '../features/listings/presentation/screens/edit_listing_screen.dart';
import '../features/listings/presentation/screens/my_listings_screen.dart';
import '../features/images/presentation/screens/manage_images_screen.dart';
import '../features/comments/presentation/screens/comments_screen.dart';
import '../features/conversations/presentation/screens/conversation_list_screen.dart';
import '../features/conversations/presentation/screens/chat_detail_screen.dart';
import '../features/rentals/presentation/screens/rental_request_detail_screen.dart';
import '../features/rentals/presentation/screens/rental_request_form_screen.dart';
import '../features/rentals/presentation/screens/my_requests_screen.dart';
import '../features/deposits/presentation/screens/deposit_status_screen.dart';
import '../features/reviews/presentation/screens/review_form_screen.dart';
import '../features/notifications/presentation/screens/notifications_screen.dart';
import '../features/users/presentation/screens/profile_screen.dart';
import '../features/users/presentation/screens/edit_profile_screen.dart';
import '../features/users/presentation/screens/public_profile_screen.dart';
import 'main_shell.dart';

/// GoRouter configuration for UniShare.
///
/// Uses a ReadProviderScope to access Riverpod providers during redirect.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isSplash = state.matchedLocation == '/';
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      // Splash handles its own redirect
      if (isSplash) return null;

      // Routes always accessible
      final publicRoutes = ['/login', '/register', '/home', '/search'];
      final isPublic = publicRoutes.any(
        (route) => state.matchedLocation.startsWith(route),
      );

      // Sub-routes under /home and /search are also public
      final isListingDetail =
          state.matchedLocation.contains('/listings/');
      final isComments = state.matchedLocation.contains('/comments');
      final isPublicProfile =
          state.matchedLocation.contains('/users/');

      if (isListingDetail || isComments || isPublicProfile) {
        return null;
      }

      if (isPublic) return null;

      // Auth state handling
      if (authState is AuthInitial || authState is AuthLoading) {
        // Wait for auth to resolve — splash will handle this
        if (isAuthRoute) return null;
        return null;
      }

      if (authState is AuthUnauthenticated) {
        if (isAuthRoute) return null;
        // Allow browsing as guest on public routes only
        return '/login';
      }

      if (authState is AuthAuthenticated) {
        if (isAuthRoute) return '/home';
        return null;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      // Deep-link routes (outside shell)
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/users/:userId',
        builder: (context, state) => PublicProfileScreen(
          userId: state.pathParameters['userId']!,
        ),
      ),
      // Top-level rental request detail
      GoRoute(
        path: '/requests/:requestId',
        builder: (context, state) => RentalRequestDetailScreen(
          requestId: state.pathParameters['requestId']!,
        ),
        routes: [
          GoRoute(
            path: 'deposit',
            builder: (context, state) => DepositStatusScreen(
              requestId: state.pathParameters['requestId']!,
            ),
          ),
          GoRoute(
            path: 'review',
            builder: (context, state) => ReviewFormScreen(
              requestId: state.pathParameters['requestId']!,
              revieweeName:
                  (state.extra as Map?)?['revieweeName'] as String?,
              revieweeAvatarUrl:
                  (state.extra as Map?)?['revieweeAvatarUrl'] as String?,
            ),
          ),
        ],
      ),
      // Shell route with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // --- Home Stack ---
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'listings/:listingId',
                builder: (context, state) => ListingDetailScreen(
                  listingId: state.pathParameters['listingId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'comments',
                    builder: (context, state) => CommentsScreen(
                      listingId: state.pathParameters['listingId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'request',
                    builder: (context, state) => RentalRequestFormScreen(
                      listingId: state.pathParameters['listingId']!,
                      listingTitle:
                          (state.extra as Map?)?['listingTitle'] as String? ??
                              '',
                      listingPricePerDay:
                          (state.extra as Map?)?['listingPricePerDay']
                                  as double? ??
                              0,
                      listingDepositAmount:
                          (state.extra as Map?)?['listingDepositAmount']
                                  as double? ??
                              0,
                      listingType:
                          (state.extra as Map?)?['listingType'] as String? ??
                              'rent',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // --- Search Stack ---
          GoRoute(
            path: '/search',
            builder: (context, state) => const SearchScreen(),
            routes: [
              GoRoute(
                path: 'listings/:listingId',
                builder: (context, state) => ListingDetailScreen(
                  listingId: state.pathParameters['listingId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'comments',
                    builder: (context, state) => CommentsScreen(
                      listingId: state.pathParameters['listingId']!,
                    ),
                  ),
                  GoRoute(
                    path: 'request',
                    builder: (context, state) => RentalRequestFormScreen(
                      listingId: state.pathParameters['listingId']!,
                      listingTitle:
                          (state.extra as Map?)?['listingTitle'] as String? ??
                              '',
                      listingPricePerDay:
                          (state.extra as Map?)?['listingPricePerDay']
                                  as double? ??
                              0,
                      listingDepositAmount:
                          (state.extra as Map?)?['listingDepositAmount']
                                  as double? ??
                              0,
                      listingType:
                          (state.extra as Map?)?['listingType'] as String? ??
                              'rent',
                    ),
                  ),
                ],
              ),
            ],
          ),

          // --- Post Stack ---
          GoRoute(
            path: '/post/create',
            builder: (context, state) => const CreateListingScreen(),
            routes: [
              GoRoute(
                path: 'images',
                builder: (context, state) => const ManageImagesScreen(),
              ),
            ],
          ),

          // --- Chat Stack ---
          GoRoute(
            path: '/chat',
            builder: (context, state) => const ConversationListScreen(),
            routes: [
              GoRoute(
                path: ':conversationId',
                builder: (context, state) => ChatDetailScreen(
                  conversationId: state.pathParameters['conversationId']!,
                ),
              ),
            ],
          ),

          // --- Profile Stack ---
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'my-listings',
                builder: (context, state) => const MyListingsScreen(),
                routes: [
                  GoRoute(
                    path: 'listings/:listingId/edit',
                    builder: (context, state) => EditListingScreen(
                      listingId: state.pathParameters['listingId']!,
                    ),
                  ),
                ],
              ),
              GoRoute(
                path: 'my-requests',
                builder: (context, state) => const MyRequestsScreen(),
                routes: [
                  GoRoute(
                    path: 'requests/:requestId',
                    builder: (context, state) =>
                        RentalRequestDetailScreen(
                      requestId: state.pathParameters['requestId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'deposit',
                        builder: (context, state) => DepositStatusScreen(
                          requestId: state.pathParameters['requestId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'review',
                        builder: (context, state) {
                          final extra = state.extra as Map?;
                          return ReviewFormScreen(
                            requestId: state.pathParameters['requestId']!,
                            revieweeName: extra?['revieweeName'] as String?,
                            revieweeAvatarUrl: extra?['revieweeAvatarUrl'] as String?,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
