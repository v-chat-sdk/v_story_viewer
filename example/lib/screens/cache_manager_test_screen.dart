import 'package:flutter/material.dart';
import 'package:v_platform/v_platform.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

/// Test screen for v_cache_manager functionality
///
/// Demonstrates:
/// - Progress streaming with URL filtering
/// - Multiple simultaneous downloads
/// - Cache hit/miss scenarios
/// - Retry logic
/// - All callback events
/// - VPlatformFile source types (network, file, assets, bytes)
class CacheManagerTestScreen extends StatefulWidget {
  const CacheManagerTestScreen({super.key});

  @override
  State<CacheManagerTestScreen> createState() => _CacheManagerTestScreenState();
}

class _CacheManagerTestScreenState extends State<CacheManagerTestScreen> {
  late VCacheController _cacheController;
  final List<String> _logs = [];
  final Map<String, VDownloadProgress> _progressMap = {};

  // Test URLs for different file types
  final List<TestMedia> _testMedia = [
    TestMedia(
      name: 'Image 1 (Small)',
      url: 'https://picsum.photos/400/600?random=1',
      type: 'Image',
    ),
    TestMedia(
      name: 'Image 2 (Medium)',
      url: 'https://picsum.photos/800/1200?random=2',
      type: 'Image',
    ),
    TestMedia(
      name: 'Image 3 (Large)',
      url: 'https://picsum.photos/1920/1080?random=3',
      type: 'Image',
    ),
    TestMedia(
      name: 'Video Sample',
      url:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
      type: 'Video',
    ),
    TestMedia(
      name: 'Video Sample 2',
      url: 'https://www.w3schools.com/html/mov_bbb.mp4',
      type: 'Video',
    ),
    TestMedia(
      name: 'Video Sample 3',
      url:
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
      type: 'Video',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCacheController();
  }

  void _initializeCacheController() {
    _cacheController = VCacheController(
      config: VCacheConfig(
        maxRetries: 3,
        retryPolicy: VRetryPolicy.exponential(),
      ),
    );

    // Listen to progress stream
    _cacheController.progressStream.listen((progress) {
      setState(() {
        _progressMap[progress.url] = progress;
      });
    });
  }

  void _addLog(String message) {
    setState(() {
      _logs.insert(
        0,
        '${DateTime.now().toIso8601String().split('T')[1].substring(0, 8)} - $message',
      );
      if (_logs.length > 50) {
        _logs.removeLast();
      }
    });
  }

  Future<void> _downloadSingle(TestMedia media) async {
    _addLog('🚀 Requesting: ${media.name}');
    final platformFile = VPlatformFile.fromUrl(networkUrl: media.url);
    final file = await _cacheController.getFile(platformFile);
    if (file != null) {
      _addLog('💾 File ready: ${file.path}');
    }
  }

  Future<void> _downloadMultiple() async {
    _addLog('🚀 Starting BATCH download (${_testMedia.length} files)');
    final futures = _testMedia.map((media) {
      final platformFile = VPlatformFile.fromUrl(networkUrl: media.url);
      return _cacheController.getFile(platformFile);
    }).toList();
    await Future.wait(futures);
    _addLog('✅ BATCH download complete!');
  }

  Future<void> _testCacheHit() async {
    _addLog('🔄 Testing cache hit (downloading same file)...');
    final platformFile = VPlatformFile.fromUrl(networkUrl: _testMedia[0].url);
    await _cacheController.getFile(platformFile);
  }

  Future<void> _clearCache() async {
    _addLog('🗑️ Clearing cache...');
    await _cacheController.clearCache();
    setState(() {
      _progressMap.clear();
    });
    _addLog('✅ Cache cleared!');
  }

  Future<void> _testInvalidUrl() async {
    _addLog('🧪 Testing invalid URL (retry logic)...');
    final platformFile = VPlatformFile.fromUrl(
      networkUrl: 'https://invalid-url-that-does-not-exist-12345.com/image.jpg',
    );
    await _cacheController.getFile(platformFile);
  }

  @override
  void dispose() {
    _cacheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cache Manager Test'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Action Buttons
          Container(
            color: Colors.grey[100],
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Test Actions',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _downloadMultiple(),
                      icon: const Icon(Icons.download),
                      label: const Text('Download All'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _testCacheHit(),
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Test Cache Hit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _testInvalidUrl(),
                      icon: const Icon(Icons.error),
                      label: const Text('Test Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _clearCache(),
                      icon: const Icon(Icons.delete),
                      label: const Text('Clear Cache'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Media List with Progress
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue[50],
                    child: const Text(
                      'Test Media Files',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: _testMedia.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final media = _testMedia[index];
                        final progress = _progressMap[media.url];
                        return MediaItem(
                          media: media,
                          progress: progress,
                          onDownload: () => _downloadSingle(media),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Logs
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.grey[800],
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Event Logs',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {
                            setState(() {
                              _logs.clear();
                            });
                          },
                          icon: const Icon(
                            Icons.clear_all,
                            size: 16,
                            color: Colors.white70,
                          ),
                          label: const Text(
                            'Clear',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _logs.isEmpty
                        ? const Center(
                            child: Text(
                              'No events yet. Try downloading files!',
                              style: TextStyle(color: Colors.white54),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemCount: _logs.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2,
                                ),
                                child: Text(
                                  _logs[index],
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    color: _getLogColor(_logs[index]),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getLogColor(String log) {
    if (log.contains('❌')) return Colors.red[300]!;
    if (log.contains('✅')) return Colors.green[300]!;
    if (log.contains('⚡')) return Colors.yellow[300]!;
    if (log.contains('📥')) return Colors.blue[300]!;
    return Colors.white70;
  }
}

/// Widget for displaying individual media item with progress
class MediaItem extends StatelessWidget {
  const MediaItem({
    required this.media,
    required this.progress,
    required this.onDownload,
    super.key,
  });

  final TestMedia media;
  final VDownloadProgress? progress;
  final VoidCallback onDownload;

  @override
  Widget build(BuildContext context) {
    final isDownloading = progress?.isDownloading ?? false;
    final isComplete = progress?.isComplete ?? false;
    final hasError = progress?.hasError ?? false;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        media.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        media.type,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (isComplete)
                  const Icon(Icons.check_circle, color: Colors.green, size: 24)
                else if (hasError)
                  const Icon(Icons.error, color: Colors.red, size: 24)
                else if (isDownloading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: onDownload,
                    color: Colors.blue,
                  ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress!.progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation(
                  hasError ? Colors.red : Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    progress!.percentageText,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    progress!.sizeText,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (hasError && progress!.error != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Error: ${progress!.error}',
                  style: const TextStyle(fontSize: 11, color: Colors.red),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// Test media data model
class TestMedia {
  const TestMedia({required this.name, required this.url, required this.type});

  final String name;
  final String url;
  final String type;
}
