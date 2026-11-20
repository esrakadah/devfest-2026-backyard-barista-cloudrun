import 'dart:async';

import 'package:backyard_barista_cloudrun/services/hall_board_controller.dart';
import 'package:flutter/material.dart';

const Color _pageBackground = Color(0xFF0E131F);
const Color _panelBackground = Color(0xFF151E30);
const Color _elevatedRowBackground = Color(0xFF1C2740);
const Color _goldAccent = Color(0xFFD4AF37);
const Color _silverAccent = Color(0xFFD5DBE3);
const Color _bronzeAccent = Color(0xFFE0A46E);
const Color _emeraldAccent = Color(0xFF4CAF50);
const Color _amberAccent = Color(0xFFFFB300);
const Color _crimsonAccent = Color(0xFFB71C1C);
const Color _creamText = Color(0xFFF3E5C8);
const Color _mutedCreamText = Color(0xFFC9B086);

const double _wideLayoutBreakpoint = 880;
const double _maxContentWidth = 1280;
const double _cardCornerRadius = 20;
const int _podiumCount = 3;

/// Standalone hall leaderboard view opened in a separate tab (`?page=leaderboard`).
///
/// Every attendee can inspect the live standings and return to the game. Pause/resume and board
/// reset controls only appear after [HallBoardController.signInAdmin] verifies the admin secret on
/// the server.
class HallLeaderboardPage extends StatefulWidget {
  const HallLeaderboardPage({
    required this.controller,
    required this.languageCode,
    required this.onBackToGame,
    super.key,
  });

  final HallBoardController controller;
  final String languageCode;
  final VoidCallback onBackToGame;

  @override
  State<HallLeaderboardPage> createState() => _HallLeaderboardPageState();
}

