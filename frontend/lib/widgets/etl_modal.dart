import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/etl_provider.dart';

const List<Map<String, String>> availableLangs = [
  {'name': 'Español e Inglés', 'value': 'es,en'},
  {'name': 'Inglés (en)', 'value': 'en'},
  {'name': 'Español (es)', 'value': 'es'},
];

class EtlForcedModal extends StatefulWidget {
  final VoidCallback onEtlStart; 

  const EtlForcedModal({
    super.key,
    required this.onEtlStart,
  });

  @override
  State<EtlForcedModal> createState() => _EtlForcedModalState();
}

class _EtlForcedModalState extends State<EtlForcedModal> {
  DateTime _dateFrom = DateTime.parse('2023-12-26'); 
  DateTime _dateTo = DateTime.parse('2024-01-01');
  
  String _selectedLangs = availableLangs.first['value']!;

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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildDateSelector(bool isFrom, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: () => _selectDate(context, isFrom),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ]
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
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Icon(
                    Icons.calendar_month_outlined,
                    color: colorScheme.primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final etlProvider = Provider.of<EtlProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    if (etlProvider.status == EtlStatus.running ||
        etlProvider.status == EtlStatus.loading) {
      return const SizedBox.shrink();
    }

    final isRunning = etlProvider.status == EtlStatus.loading || etlProvider.status == EtlStatus.running;


    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedOpacity(
            opacity: 1,
            duration: const Duration(milliseconds: 300),
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),

        Center(
          child: Material(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            elevation: 10,
            child: Container(
              width: 480,
              constraints: const BoxConstraints(maxWidth: 600),
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.speed_outlined,
                    size: 60,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '¡Bienvenido a WikiMetrics!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Para comenzar a visualizar los rankings, debes iniciar el proceso de extracción, transformación y carga (ETL).',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      _buildDateSelector(true, 'Desde'),
                      const SizedBox(width: 16), 
                      _buildDateSelector(false, 'Hasta'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Idiomas',
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

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: isRunning ? null : () {
                        etlProvider.startEtl(
                          dateFrom: _formatDate(_dateFrom),
                          dateTo: _formatDate(_dateTo),
                          languages: _selectedLangs.split(','),
                        );
                        
                        widget.onEtlStart();
                      },
                      icon: isRunning 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator.adaptive(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.start_outlined, color: Colors.white),
                      label: Text(
                        isRunning ? 'Iniciando ETL...' : 'Iniciar ETL',
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary, 
                        elevation: 6,
                      )
                    ),
                  ),
                  
                  const SizedBox(height: 10),

                  if (isRunning)
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        'El proceso puede tardar unos minutos.',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
