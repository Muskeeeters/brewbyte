import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_model.dart';
import '../models/menu_item_model.dart';

class MenuService {
  // Supabase Client ka instance
  final _supabase = Supabase.instance.client;

  // --- MENUS (Real DB Calls) ---

  // 1. Get all Menus
  Future<List<MenuModel>> getMenus() async {
    final response = await _supabase.from('menus').select();
    
    // Data ko List<MenuModel> mein convert karna
    final data = response as List<dynamic>;
    return data.map((json) => MenuModel.fromJson(json)).toList();
  }

  // 2. Add New Menu
  Future<void> addMenu(MenuModel menu) async {
    await _supabase.from('menus').insert(menu.toJson());
  }

  // 3. Delete Menu
  Future<void> deleteMenu(String id) async {
    await _supabase.from('menus').delete().eq('id', id);
  }

  // --- MENU ITEMS (Real DB Calls) ---

  // 4. Get Items for a specific Menu
  Future<List<MenuItemModel>> getItemsByMenu(String menuId) async {
    final response = await _supabase
        .from('menu_items')
        .select()
        .eq('menu_id', menuId); // Filter by Menu ID

    final data = response as List<dynamic>;
    return data.map((json) => MenuItemModel.fromJson(json)).toList();
  }
  
  // 5. Add Menu Item
  Future<void> addMenuItem(MenuItemModel item) async {
    await _supabase.from('menu_items').insert(item.toJson());
  }

  // 👇 6. Delete Menu Item (Ye Naya Function Hai)
  Future<void> deleteMenuItem(String id) async {
    await _supabase.from('menu_items').delete().eq('id', id);
  }
}