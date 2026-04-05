import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _kRareGuns = [
  _GunEntry(
    name: 'P4-AR Assault Rifle',
    type: 'Assault Rifle',
    rarity: 'Very Rare',
    manufacturer: 'Behring',
    description:
        'One of the most sought-after ARs in the game. Exceptional accuracy and damage. Extremely low spawn rate — most players never see one.',
    locations: [
      _Location('Checkmate Station – Contested Zone', 'Boss loot pool.', _Risk.extreme),
      _Location('Pyro High-Tier Derelict Outposts', 'Very rare crate spawn.', _Risk.high),
    ],
  ),
  _GunEntry(
    name: 'Railgun (Gemini S71)',
    type: 'Sniper / Railgun',
    rarity: 'Very Rare',
    manufacturer: 'Gemini',
    description:
        'Fires a hypervelocity penetrating round. One of the most powerful ground weapons. Trophy weapon — extremely hard to obtain.',
    locations: [
      _Location('Checkmate CZ Boss', 'Rarest boss drop. May need dozens of runs.', _Risk.extreme),
      _Location('Pyro Derelict Sites (high-tier)', 'Extremely low chance crate spawn.', _Risk.extreme),
    ],
  ),
  _GunEntry(
    name: 'Boomtube',
    type: 'Grenade Launcher',
    rarity: 'Very Rare',
    manufacturer: 'Outlaw',
    description:
        'Explosive launcher with devastating area damage. Rare outlaw weapon found deep in Pyro. Barely seen outside high-end contested zones.',
    locations: [
      _Location('Pyro Contested Zones', 'Outlaw loot pool. Extreme PvP risk.', _Risk.extreme),
      _Location('Checkmate Station Boss', 'Occasional boss loot drop.', _Risk.extreme),
    ],
  ),
  _GunEntry(
    name: 'P6-LR Sniper Rifle',
    type: 'Sniper Rifle',
    rarity: 'Very Rare',
    manufacturer: 'Gemini',
    description:
        'Long-range railgun-style sniper. One of the hardest weapons to obtain. Near-legendary spawn rate.',
    locations: [
      _Location('Checkmate CZ Boss', 'Extremely rare boss drop.', _Risk.extreme),
      _Location('Pyro High-Tier Outposts', 'Very low chance crate spawn.', _Risk.high),
    ],
  ),
  _GunEntry(
    name: 'Atzkav Electron Rifle',
    type: 'Sniper Rifle',
    rarity: 'Rare',
    manufacturer: 'Kastak Arms',
    description:
        'Charges and fires a devastating electron beam. Excels at draining shields before delivering massive damage. Popular for PvP sniping in Pyro.',
    locations: [
      _Location('Checkmate Station – CZ Loot', 'Boss and elite NPC loot pool.', _Risk.extreme),
      _Location('ASD Onyx Research Facilities', 'High-tier loot room crates.', _Risk.high),
    ],
  ),
  _GunEntry(
    name: 'Salvo Frag Pistol',
    type: 'Pistol',
    rarity: 'Rare',
    manufacturer: 'Gemini',
    description:
        'Fires explosive fragmentation rounds — unique mechanic. Devastating at close range. Rare find in Pyro loot crates.',
    locations: [
      _Location('Pyro Derelict Outposts', 'Rare loot crate spawn.', _Risk.high),
      _Location('ASD Facilities', 'Occasional loot room spawn.', _Risk.high),
    ],
  ),
  _GunEntry(
    name: 'Devastator Shotgun',
    type: 'Shotgun',
    rarity: 'Rare',
    manufacturer: 'Apocalypse Arms',
    description:
        'Close-quarters powerhouse. Destroys enemies at close range. Hard to find outside boss loot.',
    locations: [
      _Location('Checkmate Station – CZ', 'Boss loot pool.', _Risk.extreme),
      _Location('Pyro Outposts (high-tier)', 'Rare crate spawn.', _Risk.high),
    ],
  ),
  _GunEntry(
    name: 'Demeco LMG',
    type: 'LMG',
    rarity: 'Rare',
    manufacturer: 'Behring',
    description:
        'Ballistic LMG with drum magazine. Excellent sustained fire. Rare drop from elite NPCs in high-security areas.',
    locations: [
      _Location('ASD Onyx Facilities', 'Elite NPC drops in restricted wings.', _Risk.high),
      _Location('Pyro Contested Zones', 'Rare drop pool.', _Risk.extreme),
    ],
  ),
  _GunEntry(
    name: 'Parallax Sniper Rifle',
    type: 'Sniper Rifle',
    rarity: 'Rare',
    manufacturer: 'Behring',
    description:
        'Ballistic sniper with excellent long-range accuracy. Found in high-tier loot rooms.',
    locations: [
      _Location('ASD Onyx Research Facilities', 'High-tier loot rooms.', _Risk.high),
      _Location('Orbital Station Restricted Areas', 'May require access cards.', _Risk.medium),
    ],
  ),
  _GunEntry(
    name: 'Karna Assault Rifle',
    type: 'Assault Rifle',
    rarity: 'Uncommon',
    manufacturer: 'Kastak Arms',
    description:
        'High damage ballistic AR. Solid mid-tier find from elite NPCs in bunkers and Distribution Centers.',
    locations: [
      _Location('Hurston Bunkers', 'Elite NPC drops.', _Risk.medium),
      _Location('Distribution Centers (various)', 'Loot crates and NPC drops.', _Risk.medium),
    ],
  ),
  _GunEntry(
    name: 'Killshot Rifle',
    type: 'Assault Rifle',
    rarity: 'Very Rare',
    manufacturer: 'Gemini',
    description:
        'One of the most hyped weapons in Star Citizen. High-calibre ballistic AR with exceptional stopping power. Loot-only — cannot be purchased anywhere. Extremely rare drop.',
    locations: [
      _Location('Checkmate Station – Contested Zone', 'Boss and elite NPC loot pool.', _Risk.extreme),
      _Location('Pyro High-Tier Derelict Outposts', 'Very rare crate spawn across Pyro.', _Risk.high),
      _Location('ASD Onyx Research Facilities', 'Occasional high-tier loot room spawn.', _Risk.high),
    ],
  ),
  _GunEntry(
    name: 'LH86 Pistol',
    type: 'Pistol',
    rarity: 'Rare',
    manufacturer: 'Kastak Arms',
    description:
        'Laser pistol with a high fire rate. Rare find but useful as a sidearm. Drops off mid-to-high tier NPCs.',
    locations: [
      _Location('Distribution Centers (various)', 'NPC drops and loot crates.', _Risk.medium),
      _Location('ASD Facilities', 'Loot room spawn.', _Risk.high),
    ],
  ),
  _GunEntry(
    name: 'Animus Missile Launcher',
    type: 'Launcher',
    rarity: 'Very Rare',
    manufacturer: 'Apocalypse Arms',
    description:
        'Ground-based rocket launcher. Devastating against vehicles and groups. Extremely rare — one of the hardest weapons to find in the game.',
    locations: [
      _Location('Checkmate CZ Boss', 'Rare boss loot drop.', _Risk.extreme),
      _Location('Pyro Contested Zones', 'Very low chance outlaw loot.', _Risk.extreme),
    ],
  ),
];

