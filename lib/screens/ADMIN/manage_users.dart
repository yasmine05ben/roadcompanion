import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '/widgets/DETAILS.dart';
import '/config.dart';
class ManageUsers extends StatefulWidget {
  @override
  _ManageUsersState createState() => _ManageUsersState();
}

class _ManageUsersState extends State<ManageUsers> {

  final String usersEndpoint = '/admin/gestionusers';
  final String createUserEndpoint = '/admin/gestionusers/createuser';
  final String completeProfileEndpoint = '/admin/gestionusers/complete-profile';

  List users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}$usersEndpoint'));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['success'] == true && data['users'] is List) {
        setState(() {
          users = data['users'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> deleteUser(String userId) async {
    final response = await http.delete(Uri.parse('${Config.baseUrl}$usersEndpoint/users/$userId'));
    if (response.statusCode == 200) fetchUsers();
  }

  void editUser(Map user) {
    final firstname = TextEditingController(text: user['firstname']);
    final lastname = TextEditingController(text: user['lastname']);
    final email = TextEditingController(text: user['email']);
    final phone = TextEditingController(text: user['phone']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("تعديل المستخدم"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: firstname, decoration: InputDecoration(labelText: "الاسم الأول")),
            TextField(controller: lastname, decoration: InputDecoration(labelText: "اللقب")),
            TextField(controller: email, decoration: InputDecoration(labelText: "البريد الإلكتروني")),
            TextField(controller: phone, decoration: InputDecoration(labelText: "رقم الهاتف")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("إلغاء")),
          TextButton(
            onPressed: () async {
              await http.put(
                Uri.parse('${Config.baseUrl}$usersEndpoint/users/${user['_id']}'),
                headers: {"Content-Type": "application/json"},
                body: json.encode({
                  'firstname': firstname.text,
                  'lastname': lastname.text,
                  'email': email.text,
                  'phone': phone.text,
                }),
              );
              fetchUsers();
              Navigator.pop(context);
            },
            child: Text("حفظ"),
          ),
        ],
      ),
    );
  }

  void addUser() {
    final firstname = TextEditingController();
    final lastname = TextEditingController();
    final email = TextEditingController();
    final phone = TextEditingController();
    final password = TextEditingController();
    final sex = TextEditingController();
    final role = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("إضافة مستخدم جديد"),
        content: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: firstname, decoration: InputDecoration(labelText: "الاسم الأول")),
                TextField(controller: lastname, decoration: InputDecoration(labelText: "اللقب")),
                TextField(controller: email, decoration: InputDecoration(labelText: "البريد الإلكتروني")),
                TextField(controller: phone, decoration: InputDecoration(labelText: "رقم الهاتف")),
                TextField(controller: password, decoration: InputDecoration(labelText: "كلمة المرور")),
                DropdownButtonFormField<String>(
                  value: sex.text.isNotEmpty ? sex.text : null,
                  items: ["ذكر", "أنثى"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (v) => setState(() => sex.text = v!),
                  decoration: InputDecoration(labelText: "الجنس"),
                ),
                DropdownButtonFormField<String>(
                  value: role.text.isNotEmpty ? role.text : null,
                  items: [
                    "مستخدم عادي",
                    "ميكانيكي",
                    "بائع قطع الغيار",
                    "عامل سحب السيارات"
                  ].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
                  onChanged: (v) => setState(() => role.text = v!),
                  decoration: InputDecoration(labelText: "الدور"),
                ),
              ],
            ),
          ),
        ),

        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("إلغاء")),
          TextButton(
            onPressed: () async {
              setState(() => isLoading = true);

              final createResp = await http.post(
                Uri.parse('${Config.baseUrl}$createUserEndpoint'),
                headers: {"Content-Type": "application/json"},
                body: json.encode({
                  'firstname': firstname.text,
                  'lastname': lastname.text,
                  'email': email.text,
                  'phone': phone.text,
                  'password': password.text,
                  'sex': sex.text,
                  'role': role.text,
                }),
              );

              if (createResp.statusCode == 200 || createResp.statusCode == 201) {
                final responseData = json.decode(createResp.body);

                if (responseData['success'] == true) {
                  if (role.text == "ميكانيكي" || role.text == "عامل سحب السيارات" || role.text == "بائع قطع الغيار") {
                    Navigator.pop(context); // Close the first form
                    _showProfileForm(role.text, email.text); // Show profile form
                  } else {
                    Navigator.pop(context); // Close and go back to user list
                    fetchUsers(); // Refresh the user list (you'll need to define this)
                  }
                } else {
                  setState(() => isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("خطأ في إضافة المستخدم")));
                }
              } else {
                setState(() => isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل في الاتصال بالخادم")));
              }
            },
            child: Text("إضافة"),
          ),
        ],
      ),
    );
  }

  void _showProfileForm(String role, String email) {
    final businessAddress = TextEditingController();
    final serviceArea = TextEditingController();
    final shopAddress = TextEditingController();
    final phonePro = TextEditingController();

    XFile? profilePhotoFile;
    XFile? commerceRegisterFile;
    XFile? carteIdentiteFile;

    final picker = ImagePicker();

    Future<void> pickImage(ImageSource src, void Function(XFile?) onPicked) async {
      final img = await picker.pickImage(source: src);
      onPicked(img);
      setState(() {});
    }

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text("إكمال الملف الشخصي"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                if (["ميكانيكي", "عامل سحب السيارات", "بائع قطع الغيار"].contains(role)) ...[
                  TextField(controller: phonePro, decoration: InputDecoration(labelText: "هاتف العمل")),
                  if (role == "ميكانيكي" || role == "عامل سحب السيارات")
                    TextField(controller: businessAddress, decoration: InputDecoration(labelText: "عنوان العمل")),
                  if (role == "عامل سحب السيارات")
                    TextField(controller: serviceArea, decoration: InputDecoration(labelText: "منطقة الخدمة")),
                  if (role == "بائع قطع الغيار")
                    TextField(controller: shopAddress, decoration: InputDecoration(labelText: "عنوان المتجر")),
                  ElevatedButton(
                    onPressed: () => pickImage(ImageSource.gallery, (f) => profilePhotoFile = f),
                    child: Text(profilePhotoFile == null ? "اختر صورة شخصية" : "✓ صورة شخصية مختارة"),
                  ),
                  ElevatedButton(
                    onPressed: () => pickImage(ImageSource.gallery, (f) => commerceRegisterFile = f),
                    child: Text(commerceRegisterFile == null ? "اختر سجل تجاري" : "✓ سجل تجاري"),
                  ),
                  ElevatedButton(
                    onPressed: () => pickImage(ImageSource.gallery, (f) => carteIdentiteFile = f),
                    child: Text(carteIdentiteFile == null ? "اختر صورة الهوية" : "✓ صورة الهوية"),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("إلغاء")),
            TextButton(
              onPressed: () async {
                final uri = Uri.parse('${Config.baseUrl}$completeProfileEndpoint');
                final req = http.MultipartRequest('POST', uri)
                  ..fields['email'] = email
                  ..fields['phonePro'] = phonePro.text;

                if (role == "ميكانيكي" || role == "عامل سحب السيارات") {
                  req.fields['businessAddress'] = businessAddress.text;
                }
                if (role == "عامل سحب السيارات") {
                  req.fields['serviceArea'] = serviceArea.text;
                }
                if (role == "بائع قطع الغيار") {
                  req.fields['shopAddress'] = shopAddress.text;
                }

                if (profilePhotoFile != null)
                  req.files.add(await http.MultipartFile.fromPath('profilePhoto', profilePhotoFile!.path));
                if (commerceRegisterFile != null)
                  req.files.add(await http.MultipartFile.fromPath('commerceRegister', commerceRegisterFile!.path));
                if (carteIdentiteFile != null)
                  req.files.add(await http.MultipartFile.fromPath('carteidentite', carteIdentiteFile!.path));

                final streamResp = await req.send();
                if (streamResp.statusCode != 200) {
                  print("Erreur complete-profile: ${streamResp.statusCode}");
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("فشل في تحديث البيانات")));
                }

                Navigator.pop(context);
                fetchUsers(); // Refresh user list after profile completion
              },
              child: Text("إتمام"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: CustomAppBar(
          title: "إدارة المستخدمين",
          imagePath: "assets/image300.png",
          textColor: Colors.black,
        ),
        body: Column(
          children: [
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : users.isEmpty
                  ? Center(child: Text("لا يوجد مستخدمون", style: TextStyle(fontSize: 18)))
                  : ListView.builder(
                itemCount: users.length,
                itemBuilder: (_, i) {
                  final u = users[i];
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("${u['firstname']} ${u['lastname']}",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                Text("البريد الإلكتروني: ${u['email']}"),
                                Text("رقم الهاتف: ${u['phone']}"),
                                if (u.containsKey('sex')) Text("الجنس: ${u['sex']}"),
                                if (u.containsKey('role')) Text("الدور: ${u['role']}"),
                              ],
                            ),
                          ),
                          IconButton(icon: Icon(Icons.edit), onPressed: () => editUser(u)),
                          IconButton(icon: Icon(Icons.delete), onPressed: () => deleteUser(u['_id'])),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: addUser,
                child: Text("إضافة مستخدم جديد"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
