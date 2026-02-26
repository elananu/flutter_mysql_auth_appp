import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  final String email;

  const Dashboard({Key? key, required this.email}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Map<String, dynamic>> medicines = [];

  String getTodayDate() {
    return DateFormat('M/d/yyyy').format(DateTime.now());
  }

  // ===================== PER-DOSE ADHERENCE =====================
  int get takenCount =>
      medicines.fold(0, (sum, m) => sum + (m["times"] as List).where((d) => d["status"] == "Taken").length);

  int get missedCount =>
      medicines.fold(0, (sum, m) => sum + (m["times"] as List).where((d) => d["status"] == "Missed").length);

  int get pendingCount =>
      medicines.fold(0, (sum, m) => sum + (m["times"] as List).where((d) => d["status"] == "Pending").length);

  int get totalDoses => medicines.fold(0, (sum, m) => sum + (m["times"] as List).length);

  double get adherenceRate {
    if (totalDoses == 0) return 0;
    return takenCount / totalDoses;
  }

  // ================= QUICK ACTION WIDGET =================
  Widget quickAction(IconData icon, String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 5),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          )
        ],
      ),
    );
  }

  // ================= ADD / EDIT DIALOG =================
  void showMedicineDialog({Map<String, dynamic>? medicine, int? index}) {
    TextEditingController nameController =
        TextEditingController(text: medicine?["name"] ?? "");

    TextEditingController dosageController =
        TextEditingController(text: medicine?["dosage"] ?? "");

    String selectedFrequency = medicine?["frequency"] ?? "Once Daily";

    List<TimeOfDay> selectedTimes = medicine != null
        ? (medicine["times"] as List)
            .map<TimeOfDay>((d) {
              final parts = d["time"].split(":");
              int hour = int.parse(parts[0]);
              int minute = int.parse(parts[1].split(" ")[0]);
              return TimeOfDay(hour: hour, minute: minute);
            })
            .toList()
        : [TimeOfDay.now()];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setDialogState) {
          List<TimeOfDay> defaultTimes = [
            const TimeOfDay(hour: 8, minute: 0),
            const TimeOfDay(hour: 14, minute: 0),
            const TimeOfDay(hour: 20, minute: 0),
          ];

          return AlertDialog(
            title: Text(medicine == null ? "Add Medicine" : "Edit Medicine"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration:
                        const InputDecoration(labelText: "Medicine Name"),
                  ),
                  TextField(
                    controller: dosageController,
                    decoration: const InputDecoration(labelText: "Dosage"),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedFrequency,
                    decoration:
                        const InputDecoration(labelText: "Frequency"),
                    items: ["Once Daily", "Twice Daily", "Thrice Daily"]
                        .map((freq) => DropdownMenuItem(
                              value: freq,
                              child: Text(freq),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedFrequency = value!;
                        if (value == "Once Daily") {
                          selectedTimes = [const TimeOfDay(hour: 8, minute: 0)];
                        } else if (value == "Twice Daily") {
                          selectedTimes = [
                            const TimeOfDay(hour: 8, minute: 0),
                            const TimeOfDay(hour: 20, minute: 0)
                          ];
                        } else if (value == "Thrice Daily") {
                          selectedTimes = defaultTimes;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Column(
                    children: selectedTimes.asMap().entries.map((entry) {
                      int idx = entry.key;
                      TimeOfDay t = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(246, 255, 255, 255)),
                          onPressed: () async {
                            TimeOfDay? picked = await showTimePicker(
                              context: context,
                              initialTime: t,
                            );
                            if (picked != null) {
                              setDialogState(() {
                                selectedTimes[idx] = picked;
                              });
                            }
                          },
                          child: Text(t.format(context)),
                        ),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty &&
                      dosageController.text.isNotEmpty) {
                    setState(() {
                      List<Map<String, String>> times = selectedTimes
                          .map((t) => {"time": t.format(context), "status": "Pending"})
                          .toList();

                      Map<String, dynamic> newMedicine = {
                        "name": nameController.text,
                        "dosage": dosageController.text,
                        "frequency": selectedFrequency,
                        "times": times,
                      };

                      if (medicine == null) {
                        medicines.add(newMedicine);
                      } else {
                        medicines[index!] = newMedicine;
                      }
                    });
                    Navigator.pop(context);
                  }
                },
                child: Text(medicine == null ? "Add" : "Update"),
              )
            ],
          );
        });
      },
    );
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton(
        onPressed: () => showMedicineDialog(),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Color.fromARGB(255, 53, 249, 249)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo, Color.fromARGB(255, 255, 255, 255)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hello, ${widget.email} 👋",
                    style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(
                    getTodayDate(),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // OVERVIEW
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8)
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Today's Overview",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(getTodayDate()),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(takenCount.toString(),
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold)),
                          const Text("Taken")
                        ],
                      ),
                      Column(
                        children: [
                          Text(missedCount.toString(),
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)),
                          const Text("Missed")
                        ],
                      ),
                      Column(
                        children: [
                          Text(pendingCount.toString(),
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold)),
                          const Text("Pending")
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text("Adherence Rate ${(adherenceRate * 100).toStringAsFixed(0)}%"),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: adherenceRate,
                    backgroundColor: Colors.grey.shade300,
                    color: Colors.indigo,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // MEDICINES LIST
            medicines.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("No medicines added yet"),
                  )
                : Column(
                    children: medicines.asMap().entries.map((entry) {
                      int index = entry.key;
                      var med = entry.value;

                      return Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8)
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  med["name"],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => showMedicineDialog(
                                        medicine: med,
                                        index: index,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () {
                                        setState(() {
                                          medicines.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text("${med["dosage"]} • ${med["frequency"]}"),
                            const SizedBox(height: 8),

                            // ================= PER DOSE UI =================
                            Column(
                              children: (med["times"] as List).asMap().entries.map((entry) {
                                int idx = entry.key;
                                var dose = entry.value;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("${dose['time']}"),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                            onPressed: () {
                                              setState(() {
                                                dose['status'] = "Taken";
                                              });
                                            },
                                            child: const Text("Taken"),
                                          ),
                                          const SizedBox(width: 5),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                dose['status'] = "Missed";
                                              });
                                            },
                                            child: const Text("Missed"),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        dose['status'],
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: dose['status'] == "Taken"
                                              ? Colors.green
                                              : dose['status'] == "Missed"
                                                  ? Colors.red
                                                  : Colors.orange,
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),

            const SizedBox(height: 20),

            // ================= QUICK ACTIONS =================
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Quick Actions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.0,
                children: [
                  quickAction(Icons.camera_alt, "Scan Prescription", Colors.blue),
                  quickAction(Icons.history, "Medicine History", Colors.green),
                  quickAction(Icons.notifications, "Reminders", Colors.purple),
                  quickAction(Icons.warning, "SOS Alert", Colors.red),
                  quickAction(Icons.bar_chart, "Reports", Colors.orange),
                  quickAction(Icons.local_hospital, "Doctors", Colors.teal),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
