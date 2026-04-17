import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [
              const SizedBox(height: 20),

              // 🔹 TITLE
              const Text(
                "USER PROFILE",
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 AVATAR
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                  'images/user.png',
                ), // change if needed
              ),

              const SizedBox(height: 20),

              // 🔹 CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green, width: 2),
                ),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔸 LEFT CONTENT
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Ronan the best",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 12),

                          Text("Active Plan: Daily Pass"),
                          SizedBox(height: 8),

                          Text("Total Ride: 23 times"),
                          SizedBox(height: 4),

                          Text("Total Duration: 4h 23min 30sec"),
                        ],
                      ),
                    ),

                    const SizedBox(width: 10),

                    // 🔸 RIGHT BADGE
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),

                      child: Column(
                        children: const [
                          Icon(Icons.percent, color: Colors.green, size: 30),
                          SizedBox(height: 6),
                          Text("22h Left", style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
