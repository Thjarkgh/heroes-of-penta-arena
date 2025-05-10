use crate::arena_action_def_builder;
use crate::{ARCHER, KNIGHT, ROGUE, RITUALIST, MAGE};
// use crate::{WAIT};
// use crate::{SEE_CAST, SEE_DRAW, SEE_MOVE, SEE_RITUAL, SEE_SEARCH_TRAP, NO_EVENT, RECEIVE_ATTACK, WIN};
use crate::{ADD_OBSTACLE};
use crate::{ATTACK_FIREBALL, ATTACK_MELEE, ATTACK_RANGED};
use crate::{MIN_DRAW_ROUNDS_FOR_SHOOT, MAX_DRAW_ROUNDS_FOR_SHOOT, MIN_FIREBALL_ROUNDS_FOR_CAST, MAX_FIREBALL_ROUNDS_FOR_CAST, RITUAL_ROUNDS_FOR_WIN};
use crate::{TRAP, WIN_BY_RITUAL};
use crate::{SerializedArenaActionDefinitions};

pub global SERIALIZED_CHARACTER_BYTES: u32 = 6;
pub type SerializedCharacter = [u8; SERIALIZED_CHARACTER_BYTES];

// use skplam::{build_wait_action_def, build_shoot_action, build_draw_action, build_move_action, build_attack_action, build_cast_action, build_evocation_action, build_search_action, build_set_trap_action, build_sneak_action, build_ritual_action, build_disarm_trap_action};

// this should be more efficient: for all the following: order is: UNKNOWN_CLASS, ARCHER, RITUALIST, ROGUE, KNIGHT, MAGE
global class_damage_melee: [u8; 6] = [ 0, 32, 8, 24, 40, 16 ];
global class_damage_ranged: [u8; 6] = [ 0, 24, 40, 16, 32, 8 ];
global class_damage_fireball: [u8; 6] = [ 0, 0, 100, 50, 0, 100 ];
global class_damage: [[u8; 6]; 3] = [ class_damage_melee, class_damage_ranged, class_damage_fireball ];
global class_energy_per_attack: [u8; 6] = [ 0, 7, 7, 7, 6, 7 ];
global class_energy_per_cast: [u8; 6] = [ 0, 255, 12, 255, 255, 6 ];
global class_energy_per_disarm: [u8; 6] = [ 0, 255, 255, 12, 255, 255 ];
global class_energy_per_move: [u8; 6] = [ 0, 3, 4, 3, 4, 4 ];
global class_energy_per_ritual: [u8; 6] = [ 0, 255, 12, 255, 255, 255 ];
global class_energy_per_search: [u8; 6] = [ 0, 255, 255, 6, 255, 255 ];
global class_energy_per_sneak: [u8; 6] = [ 0, 255, 255, 6, 255, 255 ];
global class_energy_per_draw: [u8; 6] = [ 0, 9, 255, 255, 255, 255 ];
global class_energy_per_shoot: [u8; 6] = [ 0, 6, 255, 255, 255, 255 ];
// global resistances: [u16; 8 * 3] = [
//      0,  75, 100, 85,  50, 100, 20,  0, //,  255, 255, 0, 0, 0, 255, 255, 255 ], // Melee vs dummy, archer, ritualist, thief, knight, mage, wall, water, unknown_class, flag, trap, trap_used, trap_found, body, body_looted, fog
//      0,  80, 100, 90,  25, 100,  5,  0, // 255, 255, 0, 0, 0, 255, 255, 255 ], // Ranged vs dummy, archer, ritualist, thief, knight, mage, wall, water
//      0,  80, 100, 90, 100,  90, 60, 50, // 255, 255, 0, 0, 0, 255, 255, 255 ], // Fireball vs dummy, archer, ritualist, thief, knight, mage, wall, water
// ];

// global trap_resistances: [u16; 8] = [ 0,  75, 100, 50,  75, 90, 5, 0]; //,  255, 255, 255, 255, 255, 255, 255, 255 ]; // Trap vs dummy, archer, ritualist, thief, knight, mage

