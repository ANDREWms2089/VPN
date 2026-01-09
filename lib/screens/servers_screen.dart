import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/vpn_provider.dart';
import '../models/vless_server.dart';
import '../theme/app_colors.dart';

class ServersScreen extends StatefulWidget {
  const ServersScreen({super.key});

  @override
  State<ServersScreen> createState() => _ServersScreenState();
}

class _ServersScreenState extends State<ServersScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: Consumer<VpnProvider>(
                  builder: (context, vpnProvider, child) {
                    if (vpnProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryGreen,
                          ),
                        ),
                      );
                    }

                    // Показываем ошибку только если нет серверов (fallback не сработал)
                    if (vpnProvider.error != null && vpnProvider.servers.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.orange,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Backend недоступен',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Sansation',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkOrange,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Убедитесь, что backend запущен на порту 3000',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Sansation',
                                  color: AppColors.accentOrange,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () => vpnProvider.loadServers(),
                                icon: const Icon(Icons.refresh),
                                label: Text(
                                  'Повторить',
                                  style: const TextStyle(
                                  fontFamily: 'Sansation',),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final servers = vpnProvider.servers;
                    final currentServer = vpnProvider.status.currentServer;

                    if (servers.isEmpty) {
                      return Center(
                        child: Text(
                          'No servers available',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Sansation',
                            color: AppColors.darkOrange,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: servers.length,
                      itemBuilder: (context, index) {
                        return _buildServerCard(
                          context,
                          servers[index],
                          vpnProvider,
                          currentServer?.id == servers[index].id,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppColors.darkGreen,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
            Text(
              'Select Server',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Sansation',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkOrange,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildServerCard(
    BuildContext context,
    VlessServer server,
    VpnProvider vpnProvider,
    bool isCurrent,
  ) {
    return Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: isCurrent
              ? const LinearGradient(
                  colors: [AppColors.primaryGreen, AppColors.darkGreen],
                )
              : AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isCurrent ? AppColors.primaryGreen : AppColors.lightGreen)
                  .withValues(alpha: 0.3),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () async {
              if (vpnProvider.status.isConnected) {
                await vpnProvider.disconnect();
                await Future.delayed(const Duration(milliseconds: 500));
                if (context.mounted) {
                  vpnProvider.connect(server);
                  Navigator.pop(context);
                }
              } else {
                vpnProvider.connect(server);
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        server.flag,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                server.name,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Sansation',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: isCurrent ? Colors.white : AppColors.darkOrange,
                                ),
                              ),
                            ),
                            if (server.isTest)
                              Container(
                                margin: const EdgeInsets.only(left: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: (isCurrent ? Colors.white : Colors.orange)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: (isCurrent ? Colors.white : Colors.orange)
                                        .withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Тест',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Sansation',
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isCurrent ? Colors.white : Colors.orange.shade700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          server.country,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Sansation',
                            fontSize: 14,
                            color: isCurrent
                                ? Colors.white70
                                : AppColors.accentOrange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildPingIndicator(server.ping, isCurrent),
                      const SizedBox(height: 8),
                      if (isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Active',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Sansation',
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
  }

  Widget _buildPingIndicator(int ping, bool isCurrent) {
    Color pingColor;
    if (ping < 50) {
      pingColor = Colors.green;
    } else if (ping < 100) {
      pingColor = Colors.orange;
    } else {
      pingColor = Colors.red;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isCurrent ? Colors.white : pingColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$ping ms',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Sansation',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isCurrent ? Colors.white : AppColors.darkOrange,
          ),
        ),
      ],
    );
  }
}

