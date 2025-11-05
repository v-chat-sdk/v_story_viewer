import 'package:flutter/material.dart';
import 'package:v_story_viewer/v_story_viewer.dart';

/// Example 1: Simple Custom Story without loading
///
/// Shows a simple custom widget without any async operations.
/// This is the simplest use case - just provide a widget.
class SimpleCustomStoryExample {
  static VCustomStory create() {
    return VCustomStory(
      id: 'simple_custom_1',
      groupId: 'custom_group',
      createdAt: DateTime.now(),
      duration: const Duration(seconds: 5),
      builder: (context) => Container(
        color: Colors.blue,
        child: const Center(
          child: Text(
            'Simple Custom Story',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
    );
  }
}

/// Example 2: Custom Story with Async Data Loading
///
/// Shows how to load data asynchronously and control the progress bar.
/// The progress bar is paused while data loads, then resumes when ready.
class AsyncCustomStoryExample {
  static VCustomStory create() {
    return VCustomStory(
      id: 'async_custom_1',
      groupId: 'custom_group',
      createdAt: DateTime.now(),
      duration: const Duration(seconds: 10),
      builder: (context) => const AsyncDataStoryWidget(),
      loadingBuilder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
      errorBuilder: (context, error) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed: ${error.toString()}',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class AsyncDataStoryWidget extends StatefulWidget {
  const AsyncDataStoryWidget({super.key});

  @override
  State<AsyncDataStoryWidget> createState() => _AsyncDataStoryWidgetState();
}

class _AsyncDataStoryWidgetState extends State<AsyncDataStoryWidget> {
  late Future<List<String>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<List<String>> _loadData() async {
    // Get the controller from the widget tree
    final controller = VCustomStoryControllerProvider.of(context);
    controller.startLoading();

    try {
      // Simulate async data loading (replace with actual API call)
      await Future.delayed(const Duration(seconds: 2));

      final data = [
        'Item 1',
        'Item 2',
        'Item 3',
      ];

      // Signal that loading is complete
      controller.finishLoading();
      return data;
    } catch (e) {
      // Signal error to the system
      controller.setError('Failed to load data: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        final items = snapshot.data ?? [];
        return Container(
          color: Colors.purple,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(
                items[index],
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Example 3: Interactive Custom Story with Pause/Resume
///
/// Shows how to implement a custom story that can pause/resume
/// independently (e.g., a game, animation, etc.)
class InteractiveCustomStoryExample {
  static VCustomStory create() {
    return VCustomStory(
      id: 'interactive_custom_1',
      groupId: 'custom_group',
      createdAt: DateTime.now(),
      duration: const Duration(seconds: 15),
      builder: (context) => const InteractiveStoryWidget(),
    );
  }
}

class InteractiveStoryWidget extends StatefulWidget {
  const InteractiveStoryWidget({super.key});

  @override
  State<InteractiveStoryWidget> createState() => _InteractiveStoryWidgetState();
}

class _InteractiveStoryWidgetState extends State<InteractiveStoryWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isAnimating = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  void _toggleAnimation() {
    final controller = VCustomStoryControllerProvider.maybeOf(context);

    if (_isAnimating) {
      _animationController.stop();
      controller?.pauseProgress();
      setState(() => _isAnimating = false);
    } else {
      _animationController.forward();
      controller?.resumeProgress();
      setState(() => _isAnimating = true);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleAnimation,
      child: Container(
        color: Colors.green,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: Tween<double>(begin: 0.8, end: 1.2).animate(
                  CurvedAnimation(
                    parent: _animationController,
                    curve: Curves.easeInOut,
                  ),
                ),
                child: const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _isAnimating ? 'Tap to pause' : 'Tap to resume',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Example 4: Custom Story with API Call
///
/// Shows how to fetch data from an API with proper error handling.
class ApiCustomStoryExample {
  static VCustomStory create() {
    return VCustomStory(
      id: 'api_custom_1',
      groupId: 'custom_group',
      createdAt: DateTime.now(),
      duration: const Duration(seconds: 8),
      builder: (context) => const ApiDataStoryWidget(),
      errorBuilder: (context, error) => Container(
        color: Colors.red.shade900,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Error loading story:\n$error',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class ApiDataStoryWidget extends StatefulWidget {
  const ApiDataStoryWidget({super.key});

  @override
  State<ApiDataStoryWidget> createState() => _ApiDataStoryWidgetState();
}

class _ApiDataStoryWidgetState extends State<ApiDataStoryWidget> {
  late Future<Map<String, dynamic>> _dateFuture;

  @override
  void initState() {
    super.initState();
    _dateFuture = _fetchFromApi();
  }

  Future<Map<String, dynamic>> _fetchFromApi() async {
    final controller = VCustomStoryControllerProvider.of(context);
    controller.startLoading();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Replace with actual API call:
      // final response = await http.get(Uri.parse('https://api.example.com/data'));
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   controller.finishLoading();
      //   return data;
      // } else {
      //   throw Exception('API error: ${response.statusCode}');
      // }

      final data = {
        'title': 'API Data Story',
        'content': 'This data was fetched from an API',
        'timestamp': DateTime.now().toString(),
      };

      controller.finishLoading();
      return data;
    } catch (e) {
      controller.setError('Failed to fetch data: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dateFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            color: Colors.grey[800],
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            color: Colors.red[900],
            child: Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        }

        final data = snapshot.data ?? {};
        return Container(
          color: Colors.blue[900],
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data['title'] ?? 'No title',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['content'] ?? 'No content',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    data['timestamp'] ?? 'No timestamp',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Example 5: Custom Story with Form Input
///
/// Shows how to create a custom story with user input.
class FormCustomStoryExample {
  static VCustomStory create() {
    return VCustomStory(
      id: 'form_custom_1',
      groupId: 'custom_group',
      createdAt: DateTime.now(),
      duration: const Duration(seconds: 12),
      builder: (context) => const FormStoryWidget(),
    );
  }
}

class FormStoryWidget extends StatefulWidget {
  const FormStoryWidget({super.key});

  @override
  State<FormStoryWidget> createState() => _FormStoryWidgetState();
}

class _FormStoryWidgetState extends State<FormStoryWidget> {
  final TextEditingController _nameController = TextEditingController();
  String _submittedName = '';

  void _handleSubmit() {
    if (_nameController.text.isEmpty) return;

    // Pause progress bar while processing
    final controller = VCustomStoryControllerProvider.maybeOf(context);
    controller?.pauseProgress();

    setState(() => _submittedName = _nameController.text);

    // Resume after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        controller?.resumeProgress();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange,
      child: Center(
        child: _submittedName.isEmpty
            ? Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Enter your name:',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Your name',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            )
            : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Hello,',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  _submittedName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
      ),
    );
  }
}

/// Helper to create a list of example stories
List<VStoryGroup> getExampleCustomStories() {
  return [
    VStoryGroup(
      user: const VStoryUser(
        id: 'custom_group',
        username: 'Custom Stories',
        profilePicture: null,
      ),
      stories: [
        SimpleCustomStoryExample.create(),
        AsyncCustomStoryExample.create(),
        InteractiveCustomStoryExample.create(),
        ApiCustomStoryExample.create(),
        FormCustomStoryExample.create(),
      ],
    ),
  ];
}
