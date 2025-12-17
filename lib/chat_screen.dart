import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:genui_firebase_ai/genui_firebase_ai.dart';
import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';
import 'package:genui_sdk_demo/configuration.dart';
import 'package:genui_sdk_demo/constants.dart';
import 'package:genui_sdk_demo/io_get_api_key.dart';
import 'package:genui_sdk_demo/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<MessageController> _messages = [];
  late final GenUiConversation _genUiConversation;
  late final GenUiManager _genUiManager;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final Catalog catalog = CoreCatalogItems.asCatalog();
    _genUiManager = GenUiManager(catalog: catalog);

    final systemInstruction =
        '''
${PromptConstants.userInputPrompt}

You are a friendly and knowledgeable cooking assistant who helps users discover delicious meals based on the time of day and their preferences.

Your role:
- If user provides leftover ingredients, suggest recipes that can be made with those ingredients only. If not then 
suggest dishes appropriate for the specified meal time.
- Suggest appropriate dishes based on meal times (morning, afternoon, evening, night)
- Consider nutritional balance and meal heaviness appropriate for each time
- Generate beautiful, interactive UI cards for each dish recommendation
- Provide brief cooking tips and nutritional information
- Respond to user interactions like saving favorites, requesting substitutions, or getting full recipes

Meal Time Guidelines:
- **Morning (Breakfast)**: Healthy, energizing meals. Include protein and whole grains. Examples: oatmeal bowls, egg dishes, smoothie bowls, whole grain toast with toppings.
- **Afternoon (Lunch)**: Balanced, satisfying meals with good mix of protein, carbs, and vegetables. Examples: salads with protein, grain bowls, sandwiches, pasta dishes.
- **Evening (Light Dinner/Snack)**: Lighter, easily digestible meals. Examples: soups, salads, grilled fish, vegetable stir-fry.
- **Night (Dinner)**: Healthy, comforting meals. Examples: curries, roasts, casseroles, rice dishes.

UI Generation Rules:
CRITICAL: When you generate UI for a dish, you MUST always create a new surface with a unique surfaceId. 
- Each dish recommendation should be in its own separate surface
- DO NOT reuse or update existing surfaceId values
- Format: Use surfaceId like "dish_breakfast_1", "dish_lunch_1", "dish_dinner_1" etc.

For each dish, create an attractive UI card that includes:
- Dish name as a prominent title
- Brief description (1-2 sentences)
- Meal time indicator (breakfast/lunch/dinner/snack)
- Prep time and cook time
- Key ingredients list (5-7 main ingredients)
- Nutritional highlights (calories, protein, etc.)
- 1-2 cooking tips
- Visual indicators for dietary preferences (vegetarian, vegan, gluten-free, etc.)
${GenUiPromptFragments.basicChat}
''';
    // ${PromptConstants.interactiveButtonPrompt}
    // ${PromptConstants.userInputPrompt}
    // Create the appropriate content generator based on configuration
    final ContentGenerator contentGenerator = switch (aiBackend) {
      AiBackend.googleGenerativeAi => () {
        return GoogleGenerativeAiContentGenerator(
          catalog: catalog,
          systemInstruction: systemInstruction,
          apiKey: getApiKey(),
        );
      }(),
      AiBackend.firebase => FirebaseAiContentGenerator(
        catalog: catalog,
        systemInstruction: systemInstruction,
      ),
    };

    _genUiConversation = GenUiConversation(
      genUiManager: _genUiManager,
      contentGenerator: contentGenerator,
      onSurfaceAdded: _handleSurfaceAdded,
      onTextResponse: _onTextResponse,
      onError: (error) {
        genUiLogger.severe(
          'Error from content generator',
          error.error,
          error.stackTrace,
        );
      },
    );

    // Send initial greeting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages.add(
          MessageController(
            text:
                'AI: Hi! I\'m your cooking assistant. 🍳\n\n'
                'I can help you discover delicious meals for any time of day!\n\n'
                'Try asking me things like:\n'
                '• "Suggest a healthy breakfast"\n'
                '• "What should I make for lunch?"\n'
                '• "Light dinner ideas"\n'
                '• "Quick evening snack"\n\n'
                'You can interact with each recipe card to:\n'
                '❤️ Save favorites\n'
                '📝 Get full recipes\n'
                '🔄 Find substitutions\n'
                '⏱️ Get quicker versions',
          ),
        );
      });
    });
  }

  void _handleSurfaceAdded(SurfaceAdded surface) {
    if (!mounted) return;
    setState(() {
      _messages.add(MessageController(surfaceId: surface.surfaceId));
    });
    _scrollToBottom();
  }

  void _onTextResponse(String text) {
    if (!mounted) return;
    setState(() {
      _messages.add(MessageController(text: 'AI: $text'));
    });
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final String title = switch (aiBackend) {
      AiBackend.googleGenerativeAi => 'Cooking Assistant (Google AI)',
      AiBackend.firebase => 'Cooking Assistant (Firebase AI)',
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.green,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Quick action chips for common requests
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.green.shade200),
                ),
              ),
              child: Row(
                children: [
                  _buildQuickActionChip(
                    '🌅 Breakfast',
                    'Suggest a healthy breakfast',
                  ),
                  _buildQuickActionChip(
                    '☀️ Lunch',
                    'What should I make for lunch?',
                  ),
                  _buildQuickActionChip(
                    '🌆 Light Dinner',
                    'Light dinner ideas',
                  ),
                  _buildQuickActionChip(
                    '🌙 Dinner',
                    'Healthy dinner suggestions',
                  ),
                  _buildQuickActionChip('🍪 Snack', 'Quick evening snack'),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final MessageController message = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: MessageView(message, _genUiConversation.host),
                  );
                },
              ),
            ),

            ValueListenableBuilder(
              valueListenable: _genUiConversation.isProcessing,
              builder: (_, isProcessing, _) {
                if (!isProcessing) return Container();
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Cooking up some ideas...',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        decoration: InputDecoration(
                          hintText: 'Ask for meal suggestions...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.green,
                      onPressed: _sendMessage,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label, String message) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: ActionChip(
          label: Text(label),
          labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          onPressed: () {
            _textController.text = message;
            _sendMessage();
          },
          backgroundColor: Colors.white,
          side: BorderSide(color: Colors.green.shade300),
        ),
      ),
    );
  }

  void _sendMessage() {
    final String text = _textController.text;
    if (text.isEmpty) {
      return;
    }
    _textController.clear();

    setState(() {
      _messages.add(MessageController(text: 'You: $text'));
    });

    _scrollToBottom();

    unawaited(_genUiConversation.sendRequest(UserMessage([TextPart(text)])));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _genUiConversation.dispose();
    super.dispose();
  }
}
