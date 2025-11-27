// lib/features/home/presentation/widgets/navigation_menu.dart
import 'package:flutter/material.dart';

class NavigationMenuItem {
  final String label;
  final IconData icon;
  final String route;

  const NavigationMenuItem({
    required this.label,
    required this.icon,
    required this.route,
  });
}

class NavigationMenu {
  static const items = [
    NavigationMenuItem(
      label: 'Dashboard',
      icon: Icons.dashboard,
      route: '/dashboard',
    ),
    NavigationMenuItem(
      label: 'Reservar',
      icon: Icons.event_seat,
      route: '/booking',
    ),
    NavigationMenuItem(
      label: 'Acceso',
      icon: Icons.lock_open,
      route: '/access',
    ),
    NavigationMenuItem(
      label: 'Servicios',
      icon: Icons.room_service,
      route: '/services',
    ),
    NavigationMenuItem(
      label: 'Miembros',
      icon: Icons.people,
      route: '/members',
    ),
    NavigationMenuItem(
      label: 'Facturación',
      icon: Icons.receipt_long,
      route: '/billing',
    ),
    NavigationMenuItem(
      label: 'Configuración',
      icon: Icons.settings,
      route: '/settings',
    ),
  ];
}
