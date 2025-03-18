import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class HospitalsTableScreen extends StatelessWidget {
  final List<Map<String, dynamic>> hospitalData;

  const HospitalsTableScreen({Key? key, required this.hospitalData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final HospitalsDataSource hospitalsDataSource =
        HospitalsDataSource(hospitalData);
    return Scaffold(
      body: SfDataGrid(
        source: hospitalsDataSource,
        columnWidthMode: ColumnWidthMode.fill,
        columns: [
          GridColumn(columnName: 'name', label: Center(child: Text('Name'))),
          GridColumn(columnName: 'email', label: Center(child: Text('Email'))),
          GridColumn(columnName: 'phone', label: Center(child: Text('Phone'))),
          GridColumn(
              columnName: 'currentLocation',
              label: Center(child: Text('Location'))),
          GridColumn(columnName: 'dayes', label: Center(child: Text('Days'))),
          GridColumn(
              columnName: 'openingTime',
              label: Center(child: Text('Opening Time'))),
          GridColumn(
              columnName: 'closingTime',
              label: Center(child: Text('Closing Time'))),
          GridColumn(
              columnName: 'docsFile', label: Center(child: Text('Documents'))),
          GridColumn(
              columnName: 'primaryContactPerson',
              label: Center(child: Text('Primary Contact'))),
          GridColumn(
              columnName: 'status', label: Center(child: Text('Status'))),
          GridColumn(
              columnName: 'actions', label: Center(child: Text('Actions'))),
        ],
      ),
    );
  }
}

class HospitalsDataSource extends DataGridSource {
  List<DataGridRow> _hospitalsData = [];

  HospitalsDataSource(List<Map<String, dynamic>> hospitals) {
    _hospitalsData = hospitals
        .map<DataGridRow>((hospital) => DataGridRow(cells: [
              DataGridCell<String>(columnName: 'name', value: hospital['name']),
              DataGridCell<String>(
                  columnName: 'email', value: hospital['email']),
              DataGridCell<String>(
                  columnName: 'phone', value: hospital['phone']),
              DataGridCell<String>(
                  columnName: 'currentLocation',
                  value: hospital['currentLocation']),
              DataGridCell<String>(
                  columnName: 'dayes', value: hospital['dayes']),
              DataGridCell<String>(
                  columnName: 'openingTime', value: hospital['openingTime']),
              DataGridCell<String>(
                  columnName: 'closingTime', value: hospital['closingTime']),
              DataGridCell<String>(
                  columnName: 'docsFile', value: hospital['docsFile']),
              DataGridCell<String>(
                  columnName: 'primaryContactPerson',
                  value: hospital['primaryContactPerson']),
              DataGridCell<String>(
                  columnName: 'status', value: hospital['status']),
              DataGridCell(columnName: 'actions', value: hospital),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _hospitalsData;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataCell) {
        if (dataCell.columnName == 'actions') {
          final hospital = dataCell.value as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: PopupMenuButton<String>(
              icon: Icon(Icons.more_vert),
              onSelected: (String value) {},
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Text('Delete'),
                  onTap: () async {
                    final supabase = Supabase.instance.client;
                    await supabase
                        .from("HospitalAuth")
                        .delete()
                        .eq("uId", hospital["uId"]);
                  },
                ),
                PopupMenuItem<String>(
                  value: 'view_appointments',
                  child: Text('View Appointments'),
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) =>
                            HospitalAppointmentsPage(hospital: hospital));
                  },
                ),
                PopupMenuItem<String>(
                  value: 'view_emergency_donations',
                  child: Text('View Emergency Donations'),
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) => Center(
                            child: EmergencyDonationsPage(hospital: hospital)));
                  },
                ),
                PopupMenuItem<String>(
                  value: 'view_medicines',
                  child: Text('View Medicines'),
                  onTap: () {
                    showModalBottomSheet(
                        context: context,
                        builder: (context) =>
                            Center(child: MedicinesPage(hospital: hospital)));

                    //   ),
                    // );
                  },
                ),
              ],
            ),
          );
        }
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(dataCell.value.toString()),
        );
      }).toList(),
    );
  }
}

