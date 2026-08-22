import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_layout.dart';
import '../../core/app_strings.dart';
import '../../data/providers.dart';
import '../widgets/liquid_glass.dart';
import 'onboarding_scenes.dart';

/// First-launch onboarding: four swipeable, animated pages introducing the
/// app.
///
/// Shown in place of the app shell until [onboardingDoneProvider] flips true
/// — either by finishing ("Mulai") or skipping ("Lewati"). The flag lives in
/// shared_preferences, so this screen never appears again on later launches.
///
/// Motion design (kept subtle; honors prefers-reduced-motion):
///  * Each slide replays a staggered fade + slide-up entrance when it becomes
///    the active page ([_AnimatedPage] + [_StaggerIn]).
///  * Every slide carries a hand-painted vector hero scene ([OnboardingScene])
///    with one looping effect — twinkling stars, a glow sweep across the
///    mushaf, or an expanding radar pulse — paused whenever its slide rests.
///  * Scenes drift against the swipe direction (light parallax).
///  * The CTA cross-fades its label ("Lanjut" → "Mulai"); its press-scale
///    comes free from [GlassTouchButton]'s liquid-glass touch response.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _pageCount = 4;

  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Persists the flag; MaterialApp.home switches to the app shell.
  void _finish() => ref.read(onboardingDoneProvider.notifier).complete();

  void _next() {
    if (_page < _pageCount - 1) {
      _controller.nextPage(
        duration: AppLayout.durPanel,
        curve: Curves.easeOutCubic,
      );
    } else {
      _finish();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isLast = _page == _pageCount - 1;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Skip — quiet text action, top-left. Hidden on the last page,
            // where "Mulai" already finishes onboarding.
            Align(
              alignment: Alignment.centerLeft,
              child: AnimatedOpacity(
                duration: AppLayout.durBase,
                opacity: isLast ? 0 : 1,
                child: IgnorePointer(
                  ignoring: isLast,
                  child: TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(
                      foregroundColor: scheme.onSurfaceVariant,
                    ),
                    child: const Text(S.onboardingSkip),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  _AnimatedPage(
                    controller: _controller,
                    index: 0,
                    active: _page == 0,
                    builder: (context, entrance, drift) => _WelcomePage(
                      entrance: entrance,
                      drift: drift,
                      active: _page == 0,
                    ),
                  ),
                  _AnimatedPage(
                    controller: _controller,
                    index: 1,
                    active: _page == 1,
                    builder: (context, entrance, drift) => _ReadPage(
                      entrance: entrance,
                      drift: drift,
                      active: _page == 1,
                    ),
                  ),
                  _AnimatedPage(
                    controller: _controller,
                    index: 2,
                    active: _page == 2,
                    builder: (context, entrance, drift) => _HijriPage(
                      entrance: entrance,
                      drift: drift,
                      active: _page == 2,
                    ),
                  ),
                  _AnimatedPage(
                    controller: _controller,
                    index: 3,
                    active: _page == 3,
                    builder: (context, entrance, drift) => _MosquePage(
                      entrance: entrance,
                      drift: drift,
                      active: _page == 3,
                    ),
                  ),
                ],
              ),
            ),
            // Bottom bar: page dots + the liquid-glass CTA (same glass as
            // the app's search pill).
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppLayout.sp6,
                AppLayout.sp2,
                AppLayout.sp6,
                AppLayout.sp6,
              ),
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _pageCount; i++)
                        AnimatedContainer(
                          duration: AppLayout.durBase,
                          curve: Curves.easeOut,
                          margin: EdgeInsets.only(
                            right: i < _pageCount - 1 ? AppLayout.sp1 + 2 : 0,
                          ),
                          width: i == _page ? 22 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _page
                                ? scheme.primary
                                : scheme.outlineVariant.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(
                              AppLayout.radiusFull,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  GlassTouchButton(
                    onTap: _next,
                    radius: AppLayout.radiusFull,
                    style: glassChromeStyle(
                      context,
                      cornerRadius: AppLayout.radiusFull,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppLayout.sp5,
                        vertical: AppLayout.sp2 + 4,
                      ),
                      child: AnimatedSwitcher(
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : AppLayout.durBase,
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        // Cross-fade + slight rise between Lanjut/Mulai.
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        ),
                        child: Row(
                          key: ValueKey(isLast),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isLast ? S.onboardingStart : S.onboardingNext,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: scheme.primary,
                              ),
                            ),
                            const SizedBox(width: AppLayout.sp1),
                            Icon(
                              isLast
                                  ? Icons.check_rounded
                                  : Icons.arrow_forward_rounded,
                              size: 18,
                              color: scheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps one PageView slide: owns the slide's entrance animation — replaying
/// a staggered cascade every time the slide becomes active — and computes the
/// live swipe distance ([drift], −1..1) so inner layers can parallax.
class _AnimatedPage extends StatefulWidget {
  const _AnimatedPage({
    required this.controller,
    required this.index,
    required this.active,
    required this.builder,
  });

  final PageController controller;
  final int index;
  final bool active;
  final Widget Function(
    BuildContext context,
    Animation<double> entrance,
    double drift,
  )
  builder;

  @override
  State<_AnimatedPage> createState() => _AnimatedPageState();
}

class _AnimatedPageState extends State<_AnimatedPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
    value: 1,
  );

  @override
  void initState() {
    super.initState();
    if (widget.active) _play();
  }

  @override
  void didUpdateWidget(_AnimatedPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        _play();
      } else {
        // Leaving slides rest fully-visible — never re-animate mid-swipe.
        _entrance.value = 1;
      }
    }
  }

  void _play() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _entrance.value = 1;
      return;
    }
    _entrance.forward(from: 0);
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  /// Continuous swipe distance of this page from center, −1..1. Guarded for
  /// the first layout pass, where the controller has no attached position.
  double get _drift {
    final controller = widget.controller;
    if (!controller.hasClients || controller.positions.isEmpty) return 0;
    final page = controller.page;
    if (page == null) return 0;
    return (page - widget.index).clamp(-1.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    // Only swipe drift rebuilds this subtree; the entrance transitions
    // (Fade/Slide) repaint themselves straight off the animation.
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => widget.builder(context, _entrance.view, _drift),
    );
  }
}

