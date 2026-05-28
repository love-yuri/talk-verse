import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/token_record.dart';
import '../services/token_usage_service.dart';
import '../utils/date_utils.dart';
import '../widgets/glass_header.dart';

class TokenUsageScreen extends StatefulWidget {
  const TokenUsageScreen({super.key});

  @override
  State<TokenUsageScreen> createState() => _TokenUsageScreenState();
}

class _TokenUsageScreenState extends State<TokenUsageScreen> {
  static const int _pageSize = 24;

  final _service = TokenUsageService();
  final _scrollCtrl = ScrollController();

  final List<TokenRecord> _records = [];
  TokenUsageSummary _summary = TokenUsageSummary.empty;

  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  int _offset = 0;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_handleScroll);
    _load();
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _handleScroll() {
    if (_loadingMore || !_hasMore) return;
    final position = _scrollCtrl.position;
    if (position.maxScrollExtent - position.pixels <= 180) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    final summary = await _service.loadSummary();
    final firstPage = await _service.loadPage(limit: _pageSize, offset: 0);

    if (!mounted) return;

    setState(() {
      _summary = summary;
      _records
        ..clear()
        ..addAll(firstPage);
      _offset = firstPage.length;
      _hasMore = _offset < _summary.recordCount;
      _loading = false;
    });
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;

    setState(() => _loadingMore = true);

    final next = await _service.loadPage(limit: _pageSize, offset: _offset);
    if (!mounted) return;

    setState(() {
      _records.addAll(next);
      _offset = _records.length;
      _hasMore = _offset < _summary.recordCount;
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildAppBar(),
          if (_loading)
            const Expanded(
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accent,
                ),
              ),
            )
          else
            Expanded(
              child: RefreshIndicator(onRefresh: _load, child: _buildContent()),
            ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return GlassHeader(
      leading: GlassHeader.iconBtn(Icons.arrow_back_ios_new, onTap: () => Navigator.pop(context)),
      subtitle: '统计',
      title: 'Token 用量',
      badge: '${_summary.recordCount}',
      actions: [
        GlassHeader.iconBtn(Icons.delete_outline, onTap: _confirmClear),
      ],
    );
  }

  Widget _buildContent() {
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemBuilder: (context, index) {
        if (index == 0) return _buildSummaryCard();

        if (index == 1) {
          return Padding(
            padding: const EdgeInsets.only(top: 20, bottom: 10),
            child: Row(
              children: [
                const Text(
                  '请求记录',
                  style: TextStyle(
                    fontFamily: 'MapleMono',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_summary.recordCount} 次',
                  style: const TextStyle(
                    fontFamily: 'MapleMono',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        if (_records.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 30),
            child: _buildEmpty(),
          );
        }

        final recordIndex = index - 2;
        if (recordIndex < _records.length) {
          return _buildRecordCard(_records[recordIndex]);
        }

        if (_hasMore) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: _loadingMore
                  ? const CircularProgressIndicator(color: AppColors.accent)
                  : const SizedBox.shrink(),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Center(
            child: Text(
              '已经到底啦',
              style: const TextStyle(
                fontFamily: 'MapleMono',
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        );
      },
      itemCount: _records.isEmpty
          ? 3
          : _records.length + 3 + (_loadingMore ? 0 : 0),
    );
  }

  void _confirmClear() {
    if (_records.isEmpty) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('清空记录'),
        content: const Text('确定要清空所有 Token 用量记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _service.clear();
              if (!mounted) return;
              _scrollCtrl.jumpTo(0);
              await _load();
            },
            child: const Text('清空', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surfaceGlass,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.7),
          width: 0.6,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '累计总计',
            style: TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 0.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_summary.totalTokens}',
            style: const TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.87,
              height: 1.1,
            ),
          ),
          const Text(
            'tokens',
            style: TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.7),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                _summaryCol('输入', _summary.inputTokens),
                _summaryDivider(),
                _summaryCol('缓存命中', _summary.cacheReadTokens),
                _summaryDivider(),
                _summaryCol('缓存新增', _summary.cacheCreateTokens),
                _summaryDivider(),
                _summaryCol('输出', _summary.outputTokens),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCol(String label, int value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$value',
            style: const TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: -0.26,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryDivider() {
    return Container(width: 1, height: 36, color: AppColors.border);
  }

  Widget _buildRecordCard(TokenRecord r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.border.withValues(alpha: 0.75),
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          r.characterName,
                          style: const TextStyle(
                            fontFamily: 'MapleMono',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${AppDateUtils.formatChatTime(r.timestamp)} · ${r.model}',
                          style: const TextStyle(
                            fontFamily: 'MapleMono',
                            fontSize: 10,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${r.totalTokens}',
                      style: const TextStyle(
                        fontFamily: 'MapleMono',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceGlass,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  _miniChip('输入', r.inputTokens),
                  _miniChip('缓存命中', r.cacheReadTokens),
                  _miniChip('缓存新增', r.cacheCreateTokens),
                  _miniChip('输出', r.outputTokens),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(String label, int value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$label：$value',
        style: const TextStyle(
          fontFamily: 'MapleMono',
          fontSize: 11,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentLight,
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.data_usage_rounded,
              size: 32,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '暂无记录',
            style: TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '发送消息后会自动记录 Token 用量',
            style: TextStyle(
              fontFamily: 'MapleMono',
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