class HospitalAppointmentsPage extends StatelessWidget {
  final Map<String, dynamic> hospital;
  const HospitalAppointmentsPage({required this.hospital});

  Future<List<Map<String, dynamic>>> _fetchAppointments() async {
    final supabase = Supabase.instance.client;

    // Fetch appointments and user data without .execute()
    final response = await supabase
        .from('hospital_appointment')
        .select()
        .eq('hospital_id', hospital['uId'])
        .limit(100) // Optional, adjust as needed
        .then((data) => data)
        .catchError((error) {
      throw Exception('Error fetching appointments: $error');
    });

    if (response == null || response.isEmpty) {
      throw Exception('No appointments found');
    }

    // Fetch user names
    final appointments = await Future.wait(response.map((appointment) async {
      final userResponse = await supabase
          .from('UserAuth')
          .select('user_full_name')
          .eq('uId', appointment['user_id'])
          .single()
          .then((userData) => userData)
          .catchError((error) {
        throw Exception('Error fetching user name: $error');
      });

      final userName = userResponse?['user_full_name'] ?? 'Unknown';
      return {
        'user_full_name': userName,
        'title': appointment['title'],
        'status': appointment['status'],
        'unit': appointment['unit'],
        'time': appointment['time'],
        'day': appointment['day'],
        'reason': appointment['reason'],
      };
    }).toList());

    return appointments;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Appointments for ${hospital['name']}")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No appointments found.'));
          }

          final appointments = snapshot.data!;
          return SfDataGrid(
            source: AppointmentDataSource(appointments),
            columnWidthMode: ColumnWidthMode.fill,
            columns: [
              GridColumn(
                  columnName: 'user_full_name',
                  label: Center(child: Text('User Name'))),
              GridColumn(
                  columnName: 'title', label: Center(child: Text('Title'))),
              GridColumn(
                  columnName: 'status', label: Center(child: Text('Status'))),
              GridColumn(
                  columnName: 'unit', label: Center(child: Text('Unit'))),
              GridColumn(
                  columnName: 'time', label: Center(child: Text('Time'))),
              GridColumn(columnName: 'day', label: Center(child: Text('Day'))),
              GridColumn(
                  columnName: 'reason', label: Center(child: Text('Reason'))),
            ],
          );
        },
      ),
    );
  }
}

class AppointmentDataSource extends DataGridSource {
  final List<Map<String, dynamic>> appointments;
  AppointmentDataSource(this.appointments);

  @override
  List<DataGridRow> get rows => appointments
      .map<DataGridRow>((appointment) => DataGridRow(cells: [
            DataGridCell<String>(
                columnName: 'user_full_name',
                value: appointment['user_full_name']),
            DataGridCell<String>(
                columnName: 'title', value: appointment['title']),
            DataGridCell<String>(
                columnName: 'status', value: appointment['status']),
            DataGridCell<String>(
                columnName: 'unit', value: appointment['unit'].toString()),
            DataGridCell<String>(
                columnName: 'time', value: appointment['time']),
            DataGridCell<String>(columnName: 'day', value: appointment['day']),
            DataGridCell<String>(
                columnName: 'reason', value: appointment['reason']),
          ]))
      .toList();

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataCell) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(dataCell.value.toString()),
        );
      }).toList(),
    );
  }
}

class EmergencyDonationsPage extends StatelessWidget {
  final Map<String, dynamic> hospital;
  const EmergencyDonationsPage({required this.hospital});

