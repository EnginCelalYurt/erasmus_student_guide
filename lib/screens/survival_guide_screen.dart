import 'package:flutter/material.dart';
import '../models/guide_topic.dart';

class SurvivalGuideScreen extends StatefulWidget {
  final List<SurvivalTip> tips;

  const SurvivalGuideScreen({super.key, required this.tips});

  @override
  State<SurvivalGuideScreen> createState() => _SurvivalGuideScreenState();
}

class _SurvivalGuideScreenState extends State<SurvivalGuideScreen> {
  String _selectedCategory = 'All';
  final List<String> _categories = [
    'All',
    'Dormitories',
    'Transport',
    'Emergency',
    'Student Life'
  ];

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Dormitories':
        return Icons.hotel_rounded;
      case 'Transport':
        return Icons.tram_rounded;
      case 'Emergency':
        return Icons.local_hospital_rounded;
      case 'Student Life':
        return Icons.groups_rounded;
      default:
        return Icons.lightbulb_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final filteredTips = widget.tips.where((tip) {
      if (_selectedCategory == 'All') return true;
      return tip.category == _selectedCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lodz Life & Survival',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Practical Tips for Living in Łódź',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Category selector chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    avatar: cat == 'All'
                        ? null
                        : Icon(_getCategoryIcon(cat), size: 16),
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredTips.length,
              itemBuilder: (context, index) {
                final tip = filteredTips[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Theme(
                    data: theme.copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: theme.colorScheme.primaryContainer,
                        child: Icon(
                          _getCategoryIcon(tip.category),
                          color: theme.colorScheme.onPrimaryContainer,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        tip.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          tip.summary,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Divider(),
                              const SizedBox(height: 6),
                              Text(
                                tip.detailedAdvice,
                                style: const TextStyle(
                                  height: 1.45,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: tip.tags.map((tag) {
                                  return Chip(
                                    visualDensity: VisualDensity.compact,
                                    label: Text(
                                      '#$tag',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                    backgroundColor:
                                        theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                                    side: BorderSide.none,
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
