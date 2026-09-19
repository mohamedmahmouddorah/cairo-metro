import 'package:flutter/material.dart';
import 'models/line_station.dart';
import 'models/metro_line.dart';
import 'models/metro_station.dart';

abstract final class MetroData {
  const MetroData._();

  static const List<MetroLine> lines = [
    MetroLine(id: 1, nameEn: 'Line 1', nameAr: 'الخط الأول', color: Color.fromARGB(255, 3, 1, 109)),
    MetroLine(id: 2, nameEn: 'Line 2', nameAr: 'الخط الثاني', color: Color.fromARGB(255, 195, 3, 3)),
    MetroLine(id: 3, nameEn: 'Line 3', nameAr: 'الخط الثالث', color: Color.fromARGB(255, 2, 158, 5)),
  ];

  static const List<MetroStation> stations = [
    // --- Line 1 Only ---
    MetroStation(id: 'l1_helwan', nameEn: 'Helwan', nameAr: 'حلوان', latitude: 29.8486, longitude: 31.3339, lineIds: [1]),
    MetroStation(id: 'l1_ain_helwan', nameEn: 'Ain Helwan', nameAr: 'عين حلوان', latitude: 29.8550, longitude: 31.3300, lineIds: [1]),
    MetroStation(id: 'l1_helwan_university', nameEn: 'Helwan University', nameAr: 'جامعة حلوان', latitude: 29.8680, longitude: 31.3210, lineIds: [1]),
    MetroStation(id: 'l1_wadi_hof', nameEn: 'Wadi Hof', nameAr: 'وادي حوف', latitude: 29.8800, longitude: 31.3140, lineIds: [1]),
    MetroStation(id: 'l1_hadayek_helwan', nameEn: 'Hadayek Helwan', nameAr: 'حدائق حلوان', latitude: 29.8950, longitude: 31.3060, lineIds: [1]),
    MetroStation(id: 'l1_el_maasara', nameEn: 'El-Maasara', nameAr: 'المعصرة', latitude: 29.9070, longitude: 31.2990, lineIds: [1]),
    MetroStation(id: 'l1_tura_el_asmant', nameEn: 'Tura El-Asmant', nameAr: 'طرة الأسمنت', latitude: 29.9230, longitude: 31.2900, lineIds: [1]),
    MetroStation(id: 'l1_kozzika', nameEn: 'Kozzika', nameAr: 'كوتسيكا', latitude: 29.9320, longitude: 31.2850, lineIds: [1]),
    MetroStation(id: 'l1_tura_el_balad', nameEn: 'Tura El-Balad', nameAr: 'طرة البلد', latitude: 29.9430, longitude: 31.2790, lineIds: [1]),
    MetroStation(id: 'l1_sakanat_el_maadi', nameEn: 'Sakanat El-Maadi', nameAr: 'ثكنات المعادي', latitude: 29.9530, longitude: 31.2740, lineIds: [1]),
    MetroStation(id: 'l1_el_maadi', nameEn: 'El-Maadi', nameAr: 'المعادي', latitude: 29.9610, longitude: 31.2670, lineIds: [1]),
    MetroStation(id: 'l1_hadayek_el_maadi', nameEn: 'Hadayek El-Maadi', nameAr: 'حدائق المعادي', latitude: 29.9720, longitude: 31.2600, lineIds: [1]),
    MetroStation(id: 'l1_dar_el_salam', nameEn: 'Dar El-Salam', nameAr: 'دار السلام', latitude: 29.9820, longitude: 31.2530, lineIds: [1]),
    MetroStation(id: 'l1_el_zahraa', nameEn: 'El-Zahraa', nameAr: 'الزهراء', latitude: 29.9950, longitude: 31.2410, lineIds: [1]),
    MetroStation(id: 'l1_mar_girgis', nameEn: 'Mar Girgis', nameAr: 'مار جرجس', latitude: 30.0060, longitude: 31.2300, lineIds: [1]),
    MetroStation(id: 'l1_el_malek_el_saleh', nameEn: 'El-Malek El-Saleh', nameAr: 'الملك الصالح', latitude: 30.0170, longitude: 31.2310, lineIds: [1]),
    MetroStation(id: 'l1_al_sayeda_zeinab', nameEn: 'Al-Sayeda Zeinab', nameAr: 'السيدة زينب', latitude: 30.0290, longitude: 31.2360, lineIds: [1]),
    MetroStation(id: 'l1_saad_zaghloul', nameEn: 'Saad Zaghloul', nameAr: 'سعد زغلول', latitude: 30.0350, longitude: 31.2380, lineIds: [1]),
    
    // --- Line 1 & Line 2 Interchanges ---
    MetroStation(id: 'int_sadat', nameEn: 'Sadat', nameAr: 'السادات', latitude: 30.04435, longitude: 31.23560, lineIds: [1, 2]),
    MetroStation(id: 'int_al_shohadaa', nameEn: 'Al-Shohadaa', nameAr: 'الشهداء', latitude: 30.0610, longitude: 31.2460, lineIds: [1, 2]),
    
    // --- Line 1 & Line 3 Interchanges ---
    MetroStation(id: 'int_nasser', nameEn: 'Nasser', nameAr: 'ناصر', latitude: 30.0520, longitude: 31.2400, lineIds: [1, 3]),

    // --- Line 1 Continuing ---
    MetroStation(id: 'l1_orabi', nameEn: 'Orabi', nameAr: 'عرابي', latitude: 30.0560, longitude: 31.2420, lineIds: [1]),
    MetroStation(id: 'l1_ghamra', nameEn: 'Ghamra', nameAr: 'غمرة', latitude: 30.0670, longitude: 31.2640, lineIds: [1]),
    MetroStation(id: 'l1_el_demerdash', nameEn: 'El-Demerdash', nameAr: 'الدمرداش', latitude: 30.0760, longitude: 31.2770, lineIds: [1]),
    MetroStation(id: 'l1_manshiet_el_sadr', nameEn: 'Manshiet El-Sadr', nameAr: 'منشية الصدر', latitude: 30.0820, longitude: 31.2850, lineIds: [1]),
    MetroStation(id: 'l1_kobri_el_qobba', nameEn: 'Kobri El-Qobba', nameAr: 'كوبري القبة', latitude: 30.0880, longitude: 31.2940, lineIds: [1]),
    MetroStation(id: 'l1_hammamat_el_qobba', nameEn: 'Hammamat El-Qobba', nameAr: 'حمامات القبة', latitude: 30.0930, longitude: 31.3000, lineIds: [1]),
    MetroStation(id: 'l1_saray_el_qobba', nameEn: 'Saray El-Qobba', nameAr: 'سراي القبة', latitude: 30.0990, longitude: 31.3070, lineIds: [1]),
    MetroStation(id: 'l1_hadayek_el_zaytoun', nameEn: 'Hadayek El-Zaytoun', nameAr: 'حدائق الزيتون', latitude: 30.1060, longitude: 31.3140, lineIds: [1]),
    MetroStation(id: 'l1_helmeyet_el_zaytoun', nameEn: 'Helmeyet El-Zaytoun', nameAr: 'حلمية الزيتون', latitude: 30.1140, longitude: 31.3190, lineIds: [1]),
    MetroStation(id: 'l1_el_matareyya', nameEn: 'El-Matareyya', nameAr: 'المطرية', latitude: 30.1210, longitude: 31.3170, lineIds: [1]),
    MetroStation(id: 'l1_ain_shams', nameEn: 'Ain Shams', nameAr: 'عين شمس', latitude: 30.1300, longitude: 31.3210, lineIds: [1]),
    MetroStation(id: 'l1_ezbet_el_nakhl', nameEn: 'Ezbet El-Nakhl', nameAr: 'عزبة النخل', latitude: 30.1410, longitude: 31.3230, lineIds: [1]),
    MetroStation(id: 'l1_el_marg', nameEn: 'El-Marg', nameAr: 'المرج', latitude: 30.1510, longitude: 31.3320, lineIds: [1]),
    MetroStation(id: 'l1_new_el_marg', nameEn: 'New El-Marg', nameAr: 'المرج الجديدة', latitude: 30.16351, longitude: 31.33827, lineIds: [1]),

    // --- Line 2 Only ---
    MetroStation(id: 'l2_shubra', nameEn: 'Shubra El-Kheima', nameAr: 'شبرا الخيمة', latitude: 30.12213, longitude: 31.24402, lineIds: [2]),
    MetroStation(id: 'l2_koliet_el_zeraa', nameEn: 'Koliet El-Zeraa', nameAr: 'كلية الزراعة', latitude: 30.1130, longitude: 31.2460, lineIds: [2]),
    MetroStation(id: 'l2_mezallat', nameEn: 'Mezallat', nameAr: 'المظلات', latitude: 30.1040, longitude: 31.2450, lineIds: [2]),
    MetroStation(id: 'l2_khalafawy', nameEn: 'Khalafawy', nameAr: 'الخلفاوي', latitude: 30.0960, longitude: 31.2440, lineIds: [2]),
    MetroStation(id: 'l2_saint_teresa', nameEn: 'Saint Teresa', nameAr: 'سانت تريزا', latitude: 30.0880, longitude: 31.2430, lineIds: [2]),
    MetroStation(id: 'l2_rod_el_farag', nameEn: 'Rod El-Farag', nameAr: 'روض الفرج', latitude: 30.0780, longitude: 31.2450, lineIds: [2]),
    MetroStation(id: 'l2_massara', nameEn: 'Massara', nameAr: 'مسرة', latitude: 30.0710, longitude: 31.2460, lineIds: [2]),
    MetroStation(id: 'l2_mohamed_naguib', nameEn: 'Mohamed Naguib', nameAr: 'محمد نجيب', latitude: 30.0450, longitude: 31.2430, lineIds: [2]),
    MetroStation(id: 'l2_opera', nameEn: 'Opera', nameAr: 'الأوبرا', latitude: 30.0410, longitude: 31.2250, lineIds: [2]),
    MetroStation(id: 'l2_dokki', nameEn: 'Dokki', nameAr: 'الدقي', latitude: 30.0380, longitude: 31.2120, lineIds: [2]),
    MetroStation(id: 'l2_el_bohoth', nameEn: 'El-Bohoth', nameAr: 'البحوث', latitude: 30.0350, longitude: 31.2000, lineIds: [2]),
    MetroStation(id: 'l2_faisal', nameEn: 'Faisal', nameAr: 'فيصل', latitude: 30.0160, longitude: 31.1990, lineIds: [2]),
    MetroStation(id: 'l2_giza', nameEn: 'Giza', nameAr: 'الجيزة', latitude: 30.0080, longitude: 31.2030, lineIds: [2]),
    MetroStation(id: 'l2_omm_el_masryeen', nameEn: 'Omm El-Masryeen', nameAr: 'أم المصريين', latitude: 30.0010, longitude: 31.2060, lineIds: [2]),
    MetroStation(id: 'l2_sakiet_mekky', nameEn: 'Sakiet Mekky', nameAr: 'ساقية مكي', latitude: 29.9930, longitude: 31.2080, lineIds: [2]),
    MetroStation(id: 'l2_el_mounib', nameEn: 'El-Mounib', nameAr: 'المنيب', latitude: 29.9800, longitude: 31.2130, lineIds: [2]),

    // --- Line 2 & Line 3 Interchanges ---
    MetroStation(id: 'int_attaba', nameEn: 'Attaba', nameAr: 'العتبة', latitude: 30.0520, longitude: 31.2470, lineIds: [2, 3]),
    MetroStation(id: 'int_cairo_university', nameEn: 'Cairo University', nameAr: 'جامعة القاهرة', latitude: 30.0250, longitude: 31.2014, lineIds: [2, 3]),

    // --- Line 3 Trunk Only ---
    MetroStation(id: 'l3_adly_mansour', nameEn: 'Adly Mansour', nameAr: 'عدلي منصور', latitude: 30.1470, longitude: 31.4190, lineIds: [3]),
    MetroStation(id: 'l3_haykestep', nameEn: 'Haykestep', nameAr: 'الهايكستب', latitude: 30.1420, longitude: 31.4010, lineIds: [3]),
    MetroStation(id: 'l3_omar_ibn_el_khattab', nameEn: 'Omar Ibn El Khattab', nameAr: 'عمر بن الخطاب', latitude: 30.1390, longitude: 31.3910, lineIds: [3]),
    MetroStation(id: 'l3_qubaa', nameEn: 'Qubaa', nameAr: 'قباء', latitude: 30.1360, longitude: 31.3780, lineIds: [3]),
    MetroStation(id: 'l3_hesham_barakat', nameEn: 'Hesham Barakat', nameAr: 'هشام بركات', latitude: 30.1320, longitude: 31.3650, lineIds: [3]),
    MetroStation(id: 'l3_el_nozha', nameEn: 'El Nozha', nameAr: 'النزهة', latitude: 30.1250, longitude: 31.3530, lineIds: [3]),
    MetroStation(id: 'l3_el_shams_club', nameEn: 'El Shams Club', nameAr: 'نادي الشمس', latitude: 30.1190, longitude: 31.3410, lineIds: [3]),
    MetroStation(id: 'l3_alf_maskan', nameEn: 'Alf Maskan', nameAr: 'ألف مسكن', latitude: 30.1130, longitude: 31.3320, lineIds: [3]),
    MetroStation(id: 'l3_heliopolis', nameEn: 'Heliopolis', nameAr: 'ميدان هيليوبليس', latitude: 30.1060, longitude: 31.3250, lineIds: [3]),
    MetroStation(id: 'l3_haroun', nameEn: 'Haroun', nameAr: 'هارون', latitude: 30.0980, longitude: 31.3210, lineIds: [3]),
    MetroStation(id: 'l3_al_ahram', nameEn: 'Al-Ahram', nameAr: 'الأهرام', latitude: 30.0910, longitude: 31.3220, lineIds: [3]),
    MetroStation(id: 'l3_koleyet_el_banat', nameEn: 'Koleyet El-Banat', nameAr: 'كلية البنات', latitude: 30.0820, longitude: 31.3260, lineIds: [3]),
    MetroStation(id: 'l3_stadium', nameEn: 'Stadium', nameAr: 'ستاد القاهرة', latitude: 30.0730, longitude: 31.3160, lineIds: [3]),
    MetroStation(id: 'l3_fair_zone', nameEn: 'Fair Zone', nameAr: 'المعرض', latitude: 30.0730, longitude: 31.3030, lineIds: [3]),
    MetroStation(id: 'l3_abbassiya', nameEn: 'Abbassiya', nameAr: 'العباسية', latitude: 30.0670, longitude: 31.2850, lineIds: [3]),
    MetroStation(id: 'l3_abdou_pasha', nameEn: 'Abdou Pasha', nameAr: 'عبده باشا', latitude: 30.0640, longitude: 31.2750, lineIds: [3]),
    MetroStation(id: 'l3_el_geish', nameEn: 'El-Geish', nameAr: 'الجيش', latitude: 30.0620, longitude: 31.2650, lineIds: [3]),
    MetroStation(id: 'l3_bab_el_shaariya', nameEn: 'Bab El Shaariya', nameAr: 'باب الشعرية', latitude: 30.0540, longitude: 31.2560, lineIds: [3]),
    MetroStation(id: 'l3_maspero', nameEn: 'Maspero', nameAr: 'ماسبيرو', latitude: 30.0550, longitude: 31.2330, lineIds: [3]),
    MetroStation(id: 'l3_safaa_hegazy', nameEn: 'Safaa Hegazy', nameAr: 'صفاء حجازي', latitude: 30.0620, longitude: 31.2220, lineIds: [3]),
    MetroStation(id: 'l3_kit_kat', nameEn: 'Kit Kat', nameAr: 'الكيت كات', latitude: 30.07291, longitude: 31.21381, lineIds: [3]),

    // --- Line 3 NW Branch (Rod El Farag Corridor) ---
    MetroStation(id: 'l3_sudan', nameEn: 'Sudan', nameAr: 'السودان', latitude: 30.0740, longitude: 31.2050, lineIds: [3]),
    MetroStation(id: 'l3_imbaba', nameEn: 'Imbaba', nameAr: 'إمبابة', latitude: 30.0790, longitude: 31.1980, lineIds: [3]),
    MetroStation(id: 'l3_el_bohy', nameEn: 'El-Bohy', nameAr: 'البوهي', latitude: 30.0860, longitude: 31.1960, lineIds: [3]),
    MetroStation(id: 'l3_el_qawmia', nameEn: 'Al-Qawmia Al-Arabiya', nameAr: 'القومية العربية', latitude: 30.0940, longitude: 31.1910, lineIds: [3]),
    MetroStation(id: 'l3_ring_road', nameEn: 'Ring Road', nameAr: 'الطريق الدائري', latitude: 30.0980, longitude: 31.1880, lineIds: [3]),
    MetroStation(id: 'l3_rod_el_farag_corridor', nameEn: 'Rod El Farag Corridor', nameAr: 'محور روض الفرج', latitude: 30.1019, longitude: 31.1844, lineIds: [3]),

    // --- Line 3 SW Branch (Cairo University) ---
    MetroStation(id: 'l3_tawfikia', nameEn: 'Tawfikia', nameAr: 'التوفيقية', latitude: 30.0630, longitude: 31.2040, lineIds: [3]),
    MetroStation(id: 'l3_wadi_el_nile', nameEn: 'Wadi El Nile', nameAr: 'وادي النيل', latitude: 30.0550, longitude: 31.1970, lineIds: [3]),
    MetroStation(id: 'l3_gamat_el_dowal', nameEn: 'Gamat El Dowal', nameAr: 'جامعة الدول العربية', latitude: 30.0470, longitude: 31.1940, lineIds: [3]),
    MetroStation(id: 'l3_boulak_el_dakrour', nameEn: 'Boulak El Dakrour', nameAr: 'بولاق الدكرور', latitude: 30.0350, longitude: 31.1950, lineIds: [3]),
  ];

