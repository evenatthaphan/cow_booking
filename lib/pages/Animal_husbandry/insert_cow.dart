import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class InsertCowPage extends StatefulWidget {
  const InsertCowPage({super.key});

  @override
  State<InsertCowPage> createState() => _InsertCowPageState();
}

class _InsertCowPageState extends State<InsertCowPage> {
  // ── Farm Info Controllers ──────────────────────────────────────────────────
  final _farmNameCtrl = TextEditingController();
  final _farmAddressCtrl = TextEditingController();
  final _farmProvinceCtrl = TextEditingController();
  final _farmOwnerCtrl = TextEditingController();
  final _farmPhoneCtrl = TextEditingController();

  // ── Cow Info Controllers ───────────────────────────────────────────────────
  final _cowNameCtrl = TextEditingController();
  final _cowBreedCtrl = TextEditingController();
  final _cowAgeCtrl = TextEditingController();
  final _cowWeightCtrl = TextEditingController();
  final _cowTagCtrl = TextEditingController();
  String _selectedGender = 'เมีย';
  String _selectedHealthStatus = 'ปกติ';

  // ── Images ─────────────────────────────────────────────────────────────────
  final List<File?> _images = List.filled(6, null); // max 6 images
  static const int _maxImages = 6;
  final _picker = ImagePicker();

