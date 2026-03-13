import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../colors/colors.dart';
import '../providers/avatar_provider.dart';
import '../providers/user_provider.dart';
import '../services/shop_service.dart';
import '../widget/avatar_widget.dart';
import '../widget/points_header_widget.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});
  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}


class ShopItem {
  final String id;
  final String asset;
  final int price;

  ShopItem({
    required this.id,
    required this.asset,
    required this.price,
  });
}


class _ShopScreenState extends ConsumerState<ShopScreen> {
  ShopItem? currentItem;
  bool _isProcessing = false;
  List<String> ownedItems = [];

  // Local Avatar State
  String selectedHair = 'assets/avatar/Hair1.png';
  String selectedHead = 'assets/avatar/Head1.png';
  String selectedBody = 'assets/avatar/Body1.png';
  String selectedLegs = 'assets/avatar/Pants1.png';
  String selectedHand = 'assets/avatar/Hand.png';

  int selectedCategory = 0;
  int selectedItemIndex = -1;

  final List<IconData> categories = [
    Icons.face,
    Icons.content_cut,
    Icons.checkroom,
    Icons.accessibility_new,
    Icons.front_hand,
  ];

  final List<String> categoryNames = ["Face", "Hair", "Top", "Bottom", "Accessory"];

  @override
  void initState() {
    super.initState();
    _loadUserInventory();
  }

  Future<void> _loadUserInventory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        ownedItems = List<String>.from(data['inventory'] ?? []);
        final eq = data['equipped'] ?? {};
        selectedHead = eq['head'] ?? selectedHead;
        selectedHair = eq['hair'] ?? selectedHair;
        selectedBody = eq['body'] ?? selectedBody;
        selectedLegs = eq['legs'] ?? selectedLegs;
        selectedHand = eq['hand'] ?? selectedHand;
      });
    }
  }

  Future<void> _handlePurchaseAndEquip() async {
    final item = currentItem;
    if (item == null || _isProcessing) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isProcessing = true);
    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      if (!ownedItems.contains(item.id)) {
        await FirebaseFirestore.instance.runTransaction((transaction) async {
          final snapshot = await transaction.get(userRef);
          if (!snapshot.exists) throw Exception("User does not exist!");
          int currentPoints = snapshot.data()?['totalPoints'] ?? 0;
          if (currentPoints < item.price) throw Exception("Not enough points!");

          transaction.update(userRef, {
            'totalPoints': currentPoints - item.price,
            'inventory': FieldValue.arrayUnion([item.id]),
          });
        });

        ref.read(userProvider.notifier).spendPoints(item.price);
        ref.read(userProvider.notifier).addItem(item.id);
        setState(() => ownedItems.add(item.id));
      }

      setState(() {
        switch (selectedCategory) {
          case 0: selectedHead = item.asset; break;
          case 1: selectedHair = item.asset; break;
          case 2: selectedBody = item.asset; break;
          case 3: selectedLegs = item.asset; break;
          case 4: selectedHand = item.asset; break;
        }
      });

      ref.read(avatarProvider.notifier).updateAvatar(
        head: selectedHead, hair: selectedHair, body: selectedBody,
        legs: selectedLegs, hand: selectedHand,
      );

      await userRef.update({
        'equipped': {
          'head': selectedHead, 'hair': selectedHair, 'body': selectedBody,
          'legs': selectedLegs, 'hand': selectedHand,
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Success! Outfit updated."))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userProvider);
    final currentOwnedItems = userState?.inventory ?? ownedItems;

    return Scaffold(
      backgroundColor: const Color(0xfffdf8d6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Shop", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                PointsHeader()
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          /// AVATAR PREVIEW AREA
          Container(
            height: 220,
            margin: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.thirdApp, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ground shadow effect
                Positioned(
                  bottom: 30,
                  child: Container(
                    width: 100,
                    height: 20,
                    decoration: BoxDecoration(
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, spreadRadius: 5)],
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 1.4,
                  child: AvatarWidget(
                    hair: selectedHair,
                    head: selectedHead,
                    body: selectedBody,
                    legs: selectedLegs,
                    hand: selectedHand,
                  ),
                ),
              ],
            ),
          ),

          /// CATEGORY SELECTOR
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedCategory == index;
                  return GestureDetector(
                    onTap: () => setState(() {
                      selectedCategory = index;
                      selectedItemIndex = -1;
                      currentItem = null;
                    }),
                    child: Column(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.PrimApp : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: isSelected
                                ? [BoxShadow(color: AppColors.PrimApp.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                                : [],
                          ),
                          child: Icon(categories[index], color: isSelected ? Colors.white : Colors.blueGrey),
                        ),
                        const SizedBox(height: 4),
                        Text(categoryNames[index], style: TextStyle(fontSize: 10, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          /// GRID ITEMS
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(32), topRight: Radius.circular(32)),
              ),
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: shopItems[selectedCategory]!.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.85,
                ),
                itemBuilder: (context, index) {
                  final item = shopItems[selectedCategory]![index];
                  final isSelected = selectedItemIndex == index;
                  final isOwned = currentOwnedItems.contains(item.id);

                  bool isEquipped = false;
                  switch (selectedCategory) {
                    case 0: isEquipped = selectedHead == item.asset; break;
                    case 1: isEquipped = selectedHair == item.asset; break;
                    case 2: isEquipped = selectedBody == item.asset; break;
                    case 3: isEquipped = selectedLegs == item.asset; break;
                    case 4: isEquipped = selectedHand == item.asset; break;
                  }

                  return GestureDetector(
                    onTap: () => setState(() {
                      selectedItemIndex = index;
                      currentItem = item;
                    }),
                    child: AnimatedScale(
                      scale: isSelected ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isEquipped
                              ? AppColors.PrimApp.withOpacity(0.08) // Light tint if equipped
                              : (isSelected ? AppColors.PrimApp.withOpacity(0.05) : const Color(0xFFF8F9FB)),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                              color: isEquipped
                                  ? AppColors.PrimApp
                                  : (isSelected ? AppColors.PrimApp.withOpacity(0.5) : Colors.transparent),
                              width: 2
                          ),
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Image.asset(item.asset, fit: BoxFit.contain),
                              ),
                            ),
                            //Badge 1 : not owned (show price)
                            if (!isOwned)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.stars, color: Colors.amber, size: 12),
                                      const SizedBox(width: 2),
                                      Text("${item.price}", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),

                            // BADGE CASE 2: EQUIPPED (The "Active" Label)
                            if (isEquipped)
                              Positioned(
                                bottom: 8,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                        color: AppColors.PrimApp,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [BoxShadow(color: AppColors.PrimApp.withOpacity(0.4), blurRadius: 4)]
                                    ),
                                    child: const Text(
                                      "EQUIPPED",
                                      style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                                    ),
                                  ),
                                ),
                              )
                            //BADGE 3: Owned (show check)
                            else if (isOwned)
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: Icon(Icons.check_circle, color: Colors.green, size: 20),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: currentItem == null ? null : _buildBottomAction(currentOwnedItems),
    );
  }

  Widget _buildBottomAction(List<String> currentOwnedItems) {
    bool isOwned = currentOwnedItems.contains(currentItem!.id);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
      ),
      child: SafeArea(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.PrimApp,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          onPressed: _isProcessing ? null : _handlePurchaseAndEquip,
          child: _isProcessing
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
            isOwned ? "EQUIP NOW" : "UNLOCK FOR ${currentItem!.price} POINTS",
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
        ),
      ),
    );
  }
}