import 'package:flutter/material.dart';
import '../colors/colors.dart';
import '../widget/avatar_widget.dart';

class ShopScree extends StatefulWidget {
  const ShopScree({super.key});

  @override
  State<ShopScree> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScree>
    with TickerProviderStateMixin {

  late TabController tabController;

  int userPoints = 2450;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  /// Fake data (remplacé par Firestore plus tard)
  final Map<String, List<int>> items = {
    "Hair": List.generate(8, (i) => i),
    "Head": List.generate(8, (i) => i),
    "Body": List.generate(8, (i) => i),
    "Legs": List.generate(8, (i) => i),
    "Hand": List.generate(8, (i) => i),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf8d6),

      body: SafeArea(
        child: Column(
          children: [

            /// ===== AVATAR PREVIEW =====
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.thirdApp,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                children: [



                  // AvatarWidget(
                  //   hair: 0,
                  //   head: 0,
                  //   body: 0,
                  //   legs: 0,
                  //   hand: 0,
                  // ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade200,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      "$userPoints pts",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            /// ===== TABS =====
            TabBar(
              controller: tabController,
              indicatorColor: AppColors.PrimApp,
              labelColor: AppColors.PrimApp,
              unselectedLabelColor: Colors.black45,
              tabs: const [
                Tab(text: "Hair"),
                Tab(text: "Head"),
                Tab(text: "Body"),
                Tab(text: "Legs"),
                Tab(text: "Hand"),
              ],
            ),

            /// ===== ITEMS GRID =====
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: items.keys.map((category) {
                  final list = items[category]!;

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1,
                    ),
                    itemCount: list.length,
                    itemBuilder: (_, i) {

                      int price = (i + 1) * 100;

                      return _shopItem(price);
                    },
                  );
                }).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _shopItem(int price) {
    bool affordable = userPoints >= price;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          if (!affordable) return;

          setState(() {
            userPoints -= price;
          });
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            const Icon(Icons.face, size: 36),

            const SizedBox(height: 10),

            Text(
              "$price pts",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: affordable
                    ? AppColors.PrimApp
                    : Colors.grey,
              ),
            )
          ],
        ),
      ),
    );
  }
}
