import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';

void main() {
  runApp(const StorytellingApp());
}

class StorytellingApp extends StatelessWidget {
  const StorytellingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Interactive Storytelling',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurpleAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ),
      home: const StoryHomePage(),
    );
  }
}

class StoryHomePage extends StatefulWidget {
  const StoryHomePage({super.key});

  @override
  State<StoryHomePage> createState() => _StoryHomePageState();
}

class _StoryHomePageState extends State<StoryHomePage> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse('https://cdn.pixabay.com/video/2016/11/04/6266-190550868_large.mp4'),
    )
      ..initialize().then((_) {
        _controller.setLooping(true);
        _controller.setVolume(0);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_controller.value.isInitialized)
            VideoPlayer(_controller),
          Container(color: Colors.black.withOpacity(0.6)),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Story Verse',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Immersive Storytelling Experience',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GenreSelectionPage()),
                    );
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text(
                    "Begin Your Journey",
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class GenreSelectionPage extends StatefulWidget {
  const GenreSelectionPage({super.key});

  @override
  State<GenreSelectionPage> createState() => _GenreSelectionPageState();
}

class _GenreSelectionPageState extends State<GenreSelectionPage> {
  final List<String> genres = ['Fantasy', 'Sci-Fi', 'Indian Mythology', 'Adventure'];
  final List<String> languages = ['English', 'Kannada', 'Hindi'];

  String selectedLanguage = 'English';
  String selectedGenre = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Create Your Story",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/image/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.7)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.white24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selectedLanguage,
                        dropdownColor: Colors.deepPurple,
                        style: const TextStyle(color: Colors.white, fontSize: 18),
                        iconEnabledColor: Colors.white,
                        items: languages
                            .map((lang) => DropdownMenuItem(
                          value: lang,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.language,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Text(lang),
                            ],
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedLanguage = value);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Choose Your Genre',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: genres.length,
                      itemBuilder: (context, index) {
                        final genre = genres[index];
                        return GenreCard(
                          genre: genre,
                          isSelected: selectedGenre == genre,
                          onTap: () {
                            setState(() {
                              selectedGenre = genre;
                            });
                          },
                          onStart: () {
                            if (selectedGenre.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StoryPage(
                                    genre: selectedGenre,
                                    language: selectedLanguage,
                                  ),
                                ),
                              );
                            }
                          },
                          onInteractive: () {
                            if (selectedGenre.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InteractiveStoryPage(
                                    genre: selectedGenre,
                                    language: selectedLanguage,
                                  ),
                                ),
                              );
                            }
                          },
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
}

class GenreCard extends StatelessWidget {
  final String genre;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onStart;
  final VoidCallback onInteractive;

