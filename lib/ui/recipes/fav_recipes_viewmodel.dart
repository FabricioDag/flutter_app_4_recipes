import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app4_receitas/data/models/recipe.dart';
import 'package:app4_receitas/data/repositories/recipe_repository.dart';
import 'package:app4_receitas/di/service_locator.dart';

class FavRecipesViewModel extends GetxController {
  final RecipeRepository _repository = getIt<RecipeRepository>();

  final RxList<Recipe> _favRecipes = <Recipe>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  // Getters
  List<Recipe> get favRecipes => _favRecipes;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  static const _prefsKey = 'favorite_recipe_ids';

  Future<void> loadFavorites() async {
    _isLoading.value = true;
    _errorMessage.value = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final favIds = prefs.getStringList(_prefsKey) ?? [];

      final allRecipes = await _repository.getRecipes();
      _favRecipes.value = allRecipes
          .where((r) => favIds.contains(r.id.toString()))
          .toList();
    } catch (e) {
      _errorMessage.value = 'Falha ao buscar favoritos: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addToFavorites(Recipe recipe) async {
    if (!_favRecipes.any((r) => r.id == recipe.id)) {
      _favRecipes.add(recipe);
      await _saveFavoriteIds();
    }
  }

  Future<void> removeFromFavorites(Recipe recipe) async {
    _favRecipes.removeWhere((r) => r.id == recipe.id);
    await _saveFavoriteIds();
  }

  Future<void> _saveFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = _favRecipes.map((r) => r.id.toString()).toList();
    await prefs.setStringList(_prefsKey, ids);
  }
}
