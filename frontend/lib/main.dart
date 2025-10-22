import 'package:flutter/material.dart'; 
import 'package:provider/provider.dart';
import 'screens/dashboard_screen.dart';
import 'providers/page_provider.dart';
import 'providers/etl_provider.dart';
import 'services/api_service.dart';

void main() {
  runApp(const WikiMetricsApp());
}

class WikiMetricsApp extends StatelessWidget {
  const WikiMetricsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final apiService = ApiService(); 

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PageProvider(apiService)),
        ChangeNotifierProvider(create: (_) => EtlProvider(apiService)),
      ],
      child: MaterialApp(
        title: 'WikiMetrics',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'PTSans', 
          colorScheme: const ColorScheme.light(
            primary:  Color(0xFF3366FF),
            background:  Color(0xFFF7F9FC),
            surface: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              elevation: 0, 
            ),
          ),
          tabBarTheme: const TabBarThemeData(
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
            dividerColor: Colors.transparent,
          ),
          useMaterial3: true,
        ),
        home: const DashboardScreen(),
      ),
    );
  }
}
