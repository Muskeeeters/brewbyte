import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_model.dart';
import '../models/menu_item_model.dart';

class MenuService {
  final _supabase = Supabase.instance.client;

  // --- MENUS (Categories) ---

  Future<List<MenuModel>> getMenus() async {
    final response = await _supabase.from('menus').select();
    final data = response as List<dynamic>;
    return data.map((json) => MenuModel.fromJson(json)).toList();
  }

  Future<void> addMenu(MenuModel menu) async {
    await _supabase.from('menus').insert(menu.toJson());
  }

  Future<void> deleteMenu(String id) async {
    await _supabase.from('menus').delete().eq('id', id);
  }

  // --- MENU ITEMS (Food) ---

  Future<List<MenuItemModel>> getItemsByMenu(String menuId) async {
    final response = await _supabase
        .from('menu_items')
        .select()
        .eq('menu_id', menuId)
        .order('name', ascending: true); // Added sorting

    final data = response as List<dynamic>;
    return data.map((json) => MenuItemModel.fromJson(json)).toList();
  }
  
  Future<void> addMenuItem(MenuItemModel item) async {
    await _supabase.from('menu_items').insert(item.toJson());
  }

  // ⭐ NEW: UPDATE FUNCTION ⭐
  Future<void> updateMenuItem({
    required String id,
    required String name,
    required String description,
    required double price,
    String? imageUrl, // Optional: Only if image is changed
  }) async {
    
    // 1. Data prepare
    final Map<String, dynamic> updates = {
      'name': name,
      'description': description,
      'price': price,
    };

    // 2. If new image, update URL
    if (imageUrl != null) {
      updates['image_url'] = imageUrl;
    }

    // 3. Update query
    await _supabase
        .from('menu_items')
        .update(updates)
        .eq('id', id);
  }

  Future<void> deleteMenuItem(String id) async {
    await _supabase.from('menu_items').delete().eq('id', id);
  }
}