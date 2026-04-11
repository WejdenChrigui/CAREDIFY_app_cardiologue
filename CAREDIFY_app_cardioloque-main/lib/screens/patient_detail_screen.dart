import 'package:app_cardiologue/models/patient.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_cardiologue/theme/app_theme.dart';
import 'package:app_cardiologue/utils/mock_data.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  late List<double> ecgData;

  @override
  void initState() {
    super.initState();
    ecgData = MockDataService.generateMockEcgData(200); // 200 points for mock
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on, color: AppTheme.primaryColor),
            onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Opening Geolocation Map...')));
            },
            tooltip: 'View Location',
          ),
           IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.primaryColor),
            onPressed: () {
              setState(() {
                ecgData = MockDataService.generateMockEcgData(200);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ECG Data Refreshed')));
            },
             tooltip: 'Refresh ECG',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient Info Block (White Block)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                     radius: 40,
                     backgroundImage: NetworkImage(widget.patient.imageUrl),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.patient.name,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.patient.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          'Status',
                          widget.patient.status,
                          widget.patient.status == 'Critical' ? AppTheme.dangerColor : AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          context,
                          'Joined',
                          widget.patient.dateCreated,
                          AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                       Expanded(
                        child: _buildInfoCard(
                          context,
                          'Records',
                          widget.patient.recordsCount.toString(),
                           AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // ECG Historical Block
            Text(
              'ECG History',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
             Container(
              height: 250,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Stack(
                children: [
                   // Grid background for ECG
                   CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: EcgGridPainter(),
                  ),
                  LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: ecgData.length.toDouble() - 1,
                    minY: -1.5, // Adjus min/max to fit your mock data
                    maxY: 1.5,
                    lineBarsData: [
                      LineChartBarData(
                        spots: ecgData.asMap().entries.map((e) {
                          return FlSpot(e.key.toDouble(), e.value);
                        }).toList(),
                        isCurved: true,
                        color: AppTheme.dangerColor, // Red for ECG trace
                        barWidth: 2,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
                ]
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class EcgGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintThin = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..strokeWidth = 0.5;

    final paintThick = Paint()
      ..color = Colors.red.withOpacity(0.4)
      ..strokeWidth = 1.0;

    const double stepSize = 10.0;
    
    // Vertical lines
    for (double i = 0; i <= size.width; i += stepSize) {
      if ((i / stepSize) % 5 == 0) {
        canvas.drawLine(Offset(i, 0), Offset(i, size.height), paintThick);
      } else {
        canvas.drawLine(Offset(i, 0), Offset(i, size.height), paintThin);
      }
    }

    // Horizontal lines
    for (double i = 0; i <= size.height; i += stepSize) {
      if ((i / stepSize) % 5 == 0) {
        canvas.drawLine(Offset(0, i), Offset(size.width, i), paintThick);
      } else {
        canvas.drawLine(Offset(0, i), Offset(size.width, i), paintThin);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
