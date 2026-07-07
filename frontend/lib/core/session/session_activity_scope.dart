import 'dart:async';

import 'package:artid/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionActivityScope extends ConsumerStatefulWidget {
  const SessionActivityScope({required this.child, required this.navigatorKey, super.key});

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;

  static const inactivityTimeout = Duration(minutes: 10);

  @override
  ConsumerState<SessionActivityScope> createState() => _SessionActivityScopeState();
}

class _SessionActivityScopeState extends ConsumerState<SessionActivityScope> with WidgetsBindingObserver {
  Timer? _expiryTimer;
  DateTime _lastActivity = DateTime.now();
  var _hasExpired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleExpiryTimer();
  }

  @override
  void dispose() {
    _expiryTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || _hasExpired) return;

    final inactiveFor = DateTime.now().difference(_lastActivity);
    if (inactiveFor >= SessionActivityScope.inactivityTimeout) {
      _expireSession();
    } else {
      _scheduleExpiryTimer();
    }
  }

  void _recordActivity() {
    if (_hasExpired) return;
    _lastActivity = DateTime.now();
    _scheduleExpiryTimer();
  }

  void _scheduleExpiryTimer() {
    _expiryTimer?.cancel();

    final inactiveFor = DateTime.now().difference(_lastActivity);
    final remaining = SessionActivityScope.inactivityTimeout - inactiveFor;

    if (remaining <= Duration.zero) {
      _expireSession();
      return;
    }

    _expiryTimer = Timer(remaining, _expireSession);
  }

  void _expireSession() {
    if (_hasExpired || !mounted) return;
    if (!ref.read(authProvider).hasAppAccess) return;

    _hasExpired = true;
    _expiryTimer?.cancel();
    _showExpiredDialog();
  }

  Future<void> _showExpiredDialog() async {
    if (!mounted) return;

    final navigatorContext = widget.navigatorKey.currentContext;
    if (navigatorContext == null || !navigatorContext.mounted) {
      ref.read(authProvider.notifier).logout();
      return;
    }

    await showDialog<void>(
      context: navigatorContext,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sessione scaduta'),
        content: const Text('Sei rimasto inattivo troppo a lungo. Accedi di nuovo per continuare.'),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ref.read(authProvider.notifier).logout();
            },
            child: const Text('Vai al login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Listener(behavior: HitTestBehavior.translucent, onPointerDown: (_) => _recordActivity(), onPointerSignal: (_) => _recordActivity(), child: widget.child);
  }
}
