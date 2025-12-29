import 'package:flutter/material.dart';
import 'package:genui/genui.dart';

import 'package:json_schema_builder/json_schema_builder.dart';

// ============================================================================
// Custom Catalog Items - Must be defined OUTSIDE the class
// ============================================================================

final recipeCard = CatalogItem(
  name: 'RecipeCard',
  dataSchema: S.object(
    properties: {
      'dishName': A2uiSchemas.stringReference(description: 'Name of the dish'),
      'description': A2uiSchemas.stringReference(
        description: 'Brief description of the dish',
      ),
      'prepTime': A2uiSchemas.stringReference(description: 'Preparation time'),
      'cookTime': A2uiSchemas.stringReference(description: 'Cooking time'),
      'mealType': A2uiSchemas.stringReference(
        description: 'Type of meal (breakfast, lunch, dinner, snack)',
      ),
    },
    required: ['dishName', 'description'],
  ),
  widgetBuilder: (context) {
    final data = context.data as Map<String, Object?>?;

    final dishNameNotifier = context.dataContext.subscribeToString(
      data?['dishName'] as Map<String, Object?>?,
    );
    final descriptionNotifier = context.dataContext.subscribeToString(
      data?['description'] as Map<String, Object?>?,
    );
    final prepTimeNotifier = context.dataContext.subscribeToString(
      data?['prepTime'] as Map<String, Object?>?,
    );
    final cookTimeNotifier = context.dataContext.subscribeToString(
      data?['cookTime'] as Map<String, Object?>?,
    );
    final mealTypeNotifier = context.dataContext.subscribeToString(
      data?['mealType'] as Map<String, Object?>?,
    );

    return ValueListenableBuilder<String?>(
      valueListenable: dishNameNotifier,
      builder: (context, dishName, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: descriptionNotifier,
          builder: (context, description, _) {
            return ValueListenableBuilder<String?>(
              valueListenable: prepTimeNotifier,
              builder: (context, prepTime, _) {
                return ValueListenableBuilder<String?>(
                  valueListenable: cookTimeNotifier,
                  builder: (context, cookTime, _) {
                    return ValueListenableBuilder<String?>(
                      valueListenable: mealTypeNotifier,
                      builder: (context, mealType, _) {
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          elevation: 4,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (mealType != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getMealTypeColor(mealType),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      mealType.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                Text(
                                  dishName ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade800,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  description ?? '',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    if (prepTime != null) ...[
                                      const Icon(
                                        Icons.timer_outlined,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Prep: $prepTime',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                    ],
                                    if (cookTime != null) ...[
                                      const Icon(
                                        Icons.local_fire_department,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Cook: $cookTime',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  },
);

Color _getMealTypeColor(String mealType) {
  switch (mealType.toLowerCase()) {
    case 'breakfast':
      return Colors.orange;
    case 'lunch':
      return Colors.blue;
    case 'dinner':
      return Colors.purple;
    case 'snack':
      return Colors.green;
    default:
      return Colors.grey;
  }
}

// Ingredient List Widget
final ingredientList = CatalogItem(
  name: 'IngredientList',
  dataSchema: S.object(
    properties: {
      'title': A2uiSchemas.stringReference(
        description: 'Title for the ingredient list',
      ),
      'ingredients': S.list(
        items: A2uiSchemas.stringReference(
          description: 'Individual ingredient',
        ),
        description: 'List of ingredients',
      ),
    },
    required: ['ingredients'],
  ),
  widgetBuilder: (catalogContext) {
    final data = catalogContext.data as Map<String, Object?>?;

    final titleNotifier = catalogContext.dataContext.subscribeToString(
      data?['title'] as Map<String, Object?>?,
    );

    final ingredientsList = data?['ingredients'] as List?;

    return ValueListenableBuilder<String?>(
      valueListenable: titleNotifier,
      builder: (buildContext, title, _) {
        return Card(
          margin: const EdgeInsets.all(8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title ?? 'Ingredients',
                  style: Theme.of(buildContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                if (ingredientsList != null)
                  ...ingredientsList.map((ingredient) {
                    final ingredientMap = ingredient as Map<String, Object?>?;
                    final ingredientNotifier = catalogContext.dataContext
                        .subscribeToString(ingredientMap);
                    return ValueListenableBuilder<String?>(
                      valueListenable: ingredientNotifier,
                      builder: (buildContext, ingredientText, _) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(child: Text(ingredientText ?? '')),
                            ],
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  },
);

// Nutrition Info Widget
final nutritionInfo = CatalogItem(
  name: 'NutritionInfo',
  dataSchema: S.object(
    properties: {
      'calories': A2uiSchemas.stringReference(description: 'Calories'),
      'protein': A2uiSchemas.stringReference(description: 'Protein content'),
      'carbs': A2uiSchemas.stringReference(description: 'Carbohydrates'),
      'fat': A2uiSchemas.stringReference(description: 'Fat content'),
    },
  ),
  widgetBuilder: (catalogContext) {
    final data = catalogContext.data as Map<String, Object?>?;

    final caloriesNotifier = catalogContext.dataContext.subscribeToString(
      data?['calories'] as Map<String, Object?>?,
    );
    final proteinNotifier = catalogContext.dataContext.subscribeToString(
      data?['protein'] as Map<String, Object?>?,
    );
    final carbsNotifier = catalogContext.dataContext.subscribeToString(
      data?['carbs'] as Map<String, Object?>?,
    );
    final fatNotifier = catalogContext.dataContext.subscribeToString(
      data?['fat'] as Map<String, Object?>?,
    );

    return Card(
      margin: const EdgeInsets.all(8.0),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (buildContext) {
                return Text(
                  'Nutrition Facts',
                  style: Theme.of(buildContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const Divider(),
            ValueListenableBuilder<String?>(
              valueListenable: caloriesNotifier,
              builder: (buildContext, calories, _) {
                return _buildNutritionRow('Calories', calories);
              },
            ),
            ValueListenableBuilder<String?>(
              valueListenable: proteinNotifier,
              builder: (buildContext, protein, _) {
                return _buildNutritionRow('Protein', protein);
              },
            ),
            ValueListenableBuilder<String?>(
              valueListenable: carbsNotifier,
              builder: (buildContext, carbs, _) {
                return _buildNutritionRow('Carbs', carbs);
              },
            ),
            ValueListenableBuilder<String?>(
              valueListenable: fatNotifier,
              builder: (buildContext, fat, _) {
                return _buildNutritionRow('Fat', fat);
              },
            ),
          ],
        ),
      ),
    );
  },
);

// Helper function for nutrition rows (must be top-level)
Widget _buildNutritionRow(String label, String? value) {
  if (value == null) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

// Riddle Card (from readme example)
final riddleCard = CatalogItem(
  name: 'RiddleCard',
  dataSchema: S.object(
    properties: {
      'question': A2uiSchemas.stringReference(
        description: 'The question part of a riddle.',
      ),
      'answer': A2uiSchemas.stringReference(
        description: 'The answer part of a riddle.',
      ),
    },
    required: ['question', 'answer'],
  ),
  widgetBuilder: (catalogContext) {
    final data = catalogContext.data as Map<String, Object?>?;

    final questionNotifier = catalogContext.dataContext.subscribeToString(
      data?['question'] as Map<String, Object?>?,
    );
    final answerNotifier = catalogContext.dataContext.subscribeToString(
      data?['answer'] as Map<String, Object?>?,
    );

    return ValueListenableBuilder<String?>(
      valueListenable: questionNotifier,
      builder: (buildContext, question, _) {
        return ValueListenableBuilder<String?>(
          valueListenable: answerNotifier,
          builder: (buildContext, answer, _) {
            return Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(border: Border.all()),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question ?? '',
                    style: Theme.of(buildContext).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    answer ?? '',
                    style: Theme.of(buildContext).textTheme.headlineSmall,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  },
);
