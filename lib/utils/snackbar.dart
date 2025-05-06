import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String title, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: title.toLowerCase() == 'success'
          ? Colors.green[50]
          : title.toLowerCase() == 'error'
              ? Colors.red[50]
              : Colors.orange[50],
      content: Row(
        children: [
          Icon(
            title.toLowerCase() == 'success'
                ? Icons.check_circle
                : title.toLowerCase() == 'error'
                    ? Icons.error
                    : Icons.warning,
            color: title.toLowerCase() == 'success'
                ? Colors.green[800]
                : title.toLowerCase() == 'error'
                    ? Colors.red[800]
                    : Colors.orange[800],
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: title.toLowerCase() == 'success'
                        ? Colors.green[800]
                        : title.toLowerCase() == 'error'
                            ? Colors.red[800]
                            : Colors.orange[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 4),
      action: SnackBarAction(
        label: 'DISMISS',
        textColor: title.toLowerCase() == 'success'
            ? Colors.green[800]
            : title.toLowerCase() == 'error'
                ? Colors.red[800]
                : Colors.orange[800],
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    ),
  );
}
