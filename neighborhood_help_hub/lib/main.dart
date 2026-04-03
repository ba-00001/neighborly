import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(NeighborlyApp(previewConfig: PreviewConfig.fromUri(Uri.base)));
}

enum DemoMode {
  none,
  overview,
  createRequest,
}

class PreviewConfig {
  const PreviewConfig({
    this.autoSignIn = false,
    this.initialTab = 0,
    this.demoMode = DemoMode.none,
  });

  final bool autoSignIn;
  final int initialTab;
  final DemoMode demoMode;

  factory PreviewConfig.fromUri(Uri uri) {
    final demoMode = switch (uri.queryParameters['demo']?.toLowerCase()) {
      'overview' => DemoMode.overview,
      'create' || 'create-request' => DemoMode.createRequest,
      _ => DemoMode.none,
    };

    final autologin = switch (uri.queryParameters['autologin']?.toLowerCase()) {
      '1' || 'true' || 'yes' => true,
      _ => false,
    };

    final initialTab = switch (uri.queryParameters['tab']?.toLowerCase()) {
      'discover' => 1,
      'need' || 'need-help' || 'requests' => 2,
      'offer' || 'can-help' || 'offers' => 3,
      'inbox' => 4,
      'profile' => 5,
      _ => 0,
    };

    return PreviewConfig(
      autoSignIn: autologin || demoMode == DemoMode.createRequest,
      initialTab: demoMode == DemoMode.createRequest ? 2 : initialTab,
      demoMode: demoMode,
    );
  }
}

class NeighborlyApp extends StatelessWidget {
  const NeighborlyApp({
    super.key,
    this.previewConfig = const PreviewConfig(),
  });

  final PreviewConfig previewConfig;

  @override
  Widget build(BuildContext context) {
    final baseScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF0E6B56),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Neighborly',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: baseScheme,
        scaffoldBackgroundColor: const Color(0xFFF6F1E8),
      ),
      home: WelcomeGate(previewConfig: previewConfig),
    );
  }
}

class WelcomeGate extends StatefulWidget {
  const WelcomeGate({
    super.key,
    this.previewConfig = const PreviewConfig(),
  });

  final PreviewConfig previewConfig;

  @override
  State<WelcomeGate> createState() => _WelcomeGateState();
}

class _WelcomeGateState extends State<WelcomeGate> {
  late bool _signedIn;
  Timer? _demoSignInTimer;
  UserProfile _profile = const UserProfile(
    fullName: 'Brian Bazurto',
    email: 'brian@example.com',
    neighborhood: 'Westchester',
    bio: 'Student building a safer, faster way for neighbors to help each other.',
    memberSince: '2026',
  );

  @override
  void initState() {
    super.initState();
    _signedIn = widget.previewConfig.autoSignIn;
    if (!_signedIn && widget.previewConfig.demoMode == DemoMode.overview) {
      _demoSignInTimer = Timer(const Duration(milliseconds: 1800), () {
        if (!mounted) {
          return;
        }
        setState(() => _signedIn = true);
      });
    }
  }

