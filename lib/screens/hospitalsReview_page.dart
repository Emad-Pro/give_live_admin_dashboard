import 'package:flutter/material.dart';
import 'package:give_live_admin_dashboard/screens/hospitalsReview_page.dart';
import 'package:give_live_admin_dashboard/screens/reviews_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HospitalsListPage extends StatefulWidget {
  @override
  _HospitalsListPageState createState() => _HospitalsListPageState();
}

class _HospitalsListPageState extends State<HospitalsListPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchHospitals() async {
    final response = await supabase.from('HospitalAuth').select('*');
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: fetchHospitals(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading hospitals"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No hospitals found"));
          }

          final hospitals = snapshot.data!;
          return ListView.builder(
            itemCount: hospitals.length,
            itemBuilder: (context, index) {
              final hospital = hospitals[index];
              return ListTile(
                title: Text(hospital['name']),
                subtitle:
                    Text(hospital['currentLocation'] ?? 'No location provided'),
                onTap: () {
                  print("Hospital selected: ${hospital['uId']}"); // Debugging

                  try {
                    String hospitalId =
                        hospital['uId'].toString(); // Ensure String
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                              contentPadding:
                                  EdgeInsets.all(0), // Remove default padding
                              content: Container(
                                width: MediaQuery.of(context).size.width *
                                    0.8, // Set width to 80% of screen width
                                child:
                                    HospitalReviewsPage(hospitalId: hospitalId),
                              ));
                        });
                  } catch (e) {
                    print("Navigation Error: $e");
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
