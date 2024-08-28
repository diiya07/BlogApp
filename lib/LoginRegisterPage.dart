import 'package:flutter/material.dart';
import 'Authentication.dart';
import 'DialogBox.dart';

class LoginRegisterPage extends StatefulWidget {
  LoginRegisterPage({
    required this.auth,
    required this.onSignedIn,
  });
  final AuthImplementation auth;
  final VoidCallback onSignedIn;

  @override
  State<StatefulWidget> createState() => _LoginRegisterPageState();
}

enum FormType { login, register }

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  DialogBox dialogBox = new DialogBox();
  final formKey = GlobalKey<FormState>();
  FormType _formType = FormType.login;
  String _email = '';
  String _password = '';

  // Methods
  bool validateAndSave() {
    final form = formKey.currentState;
    if (form != null && form.validate()) {
      form.save();
      print('Email: $_email');
      print('Password: $_password');
      return true;
    } else {
      return false;
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          String userId = await widget.auth.signIn(_email, _password);
          // dialogBox.information(
          //     context, "Congrats!", "Access granted—you’re logged in");
          print("login userId = " + userId);
        } else {
          String userId = await widget.auth.signUp(_email, _password);
          // dialogBox.information(
          //     context, "Awesome!", "You’re in! Your account is now live");
          print("Register userId = " + userId);
        }
        widget.onSignedIn();
      } catch (e) {
        dialogBox.information(context, "Error", e.toString());
        print("Error: " + e.toString());
      }
    }
  }

  void moveToRegister() {
    formKey.currentState?.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState?.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  // Design
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blogify 📸'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: createInputs() + createButtons(),
          ),
        ),
      ),
    );
  }

  List<Widget> createInputs() {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: logo(),
      ),
      SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          decoration: InputDecoration(labelText: 'Email'),
          validator: (value) {
            return (value == null || value.isEmpty)
                ? 'Email is required'
                : null;
          },
          onSaved: (value) {
            _email = value ?? '';
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: TextFormField(
          decoration: InputDecoration(labelText: 'Password'),
          obscureText: true,
          validator: (value) {
            return (value == null || value.isEmpty)
                ? 'Password is required'
                : null;
          },
          onSaved: (value) {
            _password = value ?? '';
          },
        ),
      ),
      SizedBox(height: 20),
    ];
  }

  Widget logo() {
    return Hero(
      tag: 'hi',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 110.0,
        child: Image.asset('images/app_logo.png'),
      ),
    );
  }

  List<Widget> createButtons() {
    if (_formType == FormType.login) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: ElevatedButton(
            onPressed: validateAndSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade200,
            ),
            child: Text(
              'Login',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: TextButton(
            onPressed: moveToRegister,
            child: Text(
              'Not have an Account? Create Account?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ];
    } else {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: ElevatedButton(
            onPressed: validateAndSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange.shade200,
            ),
            child: Text(
              'Create Account',
              style: TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: TextButton(
            onPressed: moveToLogin,
            child: Text(
              'Already have an Account? Login?',
              style: TextStyle(
                fontSize: 14,
                color: Colors.red,
              ),
            ),
          ),
        ),
      ];
    }
  }
}
