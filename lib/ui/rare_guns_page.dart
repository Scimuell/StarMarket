import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Static rare gun reference data — update when new weapons are found in-game.
const _kRareGuns = [
  _GunEntry(
    name: 'Atzkav Sniper Rifle',
    type: 'Sniper Rifle',
    rarity: 'Rare',
    manufacturer: 'Kastak Arms',
    description:
        'A powerful electron-based sniper rifle. Charges a devastating beam shot. Popular for long-range PvP and PvE in Pyro.',
    locations: [
      _Location('Checkmate Station – Contested Zone', 'Rare loot crate drop. Clear the CZ first.', _Risk.extreme),
      _Location('Pyro Derelict Outposts', 'Loot crates across random outposts in Pyro.', _Risk.high),
    ],
  ),
  _GunEntry(
    name: 'Karna Assault Rifle',
    type: 'Assault Rifle',
    rarity: 'Uncommon',
    manufacturer: 'Kastak Arms',
    description:
        'High damage ballistic AR. Drops frequently off elite NPCs in bunkers and Distribution Centers.',
    locations: [
      _Location('Hurston Bunkers', 'Elite NPC drops. Chain bunker contracts.', _Risk.medium),
      _Location('Distribution Centers (various)', 'Loot crates and NPC drops.', _Risk.medium),
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
      _Location('ASD Onyx Research Facilities', 'High-tier loot rooms on both wings.', _Risk.high),
      _Location('Orbital Station Restricted Areas', 'May require access cards.', _Risk.medium),
    ],
  ),
  _GunEntry(
    name: 'Devastator Shotgun',
    type: 'Shotgun',
    rarity: 'Rare',
    manufacturer: 'Apocalypse Arms',
    description:
        'Close-quarters powerhouse. Hard to find outside boss loot and high-tier outposts.',
    locations: [
      _Location('Checkmate Station – Contested Zone', 'Boss loot pool. High PvP risk.', _Risk.extreme),
      _Location('Pyro Outposts (high-tier)', 'Rare crate spawn.', _Risk.high),
    ],
  ),
  _GunEntry(
    name: 'F-55 LMG',
    type: 'LMG',
    rarity: 'Uncommon',
    manufacturer: 'Klaus & Werner',
    description:
        'Sustained-fire laser LMG. Good for ship boarding and close-combat suppression.',
    locations: [
      _Location('Security Post Kareah', 'Drops off mercenary NPCs.', _Risk.medium),
      _Location('Distribution Centers (various)', 'Loot crates.', _Risk.medium),
    ],
  ),
  _GunEntry(
    name: 'Gallant Rifle',
    type: 'Assault Rifle',
    rarity: 'Uncommon',
    manufacturer: 'Klaus & Werner',
    description:
        'Reliable laser AR. Drops off security NPCs fairly often.',
    locations: [
      _Location('Hurston Security NPCs', 'Standard loot drop.', _Risk.medium),
      _Location('Bunker Missions', 'Common in security NPC loot pool.', _Risk.medium),
    ],
  ),
  _GunEntry(
    name: 'Custodian SMG',
    type: 'SMG',
    rarity: 'Uncommon',
    manufacturer: 'Klaus & Werner',
    description:
        'Laser SMG with a solid fire rate. Good for CQB. Drops off mid-tier security.',
    locations: [
      _Location('Bunkers (various)', 'Mid-tier NPC drops.', _Risk.medium),
      _Location('Distribution Centers', 'Loot crate pool.', _Risk.medium),
    ],
  ),
  _GunEntry(
    name: 'Demeco LMG',
    type: 'LMG',
    rarity: 'Rare',
    manufacturer: 'Behring',
    description:
        'Ballistic LMG with a drum magazine. Rare drop from elite NPCs in high-security areas.',
    locations: [
      _Location('ASD Onyx Facilities', 'Elite NPC drops in restricted wings.', _Risk.high),
      _Location('Pyro Contested Zones', 'Rare drop pool.', _Risk.extreme),
    ],
  ),
  _GunEntry(
    name: 'Arclight Pistol',
    type: 'Pistol',
    rarity: 'Common',
    manufacturer: 'Klaus & Werner',
    description:
        'Energy sidearm found everywhere. Good starting pistol. Not rare but worth knowing for loadouts.',
    locations: [
      _Location('Shops (most stations)', 'Available to buy at most kiosks.', _Risk.medium),
    ],
  ),
  _GunEntry(
    name: 'P6-LR Sniper Rifle',
    type: 'Sniper Rifle',
    rarity: 'Very Rare',
    manufacturer: 'Gemini',
    description:
        'Extremely powerful railgun-style sniper. Rarely spawns in Pyro boss loot. One of the hardest weapons to obtain.',
    locations: [
      _Location('Checkmate CZ Boss', 'Extremely rare drop. May need many runs.', _Risk.extreme),
      _Location('Pyro High-Tier Outposts', 'Very low chance crate spawn.', _Risk.high),
    ],
  ),
  _GunEntry(
    name: 'BR2 Shotgun',
    type: 'Shotgun',
    rarity: 'Uncommon',
    manufacturer: 'Apocalypse Arms',
    description:
        'Pump-action ballistic shotgun. Reliable close-range option found in mid-tier loot.',
    locations: [
      _Location('Bunker Missions', 'NPC drops and loot crates.', _Risk.medium),
      _Location('Distribution Centers', 'Loot crate pool.', _Risk.medium),
    ],
  ),
  _GunEntry(
    name: 'Salvo Frag Pistol',
    type: 'Pistol',
    rarity: 'Rare',
    manufacturer: 'Gemini',
    description:
        'Fires explosive fragmentation rounds — unique mechanic. Rare find in Pyro outpost loot.',
    locations: [
      _Location('Pyro Derelict Outposts', 'Rare loot crate spawn.', _Risk.high),
      _Location('ASD Facilities', 'Occasional loot room spawn.', _Risk.high),
    ],
  ),
];

