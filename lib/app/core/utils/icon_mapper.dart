import 'package:flutter/material.dart';

class IconMapper {
  IconMapper._();

  static const _map = <String, IconData>{
    'wallet': Icons.account_balance_wallet_outlined,
    'account_balance': Icons.account_balance,
    'phone_android': Icons.phone_android,
    'credit_card': Icons.credit_card,
    'trending_up': Icons.trending_up,
    'savings': Icons.savings,
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'shopping_bag': Icons.shopping_bag,
    'home': Icons.home,
    'favorite': Icons.favorite,
    'movie': Icons.movie,
    'school': Icons.school,
    'spa': Icons.spa,
    'flight': Icons.flight,
    'receipt_long': Icons.receipt_long,
    'repeat': Icons.repeat,
    'more_horiz': Icons.more_horiz,
    'work': Icons.work,
    'laptop': Icons.laptop,
    'card_giftcard': Icons.card_giftcard,
    'star': Icons.star,
    'swap_horiz': Icons.swap_horiz,
    'attach_money': Icons.attach_money,
    'bar_chart': Icons.bar_chart,
    'category': Icons.category,
    'flag': Icons.flag,
    'local_hospital': Icons.local_hospital,
    'sports': Icons.sports,
    'pets': Icons.pets,
    'child_care': Icons.child_care,
    'fitness_center': Icons.fitness_center,
    'local_grocery_store': Icons.local_grocery_store,
    'local_gas_station': Icons.local_gas_station,
    'phone': Icons.phone,
    'tv': Icons.tv,
    'wifi': Icons.wifi,
    'electric_bolt': Icons.electric_bolt,
    'water_drop': Icons.water_drop,
    'coffee': Icons.coffee,
    'directions_bus': Icons.directions_bus,
    'local_taxi': Icons.local_taxi,
    'fastfood': Icons.fastfood,
    'content_cut': Icons.content_cut,
    'menu_book': Icons.menu_book,
    'music_note': Icons.music_note,
    'hotel': Icons.hotel,
    'local_pharmacy': Icons.local_pharmacy,
    'car_repair': Icons.car_repair,
    'cleaning_services': Icons.cleaning_services,
    'hotel_class': Icons.hotel_class,
  };

  static IconData get(String name) =>
      _map[name] ?? Icons.help_outline;

  static String nameOf(IconData icon) =>
      _map.entries.firstWhere(
        (e) => e.value == icon,
        orElse: () => const MapEntry('help_outline', Icons.help_outline),
      ).key;

  static List<String> get allIconNames => _map.keys.toList();
}