  @override
  void dispose() {
    _demoSignInTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_signedIn) {
      return NeighborlyShell(
        initialIndex: widget.previewConfig.initialTab,
        previewConfig: widget.previewConfig,
        profile: _profile,
        onProfileUpdated: (profile) => setState(() => _profile = profile),
        onLogout: () => setState(() => _signedIn = false),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              height: 92,
              width: 92,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  colors: [Color(0xFF0E6B56), Color(0xFFF48B3C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(
                Icons.volunteer_activism_rounded,
                size: 42,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Neighborly',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'A community app where neighbors can offer help or ask for it with trust, clarity, and quick responses.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF4D5A57),
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                FeatureChip(label: 'Tutoring'),
                FeatureChip(label: 'Errands'),
                FeatureChip(label: 'Pet Sitting'),
                FeatureChip(label: 'Rides'),
                FeatureChip(label: 'Community Safety'),
              ],
            ),
            const SizedBox(height: 32),
            const _AuthCard(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => setState(() => _signedIn = true),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: const Color(0xFF0E6B56),
                ),
                child: const Text('Enter Prototype'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NeighborlyShell extends StatefulWidget {
  const NeighborlyShell({
    super.key,
    this.initialIndex = 0,
    this.previewConfig = const PreviewConfig(),
    required this.profile,
    required this.onProfileUpdated,
    required this.onLogout,
  });

  final int initialIndex;
  final PreviewConfig previewConfig;
  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileUpdated;
  final VoidCallback onLogout;

  @override
  State<NeighborlyShell> createState() => _NeighborlyShellState();
}

class _NeighborlyShellState extends State<NeighborlyShell> {
  late int _currentIndex;
  final List<Timer> _demoTimers = [];
  bool _demoStarted = false;

  final List<Listing> _listings = [
    Listing(
      id: 'REQ-101',
      title: 'After-school algebra tutoring',
      description:
          'Looking for a neighbor who can help my 9th grader prepare for Friday quizzes.',
      neighborhood: 'Westchester',
      category: 'Tutoring',
      timeText: 'Today, 5:30 PM',
      reward: 'Exchange: \$20/hour',
      urgency: 'High',
      owner: 'Ana M.',
      kind: ListingKind.request,
      tags: ['Math', 'Teens', 'In person'],
    ),
    Listing(
      id: 'OFF-210',
      title: 'Pet sitting for small dogs',
      description:
          'Available evenings and weekends. Can do walks, feeding, and overnight check-ins.',
      neighborhood: 'Sweetwater',
      category: 'Pet Care',
      timeText: 'Available this week',
      reward: 'From \$18/visit',
      urgency: 'Open',
      owner: 'Jordan R.',
      kind: ListingKind.offer,
      tags: ['Dogs', 'Evenings', 'Trusted'],
    ),
    Listing(
      id: 'REQ-145',
        title: 'Airport ride on Saturday morning',
        description:
          'Need a reliable ride to MIA with one suitcase. Leaving around 6:15 AM.',
        neighborhood: 'Kendall',
        category: 'Rides',
        timeText: 'Saturday, 6:15 AM',
        reward: '\$30 + gas',
        urgency: 'Medium',
        owner: 'Brian Bazurto',
        kind: ListingKind.request,
        tags: ['Airport', 'Early Morning'],
      ),
    Listing(
      id: 'OFF-233',
      title: 'Weekend grocery errand helper',
      description:
          'I can pick up groceries or pharmacy items within 5 miles for seniors or busy families.',
      neighborhood: 'Doral',
      category: 'Errands',
      timeText: 'Sat-Sun',
      reward: '\$12/task',
      urgency: 'Open',
      owner: 'Priya K.',
      kind: ListingKind.offer,
      tags: ['Groceries', 'Seniors', 'Flexible'],
    ),
  ];

  final List<Conversation> _conversations = const [
    Conversation(
      name: 'Jordan R.',
      category: 'Pet Care',
      message: 'I can stop by at 7 PM and send photo updates.',
      time: '4m',
      unreadCount: 2,
    ),
    Conversation(
      name: 'Ana M.',
      category: 'Tutoring',
      message: 'Can we focus on solving linear equations first?',
      time: '18m',
      unreadCount: 0,
    ),
    Conversation(
      name: 'Community Board',
      category: 'Announcements',
      message: 'New safety tips for ride coordination were posted.',
      time: '1h',
      unreadCount: 1,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) => _startDemoIfNeeded());
  }

  @override
  void dispose() {
    for (final timer in _demoTimers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final requests =
        _listings.where((listing) => listing.kind == ListingKind.request).toList();
    final offers =
        _listings.where((listing) => listing.kind == ListingKind.offer).toList();

    final pages = [
      HomePage(
        listings: _listings,
        profile: widget.profile,
        onToggleFavorite: _toggleFavorite,
        onOpenListing: _openListing,
      ),
      DiscoverPage(
        listings: _listings,
        onToggleFavorite: _toggleFavorite,
        onOpenListing: _openListing,
      ),
      ListingBoardPage(
        title: 'Need Help',
        subtitle: 'Requests from neighbors who need support soon.',
        emptyMessage: 'No help requests yet. Create one from the add button.',
        listings: requests,
        accent: const Color(0xFFF48B3C),
        onToggleFavorite: _toggleFavorite,
        onOpenListing: _openListing,
      ),
      ListingBoardPage(
        title: 'Can Help',
        subtitle: 'Offers from neighbors ready to pitch in.',
        emptyMessage: 'No offers yet. Create one from the add button.',
        listings: offers,
        accent: const Color(0xFF0E6B56),
        onToggleFavorite: _toggleFavorite,
        onOpenListing: _openListing,
      ),
      InboxPage(conversations: _conversations),
      ProfilePage(
        profile: widget.profile,
        onProfileUpdated: widget.onProfileUpdated,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_currentIndex]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createListing,
        backgroundColor: const Color(0xFF1D3557),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: const Text('Post'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.help_outline_rounded),
            selectedIcon: Icon(Icons.help_rounded),
            label: 'Need',
          ),
          NavigationDestination(
            icon: Icon(Icons.handshake_outlined),
            selectedIcon: Icon(Icons.handshake_rounded),
            label: 'Offer',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline_rounded),
            selectedIcon: Icon(Icons.chat_bubble_rounded),
            label: 'Inbox',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(String id) {
    setState(() {
      final index = _listings.indexWhere((listing) => listing.id == id);
      if (index == -1) {
        return;
      }
      _listings[index] = _listings[index].copyWith(
        isFavorite: !_listings[index].isFavorite,
      );
    });
  }

  Future<void> _openListing(Listing listing) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ListingDetailPage(listing: listing),
      ),
    );
  }

  Future<void> _createListing({
    DemoListingDraft? initialDraft,
    Duration? autoSubmitDelay,
  }) async {
    final created = await Navigator.of(context).push<Listing>(
      MaterialPageRoute<Listing>(
        builder: (_) => CreateListingPage(
          profile: widget.profile,
          initialDraft: initialDraft,
          autoSubmitDelay: autoSubmitDelay,
        ),
      ),
    );

    if (created == null) {
      return;
    }

    setState(() {
      _listings.insert(0, created);
      _currentIndex = created.kind == ListingKind.request ? 2 : 3;
    });
  }

  void _startDemoIfNeeded() {
    if (_demoStarted) {
      return;
    }
    _demoStarted = true;

    switch (widget.previewConfig.demoMode) {
      case DemoMode.overview:
        _scheduleOverviewDemo();
        break;
      case DemoMode.createRequest:
        _scheduleDemoStep(
          const Duration(milliseconds: 1200),
          () => unawaited(_runCreateRequestDemo()),
        );
        break;
      case DemoMode.none:
        break;
    }
  }

  void _scheduleOverviewDemo() {
    final steps = <int>[0, 1, 2, 3, 4, 5];
    for (var index = 1; index < steps.length; index++) {
      _scheduleDemoStep(
        Duration(milliseconds: 1800 * index),
        () => setState(() => _currentIndex = steps[index]),
      );
    }
  }

  Future<void> _runCreateRequestDemo() async {
    await _createListing(
      initialDraft: const DemoListingDraft(
        kind: ListingKind.request,
        category: 'Errands',
        urgency: 'High',
        title: 'Grocery pickup for tonight',
        description:
            'Need help picking up a few groceries before 8 PM for a family dinner.',
        neighborhood: 'Westchester',
        timeText: 'Tonight, 6:30 PM',
        reward: '\$25',
      ),
      autoSubmitDelay: const Duration(milliseconds: 1800),
    );

    if (!mounted || _listings.isEmpty) {
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 1200));
    if (!mounted) {
      return;
    }

    await _openListing(_listings.first);
  }

  void _scheduleDemoStep(Duration delay, VoidCallback action) {
    final timer = Timer(delay, () {
      if (!mounted) {
        return;
      }
      action();
    });
    _demoTimers.add(timer);
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.listings,
    required this.profile,
    required this.onToggleFavorite,
    required this.onOpenListing,
  });

