import '../models/tip.dart';

enum TipSort { mostHelpful, newest }

abstract class TipRepository {
  Future<List<Tip>> getTips({String? category});
  Future<Tip?> getTipById(String id);
  List<Tip> rankTips(List<Tip> tips, TipSort sort);
  List<Tip> searchTips(List<Tip> tips, String query);
  Future<void> markHelpful(String tipId);
  Future<Tip> addTip(NewTip newTip, {required String author});
}

class InMemoryTipRepository implements TipRepository {
  final List<Tip> _tips = [
    Tip(
      id: 't_dorms',
      title: 'Dormitories & Campus Move-in (Osiedle Akademickie)',
      category: 'Housing',
      summary: 'Dorms I–IX are right next to faculty buildings. 500–750 PLN/month.',
      body:
          'Apply the same week you receive your acceptance letter. Rent is in the 500–750 PLN range including internet and utilities. Dorms VII and II host many international students, while Dorm IX is known to be livelier. Bring an Ethernet cable because campus Wi-Fi can get congested in the evenings. For bed sheets, pillow cases, and kitchenware, visit Sukcesja or Pepco nearby rather than waiting for an IKEA trip.',
      iconName: 'apartment',
      tags: ['dorms', 'housing', 'campus', 'rent'],
      author: 'Marco (Italy)',
      helpfulCount: 42,
      createdAt: DateTime.now().subtract(const Duration(days: 28)),
      actionLabel: 'PŁ Accommodation Portal',
      actionUrl: 'https://p.lodz.pl/en/students/accommodation',
    ),
    Tip(
      id: 't_transport',
      title: 'Trams, Jakdojade & Student Migawka Card',
      category: 'Transport',
      summary: 'Student ID card gives 50% discount on trams and buses.',
      body:
          'Install the Jakdojade mobile app for real-time tram and bus navigation in Łódź. Trams 11, 12, 15, and 18 directly connect the campus with Piotrkowska street and train stations. Once you pick up your student ID (legitymacja), buy a monthly or semester "Migawka" pass at MPK points. Without a validated student ID, controllers will issue a fine even if you show a student certificate.',
      iconName: 'tram',
      tags: ['transport', 'trams', 'jakdojade', 'migawka'],
      author: 'Elena (Spain)',
      helpfulCount: 56,
      createdAt: DateTime.now().subtract(const Duration(days: 14)),
      actionLabel: 'Jakdojade Live Schedules',
      actionUrl: 'https://jakdojade.pl/lodz',
    ),
    Tip(
      id: 't_emergency',
      title: '112 Emergency Help & EHIC Clinic Visits',
      category: 'Health',
      summary: 'Dial 112 for any emergency. Keep photos of your passport and EHIC.',
      body:
          'Dialing 112 is free and connects to English-speaking operators who dispatch police, ambulance, or fire services. For non-emergency medical care, visit the student clinic (NZOZ Przychodnia Akademicka) on al. Politechniki 11 with your European Health Insurance Card (EHIC/EKUZ) or private health insurance policy. For late night pharmacy needs, search for "apteka dyżurna całodobowa".',
      iconName: 'local_hospital',
      tags: ['112', 'emergency', 'health', 'clinic', 'ehic'],
      author: 'Yusuf (Turkey)',
      helpfulCount: 68,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      actionLabel: 'Call 112',
      actionUrl: 'tel:112',
    ),
    Tip(
      id: 't_buddy',
      title: 'ESN Buddy Program & Welcome Week',
      category: 'Social',
      summary: 'Get matched with a local student mentor before arrival.',
      body:
          'Sign up for the ESN Buddy Program via Instagram (@esneye_lodz) before you land. Having a buddy pick you up at Łódź Fabryczna or Kaliska train station late at night with luggage makes arrival effortless. Welcome Week includes icebreaker parties, pub crawls on Piotrkowska, and weekend trips across Poland.',
      iconName: 'groups',
      tags: ['esn', 'buddy', 'social', 'welcome week'],
      author: 'Maja (Slovenia)',
      helpfulCount: 34,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      actionLabel: 'ESN Lodz Instagram',
      actionUrl: 'https://instagram.com/esneye_lodz',
    ),
    Tip(
      id: 't_money',
      title: 'Money, BLIK Mobile Payments & Groceries',
      category: 'Daily',
      summary: 'Poland is nearly cashless. Biedronka & Lidl are the best budget grocers.',
      body:
          'Poland widely uses BLIK, a 6-digit one-time code generated in mobile banking apps that works at every POS terminal and ATM. For budget grocery shopping, Biedronka, Lidl, and Dino offer the best prices. Żabka is on every street corner and open late. When converting money, avoid airport kiosks; exchange shops (kantor) on Piotrkowska offer much better rates.',
      iconName: 'payments',
      tags: ['money', 'blik', 'groceries', 'biedronka', 'banking'],
      author: 'Tim (Netherlands)',
      helpfulCount: 49,
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
    Tip(
      id: 't_legitymacja',
      title: 'Electronic Student ID (Legitymacja ELS)',
      category: 'Admin',
      summary: 'Your essential pass for 50% transit discounts, library, and labs.',
      body:
          'Pick up your electronic student ID (ELS) at your faculty dean office (Dziekanat) or the International Office during your first week. It grants a 50% discount on national trains (PKP Intercity) and city transit, access to the Main Library (Biblioteka Główna), and printing credit.',
      iconName: 'badge',
      tags: ['legitymacja', 'els', 'admin', 'discounts', 'library'],
      author: 'Ines (Portugal)',
      helpfulCount: 39,
      createdAt: DateTime.now().subtract(const Duration(days: 35)),
    ),
    Tip(
      id: 't_eduroam',
      title: 'Campus Wi-Fi (Eduroam) Setup',
      category: 'Admin',
      summary: 'High-speed internet across all campus buildings and worldwide universities.',
      body:
          'Configure Eduroam using your official university email credentials (@edu.p.lodz.pl). Download the Eduroam CAT profile from cat.eduroam.org to properly install root certificates on Android, iOS, or Windows. Once configured, you will connect automatically across campus and in public libraries.',
      iconName: 'wifi',
      tags: ['wifi', 'eduroam', 'internet', 'admin'],
      author: 'Aldiyar (Kazakhstan)',
      helpfulCount: 29,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      actionLabel: 'Eduroam CAT Installer',
      actionUrl: 'https://cat.eduroam.org',
    ),
    Tip(
      id: 't_winter',
      title: 'Winter Survival & Cold Weather Gear',
      category: 'Daily',
      summary: 'Temperatures drop below zero from November through March.',
      body:
          'Winter in Łódź brings sub-zero temperatures, snow, and short daylight hours (sunset around 15:45 in December). Invest in a windproof coat, thermal socks, and water-resistant boots with rubber grip for icy sidewalks. University buildings and dorms are very well heated.',
      iconName: 'ac_unit',
      tags: ['weather', 'winter', 'clothing', 'packing'],
      author: 'Marco (Italy)',
      helpfulCount: 22,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ];

  @override
  Future<List<Tip>> getTips({String? category}) async {
    if (category == null || category.toLowerCase() == 'all') {
      return List.unmodifiable(_tips);
    }
    return _tips
        .where((tip) => tip.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  @override
  Future<Tip?> getTipById(String id) async {
    try {
      return _tips.firstWhere((tip) => tip.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Sorts tips by either "Most helpful" (helpfulCount descending) or "Newest" (createdAt descending).
  @override
  List<Tip> rankTips(List<Tip> tips, TipSort sort) {
    final copy = List<Tip>.from(tips);
    switch (sort) {
      case TipSort.mostHelpful:
        copy.sort((a, b) => b.helpfulCount.compareTo(a.helpfulCount));
        break;
      case TipSort.newest:
        copy.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return copy;
  }

  /// Searches tips across title, body, summary, tags, and category (case-insensitive).
  @override
  List<Tip> searchTips(List<Tip> tips, String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return tips;

    return tips.where((tip) {
      final inTitle = tip.title.toLowerCase().contains(q);
      final inBody = tip.body.toLowerCase().contains(q);
      final inSummary = tip.summary.toLowerCase().contains(q);
      final inCategory = tip.category.toLowerCase().contains(q);
      final inTags = tip.tags.any((tag) => tag.toLowerCase().contains(q));
      final inAuthor = tip.author.toLowerCase().contains(q);
      return inTitle || inBody || inSummary || inCategory || inTags || inAuthor;
    }).toList();
  }

  @override
  Future<void> markHelpful(String tipId) async {
    final index = _tips.indexWhere((t) => t.id == tipId);
    if (index >= 0) {
      final current = _tips[index];
      if (!current.isMarkedHelpful) {
        _tips[index] = current.copyWith(
          helpfulCount: current.helpfulCount + 1,
          isMarkedHelpful: true,
        );
      }
    }
  }

  @override
  Future<Tip> addTip(NewTip newTip, {required String author}) async {
    final tip = Tip(
      id: 't_${DateTime.now().millisecondsSinceEpoch}',
      title: newTip.title,
      category: newTip.category,
      summary: newTip.summary,
      body: newTip.body,
      iconName: 'lightbulb',
      tags: newTip.tags,
      author: author,
      helpfulCount: 1,
      createdAt: DateTime.now(),
      actionLabel: newTip.actionLabel,
      actionUrl: newTip.actionUrl,
    );
    _tips.insert(0, tip);
    return tip;
  }
}
