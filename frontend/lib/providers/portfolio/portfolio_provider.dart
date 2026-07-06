import 'package:artid/domain/models/content_item.dart';
import 'package:artid/domain/models/portfolio_section.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:artid/providers/portfolio/portfolio_sections_provider.dart';
import 'package:artid/providers/portfolio/user_contents_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final portfolioProvider = Provider<List<ContentItem>>((ref) {
  final user = ref.watch(authProvider.select((state) => state.user));
  if (user == null) return const [];

  return ref.watch(userContentsProvider).items;
});

final contentByIdProvider = Provider.family<ContentItem?, String>((ref, id) {
  final items = ref.watch(userContentsProvider).items;
  try {
    return items.firstWhere((item) => item.id == id);
  } catch (_) {
    return null;
  }
});

final canManageContentProvider = Provider.family<bool, String>((ref, contentId) {
  final user = ref.watch(authProvider.select((state) => state.user));
  final item = ref.watch(contentByIdProvider(contentId));
  if (user == null || item == null) return false;
  return item.ownerId == user.id;
});

class PortfolioSectionView {
  const PortfolioSectionView({
    required this.section,
    required this.items,
  });

  final PortfolioSection section;
  final List<ContentItem> items;
}

class GroupedPortfolio {
  const GroupedPortfolio({
    required this.isOrganized,
    required this.sections,
    required this.unassigned,
    required this.allItems,
  });

  final bool isOrganized;
  final List<PortfolioSectionView> sections;
  final List<ContentItem> unassigned;
  final List<ContentItem> allItems;
}

final groupedPortfolioProvider = Provider<GroupedPortfolio>((ref) {
  final items = ref.watch(portfolioProvider);
  final layout = ref.watch(portfolioSectionsProvider);
  final byId = {for (final item in items) item.id: item};

  if (layout.sections.isEmpty) {
    return GroupedPortfolio(
      isOrganized: false,
      sections: const [],
      unassigned: items,
      allItems: items,
    );
  }

  final assigned = <String>{};
  final sections = <PortfolioSectionView>[];

  for (final section in layout.sections) {
    final sectionItems = [
      for (final id in section.contentIds)
        if (byId.containsKey(id)) byId[id]!,
    ];
    assigned.addAll(sectionItems.map((item) => item.id));
    sections.add(PortfolioSectionView(section: section, items: sectionItems));
  }

  final unassigned = items.where((item) => !assigned.contains(item.id)).toList();

  return GroupedPortfolio(
    isOrganized: true,
    sections: sections,
    unassigned: unassigned,
    allItems: items,
  );
});