  final List<Listing> listings;
  final UserProfile profile;
  final ValueChanged<String> onToggleFavorite;
  final ValueChanged<Listing> onOpenListing;

  @override
  Widget build(BuildContext context) {
    final featured = listings.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Text(
          'Good evening, ${profile.firstName}',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        Text(
          'Keep your neighborhood connected with trusted help requests, offers, and local messages.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF4F5E59),
                height: 1.35,
              ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            gradient: const LinearGradient(
              colors: [Color(0xFF184E77), Color(0xFF0E6B56)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Community pulse',
                style: TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '12 neighbors are active nearby and 5 requests need a response in the next 24 hours.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              SizedBox(height: 18),
              Row(
                children: [
                  Expanded(child: StatPill(label: 'Open Requests', value: '05')),
                  SizedBox(width: 10),
                  Expanded(child: StatPill(label: 'New Offers', value: '03')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const SectionTitle(
          title: 'Quick Actions',
          subtitle: 'Common ways people use Neighborly',
        ),
        const SizedBox(height: 14),
        const Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ActionTile(
              icon: Icons.school_rounded,
              label: 'Find a tutor',
              tint: Color(0xFFE8F3FF),
            ),
            ActionTile(
              icon: Icons.pets_rounded,
              label: 'Pet care',
              tint: Color(0xFFFFF1E5),
            ),
            ActionTile(
              icon: Icons.local_taxi_rounded,
              label: 'Ride share',
              tint: Color(0xFFEAF7EF),
            ),
            ActionTile(
              icon: Icons.shopping_bag_rounded,
              label: 'Errand help',
              tint: Color(0xFFF9EAFE),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const SectionTitle(
          title: 'Featured Nearby',
          subtitle: 'Recently posted requests and offers',
        ),
        const SizedBox(height: 12),
        ...featured.map(
          (listing) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ListingCard(
              listing: listing,
              onToggleFavorite: () => onToggleFavorite(listing.id),
              onTap: () => onOpenListing(listing),
            ),
          ),
        ),
      ],
    );
  }
}

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({
    super.key,
    required this.listings,
    required this.onToggleFavorite,
    required this.onOpenListing,
  });

  final List<Listing> listings;
  final ValueChanged<String> onToggleFavorite;
  final ValueChanged<Listing> onOpenListing;

  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String _query = '';
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final categories = [
      'All',
      ...{
        for (final listing in widget.listings) listing.category,
      },
    ];

    final filtered = widget.listings.where((listing) {
      final query = _query.toLowerCase().trim();
      final matchesCategory =
          _selectedCategory == 'All' || listing.category == _selectedCategory;
      final matchesQuery = query.isEmpty ||
          listing.title.toLowerCase().contains(query) ||
          listing.description.toLowerCase().contains(query) ||
          listing.neighborhood.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Text(
          'Discover help near you',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        TextField(
          onChanged: (value) => setState(() => _query = value),
          decoration: const InputDecoration(
            hintText: 'Search tutoring, rides, pet care, neighborhoods...',
            prefixIcon: Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: categories
                .map(
                  (category) => Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: _selectedCategory == category,
                      onSelected: (_) =>
                          setState(() => _selectedCategory = category),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 18),
        ...filtered.map(
          (listing) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ListingCard(
              listing: listing,
              onToggleFavorite: () => widget.onToggleFavorite(listing.id),
              onTap: () => widget.onOpenListing(listing),
            ),
          ),
        ),
      ],
    );
  }
}

class ListingBoardPage extends StatelessWidget {
  const ListingBoardPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emptyMessage,
    required this.listings,
    required this.accent,
    required this.onToggleFavorite,
    required this.onOpenListing,
  });

  final String title;
  final String subtitle;
  final String emptyMessage;
  final List<Listing> listings;
  final Color accent;
  final ValueChanged<String> onToggleFavorite;
  final ValueChanged<Listing> onOpenListing;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF52605B),
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        if (listings.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Text(emptyMessage),
            ),
          ),
        ...listings.map(
          (listing) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: ListingCard(
              listing: listing,
              onToggleFavorite: () => onToggleFavorite(listing.id),
              onTap: () => onOpenListing(listing),
            ),
          ),
        ),
      ],
    );
  }
}

