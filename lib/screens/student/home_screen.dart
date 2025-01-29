import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/api_response.dart';
import '../../services/stand_service.dart';
import '../../models/stand.dart';
import '../../widgets/common/error_display.dart';
import '../../widgets/home/cart_floating_action_button.dart';
import '../../widgets/home/stand_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            _buildPromoBanner(),
            _buildStandsList(),
          ],
        ),
      ),
      floatingActionButton: const CartFAB(),
    );
  }

  Future<void> _onRefresh() async {
    final standService = Provider.of<StandService>(context, listen: false);
    await standService.getStands(forceRefresh: true);
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 60,
      backgroundColor: Theme.of(context).primaryColor,
      title: const Text(
        'School Canteen',
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildPromoBanner() {
    return SliverToBoxAdapter(
      child: Container(
        height: 180,
        margin: const EdgeInsets.all(16),
        child: PageView.builder(
          itemCount: 2,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final promos = [
              {
                'title': 'Special Discount Day!',
                'description': 'Get up to 50% off on selected items',
                'image':
                    'https://res.cloudinary.com/projectsben/image/upload/v1738128587/canteen_app/kef5mhzq3luag2owrvjg.jpg',
                'discount': '50%'
              },
              {
                'title': 'Happy Hour Sale!',
                'description': 'Get up to 20% off every 2-4 PM',
                'image':
                    'https://res.cloudinary.com/projectsben/image/upload/v1738128586/canteen_app/uepumikj0g1ixisvhiz7.jpg',
                'discount': '20%'
              },
            ];

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: _buildPromoCard(
                promos[index]['title']!,
                promos[index]['description']!,
                promos[index]['image']!,
                promos[index]['discount']!,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPromoCard(
      String title, String description, String imageUrl, String discount) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: DecorationImage(
            image: NetworkImage(imageUrl),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withValues(alpha: 0.3),
              BlendMode.darken,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'DISCOUNT $discount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 2,
                            color: Colors.black45,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                flex: 1,
                child: SizedBox(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStandsList() {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverToBoxAdapter(
        child: FutureBuilder<ApiResponse<List<Stand>>>(
          future: Provider.of<StandService>(context, listen: false).getStands(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const ErrorDisplay();
            }

            final stands = snapshot.data!.data!;
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: stands.length,
              itemBuilder: (context, index) => StandCard(stand: stands[index]),
            );
          },
        ),
      ),
    );
  }
}
