import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../db/app_db.dart';
import '../services/ai_service.dart';
import '../services/price_catalog_api.dart';
import '../services/supabase_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, required this.db});
  final AppDatabase db;
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _ai = AiService();
  final _priceApi = PriceCatalogApiService();
  final _supa = SupabaseService.instance;

  // AI
  final _base = TextEditingController();
  final _model = TextEditingController();
  final _key = TextEditingController();
  String _aiProvider = 'openai';
  bool _showKey = false;

  // Catalog API
  final _catUrl = TextEditingController();
  final _catRootKey = TextEditingController();
  final _catPatch = TextEditingController();
  final _catPostBody = TextEditingController();
  final _catSecret = TextEditingController();
  String _catMethod = 'get';
  String _catAuth = 'none';
  bool _showCatSecret = false;

  // Supabase
  final _supaUrl = TextEditingController();
  final _supaKey = TextEditingController();
  bool _supaEnabled = false;
  bool _showSupaKey = false;

  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _base.dispose(); _model.dispose(); _key.dispose();
    _catUrl.dispose(); _catRootKey.dispose(); _catPatch.dispose();
    _catPostBody.dispose(); _catSecret.dispose();
    _supaUrl.dispose(); _supaKey.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    _aiProvider = await _ai.getProvider();
    _base.text = await _ai.getBaseUrl();
    _model.text = await _ai.getModel();
    _key.text = await _ai.getApiKey() ?? '';
    _catUrl.text = await _priceApi.getUrl();
    _catRootKey.text = await _priceApi.getJsonRootKey();
    _catPatch.text = await _priceApi.getDefaultPatch();
    _catPostBody.text = await _priceApi.getPostBody();
    _catMethod = await _priceApi.getMethod();
    _catAuth = await _priceApi.getAuthMode();
    _catSecret.text = await _priceApi.getSecret() ?? '';
    _supaUrl.text = await _supa.getUrl();
    _supaKey.text = await _supa.getAnonKey() ?? '';
    _supaEnabled = await _supa.isEnabled();
    if (mounted) setState(() {});
  }

  Future<void> _saveAi() async {
    await _ai.setProvider(_aiProvider);
    await _ai.setBaseUrl(_base.text.trim());
    await _ai.setModel(_model.text.trim());
    await _ai.setApiKey(_key.text.trim());
    _snack('AI settings saved.');
  }

  void _fillGroq() => setState(() {
    _aiProvider = 'openai';
    _base.text = AiService.groqDefaultBase;
    _model.text = AiService.groqDefaultModel;
  });

  void _fillOpenAi() => setState(() {
    _aiProvider = 'openai';
    _base.text = 'https://api.openai.com';
    _model.text = 'gpt-4o-mini';
  });

  Future<void> _saveCatalogApi() async {
    await _priceApi.setUrl(_catUrl.text.trim());
    await _priceApi.setMethod(_catMethod);
    await _priceApi.setPostBody(_catPostBody.text);
    await _priceApi.setJsonRootKey(_catRootKey.text.trim());
    await _priceApi.setDefaultPatch(_catPatch.text.trim().isEmpty ? '4.7' : _catPatch.text.trim());
    await _priceApi.setAuthMode(_catAuth);
    await _priceApi.setSecret(_catSecret.text.trim());
    _snack('Catalog API settings saved.');
  }

  Future<void> _syncCatalog() async {
    setState(() => _busy = true);
    try {
      await _saveCatalogApi();
      final map = await _priceApi.fetchCatalog();
      await widget.db.importCatalogJson(map);
      final count = await widget.db.catalogItemCount();
      final itemList = map['items'] as List?;
      final firstName = (itemList != null && itemList.isNotEmpty)
          ? (itemList.first['name']?.toString() ?? 'no name field')
          : 'list empty';
      if (mounted) _snack('Synced. DB has $count items. First: $firstName');
    } catch (e) {
      if (mounted) _snack('Sync failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _importFile() async {
    setState(() => _busy = true);
    try {
      final r = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: const ['json']);
      if (r == null || r.files.isEmpty) return;
      final f = r.files.single;
      final String txt;
      if (f.path != null) {
        txt = await File(f.path!).readAsString();
      } else if (f.bytes != null) {
        txt = utf8.decode(f.bytes!);
      } else {
        throw StateError('Could not read file.');
      }
      await widget.db.importCatalogJson(jsonDecode(txt) as Map<String, dynamic>);
      _snack('Catalog imported.');
    } catch (e) {
      _snack('Import failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reloadSeed() async {
    setState(() => _busy = true);
    try {
      final raw = await rootBundle.loadString('assets/catalog_seed.json');
      await widget.db.importCatalogJson(jsonDecode(raw) as Map<String, dynamic>);
      _snack('Seed reimported.');
    } catch (e) {
      _snack('Failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _clearCatalog() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('CLEAR CATALOG?'),
        content: const Text('Removes all catalog items and offers. Logs, alerts and trades are not affected.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('CLEAR')),
        ],
      ),
    );
    if (confirm != true) return;
    setState(() => _busy = true);
    try {
      await widget.db.clearCatalog();
      _snack('Catalog cleared.');
    } catch (e) {
      _snack('Failed: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _saveSupabase() async {
    await _supa.setUrl(_supaUrl.text.trim());
    await _supa.setAnonKey(_supaKey.text.trim());
    await _supa.setEnabled(_supaEnabled);
    _snack('Supabase settings saved.');
  }

  Future<void> _testSupabase() async {
    setState(() => _busy = true);
    await _saveSupabase();
    try {
      final err = await _supa.testConnection();
      _snack(err == null ? 'Connected to Supabase.' : err);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _uploadToSupabase() async {
    setState(() => _busy = true);
    await _saveSupabase();
    try {
      final result = await _supa.uploadCatalog(widget.db);
      _snack(result.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final cyan = Theme.of(context).colorScheme.primary;
    final outline = Theme.of(context).colorScheme.outline;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: cyan,
          labelColor: cyan,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
          labelStyle: const TextStyle(fontSize: 11, letterSpacing: 1.5, fontWeight: FontWeight.w700, fontFamily: 'monospace'),
          tabs: const [
            Tab(text: 'AI'),
            Tab(text: 'CATALOG'),
            Tab(text: 'SUPABASE'),
          ],
        ),
      ),
      body: AbsorbPointer(
        absorbing: _busy,
        child: TabBarView(
          controller: _tabs,
          children: [
            _aiTab(cyan, outline),
            _catalogTab(cyan, outline),
            _supabaseTab(cyan, outline),
          ],
        ),
      ),
    );
  }

  Widget _aiTab(Color cyan, Color outline) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Label('QUICK PRESETS'),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: OutlinedButton.icon(
            onPressed: _fillGroq,
            icon: const Icon(Icons.bolt, size: 14),
            label: const Text('GROQ'),
          )),
          const SizedBox(width: 8),
          Expanded(child: OutlinedButton.icon(
            onPressed: _fillOpenAi,
            icon: const Icon(Icons.smart_toy_outlined, size: 14),
            label: const Text('OPENAI'),
          )),
        ]),
        const SizedBox(height: 20),
        _Label('PROVIDER'),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _aiProvider,
          decoration: const InputDecoration(labelText: 'Provider type'),
          items: const [
            DropdownMenuItem(value: 'openai', child: Text('OpenAI-compatible')),
            DropdownMenuItem(value: 'gemini', child: Text('Google Gemini')),
          ],
          onChanged: (v) => setState(() => _aiProvider = v ?? 'openai'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _base,
          decoration: const InputDecoration(labelText: 'API Base URL'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _model,
          decoration: const InputDecoration(labelText: 'Model name'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _key,
          obscureText: !_showKey,
          decoration: InputDecoration(
            labelText: 'API Key',
            suffixIcon: IconButton(
              onPressed: () => setState(() => _showKey = !_showKey),
              icon: Icon(_showKey ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: _saveAi,
          child: const Text('SAVE AI SETTINGS'),
        )),
      ],
    );
  }

  Widget _catalogTab(Color cyan, Color outline) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _Label('QUICK PRESETS'),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          _PresetChip('SC-API Ships', () => setState(() {
            _catMethod = 'get'; _catAuth = 'path_key';
            _catUrl.text = PriceCatalogApiService.starcitizenApiComShipsCacheUrlTemplate;
            _catRootKey.clear();
          })),
          _PresetChip('UEX Commodities', () => setState(() {
            _catMethod = 'get'; _catAuth = 'bearer';
            _catUrl.text = PriceCatalogApiService.uexCommoditiesPricesAllUrl;
            _catRootKey.clear();
          })),
          _PresetChip('UEX Items', () => setState(() {
            _catMethod = 'get'; _catAuth = 'bearer';
            _catUrl.text = PriceCatalogApiService.uexItemsPricesAllUrl;
            _catRootKey.clear();
          })),
        ]),
        const SizedBox(height: 20),
        _Label('SYNC SETTINGS'),
        const SizedBox(height: 8),
        TextField(controller: _catUrl, decoration: const InputDecoration(labelText: 'Catalog URL')),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _catMethod,
          decoration: const InputDecoration(labelText: 'HTTP Method'),
          items: const [
            DropdownMenuItem(value: 'get', child: Text('GET')),
            DropdownMenuItem(value: 'post', child: Text('POST')),
          ],
          onChanged: (v) => setState(() => _catMethod = v ?? 'get'),
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          value: _catAuth,
          decoration: const InputDecoration(labelText: 'Auth mode'),
          items: const [
            DropdownMenuItem(value: 'none', child: Text('None')),
            DropdownMenuItem(value: 'bearer', child: Text('Bearer token')),
            DropdownMenuItem(value: 'x_api_key', child: Text('X-Api-Key header')),
            DropdownMenuItem(value: 'path_key', child: Text('Key in URL — SC-API.com')),
          ],
          onChanged: (v) => setState(() => _catAuth = v ?? 'none'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _catSecret,
          obscureText: !_showCatSecret,
          decoration: InputDecoration(
            labelText: 'API token / key',
            suffixIcon: IconButton(
              onPressed: () => setState(() => _showCatSecret = !_showCatSecret),
              icon: Icon(_showCatSecret ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextField(controller: _catRootKey, decoration: const InputDecoration(labelText: 'JSON root key (optional)', hintText: 'e.g. data')),
        const SizedBox(height: 10),
        TextField(controller: _catPatch, decoration: const InputDecoration(labelText: 'Default patch label')),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: _saveCatalogApi, child: const Text('SAVE'))),
          const SizedBox(width: 8),
          Expanded(child: FilledButton(onPressed: _busy ? null : _syncCatalog, child: const Text('SYNC NOW'))),
        ]),
        const SizedBox(height: 20),
        _Label('OFFLINE / FILE'),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _busy ? null : _importFile,
          icon: const Icon(Icons.upload_file_outlined, size: 16),
          label: const Text('IMPORT CATALOG JSON'),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: _busy ? null : _reloadSeed, child: const Text('Re-import bundled seed')),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _busy ? null : _clearCatalog,
          style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
          child: const Text('CLEAR ENTIRE CATALOG'),
        ),
        if (_busy) const Padding(padding: EdgeInsets.only(top: 16), child: Center(child: CircularProgressIndicator())),
      ],
    );
  }

  Widget _supabaseTab(Color cyan, Color outline) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cyan.withValues(alpha: 0.07),
            border: Border.all(color: cyan.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'Connect Supabase so the AI fetches only relevant catalog rows per query — dramatically reducing OpenAI token usage. Upload your catalog once, it persists permanently.',
            style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface),
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          value: _supaEnabled,
          onChanged: (v) => setState(() => _supaEnabled = v),
          title: const Text('Enable Supabase AI mode', style: TextStyle(fontSize: 13)),
          subtitle: Text(_supaEnabled ? 'AI queries Supabase — minimal tokens' : 'AI uses full local catalog',
              style: const TextStyle(fontSize: 11)),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 10),
        TextField(controller: _supaUrl, decoration: const InputDecoration(labelText: 'Project URL', hintText: 'https://xxxx.supabase.co')),
        const SizedBox(height: 10),
        TextField(
          controller: _supaKey,
          obscureText: !_showSupaKey,
          decoration: InputDecoration(
            labelText: 'Anon key',
            suffixIcon: IconButton(
              onPressed: () => setState(() => _showSupaKey = !_showSupaKey),
              icon: Icon(_showSupaKey ? Icons.visibility_off_outlined : Icons.visibility_outlined),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: OutlinedButton(onPressed: _busy ? null : _testSupabase, child: const Text('TEST'))),
          const SizedBox(width: 8),
          Expanded(child: FilledButton(onPressed: _busy ? null : _saveSupabase, child: const Text('SAVE'))),
        ]),
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, child: OutlinedButton.icon(
          onPressed: _busy ? null : _uploadToSupabase,
          icon: const Icon(Icons.cloud_upload_outlined, size: 16),
          label: const Text('UPLOAD CATALOG TO SUPABASE'),
        )),
        const SizedBox(height: 12),
        _Label('SETUP GUIDE'),
        const SizedBox(height: 8),
        _Step('1', 'Go to supabase.com → New project'),
        _Step('2', 'Open SQL Editor, run the schema (see GitHub README)'),
        _Step('3', 'Settings → API → copy Project URL and anon key'),
        _Step('4', 'Paste above, tap Save, then Test'),
        _Step('5', 'Tap Upload — only needed once per UEX sync'),
        if (_busy) const Padding(padding: EdgeInsets.only(top: 16), child: Center(child: CircularProgressIndicator())),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 2, height: 11, color: Theme.of(context).colorScheme.primary),
      const SizedBox(width: 7),
      Text(text, style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.w700)),
    ]);
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip(this.label, this.onTap);
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final cyan = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: cyan.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(label, style: TextStyle(color: cyan, fontSize: 11, letterSpacing: 0.5)),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step(this.num, this.text);
  final String num;
  final String text;
  @override
  Widget build(BuildContext context) {
    final cyan = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 20, height: 20,
          decoration: BoxDecoration(color: cyan.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(2)),
          child: Center(child: Text(num, style: TextStyle(color: cyan, fontSize: 11, fontWeight: FontWeight.w700))),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface))),
      ]),
    );
  }
}