class InboxPage extends StatelessWidget {
  const InboxPage({super.key, required this.conversations});

  final List<Conversation> conversations;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Text(
          'Inbox',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Use messaging to confirm details, timing, and safety expectations.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF52605B),
              ),
        ),
        const SizedBox(height: 18),
        ...conversations.map(
          (conversation) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(18),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFF1D3557),
                child: Text(
                  conversation.name.substring(0, 1),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                conversation.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${conversation.category} • ${conversation.message}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    conversation.time,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  if (conversation.unreadCount > 0)
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: const Color(0xFFF48B3C),
                      child: Text(
                        '${conversation.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.profile,
    required this.onProfileUpdated,
    required this.onLogout,
  });

  final UserProfile profile;
  final ValueChanged<UserProfile> onProfileUpdated;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFF0E6B56),
                      child: Text(
                        profile.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.fullName,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Neighborhood member since ${profile.memberSince}'),
                          const SizedBox(height: 2),
                          Text(profile.neighborhood),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  profile.bio,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF53615D),
                        height: 1.35,
                      ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    StatBadge(label: 'Help Given', value: '14'),
                    StatBadge(label: 'Requests Posted', value: '3'),
                    StatBadge(label: 'Rating', value: '4.9'),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Trust tools',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.verified_user_rounded),
                  title: Text('Identity verified'),
                  subtitle: Text('Email and phone confirmation enabled'),
                ),
                const ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.shield_moon_rounded),
                  title: Text('Safety checklist'),
                  subtitle:
                      Text('Meet in public spaces first when arranging rides'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.mail_outline_rounded),
                  title: const Text('Contact'),
                  subtitle: Text('${profile.email}\n(305) 555-0148'),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final updated = await Navigator.of(context).push<UserProfile>(
                        MaterialPageRoute<UserProfile>(
                          builder: (_) => EditProfilePage(profile: profile),
                        ),
                      );
                      if (updated != null) {
                        onProfileUpdated(updated);
                      }
                    },
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Edit Profile'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: onLogout,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1D3557),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Log Out'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CreateListingPage extends StatefulWidget {
  const CreateListingPage({
    super.key,
    required this.profile,
    this.initialDraft,
    this.autoSubmitDelay,
  });

  final UserProfile profile;
  final DemoListingDraft? initialDraft;
  final Duration? autoSubmitDelay;

  @override
  State<CreateListingPage> createState() => _CreateListingPageState();
}

