import 'package:flutter/material.dart';
import '../screens/products_screen.dart';

class Header extends StatefulWidget {
  final String? userName; // 🔹 optionnel
  final String? location; // 🔹 optionnel
  final bool isHome; // indique si on affiche les infos perso
  final String? initialQuery; // texte pré-rempli dans la barre

  const Header({
    super.key,
    this.userName,
    this.location,
    this.isHome = true,
    this.initialQuery,
  });

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // 🟩 Fond principal
        SizedBox(
          width: double.infinity,
          height: widget.isHome ? 300 + statusBarHeight : 180 + statusBarHeight,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: Color(0xFF00616B),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
          ),
        ),

        // 🟩 Contenu
        Padding(
          padding: EdgeInsets.fromLTRB(24, statusBarHeight + 30, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👋 Bonjour + cloche (affiché seulement si isHome ET userName défini)
              if (widget.isHome && (widget.userName?.isNotEmpty ?? false))
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(
                              text: "Bonjour,\n",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: widget.userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_none,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

              if (widget.isHome &&
                  (widget.userName?.isNotEmpty ?? false) &&
                  (widget.location?.isNotEmpty ?? false))
                const SizedBox(height: 16),

              // 📍 Localisation (affiché seulement si isHome ET location défini)
              if (widget.isHome && (widget.location?.isNotEmpty ?? false))
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      widget.location!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.expand_more,
                        color: Colors.white70, size: 18),
                  ],
                ),

              const SizedBox(height: 24),

              // 🔍 Titre de recherche
              const Text(
                "Que recherchez-vous ?",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 16),

              // 🔎 Barre de recherche
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Objets, mot-clé...',
                    hintStyle:
                        const TextStyle(color: Colors.grey, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.grey),
                      onPressed: _onSearch,
                    ),
                  ),
                  onSubmitted: (_) => _onSearch(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _onSearch() {
  final query = _controller.text.trim();
  if (query.isNotEmpty) {
    Navigator.pushNamed(
      context,
      '/products',
      arguments: query, 
    );
  }
}


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