  static const List<LineStation> line1Stations = [
    LineStation(stationId: 'l1_helwan', order: 0),
    LineStation(stationId: 'l1_ain_helwan', order: 1),
    LineStation(stationId: 'l1_helwan_university', order: 2),
    LineStation(stationId: 'l1_wadi_hof', order: 3),
    LineStation(stationId: 'l1_hadayek_helwan', order: 4),
    LineStation(stationId: 'l1_el_maasara', order: 5),
    LineStation(stationId: 'l1_tura_el_asmant', order: 6),
    LineStation(stationId: 'l1_kozzika', order: 7),
    LineStation(stationId: 'l1_tura_el_balad', order: 8),
    LineStation(stationId: 'l1_sakanat_el_maadi', order: 9),
    LineStation(stationId: 'l1_el_maadi', order: 10),
    LineStation(stationId: 'l1_hadayek_el_maadi', order: 11),
    LineStation(stationId: 'l1_dar_el_salam', order: 12),
    LineStation(stationId: 'l1_el_zahraa', order: 13),
    LineStation(stationId: 'l1_mar_girgis', order: 14),
    LineStation(stationId: 'l1_el_malek_el_saleh', order: 15),
    LineStation(stationId: 'l1_al_sayeda_zeinab', order: 16),
    LineStation(stationId: 'l1_saad_zaghloul', order: 17),
    LineStation(stationId: 'int_sadat', order: 18),
    LineStation(stationId: 'int_nasser', order: 19),
    LineStation(stationId: 'l1_orabi', order: 20),
    LineStation(stationId: 'int_al_shohadaa', order: 21),
    LineStation(stationId: 'l1_ghamra', order: 22),
    LineStation(stationId: 'l1_el_demerdash', order: 23),
    LineStation(stationId: 'l1_manshiet_el_sadr', order: 24),
    LineStation(stationId: 'l1_kobri_el_qobba', order: 25),
    LineStation(stationId: 'l1_hammamat_el_qobba', order: 26),
    LineStation(stationId: 'l1_saray_el_qobba', order: 27),
    LineStation(stationId: 'l1_hadayek_el_zaytoun', order: 28),
    LineStation(stationId: 'l1_helmeyet_el_zaytoun', order: 29),
    LineStation(stationId: 'l1_el_matareyya', order: 30),
    LineStation(stationId: 'l1_ain_shams', order: 31),
    LineStation(stationId: 'l1_ezbet_el_nakhl', order: 32),
    LineStation(stationId: 'l1_el_marg', order: 33),
    LineStation(stationId: 'l1_new_el_marg', order: 34),
  ];

