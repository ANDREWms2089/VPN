import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animations/animations.dart';
import '../providers/vpn_provider.dart';
import '../models/vpn_status.dart';
import '../theme/app_colors.dart';
import '../widgets/settings_dialog.dart';
import 'servers_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Consumer<VpnProvider>(
            builder: (context, vpnProvider, child) {
              final status = vpnProvider.status;
              return Column(
                children: [
                  _buildHeader(context, status),
                  Expanded(
                    child: _buildMainContent(context, status, vpnProvider),
                  ),
                  _buildBottomSection(context, status, vpnProvider),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, VpnStatus status) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Belchonok VPN',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Sansation',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkOrange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusText(status),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Sansation',
                    fontSize: 14,
                    color: AppColors.accentOrange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            color: AppColors.darkOrange,
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return const SettingsDialog();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
      BuildContext context, VpnStatus status, VpnProvider vpnProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildConnectionButton(context, status, vpnProvider),
          const SizedBox(height: 40),
          if (status.isConnected) _buildConnectionInfo(context, status),
        ],
      ),
    );
  }

  Widget _buildConnectionButton(
      BuildContext context, VpnStatus status, VpnProvider vpnProvider) {
    return GestureDetector(
      onTap: () {
        if (status.isConnected) {
          vpnProvider.disconnect();
        } else if (status.isDisconnected) {
          _showServerSelection(context, vpnProvider);
        }
      },
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: status.isConnecting ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: status.isConnected
                    ? const LinearGradient(
                        colors: [AppColors.primaryGreen, AppColors.darkGreen],
                      )
                    : status.isConnecting
                        ? const LinearGradient(
                            colors: [AppColors.lightGreen, AppColors.primaryGreen],
                          )
                        : const LinearGradient(
                            colors: [AppColors.mintGreen, AppColors.cucumberGreen],
                          ),
                boxShadow: [
                  BoxShadow(
                    color: (status.isConnected
                            ? AppColors.primaryGreen
                            : AppColors.lightGreen)
                        .withValues(alpha: 0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _buildButtonIcon(status),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildButtonIcon(VpnStatus status) {
    if (status.isConnecting) {
      return const SizedBox(
        key: ValueKey('connecting'),
        width: 80,
        height: 80,
        child: CircularProgressIndicator(
          strokeWidth: 4,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (status.isConnected) {
      return const Icon(
        Icons.vpn_key,
        key: ValueKey('connected'),
        size: 80,
        color: Colors.white,
      );
    } else {
      return const Icon(
        Icons.power_settings_new,
        key: ValueKey('disconnected'),
        size: 80,
        color: Colors.white,
      );
    }
  }

  Widget _buildConnectionInfo(BuildContext context, VpnStatus status) {
    if (!status.isConnected || status.currentServer == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _pulseController,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(
                parent: _pulseController,
                curve: Curves.easeInOut,
              ),
            ),
            child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.lightGreen.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  status.currentServer!.flag,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    status.currentServer!.name,
                    style: const TextStyle(
                    fontFamily: 'Sansation',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkOrange,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (status.downloadSpeed != null && status.uploadSpeed != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSpeedInfo('Download', status.downloadSpeed!),
                  const SizedBox(width: 40),
                  _buildSpeedInfo('Upload', status.uploadSpeed!),
                ],
              ),
          ],
        ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSpeedInfo(String label, int speed) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _formatSpeed(speed),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Sansation',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.darkOrange,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Sansation',
            fontSize: 12,
            color: AppColors.accentOrange,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(
      BuildContext context, VpnStatus status, VpnProvider vpnProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (status.isConnected && status.connectedAt != null)
            Text(
              'Connected ${_formatDuration(status.connectedAt!)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Sansation',
                fontSize: 12,
                color: AppColors.accentOrange,
              ),
            ),
          const SizedBox(height: 16),
            ElevatedButton.icon(
            onPressed: () => _showServerSelection(context, vpnProvider),
            icon: const Icon(Icons.list),
            label: Text(
              'Choose Server',
              style: const TextStyle(fontFamily: 'Sansation'),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
            ),
          ),
        ],
      ),
    );
  }

  void _showServerSelection(BuildContext context, VpnProvider vpnProvider) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const ServersScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            transitionType: SharedAxisTransitionType.horizontal,
            child: child,
          );
        },
      ),
    );
  }

  String _getStatusText(VpnStatus status) {
    switch (status.status) {
      case VpnConnectionStatus.connected:
        return 'Connected';
      case VpnConnectionStatus.connecting:
        return 'Connecting...';
      case VpnConnectionStatus.disconnecting:
        return 'Disconnecting...';
      case VpnConnectionStatus.error:
        return 'Error: ${status.errorMessage}';
      default:
        return 'Disconnected';
    }
  }

  String _formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '$bytesPerSecond B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(1)} MB/s';
    }
  }

  String _formatDuration(DateTime startTime) {
    final duration = DateTime.now().difference(startTime);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

