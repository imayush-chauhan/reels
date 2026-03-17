import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:reels/presentation/viewmodels/reels_viewmodel.dart';
import 'package:reels/presentation/widgets/reel_page_item.dart';
import 'package:reels/presentation/widgets/reels_error_widget.dart';
import 'package:reels/presentation/widgets/reels_initial_loader.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen>
    with WidgetsBindingObserver {
  late final PageController _pageController;
  late final ReelsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pageController = PageController();
    _viewModel = context.read<ReelsViewModel>();

    // Hide system UI for immersive experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadReels();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Pause video when app goes to background
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      final controllerState =
          _viewModel.getControllerState(_viewModel.currentIndex);
      controllerState?.controller?.pause();
    } else if (state == AppLifecycleState.resumed) {
      final controllerState =
          _viewModel.getControllerState(_viewModel.currentIndex);
      controllerState?.controller?.play();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pageController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Consumer<ReelsViewModel>(
        builder: (context, vm, _) {
          return switch (vm.loadingState) {
            ReelsLoadingState.initial ||
            ReelsLoadingState.loading =>
              const ReelsInitialLoader(),
            ReelsLoadingState.error => ReelsErrorWidget(
                message: vm.errorMessage ?? 'Something went wrong.',
                onRetry: vm.loadReels,
              ),
            _ => _buildReelsFeed(vm),
          };
        },
      ),
    );
  }

  Widget _buildReelsFeed(ReelsViewModel vm) {
    if (vm.reels.isEmpty) {
      return const Center(
        child: Text(
          'No reels yet.',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      );
    }

    return Stack(
      children: [
        PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          itemCount: vm.reels.length + (vm.hasMore ? 1 : 0),
          onPageChanged: vm.onPageChanged,
          itemBuilder: (context, index) {
            if (index >= vm.reels.length) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final reel = vm.reels[index];
            final controllerState = vm.getControllerState(index);

            return ReelPageItem(
              key: ValueKey(reel.id),
              reel: reel,
              controllerState: controllerState,
              isMuted: vm.isMuted,
              onLike: () => vm.toggleLike(index),
              onMute: vm.toggleMute,
            );
          },
        ),

        // Top gradient overlay for status bar legibility
        const _TopGradientOverlay(),
      ],
    );
  }
}

class _TopGradientOverlay extends StatelessWidget {
  const _TopGradientOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 120,
      child: IgnorePointer(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black54, Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }
}
