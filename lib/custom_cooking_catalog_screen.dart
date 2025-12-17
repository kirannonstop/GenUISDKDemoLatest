// // main.dart - Updated to use custom catalog
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:genui/genui.dart';
// import 'package:genui_firebase_ai/genui_firebase_ai.dart';
// import 'package:genui_google_generative_ai/genui_google_generative_ai.dart';
// import 'package:genui_sdk_demo/custom_catalog/cooking_catalog.dart';

// import 'configuration.dart';
// import 'io_get_api_key.dart' if (dart.library.html) 'web_get_api_key.dart';
// import 'message.dart';

// class CustomCookingCatalogScreen extends StatefulWidget {
//   const CustomCookingCatalogScreen({super.key});

//   @override
//   State<CustomCookingCatalogScreen> createState() =>
//       _CustomCookingCatalogScreenState();
// }

// class _CustomCookingCatalogScreenState
//     extends State<CustomCookingCatalogScreen> {
//   final TextEditingController _textController = TextEditingController();
//   final List<MessageController> _messages = [];
//   late final GenUiConversation _genUiConversation;
//   late final GenUiManager _genUiManager;
//   final ScrollController _scrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();

//     // STEP 1: Use the custom catalog instead of CoreCatalogItems
//     final Catalog catalog = CookingCatalog.create();

//     _genUiManager = GenUiManager(catalog: catalog);

//     final systemInstruction =
//         '''You are a friendly and knowledgeable cooking assistant who helps users discover delicious meals based on the time of day and their preferences.

// Your role:
// - Suggest appropriate dishes based on meal times (morning, afternoon, evening, night)
// - Consider nutritional balance and meal heaviness appropriate for each time
// - Generate beautiful, interactive UI using custom RecipeCard widgets
// - Provide cooking timers and ingredient checklists when appropriate
// - Respond to user interactions with recipes

// Meal Time Guidelines:
// - **Morning (Breakfast)**: Healthy, energizing meals. Include protein and whole grains. Examples: oatmeal bowls, egg dishes, smoothie bowls, whole grain toast with toppings.
// - **Afternoon (Lunch)**: Balanced, satisfying meals with good mix of protein, carbs, and vegetables. Examples: salads with protein, grain bowls, sandwiches, pasta dishes.
// - **Evening (Light Dinner/Snack)**: Lighter, easily digestible meals. Examples: soups, salads, grilled fish, vegetable stir-fry.
// - **Night (Dinner)**: Hearty, comforting meals. Examples: curries, roasts, casseroles, rice dishes.

// UI Generation Rules:
// CRITICAL: When you generate UI for a dish, you MUST always create a new surface with a unique surfaceId. 
// - Each dish recommendation should be in its own separate surface
// - DO NOT reuse or update existing surfaceId values
// - Format: Use surfaceId like "dish_breakfast_1", "dish_lunch_2", "dish_dinner_1" etc.

// CUSTOM WIDGETS AVAILABLE:

// 1. **RecipeCard** - THE PRIMARY widget for displaying dishes
//    Use this for EVERY dish recommendation. Parameters:
//    {
//      "dishName": "Avocado Toast with Poached Eggs",
//      "description": "A healthy breakfast with creamy avocado and protein-rich eggs",
//      "mealType": "breakfast",  // breakfast/lunch/dinner/snack
//      "prepTime": 5,
//      "cookTime": 10,
//      "ingredients": ["2 eggs", "1 avocado", "2 slices whole grain bread", "olive oil", "salt", "pepper"],
//      "calories": "350",
//      "protein": "18g",
//      "isVegetarian": true,
//      "isVegan": false,
//      "isGlutenFree": false
//    }
   
   
//    Events you'll receive:
//    - "save_favorite" → Acknowledge and offer similar recipes
//    - "get_recipe" → Provide detailed step-by-step instructions with CookingTimer
//    - "get_substitutions" → Suggest 3-4 ingredient alternatives
//    - "quick_version" → Provide time-saving modifications

