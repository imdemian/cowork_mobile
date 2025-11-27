import 'package:flutter/material.dart';
import '../../../../models/user_model.dart';

class ClientListWidget extends StatelessWidget {
  final List<UserModel> clients;
  final VoidCallback onRefresh;

  const ClientListWidget({
    Key? key,
    required this.clients,
    required this.onRefresh,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: clients.length,
        itemBuilder: (context, index) {
          final client = clients[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(
                    client.displayName?.substring(0, 1).toUpperCase() ??
                        client.email.substring(0, 1).toUpperCase(),
                  ),
                ),
                title: Text(client.displayName ?? 'Sin nombre'),
                subtitle: Text(client.email),
                trailing: Chip(
                  label: Text(
                    client.emailVerified ? 'Verificado' : 'Pendiente',
                    style: TextStyle(
                      color: client.emailVerified
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
