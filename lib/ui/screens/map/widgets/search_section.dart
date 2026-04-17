import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../model/station.dart';
import '../../../theme/app_colors.dart';
import '../map_view_model.dart';

class SearchSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final void Function(Station) onSuggestionTap;

  const SearchSection({
    required this.controller,
    required this.focusNode,
    required this.onSuggestionTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onChanged: (q) => context.read<MapViewModel>().onSearchChanged(q),
            decoration: InputDecoration(
              hintText: vm.isRiding
                  ? 'Search Return Station'
                  : 'Search Station',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        context.read<MapViewModel>().clearSearch();
                        controller.clear();
                        focusNode.unfocus();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (vm.searchSuggestions.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: vm.searchSuggestions.map((s) {
                  final dockCount = vm.isRiding
                      ? s.availableDocks
                      : s.availableBikes;
                  final label = vm.isRiding ? 'free slots' : 'bikes';
                  final dotColor = dockCount <= 3
                      ? Colors.red
                      : dockCount < 6
                      ? Colors.orange
                      : AppColors.primary;
                  return InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onSuggestionTap(s),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(

                        children: [

                          const Icon(
                            Icons.location_on_outlined,
                            color: Colors.grey,
                            size: 20,
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              s.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),

                          const SizedBox(width: 6),
                          
                          Text(
                            '$dockCount $label',
                            style: TextStyle(
                              fontSize: 13,
                              color: dotColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }
}
