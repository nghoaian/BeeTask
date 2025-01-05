import 'package:bee_task/bloc/account/account_bloc.dart';
import 'package:bee_task/bloc/account/account_event.dart';
import 'package:bee_task/bloc/account/account_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UpdateEmailScreen extends StatefulWidget {
  @override
  _UpdateEmailScreenState createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends State<UpdateEmailScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Update Email"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: BlocConsumer<AccountBloc, AccountState>(
          listener: (context, state) {
            if (state is UpdateEmailSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Email updated successfully!")),
              );
              Navigator.pop(context);
            } else if (state is UpdateEmailFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage)),
              );
            }
          },
          builder: (context, state) {
            if (state is AccountLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nhập email mới
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "New Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // Xác nhận email
                TextField(
                  controller: _confirmEmailController,
                  decoration: InputDecoration(
                    labelText: "Confirm Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final newEmail = _emailController.text.trim();
                    final confirmEmail = _confirmEmailController.text.trim();

                    if (newEmail.isEmpty || confirmEmail.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please fill in all fields.")),
                      );
                      return;
                    }

                    if (newEmail != confirmEmail) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Emails do not match.")),
                      );
                      return;
                    }

                    context
                        .read<AccountBloc>()
                        .add(UpdateEmailRequested(newEmail: newEmail));
                  },
                  child: Text("Update Email"),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
