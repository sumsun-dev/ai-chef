import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/ingredient.dart';
import 'models/recipe.dart';
import 'models/recipe_quick_filter.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/camera_screen.dart';
import 'screens/ingredient_add_screen.dart';
import 'screens/ingredient_review_screen.dart';
import 'screens/receipt_scan_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/cooking_mode_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/profile/chef_selection_screen.dart';
import 'screens/profile/cooking_tools_screen.dart';
import 'screens/profile/profile_edit_screen.dart';
import 'screens/expiry_alert_screen.dart';
import 'screens/settings/notification_settings_screen.dart';
import 'screens/settings/privacy_screen.dart';
import 'screens/settings/help_screen.dart';
import 'screens/main_shell.dart';
import 'screens/tabs/home_tab.dart';
import 'screens/tabs/recipe_tab.dart';
import 'screens/tabs/refrigerator_tab.dart';
import 'screens/tabs/profile_tab.dart';

/// 앱 라우터 Provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isLoginRoute = state.matchedLocation == '/login';
      final isOnboardingRoute = state.matchedLocation == '/onboarding';

      debugPrint('[Router] redirect: location=${state.matchedLocation}, loggedIn=$isLoggedIn');

      // 로그인 안 됨 -> 로그인 페이지로
      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }

      // 로그인 됨 + 로그인 페이지 -> 홈으로
      if (isLoggedIn && isLoginRoute) {
        return '/';
      }

      // 로그인 됨 + 메인 페이지 -> 온보딩 체크
      if (isLoggedIn && !isOnboardingRoute && state.matchedLocation == '/') {
        try {
          final userId = Supabase.instance.client.auth.currentUser?.id;
          if (userId != null) {
            final profile = await Supabase.instance.client
                .from('user_profiles')
                .select('ai_chef_name')
                .eq('id', userId)
                .maybeSingle();
            debugPrint('[Router] profile check: ai_chef_name=${profile?['ai_chef_name']}');
            if (profile == null || profile['ai_chef_name'] == null) {
              debugPrint('[Router] → /onboarding (no chef name)');
              return '/onboarding';
            }
          }
        } catch (e) {
          debugPrint('[Router] profile check error: $e');
          // profile check failed - continue to home
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/camera',
        builder: (context, state) => const CameraScreen(),
      ),
      GoRoute(
        path: '/ingredient/add',
        builder: (context, state) => const IngredientAddScreen(),
      ),
      GoRoute(
        path: '/ingredient/edit',
        builder: (context, state) {
          final ingredient = state.extra as Ingredient?;
          return IngredientAddScreen(ingredient: ingredient);
        },
      ),
      GoRoute(
        path: '/recipe/detail',
        builder: (context, state) {
          final recipe = state.extra as Recipe;
          return RecipeDetailScreen(recipe: recipe);
        },
      ),
      GoRoute(
        path: '/recipe/cooking',
        builder: (context, state) {
          final recipe = state.extra as Recipe;
          return CookingModeScreen(recipe: recipe);
        },
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) {
          final initialMessage = state.extra as String?;
          return ChatScreen(initialMessage: initialMessage);
        },
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const ExpiryAlertScreen(),
      ),
      GoRoute(
        path: '/receipt-scan',
        builder: (context, state) => const ReceiptScanScreen(),
      ),
      GoRoute(
        path: '/receipt-result',
        builder: (context, state) {
          final result = state.extra as ReceiptOcrResult;
          return IngredientReviewScreen(ocrResult: result);
        },
      ),
      GoRoute(
        path: '/profile/chef-selection',
        builder: (context, state) => const ChefSelectionScreen(),
      ),
      GoRoute(
        path: '/profile/cooking-tools',
        builder: (context, state) => const CookingToolsScreen(),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/settings/notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        builder: (context, state) => PrivacyScreen(),
      ),
      GoRoute(
        path: '/settings/help',
        builder: (context, state) => const HelpScreen(),
      ),

      // 메인 4탭 네비게이션
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // 홈 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeTab(),
              ),
            ],
          ),
          // 레시피 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/recipe',
                builder: (context, state) {
                  final filter = state.extra as RecipeQuickFilter?;
                  return RecipeTab(quickFilter: filter);
                },
              ),
            ],
          ),
          // 냉장고 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/refrigerator',
                builder: (context, state) => const RefrigeratorTab(),
              ),
            ],
          ),
          // 프로필 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileTab(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

/// AI Chef 앱
class AIChefApp extends ConsumerWidget {
  const AIChefApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'AI Chef',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