  static const List<LineStation> line2Stations = [
    LineStation(stationId: 'l2_shubra', order: 0),
    LineStation(stationId: 'l2_koliet_el_zeraa', order: 1),
    LineStation(stationId: 'l2_mezallat', order: 2),
    LineStation(stationId: 'l2_khalafawy', order: 3),
    LineStation(stationId: 'l2_saint_teresa', order: 4),
    LineStation(stationId: 'l2_rod_el_farag', order: 5),
    LineStation(stationId: 'l2_massara', order: 6),
    LineStation(stationId: 'int_al_shohadaa', order: 7),
    LineStation(stationId: 'int_attaba', order: 8),
    LineStation(stationId: 'l2_mohamed_naguib', order: 9),
    LineStation(stationId: 'int_sadat', order: 10),
    LineStation(stationId: 'l2_opera', order: 11),
    LineStation(stationId: 'l2_dokki', order: 12),
    LineStation(stationId: 'l2_el_bohoth', order: 13),
    LineStation(stationId: 'int_cairo_university', order: 14),
    LineStation(stationId: 'l2_faisal', order: 15),
    LineStation(stationId: 'l2_giza', order: 16),
    LineStation(stationId: 'l2_omm_el_masryeen', order: 17),
    LineStation(stationId: 'l2_sakiet_mekky', order: 18),
    LineStation(stationId: 'l2_el_mounib', order: 19),
  ];