class _CreateListingPageState extends State<CreateListingPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _neighborhoodController = TextEditingController(text: 'Westchester');
  final _rewardController = TextEditingController(text: 'Optional');
  final _timeController = TextEditingController(text: 'This week');

  ListingKind _kind = ListingKind.request;
  String _category = 'Tutoring';
  String _urgency = 'Medium';
  Timer? _autoSubmitTimer;

  @override
  void initState() {
    super.initState();
    final draft = widget.initialDraft;
    if (draft != null) {
      _kind = draft.kind;
      _category = draft.category;
      _urgency = draft.urgency;
      _titleController.text = draft.title;
      _descriptionController.text = draft.description;
      _neighborhoodController.text = draft.neighborhood;
      _rewardController.text = draft.reward;
      _timeController.text = draft.timeText;
    }
    if (widget.autoSubmitDelay != null) {
      _autoSubmitTimer = Timer(widget.autoSubmitDelay!, () {
        if (!mounted) {
          return;
        }
        _submit();
      });
    }
  }

  @override
  void dispose() {
    _autoSubmitTimer?.cancel();
    _titleController.dispose();
    _descriptionController.dispose();
    _neighborhoodController.dispose();
    _rewardController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create a post')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            SegmentedButton<ListingKind>(
              segments: const [
                ButtonSegment(
                  value: ListingKind.request,
                  icon: Icon(Icons.help_rounded),
                  label: Text('Need Help'),
                ),
                ButtonSegment(
                  value: ListingKind.offer,
                  icon: Icon(Icons.handshake_rounded),
                  label: Text('Can Help'),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (selection) {
                setState(() => _kind = selection.first);
              },
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(labelText: 'Category'),
              items: const [
                DropdownMenuItem(value: 'Tutoring', child: Text('Tutoring')),
                DropdownMenuItem(value: 'Rides', child: Text('Rides')),
                DropdownMenuItem(value: 'Errands', child: Text('Errands')),
                DropdownMenuItem(value: 'Pet Care', child: Text('Pet Care')),
                DropdownMenuItem(value: 'Home Help', child: Text('Home Help')),
              ],
              onChanged: (value) => setState(() => _category = value!),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Enter a title.' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Description'),
              validator: (value) => value == null || value.trim().length < 12
                  ? 'Add a few more details.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _neighborhoodController,
              decoration: const InputDecoration(labelText: 'Neighborhood'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'When'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _rewardController,
              decoration:
                  const InputDecoration(labelText: 'Compensation or exchange'),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _urgency,
              decoration: const InputDecoration(labelText: 'Urgency'),
              items: const [
                DropdownMenuItem(value: 'Low', child: Text('Low')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'High', child: Text('High')),
              ],
              onChanged: (value) => setState(() => _urgency = value!),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
                backgroundColor: const Color(0xFF0E6B56),
              ),
              child: const Text('Publish Listing'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      Listing(
        id: 'USER-${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        category: _category,
        timeText: _timeController.text.trim(),
        reward: _rewardController.text.trim(),
        urgency: _urgency,
        owner: widget.profile.fullName,
        kind: _kind,
        tags: [_category, _neighborhoodController.text.trim()],
      ),
    );
  }
}