  Future<void> _pickImage(int index) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _images[index] = File(picked.path));
    }
  }

  void _removeImage(int index) {
    setState(() => _images[index] = null);
  }

  int get _filledImageCount => _images.where((e) => e != null).length;

  void _save() {
    // TODO: ส่งข้อมูลไปยัง API
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('บันทึกข้อมูลเรียบร้อยแล้ว',
            style: GoogleFonts.notoSansThai()),
        backgroundColor: Colors.lightGreen[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _farmNameCtrl.dispose();
    _farmAddressCtrl.dispose();
    _farmProvinceCtrl.dispose();
    _farmOwnerCtrl.dispose();
    _farmPhoneCtrl.dispose();
    _cowNameCtrl.dispose();
    _cowBreedCtrl.dispose();
    _cowAgeCtrl.dispose();
    _cowWeightCtrl.dispose();
    _cowTagCtrl.dispose();
    super.dispose();
  }

  // ── UI Helpers ─────────────────────────────────────────────────────────────

  Widget _sectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.lightGreen[700],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: GoogleFonts.notoSansThai(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionDivider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Divider(color: Colors.grey[300], thickness: 1.5),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Icon(Icons.more_horiz, color: Colors.grey[400], size: 18),
            ),
            Expanded(
              child: Divider(color: Colors.grey[300], thickness: 1.5),
            ),
          ],
        ),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.notoSansThai(
              color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.lightGreen[700], size: 20),
          filled: true,
          fillColor: const Color(0xFFF4F9F0),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.lightGreen[700]!, width: 1.5),
          ),
        ),
        style: GoogleFonts.notoSansThai(fontSize: 14),
      ),
    );
  }

  Widget _dropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required void Function(T?) onChanged,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.notoSansThai(
              color: Colors.grey[600], fontSize: 14),
          prefixIcon: Icon(icon, color: Colors.lightGreen[700], size: 20),
          filled: true,
          fillColor: const Color(0xFFF4F9F0),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.lightGreen[700]!, width: 1.5),
          ),
        ),
        items: items
            .map((e) => DropdownMenuItem<T>(
                  value: e,
                  child: Text(e.toString(),
                      style: GoogleFonts.notoSansThai(fontSize: 14)),
                ))
            .toList(),
        onChanged: onChanged,
        style: GoogleFonts.notoSansThai(fontSize: 14, color: Colors.black87),
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // ── Section Widgets ────────────────────────────────────────────────────────

  Widget _buildFarmSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('ข้อมูลที่มาของฟาร์มวัว', Icons.house_outlined),
        _inputField(
          controller: _farmNameCtrl,
          label: 'ชื่อฟาร์ม',
          icon: Icons.store_outlined,
        ),
        _inputField(
          controller: _farmOwnerCtrl,
          label: 'ชื่อเจ้าของฟาร์ม',
          icon: Icons.person_outline,
        ),
        _inputField(
          controller: _farmPhoneCtrl,
          label: 'เบอร์โทรศัพท์ฟาร์ม',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        _inputField(
          controller: _farmProvinceCtrl,
          label: 'จังหวัด / อำเภอ',
          icon: Icons.location_city_outlined,
        ),
        _inputField(
          controller: _farmAddressCtrl,
          label: 'ที่อยู่ฟาร์ม',
          icon: Icons.map_outlined,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildCowSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('ข้อมูลของวัว', Icons.pets_outlined),
        _inputField(
          controller: _cowTagCtrl,
          label: 'หมายเลขประจำตัววัว (Tag)',
          icon: Icons.tag_outlined,
        ),
        _inputField(
          controller: _cowNameCtrl,
          label: 'ชื่อวัว',
          icon: Icons.label_outline,
        ),
        _inputField(
          controller: _cowBreedCtrl,
          label: 'สายพันธุ์',
          icon: Icons.biotech_outlined,
        ),
        _inputField(
          controller: _cowAgeCtrl,
          label: 'อายุ (เดือน)',
          icon: Icons.cake_outlined,
          keyboardType: TextInputType.number,
        ),
        _inputField(
          controller: _cowWeightCtrl,
          label: 'น้ำหนัก (กก.)',
          icon: Icons.monitor_weight_outlined,
          keyboardType: TextInputType.number,
        ),
        _dropdownField<String>(
          label: 'เพศ',
          value: _selectedGender,
          items: const ['เมีย', 'ผู้'],
          onChanged: (v) => setState(() => _selectedGender = v!),
          icon: Icons.male_outlined,
        ),
        _dropdownField<String>(
          label: 'สถานะสุขภาพ',
          value: _selectedHealthStatus,
          items: const ['ปกติ', 'ป่วย', 'พักฟื้น', 'ตั้งท้อง'],
          onChanged: (v) => setState(() => _selectedHealthStatus = v!),
          icon: Icons.health_and_safety_outlined,
        ),
      ],
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('รูปภาพวัว', Icons.photo_library_outlined),
        // Counter
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _filledImageCount >= _maxImages
                      ? Colors.orange[100]
                      : Colors.lightGreen[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _filledImageCount >= _maxImages
                        ? Colors.orange
                        : Colors.lightGreen[300]!,
                  ),
                ),
                child: Text(
                  '$_filledImageCount / $_maxImages รูป',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _filledImageCount >= _maxImages
                        ? Colors.orange[800]
                        : Colors.lightGreen[800],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'เพิ่มได้สูงสุด $_maxImages รูป',
                style: GoogleFonts.notoSansThai(
                    fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _maxImages,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, i) {
            final hasImage = _images[i] != null;
            return GestureDetector(
              onTap: hasImage ? null : () => _pickImage(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: hasImage ? Colors.transparent : const Color(0xFFF4F9F0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasImage
                        ? Colors.lightGreen[400]!
                        : Colors.grey[300]!,
                    width: hasImage ? 2 : 1.5,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: hasImage
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(9),
                            child: Image.file(_images[i]!,
                                fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(i),
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(3),
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 4,
                            left: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('รูปที่ ${i + 1}',
                                  style: GoogleFonts.notoSansThai(
                                      fontSize: 9, color: Colors.white)),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined,
                              color: Colors.grey[400], size: 28),
                          const SizedBox(height: 4),
                          Text('รูปที่ ${i + 1}',
                              style: GoogleFonts.notoSansThai(
                                  fontSize: 11, color: Colors.grey[400])),
                        ],
                      ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1E8),
      appBar: AppBar(
        title: Text(
          'จัดการข้อมูลวัว',
          style: GoogleFonts.notoSansThai(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.lightGreen[700],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: Farm ──────────────────────────────────────────────
            _buildCard(child: _buildFarmSection()),

            _sectionDivider(),

            // ── Section 2: Cow Info ──────────────────────────────────────────
            _buildCard(child: _buildCowSection()),

            _sectionDivider(),

            // ── Section 3: Images ────────────────────────────────────────────
            _buildCard(child: _buildImageSection()),

            const SizedBox(height: 24),

            // ── Save Button ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined, color: Colors.white),
                label: Text(
                  'บันทึกข้อมูล',
                  style: GoogleFonts.notoSansThai(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen[700],
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}