String rareGunsContextBlob() {
  final buf = StringBuffer();
  buf.writeln('=== RARE WEAPONS REFERENCE ===');
  for (final g in _kRareGuns) {
    buf.writeln('${g.name} | ${g.type} | ${g.rarity} | ${g.manufacturer}');
    buf.writeln('  ${g.description}');
    for (final l in g.locations) {
      buf.writeln('  Location: ${l.name} — ${l.notes} [Risk: ${l.risk.label}]');
    }
  }
  buf.writeln('=== END RARE WEAPONS ===');
  return buf.toString();
}

enum _Risk {
  medium('Medium'),
  high('High'),
  extreme('Extreme / PvP');

  const _Risk(this.label);
  final String label;
}

class _Location {
  const _Location(this.name, this.notes, this.risk);
  final String name;
  final String notes;
  final _Risk risk;
}

class _GunEntry {
  const _GunEntry({
    required this.name,
    required this.type,
    required this.rarity,
    required this.manufacturer,
    required this.description,
    required this.locations,
  });
  final String name;
  final String type;
  final String rarity;
  final String manufacturer;
  final String description;
  final List<_Location> locations;
}

const _kRarities = ['All', 'Very Rare', 'Rare', 'Uncommon'];

class RareGunsPage extends StatefulWidget {
  const RareGunsPage({super.key});

  @override
  State<RareGunsPage> createState() => _RareGunsPageState();
}

class _RareGunsPageState extends State<RareGunsPage> {
  String _filter = '';
  String _rarityFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final cyan = Theme.of(context).colorScheme.primary;
    final outline = Theme.of(context).colorScheme.outline;

