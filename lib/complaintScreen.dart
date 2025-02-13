import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:gallery/auth/loginApi.dart';
import 'package:gallery/ipaddress_page.dart';

class ComplaintScreen extends StatefulWidget {
  const ComplaintScreen({super.key});

  @override
  _ComplaintScreenState createState() => _ComplaintScreenState();
}

class _ComplaintScreenState extends State<ComplaintScreen> {
  final TextEditingController _complaintController = TextEditingController();
  List<Map<String, dynamic>> _complaints = []; // Stores previous complaints

  Future<void> _submitComplaint() async {
    if (_complaintController.text.isNotEmpty) {
      try {
        final response = await Dio().post(
          '$baseurl/submit_complaint',
          queryParameters: {
            "complaint": _complaintController.text.trim(),
            "user_id": lid
          },
        );

        if (response.statusCode == 201) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Complaint sent successfully"),
              backgroundColor: Colors.green,
            ),
          );

          _complaintController.clear(); // Clear input field
          _getComplaints(); // Refresh complaints list
        }
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to send complaint: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // If the field is empty, show a warning message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a complaint"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _getComplaints() async {
    try {
      final response = await Dio().get(
        '$baseurl/complaints',
        queryParameters: {"id": lid},
      );

      if (response.statusCode == 200) {
        setState(() {
          _complaints = List<Map<String, dynamic>>.from(response.data);
        });
      }
    } catch (e) {
      print("Error fetching complaints: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _getComplaints(); // Fetch complaints on screen load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Complaint'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Complaint Input Field
              TextField(
                controller: _complaintController,
                decoration: const InputDecoration(
                  labelText: 'Enter your complaint',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _submitComplaint,
                  child: const Text('Submit Complaint'),
                ),
              ),
              const SizedBox(height: 20),

              // Previous Complaints Title
              const Text(
                'Previous Complaints:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              // ListView to display complaints
              Expanded(
                child: _complaints.isEmpty
                    ? const Center(
                        child: Text(
                          "No complaints submitted yet.",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _complaints.length,
                        itemBuilder: (context, index) {
                          bool hasReply = _complaints[index]['replay'] != null;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text('Complaint: ${_complaints[index]['complaint']}'),
                              tileColor: hasReply ? Colors.lightBlue[100] : Colors.lightGreen[200], // Light blue if has reply, light green if no reply
                              subtitle: Text(
                                'Reply: ${_complaints[index]['replay'] ?? 'No reply yet'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: hasReply ? Colors.blue[900] : Colors.green[900], // Darker text for visibility
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
