import '../models/menu_model.dart';
import '../models/menu_item_model.dart';

class MenuService {
  // --- DUMMY DATA (Pehle se मौजूद data) ---
  static List<MenuModel> menus = [
    MenuModel(id: '1', name: 'Hot Coffees', description: 'Freshly brewed hot coffee'),
    MenuModel(id: '2', name: 'Cold Drinks', description: 'Chilled beverages'),
  ];

  static List<MenuItemModel> menuItems = [
    MenuItemModel(id: '101', menuId: '1', name: 'Espresso', price: 300.0, description: 'Strong shot'),
    MenuItemModel(id: '102', menuId: '1', name: 'Latte', price: 450.0, description: 'Milky coffee'),
    MenuItemModel(id: '201', menuId: '2', name: 'Iced Tea', price: 250.0, description: 'Lemon flavor'),
  ];

  // --- CRUD OPERATIONS ---

  // 1. Get all Menus
  List<MenuModel> getMenus() {
    return menus;
  }

  // 2. Add New Menu
  void addMenu(MenuModel menu) {
    menus.add(menu);
  }

  // 3. Delete Menu
  void deleteMenu(String id) {
    menus.removeWhere((element) => element.id == id);
    // Jab menu delete ho, uske items bhi delete hone chahiye
    menuItems.removeWhere((element) => element.menuId == id);
  }

  // 4. Get Items for a specific Menu
  List<MenuItemModel> getItemsByMenu(String menuId) {
    return menuItems.where((item) => item.menuId == menuId).toList();
  }
}