pub fn get_test_action_register() -> SerializedArenaActionDefinitions {
  let action_builder = arena_action_def_builder;
     [
            std::field::bytes32_to_field(action_builder.build_move_action(class_energy_per_move[ARCHER])),
            std::field::bytes32_to_field(action_builder.build_attack_action(class_energy_per_attack[ARCHER], ATTACK_MELEE, 1, class_damage[0][ARCHER])),
            std::field::bytes32_to_field(action_builder.build_draw_action(3, class_energy_per_draw[ARCHER], 10, ARCHER)),
            std::field::bytes32_to_field(action_builder.build_shoot_action(3, class_energy_per_shoot[ARCHER], ATTACK_RANGED, 8, class_damage[1][ARCHER], 2, MIN_DRAW_ROUNDS_FOR_SHOOT, MAX_DRAW_ROUNDS_FOR_SHOOT)), // arche),
            std::field::bytes32_to_field(action_builder.build_wait_action_def()),
            std::field::bytes32_to_field(action_builder.build_wait_action_def()),
            
            std::field::bytes32_to_field(action_builder.build_move_action(class_energy_per_move[RITUALIST])),
            std::field::bytes32_to_field(action_builder.build_attack_action(class_energy_per_attack[RITUALIST], ATTACK_MELEE, 1, class_damage[0][RITUALIST])),
            std::field::bytes32_to_field(action_builder.build_cast_action(3, class_energy_per_cast[RITUALIST], RITUALIST, 255)),
            std::field::bytes32_to_field(action_builder.build_ritual_action(3, class_energy_per_ritual[RITUALIST], RITUAL_ROUNDS_FOR_WIN, WIN_BY_RITUAL)),
            std::field::bytes32_to_field(action_builder.build_wait_action_def()),
            std::field::bytes32_to_field(action_builder.build_wait_action_def()),

            std::field::bytes32_to_field(action_builder.build_move_action(class_energy_per_move[ROGUE])),
            std::field::bytes32_to_field(action_builder.build_attack_action(class_energy_per_attack[ROGUE], ATTACK_MELEE, 1, class_damage[0][ROGUE])),
            std::field::bytes32_to_field(action_builder.build_sneak_action(class_energy_per_sneak[ROGUE])),
            std::field::bytes32_to_field(action_builder.build_search_action(class_energy_per_search[ROGUE], 1)),
            std::field::bytes32_to_field(action_builder.build_disarm_trap_action(class_energy_per_disarm[ROGUE], 1)),
            std::field::bytes32_to_field(action_builder.build_set_trap_action(class_energy_per_disarm[ROGUE], 1, ADD_OBSTACLE, TRAP)),

            std::field::bytes32_to_field(action_builder.build_move_action(class_energy_per_move[KNIGHT])),
           std::field::bytes32_to_field( action_builder.build_attack_action(class_energy_per_attack[KNIGHT], ATTACK_MELEE, 1, class_damage[0][KNIGHT])),
            std::field::bytes32_to_field(action_builder.build_wait_action_def()),
            std::field::bytes32_to_field(action_builder.build_wait_action_def()),
            std::field::bytes32_to_field(action_builder.build_wait_action_def()),
            std::field::bytes32_to_field(action_builder.build_wait_action_def()),

            std::field::bytes32_to_field(action_builder.build_move_action(class_energy_per_move[MAGE])),
            std::field::bytes32_to_field(action_builder.build_attack_action(class_energy_per_attack[MAGE], ATTACK_MELEE, 1, class_damage[0][MAGE])),
            std::field::bytes32_to_field(action_builder.build_cast_action(3, class_energy_per_cast[MAGE], MAGE, 7)),
            std::field::bytes32_to_field(action_builder.build_evocation_action(3, class_energy_per_cast[MAGE], ATTACK_FIREBALL, 6, 1,class_damage[2][MAGE], 5, MIN_FIREBALL_ROUNDS_FOR_CAST, MAX_FIREBALL_ROUNDS_FOR_CAST)),
            std::field::bytes32_to_field(action_builder.build_wait_action_def()),
            std::field::bytes32_to_field(action_builder.build_wait_action_def())
        ]
}


//global x: ActionDefinition = build_set_trap_action(1 as u8, 1 as u8);
// TODO: move to character!
// global ARCHER: u8 = 1;    WAIT, MOVE, ATTACK, DRAW, SHOOT
// global RITUALIST: u8 = 2; WAIT, MOVE, ATTACK, CAST, RITUAL
// global ROGUE: u8 = 3;     WAIT, MOVE, ATTACK, SNEAK, SEARCH, DISARM_TRAP, SET_TRAP
// global KNIGHT: u8 = 4;    WAIT, MOVE, ATTACK
// global MAGE: u8 = 5;      WAIT, MOVE, ATTACK, CAST, CAST_FIREBALL
// global ACTION_DEFINITIONS: [ActionDefinition; MAX_ACTIONS_PER_CHARACTER * CLASS_COUNT] = [
//     // [[0 as u8; ACTION_DEFINITION_SIZE]; MAX_ACTIONS_PER_CHARACTER], // 0 for no action
//     [0 as u8; ACTION_DEFINITION_SIZE],
//     [0 as u8; ACTION_DEFINITION_SIZE],
//     [0 as u8; ACTION_DEFINITION_SIZE],
//     [0 as u8; ACTION_DEFINITION_SIZE],
//     [0 as u8; ACTION_DEFINITION_SIZE],
//     [0 as u8; ACTION_DEFINITION_SIZE],
//     [0 as u8; ACTION_DEFINITION_SIZE],
    
