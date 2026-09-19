import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/metro_station.dart';
import '../../../../data/metro_data.dart';
import '../../../../core/utils/station_search.dart';

class StationSearchDialog extends StatefulWidget {
  const StationSearchDialog({super.key});

  @override
  State<StationSearchDialog> createState() => _StationSearchDialogState();
}

class _StationSearchDialogState extends State<StationSearchDialog> {
  final TextEditingController _searchController = TextEditingController();
  
  // 0: الكل, 1: الخط الأول, 2: الخط الثاني, 3: الخط الثالث
  int _selectedLineFilter = 0;
  List<MetroStation> _filteredStations = MetroData.stations;

  /// دالة تصفية المحطات بالدمج بين النص والخط المكتوب
  void _applyFilter() {
    final query = _searchController.text.trim();
    
    // 1. التصفية النصية أو جلب المحطات كافة
    List<MetroStation> searchResults = query.isEmpty 
        ? MetroData.stations 
        : StationSearch.search(query);

    // 2. التصفية حسب رقم الخط المحدد
    setState(() {
      if (_selectedLineFilter == 0) {
        _filteredStations = searchResults;
      } else {
        _filteredStations = searchResults
            .where((station) => station.lineIds.contains(_selectedLineFilter))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.75,
        child: Column(
          children: [
            // حقل البحث النصي
            TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilter(),
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'ابحث عن محطة...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.blue),
                filled: true,
                fillColor: const Color(0xFF2A2D34),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // أزرار فلترة الخطوط (Filter Chips)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _buildFilterChip(label: 'الخط الثالث (L3)', lineValue: 3),
                    const SizedBox(width: 6),
                  _buildFilterChip(label: 'الخط الثاني (L2)', lineValue: 2),
                  const SizedBox(width: 6),
                  _buildFilterChip(label: 'الخط الأول (L1)', lineValue: 1),
                  const SizedBox(width: 6),
                  _buildFilterChip(label: 'الكل', lineValue: 0),
                
                ],
              ),
            ),
            const SizedBox(height: 12),

            // قائمة عرض المحطات
            Expanded(
              child: _filteredStations.isEmpty
                  ? const Center(
                      child: Text(
                        'لا توجد محطات مطابقة للبحث',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredStations.length,
                      itemBuilder: (context, index) {
                        final station = _filteredStations[index];
                        return ListTile(
                          title: Text(
                            station.nameAr,
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            station.nameEn,
                            textAlign: TextAlign.right,
                            style: const TextStyle(color: Colors.white54),
                          ),
                          trailing: _buildLineIcons(station.lineIds),
                          onTap: () => Get.back(result: station),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// ودجت زر الفلتر
  Widget _buildFilterChip({required String label, required int lineValue}) {
    final isSelected = _selectedLineFilter == lineValue;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedColor: Colors.blue,
      backgroundColor: const Color(0xFF2A2D34),
      side: BorderSide(
        color: isSelected ? Colors.blue : Colors.transparent,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedLineFilter = lineValue;
            _applyFilter();
          });
        }
      },
    );
  }

  /// الشارات الدائرية لأرقام الخطوط
  Widget _buildLineIcons(List<int> lineIds) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: lineIds.map((id) {
        Color color = Colors.grey;
        if (id == 1) color = const Color.fromARGB(255, 17, 9, 225);
        if (id == 2) color = const Color(0xFFC30303);
        if (id == 3) color = const Color.fromARGB(255, 2, 198, 5);

        return Container(
          margin: const EdgeInsets.only(left: 4),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Text(
            '$id',
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        );
      }).toList(),
    );
  }
}