class _HallLeaderboardPageState extends State<HallLeaderboardPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.startWatching();
  }

  @override
  void dispose() {
    widget.controller.stopWatching();
    super.dispose();
  }

  bool get _isEnglish => widget.languageCode == 'en';

  Future<void> _openAdminDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _AdminSignInDialog(
        controller: widget.controller,
        isEnglish: _isEnglish,
      ),
    );
  }

  Future<void> _confirmAndResetBoard() async {
    final playerCount = widget.controller.entries.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        key: const Key('leaderboard_confirm_reset_dialog'),
        backgroundColor: _panelBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_cardCornerRadius),
          side: const BorderSide(color: _goldAccent, width: 1.5),
        ),
        title: Text(
          _isEnglish ? 'Reset leaderboard?' : 'Tabloyu sıfırla?',
          style: const TextStyle(fontWeight: FontWeight.w800, color: _creamText),
        ),
        content: Text(
          _isEnglish
              ? 'This permanently deletes all rows in "${widget.controller.eventId}" ($playerCount visible). Continue?'
              : '"${widget.controller.eventId}" tablosundaki tüm oyuncu kayıtları ($playerCount görünür kayıt) kalıcı olarak silinecek. Devam edilsin mi?',
          style: const TextStyle(color: _mutedCreamText, height: 1.4),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(
              _isEnglish ? 'Cancel' : 'Vazgeç',
              style: const TextStyle(color: _mutedCreamText),
            ),
          ),
          FilledButton.icon(
            key: const Key('leaderboard_confirm_reset_button'),
            style: FilledButton.styleFrom(
              backgroundColor: _crimsonAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_forever_rounded, size: 18),
            label: Text(
              _isEnglish ? 'Yes, Reset' : 'Evet, Sıfırla',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final deletedPlayers = await widget.controller.resetBoard();
    if (!mounted) {
      return;
    }
    final message = deletedPlayers != null
        ? (_isEnglish
            ? 'Leaderboard cleared ($deletedPlayers players deleted).'
            : 'Tablo sıfırlandı ($deletedPlayers oyuncu silindi).')
        : (widget.controller.adminErrorMessage ?? (_isEnglish ? 'Reset failed.' : 'Sıfırlama başarısız oldu.'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _togglePause() async {
    final targetPaused = !widget.controller.isPaused;
    final succeeded = await widget.controller.setPaused(paused: targetPaused);
    if (!mounted) {
      return;
    }
    if (!succeeded) {
      final errorMessage =
          widget.controller.adminErrorMessage ?? (_isEnglish ? 'Could not update state.' : 'Durum güncellenemedi.');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }
    final statusMessage = targetPaused
        ? (_isEnglish ? 'Leaderboard frozen.' : 'Oyun durduruldu, tablo donduruldu.')
        : (_isEnglish ? 'Leaderboard live again.' : 'Tablo tekrar canlıya alındı.');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(statusMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final entries = widget.controller.entries;
        final isPaused = widget.controller.isPaused;
        final isAdmin = widget.controller.isAdminAuthenticated;
        final isBusy = widget.controller.isAdminActionInFlight;

        return Scaffold(
          backgroundColor: _pageBackground,
          appBar: AppBar(
            backgroundColor: const Color(0xFF1A120D),
            automaticallyImplyLeading: false,
            titleSpacing: 12,
            leadingWidth: 148,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
              child: FilledButton.tonalIcon(
                key: const Key('leaderboard_back_to_game_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E2016),
                  foregroundColor: _creamText,
                  side: const BorderSide(color: _goldAccent, width: 1.2),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
                onPressed: widget.onBackToGame,
                icon: const Icon(Icons.arrow_back_rounded, size: 18, color: _goldAccent),
                label: Text(
                  _isEnglish ? 'Back to Game' : 'Oyuna Dön',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            title: Row(
              children: <Widget>[
                const Icon(Icons.emoji_events_rounded, color: _goldAccent, size: 22),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _isEnglish ? 'Live Hall Leaderboard' : 'Canlı Skor Tablosu',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: _creamText,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _elevatedRowBackground,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: _goldAccent.withValues(alpha: 0.7)),
                  ),
                  child: Text(
                    widget.controller.eventId,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _mutedCreamText,
                    ),
                  ),
                ),
              ],
            ),
            actions: <Widget>[
              IconButton(
                key: const Key('leaderboard_refresh_button'),
                tooltip: _isEnglish ? 'Refresh' : 'Yenile',
                onPressed: () => unawaited(widget.controller.refresh()),
                icon: const Icon(Icons.refresh_rounded, color: _goldAccent),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                child: OutlinedButton.icon(
                  key: const Key('leaderboard_admin_button'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isAdmin ? _emeraldAccent : _mutedCreamText,
                    side: BorderSide(
                      color: isAdmin ? _emeraldAccent : _goldAccent.withValues(alpha: 0.6),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: isAdmin ? widget.controller.signOutAdmin : _openAdminDialog,
                  icon: Icon(
                    isAdmin ? Icons.verified_user_rounded : Icons.lock_outline_rounded,
                    size: 16,
                  ),
                  label: Text(
                    isAdmin ? (_isEnglish ? 'Admin (Exit)' : 'Admin (Çıkış)') : 'Admin',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _StatusHeaderStrip(
                        isEnglish: _isEnglish,
                        isPaused: isPaused,
                        isLastFetchFailed: widget.controller.isLastFetchFailed,
                        playerCount: entries.length,
                      ),
                      if (isAdmin) ...<Widget>[
                        const SizedBox(height: 12),
                        _AdminControlToolbar(
                          isEnglish: _isEnglish,
                          isPaused: isPaused,
                          isBusy: isBusy,
                          onTogglePause: _togglePause,
                          onResetBoard: _confirmAndResetBoard,
                        ),
                      ],
                      const SizedBox(height: 14),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final standingsPanel = _StandingsListPanel(
                              entries: entries,
                              hasLoadedOnce: widget.controller.hasLoadedOnce,
                              isEnglish: _isEnglish,
                            );
                            final prizesPanel = _PrizesSidePanel(
                              entries: entries,
                              isEnglish: _isEnglish,
                            );

                            if (constraints.maxWidth >= _wideLayoutBreakpoint) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: <Widget>[
                                  Expanded(flex: 7, child: standingsPanel),
                                  const SizedBox(width: 16),
                                  Expanded(flex: 4, child: prizesPanel),
                                ],
                              );
                            }

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                _CompactPrizesBanner(isEnglish: _isEnglish),
                                const SizedBox(height: 12),
                                Expanded(child: standingsPanel),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusHeaderStrip extends StatelessWidget {
  const _StatusHeaderStrip({
    required this.isEnglish,
    required this.isPaused,
    required this.isLastFetchFailed,
    required this.playerCount,
  });

  final bool isEnglish;
  final bool isPaused;
  final bool isLastFetchFailed;
  final int playerCount;

  @override
  Widget build(BuildContext context) {
    final badgeColor = isPaused ? _amberAccent : _emeraldAccent;
    final statusText = isPaused
        ? (isEnglish ? 'PAUSED · FINAL STANDINGS' : 'OYUN DURDURULDU · SON SIRALAMA')
        : (isEnglish ? 'LIVE · UPDATES EVERY 3S' : 'CANLI · 3 SANİYEDE BİR GÜNCELLENİR');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: badgeColor.withValues(alpha: 0.7), width: 1.4),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 6,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                isPaused ? Icons.pause_circle_filled_rounded : Icons.sensors_rounded,
                color: badgeColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                statusText,
                key: const Key('leaderboard_status_chip'),
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: badgeColor,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          Text(
            isLastFetchFailed
                ? (isEnglish ? 'Waiting for connection...' : 'Bağlantı bekleniyor...')
                : (isEnglish
                    ? '$playerCount baristas on the board · 3 min per player'
                    : 'Tabloda $playerCount barista · İlk tepsiden itibaren 3 dk'),
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: _mutedCreamText,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminControlToolbar extends StatelessWidget {
  const _AdminControlToolbar({
    required this.isEnglish,
    required this.isPaused,
    required this.isBusy,
    required this.onTogglePause,
    required this.onResetBoard,
  });

  final bool isEnglish;
  final bool isPaused;
  final bool isBusy;
  final VoidCallback onTogglePause;
  final VoidCallback onResetBoard;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('leaderboard_admin_toolbar'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF241B13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _goldAccent, width: 1.6),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.admin_panel_settings_rounded, color: _goldAccent, size: 20),
              const SizedBox(width: 8),
              Text(
                isEnglish ? 'Stage Admin Controls' : 'Sahne Admin Kontrolleri',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5,
                  color: _creamText,
                ),
              ),
            ],
          ),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: <Widget>[
              FilledButton.icon(
                key: const Key('leaderboard_toggle_pause_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: isPaused ? _emeraldAccent : _amberAccent,
                  foregroundColor: const Color(0xFF101520),
                ),
                onPressed: isBusy ? null : onTogglePause,
                icon: Icon(
                  isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  size: 18,
                ),
                label: Text(
                  isPaused
                      ? (isEnglish ? 'Resume Game' : 'Oyunu Devam Ettir')
                      : (isEnglish ? 'Stop / Freeze Board' : 'Oyunu Durdur'),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
              FilledButton.icon(
                key: const Key('leaderboard_reset_button'),
                style: FilledButton.styleFrom(
                  backgroundColor: _crimsonAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: isBusy ? null : onResetBoard,
                icon: const Icon(Icons.delete_forever_rounded, size: 18),
                label: Text(
                  isEnglish ? 'Reset Board' : 'Tabloyu Sıfırla (Reset)',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StandingsListPanel extends StatelessWidget {
  const _StandingsListPanel({
    required this.entries,
    required this.hasLoadedOnce,
    required this.isEnglish,
  });

  final List<HallBoardPlayerEntry> entries;
  final bool hasLoadedOnce;
  final bool isEnglish;

  Color _accentForRank(int rank) {
    return switch (rank) {
      1 => _goldAccent,
      2 => _silverAccent,
      3 => _bronzeAccent,
      _ => _mutedCreamText,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_cardCornerRadius),
        border: Border.all(color: _goldAccent.withValues(alpha: 0.55), width: 1.5),
      ),
      child: entries.isEmpty
          ? Center(
              child: Text(
                hasLoadedOnce
                    ? (isEnglish
                        ? 'Waiting for the first served tray!'
                        : 'Henüz puan yok. İlk servis edilen tepsi bekleniyor!')
                    : (isEnglish ? 'Loading leaderboard...' : 'Skor tablosu yükleniyor...'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _creamText,
                ),
              ),
            )
          : ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final rank = index + 1;
                final entry = entries[index];
                final isPodium = rank <= _podiumCount;
                final rankColor = _accentForRank(rank);

                return Container(
                  key: Key('leaderboard_row_$rank'),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isPodium ? rankColor.withValues(alpha: 0.14) : _elevatedRowBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPodium ? rankColor : const Color(0xFF2D3C5E),
                      width: isPodium ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 44,
                        child: Text(
                          '#$rank',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: rankColor,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          hallBoardSafeDisplayName(entry.name),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: _creamText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isEnglish ? '${entry.rounds} rounds' : '${entry.rounds} tur',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _mutedCreamText,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isEnglish ? '${entry.score} pts' : '${entry.score}p',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                          color: _goldAccent,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _PrizesSidePanel extends StatelessWidget {
  const _PrizesSidePanel({
    required this.entries,
    required this.isEnglish,
  });

  final List<HallBoardPlayerEntry> entries;
  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    final prizes = <_PrizeSpec>[
      _PrizeSpec(
        rank: 1,
        title: 'Dash',
        icon: Icons.flutter_dash,
        color: _goldAccent,
        leader: entries.isNotEmpty ? hallBoardSafeDisplayName(entries[0].name) : null,
      ),
      _PrizeSpec(
        rank: 2,
        title: isEnglish ? 'Google Cloud Glasses' : 'Google Cloud Gözlük',
        icon: Icons.wb_sunny_rounded,
        color: _silverAccent,
        leader: entries.length > 1 ? hallBoardSafeDisplayName(entries[1].name) : null,
      ),
      _PrizeSpec(
        rank: 3,
        title: isEnglish ? 'Sticker Set' : 'Sticker Seti',
        icon: Icons.auto_awesome_mosaic_rounded,
        color: _bronzeAccent,
        leader: entries.length > 2 ? hallBoardSafeDisplayName(entries[2].name) : null,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(_cardCornerRadius),
        border: Border.all(color: _goldAccent.withValues(alpha: 0.55), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            isEnglish ? 'STAGE PRIZES' : 'SAHNE ÖDÜLLERİ',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 0.8,
              color: _goldAccent,
            ),
          ),
          const SizedBox(height: 12),
          for (final prize in prizes) ...<Widget>[
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: _elevatedRowBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: prize.color.withValues(alpha: 0.6)),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(prize.icon, size: 34, color: prize.color),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            isEnglish ? 'PLACE #${prize.rank}' : '${prize.rank}. OLANA',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: prize.color,
                            ),
                          ),
                          Text(
                            prize.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: _creamText,
                            ),
                          ),
                          if (prize.leader != null)
                            Text(
                              prize.leader!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: _mutedCreamText,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (prize.rank < _podiumCount) const SizedBox(height: 10),
          ],
          const SizedBox(height: 10),
          Text(
            isEnglish
                ? 'Correct tray: 100 pts · Prank or incomplete tray: 30 pts'
                : 'Doğru tepsi: 100p · Şaka veya eksik tepsi: 30p',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _mutedCreamText,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactPrizesBanner extends StatelessWidget {
  const _CompactPrizesBanner({required this.isEnglish});

  final bool isEnglish;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _panelBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _goldAccent.withValues(alpha: 0.5)),
      ),
      child: Text(
        isEnglish
            ? '1st: Dash · 2nd: Google Cloud Glasses · 3rd: Sticker Set'
            : '1. Dash · 2. Google Cloud Gözlük · 3. Sticker Seti',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: _creamText,
        ),
      ),
    );
  }
}

class _PrizeSpec {
  const _PrizeSpec({
    required this.rank,
    required this.title,
    required this.icon,
    required this.color,
    required this.leader,
  });

  final int rank;
  final String title;
  final IconData icon;
  final Color color;
  final String? leader;
}

class _AdminSignInDialog extends StatefulWidget {
  const _AdminSignInDialog({
    required this.controller,
    required this.isEnglish,
  });

  final HallBoardController controller;
  final bool isEnglish;

  @override
  State<_AdminSignInDialog> createState() => _AdminSignInDialogState();
}

class _AdminSignInDialogState extends State<_AdminSignInDialog> {
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final succeeded = await widget.controller.signInAdmin(_passwordController.text);
    if (!mounted) {
      return;
    }
    if (succeeded) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final isBusy = widget.controller.isAdminActionInFlight;
        final errorMessage = widget.controller.adminErrorMessage;

        return AlertDialog(
          backgroundColor: _panelBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(_cardCornerRadius),
            side: const BorderSide(color: _goldAccent, width: 1.5),
          ),
          title: Text(
            widget.isEnglish ? 'Speaker Admin Sign-In' : 'Sahne Admin Girişi',
            style: const TextStyle(fontWeight: FontWeight.w800, color: _creamText),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.isEnglish
                    ? 'Enter your admin key to unlock Stop/Freeze and Reset controls.'
                    : 'Oyunu durdurma ve sıfırlama kontrollerini açmak için admin şifreni gir.',
                style: const TextStyle(fontSize: 13, color: _mutedCreamText, height: 1.35),
              ),
              const SizedBox(height: 14),
              TextField(
                key: const Key('admin_password_field'),
                controller: _passwordController,
                obscureText: true,
                autofocus: true,
                enabled: !isBusy,
                textInputAction: TextInputAction.done,
                style: const TextStyle(color: _creamText, fontWeight: FontWeight.w700),
                decoration: InputDecoration(
                  hintText: widget.isEnglish ? 'Admin key' : 'Admin şifresi',
                  hintStyle: const TextStyle(color: _mutedCreamText),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: _goldAccent),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: _goldAccent, width: 2),
                  ),
                ),
                onSubmitted: (_) => unawaited(_submit()),
              ),
              if (errorMessage != null) ...<Widget>[
                const SizedBox(height: 10),
                Text(
                  errorMessage,
                  key: const Key('admin_login_error_text'),
                  style: const TextStyle(
                    color: Color(0xFFFF8A80),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: isBusy ? null : () => Navigator.of(context).pop(),
              child: Text(
                widget.isEnglish ? 'Cancel' : 'Vazgeç',
                style: const TextStyle(color: _mutedCreamText),
              ),
            ),
            FilledButton(
              key: const Key('admin_login_submit_button'),
              style: FilledButton.styleFrom(
                backgroundColor: _goldAccent,
                foregroundColor: _pageBackground,
              ),
              onPressed: isBusy ? null : () => unawaited(_submit()),
              child: Text(
                isBusy
                    ? (widget.isEnglish ? 'Checking...' : 'Doğrulanıyor...')
                    : (widget.isEnglish ? 'Unlock' : 'Kilidi Aç'),
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }
}