class ListingDetailPage extends StatelessWidget {
  const ListingDetailPage({super.key, required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(listing.category)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: listing.kind == ListingKind.request
                  ? const Color(0xFFFFF1E5)
                  : const Color(0xFFEAF7EF),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  listing.kind.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Text(
                  listing.title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 10),
                Text(
                  listing.description,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          DetailRow(label: 'Posted by', value: listing.owner),
          DetailRow(label: 'Neighborhood', value: listing.neighborhood),
          DetailRow(label: 'When', value: listing.timeText),
          DetailRow(label: 'Compensation', value: listing.reward),
          DetailRow(label: 'Urgency', value: listing.urgency),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: listing.tags.map((tag) => Chip(label: Text(tag))).toList(),
          ),
          const SizedBox(height: 28),
          FilledButton.icon(
            onPressed: () {},
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: const Color(0xFF1D3557),
            ),
            icon: const Icon(Icons.chat_rounded),
            label: Text(
              listing.kind == ListingKind.request
                  ? 'Offer to Help'
                  : 'Request This Help',
            ),
          ),
        ],
      ),
    );
  }
}

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.profile});

  final UserProfile profile;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _neighborhoodController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _emailController = TextEditingController(text: widget.profile.email);
    _neighborhoodController =
        TextEditingController(text: widget.profile.neighborhood);
    _bioController = TextEditingController(text: widget.profile.bio);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _neighborhoodController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter your name.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) =>
                  value != null && value.contains('@') ? null : 'Enter a valid email.',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _neighborhoodController,
              decoration: const InputDecoration(labelText: 'Neighborhood'),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter your neighborhood.'
                  : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _bioController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Bio'),
              validator: (value) => value == null || value.trim().length < 12
                  ? 'Add a short bio.'
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0E6B56),
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              child: const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      widget.profile.copyWith(
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        neighborhood: _neighborhoodController.text.trim(),
        bio: _bioController.text.trim(),
      ),
    );
  }
}

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    required this.onToggleFavorite,
    required this.onTap,
  });

  final Listing listing;
  final VoidCallback onToggleFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = listing.kind == ListingKind.request
        ? const Color(0xFFFFF1E5)
        : const Color(0xFFEAF7EF);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: tone,
                    ),
                    child: Text(
                      listing.kind.label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: onToggleFavorite,
                    icon: Icon(
                      listing.isFavorite
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                    ),
                  ),
                ],
              ),
              Text(
                listing.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                listing.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF54645F),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: listing.tags
                    .map(
                      (tag) => Chip(
                        label: Text(tag),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 18),
                  const SizedBox(width: 6),
                  Expanded(child: Text(listing.neighborhood)),
                  const Icon(Icons.schedule_rounded, size: 18),
                  const SizedBox(width: 6),
                  Text(listing.timeText),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    listing.reward,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Text(
                    'Posted by ${listing.owner}',
                    style: const TextStyle(color: Color(0xFF677570)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FeatureChip extends StatelessWidget {
  const FeatureChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.white,
      side: BorderSide.none,
      labelStyle: const TextStyle(fontWeight: FontWeight.w600),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: const [
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 158,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 30),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF65726D),
              ),
        ),
      ],
    );
  }
}