// 2. **IngredientChecklist** - For shopping lists
//    Use when user requests a shopping list or wants to track ingredients.
//    Parameters:
//    {
//      "ingredients": ["2 eggs", "1 avocado", "whole grain bread", "olive oil"]
//    }
   
//    Events you'll receive:
//    - "ingredients_checked" → User is tracking what they have

// 3. **CookingTimer** - For time-sensitive cooking steps
//    Use when providing step-by-step instructions with timing.
//    Parameters:
//    {
//      "label": "Boil pasta",
//      "durationMinutes": 8
//    }
   
//    Events you'll receive:
//    - "timer_complete" → Timer finished, acknowledge and provide next step

// WORKFLOW EXAMPLES:

// Example 1: Initial dish suggestion
// User asks: "Suggest a healthy breakfast"
// → Create a RecipeCard with all details filled in

// Example 2: User clicks "Get Full Recipe"
// You receive: Event "get_recipe" from RecipeCard
// → Respond with detailed cooking steps
// → Add CookingTimer widgets for time-sensitive steps (e.g., "Poach eggs" - 3 minutes)

// Example 3: User clicks "Save to Favorites"
// You receive: Event "save_favorite" from RecipeCard
// → "Great choice! I've noted that you like [dish name]. Would you like similar [meal type] recipes?"

// Example 4: User clicks "Get Substitutions"
// You receive: Event "get_substitutions" from RecipeCard
// → Provide alternatives:
//   - Avocado → Hummus or mashed white beans
//   - Eggs → Tofu scramble (vegan option)
//   - Whole grain bread → Gluten-free bread or rice cakes

// Example 5: User requests shopping list
// User asks: "Give me a shopping list for this recipe"
// → Create IngredientChecklist with all ingredients

// ${GenUiPromptFragments.basicChat}''';

//     final ContentGenerator contentGenerator = switch (aiBackend) {
//       AiBackend.googleGenerativeAi => () {
//         return GoogleGenerativeAiContentGenerator(
//           catalog: catalog,
//           systemInstruction: systemInstruction,
//           apiKey: getApiKey(),
//         );
//       }(),
//       AiBackend.firebase => FirebaseAiContentGenerator(
//         catalog: catalog,
//         systemInstruction: systemInstruction,
//       ),
//     };

//     _genUiConversation = GenUiConversation(
//       genUiManager: _genUiManager,
//       contentGenerator: contentGenerator,
//       onSurfaceAdded: _handleSurfaceAdded,
//       onTextResponse: _onTextResponse,
//       onError: (error) {
//         genUiLogger.severe(
//           'Error from content generator',
//           error.error,
//           error.stackTrace,
//         );
//       },
//     );

