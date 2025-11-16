import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    // Liste des routes principales
    final List<String> routes = [
      '/',            // Accueil
      '/calendar',    // Calendrier
      '/create',      // Créer
      '/messages',    // Messages
      '/profile',     // Profil
    ];

    // Empêche de recharger la page actuelle
    if (index == currentIndex) return;

    // Navigation propre : remplace la route actuelle
    Navigator.pushReplacementNamed(context, routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          // Les 4 icônes avec espace pour le bouton central
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildItem(context, Icons.home, "Accueil", 0),
              _buildItem(context, Icons.calendar_today, "Calendrier", 1),
              const SizedBox(width: 60), // espace pour le bouton "+"
              _buildItem(context, Icons.message_outlined, "Messages", 3),
              _buildItem(context, Icons.person, "Profil", 4),
            ],
          ),

          // Bouton central "+"
          Positioned(
            top: -30,
            child: GestureDetector(
              onTap: () => _onItemTapped(context, 2),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xFF00616B),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String label, int index) {
    final isActive = index == currentIndex;

    return GestureDetector(
      onTap: () => _onItemTapped(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF00616B) : Colors.black54,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? const Color(0xFF00616B) : Colors.black87,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
