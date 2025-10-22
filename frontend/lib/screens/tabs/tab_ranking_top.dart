import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/page_provider.dart';
import '../../models/page_models.dart';

const List<Map<String, String>> availableLangs = [
  {'name': 'Español (es)', 'value': 'es'},
  {'name': 'Inglés (en)', 'value': 'en'},
];

class RankingTopTab extends StatefulWidget {
  const RankingTopTab({super.key});

  @override
  State<RankingTopTab> createState() => _RankingTopTabState();
}

class _RankingTopTabState extends State<RankingTopTab> {
  DateTime _selectedDate = DateTime.now().subtract(const Duration(days: 1));
  String _selectedLang = availableLangs.first['value']!;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFilter();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void _applyFilter() {
    final pageProvider = Provider.of<PageProvider>(context, listen: false);
    
    // pageProvider.loadRankings(
    //   date: _formatDate(_selectedDate),
    //   lang: _selectedLang,
    // );
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = _selectedDate;
    final firstDate = DateTime(2020); 
    final lastDate = DateTime.now().subtract(const Duration(days: 1));

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      helpText: 'Selecciona Fecha del Ranking',
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Widget _buildDateSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Fecha',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDate(_selectedDate),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.calendar_month_outlined,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLangDropdown(BuildContext context) {
    return Expanded(
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Idioma',
          prefixIcon: const Icon(Icons.language, size: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
        value: _selectedLang,
        items: availableLangs.map((lang) {
          return DropdownMenuItem<String>(
            value: lang['value'],
            child: Text(lang['name']!),
          );
        }).toList(),
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedLang = newValue;
            });
          }
        },
      ),
    );
  }

  Widget _buildFilterForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            _buildDateSelector(context),
            const SizedBox(width: 16),
            
            _buildLangDropdown(context),
            const SizedBox(width: 16),
            
            SizedBox(
              width: 150,
              height: 55, 
              child: ElevatedButton.icon(
                onPressed: _applyFilter,
                icon: const Icon(Icons.filter_list_outlined),
                label: const Text('Aplicar', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
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

  @override
  Widget build(BuildContext context) {
    final pageProvider = context.watch<PageProvider>();
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Top de Páginas por Vistas',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildFilterForm(context),
          
          if (pageProvider.isLoadingRankings)
            Center(child: CircularProgressIndicator(color: colorScheme.primary))
          else if (pageProvider.topRanking == null || pageProvider.topRanking!.items.isEmpty)
            _buildEmptyState(context, colorScheme)
          else
            buildRankingTable<TopPageItem>(
              context,
              pageProvider.topRanking!,
              [
                DataColumn(
                  label: Text('Rank', style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                ),
                DataColumn(
                  label: Text('Título', style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                ),
                DataColumn(
                  label: Text('Idioma', style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.onSurface)),
                ),
                DataColumn(
                  label: Text('Vistas Totales', style: TextStyle(fontWeight: FontWeight.w700, color: colorScheme.onSurface), textAlign: TextAlign.right),
                  numeric: true,
                ),
              ],
              (item, rank) => DataRow(
                cells: [
                  DataCell(Text('#$rank', style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary))),
                  DataCell(Text(item.title, style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(item.lang.toUpperCase())),
                  DataCell(Text(item.viewsTotal.toString(), textAlign: TextAlign.right)),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_outlined, size: 80, color: colorScheme.secondary.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              'No hay datos de ranking disponibles.',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Asegúrate de que el ETL se haya ejecutado para la fecha y el idioma seleccionados.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

Widget buildRankingTable<T>(
  BuildContext context,
  PaginatedResponse<T> data,
  List<DataColumn> columns,
  DataRow Function(T, int) buildRow,
) {
  final colorScheme = Theme.of(context).colorScheme;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Text(
          'Total de Resultados: ${data.total}', 
          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Colors.grey.shade600, fontWeight: FontWeight.w600),
        ),
      ),
      
      Card(
        elevation: 4, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            columnSpacing: 30, 
            dataRowMinHeight: 50, 
            dataRowMaxHeight: 60,
            headingRowColor: MaterialStateProperty.resolveWith((states) => colorScheme.background), 
            
            dataTextStyle: Theme.of(context).textTheme.bodyMedium,
            
            columns: columns,
            rows: data.items.asMap().entries.map((entry) {
              int index = entry.key;
              T item = entry.value;
              
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

              final baseRow = buildRow(item, index + 1);

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
      
      const SizedBox(height: 20),
      Center(
        child: Text(
          'Página 1 de ${(data.total / (data.items.isEmpty ? 1 : data.items.length)).ceil()} (Mostrando ${data.items.length} resultados)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
        ),
      )
    ],
  );
}