    final filtered = [..._kRareGuns].where((g) {
      final matchesText = _filter.isEmpty ||
          g.name.toLowerCase().contains(_filter) ||
          g.type.toLowerCase().contains(_filter) ||
          g.manufacturer.toLowerCase().contains(_filter) ||
          g.locations.any((l) => l.name.toLowerCase().contains(_filter));
      final matchesRarity = _rarityFilter == 'All' || g.rarity == _rarityFilter;
      return matchesText && matchesRarity;
    }).toList()..sort((a, b) => _rarityOrder(a.rarity).compareTo(_rarityOrder(b.rarity)));

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: TextField(
              onChanged: (v) => setState(() => _filter = v.toLowerCase().trim()),
              decoration: InputDecoration(
                hintText: 'SEARCH WEAPONS...',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12, letterSpacing: 1),
                prefixIcon: Icon(Icons.search, size: 18, color: cyan),
                suffixIcon: _filter.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 16), onPressed: () => setState(() => _filter = ''))
                    : null,
              ),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _kRarities.map((r) {
                final selected = _rarityFilter == r;
                final color = _chipColor(r, context);
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _rarityFilter = r),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? color.withValues(alpha: 0.2) : Colors.transparent,
                        border: Border.all(color: selected ? color : outline.withValues(alpha: 0.5)),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(r.toUpperCase(),
                          style: TextStyle(
                              color: selected ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 10, letterSpacing: 1.5,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(child: Text('No weapons match your filters',
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => _GunCard(gun: filtered[i], cyan: cyan, outline: outline),
                  ),
          ),
        ],
      ),
    );
  }


  static int _rarityOrder(String rarity) {
    switch (rarity) {
      case 'Boss Loot': return 0;
      case 'Very Rare': return 1;
      case 'Rare': return 2;
      case 'Uncommon': return 3;
      case 'Common': return 4;
      default: return 5;
    }
  }
  Color _chipColor(String r, BuildContext context) {
    switch (r) {
      case 'Very Rare': return const Color(0xFFB44FFF);
      case 'Rare': return const Color(0xFF4FC3F7);
      case 'Uncommon': return const Color(0xFF00FF9C);
      default: return Theme.of(context).colorScheme.primary;
    }
  }
}

class _GunCard extends StatelessWidget {
  const _GunCard({required this.gun, required this.cyan, required this.outline});
  final _GunEntry gun;
  final Color cyan;
  final Color outline;

  Color _rarityColor(BuildContext context) {
    switch (gun.rarity) {
      case 'Very Rare': return const Color(0xFFB44FFF);
      case 'Rare': return const Color(0xFF4FC3F7);
      case 'Uncommon': return const Color(0xFF00FF9C);
      default: return Theme.of(context).colorScheme.onSurface;
    }
  }

  Color _riskColor(_Risk risk) {
    switch (risk) {
      case _Risk.extreme: return const Color(0xFFFF4444);
      case _Risk.high: return const Color(0xFFFF9800);
      case _Risk.medium: return const Color(0xFFFFEB3B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rc = _rarityColor(context);
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: '${gun.name}: ${gun.locations.map((l) => l.name).join(', ')}'));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location copied')));
      },
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: outline.withValues(alpha: 0.5)), borderRadius: BorderRadius.circular(4)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: rc.withValues(alpha: 0.07), borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
              child: Row(
                children: [
                  Container(width: 3, height: 20, color: rc),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(gun.name.toUpperCase(), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1, color: rc)),
                      Text(gun.manufacturer, style: TextStyle(fontSize: 10, color: rc.withValues(alpha: 0.7))),
                    ]),
                  ),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    _Badge(label: gun.rarity, color: rc),
                    const SizedBox(height: 3),
                    _Badge(label: gun.type, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5), border: outline.withValues(alpha: 0.4)),
                  ]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
              child: Text(gun.description, style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.85))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('WHERE TO FIND', style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: cyan.withValues(alpha: 0.7), fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                ...gun.locations.map((l) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(margin: const EdgeInsets.only(top: 4), width: 6, height: 6, decoration: BoxDecoration(color: _riskColor(l.risk), shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(l.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      Text('${l.notes}  •  Risk: ${l.risk.label}', style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                    ])),
                  ]),
                )),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, this.border});
  final String label;
  final Color color;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: border ?? color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(label.toUpperCase(), style: TextStyle(color: color, fontSize: 9, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
    );
  }
}
