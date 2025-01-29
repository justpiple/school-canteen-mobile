import 'package:flutter/material.dart';

void showMessageDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: title.toLowerCase() == 'success'
                      ? Colors.green[50]
                      : title.toLowerCase() == 'error'
                          ? Colors.red[50]
                          : Colors.orange[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
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
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: title.toLowerCase() == 'success'
                        ? Colors.green[800]
                        : title.toLowerCase() == 'error'
                            ? Colors.red[800]
                            : Colors.orange[800],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
