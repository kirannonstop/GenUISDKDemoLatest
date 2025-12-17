// ============================================================================
// STEP 1: Create Custom Widget Classes
// ============================================================================

import 'package:flutter/material.dart';

/// Custom Recipe Card Widget
class RecipeCard extends StatelessWidget {
  final String dishName;
  final String description;
  final String mealType;
  final int prepTime;
  final int cookTime;
  final List<String> ingredients;
  final String calories;
  final String protein;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final VoidCallback? onSaveFavorite;
  final VoidCallback? onGetRecipe;
  final VoidCallback? onGetSubstitutions;
  final VoidCallback? onGetQuickVersion;

  const RecipeCard({
    super.key,
    required this.dishName,
    required this.description,
    required this.mealType,
    required this.prepTime,
    required this.cookTime,
    required this.ingredients,
    required this.calories,
    required this.protein,
    this.isVegetarian = false,
    this.isVegan = false,
    this.isGlutenFree = false,
    this.onSaveFavorite,
    this.onGetRecipe,
    this.onGetSubstitutions,
    this.onGetQuickVersion,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with dish name and meal type
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade400, Colors.orange.shade600],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dishName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    _buildMealTypeBadge(mealType),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),

          // Time and nutrition info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildInfoChip(Icons.access_time, '$prepTime min prep'),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.restaurant, '$cookTime min cook'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.local_fire_department,
                      '$calories cal',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(Icons.fitness_center, '$protein protein'),
                  ],
                ),
                const SizedBox(height: 12),

                // Dietary badges
                if (isVegetarian || isVegan || isGlutenFree)
                  Wrap(
                    spacing: 8,
                    children: [
                      if (isVegetarian)
                        _buildDietaryBadge('🥬 Vegetarian', Colors.green),
                      if (isVegan) _buildDietaryBadge('🌱 Vegan', Colors.teal),
                      if (isGlutenFree)
                        _buildDietaryBadge('🌾 Gluten-Free', Colors.amber),
                    ],
                  ),
              ],
            ),
          ),

          // Ingredients section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Key Ingredients:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...ingredients.map(
                  (ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: Colors.orange),
                        const SizedBox(width: 8),
                        Text(ingredient),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onSaveFavorite,
                        icon: const Icon(Icons.favorite, size: 18),
                        label: const Text('Save'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onGetRecipe,
                        icon: const Icon(Icons.description, size: 18),
                        label: const Text('Recipe'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onGetSubstitutions,
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        label: const Text('Substitutions'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onGetQuickVersion,
                        icon: const Icon(Icons.flash_on, size: 18),
                        label: const Text('Quick'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeBadge(String type) {
    final emoji = switch (type.toLowerCase()) {
      'breakfast' => '🌅',
      'lunch' => '☀️',
      'dinner' => '🌙',
      'snack' => '🍪',
      _ => '🍽️',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$emoji $type',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.orange.shade700),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryBadge(String label, Color color) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: color.withOpacity(0.2),
      side: BorderSide(color: color),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

/// Custom Ingredient Checklist Widget
class IngredientChecklist extends StatefulWidget {
  final List<String> ingredients;
  final Function(List<bool>)? onCheckedChanged;

  const IngredientChecklist({
    super.key,
    required this.ingredients,
    this.onCheckedChanged,
  });

  @override
  State<IngredientChecklist> createState() => _IngredientChecklistState();
}

class _IngredientChecklistState extends State<IngredientChecklist> {
  late List<bool> _checkedItems;

  @override
  void initState() {
    super.initState();
    _checkedItems = List.filled(widget.ingredients.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shopping List',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...List.generate(widget.ingredients.length, (index) {
              return CheckboxListTile(
                title: Text(
                  widget.ingredients[index],
                  style: TextStyle(
                    decoration: _checkedItems[index]
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                value: _checkedItems[index],
                onChanged: (value) {
                  setState(() {
                    _checkedItems[index] = value ?? false;
                  });
                  widget.onCheckedChanged?.call(_checkedItems);
                },
                activeColor: Colors.green,
              );
            }),
          ],
        ),
      ),
    );
  }
}

/// Custom Cooking Timer Widget
class CookingTimer extends StatefulWidget {
  final String label;
  final int durationMinutes;
  final VoidCallback? onTimerComplete;

  const CookingTimer({
    super.key,
    required this.label,
    required this.durationMinutes,
    this.onTimerComplete,
  });

  @override
  State<CookingTimer> createState() => _CookingTimerState();
}

class _CookingTimerState extends State<CookingTimer> {
  bool _isRunning = false;
  int _remainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.durationMinutes * 60;
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    Future.delayed(const Duration(seconds: 1), _tick);
  }

  void _tick() {
    if (!_isRunning || _remainingSeconds <= 0) {
      if (_remainingSeconds <= 0) {
        widget.onTimerComplete?.call();
      }
      return;
    }
    setState(() => _remainingSeconds--);
    Future.delayed(const Duration(seconds: 1), _tick);
  }

  void _stopTimer() {
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    setState(() {
      _isRunning = false;
      _remainingSeconds = widget.durationMinutes * 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              widget.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!_isRunning)
                  ElevatedButton.icon(
                    onPressed: _startTimer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _stopTimer,
                    icon: const Icon(Icons.pause),
                    label: const Text('Pause'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
