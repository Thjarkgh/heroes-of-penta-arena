global TARGET_TYPE_SELF = 0;
global TARGET_TYPE_ALLY = 1;
global TARGET_TYPE_TILE = 2;
global TARGET_TYPE_ALL = 3;

global STAT_HP = 0;
global STAT_CONCENTRATION = 1;
global STAT_MORALE = 2;
global STAT_ATTACK = 3;
global STAT_DEFENSE = 4;
global STAT_DODGE = 5;
global STAT_RESISTANCE_DROWNING = 6;
global STAT_RESISTANCE_FALLING = 7;
global STAT_RESISTANCE_BLUNT = 8;
global STAT_RESISTANCE_PIERCE = 9;
global STAT_RESISTANCE_SLASH = 10;
global STAT_RESISTANCE_ACID = 11;
global STAT_RESISTANCE_FIRE = 12;
global STAT_RESISTANCE_COLD = 13;
global STAT_RESISTANCE_LIGHTNING = 14;
global STAT_RESISTANCE_POISON = 15;

// makes 16 bytes
// + 5 bytes for the old stats (health overlaps with hp) = 21 bytes => leaves 10 bytes for attacks
let abjurer = {
    attacks: [
        {
            // Mage Armor
            effects: [
                {
                    target_type: TARGET_TYPE_SELF, // nibble
                    target_radius: 0, // nibble
                    affected_stat: STAT_DEFENSE, // byte
                    value: 2 // byte
                }
            ]
        }
    ]
}