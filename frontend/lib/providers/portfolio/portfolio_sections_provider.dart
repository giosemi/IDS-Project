import 'package:artid/data/services/portfolio_api_service.dart';
import 'package:artid/domain/models/portfolio_section.dart';
import 'package:artid/providers/auth/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PortfolioLayoutState {
  const PortfolioLayoutState({this.sections = const [], this.isLoading = false});

  final List<PortfolioSection> sections;
  final bool isLoading;

  PortfolioLayoutState copyWith({List<PortfolioSection>? sections, bool? isLoading}) {
    return PortfolioLayoutState(
      sections: sections ?? this.sections,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PortfolioSectionsNotifier extends Notifier<PortfolioLayoutState> {
  @override
  PortfolioLayoutState build() {
    ref.listen(authProvider.select((s) => s.user?.id), (previous, next) {
      if (next == null) {
        state = const PortfolioLayoutState();
      } else if (previous != next) {
        Future.microtask(_load);
      }
    });

    final userId = ref.read(authProvider).user?.id;
    if (userId != null) Future.microtask(_load);

    return const PortfolioLayoutState();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    try {
      final sections = await ref.read(portfolioApiServiceProvider).getSections();
      state = PortfolioLayoutState(sections: sections);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> addSection(String title) async {
    try {
      final section = await ref.read(portfolioApiServiceProvider).addSection(title.trim());
      state = state.copyWith(sections: [...state.sections, section]);
    } catch (_) {}
  }

  Future<void> renameSection(String sectionId, String title) async {
    try {
      final updated =
          await ref.read(portfolioApiServiceProvider).renameSection(sectionId, title.trim());
      state = state.copyWith(
        sections: [
          for (final s in state.sections) if (s.id == sectionId) updated else s,
        ],
      );
    } catch (_) {}
  }

  Future<void> removeSection(String sectionId) async {
    try {
      await ref.read(portfolioApiServiceProvider).deleteSection(sectionId);
      state = state.copyWith(
        sections: state.sections.where((s) => s.id != sectionId).toList(),
      );
    } catch (_) {}
  }

  Future<void> reorderSections(int oldIndex, int newIndex) async {
    final sections = [...state.sections];
    if (newIndex > oldIndex) newIndex -= 1;
    final section = sections.removeAt(oldIndex);
    sections.insert(newIndex, section);
    state = state.copyWith(sections: sections);
    try {
      await ref.read(portfolioApiServiceProvider).reorderSections(sections.map((s) => s.id).toList());
    } catch (_) {}
  }

  void reorderInSection(String sectionId, int oldIndex, int newIndex) {
    state = state.copyWith(
      sections: [
        for (final section in state.sections)
          if (section.id != sectionId)
            section
          else
            () {
              final ids = [...section.contentIds];
              if (newIndex > oldIndex) newIndex -= 1;
              final id = ids.removeAt(oldIndex);
              ids.insert(newIndex, id);
              return section.copyWith(contentIds: ids);
            }(),
      ],
    );
  }

  Future<void> assignToSection(String contentId, String sectionId) async {
    try {
      await ref.read(portfolioApiServiceProvider).assignContent(sectionId, contentId);
      final sections = state.sections.map((section) {
        final ids = section.contentIds.where((id) => id != contentId).toList();
        if (section.id == sectionId) {
          return section.copyWith(contentIds: [...ids, contentId]);
        }
        return section.copyWith(contentIds: ids);
      }).toList();
      state = state.copyWith(sections: sections);
    } catch (_) {}
  }

  void removeFromSections(String contentId) {
    state = state.copyWith(
      sections: [
        for (final section in state.sections)
          section.copyWith(
            contentIds: section.contentIds.where((id) => id != contentId).toList(),
          ),
      ],
    );
  }
}

final portfolioSectionsProvider =
    NotifierProvider<PortfolioSectionsNotifier, PortfolioLayoutState>(
        PortfolioSectionsNotifier.new);
