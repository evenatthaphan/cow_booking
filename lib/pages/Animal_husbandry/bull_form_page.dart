import 'dart:convert';
import 'dart:io';
import 'package:cow_booking/config/internal_config.dart';
import 'package:cow_booking/share/share_data.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class AddBullStockPage extends StatefulWidget {
  const AddBullStockPage({super.key});

  @override
  State<AddBullStockPage> createState() => _AddBullStockPageState();
}

class _AddBullStockPageState extends State<AddBullStockPage> {
  // ── Cloudinary config ─────────────────────────────────────────────────────
  static const _cloudName = 'YOUR_CLOUD_NAME'; // ← ใส่ cloud name
  static const _uploadPreset = 'YOUR_UPLOAD_PRESET'; // ← ใส่ upload preset

  bool _isSaving = false;
  bool _isUploading = false;

  // ── ฟาร์ม ────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _farms = [];
  Map<String, dynamic>? _selectedFarm;
  bool _loadingFarms = true;

  // ── วัว ──────────────────────────────────────────────────────────────────
  List<Map<String, dynamic>> _bullsInFarm = [];
  Map<String, dynamic>? _selectedBull;
  bool _loadingBulls = false;

  // ── รูปภาพ ───────────────────────────────────────────────────────────────
  final List<File> _imageFiles = [];
  final List<String> _imageUrls = []; // URL หลัง upload Cloudinary

