import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../logic/logic.dart';
import '../widgets/common/tt_app_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: const TtAppBar(showNotification: false, showLogo: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildCategoryChips(),
            const SizedBox(height: 24),
            _buildProductList(),
            const SizedBox(height: 32),
            _buildSustainableShipping(),
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: _buildCartButton(ref),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar en la tienda...',
        prefixIcon: const Icon(Icons.search),
        fillColor: AppColors.colorInputBg,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      'Todos',
      'Semillas',
      'Herramientas',
      'Nutrientes',
      'Sensores',
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.asMap().entries.map((entry) {
          return _buildCategoryChip(entry.value, entry.key == 0);
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.colorPrimary : Colors.white,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: isSelected
              ? AppColors.colorPrimary
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.colorTextPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildProductList() {
    final products = [
      _ProductData(
        imageUrl:
            'https://images.unsplash.com/photo-1592323860081-36362220914d?q=80&w=600',
        name: 'Kit de inicio: Albahaca Hidro',
        price: '45.00',
        badge: 'WORK',
      ),
      _ProductData(
        imageUrl:
            'https://images.unsplash.com/photo-1582234372722-50d7ccc30ebd?q=80&w=600',
        name: 'Solución Nutritiva A+B (1L)',
        price: '28.50',
        badge: 'OFERTA',
      ),
      _ProductData(
        imageUrl:
            'https://images.unsplash.com/photo-1558449028-b53a39d100fc?q=80&w=600',
        name: 'Sensor de Humedad V3',
        price: '115.00',
        badge: null,
      ),
    ];

    return Column(
      children: products.map((product) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildProductCard(
            imageUrl: product.imageUrl,
            name: product.name,
            price: product.price,
            badge: product.badge,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildProductCard({
    required String imageUrl,
    required String name,
    required String price,
    String? badge,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(height: 160, color: Colors.grey[200]),
                  errorWidget: (context, url, error) => Container(
                    height: 160,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image),
                  ),
                ),
              ),
              if (badge != null)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.colorPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            price,
                            style: AppTextStyles.heading.copyWith(
                              fontSize: 24,
                              color: AppColors.colorSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'SOLES',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.colorSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: AppColors.colorPrimary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.add_shopping_cart,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSustainableShipping() {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.colorSecondaryLight,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.eco, color: AppColors.colorPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            'Envío Sostenible',
            style: AppTextStyles.titleMedium.copyWith(
              fontSize: 20,
              color: AppColors.colorSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Utilizamos empaques 100% compostables y logística neutra en emisiones para todas tus compras.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.colorSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartButton(WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () {},
      backgroundColor: AppColors.colorPrimary,
      child: const Icon(Icons.shopping_cart, color: Colors.white),
    );
  }
}

class _ProductData {
  final String imageUrl;
  final String name;
  final String price;
  final String? badge;

  _ProductData({
    required this.imageUrl,
    required this.name,
    required this.price,
    this.badge,
  });
}
