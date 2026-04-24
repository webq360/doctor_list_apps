import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';

class BannerSlider extends StatefulWidget {
  const BannerSlider({super.key});

  @override
  State<BannerSlider> createState() => _BannerSliderState();
}

class _BannerSliderState extends State<BannerSlider> {
  List<Map<String, dynamic>> _banners = [];
  final PageController _pageCtrl = PageController();
  int _current = 0;
  Timer? _timer;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchBanners();
  }

  Future<void> _fetchBanners() async {
    try {
      final res = await ApiClient.dio
          .get('/banners', queryParameters: {'category': 'home_slider'});
      final data = res.data;
      if (!mounted) return;
      if (data is! List) {
        setState(() {
          _loading = false;
          _error = 'Invalid response';
        });
        return;
      }
      final list = data.whereType<Map<String, dynamic>>().toList();
      setState(() {
        _banners = list;
        _loading = false;
      });
      if (list.length > 1) _startTimer();
    } catch (e) {
      debugPrint('BannerSlider error: $e');
      if (mounted)
        setState(() {
          _loading = false;
          _error = e.toString();
        });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _banners.isEmpty) return;
      final next = (_current + 1) % _banners.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const _BannerPlaceholder();
    if (_error != null || _banners.isEmpty) {
      return Container(
        height: 180,
        color: const Color(0xFFE8ECFF),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, color: Color(0xFF2B3EE6), size: 32),
              const SizedBox(height: 8),
              Text(
                _error != null ? 'Connection error' : 'No banners',
                style: const TextStyle(color: Color(0xFF2B3EE6), fontSize: 12),
              ),
              if (_error != null) ...[
                const SizedBox(height: 4),
                Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 10),
                    textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 180,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _banners.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) {
              final b = _banners[i];
              return Image.network(
                b['imageUrl'] ?? '',
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE8ECFF),
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        color: Color(0xFF2B3EE6), size: 40),
                  ),
                ),
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : Container(
                        color: const Color(0xFFF0F0F0),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
              );
            },
          ),
          // Dot indicators
          if (_banners.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_banners.length, (i) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: _current == i ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _current == i
                          ? const Color(0xFF2B3EE6)
                          : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      color: const Color(0xFFE8ECFF),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      ),
    );
  }
}
