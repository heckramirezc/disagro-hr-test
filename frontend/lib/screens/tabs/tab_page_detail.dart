import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/page_provider.dart';
import '../../models/page_models.dart';

const List<Map<String, String>> availableLangs = [
  {'name': 'Inglés (en)', 'value': 'en'},
  {'name': 'Español (es)', 'value': 'es'},
];

class PageDetailTab extends StatefulWidget {
  const PageDetailTab({super.key});

  @override
  State<PageDetailTab> createState() => _PageDetailTabState();
}

class _PageDetailTabState extends State<PageDetailTab> {
  final TextEditingController _titleController = TextEditingController(text: 'dia_de_ano_nuevo');
  
  DateTime _dateFrom = DateTime.parse('2023-12-26');
  DateTime _dateTo = DateTime.parse('2024-01-01');

  String _selectedLangGroup = availableLangs.first['value']!;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSeries();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _fetchSeries() {
    String title = _titleController.text.trim().replaceAll(' ', '_');
    
    final dateFromString = _formatDate(_dateFrom);
    final dateToString = _formatDate(_dateTo);
    
    final langString = _selectedLangGroup;
    
    if (title.isNotEmpty && langString.isNotEmpty) {
      Provider.of<PageProvider>(context, listen: false).loadPageSeries(
        title: title,
        dateFrom: dateFromString,
        dateTo: dateToString,
        lang: langString,
      );
    }
  }
  
  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final initialDate = isFrom ? _dateFrom : _dateTo;
    final firstDate = DateTime(2007); 
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
              primary: Theme.of(context).colorScheme.primary, 
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
    final pageProvider = context.watch<PageProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final data = pageProvider.pageSeries;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalle de métricas por página', 
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          _buildSearchForm(context),
          const SizedBox(height: 30),

          if (pageProvider.isLoadingSeries)
            Center(child: CircularProgressIndicator(color: colorScheme.primary))
          else if (data != null && data.items.isNotEmpty)
            _buildSeriesTable(context, data)
          else
            _buildEmptyState(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildSearchForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    controller: _titleController,
                    label: 'Título de Página (ej: disagro_test)',
                    icon: Icons.title,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: _buildLangDropdown(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                _buildDateSelector(true, 'Fecha Inicio'),
                const SizedBox(width: 16),
                _buildDateSelector(false, 'Fecha Fin'),
              ],
            ),
            
            const SizedBox(height: 20),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _fetchSeries,
                icon: const Icon(Icons.search),
                label: const Text('Buscar Serie', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }
  
  Widget _buildLangDropdown(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Idiomas',
        prefixIcon: const Icon(Icons.language, size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      ),
      value: _selectedLangGroup,
      items: availableLangs.map((lang) {
        return DropdownMenuItem<String>(
          value: lang['value'],
          child: Text(lang['name']!),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedLangGroup = newValue;
          });
        }
      },
    );
  }


  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.query_builder, size: 80, color: colorScheme.secondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'Consulta la Serie Temporal',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa el título de la página, el idioma y el rango de fechas para ver su historial de vistas.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSeriesTable(BuildContext context, PaginatedResponse<SeriesItem> data) {
    final colorScheme = Theme.of(context).colorScheme;

    final selectedLangName = availableLangs.firstWhere((e) => e['value'] == _selectedLangGroup)['name'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Serie para: ${_titleController.text} (${_formatDate(_dateFrom)} a ${_formatDate(_dateTo)}) - Idiomas: $selectedLangName',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: 30,
              dataRowMinHeight: 50,
              dataRowMaxHeight: 60,
              headingRowColor: MaterialStateProperty.resolveWith((states) => colorScheme.background),
              dataTextStyle: Theme.of(context).textTheme.bodyMedium,
              
              columns: [
                DataColumn(label: Text('Día', style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.onSurface))),
                DataColumn(label: Text('Vistas diarias', style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.onSurface), textAlign: TextAlign.right), numeric: true),
                DataColumn(label: Text('AVG 7 días', style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.onSurface))),
                DataColumn(label: Text('Trend Score', style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.onSurface))),
              ],

              rows: data.items.asMap().entries.map((entry) {
                int index = entry.key;
                SeriesItem item = entry.value;

                final isEven = index % 2 == 0;
                final rowColorProperty = MaterialStateProperty.resolveWith<Color?>(
                  (Set<MaterialState> states) {
                    if (states.contains(MaterialState.selected)) {
                      return Theme.of(context).colorScheme.primary.withOpacity(0.1); 
                    }
                    if (isEven) {
                      return colorScheme.surface; 
                    }
                    return colorScheme.background.withOpacity(0.5); 
                  },
                );
                
                final baseRow = DataRow(
                  cells: [
                    DataCell(Text(item.day, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary))),
                    DataCell(Text(item.viewsTotal.toString(), textAlign: TextAlign.right)),
                    DataCell(Text(item.avg7Day.toStringAsFixed(0))),
                    DataCell(Text(item.trendScore.toStringAsFixed(2))),
                  ],
                );
                
                return DataRow(
                  color: rowColorProperty, 
                  cells: baseRow.cells,
                  onSelectChanged: baseRow.onSelectChanged,
                  selected: baseRow.selected,
                );

              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
