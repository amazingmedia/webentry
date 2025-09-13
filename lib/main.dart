import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:image_picker/image_picker.dart';

// Mouse drag ဖြင့် scroll လုပ်နိုင်ရန် Custom Scroll Behavior
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.stylus,
    PointerDeviceKind.mouse,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://covndqwpnfcpqwsedruo.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNvdm5kcXdwbmZjcHF3c2VkcnVvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0MDQzNDgsImV4cCI6MjA3Mjk4MDM0OH0.T3GZWrSkmmw5fn6AE2shvfvuhp2UqU-i5N0uo74caKs',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reason For Entry',
      debugShowCheckedModeBanner: false,
      // App တစ်ခုလုံးတွင် Mouse drag ဖြင့် scroll လုပ်နိုင်ရန်
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: Colors.tealAccent,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E).withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 4,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.tealAccent.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
      home: const InitialPage(),
    );
  }
}

//--- Auth Pages ---

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(Duration.zero);
    final session = Supabase.instance.client.auth.currentSession;
    if (mounted) {
      if (session != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator(color: Colors.tealAccent)),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final AuthResponse res = await _supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (res.session != null && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MyHomePage()),
        );
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message, style: GoogleFonts.poppins()),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'An unexpected error occurred: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.tealAccent,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: GoogleFonts.poppins(color: Colors.white70),
                  decoration: InputDecoration(
                    hintText: 'Email',
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: Colors.tealAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  style: GoogleFonts.poppins(color: Colors.white70),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Colors.tealAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.tealAccent,
                        ),
                      )
                    : _buildGradientButton(
                        onPressed: _signIn,
                        child: Text(
                          'Sign In',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//--- Main Application Page ---

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _displayTextLines = [];
  final List<TextEditingController> _controllers = [];
  final _supabase = Supabase.instance.client;

  bool _showNumberButtons = true;
  bool _showTimeframeButtons = false;
  bool _showPatternButtons = false;
  bool _showOptionButtons = false;
  bool _isLoading = false;

  List<dynamic> _options = [];
  dynamic _selectedOption;
  String _currentType = '';

  void _signOut() async {
    try {
      await _supabase.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to sign out: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  void _handleNumberButton(int number) {
    setState(() {
      _displayTextLines.add("$number/");
      _controllers.add(TextEditingController(text: "$number/"));
      _showNumberButtons = false;
      _showTimeframeButtons = true;
    });
  }

  Future<void> _handleTimeframeButton(String timeframe) async {
    if (timeframe == 'Chart pattern') {
      setState(() {
        _showTimeframeButtons = false;
        _showPatternButtons = true;
      });
      return;
    }
    setState(() {
      _isLoading = true;
      _showTimeframeButtons = false;
      _currentType = 'text';
    });
    try {
      final response = await _supabase
          .from('options')
          .select('value')
          .eq('type', timeframe);
      if (!mounted) return;
      List<String> fetchedOptions = (response as List)
          .map((item) => item['value'].toString())
          .toList();
      setState(() {
        _isLoading = false;
        _options = fetchedOptions;
        _showOptionButtons = true;
        _selectedOption = null;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePatternButton(String patternType) async {
    setState(() {
      _isLoading = true;
      _showPatternButtons = false;
      _currentType = 'image';
    });
    try {
      final response = await _supabase
          .from('patterns')
          .select('text_value, image_url, folder_path')
          .eq('type', patternType)
          .order('sort_order', ascending: true);
      if (!mounted) return;
      List<Map<String, dynamic>> fetchedOptions = (response as List)
          .map(
            (item) => {
              'text': item['text_value'].toString(),
              'image': item['image_url'].toString(),
              'folder_path': item['folder_path'].toString(),
            },
          )
          .toList();
      setState(() {
        _isLoading = false;
        _options = fetchedOptions;
        _showOptionButtons = true;
        _selectedOption = null;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleOptionSelect(dynamic option) {
    setState(() => _selectedOption = option);
  }

  void _handleDoneButton() {
    if (_selectedOption != null) {
      setState(() {
        final lastLineIndex = _displayTextLines.length - 1;
        String selectedValue = _currentType == 'image'
            ? _selectedOption['text']
            : _selectedOption;
        final updatedText =
            "${_displayTextLines[lastLineIndex]} $selectedValue";
        _displayTextLines[lastLineIndex] = updatedText;
        _controllers[lastLineIndex].text = updatedText;

        _showNumberButtons = true;
        _showOptionButtons = false;
        _showTimeframeButtons = false;
        _showPatternButtons = false;
        _selectedOption = null;
        _options = [];
      });
    }
  }

  void _handleBackButton() {
    setState(() {
      _showOptionButtons = false;
      if (_currentType == 'image') {
        _showPatternButtons = true;
      } else {
        _showTimeframeButtons = true;
      }
      _selectedOption = null;
      _options = [];
    });
  }

  void _showGalleryModal() {
    final folderPath = _selectedOption?['folder_path']?.toString() ?? '';
    if (folderPath.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: GalleryPage(
            folderPath: folderPath,
            selectedOption: _selectedOption,
            onDone: () {
              Navigator.of(context).pop();
              _handleDoneButton();
            },
          ),
        ),
      ),
    );
  }

  void _copyAllText() {
    final textToCopy = _controllers.map((c) => c.text).join('\n');
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'စာသားအားလုံးကို ကူးယူပြီးပါပြီ။',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.teal,
      ),
    );
  }

  void _clearAllText() {
    setState(() {
      _displayTextLines.clear();
      for (var controller in _controllers) {
        controller.dispose();
      }
      _controllers.clear();
      _showNumberButtons = true;
      _showTimeframeButtons = false;
      _showPatternButtons = false;
      _showOptionButtons = false;
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reason For Entry'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 800) {
            return _buildWideLayout();
          } else {
            return _buildNarrowLayout();
          }
        },
      ),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildTextPanel()),
        const VerticalDivider(width: 1, thickness: 1),
        Expanded(flex: 3, child: _buildControlPanel()),
      ],
    );
  }

  Widget _buildNarrowLayout() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(flex: 2, child: _buildTextPanel()),
          const SizedBox(height: 16),
          Expanded(flex: 3, child: _buildControlPanel()),
        ],
      ),
    );
  }

  Widget _buildTextPanel() {
    return Material(
      color: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Entry Reasons',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: Colors.tealAccent),
                ),
                if (_displayTextLines.isNotEmpty)
                  Row(
                    children: [
                      _buildGradientButton(
                        onPressed: _copyAllText,
                        child: const Icon(Icons.copy_all, size: 18),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildGradientButton(
                        onPressed: _clearAllText,
                        child: const Icon(Icons.clear_all, size: 18),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: _displayTextLines.isEmpty
                  ? Center(
                      child: Text(
                        'Start by selecting a number from the right panel.',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Card(
                      child: ListView.builder(
                        itemCount: _controllers.length,
                        itemBuilder: (context, index) => Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 4.0,
                          ),
                          child: TextField(
                            controller: _controllers[index],
                            onChanged: (newText) =>
                                _displayTextLines[index] = newText,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            maxLines: null,
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: animation, child: child),
        ),
        child: _buildCurrentStateWidget(),
      ),
    );
  }

  Widget _buildCurrentStateWidget() {
    if (_showNumberButtons) {
      return _buildSelector<int>(
        'Select a Number',
        List.generate(10, (i) => i + 1),
        _handleNumberButton,
      );
    }
    if (_showTimeframeButtons) {
      return _buildSelector<String>('Select Timeframe / Type', [
        'Weekly',
        'Daily',
        'H4',
        'H1',
        '15min',
        'Chart pattern',
        'Entry',
      ], _handleTimeframeButton);
    }
    if (_showPatternButtons) {
      return _buildSelector<String>('Select Pattern Type', [
        'RC',
        'CC',
      ], _handlePatternButton);
    }
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.tealAccent),
      );
    }
    if (_showOptionButtons) {
      return _buildOptionSelector();
    }
    return const SizedBox.shrink();
  }

  Widget _buildSelector<T>(
    String title,
    List<T> items,
    Function(T) onSelected,
  ) {
    return Column(
      key: ValueKey(title),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          alignment: WrapAlignment.center,
          children: items
              .map(
                (item) => _buildGradientButton(
                  onPressed: () => onSelected(item),
                  child: Text(item.toString()),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _buildOptionSelector() {
    return Column(
      key: const ValueKey('options'),
      children: [
        Expanded(
          child: _currentType == 'image'
              ? _buildImageOptionGrid()
              : _buildTextOptionWrap(),
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 16.0,
          runSpacing: 12.0,
          children: [
            _buildGradientButton(
              onPressed: _handleBackButton,
              child: const Text('Back'),
            ),
            _buildGradientButton(
              onPressed: _selectedOption != null ? _handleDoneButton : null,
              child: const Text('Done'),
            ),
            if (_currentType == 'image' && _selectedOption != null)
              _buildGradientButton(
                onPressed: _showGalleryModal,
                child: const Text('View'),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildImageOptionGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: _options.length,
      itemBuilder: (context, index) {
        final option = _options[index];
        final isSelected = _selectedOption?['text'] == option['text'];
        return GestureDetector(
          onTap: () => _handleOptionSelect(option),
          child: Card(
            color: isSelected ? Colors.teal : const Color(0xFF1E1E1E),
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
              side: BorderSide(
                color: isSelected ? Colors.tealAccent : Colors.transparent,
                width: 2.0,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.network(
                      option['image'],
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.error, color: Colors.redAccent);
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 12,
                  ),
                  child: Text(
                    option['text'],
                    style: GoogleFonts.poppins(
                      color: isSelected ? Colors.white : Colors.tealAccent,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextOptionWrap() {
    return SingleChildScrollView(
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        alignment: WrapAlignment.center,
        children: _options.map((option) {
          final isSelected = _selectedOption == option;
          return _buildGradientButton(
            onPressed: () => _handleOptionSelect(option),
            child: Text(option),
            isSelected: isSelected,
          );
        }).toList(),
      ),
    );
  }
}

//--- Helper Widgets ---

Widget _buildGradientButton({
  required VoidCallback? onPressed,
  required Widget child,
  bool isSelected = false,
  EdgeInsets? padding,
}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      gradient: LinearGradient(
        colors: isSelected
            ? [Colors.teal, Colors.tealAccent]
            : onPressed != null
            ? [Colors.grey[800]!, Colors.grey[700]!]
            : [Colors.grey[850]!, Colors.grey[800]!],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          offset: const Offset(4, 4),
          blurRadius: 8,
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style:
          ElevatedButton.styleFrom(
            padding:
                padding ??
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ).copyWith(
            overlayColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.hovered)) {
                return Colors.white.withOpacity(0.1);
              }
              return null;
            }),
          ),
      child: child,
    ),
  );
}

//--- Gallery Widgets ---

class GalleryPage extends StatefulWidget {
  final String folderPath;
  final VoidCallback onDone;
  final dynamic selectedOption;

  const GalleryPage({
    super.key,
    required this.folderPath,
    required this.onDone,
    required this.selectedOption,
  });

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  final picker = ImagePicker();
  final _supabase = Supabase.instance.client;

  List<Map<String, String>> _currentGalleryItems = [];
  bool _isLoading = true;
  bool _isUploading = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _refreshGallery();
  }

  Future<void> _refreshGallery() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final List<FileObject> images = await _supabase.storage
          .from('Image')
          .list(path: widget.folderPath);
      final List<Map<String, String>> items = images.map((file) {
        final publicUrl = _supabase.storage
            .from('Image')
            .getPublicUrl('${widget.folderPath}/${file.name}');
        return {'url': publicUrl, 'path': '${widget.folderPath}/${file.name}'};
      }).toList();

      if (mounted) {
        setState(() {
          _currentGalleryItems = items;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadImage() async {
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles.isEmpty || !mounted) return;

    setState(() => _isUploading = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${pickedFiles.length} ပုံ တင်နေပါပြီ...'),
        backgroundColor: Colors.teal,
      ),
    );

    int successCount = 0;
    int failCount = 0;

    for (final file in pickedFiles) {
      try {
        final fileBytes = await file.readAsBytes();
        final fileName = file.name;

        await _supabase.storage
            .from('Image')
            .uploadBinary(
              '${widget.folderPath}/$fileName',
              fileBytes,
              fileOptions: const FileOptions(
                cacheControl: '3600',
                upsert: true,
              ),
            );
        successCount++;
      } catch (e) {
        failCount++;
        print('Failed to upload ${file.name}: $e');
      }
    }

    await _refreshGallery();

    if (mounted) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'တင်ခြင်းပြီးပါပြီ။ အောင်မြင်: $successCount ပုံ, မအောင်မြင်: $failCount ပုံ။',
          ),
          backgroundColor: failCount > 0 ? Colors.orangeAccent : Colors.teal,
        ),
      );
    }
  }

  Future<void> _deleteImage(String path) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Image'),
        content: const Text('ဤပုံကို ဖျက်ချင်တာ သေချာပါသလား?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (mounted) setState(() => _isDeleting = true);

    try {
      await _supabase.storage.from('Image').remove([path]);
      await _refreshGallery();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ပုံကို ဖျက်ပြီးပါပြီ။'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ပုံ ဖျက်ခြင်း မအောင်မြင်ပါ: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  void _openPhotoViewer(BuildContext context, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenImageViewer(
          galleryItems: _currentGalleryItems,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Gallery', style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  )
                : _currentGalleryItems.isEmpty
                ? const Center(child: Text('No images found in this gallery.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 200,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                    itemCount: _currentGalleryItems.length,
                    itemBuilder: (context, index) {
                      final item = _currentGalleryItems[index];
                      final path = item['path']!;

                      return GestureDetector(
                        onTap: () => _openPhotoViewer(context, index),
                        child: GridTile(
                          footer: GridTileBar(
                            backgroundColor: Colors.black45,
                            trailing: IconButton(
                              icon: _isDeleting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.delete_outline),
                              onPressed: () => _deleteImage(path),
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(
                              item['url']!,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.tealAccent,
                                      ),
                                    );
                                  },
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.error,
                                  color: Colors.redAccent,
                                  size: 50,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isUploading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.tealAccent),
                  )
                : Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 16.0,
                    runSpacing: 12.0,
                    children: [
                      _buildGradientButton(
                        onPressed: widget.onDone,
                        child: const Text('Done'),
                      ),
                      _buildGradientButton(
                        onPressed: _uploadImage,
                        child: const Text('Upload'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImageViewer extends StatefulWidget {
  final List<Map<String, String>> galleryItems;
  final int initialIndex;

  const FullScreenImageViewer({
    super.key,
    required this.galleryItems,
    required this.initialIndex,
  });

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer> {
  late PageController _pageController;
  late int _currentIndex;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  PhotoViewScaleState scaleStateCycle(PhotoViewScaleState actual) {
    switch (actual) {
      case PhotoViewScaleState.initial:
        return PhotoViewScaleState.covering;
      case PhotoViewScaleState.covering:
        return PhotoViewScaleState.originalSize;
      case PhotoViewScaleState.originalSize:
        return PhotoViewScaleState.initial;
      case PhotoViewScaleState.zoomedIn:
      case PhotoViewScaleState.zoomedOut:
        return PhotoViewScaleState.initial;
      default:
        return PhotoViewScaleState.initial;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.7),
          elevation: 0,
          title: Text(
            '${_currentIndex + 1} / ${widget.galleryItems.length}',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: PhotoViewGallery.builder(
          allowImplicitScrolling: true,
          itemCount: widget.galleryItems.length,
          builder: (context, index) {
            final item = widget.galleryItems[index];
            return PhotoViewGalleryPageOptions(
              imageProvider: NetworkImage(item['url']!),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2.5,
              initialScale: PhotoViewComputedScale.contained,
              heroAttributes: PhotoViewHeroAttributes(tag: item['url']!),
              scaleStateCycle: scaleStateCycle,
            );
          },
          scrollPhysics: const BouncingScrollPhysics(),
          pageController: _pageController,
          onPageChanged: onPageChanged,
          loadingBuilder: (context, event) => const Center(
            child: CircularProgressIndicator(color: Colors.tealAccent),
          ),
        ),
      ),
    );
  }
}
