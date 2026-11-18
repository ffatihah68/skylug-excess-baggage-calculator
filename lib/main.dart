import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SkyLugApp());
}

// COLOUR PALETTE
// The colours are kept in one class so the app has a consistent theme.
class AppColors {
  static const navy = Color(0xFF15345A);
  static const blue = Color(0xFF397FB9);
  static const lightBlue = Color(0xFFEAF3FC);
  static const background = Color(0xFFF6F9FD);
  static const muted = Color(0xFF60778F);
  static const teal = Color(0xFF277A78);
  static const border = Color(0xFFD5E4F2);
}

// MAIN APPLICATION
class SkyLugApp extends StatelessWidget {
  const SkyLugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkyLug',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.blue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.navy,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.blue,
              width: 2,
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// NAVIGATION DRAWER
class SkyLugDrawer extends StatelessWidget {
  const SkyLugDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 65, 24, 28),
            decoration: const BoxDecoration(
              color: AppColors.navy,
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.flight_takeoff_rounded,
                  color: Colors.white,
                  size: 42,
                ),
                SizedBox(height: 16),
                Text(
                  'skylug',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Travel light. Pay right.',
                  style: TextStyle(color: Color(0xFFB7DBF6)),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_rounded),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('About'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutPage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// HOME PAGE
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Controllers read the values entered by the user.
  final TextEditingController weightController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  // The selected ticket class.
  String ticketClass = 'Economy';

  // Calculation results.
  double excessWeight = 0;
  double excessCharge = 0;
  double totalPayable = 0;

  bool showResult = false;

  // Check the input before calculating.
  // This uses the simple if and tryParse approach from the labs.
  void calculateFee() {
    String weightText = weightController.text.trim();
    String rateText = rateController.text.trim();

    if (weightText.isEmpty || rateText.isEmpty) {
      showMessage('Please fill in all fields.');
      setState(() {
        showResult = false;
      });
      return;
    }

    double? weight = double.tryParse(weightText);
    double? rate = double.tryParse(rateText);

    if (weight == null || rate == null ||
        !weight.isFinite || !rate.isFinite) {
      showMessage('Please enter valid numbers.');
      setState(() {
        showResult = false;
      });
      return;
    }

    if (weight < 0 || rate < 0) {
      showMessage('Values cannot be negative.');
      setState(() {
        showResult = false;
      });
      return;
    }

    // Determine the baggage allowance.
    double allowance;

    if (ticketClass == 'Economy') {
      allowance = 20;
    } else {
      allowance = 40;
    }

    // Calculate excess weight and charges.
    double calculatedExcess = weight - allowance;

    if (calculatedExcess < 0) {
      calculatedExcess = 0;
    }

    double calculatedCharge = calculatedExcess * rate;
    double calculatedTax = calculatedCharge * 0.08;
    double calculatedTotal = calculatedCharge + calculatedTax;

    setState(() {
      excessWeight = calculatedExcess;
      excessCharge = calculatedCharge;
      totalPayable = calculatedTotal;
      showResult = true;
    });
  }

  // Display a message when the input is invalid.
  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.navy,
      ),
    );
  }

  // Clear all inputs and return to the default selection.
  void resetCalculator() {
    weightController.clear();
    rateController.clear();

    setState(() {
      ticketClass = 'Economy';
      excessWeight = 0;
      excessCharge = 0;
      totalPayable = 0;
      showResult = false;
    });
  }

  @override
  void dispose() {
    weightController.dispose();
    rateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SkyLugDrawer(),
      appBar: AppBar(
        title: const Text(
          'skylug',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // AESTHETIC HEADER
                Container(
                  padding: const EdgeInsets.all(26),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.navy,
                        AppColors.blue,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'YOUR JOURNEY, MADE LIGHTER',
                        style: TextStyle(
                          color: Color(0xFFB7DBF6),
                          fontSize: 11,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Travel light.\nPay right.',
                        style: TextStyle(
                          fontSize: 32,
                          height: 1.15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Calculate your baggage fees before you fly.',
                        style: TextStyle(
                          color: Color(0xFFE2EFFB),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        children: [
                          Icon(
                            Icons.flight_rounded,
                            color: Color(0xFFC2E7FF),
                          ),
                          SizedBox(width: 10),
                          Text(
                            'SMART BAGGAGE ESTIMATOR',
                            style: TextStyle(
                              color: Color(0xFFC2E7FF),
                              fontSize: 11,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // CALCULATOR INPUTS
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(
                            Icons.luggage_rounded,
                            color: AppColors.blue,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Flight Details',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),

                      const Text(
                        'Baggage Weight (kg)',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'e.g. 25',
                          prefixIcon: Icon(Icons.scale_rounded),
                          suffixText: 'kg',
                        ),
                        onChanged: (value) {
                          setState(() {
                            showResult = false;
                          });
                        },
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Ticket Class',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // RADIO GROUP FROM THE LAB.
                      // LayoutBuilder and Wrap make the cards responsive.
                      RadioGroup<String>(
                        groupValue: ticketClass,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              ticketClass = value;
                              showResult = false;
                            });
                          }
                        },
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            double cardWidth =
                                (constraints.maxWidth - 12) / 2;

                            return Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  width: cardWidth,
                                  child: ticketClassCard(
                                    title: 'Economy',
                                    allowance: '20 kg allowance',
                                    value: 'Economy',
                                    icon: Icons.airline_seat_recline_normal,
                                  ),
                                ),
                                SizedBox(
                                  width: cardWidth,
                                  child: ticketClassCard(
                                    title: 'Business',
                                    allowance: '40 kg allowance',
                                    value: 'Business',
                                    icon: Icons.business_center_outlined,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),
                      const Text(
                        'Excess Baggage Rate',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: rateController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          hintText: 'e.g. 15',
                          prefixIcon: Icon(Icons.payments_outlined),
                          suffixText: 'RM/kg',
                        ),
                        onChanged: (value) {
                          setState(() {
                            showResult = false;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      // INFORMATION CARD
                      Card(
                        color: AppColors.lightBlue,
                        elevation: 0,
                        child: const Padding(
                          padding: EdgeInsets.all(14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: AppColors.blue,
                                size: 19,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Economy includes 20 kg and Business '
                                  'includes 40 kg. An 8% service tax '
                                  'applies to excess baggage charges.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.muted,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: calculateFee,
                          icon: const Icon(Icons.calculate_outlined),
                          label: const Text(
                            'Calculate Fee',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: resetCalculator,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reset Calculator'),
                      ),

                      if (showResult) ...[
                        const SizedBox(height: 18),
                        resultCard(),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TICKET CLASS CARD
  // RadioListTile handles selection; Card provides the visual design.
  Widget ticketClassCard({
    required String title,
    required String allowance,
    required String value,
    required IconData icon,
  }) {
    bool selected = ticketClass == value;

    return Card(
      color: selected ? AppColors.lightBlue : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected ? AppColors.blue : AppColors.border,
          width: selected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
        subtitle: Text(
          allowance,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.muted,
          ),
        ),
        secondary: Icon(
          icon,
          color: AppColors.blue,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        dense: true,
      ),
    );
  }

  // RESULTS CARD
  Widget resultCard() {
    return Card(
      color: AppColors.lightBlue,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.teal,
                ),
                SizedBox(width: 10),
                Text(
                  'Your Estimate',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            resultRow(
              'Excess Weight',
              '${excessWeight.toStringAsFixed(2)} kg',
            ),
            const SizedBox(height: 14),
            resultRow(
              'Baggage Charge',
              'RM ${excessCharge.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 14),
            resultRow(
              'Service Tax (8%)',
              'RM ${(excessCharge * 0.08).toStringAsFixed(2)}',
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Divider(),
            ),
            const Text(
              'TOTAL PAYABLE',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 1.5,
                color: AppColors.muted,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'RM ${totalPayable.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // A reusable row for displaying the calculation details.
  Widget resultRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: AppColors.muted),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.navy,
          ),
        ),
      ],
    );
  }
}

// ABOUT PAGE
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  // Replace YOUR_USERNAME with your actual GitHub username.
  static const String githubUrl =
      'https://github.com/YOUR_USERNAME/excess_baggage_calculator';

  Future<void> openGitHub(BuildContext context) async {
    final uri = Uri.parse(githubUrl);

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        throw Exception('Unable to open link');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open GitHub repository'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const SkyLugDrawer(),
      appBar: AppBar(
        title: const Text('About Me'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  // APPLICATION ICON: skylug_icon.jpg
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/images/skylug_icon.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [AppColors.navy, AppColors.blue],
                              ),
                            ),
                            child: const Icon(
                              Icons.luggage_rounded,
                              color: Colors.white,
                              size: 58,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'skylug',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Travel light. Pay right.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 26),

                  // PERSONAL PROFILE PHOTO: profile.jpg
                  Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/profile.jpg',
                        width: 112,
                        height: 112,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 112,
                            height: 112,
                            color: AppColors.lightBlue,
                            child: const Icon(
                              Icons.person_rounded,
                              color: AppColors.blue,
                              size: 58,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'NUR FATIN FATIHAH',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'SkyLug Developer',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.muted,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // ABOUT THE APPLICATION
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    child: const Padding(
                      padding: EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Me',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'My name is NUR FATIN FATIHAH. I am a CSC251 '
                            'student and the developer of SkyLug. I created '
                            'this application to help airline passengers '
                            'estimate their excess baggage fees easily '
                            'and accurately.',
                            style: TextStyle(
                              height: 1.6,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // STUDENT INFORMATION
                  Card(
                    color: Colors.white,
                    elevation: 0,
                    child: const Column(
                      children: [
                        ListTile(
                          leading: Icon(
                            Icons.person_outline,
                            color: AppColors.blue,
                          ),
                          title: Text('Author'),
                          subtitle: Text('NUR FATIN FATIHAH'),
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.badge_outlined,
                            color: AppColors.blue,
                          ),
                          title: Text('Matric Number'),
                          subtitle: Text('2025238682'),
                        ),
                        Divider(height: 1),
                        ListTile(
                          leading: Icon(
                            Icons.school_outlined,
                            color: AppColors.blue,
                          ),
                          title: Text('Course'),
                          subtitle: Text('CSC251'),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // GITHUB LINK
                  Card(
                    color: AppColors.lightBlue,
                    elevation: 0,
                    child: ListTile(
                      leading: const Icon(
                        Icons.code_rounded,
                        color: AppColors.blue,
                      ),
                      title: const Text(
                        'GitHub Repository',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('View SkyLug source code'),
                      trailing: const Icon(Icons.open_in_new),
                      onTap: () => openGitHub(context),
                    ),
                  ),

                  const SizedBox(height: 35),
                  const Text(
                    '© 2026 NUR FATIN FATIHAH. All rights reserved.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
