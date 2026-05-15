import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
 
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _testsController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();
  final TextEditingController _referralsController = TextEditingController();

  
  DateTime? _selectedAppointmentDate;
  TimeOfDay? _selectedAppointmentTime;
  DateTime? _selectedOnsetDate;

  
  final Color _primaryBurgundy = const Color(0xFF672E3A);
  final Color _lightCream = const Color(0xFFE8DDDA);

  
  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  @override
  void dispose() {
    _clientNameController.dispose();
    _testsController.dispose();
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _referralsController.dispose();
    super.dispose();
  }

  // --- Date/Time Pickers ---
  Future<DateTime?> _selectDate(BuildContext context, DateTime? initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: _primaryBurgundy),
          ),
          child: child!,
        );
      },
    );
  }

  Future<TimeOfDay?> _selectTime(BuildContext context) async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: _primaryBurgundy),
          ),
          child: child!,
        );
      },
    );
  }

  
  Future<void> _saveRecordToFirebase() async {
    if (_uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: You must be logged in to save.')),
      );
      return;
    }

    if (_clientNameController.text.isEmpty ||
        _selectedAppointmentDate == null ||
        _selectedAppointmentTime == null ||
        _selectedOnsetDate == null ||
        _diagnosisController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all mandatory fields.')),
      );
      return;
    }

    String formattedAppt =
        "${_selectedAppointmentDate!.toLocal().toString().split(' ')[0]} at ${_selectedAppointmentTime!.format(context)}";
    String formattedOnsetDate = _selectedOnsetDate!.toLocal().toString().split(' ')[0];

    try {
      
      await FirebaseFirestore.instance.collection('patient_visits').add({
        'clientName': _clientNameController.text,
        'appointment': formattedAppt,
        'onsetDate': formattedOnsetDate,
        'tests': _testsController.text.isEmpty ? 'None' : _testsController.text,
        'diagnosis': _diagnosisController.text,
        'prescription': _prescriptionController.text.isEmpty ? 'None' : _prescriptionController.text,
        'referrals': _referralsController.text.isEmpty ? 'None' : _referralsController.text,
        'createdBy': _uid, // Critical for filtering
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Clear all fields after saving
      _clientNameController.clear();
      _testsController.clear();
      _diagnosisController.clear();
      _prescriptionController.clear();
      _referralsController.clear();
      setState(() {
        _selectedAppointmentDate = null;
        _selectedAppointmentTime = null;
        _selectedOnsetDate = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Record Saved Privately!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Patient Records Portal"),
          backgroundColor: _primaryBurgundy,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.add_box), text: "New Entry"),
              Tab(icon: Icon(Icons.lock), text: "Private Logs"),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: TabBarView(
          children: [
            // TAB 1: ENTRY FORM
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader("Input Visit Record", Icons.edit_document),
                  const SizedBox(height: 16),
                  _buildInputForm(),
                ],
              ),
            ),

            // TAB 2: PRIVATE LOGS
            _buildPrivateDataTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivateDataTab() {
    if (_uid == null) return const Center(child: Text("Please log in."));

    return StreamBuilder<QuerySnapshot>(
      // Filtering records to show ONLY those created by the current user
      stream: FirebaseFirestore.instance
          .collection('patient_visits')
          .where('createdBy', isEqualTo: _uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No private records found."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var data = doc.data() as Map<String, dynamic>;

            return Card(
              color: _lightCream,
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ExpansionTile(
                iconColor: _primaryBurgundy,
                collapsedIconColor: _primaryBurgundy,
                title: Text(
                  data['clientName'] ?? 'No Name',
                  style: TextStyle(fontWeight: FontWeight.bold, color: _primaryBurgundy, fontSize: 18),
                ),
                subtitle: Text("Appt: ${data['appointment']}"),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        _buildDetailRow("Onset Date", data['onsetDate']),
                        _buildDetailRow("Tests", data['tests']),
                        _buildDetailRow("Diagnosis", data['diagnosis']),
                        _buildDetailRow("Prescription", data['prescription']),
                        _buildDetailRow("Referrals", data['referrals']),
                        const SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => doc.reference.delete(),
                            icon: const Icon(Icons.delete_forever, color: Colors.red),
                            label: const Text("Delete Record", style: TextStyle(color: Colors.red)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 15),
          children: [
            TextSpan(text: "$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value ?? "N/A"),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: _primaryBurgundy, size: 28),
        const SizedBox(width: 10),
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _primaryBurgundy)),
      ],
    );
  }

  Widget _buildInputForm() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _clientNameController, decoration: const InputDecoration(labelText: 'Client Name')),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryBurgundy,
                      side: BorderSide(color: _primaryBurgundy),
                    ),
                    onPressed: () async {
                      final d = await _selectDate(context, _selectedAppointmentDate);
                      if (d != null) setState(() => _selectedAppointmentDate = d);
                    },
                    child: Text(_selectedAppointmentDate == null ? "Appt Date" : _selectedAppointmentDate!.toLocal().toString().split(' ')[0]),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryBurgundy,
                      side: BorderSide(color: _primaryBurgundy),
                    ),
                    onPressed: () async {
                      final t = await _selectTime(context);
                      if (t != null) setState(() => _selectedAppointmentTime = t);
                    },
                    child: Text(_selectedAppointmentTime == null ? "Appt Time" : _selectedAppointmentTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primaryBurgundy,
                  side: BorderSide(color: _primaryBurgundy),
                ),
                icon: const Icon(Icons.calendar_today),
                onPressed: () async {
                  final d = await _selectDate(context, _selectedOnsetDate);
                  if (d != null) setState(() => _selectedOnsetDate = d);
                },
                label: Text(_selectedOnsetDate == null ? "Symptom Onset Date" : "Onset: ${_selectedOnsetDate!.toLocal().toString().split(' ')[0]}"),
              ),
            ),
            TextField(controller: _testsController, decoration: const InputDecoration(labelText: 'Tests Administered')),
            TextField(controller: _diagnosisController, decoration: const InputDecoration(labelText: 'Diagnosis')),
            TextField(controller: _prescriptionController, decoration: const InputDecoration(labelText: 'Prescription')),
            TextField(controller: _referralsController, decoration: const InputDecoration(labelText: 'Referrals')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveRecordToFirebase,
              style: ElevatedButton.styleFrom(backgroundColor: _primaryBurgundy, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 50)),
              child: const Text("SAVE TO FIREBASE", style: TextStyle(fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }
}