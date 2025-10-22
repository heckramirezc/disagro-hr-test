import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/etl_provider.dart';
import '../../providers/page_provider.dart';

const List<Map<String, String>> availableLangs = [
  {'name': 'Español e Inglés', 'value': 'es,en'},
  {'name': 'Inglés (en)', 'value': 'en'},
  {'name': 'Español (es)', 'value': 'es'},
];

class EtlAdminTab extends StatefulWidget {
  final VoidCallback onEtlCompleted;

  const EtlAdminTab({
    super.key,
    required this.onEtlCompleted,
  });

  @override
  State<EtlAdminTab> createState() => _EtlAdminTabState();
}

class _EtlAdminTabState extends State<EtlAdminTab> {
  DateTime _dateFrom = DateTime.parse('2024-01-01');
  DateTime _dateTo = DateTime.parse('2024-01-02');
  String _selectedLangs = availableLangs.first['value']!;

  @override
  void initState() {
    super.initState();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final initialDate = isFrom ? _dateFrom : _dateTo;
    final firstDate = DateTime(2020);
    final lastDate = DateTime.now().subtract(const Duration(days: 1)); 

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: isFrom ? 'Selecciona Fecha de Inicio' : 'Selecciona Fecha de Fin',
      confirmText: 'Seleccionar',
      cancelText: 'Cancelar',
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.secondary,
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isFrom) {
          _dateFrom = picked;
          if (_dateTo.isBefore(_dateFrom)) {
            _dateTo = _dateFrom; 
          }
        } else {
          _dateTo = picked;
          if (_dateFrom.isAfter(_dateTo)) {
            _dateFrom = _dateTo; 
          }
        }
      });
    }
  }

  Widget _buildDateSelector(bool isFrom, String label) {
    return Expanded(
      child: InkWell(
        onTap: () => _selectDate(context, isFrom),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(isFrom ? _dateFrom : _dateTo),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  Icon(
                    Icons.calendar_month_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startEtl() {
    final etlProvider = Provider.of<EtlProvider>(context, listen: false);
    final langs = _selectedLangs.split(',').map((s) => s.trim()).toList();
    
    etlProvider.startEtl(
      dateFrom: _formatDate(_dateFrom),
      dateTo: _formatDate(_dateTo),
      languages: langs,
    );
  }

  @override
  Widget build(BuildContext context) {
    final etlProvider = context.watch<EtlProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    context.select((EtlProvider p) {
      if (p.status == EtlStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Provider.of<PageProvider>(context, listen: false).loadRankings();
          widget.onEtlCompleted(); 
          p.reset(); 
        });
      }
    });

    final isRunning = etlProvider.status == EtlStatus.loading || etlProvider.status == EtlStatus.running;

    return Container(
      color: Colors.transparent, 
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Administración y Control de ETL', 
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configura los parámetros de fecha e idioma para iniciar una nueva ingesta de datos.', 
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const Divider(height: 40),

            Row(
              children: [
                _buildDateSelector(true, 'Desde'),
                const SizedBox(width: 16),
                _buildDateSelector(false, 'Hasta'),
              ],
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Idiomas',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                fillColor: colorScheme.surface,
                filled: true,
              ),
              value: _selectedLangs,
              items: availableLangs.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang['value'],
                  child: Text(lang['name']!),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLangs = newValue;
                  });
                }
              },
            ),
            
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isRunning ? null : _startEtl,
                icon: isRunning 
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator.adaptive(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.flash_on, color: Colors.white),
                label: Text(
                  isRunning ? 'ETL en curso...' : 'Iniciar ETL',
                  style: const TextStyle(
                    fontSize: 17, 
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                  shadowColor: colorScheme.secondary.withOpacity(0.4),
                ),
              ),
            ),
            
            const SizedBox(height: 40),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Estado actual del trabajo', 
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
                  const Divider(height: 20),
                  if (etlProvider.currentJob != null) ...[
                    _buildStatusRow('Job Id', etlProvider.currentJob!.jobId, isMonospace: true),
                    _buildStatusRow('Inicio', etlProvider.currentJob!.startTime),
                    _buildStatusRow('Fin', etlProvider.currentJob!.endTime ?? 'N/A'),
                    _buildStatusRow(
                      'Estado', 
                      etlProvider.currentJob!.status ==  'COMPLETED' ? 'FINALIZADO' : 'EN PROCESO', 
                      isStatus: true,
                      statusColor: etlProvider.currentJob!.status == 'COMPLETED' 
                          ? Colors.green.shade600 
                          : (etlProvider.currentJob!.status == 'RUNNING' ? Colors.orange.shade600 : Colors.red.shade600),
                    ),
                  ] else if (etlProvider.errorMessage.isNotEmpty) ...[
                    Text(
                      'Error: ${etlProvider.errorMessage}', 
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.red.shade700, 
                        fontWeight: FontWeight.bold
                      )
                    ),
                  ] else ...[
                    const Text('No hay trabajo ETL activo.')
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {bool isMonospace = false, bool isStatus = false, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value, 
              style: isStatus
                  ? Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: statusColor)
                  : TextStyle(fontFamily: isMonospace ? 'monospace' : null),
            ),
          ),
        ],
      ),
    );
  }
}
