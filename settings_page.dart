import 'package:flutter/material.dart';
import 'login_page.dart';

class SettingsPage extends StatefulWidget {
  final String email;
  const SettingsPage({Key? key, required this.email}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController nameController = TextEditingController(text: "Full Name");
  TextEditingController phoneController = TextEditingController(text: "+91 9876543210");
  TextEditingController bloodGroupController = TextEditingController(text: "A+");

  bool isEditingName = false;
  bool isEditingPhone = false;

  bool reminderSound = true;
  bool voiceReminder = false;
  String notificationTiming = "5 mins before";
  String language = "English";

  List<String> notificationOptions = ["5 mins before", "10 mins before", "15 mins before"];
  List<String> languageOptions = ["English", "Tamil"];
  List<String> bloodGroupOptions = ["A+", "A-", "B+", "B-", "O+", "O-", "AB+", "AB-"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ===== User Info =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name Field
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: "Full Name",
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            enabled: isEditingName,
                          ),
                        ),
                        IconButton(
                          icon: Icon(isEditingName ? Icons.check : Icons.edit),
                          onPressed: () {
                            setState(() {
                              // Toggle edit mode
                              isEditingName = !isEditingName;
                            });
                          },
                        ),
                      ],
                    ),
                    // Phone Field
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              labelText: "Phone Number",
                              border: InputBorder.none,
                            ),
                            keyboardType: TextInputType.phone,
                            enabled: isEditingPhone,
                          ),
                        ),
                        IconButton(
                          icon: Icon(isEditingPhone ? Icons.check : Icons.edit),
                          onPressed: () {
                            setState(() {
                              // Toggle edit mode
                              isEditingPhone = !isEditingPhone;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(widget.email, style: TextStyle(color: Colors.grey[700])),
                    const SizedBox(height: 10),
                    // Blood Group Dropdown
                    Row(
                      children: [
                        const Text("Blood Group: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 10),
                        DropdownButton<String>(
                          value: bloodGroupController.text,
                          items: bloodGroupOptions
                              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: (val) => setState(() => bloodGroupController.text = val!),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ===== Save Profile Button =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Save the profile changes (name, phone, blood group)
                    // Here you can integrate with your backend/db

                    // Reset edit modes
                    setState(() {
                      isEditingName = false;
                      isEditingPhone = false;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Profile saved successfully!")),
                    );
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Save Profile"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ===== Notification Settings =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Notifications", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SwitchListTile(
                      title: const Text("Reminder Sound"),
                      value: reminderSound,
                      onChanged: (val) => setState(() => reminderSound = val),
                    ),
                    SwitchListTile(
                      title: const Text("Voice Reminder"),
                      value: voiceReminder,
                      onChanged: (val) => setState(() => voiceReminder = val),
                    ),
                    const SizedBox(height: 10),
                    const Text("Notification Timing"),
                    DropdownButton<String>(
                      value: notificationTiming,
                      items: notificationOptions
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => notificationTiming = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ===== Language =====
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Language", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    DropdownButton<String>(
                      value: language,
                      items: languageOptions
                          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (val) => setState(() => language = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // ===== Logout =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => LoginPage()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
