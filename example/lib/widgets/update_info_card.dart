import 'package:flutter/material.dart';
import 'package:flutter_apk_updater/flutter_apk_updater.dart';

class UpdateInfoCard extends StatelessWidget {
  final UpdateInfo updateInfo;

  const UpdateInfoCard({
    super.key,
    required this.updateInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Update Info',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: updateInfo.hasUpdate ? Colors.orange : Colors.green,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    updateInfo.hasUpdate ? 'Update Tersedia' : 'Terbaru',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              'Versi Saat Ini',
              updateInfo.currentVersion,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Versi Terbaru',
              updateInfo.latestVersion,
              color: updateInfo.hasUpdate ? Colors.orange : Colors.green,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'APK File',
              updateInfo.asset.name,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              'Ukuran',
              '${(updateInfo.asset.size / (1024 * 1024)).toStringAsFixed(2)} MB',
            ),
            if (updateInfo.release.releaseNotes.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Release Notes:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  updateInfo.release.releaseNotes.isEmpty?'-':updateInfo.release.releaseNotes,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}