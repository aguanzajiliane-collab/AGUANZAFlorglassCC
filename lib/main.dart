import 'package:flutter/material.dart';

void main() => runApp(const FlorglassAluminumApp());

const Color brandOrange = Color(0xFFFF7900);
const Color ink = Color(0xFF171717);
const Color canvas = Color(0xFFFFF8F0);

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, required this.message, this.action});
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54, color: brandOrange),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54, height: 1.4)),
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}

class FlorglassAluminumApp extends StatelessWidget {
  const FlorglassAluminumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlorglassAluminum',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: canvas,
        colorScheme: ColorScheme.fromSeed(seedColor: brandOrange),
        appBarTheme: const AppBarTheme(
          backgroundColor: canvas,
          foregroundColor: ink,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class ServiceItem {
  ServiceItem({
    required this.name,
    required this.category,
    required this.description,
    required this.price,
    this.isCustom = false,
  });

  final String name;
  final String category;
  final String description;
  final double price;
  final bool isCustom;
}

class RemoteProduct {
  RemoteProduct({
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
  });

  final String title;
  final String description;
  final double price;
  final String thumbnail;

  factory RemoteProduct.fromJson(Map<String, dynamic> json) {
    return RemoteProduct(
      title: json['title']?.toString() ?? 'Untitled item',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      thumbnail: json['thumbnail']?.toString() ?? '',
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedTab = 0;
  bool isLoading = false;
  String? apiError;
  List<RemoteProduct> remoteProducts = [];
  final List<ServiceItem> services = [
    ServiceItem(
      name: 'Aluminum Windows',
      category: 'Windows',
      description: 'Made-to-measure aluminum window installation.',
      price: 2500,
    ),
    ServiceItem(
      name: 'Glass Doors',
      category: 'Doors',
      description: 'Modern glass door supply and installation.',
      price: 4800,
    ),
    ServiceItem(
      name: 'Glass Partitions',
      category: 'Partitions',
      description: 'Clean glass partitions for homes and offices.',
      price: 3200,
    ),
    ServiceItem(
      name: 'Aluminum Cabinets',
      category: 'Cabinetry',
      description: 'Durable aluminum cabinet fabrication.',
      price: 5500,
    ),
  ];

  @override
  void initState() {
    super.initState();
    fetchRemoteProducts();
  }

 
Future<void> fetchRemoteProducts() async {
  setState(() {
    isLoading = true;
    apiError = null;
  });

  await Future<void>.delayed(const Duration(milliseconds: 300));

  if (!mounted) return;

  setState(() {
    remoteProducts = [
      RemoteProduct(
        title: 'Aluminum Jalousie Window',
        description: 'Aluminum frame with adjustable glass blades.',
        price: 2500,
        thumbnail: 'assets/images/aluminumjalousiewindow.png',
      ),
      RemoteProduct(
        title: 'Jalousie Glass Blades',
        description: 'Glass slats for aluminum jalousie windows.',
        price: 800,
        thumbnail: 'assets/images/aluminumjalousiewindow.png',
      ),
      RemoteProduct(
        title: 'Clear Glass',
        description: 'Clear glass panels for windows and doors.',
        price: 1200,
        thumbnail: 'assets/images/clear-glass.png',
      ),
      RemoteProduct(
        title: 'Tinted Glass',
        description: 'Tinted glass panels for homes and offices.',
        price: 1800,
        thumbnail: 'assets/images/tintedglass.png',
      ),
      RemoteProduct(
        title: 'Aluminum Window Frames',
        description: 'Aluminum profiles for custom windows.',
        price: 1500,
        thumbnail: 'assets/images/Aluminum Window Frames.png',
      ),
      RemoteProduct(
        title: 'Sliding Window Rollers',
        description: 'Rollers for smooth sliding windows.',
        price: 150,
        thumbnail: 'assets/images/Sliding Window Rollers.png',
      ),
      RemoteProduct(
        title: 'Window Handles and Locks',
        description: 'Accessories for aluminum windows.',
        price: 120,
        thumbnail: 'assets/images/Window Handles and Locks.png',
      ),
      RemoteProduct(
        title: 'Glass Door Panels',
        description: 'Glass panels for door fabrication.',
        price: 3500,
        thumbnail: 'assets/images/Glass Door Panels.png',
      ),
    ];

    isLoading = false;
  });
}


  void addService() {
    final nameController = TextEditingController();
    final categoryController = TextEditingController(text: 'Custom');
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add a service'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Service name')),
              const SizedBox(height: 10),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Category')),
              const SizedBox(height: 10),
              TextField(controller: descriptionController, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 10),
              TextField(
                controller: priceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Starting price (₱)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: brandOrange),
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim());
              if (name.isEmpty || price == null || price < 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Enter a service name and a valid price.')),
                );
                return;
              }
              setState(() {
                services.add(ServiceItem(
                  name: name,
                  category: categoryController.text.trim().isEmpty ? 'Custom' : categoryController.text.trim(),
                  description: descriptionController.text.trim().isEmpty
                      ? 'Contact us for more details.'
                      : descriptionController.text.trim(),
                  price: price,
                  isCustom: true,
                ));
              });
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service added successfully.')),
              );
            },
            child: const Text('Add service'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteService(int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete service?'),
        content: Text('Remove "${services[index].name}" from this list?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      setState(() => services.removeAt(index));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Service deleted.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      dashboardPage(),
      servicesPage(),
      onlinePage(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/florglassaluminum_logo.png',
                width: 42,
                height: 42,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('FlorglassAluminum', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
                  Text('Glass • Aluminum • Works', style: TextStyle(fontSize: 11, color: Colors.black54)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(child: IndexedStack(index: selectedTab, children: pages)),
      floatingActionButton: selectedTab == 1
          ? FloatingActionButton.extended(
              onPressed: addService,
              backgroundColor: brandOrange,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add service'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedTab,
        onDestinationSelected: (index) => setState(() => selectedTab = index),
        indicatorColor: brandOrange.withValues(alpha: 0.18),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.construction_outlined), selectedIcon: Icon(Icons.construction), label: 'Services'),
          NavigationDestination(icon: Icon(Icons.cloud_outlined), selectedIcon: Icon(Icons.cloud), label: 'Online items'),
        ],
      ),
    );
  }

  Widget dashboardPage() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8B1F), Color(0xFFEF5B00)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('BUILD WITH CONFIDENCE', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              const SizedBox(height: 10),
              const Text('Glass & aluminum\\nsolutions for your space.', style: TextStyle(color: Colors.white, fontSize: 26, height: 1.15, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              const Text('Explore services, manage your list, and browse online product inspiration.', style: TextStyle(color: Colors.white, height: 1.4)),
              const SizedBox(height: 18),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: ink),
                onPressed: () => setState(() => selectedTab = 1),
                child: const Text('Explore services'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const SectionHeading(title: 'At a glance', subtitle: 'Your workspace overview'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: SummaryCard(icon: Icons.handyman_outlined, label: 'Services', value: '${services.length}', color: brandOrange)),
            const SizedBox(width: 12),
            Expanded(child: SummaryCard(icon: Icons.cloud_done_outlined, label: 'Online items', value: isLoading ? '…' : '${remoteProducts.length}', color: const Color(0xFF247A68))),
          ],
        ),
        const SizedBox(height: 24),
        const SectionHeading(title: 'Popular services', subtitle: 'A quick look at what we offer'),
        const SizedBox(height: 10),
        ...services.take(3).map((item) => ServiceTile(item: item)),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => setState(() => selectedTab = 1),
          icon: const Icon(Icons.arrow_forward),
          label: const Text('View all services'),
        ),
      ],
    );
  }

  Widget servicesPage() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 16, 18, 8),
          child: SectionHeading(title: 'Our services', subtitle: 'Add, review, or remove service records'),
        ),
        Expanded(
          child: services.isEmpty
              
? const EmptyState(
    icon: Icons.construction_outlined,
    title: 'No services yet',
    message: 'Tap “Add service” to create your first service record.',
  )
  : ListView.builder(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 100),
      itemCount: services.length,
      itemBuilder: (context, index) => ServiceTile(
        item: services[index],
        onDelete: () => deleteService(index),
      ),
    ),
        ),
      ],
    );
  }

  Widget onlinePage() {
    if (isLoading && remoteProducts.isEmpty) {
      return const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [CircularProgressIndicator(), SizedBox(height: 14), Text('Loading online items…')]));
    }
    if (apiError != null && remoteProducts.isEmpty) {
      return EmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Unable to load items',
        message: apiError!,
        action: FilledButton.icon(
          onPressed: fetchRemoteProducts,
          icon: const Icon(Icons.refresh),
          label: const Text('Try again'),
        ),
      );
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
          child: Row(
            children: [
              const Expanded(child: SectionHeading(title: 'Online items', subtitle: 'Sample products loaded from an API')),
              IconButton(onPressed: fetchRemoteProducts, tooltip: 'Refresh', icon: const Icon(Icons.refresh)),
            ],
          ),
        ),
        if (apiError != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Text(apiError!, style: const TextStyle(color: Colors.red)),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
            itemCount: remoteProducts.length,
            itemBuilder: (context, index) => RemoteProductTile(product: remoteProducts[index]),
          ),
        ),
      ],
    );
  }
}

class SectionHeading extends StatelessWidget {
  const SectionHeading({super.key, required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
        const SizedBox(height: 3),
        Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 12)),
      ],
    );
  }
}

class SummaryCard extends StatelessWidget {
  const SummaryCard({super.key, required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 14),
          Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class ServiceTile extends StatelessWidget {
  const ServiceTile({super.key, required this.item, this.onDelete});
  final ServiceItem item;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: brandOrange.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
            child: Icon(item.category.toLowerCase().contains('window') ? Icons.window : Icons.home_repair_service_outlined, color: brandOrange, size: 26),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                const SizedBox(height: 4),
                Text(item.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.3)),
                const SizedBox(height: 7),
                Text('From ₱${item.price.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFB94E00), fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Delete service',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            ),
        ],
      ),
    );
  }
}

class RemoteProductTile extends StatelessWidget {
  const RemoteProductTile({super.key, required this.product});

  final RemoteProduct product;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              product.thumbnail,
              width: 74,
              height: 74,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 74,
                  height: 74,
                  color: canvas,
                  child: const Icon(
                    Icons.image_not_supported_outlined,
                    size: 30,
                    color: brandOrange,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  product.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                '₱${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xFFB94E00),
                ),
               ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