//     // Send initial greeting
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         _messages.add(
//           MessageController(
//             text:
//                 'AI: Hi! I\'m your cooking assistant with custom recipe cards! 🍳\n\n'
//                 'I can create beautiful recipe cards for any meal.\n\n'
//                 'Try asking:\n'
//                 '• "Suggest a healthy breakfast"\n'
//                 '• "Quick lunch ideas"\n'
//                 '• "Give me a shopping list"\n\n'
//                 'Each recipe card has interactive buttons:\n'
//                 '❤️ Save favorites | 📝 Get full recipe\n'
//                 '🔄 Find substitutions | ⏱️ Get quick version',
//           ),
//         );
//       });
//     });
//   }

//   void _handleSurfaceAdded(SurfaceAdded surface) {
//     if (!mounted) return;
//     setState(() {
//       _messages.add(MessageController(surfaceId: surface.surfaceId));
//     });
//     _scrollToBottom();
//   }

//   void _onTextResponse(String text) {
//     if (!mounted) return;
//     setState(() {
//       _messages.add(MessageController(text: 'AI: $text'));
//     });
//     _scrollToBottom();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final String title = switch (aiBackend) {
//       AiBackend.googleGenerativeAi => 'Cooking Assistant (Custom Widgets)',
//       AiBackend.firebase => 'Cooking Assistant (Custom Widgets)',
//     };

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//         backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//         actions: [
//           // Info button to show available custom widgets
//           IconButton(
//             icon: const Icon(Icons.info_outline),
//             onPressed: () => _showWidgetInfo(context),
//           ),
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Quick action chips
//             Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 8.0,
//                 vertical: 4.0,
//               ),
//               decoration: BoxDecoration(
//                 color: Colors.orange.shade50,
//                 border: Border(
//                   bottom: BorderSide(color: Colors.orange.shade200),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: Row(
//                   children: [
//                     _buildQuickActionChip(
//                       '🌅 Breakfast',
//                       'Suggest a healthy breakfast',
//                     ),
//                     _buildQuickActionChip('☀️ Lunch', 'Quick lunch ideas'),
//                     _buildQuickActionChip(
//                       '🌆 Light Dinner',
//                       'Light dinner ideas',
//                     ),
//                     _buildQuickActionChip(
//                       '🌙 Dinner',
//                       'Hearty dinner suggestions',
//                     ),
//                     _buildQuickActionChip(
//                       '📋 Shopping List',
//                       'Create a shopping list for the last recipe',
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             Expanded(
//               child: ListView.builder(
//                 controller: _scrollController,
//                 itemCount: _messages.length,
//                 itemBuilder: (context, index) {
//                   final MessageController message = _messages[index];
//                   return Padding(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 8.0,
//                       vertical: 4.0,
//                     ),
//                     child: MessageView(message, _genUiConversation.host),
//                   );
//                 },
//               ),
//             ),

//             ValueListenableBuilder(
//               valueListenable: _genUiConversation.isProcessing,
//               builder: (_, isProcessing, _) {
//                 if (!isProcessing) return Container();
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         width: 20,
//                         height: 20,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           color: Colors.orange,
//                         ),
//                       ),
//                       const SizedBox(width: 12),
//                       const Text(
//                         'Cooking up some ideas...',
//                         style: TextStyle(
//                           fontStyle: FontStyle.italic,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             ),

//             Container(
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, -2),
//                   ),
//                 ],
//               ),
//               child: Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: TextField(
//                         controller: _textController,
//                         decoration: InputDecoration(
//                           hintText: 'Ask for meal suggestions...',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(24),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 12,
//                           ),
//                         ),
//                         onSubmitted: (_) => _sendMessage(),
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     IconButton(
//                       icon: const Icon(Icons.send),
//                       color: Colors.orange,
//                       onPressed: _sendMessage,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildQuickActionChip(String label, String message) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 4.0),
//       child: ActionChip(
//         label: Text(label, style: const TextStyle(fontSize: 12)),
//         onPressed: () {
//           _textController.text = message;
//           _sendMessage();
//         },
//         backgroundColor: Colors.white,
//         side: BorderSide(color: Colors.orange.shade300),
//       ),
//     );
//   }

//   void _showWidgetInfo(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Custom Widgets Available'),
//         content: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               _buildWidgetInfoItem(
//                 '🍽️ Recipe Card',
//                 'Beautiful cards with dish info, nutrition, and interactive buttons',
//               ),
//               const SizedBox(height: 12),
//               _buildWidgetInfoItem(
//                 '📋 Ingredient Checklist',
//                 'Interactive shopping list to track ingredients you have',
//               ),
//               const SizedBox(height: 12),
//               _buildWidgetInfoItem(
//                 '⏱️ Cooking Timer',
//                 'Built-in timers for time-sensitive cooking steps',
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Got it!'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildWidgetInfoItem(String title, String description) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         const SizedBox(height: 4),
//         Text(
//           description,
//           style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
//         ),
//       ],
//     );
//   }

//   void _sendMessage() {
//     final String text = _textController.text;
//     if (text.isEmpty) {
//       return;
//     }
//     _textController.clear();

//     setState(() {
//       _messages.add(MessageController(text: 'You: $text'));
//     });

//     _scrollToBottom();

//     unawaited(_genUiConversation.sendRequest(UserMessage([TextPart(text)])));
//   }

//   void _scrollToBottom() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 300),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _genUiConversation.dispose();
//     super.dispose();
//   }
// }
