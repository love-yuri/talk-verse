import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/token_record.dart';
import '../services/token_usage_service.dart';
import '../utils/date_utils.dart';
import '../widgets/warm_background.dart';

class TokenUsageScreen extends StatefulWidget {
  const TokenUsageScreen({super.key});

  @override
  State<TokenUsageScreen> createState() => _TokenUsageScreenState();
}

class _TokenUsageScreenState extends State<TokenUsageScreen> {
  List<TokenRecord> _records = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final records = await TokenUsageService().load();
    if (!mounted) return;
    setState(() {
      _records = records;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        _buildAppBar(),
        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accent)))
        else if (_records.isEmpty)
          Expanded(child: _buildEmpty())
        else
          Expanded(child: _buildContent()),
      ]),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF9B7BB8), Color(0xFFB4A0D4), Color(0xFFD4BBFF)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(children: [
          TapScale(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(width: 10),
          const Text('Token 用量', style: TextStyle(fontFamily: 'MapleMono', fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.41)),
          const Spacer(),
          TapScale(
            onTap: () => _confirmClear(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline, size: 16, color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }

  void _confirmClear() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('清空记录'),
        content: const Text('确定要清空所有 Token 用量记录吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await TokenUsageService().clear();
              if (!mounted) return;
              setState(() => _records.clear());
            },
            child: const Text('清空', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final t = _aggregate();
    return SingleChildScrollView(
      child: Column(children: [
        const SizedBox(height: 16),
        _buildSummaryCard(t),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            const Text('请求记录', style: TextStyle(fontFamily: 'MapleMono', fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF6B4E9B))),
            const Spacer(),
            Text('${_records.length} 次请求', style: TextStyle(fontFamily: 'MapleMono', fontSize: 12, color: Colors.grey[400])),
          ]),
        ),
        const SizedBox(height: 10),
        ..._records.map((r) => _buildRecordCard(r)),
        const SizedBox(height: 32),
      ]),
    );
  }

  _Totals _aggregate() {
    int input = 0, cacheRead = 0, cacheCreate = 0, output = 0;
    for (final r in _records) {
      input += r.inputTokens;
      cacheRead += r.cacheReadTokens;
      cacheCreate += r.cacheCreateTokens;
      output += r.outputTokens;
    }
    return _Totals(input: input, cacheRead: cacheRead, cacheCreate: cacheCreate, output: output);
  }

  Widget _buildSummaryCard(_Totals t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5B3E85), Color(0xFF7B5EA7), Color(0xFFA48CC9)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: const Color(0xFF7B5EA7).withValues(alpha: 0.35), blurRadius: 24, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(children: [
          const Text('累计总计', style: TextStyle(fontFamily: 'MapleMono', fontSize: 11, fontWeight: FontWeight.w500, color: Color(0x99FFFFFF), letterSpacing: 0.15)),
          const SizedBox(height: 6),
          Text('${t.total}', style: const TextStyle(fontFamily: 'MapleMono', fontSize: 36, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.87, height: 1.1)),
          const Text('tokens', style: TextStyle(fontFamily: 'MapleMono', fontSize: 12, fontWeight: FontWeight.w400, color: Color(0x80FFFFFF))),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              _summaryCol('输入', t.input),
              _summaryDivider(),
              _summaryCol('缓存命中', t.cacheRead),
              _summaryDivider(),
              _summaryCol('输出', t.output),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _summaryCol(String label, int value) {
    return Expanded(
      child: Column(children: [
        Text('$value', style: const TextStyle(fontFamily: 'MapleMono', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: -0.26)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontFamily: 'MapleMono', fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.8))),
      ]),
    );
  }

  Widget _summaryDivider() {
    return Container(width: 1, height: 36, color: Colors.white.withValues(alpha: 0.15));
  }

  Widget _buildRecordCard(TokenRecord r) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: const Color(0xFFE8B4F8).withValues(alpha: 0.07), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 头部：角色 + 时间
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFD4BBFF), Color(0xFFE8B4F8)]),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.auto_awesome, size: 13, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.characterName, style: const TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
                      Text('${AppDateUtils.formatChatTime(r.timestamp)} · ${r.model}', style: TextStyle(fontFamily: 'MapleMono', fontSize: 10, color: Colors.grey[400])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0E6F6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${r.totalTokens}', style: const TextStyle(fontFamily: 'MapleMono', fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF6B4E9B))),
                ),
              ]),
            ),
            const SizedBox(height: 10),
            // token 分项
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF7FC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                _miniChip('输入', r.inputTokens),
                _miniChip('缓存命中', r.cacheReadTokens),
                _miniChip('输出', r.outputTokens),
              ]),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _miniChip(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$value', style: const TextStyle(fontFamily: 'MapleMono', fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2D2D2D))),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontFamily: 'MapleMono', fontSize: 10, color: Colors.grey[400])),
        ],
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
              gradient: const LinearGradient(colors: [Color(0xFFE8B4F8), Color(0xFFD4BBFF)]),
              boxShadow: [BoxShadow(color: const Color(0xFFE8B4F8).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: const Icon(Icons.data_usage_rounded, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text('暂无记录', style: TextStyle(fontFamily: 'MapleMono', fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF6B4E9B))),
          const SizedBox(height: 4),
          Text('发送消息后自动记录 Token 用量', style: TextStyle(fontFamily: 'MapleMono', fontSize: 12, color: Colors.grey[400])),
        ],
      ),
    );
  }
}

class _Totals {
  final int input;
  final int cacheRead;
  final int cacheCreate;
  final int output;
  const _Totals({required this.input, required this.cacheRead, required this.cacheCreate, required this.output});

  int get total => input + cacheRead + cacheCreate + output;
}