  static const List<LineStation> line3Stations = [
    // Trunk
    LineStation(stationId: 'l3_adly_mansour', order: 0),
    LineStation(stationId: 'l3_haykestep', order: 1),
    LineStation(stationId: 'l3_omar_ibn_el_khattab', order: 2),
    LineStation(stationId: 'l3_qubaa', order: 3),
    LineStation(stationId: 'l3_hesham_barakat', order: 4),
    LineStation(stationId: 'l3_el_nozha', order: 5),
    LineStation(stationId: 'l3_el_shams_club', order: 6),
    LineStation(stationId: 'l3_alf_maskan', order: 7),
    LineStation(stationId: 'l3_heliopolis', order: 8),
    LineStation(stationId: 'l3_haroun', order: 9),
    LineStation(stationId: 'l3_al_ahram', order: 10),
    LineStation(stationId: 'l3_koleyet_el_banat', order: 11),
    LineStation(stationId: 'l3_stadium', order: 12),
    LineStation(stationId: 'l3_fair_zone', order: 13),
    LineStation(stationId: 'l3_abbassiya', order: 14),
    LineStation(stationId: 'l3_abdou_pasha', order: 15),
    LineStation(stationId: 'l3_el_geish', order: 16),
    LineStation(stationId: 'l3_bab_el_shaariya', order: 17),
    LineStation(stationId: 'int_attaba', order: 18),
    LineStation(stationId: 'int_nasser', order: 19),
    LineStation(stationId: 'l3_maspero', order: 20),
    LineStation(stationId: 'l3_safaa_hegazy', order: 21),
    LineStation(stationId: 'l3_kit_kat', order: 22),

    // NW Branch
    LineStation(stationId: 'l3_sudan', order: 23, branchId: 'nw'),
    LineStation(stationId: 'l3_imbaba', order: 24, branchId: 'nw'),
    LineStation(stationId: 'l3_el_bohy', order: 25, branchId: 'nw'),
    LineStation(stationId: 'l3_el_qawmia', order: 26, branchId: 'nw'),
    LineStation(stationId: 'l3_ring_road', order: 27, branchId: 'nw'),
    LineStation(stationId: 'l3_rod_el_farag_corridor', order: 28, branchId: 'nw'),

    // SW Branch
    LineStation(stationId: 'l3_tawfikia', order: 23, branchId: 'sw'),
    LineStation(stationId: 'l3_wadi_el_nile', order: 24, branchId: 'sw'),
    LineStation(stationId: 'l3_gamat_el_dowal', order: 25, branchId: 'sw'),
    LineStation(stationId: 'l3_boulak_el_dakrour', order: 26, branchId: 'sw'),
    LineStation(stationId: 'int_cairo_university', order: 27, branchId: 'sw'),
  ];

  // Map Fast Lookup Optimization (0ms constant time)
  static final Map<String, MetroStation> _stationMap = {
    for (final s in stations) s.id: s
  };

  static final Map<int, MetroLine> _lineMap = {
    for (final l in lines) l.id: l
  };

  // Map Fast Lookup لخوارزمية تتبع فروع الخط الثالث بسرعة O(1)
  static final Map<String, String?> _line3BranchMap = {
    for (final item in line3Stations) item.stationId: item.branchId
  };

  static MetroStation? stationById(String id) => _stationMap[id];

  static MetroLine? lineById(int id) => _lineMap[id];

  static List<LineStation> stationsForLine(int lineId) {
    switch (lineId) {
      case 1:
        return line1Stations;
      case 2:
        return line2Stations;
      case 3:
        return line3Stations;
      default:
        return const [];
    }
  }

  /// جلب التفريع للخط الثالث بنطاق O(1) المباشر
  static String? branchIdFor(String stationId, int lineId) {
    if (lineId != 3) return null;
    return _line3BranchMap[stationId];
  }
}