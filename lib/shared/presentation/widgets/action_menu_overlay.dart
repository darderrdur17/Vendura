import 'package:flutter/material.dart';
import 'dart:ui';

class ActionMenuOverlay extends StatelessWidget {
  final VoidCallback onNewTicket;
  final VoidCallback onUpdateTicket;
  final VoidCallback onDeleteTicket;
  final VoidCallback onClose;

  const ActionMenuOverlay({
    Key? key,
    required this.onNewTicket,
    required this.onUpdateTicket,
    required this.onDeleteTicket,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blurred background
        Positioned.fill(
          child: GestureDetector(
            onTap: onClose,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0.3),
              ),
            ),
          ),
        ),
        // Menu content
        Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Choose Action',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _ActionButton(
                  icon: Icons.add_circle_outline,
                  label: 'New Ticket',
                  color: Colors.green,
                  onTap: () {
                    onClose();
                    onNewTicket();
                  },
                ),
                const SizedBox(height: 16),
                _ActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Update Ticket',
                  color: Colors.blue,
                  onTap: () {
                    onClose();
                    onUpdateTicket();
                  },
                ),
                const SizedBox(height: 16),
                _ActionButton(
                  icon: Icons.delete_outline,
                  label: 'Delete Ticket',
                  color: Colors.red,
                  onTap: () {
                    onClose();
                    onDeleteTicket();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}