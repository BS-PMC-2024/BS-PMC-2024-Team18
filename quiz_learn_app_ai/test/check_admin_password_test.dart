import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Define TestSignUpPage here
class TestSignUpPage extends StatefulWidget {
  // ignore: use_super_parameters
  const TestSignUpPage({Key? key}) : super(key: key);

  @override
  TestSignUpPageState createState() => TestSignUpPageState();
}

class TestSignUpPageState extends State<TestSignUpPage> {
  final TextEditingController adminPasswordController = TextEditingController();
  bool isAdminPasswordCorrect = false;
  String selectedUserType = 'Student';

  void checkAdminPassword() {
    if (adminPasswordController.text == "gilIsLove") {
      setState(() {
        isAdminPasswordCorrect = true;
        selectedUserType = 'Admin';
      });
    } else {
      setState(() {
        isAdminPasswordCorrect = false;
        selectedUserType = 'Student';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(); // Minimal implementation for testing
  }
}

void main() {
  testWidgets('checkAdminPassword sets correct state for correct password',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: TestSignUpPage()));

    final state = tester.state<TestSignUpPageState>(find.byType(TestSignUpPage));

    // Test correct admin password
    state.adminPasswordController.text = "gilIsLove";
    state.checkAdminPassword();
    await tester.pump();

    expect(state.isAdminPasswordCorrect, true);
    expect(state.selectedUserType, 'Admin');

    // Test incorrect admin password
    state.adminPasswordController.text = "wrongPassword";
    state.checkAdminPassword();
    await tester.pump();

    expect(state.isAdminPasswordCorrect, false);
    expect(state.selectedUserType, 'Student');
  });
}