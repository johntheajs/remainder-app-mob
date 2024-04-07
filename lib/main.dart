import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

// Import User model and UserDAO
import 'models/user_model.dart';
import '../dao/user_dao.dart';
import 'models/reminder_model.dart'; // Import Movie model
import 'dao/reminder_dao.dart'; // Import MovieDAO
import '../helpers/database_helper.dart'; // Import DatabaseHelper
import 'package:intl/intl.dart';
import './helpers/database_helper.dart'; // Import your database helper
import 'package:flutter_local_notifications/flutter_local_notifications.dart';



void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder',
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoginMode = true;
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _reEnterPasswordController = TextEditingController();

  // Instantiate UserDAO
  final UserDao _userDAO = UserDao();
  int? _userId; // Temporary variable to store the logged-in user's ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _isLoginMode
                      ? _buildLoginForm()
                      : _buildSignupForm(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLoginForm() {
    return [
      Text(
        'Login',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _usernameController,
        decoration: InputDecoration(
          labelText: 'Username',
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Password',
        ),
      ),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          _performLogin();
        },
        child: Text('Login'),
      ),
      SizedBox(height: 16),
      TextButton(
        onPressed: () {
          setState(() {
            _isLoginMode = false;
          });
        },
        child: Text('Signup'),
      ),
    ];
  }

  List<Widget> _buildSignupForm() {
    return [
      Text(
        'Signup',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _usernameController,
        decoration: InputDecoration(
          labelText: 'Username',
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Password',
        ),
      ),
      SizedBox(height: 16),
      TextFormField(
        controller: _reEnterPasswordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Re-enter Password',
        ),
      ),
      SizedBox(height: 16),
      ElevatedButton(
        onPressed: () {
          _performSignup();
        },
        child: Text('Signup'),
      ),
      SizedBox(height: 16),
      TextButton(
        onPressed: () {
          setState(() {
            _isLoginMode = true;
          });
        },
        child: Text('Login'),
      ),
    ];
  }

  Future<void> _performLogin() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    // Retrieve user from database by username
    User? user = await _userDAO.getUserByUsername(username);
    if (user != null && user.password == password) {
      // Store the logged-in user's ID
      _userId = user.id;
      // Navigate to MainPage if login successful
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainPage(userId: _userId!),
        ),
      );
    } else {
      // Show error message
      _showErrorMessage('Invalid username or password');
    }
  }

  Future<void> _performSignup() async {
    String username = _usernameController.text;
    String password = _passwordController.text;
    String reEnterPassword = _reEnterPasswordController.text;

    if (password != reEnterPassword) {
      // Show error message
      _showErrorMessage('Passwords do not match');
      return;
    }

    // Check if the username is already taken
    User? existingUser = await _userDAO.getUserByUsername(username);
    if (existingUser != null) {
      // Show error message
      _showErrorMessage('Username already exists');
      return;
    }

    // Insert new user into the database
    User newUser = User(username: username, password: password);
    await _userDAO.insertUser(newUser);

    // Navigate to LoginPage after successful signup
    setState(() {
      _isLoginMode = true;
    });
    _showSuccessMessage('Signup successful! Please login.');
  }

  void _showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}



class MainPage extends StatefulWidget {
  final int userId; // User ID passed from login page

  const MainPage({Key? key, required this.userId}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // void _logout() {
  //   // TODO: Implement logout functionality
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Remainder App'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Reminders'),
            Tab(text: 'All Reminders'),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Remainder App'),
            ),
            ListTile(
              title: Text('Reminders'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Navigate to ReminderPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReminderPage(userId: widget.userId),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
              title: Text('All Reminders'),
              onTap: () {
                Navigator.pop(context); // Close drawer
                // Navigate to AllRemindersPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AllRemindersPage(userId: widget.userId),
                  ),
                );
              },
            ),
            Divider(),
            ListTile(
                title: Text('Logout'),
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ReminderPage(userId: widget.userId),
          AllRemindersPage(userId: widget.userId),
        ],
      ),
    );
  }
}

class ReminderPage extends StatefulWidget {
  final int userId;

  const ReminderPage({Key? key, required this.userId}) : super(key: key);

  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  late TextEditingController _descriptionController;
  late FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _selectedDate = DateTime.now();
    _selectedTime = TimeOfDay.now();
    _descriptionController = TextEditingController();

    // Initialize FlutterLocalNotificationsPlugin
    _initializeNotifications();
  }

  void _initializeNotifications() {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminder'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text('Date'),
                subtitle: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null && picked != _selectedDate) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              ListTile(
                title: Text('Time'),
                subtitle: Text(_selectedTime.format(context)),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (picked != null && picked != _selectedTime) {
                    setState(() {
                      _selectedTime = picked;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Save reminder to database
                    Reminder reminder = Reminder(
                      userId: widget.userId,
                      title: _titleController.text,
                      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
                      time: _selectedTime.format(context),
                      description: _descriptionController.text,
                    );
                    ReminderDAO remaindao = ReminderDAO();
                    await remaindao.insertReminder(reminder);
                    // Show local notification
                    _showNotification(reminder);
                    // Clear form fields
                    _titleController.clear();
                    _descriptionController.clear();
                    setState(() {
                      _selectedDate = DateTime.now();
                      _selectedTime = TimeOfDay.now();
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reminder added successfully')),
                    );
                  }
                },
                child: Text('Add Reminder'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotification(Reminder reminder) async {
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Reminder',
      'Title: ${reminder.title}\nDate: ${reminder.date}\nTime: ${reminder.time}\nDescription: ${reminder.description}',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          // 'Channel for reminder notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }
}

class AllRemindersPage extends StatelessWidget {
  final int userId;
  final ReminderDAO reminderDAO = ReminderDAO(); // Initialize the ReminderDAO

  AllRemindersPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Reminders'),
      ),
      body: FutureBuilder<List<Reminder>>(
        future: reminderDAO.getRemindersByUserId(userId), // Use the ReminderDAO to fetch reminders
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No reminders found'));
          } else {
            List<Reminder> reminders = snapshot.data!;
            return ListView.builder(
              itemCount: reminders.length,
              itemBuilder: (context, index) {
                Reminder reminder = reminders[index];
                return GestureDetector(
                  onLongPress: () {
                    _showUpdateDialog(context, reminder);
                  },
                  child: ListTile(
                    title: Text(reminder.title),
                    subtitle: Text('${reminder.date} ${reminder.time}'),
                    onTap: () {
                      _showReminderDetails(context, reminder);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  // Function to show reminder details dialog
  void _showReminderDetails(BuildContext context, Reminder reminder) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(reminder.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Date: ${reminder.date}'),
              Text('Time: ${reminder.time}'),
              Text('Description: ${reminder.description}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                // Delete reminder and close dialog
                reminderDAO.deleteReminder(reminder.id!);
                Navigator.of(context).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Function to show update reminder dialog
  void _showUpdateDialog(BuildContext context, Reminder reminder) {
    TextEditingController titleController = TextEditingController(text: reminder.title);
    TextEditingController descriptionController = TextEditingController(text: reminder.description);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                reminder.title = titleController.text;
                reminder.description = descriptionController.text;
                await reminderDAO.updateReminder(reminder);
                Navigator.of(context).pop(); // Close dialog
                // You can add further actions or UI updates as needed after updating the reminder
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );
  }
}