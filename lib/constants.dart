class PromptConstants {
  /// A basic chat prompt fragment.
  static const String interactiveButtonPrompt = '''

INTERACTIVE BUTTONS:
IMPORTANT: Add interactive buttons (should be horizontal aligned) to EVERY dish card UI you create:
- "❤️ Save to Favorites" button - when clicked, acknowledge saving and ask if they want more similar dishes
- "📝 Get Full Recipe" button - when clicked, provide detailed step-by-step cooking instructions
- "🔄 Suggest Substitutions" button - when clicked, suggest ingredient alternatives (e.g., gluten-free, vegan options)
- "⏱️ Quick Version" button - when clicked, provide a faster version of the recipe
- "Add option for Marathi cuisine" - when clicked, suggest a popular Marathi dish

When a user clicks these buttons, you'll receive a message about the interaction. Respond appropriately:
- For "Save to Favorites": Acknowledge and offer similar recommendations
- For "Get Full Recipe": Provide detailed step-by-step instructions with cooking techniques
- For "Suggest Substitutions": Offer 3-4 ingredient alternatives with explanations
- For "Quick Version": Provide time-saving modifications to the recipe 
''';

  ///Add a prompt for taking values from user like what leftover ingredients they have, or what leftover meals they want to cook
  static const String userInputPrompt = '''
USER INPUT HANDLING:
IMPORTANT: Always include a text input field at the start of the UI for user queries. Label it "Left Over Things".
When the user submits a query, respond with relevant dish recommendations or cooking tips based on their input.
If user inputs leftover ingredients, suggest recipes that can be made with those ingredients only.
''';
}