  const GenreCard({
    super.key,
    required this.genre,
    required this.isSelected,
    required this.onTap,
    required this.onStart,
    required this.onInteractive,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepPurpleAccent.withOpacity(0.8)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? Colors.deepPurpleAccent
                : Colors.white24,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.deepPurpleAccent.withOpacity(0.5),
              blurRadius: 15,
              spreadRadius: 2,
            )
          ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                genre,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              if (isSelected) ...[
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final buttonWidth = (constraints.maxWidth - 16) / 2;
                    return Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        SizedBox(
                          width: buttonWidth,
                          child: ElevatedButton(
                            onPressed: onStart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.deepPurple,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Text(
                                'Start',
                                style: TextStyle(fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: buttonWidth,
                          child: ElevatedButton(
                            onPressed: onInteractive,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              child: Text(
                                'Interactive',
                                style: TextStyle(fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class StoryPage extends StatefulWidget {
  final String genre;
  final String language;

  const StoryPage({
    super.key,
    required this.genre,
    required this.language
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();
  List<String> storySentences = [];
  int currentSentenceIndex = 0;
  bool isLoading = true;
  String errorMessage = '';
  bool translationFailed = false;
  bool ttsAvailable = true;

  @override
  void initState() {
    super.initState();
    developer.log('Initializing StoryPage for ${widget.genre} in ${widget.language}');
    initTts();
    fetchStory();
    playAmbientMusic();
  }

  Future<void> initTts() async {
    try {
      developer.log('Initializing TTS engine');

      // Get available languages
      final languages = await flutterTts.getLanguages;
      developer.log('Available TTS languages: $languages');

      // Set language based on selection
      String ttsLanguage = _getTtsLanguageCode(widget.language);
      developer.log('Attempting to set TTS language to: $ttsLanguage');

      // Check if language is available
      if (languages.contains(ttsLanguage)) {
        await flutterTts.setLanguage(ttsLanguage);
        developer.log('TTS language set to: $ttsLanguage');
        setState(() => ttsAvailable = true);
      } else {
        developer.log('Requested language not available, falling back to English');
        await flutterTts.setLanguage('en-US');
        setState(() => ttsAvailable = false);
      }

      await flutterTts.setSpeechRate(0.55);
      await flutterTts.setPitch(1.0);
      await flutterTts.awaitSpeakCompletion(true);
      developer.log('TTS engine initialized successfully');
    } catch (e) {
      developer.log('TTS initialization failed: $e', error: e);
      setState(() => ttsAvailable = false);
    }
  }

  Future<void> playAmbientMusic() async {
    try {
      developer.log('Starting ambient music');
      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      await audioPlayer.play(AssetSource('audio/piano.mp3'));
      developer.log('Ambient music started');
    } catch (e) {
      developer.log('Failed to play ambient music: $e', error: e);
    }
  }

  Future<void> fetchStory() async {
    const String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyD3IMk7vpWbOQLcjDuKTmNNlbL4VZ6Pxxw';

    final String prompt =
        "You are an amazing storyteller. Write a vivid, age-appropriate, and creative short story (around 100 words) in the genre: ${widget.genre}. Keep it exciting and magical. End the story with 'The End'.";

    try {
      developer.log('Fetching story from API with prompt: $prompt');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [{'text': prompt}]
            }
          ]
        }),
      );

      developer.log('API response status: ${response.statusCode}');
      developer.log('API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          throw Exception('No story content received from API');
        }

        final String story = data['candidates'][0]['content']['parts'][0]['text'];
        developer.log('Original story received: $story');

        // Always keep the original English story as fallback
        List<String> englishSentences = story
            .split(RegExp(r'(?<=[.!?])\s+'))
            .where((s) => s.trim().isNotEmpty)
            .toList();

        if (widget.language == 'English') {
          if (!mounted) return;
          developer.log('Using English story directly');
          setState(() {
            storySentences = englishSentences;
            isLoading = false;
          });
          startNarration(englishSentences);
        } else {
          // For other languages, try to translate each sentence individually
          try {
            developer.log('Starting translation to ${widget.language}');
            List<String> translatedSentences = [];

            for (String sentence in englishSentences) {
              developer.log('Translating sentence: $sentence');
              final translated = await translateStory(sentence, widget.language);
              translatedSentences.add(translated);
              developer.log('Translated to: $translated');
            }

            if (!mounted) return;
            developer.log('Translation completed successfully');
            setState(() {
              storySentences = translatedSentences;
              isLoading = false;
              translationFailed = false;
            });
            startNarration(translatedSentences);
          } catch (e) {
            developer.log('Translation failed: $e', error: e);
            // If translation fails, fall back to English
            if (!mounted) return;
            setState(() {
              storySentences = englishSentences;
              isLoading = false;
              translationFailed = true;
              errorMessage = 'Translation failed: Showing English version';
            });
            startNarration(englishSentences);
          }
        }
      } else {
        throw Exception('Failed to fetch story: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Story fetch error: $e', error: e);
      if (!mounted) return;
      showError("Failed to fetch story: ${e.toString()}");
    }
  }

  Future<String> translateStory(String text, String language) async {
    if (language == 'English') return text;

    final targetLang = _getLanguageCode(language);
    try {
      developer.log('Calling MyMemory API for $language ($targetLang)');
      final response = await http.get(
        Uri.https(
          'api.mymemory.translated.net',
          '/get',
          {
            'q': text,
            'langpair': 'en|$targetLang',
          },
        ),
      );

      developer.log('MyMemory API response: ${response.statusCode}');
      developer.log('MyMemory API body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['responseData'] != null && data['responseData']['translatedText'] != null) {
          return data['responseData']['translatedText'];
        } else {
          throw Exception('Invalid MyMemory API response format');
        }
      } else {
        throw Exception('MyMemory API error: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Translation error: $e', error: e);
      throw Exception('Translation failed: ${e.toString()}');
    }
  }

  String _getLanguageCode(String language) {
    switch (language) {
      case 'Hindi':
        return 'hi';
      case 'Kannada':
        return 'kn';
      case 'Tamil':
        return 'ta';
      case 'Telugu':
        return 'te';
      default:
        return 'en';
    }
  }

  String _getTtsLanguageCode(String language) {
    switch (language) {
      case 'Hindi':
        return 'hi-IN';
      case 'Kannada':
        return 'kn-IN';
      case 'Tamil':
        return 'ta-IN';
      case 'Telugu':
        return 'te-IN';
      default:
        return 'en-US';
    }
  }

  Future<void> startNarration(List<String> sentences) async {
    try {
      if (!ttsAvailable) {
        developer.log('TTS not available for this language');
        return;
      }

      developer.log('Starting narration for ${sentences.length} sentences');
      for (int i = 0; i < sentences.length; i++) {
        if (!mounted) return;
        setState(() {
          currentSentenceIndex = i;
        });

        developer.log('Speaking sentence $i: ${sentences[i]}');
        await flutterTts.speak(sentences[i]);
        await Future.delayed(const Duration(milliseconds: 200));
      }
      developer.log('Narration completed');
    } catch (e) {
      developer.log('Narration error: $e', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Speech synthesis not available for this language'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void showError(String message) {
    if (!mounted) return;
    setState(() {
      isLoading = false;
      errorMessage = message;
    });
    developer.log('Error shown to user: $message');
  }

  @override
  void dispose() {
    developer.log('Disposing StoryPage resources');
    flutterTts.stop();
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("${widget.genre} Story (${widget.language})"),
        actions: [
          if (translationFailed)
            IconButton(
              icon: const Icon(Icons.warning, color: Colors.amber),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(errorMessage)),
                );
              },
            ),
          if (!ttsAvailable)
            const Tooltip(
              message: 'Text-to-speech not available for this language',
              child: Icon(Icons.volume_off, color: Colors.grey),
            ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/image/background_image.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(color: Colors.black.withOpacity(0.7)),
          Center(
            child: isLoading
                ? const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Colors.deepPurpleAccent),
                SizedBox(height: 20),
                Text(
                  'Creating your magical story...',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            )
                : errorMessage.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 50,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: fetchStory,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            )
                : storySentences.isEmpty
                ? const Text(
              "Could not load the story",
              style: TextStyle(color: Colors.white, fontSize: 24),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 80),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          storySentences[currentSentenceIndex],
                          key: ValueKey(currentSentenceIndex),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (currentSentenceIndex < storySentences.length - 1)
                    ElevatedButton.icon(
                      onPressed: () async {
                        if (currentSentenceIndex < storySentences.length - 1) {
                          setState(() {
                            currentSentenceIndex++;
                          });
                          if (ttsAvailable) {
                            await flutterTts.speak(storySentences[currentSentenceIndex]);
                          }
                        }
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Next Sentence'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                    ),
                  if (currentSentenceIndex >= storySentences.length - 1)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.home),
                      label: const Text('Back to Home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
}

class StoryTheme {
  final Color primaryColor;
  final Color backgroundColor;
  final String backgroundImage;
  final List<String> soundEffects;

  const StoryTheme({
    required this.primaryColor,
    required this.backgroundColor,
    required this.backgroundImage,
    required this.soundEffects,
  });

  static StoryTheme getThemeForMood(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return StoryTheme(
          primaryColor: Colors.amber,
          backgroundColor: Colors.amber.withOpacity(0.1),
          backgroundImage: 'assets/audio/happy_forest.jpg',
          soundEffects: ['happy_chime.mp3', 'birds_chirping.mp3'],
        );
      case 'mysterious':
        return StoryTheme(
          primaryColor: Colors.purple,
          backgroundColor: Colors.purple.withOpacity(0.1),
          backgroundImage: 'assets/image/mys.jpg',
          soundEffects: ['mystery_sound.mp3', 'wind_howling.mp3'],
        );
      case 'action':
        return StoryTheme(
          primaryColor: Colors.red,
          backgroundColor: Colors.red.withOpacity(0.1),
          backgroundImage: 'assets/audio/battlefield.jpg',
          soundEffects: ['sword_clash.mp3', 'epic_drums.mp3'],
        );
      default:
        return StoryTheme(
          primaryColor: Colors.deepPurple,
          backgroundColor: Colors.deepPurple.withOpacity(0.1),
          backgroundImage: 'assets/image/krishna.jpg',
          soundEffects: ['ambient_magic.mp3'],
        );
    }
  }
}

class InteractiveStoryPage extends StatefulWidget {
  final String genre;
  final String language;

  const InteractiveStoryPage({
    super.key,
    required this.genre,
    required this.language,
  });

  @override
  State<InteractiveStoryPage> createState() => _InteractiveStoryPageState();
}

class _InteractiveStoryPageState extends State<InteractiveStoryPage> with TickerProviderStateMixin {
  final FlutterTts flutterTts = FlutterTts();
  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioPlayer effectsPlayer = AudioPlayer();
  String currentStory = '';
  List<String> choices = [];
  List<Map<String, dynamic>> storyHistory = [];
  bool isLoading = true;
  String errorMessage = '';
  bool ttsAvailable = true;
  late StoryTheme currentTheme;
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;
  final List<Achievement> achievements = [];
  final List<StoryBranch> storyBranches = [];
  bool showParticles = false;
  late AnimationController _particleController;
  late SharedPreferences _prefs;

  String _getTtsLanguageCode(String language) {
    switch (language) {
      case 'Hindi':
        return 'hi-IN';
      case 'Kannada':
        return 'kn-IN';
      case 'Tamil':
        return 'ta-IN';
      case 'Telugu':
        return 'te-IN';
      default:
        return 'en-US';
    }
  }

  @override
  void initState() {
    super.initState();
    developer.log('Initializing InteractiveStoryPage with genre: ${widget.genre}, language: ${widget.language}');
    currentTheme = StoryTheme.getThemeForMood('default');
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _initializePrefs();
    initTts();
    startInteractiveStory();
    playAmbientMusic();
  }

  Future<void> _initializePrefs() async {
    try {
      developer.log('Initializing SharedPreferences');
      _prefs = await SharedPreferences.getInstance();
      await _loadAchievements();
      developer.log('SharedPreferences initialized successfully');
    } catch (e) {
      developer.log('Error initializing SharedPreferences', error: e);
    }
  }

  Future<void> initTts() async {
    try {
      developer.log('Initializing Text-to-Speech');
      final languages = await flutterTts.getLanguages;
      String ttsLanguage = _getTtsLanguageCode(widget.language);
      developer.log('Available TTS languages: $languages');
      developer.log('Selected TTS language: $ttsLanguage');

      if (languages.contains(ttsLanguage)) {
        await flutterTts.setLanguage(ttsLanguage);
        setState(() => ttsAvailable = true);
        developer.log('TTS initialized with selected language');
      } else {
        await flutterTts.setLanguage('en-US');
        setState(() => ttsAvailable = false);
        developer.log('Selected language not available, falling back to en-US');
      }

      await flutterTts.setSpeechRate(0.55);
      await flutterTts.setPitch(1.0);
      await flutterTts.awaitSpeakCompletion(true);
    } catch (e) {
      setState(() => ttsAvailable = false);
      developer.log('Error initializing TTS', error: e);
    }
  }

  Future<void> startInteractiveStory() async {
    developer.log('Starting interactive story');
    const String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyD3IMk7vpWbOQLcjDuKTmNNlbL4VZ6Pxxw';

    final String prompt = '''
Start an interactive ${widget.genre} story. At each step:
1. Describe the scene briefly (2-3 sentences)
2. Present 2-3 clear choices for the user
3. Specify the mood of the scene (happy, mysterious, action, or default)
Format the response as JSON with these exact keys:
{
  "story": "scene description here",
  "choices": ["choice 1", "choice 2", "choice 3"],
  "mood": "mood_type_here"
}
''';

    try {
      developer.log('Sending API request to Gemini');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [{'text': prompt}]
            }
          ]
        }),
      );

      developer.log('API response status code: ${response.statusCode}');
      developer.log('API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          throw Exception('No story content received from API');
        }

        final String responseText = data['candidates'][0]['content']['parts'][0]['text'];
        developer.log('Received story response: $responseText');

        final RegExp jsonRegex = RegExp(r'\{[\s\S]*\}');
        final match = jsonRegex.firstMatch(responseText);

        if (match != null) {
          final storyData = jsonDecode(match.group(0)!);
          developer.log('Parsed story data: $storyData');

          if (!mounted) return;
          setState(() {
            currentStory = storyData['story'];
            choices = List<String>.from(storyData['choices']);
            storyHistory.add({
              'story': currentStory,
              'choices': choices,
              'mood': storyData['mood'] ?? 'default',
            });
            isLoading = false;
          });

          await updateTheme(storyData['mood'] ?? 'default');

          if (ttsAvailable) {
            await flutterTts.speak(currentStory);
          }
        } else {
          throw Exception('Invalid story format received');
        }
      } else {
        throw Exception('Failed to fetch story: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error in startInteractiveStory', error: e, stackTrace: StackTrace.current);
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> makeChoice(String choice) async {
    developer.log('Making choice: $choice');
    setState(() {
      isLoading = true;
    });

    const String apiUrl =
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=AIzaSyD3IMk7vpWbOQLcjDuKTmNNlbL4VZ6Pxxw';

    final String prompt = '''
Continue the interactive ${widget.genre} story. Previous events:
${storyHistory.map((h) => "Scene: ${h['story']}").join('\n')}

The user chose: $choice

Respond with the next scene and new choices in this JSON format:
{
  "story": "scene description here",
  "choices": ["choice 1", "choice 2", "choice 3"],
  "mood": "mood_type_here"
}
''';

    try {
      developer.log('Sending choice to API');
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [{'text': prompt}]
            }
          ]
        }),
      );

      developer.log('Choice API response status: ${response.statusCode}');
      developer.log('Choice API response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['candidates'] == null || data['candidates'].isEmpty) {
          throw Exception('No story content received from API');
        }

        final String responseText = data['candidates'][0]['content']['parts'][0]['text'];
        developer.log('Received choice response: $responseText');

        final RegExp jsonRegex = RegExp(r'\{[\s\S]*\}');
        final match = jsonRegex.firstMatch(responseText);

        if (match != null) {
          final storyData = jsonDecode(match.group(0)!);
          developer.log('Parsed choice data: $storyData');

          if (!mounted) return;
          setState(() {
            currentStory = storyData['story'];
            choices = List<String>.from(storyData['choices']);
            storyHistory.add({
              'story': currentStory,
              'choices': choices,
              'mood': storyData['mood'] ?? 'default',
            });
            isLoading = false;
          });

          await updateTheme(storyData['mood'] ?? 'default');

          if (ttsAvailable) {
            await flutterTts.speak(currentStory);
          }
        } else {
          throw Exception('Invalid story format received');
        }
      } else {
        throw Exception('Failed to fetch story: ${response.statusCode}');
      }
    } catch (e) {
      developer.log('Error in makeChoice', error: e, stackTrace: StackTrace.current);
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> updateTheme(String mood) async {
    try {
      developer.log('Updating theme for mood: $mood');
      final newTheme = StoryTheme.getThemeForMood(mood);
      setState(() {
        currentTheme = newTheme;
      });
      _backgroundController.forward(from: 0.0);

      if (newTheme.soundEffects.isNotEmpty) {
        developer.log('Playing sound effect: ${newTheme.soundEffects[0]}');
        await effectsPlayer.play(AssetSource(newTheme.soundEffects[0]));
      }
    } catch (e) {
      developer.log('Error updating theme', error: e);
    }
  }

  Future<void> playAmbientMusic() async {
    try {
      developer.log('Starting ambient music');
      await audioPlayer.setReleaseMode(ReleaseMode.loop);
      await audioPlayer.play(AssetSource('audio/piano.mp3'));
      developer.log('Ambient music started successfully');
    } catch (e) {
      developer.log('Failed to play ambient music', error: e);
    }
  }

  Future<void> _loadAchievements() async {
    final savedAchievements = _prefs.getStringList('achievements') ?? [];
    setState(() {
      achievements.addAll([
        Achievement(
          title: 'Adventurer',
          description: 'Started your first interactive story',
          icon: '🌟',
          isUnlocked: savedAchievements.contains('adventurer'),
        ),
        Achievement(
          title: 'Decision Maker',
          description: 'Made 5 different choices',
          icon: '🎯',
          isUnlocked: savedAchievements.contains('decision_maker'),
        ),
        Achievement(
          title: 'Plot Twister',
          description: 'Experienced 3 different story endings',
          icon: '🌀',
          isUnlocked: savedAchievements.contains('plot_twister'),
        ),
      ]);
    });
  }

  Future<void> _unlockAchievement(String id) async {
    final savedAchievements = _prefs.getStringList('achievements') ?? [];
    if (!savedAchievements.contains(id)) {
      savedAchievements.add(id);
      await _prefs.setStringList('achievements', savedAchievements);

      setState(() {
        showParticles = true;
      });
      _particleController.forward(from: 0.0);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 10),
              Text('Achievement Unlocked: ${achievements.firstWhere((a) => a.title.toLowerCase().replaceAll(' ', '_') == id).title}'),
            ],
          ),
          backgroundColor: Colors.deepPurple,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _showAchievements() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.black87,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: currentTheme.primaryColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: achievements.length,
                itemBuilder: (context, index) {
                  final achievement = achievements[index];
                  return ListTile(
                    leading: Text(
                      achievement.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      achievement.title,
                      style: TextStyle(
                        color: achievement.isUnlocked ? Colors.white : Colors.grey,
                        fontWeight: achievement.isUnlocked ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      achievement.description,
                      style: TextStyle(
                        color: achievement.isUnlocked ? Colors.white70 : Colors.grey,
                      ),
                    ),
                    trailing: achievement.isUnlocked
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.lock, color: Colors.grey),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStoryMap() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: currentTheme.primaryColor),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Story Map',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: _buildStoryTree(storyHistory),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoryTree(List<Map<String, dynamic>> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: history.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: currentTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: currentTheme.primaryColor.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry['story'] as String,
                    style: const TextStyle(color: Colors.white),
                  ),
                  if (entry['choices'] != null) ...[
                    const SizedBox(height: 10),
                    ...List<String>.from(entry['choices']).map(
                          (choice) => Padding(
                        padding: const EdgeInsets.only(left: 20, top: 5),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 12,
                              color: currentTheme.primaryColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              choice,
                              style: TextStyle(
                                color: currentTheme.primaryColor,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    audioPlayer.dispose();
    effectsPlayer.dispose();
    _backgroundController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Interactive ${widget.genre} Story",
          style: TextStyle(color: currentTheme.primaryColor),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.emoji_events),
            onPressed: _showAchievements,
            color: currentTheme.primaryColor,
          ),
          IconButton(
            icon: const Icon(Icons.account_tree),
            onPressed: _showStoryMap,
            color: currentTheme.primaryColor,
          ),
          if (!ttsAvailable)
            const Tooltip(
              message: 'Text-to-speech not available for this language',
              child: Icon(Icons.volume_off, color: Colors.grey),
            ),
        ],
      ),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      currentTheme.backgroundImage,
                      fit: BoxFit.cover,
                      opacity: AlwaysStoppedAnimation(_backgroundAnimation.value),
                    ),
                  ),
                  Container(
                    color: currentTheme.backgroundColor.withOpacity(0.7),
                  ),
                ],
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: isLoading
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: currentTheme.primaryColor),
                    const SizedBox(height: 20),
                    const Text(
                      'Creating your adventure...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              )
                  : errorMessage.isNotEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: currentTheme.primaryColor, size: 50),
                    const SizedBox(height: 20),
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: startInteractiveStory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentTheme.primaryColor,
                      ),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              )
                  : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: currentTheme.primaryColor.withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: currentTheme.primaryColor.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  currentStory,
                                  speed: const Duration(milliseconds: 50),
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                              isRepeatingAnimation: false,
                              totalRepeatCount: 1,
                            ),
                          ),
                          const SizedBox(height: 30),
                          ...choices.map((choice) => ChoiceButton(
                            choice: choice,
                            onPressed: () => makeChoice(choice),
                            color: currentTheme.primaryColor,
                          )).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showParticles)
            Container(
              width: double.infinity,
              height: double.infinity,
              child: CustomPaint(
                painter: ParticlePainter(
                  controller: _particleController,
                  colors: [
                    currentTheme.primaryColor,
                    Colors.white,
                    Colors.amber,
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final AnimationController controller;
  final List<Color> colors;
  final List<Offset> particles = [];
  final Random random = Random();

  ParticlePainter({
    required this.controller,
    required this.colors,
  }) : super(repaint: controller) {
    for (int i = 0; i < 100; i++) {
      particles.add(Offset.zero);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < particles.length; i++) {
      final progress = controller.value;
      final angle = random.nextDouble() * 2 * pi;
      final velocity = random.nextDouble() * 100;
      final dx = cos(angle) * velocity * progress;
      final dy = sin(angle) * velocity * progress - 50 * progress * progress;

      final position = Offset(
        size.width / 2 + dx,
        size.height / 2 + dy,
      );

      paint.color = colors[i % colors.length].withOpacity(1 - progress);
      canvas.drawCircle(position, 2, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

class Achievement {
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;

  const Achievement({
    required this.title,
    required this.description,
    required this.icon,
    this.isUnlocked = false,
  });
}

class StoryBranch {
  final String choice;
  final String consequence;
  final List<StoryBranch> branches;

  const StoryBranch({
    required this.choice,
    required this.consequence,
    this.branches = const [],
  });
}

class ChoiceButton extends StatefulWidget {
  final String choice;
  final VoidCallback onPressed;
  final Color color;

  const ChoiceButton({
    super.key,
    required this.choice,
    required this.onPressed,
    required this.color,
  });

  @override
  State<ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<ChoiceButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              ),
              child: Text(
                widget.choice,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }
}