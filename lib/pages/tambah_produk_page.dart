import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class TambahProdukPage extends StatefulWidget {
  final String token;
  const TambahProdukPage({super.key, required this.token});

  @override
  State<TambahProdukPage> createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.tambahProduk(
        widget.token,
        _nameCtrl.text.trim(),
        int.parse(_priceCtrl.text.trim()),
        _descCtrl.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        _showSnackBar('Produk berhasil disimpan!');
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.pop(context, true);
      } else {
        _showSnackBar(result['message'] ?? 'Gagal menyimpan produk',
            isError: true);
      }
    } catch (e) {
      _showSnackBar('Tidak dapat terhubung ke server', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tambah Produk',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF6366F1).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Color(0xFF6366F1), size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pastikan data sudah benar. Data tidak dapat diubah setelah disimpan.',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Nama Produk
                _label('Nama Produk'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration(
                      'Contoh: Macbook Pro M5 2026', Icons.label_outline),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Nama produk wajib diisi' : null,
                ),
                const SizedBox(height: 20),

                // Harga
                _label('Harga (Rp)'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _priceCtrl,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration:
                      _inputDecoration('Contoh: 32450000', Icons.payments_outlined),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Harga wajib diisi';
                    if (int.tryParse(v) == null) return 'Harga tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Deskripsi
                _label('Deskripsi'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  decoration: _inputDecoration(
                      'Deskripsi produk...', Icons.description_outlined,
                      multiline: true),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
                ),
                const SizedBox(height: 32),

                // Button Simpan
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _simpan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_rounded, size: 20),
                              SizedBox(width: 8),
                              Text('Simpan Produk',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
          color: Colors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w500),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon,
      {bool multiline = false}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
      prefixIcon: multiline
          ? null
          : Icon(icon, color: Colors.white38, size: 20),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: EdgeInsets.symmetric(
          horizontal: 16, vertical: multiline ? 14 : 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFF6366F1), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}