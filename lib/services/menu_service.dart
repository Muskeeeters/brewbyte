import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/menu_model.dart';
import '../models/menu_item_model.dart';

class MenuService {
  // Supabase Client ka instance
  final _supabase = Supabase.instance.client;

  // --- MENUS (Categories like Hot Coffee, Bakery) ---

  // 1. Get all Menus
  Future<List<MenuModel>> getMenus() async {
    final response = await _supabase.from('menus').select();
    
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

  // --- MENU ITEMS (Food Items) ---

  // 4. Get Items for a specific Menu
  Future<List<MenuItemModel>> getItemsByMenu(String menuId) async {
    final response = await _supabase
        .from('menu_items')
        .select()
        .eq('menu_id', menuId); 

    final data = response as List<dynamic>;
    return data.map((json) => MenuItemModel.fromJson(json)).toList();
  }
  
  // 5. Add Menu Item (Ab ye Image URL bhi save karega via toJson)
  Future<void> addMenuItem(MenuItemModel item) async {
    await _supabase.from('menu_items').insert(item.toJson());
  }

  // 6. Delete Menu Item
  Future<void> deleteMenuItem(String id) async {
    await _supabase.from('menu_items').delete().eq('id', id);
  }
}