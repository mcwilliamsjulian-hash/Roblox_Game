# Crownfall

A server-authoritative Roblox round game: one player becomes the King, while every
other player becomes a Peasant. The King has a stronger sword and CPU bodyguards;
the Peasants win by defeating the King before time expires.

## Development

The project targets [Rojo 7](https://rojo.space/) and uses strict Luau.

```bash
rojo serve
```

Connect Roblox Studio with the Rojo plugin, then start a local server with at
least two players. For quick solo iteration, set `MinimumPlayers` to `1` in
`src/shared/Config/GameConfig.luau` (solo rounds have no Peasants and therefore
end immediately).

## Rules

- One eligible player is selected as King each round; all others are Peasants.
- The King wins when all Peasants are eliminated or the timer expires.
- The Peasants win when the King is eliminated or leaves the server.
- Eliminated players spectate until the next round.
- Sword hit detection, cooldowns, team checks, and damage are server-owned.
- Bodyguards follow the King, acquire nearby Peasants, and return when leashed.

## Configuration

Balance values are split between:

- `src/shared/Config/GameConfig.luau` — players, timers, health, and spawn layout.
- `src/shared/Config/CombatConfig.luau` — sword and bodyguard combat values.
- `src/shared/Config/BodyguardConfig.luau` — guard count, navigation, and targeting.

## Studio checklist

1. Start a two-or-more-player local server.
2. Confirm exactly one player receives the King role and gold sword.
3. Confirm Peasants receive iron swords and cannot damage one another.
4. Confirm guards attack Peasants, never the King, and return after long chases.
5. Confirm King death, all-Peasant elimination, timer expiry, and King departure
   produce the correct result and a clean next round.