class StatPill extends StatelessWidget {
  const StatPill({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class StatBadge extends StatelessWidget {
  const StatBadge({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F5F4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
          ),
          Text(label),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  const DetailRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF53615D),
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class DemoListingDraft {
  const DemoListingDraft({
    required this.kind,
    required this.category,
    required this.urgency,
    required this.title,
    required this.description,
    required this.neighborhood,
    required this.timeText,
    required this.reward,
  });

  final ListingKind kind;
  final String category;
  final String urgency;
  final String title;
  final String description;
  final String neighborhood;
  final String timeText;
  final String reward;
}

enum ListingKind {
  request('Need Help'),
  offer('Can Help');

  const ListingKind(this.label);

  final String label;
}

class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.description,
    required this.neighborhood,
    required this.category,
    required this.timeText,
    required this.reward,
    required this.urgency,
    required this.owner,
    required this.kind,
    required this.tags,
    this.isFavorite = false,
  });

  final String id;
  final String title;
  final String description;
  final String neighborhood;
  final String category;
  final String timeText;
  final String reward;
  final String urgency;
  final String owner;
  final ListingKind kind;
  final List<String> tags;
  final bool isFavorite;

  Listing copyWith({bool? isFavorite}) {
    return Listing(
      id: id,
      title: title,
      description: description,
      neighborhood: neighborhood,
      category: category,
      timeText: timeText,
      reward: reward,
      urgency: urgency,
      owner: owner,
      kind: kind,
      tags: tags,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

class Conversation {
  const Conversation({
    required this.name,
    required this.category,
    required this.message,
    required this.time,
    required this.unreadCount,
  });

  final String name;
  final String category;
  final String message;
  final String time;
  final int unreadCount;
}

class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.email,
    required this.neighborhood,
    required this.bio,
    required this.memberSince,
  });

  final String fullName;
  final String email;
  final String neighborhood;
  final String bio;
  final String memberSince;

  String get firstName => fullName.trim().split(' ').first;

  String get initials {
    final parts = fullName
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .toList();
    return parts.map((part) => part[0].toUpperCase()).join();
  }

  UserProfile copyWith({
    String? fullName,
    String? email,
    String? neighborhood,
    String? bio,
    String? memberSince,
  }) {
    return UserProfile(
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      neighborhood: neighborhood ?? this.neighborhood,
      bio: bio ?? this.bio,
      memberSince: memberSince ?? this.memberSince,
    );
  }
}
