// core/router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lively/screens/add_edit_event_screen.dart';
import 'package:lively/screens/config_screen.dart';
import 'package:lively/screens/event_history_screen.dart';
import 'package:lively/screens/home_screen.dart';
import 'package:lively/screens/profile_screen.dart';

/// Router configuration for the Lively app
final GoRouter appRouter = GoRouter(
  routes: [
    // Home screen (root)
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    
    // Event history screen
    GoRoute(
      path: '/history',
      builder: (context, state) => const EventHistoryScreen(),
    ),
    
    // Add event screen
    GoRoute(
      path: '/event/add',
      builder: (context, state) => const AddEditEventScreen(),
    ),
    
    // Edit event screen with id parameter
    GoRoute(
      path: '/event/edit/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return AddEditEventScreen(eventId: id);
      },
    ),
    
    // Profile screen
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    
    // Config screen
    GoRoute(
      path: '/config',
      builder: (context, state) => const ConfigScreen(),
    ),
  ],
  
  // Show error screen for invalid routes
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.error}'),
    ),
  ),
);