//         WAIT_ACTION,
//         build_move_action(class_energy_per_move[ARCHER]),
//         build_attack_action(class_energy_per_attack[ARCHER], ATTACK_MELEE, 1, class_damage[0][ARCHER]),
//         build_draw_action(3, class_energy_per_draw[ARCHER], 10, ARCHER),
//         build_shoot_action(3, class_energy_per_shoot[ARCHER], ATTACK_RANGED, 8, class_damage[1][ARCHER], 2, MIN_DRAW_ROUNDS_FOR_SHOOT, MAX_DRAW_ROUNDS_FOR_SHOOT), // archer
//         WAIT_ACTION,
//         WAIT_ACTION,
//     // ],
//     // [
//         WAIT_ACTION,
//         build_move_action(class_energy_per_move[RITUALIST]),
//         build_attack_action(class_energy_per_attack[RITUALIST], ATTACK_MELEE, 1, class_damage[0][RITUALIST]),
//         build_cast_action(3, class_energy_per_cast[RITUALIST], RITUALIST),
//         build_ritual_action(3, class_energy_per_ritual[RITUALIST]),
//         WAIT_ACTION,
//         WAIT_ACTION,
//     // ],
//     // [
//         WAIT_ACTION,
//         build_move_action(class_energy_per_move[ROGUE]),
//         build_attack_action(class_energy_per_attack[ROGUE], ATTACK_MELEE, 1, class_damage[0][ROGUE]),
//         build_sneak_action(class_energy_per_sneak[ROGUE]),
//         build_search_action(class_energy_per_search[ROGUE], 1),
//         build_disarm_trap_action(class_energy_per_disarm[ROGUE], 1),
//         build_set_trap_action(class_energy_per_disarm[ROGUE], 1),
//     // ],
//     // [
//         WAIT_ACTION,
//         build_move_action(class_energy_per_move[KNIGHT]),
//         build_attack_action(class_energy_per_attack[KNIGHT], ATTACK_MELEE, 1, class_damage[0][KNIGHT]),
//         WAIT_ACTION,
//         WAIT_ACTION,
//         WAIT_ACTION,
//         WAIT_ACTION,
//     // ],
//     // [
//         WAIT_ACTION,
//         build_move_action(class_energy_per_move[MAGE]),
//         build_attack_action(class_energy_per_attack[MAGE], ATTACK_MELEE, 1, class_damage[0][MAGE]),
//         build_cast_action(3, class_energy_per_cast[MAGE], MAGE),
//         build_evocation_action(3, class_energy_per_cast[MAGE], ATTACK_FIREBALL, 6, 1,class_damage[2][MAGE], 5, FIREBALL_ROUNDS_FOR_CAST, FIREBALL_ROUNDS_FOR_CAST),
//         WAIT_ACTION,
//         WAIT_ACTION
//     // ]
// ];
// global 
// pub fn get_test_action_register() -> [u8; ACTION_DEFINITION_REGISTER_SIZE] {
//     build_action_def_reg!([
//         [
//             build_move_action(class_energy_per_move[ARCHER]),
//             build_attack_action(class_energy_per_attack[ARCHER], ATTACK_MELEE, 1, class_damage[0][ARCHER]),
//             build_draw_action(3, class_energy_per_draw[ARCHER], 10, ARCHER),
//             build_shoot_action(3, class_energy_per_shoot[ARCHER], ATTACK_RANGED, 8, class_damage[1][ARCHER], 2, MIN_DRAW_ROUNDS_FOR_SHOOT, MAX_DRAW_ROUNDS_FOR_SHOOT), // archer
//             build_wait_action_def(),
//             build_wait_action_def(),
//         ],
//         [
//             build_move_action(class_energy_per_move[RITUALIST]),
//             build_attack_action(class_energy_per_attack[RITUALIST], ATTACK_MELEE, 1, class_damage[0][RITUALIST]),
//             build_cast_action(3, class_energy_per_cast[RITUALIST], RITUALIST),
//             build_ritual_action(3, class_energy_per_ritual[RITUALIST]),
//             build_wait_action_def(),
//             build_wait_action_def(),
//         ],
//         [
//             build_move_action(class_energy_per_move[ROGUE]),
//             build_attack_action(class_energy_per_attack[ROGUE], ATTACK_MELEE, 1, class_damage[0][ROGUE]),
//             build_sneak_action(class_energy_per_sneak[ROGUE]),
//             build_search_action(class_energy_per_search[ROGUE], 1),
//             build_disarm_trap_action(class_energy_per_disarm[ROGUE], 1),
//             build_set_trap_action(class_energy_per_disarm[ROGUE], 1),
//         ],
//         [
//             build_move_action(class_energy_per_move[KNIGHT]),
//             build_attack_action(class_energy_per_attack[KNIGHT], ATTACK_MELEE, 1, class_damage[0][KNIGHT]),
//             build_wait_action_def(),
//             build_wait_action_def(),
//             build_wait_action_def(),
//             build_wait_action_def(),
//         ],
//         [
//             build_move_action(class_energy_per_move[MAGE]),
//             build_attack_action(class_energy_per_attack[MAGE], ATTACK_MELEE, 1, class_damage[0][MAGE]),
//             build_cast_action(3, class_energy_per_cast[MAGE], MAGE),
//             build_evocation_action(3, class_energy_per_cast[MAGE], ATTACK_FIREBALL, 6, 1,class_damage[2][MAGE], 5, MIN_FIREBALL_ROUNDS_FOR_CAST, MAX_FIREBALL_ROUNDS_FOR_CAST),
//             build_wait_action_def(),
//             build_wait_action_def()
//         ]
//     ])
// }