/// Plain-text summary for the AI context window.
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

// ─── Data model ──────────────────────────────────────────────────────────────

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

// ─── Page ─────────────────────────────────────────────────────────────────────

class RareGunsPage extends StatefulWidget {
  const RareGunsPage({super.key});

  @override
  State<RareGunsPage> createState() => _RareGunsPageState();
}

class _RareGunsPageState extends State<RareGunsPage> {
  String _filter = '';

  @override
  Widget build(BuildContext context) {
    final cyan = Theme.of(context).colorScheme.primary;
    final outline = Theme.of(context).colorScheme.outline;

    final filtered = _filter.isEmpty
        ? _kRareGuns
        : _kRareGuns
            .where((g) =>
                g.name.toLowerCase().contains(_filter) ||
                g.type.toLowerCase().contains(_filter) ||
                g.rarity.toLowerCase().contains(_filter) ||
                g.manufacturer.toLowerCase().contains(_filter) ||
                g.locations.any((l) => l.name.toLowerCase().contains(_filter)))
            .toList();

    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => _filter = v.toLowerCase().trim()),
              decoration: InputDecoration(
                hintText: 'SEARCH WEAPONS...',
                hintStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4), fontSize: 12, letterSpacing: 1),
                prefixIcon: Icon(Icons.search, size: 18, color: cyan),
                suffixIcon: _filter.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () => setState(() => _filter = ''),
                      )
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Long-press any card to copy location. AI Advisor knows all weapons listed here.',
                    style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No weapons match "$_filter"',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)),
                    ),
                  )
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
}

class _GunCard extends StatelessWidget {
  const _GunCard({required this.gun, required this.cyan, required this.outline});
  final _GunEntry gun;
  final Color cyan;
  final Color outline;

  Color _rarityColor(BuildContext context) {
    switch (gun.rarity) {
      case 'Very Rare':
        return const Color(0xFFB44FFF);
      case 'Rare':
        return const Color(0xFF4FC3F7);
      case 'Uncommon':
        return const Color(0xFF00FF9C);
      case 'Common':
        return Theme.of(context).colorScheme.onSurface;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  Color _riskColor(_Risk risk) {
    switch (risk) {
      case _Risk.extreme:
        return const Color(0xFFFF4444);
      case _Risk.high:
        return const Color(0xFFFF9800);
      case _Risk.medium:
        return const Color(0xFFFFEB3B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final rarityColor = _rarityColor(context);
    return GestureDetector(
      onLongPress: () {
        final locationText = gun.locations.map((l) => l.name).join(', ');
        Clipboard.setData(ClipboardData(text: '${gun.name}: $locationText'));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location copied to clipboard')),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: outline.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: rarityColor.withValues(alpha: 0.07),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Row(
                children: [
                  Container(width: 3, height: 20, color: rarityColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gun.name.toUpperCase(),
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1, color: rarityColor),
                        ),
                        Text(
                          gun.manufacturer,
                          style: TextStyle(fontSize: 10, color: rarityColor.withValues(alpha: 0.7), letterSpacing: 0.5),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: rarityColor.withValues(alpha: 0.15),
                          border: Border.all(color: rarityColor.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(gun.rarity.toUpperCase(),
                            style: TextStyle(color: rarityColor, fontSize: 9, letterSpacing: 1.5, fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.07),
                          border: Border.all(color: outline.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(gun.type.toUpperCase(),
                            style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7), fontSize: 9, letterSpacing: 1.2)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Description
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 6),
              child: Text(gun.description,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8))),
            ),
            // Locations
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('WHERE TO FIND',
                      style: TextStyle(fontSize: 9, letterSpacing: 1.5, color: cyan.withValues(alpha: 0.7), fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  ...gun.locations.map((l) {
                    final riskColor = _riskColor(l.risk);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(color: riskColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                Text(
                                  '${l.notes}  •  Risk: ${l.risk.label}',
                                  style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