/// One element of a slide's staggered entrance: fades in while sliding up,
/// starting at [start] (0..1) along the shared entrance timeline.
class _StaggerIn extends StatelessWidget {
  const _StaggerIn({
    required this.entrance,
    required this.start,
    required this.child,
  }) : assert(start >= 0 && start <= 1);

  final Animation<double> entrance;
  final double start;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final end = start + 0.55 > 1 ? 1.0 : start + 0.55;
    final curved = CurvedAnimation(
      parent: entrance,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.16),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// A quiet pill chip listing one capability (slide 2 & 3).
class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppLayout.sp3,
        vertical: AppLayout.sp1 + 2,
      ),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(AppLayout.radiusFull),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Shared layout for a slide: centered column of staggered elements.
class _SlideLayout extends StatelessWidget {
  const _SlideLayout({required this.entrance, required this.children});

  final Animation<double> entrance;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppLayout.sp6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: AppLayout.sp3),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Slide 1 — welcome: night-sky scene (crescent, twinkling stars, mosque
/// skyline) + name + tagline.
class _WelcomePage extends StatelessWidget {
  const _WelcomePage({
    required this.entrance,
    required this.drift,
    required this.active,
  });

  final Animation<double> entrance;
  final double drift;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _SlideLayout(
      entrance: entrance,
      children: [
        _StaggerIn(
          entrance: entrance,
          start: 0,
          child: OnboardingScene(
            active: active,
            drift: drift,
            painter: (t) => WelcomeSkyPainter(ScenePalette.of(scheme), t),
          ),
        ),
        _StaggerIn(
          entrance: entrance,
          start: 0.2,
          child: Column(
            children: [
              Text(
                S.onboardingWelcomeEyebrow,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: scheme.tertiary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: AppLayout.sp2),
              Text(
                S.onboardingWelcomeTitle,
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ],
          ),
        ),
        _StaggerIn(
          entrance: entrance,
          start: 0.4,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              S.onboardingWelcomeTagline,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Slide 2 — reading: mushaf scene + what the mushaf experience offers.
class _ReadPage extends StatelessWidget {
  const _ReadPage({
    required this.entrance,
    required this.drift,
    required this.active,
  });

  final Animation<double> entrance;
  final double drift;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _SlideLayout(
      entrance: entrance,
      children: [
        _StaggerIn(
          entrance: entrance,
          start: 0,
          child: OnboardingScene(
            active: active,
            drift: drift,
            painter: (t) => MushafGlowPainter(ScenePalette.of(scheme), t),
          ),
        ),
        _StaggerIn(
          entrance: entrance,
          start: 0.2,
          child: Text(
            S.onboardingReadTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        ),
        _StaggerIn(
          entrance: entrance,
          start: 0.35,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              S.onboardingReadDesc,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ),
        _StaggerIn(
          entrance: entrance,
          start: 0.5,
          child: Wrap(
            spacing: AppLayout.sp2,
            runSpacing: AppLayout.sp2,
            alignment: WrapAlignment.center,
            children: const [
              _Chip(label: S.onboardingChipTranslation),
              _Chip(label: S.onboardingChipTafsir),
              _Chip(label: S.onboardingChipTajwid),
            ],
          ),
        ),
      ],
    );
  }
}

/// Slide 3 — hijri calendar: crescent + calendar-card scene, date & khatam
/// tracking.
class _HijriPage extends StatelessWidget {
  const _HijriPage({
    required this.entrance,
    required this.drift,
    required this.active,
  });

  final Animation<double> entrance;
  final double drift;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _SlideLayout(
      entrance: entrance,
      children: [
        _StaggerIn(
          entrance: entrance,
          start: 0,
          child: OnboardingScene(
            active: active,
            drift: drift,
            painter: (t) => HijriCalendarPainter(ScenePalette.of(scheme), t),
          ),
        ),
        _StaggerIn(
          entrance: entrance,
          start: 0.2,
          child: Text(
            S.onboardingHijriTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        ),
        _StaggerIn(
          entrance: entrance,
          start: 0.35,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              S.onboardingHijriDesc,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ),
        _StaggerIn(
          entrance: entrance,
          start: 0.5,
          child: Wrap(
            spacing: AppLayout.sp2,
            runSpacing: AppLayout.sp2,
            alignment: WrapAlignment.center,
            children: const [
              _Chip(label: S.onboardingChipHijriDate),
              _Chip(label: S.onboardingChipKhatam),
            ],
          ),
        ),
      ],
    );
  }
}

/// Slide 4 — find a mosque: radar-pulse mosque scene + nearby/qibla promise.
class _MosquePage extends StatelessWidget {
  const _MosquePage({
    required this.entrance,
    required this.drift,
    required this.active,
  });

  final Animation<double> entrance;
  final double drift;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return _SlideLayout(
      entrance: entrance,
      children: [
        _StaggerIn(
          entrance: entrance,
          start: 0,
          child: OnboardingScene(
            active: active,
            drift: drift,
            painter: (t) => MosqueRadarPainter(ScenePalette.of(scheme), t),
          ),
        ),
        _StaggerIn(
          entrance: entrance,
          start: 0.2,
          child: Text(
            S.onboardingMosqueTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
          ),
        ),
        _StaggerIn(
          entrance: entrance,
          start: 0.4,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Text(
              S.onboardingMosqueDesc,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ),
        _StaggerIn(
          entrance: entrance,
          start: 0.55,
          child: Wrap(
            spacing: AppLayout.sp2,
            runSpacing: AppLayout.sp2,
            alignment: WrapAlignment.center,
            children: const [
              _Chip(label: S.onboardingChipNearbyMosque),
              _Chip(label: S.onboardingChipQibla),
            ],
          ),
        ),
      ],
    );
  }
}
