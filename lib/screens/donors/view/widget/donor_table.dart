import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

class DonorsTableScreen extends StatelessWidget {
  final List<Map<String, dynamic>> donorData;

  const DonorsTableScreen({
    super.key,
    required this.donorData,
  });

  @override
  Widget build(BuildContext context) {
    final DonorsDataSource donorsDataSource = DonorsDataSource(donorData);
    return Scaffold(
      body: SfDataGrid(
        source: donorsDataSource,
        columnWidthMode: ColumnWidthMode.fill,
        columns: [
          GridColumn(
            columnName: 'user_full_name',
            label: Center(
                child: Text('Name',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          GridColumn(
            columnName: 'user_email',
            label: Center(
                child: Text('Email',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          GridColumn(
            columnName: 'user_location_name',
            label: Center(
                child: Text('Location',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          GridColumn(
            columnName: 'user_phone',
            label: Center(
                child: Text('Phone',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          GridColumn(
            columnName: 'user_age',
            label: Center(
                child:
                    Text('Age', style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          GridColumn(
            columnName: 'user_weight',
            label: Center(
                child: Text('Weight',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          GridColumn(
            columnName: 'user_height',
            label: Center(
                child: Text('Height',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          GridColumn(
            columnName: 'user_gender',
            label: Center(
                child: Text('Gender',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          GridColumn(
            columnName: 'user_blood_type',
            label: Center(
                child: Text('Blood Type',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          GridColumn(
            columnName: 'user_last_dontaion',
            label: Center(
                child: Text('Last Donation',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          GridColumn(
            columnName: 'uId',
            label: Center(
                child: Text('User Id',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          GridColumn(
            columnName: 'profile_image',
            label: Center(
                child: Text('Profile Image',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          GridColumn(
            columnName: 'onesignal_id',
            label: Center(
                child: Text('Is Active',
                    style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          GridColumn(
            columnName: 'actions',
            label: Center(
              child: Text('Actions',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

// ************* Data Source *************
class DonorsDataSource extends DataGridSource {
  List<DataGridRow> _donorsData = [];

  DonorsDataSource(List<Map<String, dynamic>> donors) {
    _donorsData = donors
        .map<DataGridRow>((donor) => DataGridRow(cells: [
              DataGridCell<String>(
                  columnName: 'user_full_name', value: donor["user_full_name"]),
              DataGridCell<String>(
                  columnName: 'user_email', value: donor["user_email"]),
              DataGridCell<String>(
                  columnName: 'user_location_name',
                  value: donor["user_location_name"]),
              DataGridCell<String>(
                  columnName: 'user_phone', value: donor["user_phone"]),
              DataGridCell<String>(
                  columnName: 'user_age',
                  value: (DateTime.now().year -
                          DateTime.parse(donor["user_age"]).year)
                      .toString()),
              DataGridCell<double>(
                  columnName: 'user_weight', value: donor["user_weight"]),
              DataGridCell<double>(
                  columnName: 'user_height', value: donor["user_height"]),
              DataGridCell<String>(
                  columnName: 'user_gender', value: donor["user_gender"]),
              DataGridCell<String>(
                  columnName: 'user_blood_type',
                  value: donor["user_blood_type"]),
              DataGridCell<String>(
                  columnName: 'user_last_dontaion',
                  value: DateFormat.yMMMMEEEEd()
                      .format(DateTime.parse(donor["user_last_dontaion"]))),
              DataGridCell<String>(columnName: 'uId', value: donor["uId"]),
              DataGridCell<String>(
                  columnName: 'profile_image', value: donor["profile_image"]),
              DataGridCell<String>(
                  columnName: 'onesignal_id',
                  value: (donor["onesignal_id"] == null ||
                          donor["onesignal_id"] == "")
                      ? "Offline"
                      : "Active"),
              DataGridCell<Map<String, dynamic>>(
                  columnName: 'actions', value: donor),
            ]))
        .toList();
  }

  @override
  List<DataGridRow> get rows => _donorsData;

  @override
  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataCell) {
        if (dataCell.columnName == 'profile_image') {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircleAvatar(
              backgroundImage: NetworkImage(dataCell.value.toString()),
              onBackgroundImageError: (_, __) => Icon(Icons.person, size: 30),
            ),
          );
        } else if (dataCell.columnName == 'actions') {
          // ✅ إضافة زر القائمة الجانبية
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
                    final response = await supabase.auth.admin
                        .deleteUser(dataCell.value["uId"]);
                    supabase
                        .from("UserAuth")
                        .delete()
                        .eq("uId", dataCell.value["uId"])
                        .then((onValue) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "User ${dataCell.value['user_full_name']} has been deleted")));
                    }).catchError((onError) {});
                  },
                ),
                PopupMenuItem<String>(
                  onTap: () async {
                    final response = await Supabase.instance.client.auth.admin
                        .getUserById(dataCell.value["uId"]);

                    if (response!.user!.userMetadata!["is_banned"] == true) {
                      Supabase.instance.client.auth.admin.updateUserById(
                          dataCell.value["uId"],
                          attributes: AdminUserAttributes(
                              banDuration: "0h",
                              userMetadata: {"is_banned": false}));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "User ${dataCell.value['user_full_name']} has been unbanned")));
                    } else {
                      Supabase.instance.client.auth.admin.updateUserById(
                          dataCell.value["uId"],
                          attributes: AdminUserAttributes(
                              banDuration: "8760h",
                              userMetadata: {"is_banned": true}));
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              "User ${dataCell.value['user_full_name']} has been banned")));
                    }
                  },
                  value: 'Ban',
                  child: FutureBuilder(
                      future: Supabase.instance.client.auth.admin
                          .getUserById(dataCell.value["uId"]),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (snapshot.data!.user!.userMetadata!["is_banned"] ==
                              true) {
                            return Text('Unban');
                          } else {
                            return Text('Ban');
                          }
                        } else {
                          return CircularProgressIndicator();
                        }
                      }),
                ),
              ],
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              dataCell.value.toString(),
              style: TextStyle(fontSize: 14),
            ),
          );
        }
      }).toList(),
    );
  }
}
