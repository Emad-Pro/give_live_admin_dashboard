import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalsAdminPage extends StatefulWidget {
  @override
  _HospitalsAdminPageState createState() => _HospitalsAdminPageState();
}

class _HospitalsAdminPageState extends State<HospitalsAdminPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<dynamic>> fetchPendingHospitals() async {
    final response = await supabase
        .from('HospitalAuth')
        .select('*')
        .eq('status', 'isPending');
    return response;
  }

  Future<void> updateHospitalStatus(String id, String status) async {
    await supabase
        .from('HospitalAuth')
        .update({'status': status}).eq('uId', id);
    setState(() {}); // Refresh the UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hospital Applications')),
      body: FutureBuilder<List<dynamic>>(
        future: fetchPendingHospitals(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final hospitals = snapshot.data ?? [];
          if (hospitals.isEmpty) {
            return Center(child: Text('No pending applications.'));
          }
          return ListView.builder(
            itemCount: hospitals.length,
            itemBuilder: (context, index) {
              final hospital = hospitals[index];

              // Handle docsFile as a String or List
              final docs = hospital['docsFile'];
              List<String> docUrls = docs is List
                  ? docs.cast<String>()
                  : docs != null
                      ? [docs]
                      : [];

              return Card(
                margin: EdgeInsets.all(10),
                child: ListTile(
                  title: Text(hospital['name'] ?? 'No Name'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${hospital['email'] ?? 'N/A'}'),
                      Text('Phone: ${hospital['phone'] ?? 'N/A'}'),
                      Text('Address: ${hospital['currentLocation'] ?? 'N/A'}'),
                      if (docUrls.isNotEmpty)
                        Column(
                          children: List.generate(
                            docUrls.length,
                            (i) => TextButton(
                              onPressed: () => launchURL(docUrls[i]),
                              child: Text('View Document ${i + 1}'),
                            ),
                          ),
                        ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.green),
                        onPressed: () =>
                            updateHospitalStatus(hospital['uId'], 'isApproved'),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.red),
                        onPressed: () =>
                            updateHospitalStatus(hospital['uId'], 'isRejected'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
