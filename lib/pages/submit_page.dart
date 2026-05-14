import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class SubmitPage extends StatefulWidget {
  final String token;
  const SubmitPage({super.key, required this.token});

  @override
  State<SubmitPage> createState() => _SubmitPageState();
}

class _SubmitPageState extends State<SubmitPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _githubCtrl = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _githubCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Konfirmasi sebelum submit
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: Colors.amber, size: 24),
            SizedBox(width: 8),
            Text('Konfirmasi Submit',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
        content: const Text(
          'Pastikan semua data sudah benar!\n\nTugas yang sudah disubmit tidak dapat diubah. Lanjutkan?',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal',
                style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Ya, Submit!',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final result = await ApiService.submitTugas(
        widget.token,
        _nameCtrl.text.trim(),
        int.parse(_priceCtrl.text.trim()),
        _descCtrl.text.trim(),
        _githubCtrl.text.trim(),
      );

      if (!mounted) return;

      if (result['success']) {
        setState(() => _isSubmitted = true);
        _showSuccessDialog();
      } else {
        _showSnackBar(result['message'] ?? 'Gagal submit tugas',
            isError: true);
      }
    } catch (e) {
      _showSnackBar('Tidak dapat terhubung ke server', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: Colors.green, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Tugas Berhasil Disubmit!',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Waktu submit telah tercatat otomatis oleh sistem.',
              style: TextStyle(
                  color: Colors.white.withOpacity(0.6), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                child: const Text('Kembali ke Home',
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
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
          'Submit Tugas',
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
                // Warning banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.amber.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Submit hanya bisa dilakukan sekali. Pastikan GitHub URL dan data sudah benar!',
                          style: TextStyle(
                              color: Colors.amber.withOpacity(0.9),
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
                      'Nama produk yang disubmit', Icons.label_outline),
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
                  decoration: _inputDecoration(
                      'Contoh: 32450000', Icons.payments_outlined),
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
                  maxLines: 3,
                  decoration: _inputDecoration(
                      'Deskripsi produk...', Icons.description_outlined,
                      multiline: true),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Deskripsi wajib diisi' : null,
                ),
                const SizedBox(height: 20),

                // GitHub URL
                _label('GitHub URL'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _githubCtrl,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.url,
                  decoration: _inputDecoration(
                      'https://github.com/username/repo',
                      Icons.link_rounded),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'GitHub URL wajib diisi';
                    if (!v.startsWith('https://github.com/')) {
                      return 'URL harus dimulai dengan https://github.com/';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),

                // Button Submit
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: (_isLoading || _isSubmitted) ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSubmitted
                          ? Colors.green.shade700
                          : const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                      disabledBackgroundColor: _isSubmitted
                          ? Colors.green.shade700
                          : Colors.grey.shade800,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.5),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _isSubmitted
                                    ? Icons.check_circle_rounded
                                    : Icons.upload_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isSubmitted
                                    ? 'Sudah Disubmit'
                                    : 'Submit Tugas',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
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
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide:
            const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }
}