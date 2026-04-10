import 'package:app_cardiologue/models/patient.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:app_cardiologue/theme/app_theme.dart';
import 'package:app_cardiologue/utils/api_service.dart';
import 'package:google_fonts/google_fonts.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  List<double> ecgData = [];
  bool _isLoadingEcg = true;

  @override
  void initState() {
    super.initState();
    _loadEcg();
  }

  Future<void> _loadEcg() async {
    setState(() => _isLoadingEcg = true);
    final data = await ApiService.fetchEcgData(widget.patient.id);
    setState(() {
      ecgData = data;
      _isLoadingEcg = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Détails du Patient'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            onPressed: () {
               _showToast('Localisation en cours...');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Patient Header Info
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2), width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(widget.patient.imageUrl),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppTheme.successColor,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: const Icon(Icons.check, color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    widget.patient.name,
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.patient.email,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Info Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          'État',
                          widget.patient.status,
                          widget.patient.status.toLowerCase().contains('danger') 
                              ? AppTheme.dangerColor 
                              : AppTheme.successColor,
                          Icons.favorite_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          'Dernière V.',
                          'Aujourd\'hui',
                          AppTheme.primaryColor,
                          Icons.visibility_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // ECG Block
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Historique ECG',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                IconButton(
                  onPressed: () => _loadEcg(),
                  icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryColor),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 280,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isLoadingEcg 
                ? const Center(child: CircularProgressIndicator())
                : ecgData.isEmpty 
                  ? const Center(child: Text('Aucune donnée ECG disponible'))
                  : Stack(
                children: [
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
                      minY: -1.5,
                      maxY: 1.5,
                      lineBarsData: [
                        LineChartBarData(
                          spots: ecgData.asMap().entries.map((e) {
                            return FlSpot(e.key.toDouble(), e.value);
                          }).toList(),
                          isCurved: true,
                          color: AppTheme.dangerColor,
                          barWidth: 2,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppTheme.dangerColor.withOpacity(0.05),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Action Button
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.document_scanner_rounded),
              label: const Text('Générer Rapport PDF'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w800,
            ),
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
      ..color = Colors.red.withOpacity(0.1)
      ..strokeWidth = 0.5;

    final paintThick = Paint()
      ..color = Colors.red.withOpacity(0.2)
      ..strokeWidth = 1.0;

    const double stepSize = 10.0;
    
    for (double i = 0; i <= size.width; i += stepSize) {
      if ((i / stepSize) % 5 == 0) {
        canvas.drawLine(Offset(i, 0), Offset(i, size.height), paintThick);
      } else {
        canvas.drawLine(Offset(i, 0), Offset(i, size.height), paintThin);
      }
    }

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

