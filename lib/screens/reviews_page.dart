import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HospitalReviewsPage extends StatefulWidget {
  final String hospitalId; // Ensure this is a String

  const HospitalReviewsPage({Key? key, required this.hospitalId})
      : super(key: key);

  @override
  _HospitalReviewsPageState createState() => _HospitalReviewsPageState();
}

class _HospitalReviewsPageState extends State<HospitalReviewsPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchReviews() async {
    try {
      final response = await supabase
          .from('Reviews_hospital')
          .select('*, UserAuth(user_full_name)')
          .eq('hospital_id', widget.hospitalId);

      print("Fetched reviews: $response");
      return response;
    } catch (e) {
      print("Error fetching reviews: $e");
      return [];
    }
  }

  Future<void> deleteReview(String reviewId) async {
    await supabase.from('Reviews_hospital').delete().eq('id', reviewId);
    setState(() {}); // Refresh the list after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Hospital Reviews")),
      body: FutureBuilder(
        future: fetchReviews(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading reviews"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No reviews found"));
          }

          final reviews = snapshot.data!;
          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              final donorName = review['UserAuth']?['user_full_name'] ??
                  'Unknown Donor'; // Get donor name

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(review['review'] ?? 'No content'),
                  subtitle: Text("By: $donorName"),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      deleteReview(review['id'].toString());
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