  Future<List<Map<String, dynamic>>> _fetchEmergencyDonations() async {
    final supabase = Supabase.instance.client;

    // Fetch emergency donations and join with the UserAuth table using the correct column `uId` for the user
    final response = await supabase
        .from('emergency_donation') // The table storing donation data
        .select(
            'user_uid, point, blood_bags_count, UserAuth(user_full_name)') // Join with UserAuth to get user_full_name
        .eq('hospital_uid', hospital['uId']) // Filter by hospital ID
        .limit(100); // Optional: Limit the number of records

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchEmergencyDonations(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No emergency donations found.'));
          }

          final emergencyDonations = snapshot.data!;
          print(emergencyDonations);
          return SfDataGrid(
            source: EmergencyDonationDataSource(emergencyDonations),
            columnWidthMode: ColumnWidthMode.fill,
            columns: [
              GridColumn(
                  columnName: 'user_full_name',
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Donor Name'),
                  ),
                  width: 150),
              GridColumn(
                  columnName: 'point',
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Point'),
                  ),
                  width: 100),
              GridColumn(
                  columnName: 'blood_bags_count',
                  label: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Blood Bags Count'),
                  ),
                  width: 150),
            ],
          );
        },
      ),
    );
  }
}

class EmergencyDonationDataSource extends DataGridSource {
  final List<Map<String, dynamic>> emergencyDonations;
  EmergencyDonationDataSource(this.emergencyDonations);

  @override
  List<DataGridRow> get rows => emergencyDonations
      .map<DataGridRow>((donation) => DataGridRow(cells: [
            DataGridCell<String>(
                columnName: 'user_full_name',
                value: donation['UserAuth']['user_full_name'] ??
                    'Ndd/A'), // Fetch user_full_name correctly
            DataGridCell<String>(
                columnName: 'point', value: donation['point'].toString()),
            DataGridCell<String>(
                columnName: 'blood_bags_count',
                value: donation['blood_bags_count'].toString()),
          ]))
      .toList();

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataCell) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(dataCell.value.toString()),
        );
      }).toList(),
    );
  }
}

class MedicinesPage extends StatelessWidget {
  final Map<String, dynamic> hospital;
  const MedicinesPage({required this.hospital});

  // Fetch medicines data from Supabase based on hospital's uId
  Future<List<Map<String, dynamic>>> _fetchMedicines() async {
    final supabase = Supabase.instance.client;

    // Fetch the medicines data filtered by uId (hospital's unique identifier)
    final response = await supabase
        .from('medicines')
        .select('name, points, quantity, description')
        .eq('uId', hospital['uId']); // Correct field name here (uId)

    // Debug: Print the response to check the data
    print('Medicines response: $response');

    // If the response has no data, throw an exception
    if (response.isEmpty) {
      throw Exception('No medicines found for this hospital.');
    }

    return List<Map<String, dynamic>>.from(response);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Medicines for ${hospital['name']}")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchMedicines(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No medicines found.'));
          }

          final medicines = snapshot.data!;

          return SfDataGrid(
            source: MedicinesDataSource(medicines),
            columnWidthMode: ColumnWidthMode.fill,
            columns: [
              GridColumn(
                  columnName: 'name', label: Center(child: Text('Medicine'))),
              GridColumn(
                  columnName: 'points', label: Center(child: Text('Points'))),
              GridColumn(
                  columnName: 'quantity',
                  label: Center(child: Text('Quantity'))),
              GridColumn(
                  columnName: 'description',
                  label: Center(child: Text('Description'))),
            ],
          );
        },
      ),
    );
  }
}

class MedicinesDataSource extends DataGridSource {
  final List<Map<String, dynamic>> medicines;
  MedicinesDataSource(this.medicines);

  @override
  List<DataGridRow> get rows => medicines
      .map<DataGridRow>((medicine) => DataGridRow(cells: [
            DataGridCell<String>(columnName: 'name', value: medicine['name']),
            DataGridCell<String>(
                columnName: 'points', value: medicine['points'].toString()),
            DataGridCell<String>(
                columnName: 'quantity', value: medicine['quantity'].toString()),
            DataGridCell<String>(
                columnName: 'description', value: medicine['description']),
          ]))
      .toList();

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataCell) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(dataCell.value.toString()),
        );
      }).toList(),
    );
  }
}
