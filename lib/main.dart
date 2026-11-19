import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const SkyLugApp());
}

class SkyLugApp extends StatelessWidget {
  const SkyLugApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SkyLug',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF6F9FD),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF15345A),
          centerTitle: true,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD5E4F2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF397FB9), width: 2),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// Side menu with the same soft blue and white style as the Home page.
class SkyLugDrawer extends StatelessWidget {
  final bool isAbout;

  const SkyLugDrawer({super.key, this.isAbout = false});

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF15345A);
    const blue = Color(0xFF397FB9);
    const lightBlue = Color(0xFFEAF3FC);

    return Drawer(
      backgroundColor: const Color(0xFFF6F9FD),
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 22),
            child: Row(
              children: [
                Image.asset(
                  'assets/images/skylug_launcher.png',
                  width: 68,
                  height: 68,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('SkyLug',
                          style: TextStyle(
                              color: navy,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 3),
                      Text('Travel light. Pay right.',
                          style: TextStyle(color: Color(0xFF60778F), fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: isAbout ? Colors.transparent : lightBlue,
              leading: Icon(Icons.home_outlined, color: isAbout ? navy : blue),
              title: Text('Home',
                  style: TextStyle(
                      color: navy,
                      fontWeight: isAbout ? FontWeight.normal : FontWeight.bold)),
              onTap: () {
                Navigator.pop(context);
                if (isAbout) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: isAbout ? lightBlue : Colors.transparent,
              leading: Icon(Icons.person_outline, color: isAbout ? blue : navy),
              title: Text('About Me',
                  style: TextStyle(
                      color: navy,
                      fontWeight: isAbout ? FontWeight.bold : FontWeight.normal)),
              onTap: () {
                Navigator.pop(context);
                if (!isAbout) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AboutPage()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController rateController = TextEditingController();

  String ticketClass = 'Economy';
  double excessWeight = 0;
  double excessCharge = 0;
  double totalPayable = 0;
  bool showResult = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void calculateFee() {
    String weightText = weightController.text.trim();
    String rateText = rateController.text.trim();

    if (weightText.isEmpty || rateText.isEmpty) {
      showMessage('Please fill in all fields.');
      setState(() { showResult = false; });
      return;
    }

    double? weight = double.tryParse(weightText);
    double? rate = double.tryParse(rateText);

    if (weight == null || rate == null ||
        !weight.isFinite || !rate.isFinite) {
      showMessage('Please enter valid numbers.');
      setState(() { showResult = false; });
      return;
    }

    if (weight < 0 || rate < 0) {
      showMessage('Values cannot be negative.');
      setState(() { showResult = false; });
      return;
    }

    if (weight > 100) {
      showMessage('Baggage weight cannot exceed 100 kg.');
      setState(() { showResult = false; });
      return;
    }

    double allowance;
    if (ticketClass == 'Economy') {
      allowance = 20;
    } else {
      allowance = 40;
    }

    double calculatedExcess = weight - allowance;
    if (calculatedExcess < 0) {
      calculatedExcess = 0;
    }

    double calculatedCharge = calculatedExcess * rate;
    double calculatedTax = calculatedCharge * 0.08;

    setState(() {
      excessWeight = calculatedExcess;
      excessCharge = calculatedCharge;
      totalPayable = calculatedCharge + calculatedTax;
      showResult = true;
    });
  }

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
      appBar: AppBar(title: const Text('SkyLug', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A light header lets the white SkyLug logo blend in naturally.
            Container(
              padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD5E4F2)),
              ),
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/skylug_launcher.png',
                    width: 102,
                    height: 102,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Excess Baggage Calculator',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF15345A),
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Travel light. Pay right.',
                    style: TextStyle(color: Color(0xFF60778F)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const Text('Flight Details', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Color(0xFF15345A))),
            const SizedBox(height: 16),
            const Text('Baggage Weight (kg)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Enter baggage weight (max 100 kg)',
              ),
              onChanged: (value) {
                setState(() { showResult = false; });
              },
            ),
            const SizedBox(height: 20),

            const Text('Ticket Class', style: TextStyle(fontWeight: FontWeight.w600)),
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
              child: const Column(
                children: [
                  RadioListTile<String>(
                    title: Text('Economy (20 kg allowance)'),
                    value: 'Economy',
                  ),
                  RadioListTile<String>(
                    title: Text('Business (40 kg allowance)'),
                    value: 'Business',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            const Text('Excess Baggage Rate (RM/kg)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            TextField(
              controller: rateController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                hintText: 'Enter rate per kg',
              ),
              onChanged: (value) {
                setState(() { showResult = false; });
              },
            ),
            const SizedBox(height: 18),
            const Text(
              'Service tax: 8% of the excess baggage charge',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 18),

            SizedBox(
              height: 50,
              child: ElevatedButton(
              onPressed: calculateFee,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF397FB9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Calculate Fee', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            TextButton(
              onPressed: resetCalculator,
              child: const Text('Reset Calculator'),
            ),

            if (showResult) ...[
              const SizedBox(height: 15),
              Card(
                color: const Color(0xFFEAF3FC),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Your Estimate',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Text('Excess Weight: ${excessWeight.toStringAsFixed(2)} kg'),
                      Text('Baggage Charge: RM ${excessCharge.toStringAsFixed(2)}'),
                      Text('Service Tax (8%): RM ${(excessCharge * 0.08).toStringAsFixed(2)}'),
                      const Divider(),
                      Text('Total Payable: RM ${totalPayable.toStringAsFixed(2)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const String githubUrl =
      'https://github.com/ffatihah68/skylug-excess-baggage-calculator';

  Future<void> openGitHub(BuildContext context) async {
    try {
      final opened = await launchUrl(
        Uri.parse(githubUrl),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        throw Exception('Unable to open URL');
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to open GitHub repository')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const navy = Color(0xFF15345A);
    const blue = Color(0xFF397FB9);
    const borderColor = Color(0xFFD5E4F2);
    const muted = Color(0xFF60778F);

    return Scaffold(
      drawer: const SkyLugDrawer(isAbout: true),
      appBar: AppBar(
        title: const Text('About Me',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Brand header. White background blends with the logo image.
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/skylug_launcher.png',
                        width: 98,
                        height: 98,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.cloud_outlined, color: blue, size: 72),
                      ),
                      const SizedBox(height: 4),
                      const Text('SkyLug',
                          style: TextStyle(
                              fontSize: 26,
                              color: navy,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      const Text('Travel light. Pay right.',
                          style: TextStyle(color: muted)),
                      const SizedBox(height: 12),
                      const Text(
                        'A simple app to estimate excess baggage fees before your flight.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: muted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Developer details grouped into one neat card.
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: borderColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Meet the Developer',
                          style: TextStyle(
                              fontSize: 18,
                              color: navy,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ClipOval(
                            child: Image.asset(
                              'assets/images/profile.jpg',
                              width: 76,
                              height: 76,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 76,
                                height: 76,
                                color: const Color(0xFFEAF3FC),
                                child: const Icon(Icons.person, color: blue, size: 42),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('NUR FATIN FATIHAH BINTI RAZALI',
                                    style: TextStyle(
                                        color: navy,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('SkyLug Developer',
                                    style: TextStyle(color: muted, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.badge_outlined, color: blue),
                        title: Text('Matric Number'),
                        subtitle: Text('2025238682'),
                      ),
                      const ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.school_outlined, color: blue),
                        title: Text('Course'),
                        subtitle: Text('CSC251'),
                      ),
                      const Divider(),
                      const SizedBox(height: 10),
                      const Text('About Me',
                          style: TextStyle(color: navy, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text(
                        'I am a CSC251 student and the developer of SkyLug. '
                        'I created this app to help passengers calculate their '
                        'excess baggage fees quickly and easily.',
                        style: TextStyle(color: muted, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                // Tappable repository card.
                Card(
                  color: const Color(0xFFEAF3FC),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: borderColor),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.code_outlined, color: blue),
                    title: const Text('GitHub Repository',
                        style: TextStyle(color: navy, fontWeight: FontWeight.bold)),
                    subtitle: const Text('View SkyLug source code'),
                    trailing: const Icon(Icons.open_in_new, color: blue),
                    onTap: () => openGitHub(context),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '© 2026 NUR FATIN FATIHAH BINTI RAZALI. All rights reserved.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