  // ── stock + ราคา ─────────────────────────────────────────────────────────
  final _stockCtrl = TextEditingController(text: '0');
  final _priceCtrl = TextEditingController(text: '0');

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchFarms();
  }

  @override
  void dispose() {
    _stockCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  // ── โหลดฟาร์ม ─────────────────────────────────────────────────────────────
  Future<void> _fetchFarms() async {
    try {
      final res = await http.get(Uri.parse('$apiEndpoint/vet/vet-bulls/farms'));
      if (res.statusCode == 200) {
        setState(() {
          _farms = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingFarms = false);
    }
  }

  // ── โหลดวัวในฟาร์ม ────────────────────────────────────────────────────────
  Future<void> _fetchBullsInFarm(int farmId) async {
    setState(() {
      _loadingBulls = true;
      _bullsInFarm = [];
      _selectedBull = null;
    });
    try {
      final res = await http
          .get(Uri.parse('$apiEndpoint/vet/vet-bulls/bulls-in-farm/$farmId'));
      if (res.statusCode == 200) {
        setState(() {
          _bullsInFarm = List<Map<String, dynamic>>.from(jsonDecode(res.body));
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _loadingBulls = false);
    }
  }

  // ── เพิ่มรูปภาพ ───────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    if (_imageFiles.length >= 5) {
      _showSnack('อัพโหลดได้สูงสุด 5 รูป', isError: true);
      return;
    }
    final picked = await _picker.pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() => _imageFiles.add(File(picked.path)));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.green),
              title: const Text('ถ่ายภาพ'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text('เลือกจากคลัง'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Upload Cloudinary ─────────────────────────────────────────────────────
  Future<String?> _uploadToCloudinary(File file) async {
    final uri =
        Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final res = await request.send();
    final body = jsonDecode(await res.stream.bytesToString());
    if (res.statusCode == 200) return body['secure_url'] as String;
    return null;
  }

  // ── Dialog สร้างฟาร์มใหม่ ─────────────────────────────────────────────────
  void _showCreateFarmDialog() {
    final nameCtrl = TextEditingController();
    final provinceCtrl = TextEditingController();
    final districtCtrl = TextEditingController();
    final localityCtrl = TextEditingController();
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('สร้างฟาร์มใหม่',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _simpleField(nameCtrl, 'ชื่อฟาร์ม *', Icons.home_work_outlined),
              const SizedBox(height: 10),
              _simpleField(
                  provinceCtrl, 'จังหวัด', Icons.location_city_outlined),
              const SizedBox(height: 10),
              _simpleField(districtCtrl, 'อำเภอ', Icons.map_outlined),
              const SizedBox(height: 10),
              _simpleField(localityCtrl, 'ตำบล', Icons.place_outlined),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('ยกเลิก',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: saving || nameCtrl.text.isEmpty
                        ? null
                        : () async {
                            setD(() => saving = true);
                            try {
                              final res = await http.post(
                                Uri.parse(
                                    '$apiEndpoint/vet/vet-bulls/farms/create'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'frams_name': nameCtrl.text.trim(),
                                  'frams_province': provinceCtrl.text.trim(),
                                  'frams_district': districtCtrl.text.trim(),
                                  'frams_locality': localityCtrl.text.trim(),
                                }),
                              );
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              if (res.statusCode == 201) {
                                final data = jsonDecode(res.body);
                                final newFarm = {
                                  'frams_id': data['frams_id'],
                                  'frams_name': nameCtrl.text.trim(),
                                  'frams_province': provinceCtrl.text.trim(),
                                  'frams_district': districtCtrl.text.trim(),
                                  'frams_locality': localityCtrl.text.trim(),
                                };
                                setState(() {
                                  _farms.add(newFarm);
                                  _selectedFarm = newFarm;
                                });
                                _fetchBullsInFarm(data['frams_id']);
                                _showSnack('สร้างฟาร์มสำเร็จ ✓');
                              }
                            } catch (_) {
                              if (ctx.mounted) Navigator.pop(ctx);
                              _showSnack('เกิดข้อผิดพลาด', isError: true);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('สร้างฟาร์ม',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Dialog สร้างวัวใหม่ ───────────────────────────────────────────────────
  void _showCreateBullDialog() {
    if (_selectedFarm == null) {
      _showSnack('กรุณาเลือกฟาร์มก่อน', isError: true);
      return;
    }
    final nameCtrl = TextEditingController();
    final breedCtrl = TextEditingController();
    final ageCtrl = TextEditingController();
    bool saving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('เพิ่มข้อมูลวัวใหม่',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _simpleField(nameCtrl, 'ชื่อวัว *', Icons.pets),
                const SizedBox(height: 10),
                _simpleField(breedCtrl, 'สายพันธุ์', Icons.category_outlined),
                const SizedBox(height: 10),
                _simpleField(ageCtrl, 'อายุ (ปี)', Icons.cake_outlined,
                    keyboardType: TextInputType.number),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('ยกเลิก',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: saving || nameCtrl.text.isEmpty
                        ? null
                        : () async {
                            setD(() => saving = true);
                            try {
                              final res = await http.post(
                                Uri.parse(
                                    '$apiEndpoint/vet/vet-bulls/bulls/create'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'bulls_name': nameCtrl.text.trim(),
                                  'bulls_breed': breedCtrl.text.trim(),
                                  'bulls_age': int.tryParse(ageCtrl.text),
                                  'ref_farm_id': _selectedFarm!['frams_id'],
                                }),
                              );
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              if (res.statusCode == 201) {
                                final data = jsonDecode(res.body);
                                final newBull = {
                                  'bulls_id': data['bulls_id'],
                                  'bulls_name': nameCtrl.text.trim(),
                                  'bulls_breed': breedCtrl.text.trim(),
                                };
                                setState(() {
                                  _bullsInFarm.add(newBull);
                                  _selectedBull = newBull;
                                });
                                _showSnack('เพิ่มข้อมูลวัวสำเร็จ ✓');
                              }
                            } catch (_) {
                              if (ctx.mounted) Navigator.pop(ctx);
                              _showSnack('เกิดข้อผิดพลาด', isError: true);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('เพิ่มวัว',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // บันทึก 
  Future<void> _save() async {
    if (_selectedBull == null) {
      _showSnack('กรุณาเลือกวัว', isError: true);
      return;
    }

    final stock = int.tryParse(_stockCtrl.text) ?? -1;
    final price = double.tryParse(_priceCtrl.text) ?? -1;

    if (stock <= 0 || stock > 10) {
      _showSnack('จำนวนโดสต้องเป็นตัวเลข 1-10', isError: true);
      return;
    }
    if (price <= 0) {
      _showSnack('ราคาต่อโดสต้องมากกว่า 0', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final urls = <String>[];

      // Upload รูปเฉพาะเมื่อมีรูป
      if (_imageFiles.isNotEmpty) {
        setState(() => _isUploading = true);
        for (final file in _imageFiles) {
          final url = await _uploadToCloudinary(file);
          if (url != null) urls.add(url);
        }
        setState(() => _isUploading = false);
      }

      final vetId = context.read<DataVetExpert>().datauser.id;
      final res = await http.post(
        Uri.parse('$apiEndpoint/vet/vet-bulls/add'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vet_id': vetId,
          'bulls_id': _selectedBull!['bulls_id'],
          'bulls_semen_stock': stock,
          'bulls_price_per_dose': price,
          'images': urls, // ส่ง [] ถ้าไม่มีรูป
        }),
      );

      if (!mounted) return;

      if (res.statusCode == 201) {
        _showSnack('เพิ่มวัวเข้าสต็อกสำเร็จ ✓');
        Navigator.pop(context, true);
      } else {
        final body = jsonDecode(res.body);
        _showSnack(body['error'] ?? 'เกิดข้อผิดพลาด', isError: true);
      }
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาด: $e', isError: true);
    } finally {
      if (mounted)
        setState(() {
          _isSaving = false;
          _isUploading = false;
        });
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: isError ? Colors.red : Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.green[900]),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('🐄', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cow Booking',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.green[900],
                    height: 1.1,
                  ),
                ),
                Text(
                  'ตั้งค่าบัญชีของคุณ',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 11,
                    color: Colors.green[900],
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Step 1: เลือกฟาร์ม ────────────────────────────────────
            _sectionLabel('1. เลือกฟาร์ม'),
            _card([
              Padding(
                padding: const EdgeInsets.all(14),
                child: _loadingFarms
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.green))
                    : Column(
                        children: [
                          DropdownButtonFormField<Map<String, dynamic>>(
                            value: _selectedFarm,
                            isExpanded: true,
                            decoration: _dropdownDeco(
                                'เลือกฟาร์ม', Icons.home_work_outlined),
                            items: _farms
                                .map((f) => DropdownMenuItem(
                                      value: f,
                                      child: Text(f['frams_name'] ?? '',
                                          style: GoogleFonts.notoSansThai(
                                              fontSize: 14),
                                          overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (f) {
                              setState(() => _selectedFarm = f);
                              if (f != null) _fetchBullsInFarm(f['frams_id']);
                            },
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: _showCreateFarmDialog,
                            icon: Icon(Icons.add,
                                size: 16, color: Colors.green[700]),
                            label: Text('ฟาร์มไม่มีในระบบ เพิ่มใหม่',
                                style: TextStyle(
                                    color: Colors.green[700], fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.green[300]!),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
              ),
            ]),

            const SizedBox(height: 16),

            // ── Step 2: เลือกวัว ──────────────────────────────────────
            _sectionLabel('2. เลือกวัว'),
            _card([
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    _loadingBulls
                        ? const Center(
                            child:
                                CircularProgressIndicator(color: Colors.green))
                        : DropdownButtonFormField<Map<String, dynamic>>(
                            value: _selectedBull,
                            isExpanded: true,
                            decoration: _dropdownDeco(
                              _selectedFarm == null
                                  ? 'เลือกฟาร์มก่อน'
                                  : _bullsInFarm.isEmpty
                                      ? 'ไม่มีวัวในฟาร์มนี้'
                                      : 'เลือกวัว',
                              Icons.pets,
                            ),
                            items: _bullsInFarm
                                .map((b) => DropdownMenuItem(
                                      value: b,
                                      child: Text(
                                        '${b['bulls_name']} (${b['bulls_breed'] ?? '-'})',
                                        style: GoogleFonts.notoSansThai(
                                            fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ))
                                .toList(),
                            onChanged: _selectedFarm == null
                                ? null
                                : (b) => setState(() => _selectedBull = b),
                          ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _showCreateBullDialog,
                      icon: Icon(Icons.add, size: 16, color: Colors.brown[600]),
                      label: Text('วัวไม่มีในระบบ เพิ่มใหม่',
                          style: TextStyle(
                              color: Colors.brown[600], fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.brown[300]!),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 16),

            // ── Step 3: รูปภาพ ────────────────────────────────────────
            _sectionLabel('3. รูปภาพวัว (ไม่บังคับ, สูงสุด 5 รูป)'),
            _card([
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    // Grid รูปภาพ
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount:
                          _imageFiles.length + (_imageFiles.length < 5 ? 1 : 0),
                      itemBuilder: (_, i) {
                        if (i < _imageFiles.length) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(_imageFiles[i],
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _imageFiles.removeAt(i)),
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.close,
                                        color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        // ปุ่มเพิ่มรูป
                        return GestureDetector(
                          onTap: _showImageSourceSheet,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: Colors.green[200]!,
                                  width: 1.5,
                                  style: BorderStyle.solid),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo_outlined,
                                    color: Colors.green[600], size: 24),
                                const SizedBox(height: 4),
                                Text('เพิ่มรูป',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.green[600])),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    if (_imageFiles.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text('* กรุณาเพิ่มรูปภาพอย่างน้อย 1 รูป',
                            style: TextStyle(
                                fontSize: 12, color: Colors.red[400])),
                      ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 16),

            // ── Step 4: Stock + ราคา ──────────────────────────────────
            _sectionLabel('4. จำนวนโดสและราคา'),
            _card([
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Expanded(
                      child: _inputField(
                        controller: _stockCtrl,
                        label: 'จำนวนโดส',
                        icon: Icons.science_outlined,
                        suffix: 'โดส',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _inputField(
                        controller: _priceCtrl,
                        label: 'ราคา/โดส',
                        icon: Icons.attach_money,
                        suffix: '฿',
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ),
            ]),

            const SizedBox(height: 32),

            // ── ปุ่มบันทึก ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isSaving
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2)),
                          const SizedBox(width: 10),
                          Text(
                            _isUploading
                                ? 'กำลังอัพโหลดรูป...'
                                : 'กำลังบันทึก...',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                        ],
                      )
                    : const Text('บันทึกเพิ่มวัวเข้าสต็อก',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _sectionLabel(String label) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 2),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
                letterSpacing: 0.3)),
      );

  Widget _card(List<Widget> children) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(children: children),
      );

  InputDecoration _dropdownDeco(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.notoSansThai(color: Colors.grey, fontSize: 13),
        prefixIcon: Icon(icon, size: 20, color: Colors.green[600]),
        filled: true,
        fillColor: const Color(0xFFF5F7F2),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.green[400]!, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? suffix,
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: Icon(icon, size: 18, color: Colors.green[600]),
          suffixText: suffix,
          suffixStyle: const TextStyle(color: Colors.grey, fontSize: 13),
          filled: true,
          fillColor: const Color(0xFFF5F7F2),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.green[400]!, width: 1.5)),
        ),
      );

  Widget _simpleField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
  }) =>
      TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13, color: Colors.grey),
          prefixIcon: Icon(icon, size: 18, color: Colors.green[600]),
          filled: true,
          fillColor: const Color(0xFFF5F7F2),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.green[400]!, width: 1.5)),
        ),
      );
}
