
use arenalib::ARCHER;
use arenalib::KNIGHT;
use arenalib::MAGE;
use arenalib::RITUALIST;
use arenalib::ROGUE;
use arenalib::WIDTH;
use arenalib::HEIGHT;
use arenalib::{ CLASS_COUNT, PROGRESS_COUNT };
use arenalib::{ WAIT }; //, ATTACK_MELEE, ATTACK_FIREBALL, ATTACK_RANGED, MAX_FIREBALL_ROUNDS_FOR_CAST, MIN_FIREBALL_ROUNDS_FOR_CAST, MIN_DRAW_ROUNDS_FOR_SHOOT, MAX_DRAW_ROUNDS_FOR_SHOOT };
use arenalib::{ MAX_CHARACTERS, MAX_EVENTS, MAX_OBSTACLES, MAX_ACTIONS_PER_CHARACTER };
use arenalib::{ WIDTH_MASK, HEIGHT_MASK, CLASS_MASK, PROGRESS_MASK };
use arenalib::{ WIDTH_BITS, HEIGHT_BITS, CLASS_BITS, PROGRESS_BITS };
use crate::event::Event;
use crate::map::is_visible;
use crate::obstacle::Obstacle;
use crate::obstacle::new_obstacle;
use skplg::{NOWHERE, debug, softassert};
use arenalib::{ActionDefinition};
use arenalib::{SerializedArenaCharacterRoster, SerializedArenaActionDefinitions, SerializedArenaCharacterActionDefinitions, SerializedArenaCharacterActionDefinition};
// use arenalib::{TRAP, ADD_OBSTACLE, WIN_BY_RITUAL, RITUAL_ROUNDS_FOR_WIN};
use arenalib::get_test_action_register;
use crate::event::{build_subtype_value_event, serialize_events};
use arenalib::NO_EVENT;
use arenalib::get_wait_action_def;


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
global resistances: [u16; 8 * 3] = [
     0,  75, 100, 85,  50, 100, 20,  0, //,  255, 255, 0, 0, 0, 255, 255, 255 ], // Melee vs dummy, archer, ritualist, thief, knight, mage, wall, water, unknown_class, flag, trap, trap_used, trap_found, body, body_looted, fog
     0,  80, 100, 90,  25, 100,  5,  0, // 255, 255, 0, 0, 0, 255, 255, 255 ], // Ranged vs dummy, archer, ritualist, thief, knight, mage, wall, water
     0,  80, 100, 90, 100,  90, 60, 50, // 255, 255, 0, 0, 0, 255, 255, 255 ], // Fireball vs dummy, archer, ritualist, thief, knight, mage, wall, water
];

global trap_resistances: [u16; 8] = [ 0,  75, 100, 50,  75, 90, 5, 0]; //,  255, 255, 255, 255, 255, 255, 255, 255 ]; // Trap vs dummy, archer, ritualist, thief, knight, mage


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
// pub fn get_test_action_register() -> SerializedArenaActionDefinitions {
//   let action_builder = arena_action_def_builder;
//      [
//             std::field::bytes32_to_field(action_builder.build_move_action(class_energy_per_move[ARCHER])),
//             std::field::bytes32_to_field(action_builder.build_attack_action(class_energy_per_attack[ARCHER], ATTACK_MELEE, 1, class_damage[0][ARCHER])),
//             std::field::bytes32_to_field(action_builder.build_draw_action(3, class_energy_per_draw[ARCHER], 10, ARCHER)),
//             std::field::bytes32_to_field(action_builder.build_shoot_action(3, class_energy_per_shoot[ARCHER], ATTACK_RANGED, 8, class_damage[1][ARCHER], 2, MIN_DRAW_ROUNDS_FOR_SHOOT, MAX_DRAW_ROUNDS_FOR_SHOOT)), // arche),
//             std::field::bytes32_to_field(action_builder.build_wait_action_def()),
//             std::field::bytes32_to_field(action_builder.build_wait_action_def()),
            
//             std::field::bytes32_to_field(action_builder.build_move_action(class_energy_per_move[RITUALIST])),
//             std::field::bytes32_to_field(action_builder.build_attack_action(class_energy_per_attack[RITUALIST], ATTACK_MELEE, 1, class_damage[0][RITUALIST])),
//             std::field::bytes32_to_field(action_builder.build_cast_action(3, class_energy_per_cast[RITUALIST], RITUALIST, 255)),
//             std::field::bytes32_to_field(action_builder.build_ritual_action(3, class_energy_per_ritual[RITUALIST], RITUAL_ROUNDS_FOR_WIN, WIN_BY_RITUAL)),
//             std::field::bytes32_to_field(action_builder.build_wait_action_def()),
//             std::field::bytes32_to_field(action_builder.build_wait_action_def()),

//             std::field::bytes32_to_field(action_builder.build_move_action(class_energy_per_move[ROGUE])),
//             std::field::bytes32_to_field(action_builder.build_attack_action(class_energy_per_attack[ROGUE], ATTACK_MELEE, 1, class_damage[0][ROGUE])),
//             std::field::bytes32_to_field(action_builder.build_sneak_action(class_energy_per_sneak[ROGUE])),
//             std::field::bytes32_to_field(action_builder.build_search_action(class_energy_per_search[ROGUE], 1)),
//             std::field::bytes32_to_field(action_builder.build_disarm_trap_action(class_energy_per_disarm[ROGUE], 1)),
//             std::field::bytes32_to_field(action_builder.build_set_trap_action(class_energy_per_disarm[ROGUE], 1, ADD_OBSTACLE, TRAP)),

//             std::field::bytes32_to_field(action_builder.build_move_action(class_energy_per_move[KNIGHT])),
//            std::field::bytes32_to_field( action_builder.build_attack_action(class_energy_per_attack[KNIGHT], ATTACK_MELEE, 1, class_damage[0][KNIGHT])),
//             std::field::bytes32_to_field(action_builder.build_wait_action_def()),
//             std::field::bytes32_to_field(action_builder.build_wait_action_def()),
//             std::field::bytes32_to_field(action_builder.build_wait_action_def()),
//             std::field::bytes32_to_field(action_builder.build_wait_action_def()),

//             std::field::bytes32_to_field(action_builder.build_move_action(class_energy_per_move[MAGE])),
//             std::field::bytes32_to_field(action_builder.build_attack_action(class_energy_per_attack[MAGE], ATTACK_MELEE, 1, class_damage[0][MAGE])),
//             std::field::bytes32_to_field(action_builder.build_cast_action(3, class_energy_per_cast[MAGE], MAGE, 7)),
//             std::field::bytes32_to_field(action_builder.build_evocation_action(3, class_energy_per_cast[MAGE], ATTACK_FIREBALL, 6, 1,class_damage[2][MAGE], 5, MIN_FIREBALL_ROUNDS_FOR_CAST, MAX_FIREBALL_ROUNDS_FOR_CAST)),
//             std::field::bytes32_to_field(action_builder.build_wait_action_def()),
//             std::field::bytes32_to_field(action_builder.build_wait_action_def())
//         ]
// }

// struct CharacterClass {
//     class: u8,
//     damage: u8,
//     energy_per_attack: u8,
//     energy_per_cast: u8,
//     energy_per_disarm: u8,
//     energy_per_move: u8,
//     energy_per_ritual: u8,
//     energy_per_search: u8,
//     energy_per_sneak: u8,
// }

pub struct Character {
    pub id: u8,
    pub x: u8, // 5 bit
    pub y: u8, // 4 bit
    pub class: u8, // 3 bit
    pub progress: u8, // 0 = idle, 1-15 = continuing action => 4 bit
    pub health: u8,
    pub has_been_seen: bool,
    pub is_hidden: u1,
    pub target_x: u8,
    pub target_y: u8,
    pub damage_mod: u8,
    pub last_action: u8,
    pub status: u8,
    // pub wait_action: ActionDefinition,
    pub actions: [ActionDefinition; MAX_ACTIONS_PER_CHARACTER + 1], // BoundedVec<ActionDefinition, MAX_ACTIONS_PER_CHARACTER>,
}

// pub fn resolve_action(action: u8, class: u8) -> ActionDefinition {
//     let mut idx = class as u32 * MAX_ACTIONS_PER_CHARACTER + action as u32;
//     if idx >= (ACTION_DEFINITIONS.len()) {
//         idx = 0;
//     }
//     // assert(action as u32 < MAX_ACTIONS_PER_CHARACTER);
//     // assert(class as u32 < CLASS_COUNT);
//     ACTION_DEFINITIONS[idx]
// }
//     pub fn resolve_action(action: Action) -> ActionDefinition {
//         // let idx = get_action_base_index(self.get_id(), action);
//         ActionDefinition::new(action, ACTION_DEFINITIONS)
// //        (idx, ACTION_DEFINITIONS)
//         //resolve_action(action, self.class)
//         // let mut a = action as u32;
//         // if a >= self.actions.len() { a = 0; }
//         // self.actions[a] //.get_unchecked(a)
//     }
//global wait_action: ActionDefinition = buld_wait_action_def();

// global wait_action: ActionDefinition = action_builder.build_wait_action_def();

impl Character {
    // pub fn new(id: u8 x: u8, y: u8, class: u8, status: u8, health: u8, has_been_seen: u8)
    /// May throw


    pub fn get_id(self) -> u8 {
        self.id
    }

    pub fn get_x(self) -> u8 {
        self.x
    }

    pub fn get_y(self) -> u8 {
        self.y
    }

    pub fn get_class(self) -> u8 {
        self.class
    }

    pub fn get_progress(self) -> u8 {
        self.progress
    }

    pub fn get_status(self) -> u8 {
        self.status
    }

    pub fn get_health(self) -> u8 {
        self.health
    }

    pub fn get_has_been_seen(self) -> bool {
        self.has_been_seen
    }

    pub fn get_target_x(self) -> u8 {
        self.target_x
    }

    pub fn get_target_y(self) -> u8 {
        self.target_y
    }

    pub fn get_is_hidden(self) -> u1 {
      self.is_hidden
    }

    pub fn get_damage_mod(self) -> u8 {
      self.damage_mod
    }

    pub fn get_action(self, action_idx: u8) -> (bool, ActionDefinition) {
      /*if action_idx == 0 {
        (true, self.wait_action)
      } else */if action_idx <= MAX_ACTIONS_PER_CHARACTER as u8 {
        (true, self.actions[action_idx])
      } else {
        (false, self.actions[0])
      }
    }

    // pub fn get_energy_per_attack(self) -> u8 {
    //     class_energy_per_attack[self.class]
    // }

    // pub fn get_energy_per_cast(self) -> u8 {
    //     class_energy_per_cast[self.class]
    // }

    // pub fn get_energy_per_disarm(self) -> u8 {
    //     class_energy_per_disarm[self.class]
    // }

    // pub fn get_energy_per_move(self) -> u8 {
    //     class_energy_per_move[self.class]
    // }

    // pub fn get_energy_per_ritual(self) -> u8 {
    //     class_energy_per_ritual[self.class]
    // }

    // pub fn get_energy_per_search(self) -> u8 {
    //     class_energy_per_search[self.class]
    // }

    // pub fn get_energy_per_sneak(self) -> u8 {
    //     class_energy_per_sneak[self.class]
    // }

    // pub fn get_energy_per_draw(self) -> u8 {
    //     class_energy_per_draw[self.class]
    // }

    // pub fn get_energy_per_shoot(self) -> u8 {
    //     class_energy_per_shoot[self.class]
    // }

    // pub fn get_damage(self, attack_type: u8) -> u8 {
    //     self.damage_mod + class_damage[attack_type][self.class]
    // }

    pub fn get_last_action(self) -> u8 {
      self.last_action
    }

    // pub fn can_sneak(self) -> bool {
    //     class_energy_per_sneak[self.class] != 255
    // }

    // pub fn can_ritual(self) -> bool {
    //     class_energy_per_ritual[self.class] != 255
    // }

    // pub fn can_cast_fireball(self) -> bool {
    //     class_energy_per_cast[self.class] != 255
    // }

    pub fn can_shoot(self) -> bool {
        self.class == ARCHER
    }
    // pub fn can_disarm(self) -> bool {
    //     class_energy_per_disarm[self.class] != 255
    // }

    // pub fn can_search(self) -> bool {
    //     class_energy_per_search[self.class] != 255
    // }

    fn is_pos_valid(x: u8, y: u8) -> bool { ((x < WIDTH) & (y < HEIGHT)) | ((x == 255) & (y == 255)) }
    fn is_target_valid(x: u8, y: u8) -> bool { ((x < WIDTH) & (y < HEIGHT)) | ((x == 255) & (y == 255)) }
    fn is_class_valid(class: u8) -> bool { class as u32 <= CLASS_COUNT }
    fn is_status_valid(status: u8) -> bool { status < PROGRESS_COUNT }

    pub fn is_valid(self) -> bool {
        Character::is_pos_valid(self.x, self.y) &
        Character::is_target_valid(self.target_x, self.target_y) &
        Character::is_class_valid(self.class) &
        Character::is_status_valid(self.progress)
    }

    pub fn serialize(self) -> (SerializedCharacter, SerializedArenaCharacterActionDefinitions) {
        comptime {
            assert(WIDTH <= WIDTH_MASK + 1);
            assert(HEIGHT <= HEIGHT_MASK + 1);
            assert(CLASS_COUNT <= (CLASS_MASK + 1) as u32);
            assert(PROGRESS_COUNT <= PROGRESS_MASK + 1);
            assert(WIDTH_BITS + CLASS_BITS <= 8);
            assert(HEIGHT_BITS + PROGRESS_BITS <= 8);
            assert(WIDTH_BITS + 1 <= 8);
        }
        assert(self.is_valid());
        let packed_x = self.x + (self.class << WIDTH_BITS);
        let packed_y = self.y + (self.progress << HEIGHT_BITS);
        let packed_target_x = (self.target_x & WIDTH_MASK) + ((self.is_hidden as u8) << WIDTH_BITS);
        let packed_target_y = (self.target_y & HEIGHT_MASK) + ((self.last_action as u8) << HEIGHT_BITS);

        // let serialized_action_defs = self.actions.map(|a|std::field::bytes32_to_field(a));
        let serialized_action_defs = [
          std::field::bytes32_to_field(self.actions[1]),
          std::field::bytes32_to_field(self.actions[2]),
          std::field::bytes32_to_field(self.actions[3]),
          std::field::bytes32_to_field(self.actions[4]),
          std::field::bytes32_to_field(self.actions[5]),
          std::field::bytes32_to_field(self.actions[6])
        ];
        
        ([packed_x, packed_y, self.health, packed_target_x, packed_target_y, self.damage_mod], serialized_action_defs)
    }

    pub fn to_obstacle(self) -> (bool, Obstacle) {
        comptime {
            assert(MAX_CHARACTERS < (255 - MAX_OBSTACLES));
        }
        assert(self.is_valid());
        new_obstacle(self.id + (MAX_OBSTACLES as u8), self.x, self.y, self.health, self.class)
        // Obstacle {
        //     id: self.id + (MAX_CHARACTERS as u8),
        //     x: self.x,
        //     y: self.y,
        //     obstacle_type: self.class,
        //     health: self.health,
        //     //was_alive: 
        // }
    }

    pub fn move(self, x: u8, y: u8) -> Character {
        let mut c = self;
        c.x = x;
        c.y = y;
        c
    }

    pub fn take_damage(self, attack_type: u8, dmg: u8) -> Character {
        let damage_after_resistances = get_attack_damage_to_tile(attack_type, dmg as u32, self.class);
        let mut c = self;
        if damage_after_resistances > (c.health as u32) {
            c.health = 0;
        } else {
            c.health -= (damage_after_resistances as u8);
        }
        c
    }

    pub fn set_status(self, status: u8) -> Character {
        assert(status < PROGRESS_COUNT);
        let mut c = self;
        c.progress = status;
        c
    }

    pub fn create_character(id: u8, x: u8, y: u8, class: u8) -> Character {
        // let mut actions: BoundedVec<ActionDefinition, 6> = BoundedVec::new();
        // let idx = class as u32 * MAX_ACTIONS_PER_CHARACTER;
        // for i in 1..6 {
        //     if (ACTION_DEFINITIONS[idx + i][ACTION_IS_CONTINUOUS] != 0) | (ACTION_DEFINITIONS[idx + 1][ACTION_RESULT_STATUS_MULTIPLIER] != 1) {
        //         actions.push(ACTION_DEFINITIONS[idx + i]);
        //     }
        // }
        let c = Character {
            id: id,
            x: x,
            y: y,
            class: class,
            progress: 0,
            health: 0,
            has_been_seen: false,
            is_hidden: 0,
            target_x: 255,
            target_y: 255,
            damage_mod: 0,//: class_damage[class],
            last_action: WAIT,
            status: 0, // TODO: status
            actions: [[0 as u8; 32]; MAX_ACTIONS_PER_CHARACTER + 1]// BoundedVec::new()
        };
        assert(c.is_valid());
        c
    }

    pub fn parse(id: u8, data: Field, actions_data: SerializedArenaActionDefinitions, wait_action: ActionDefinition, events: [Event; MAX_EVENTS], enemy_advance: u8) -> (bool, Character) {
        // these asserts could be disabled for production
        comptime {
            assert(WIDTH <= WIDTH_MASK + 1);
            assert(HEIGHT <= HEIGHT_MASK + 1);
            assert(CLASS_COUNT <= (CLASS_MASK + 1) as u32);
            assert(PROGRESS_COUNT <= PROGRESS_MASK + 1);
            assert(WIDTH_BITS + CLASS_BITS <= 8);
            assert(HEIGHT_BITS + PROGRESS_BITS <= 8);
            assert(WIDTH_BITS + 1 <= 8);
        }

      let (is_valid, c) = parse_unconstrained(id, data, actions_data, wait_action, events, enemy_advance);
      // assert(c.)

        assert(c.is_valid());
        (is_valid, c)
    }
}

fn parse_unconstrained(id: u8, data: Field, actions_data: SerializedArenaActionDefinitions, wait_action: ActionDefinition, events: [Event; MAX_EVENTS], enemy_advance: u8) -> (bool,Character) {
          let mut is_valid = true;

        let split: [u8; 32] = data.to_be_bytes::<32>();
        assert(split.len() == 32);
        let x_packed = split[2 + id * 6]; // 5 bit x, 3 bit class
        let y_packed = split[2 + id * 6 + 1]; // 4 bit y, 4 bit status
        let mut health = split[2 + id * 6 + 2] as u16;
        let target_x_packed = split[2 + id * 6 + 3]; // 5 bit target x, 1 bit hidden, 1 bit has target, 1 bit unused
        let target_y_packed = split[2 + id * 6 + 4]; // 4 bit target y, 4 bit last action
        let damage_mod = split[2 + id * 6 + 5]; // last byte: for the moment, use to save damage_mod (buffs, etc)

        let x = x_packed & WIDTH_MASK;
        let y = y_packed & HEIGHT_MASK;
        let mut class = (x_packed >> WIDTH_BITS) & CLASS_MASK;
        if !Character::is_class_valid(class) {
            debug!(quote { println(f"Invalid class {class}"); });
            class = 0;
            is_valid = false;
        }

        let progress = (y_packed >> HEIGHT_BITS) & PROGRESS_MASK;
        softassert!(quote { is_valid }, quote { Character::is_status_valid(progress) }, quote { f"Invalid status {progress} during character parsing {id}" });

        let target_x = target_x_packed & WIDTH_MASK;
        let target_y = target_y_packed & HEIGHT_MASK;
        let last_action = (target_y_packed >> HEIGHT_BITS) & PROGRESS_MASK;

        let is_visible = is_visible(enemy_advance, x); //((target_x_packed >> 5) & 1) as u1;
        let is_hidden = ((target_x_packed >> WIDTH_BITS) & 1) as u1;

        let mut damage: u16 = 0;
        for i in 0..MAX_EVENTS {
            let event = events[i];
            damage += event.get_applied_damage_to_my_asset(x, y, class);
            // if events[i].actor_id == id {
            //     let event = events[i];
            //     if event.actor_id == id {
            //         damage += event.get_applied_damage_to_my_asset(x, y, class);
            //     }
            // }
        }
        if damage > health {
            health = 0;
        } else {
            health -= damage;
        }

        // let mut actions = [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER]; //: BoundedVec<ActionDefinition, MAX_ACTIONS_PER_CHARACTER> = BoundedVec::new();
        // let idx = class as u32 * MAX_ACTIONS_PER_CHARACTER;
        // for i in 1..MAX_ACTIONS_PER_CHARACTER {
        //     if (ACTION_DEFINITIONS[idx + i][ACTION_IS_CONTINUOUS] != 0) | (ACTION_DEFINITIONS[idx + 1][ACTION_RESULT_STATUS_MULTIPLIER] != 1) {
        //         actions[i] = ACTION_DEFINITIONS[idx + i];
        //     }
        // }

        let c = Character {
            id: id,
            x: x,
            y: y,
            class: class,
            progress: progress,
            health: health as u8,
            has_been_seen: is_visible, // TODO 
            is_hidden: is_hidden,
            target_x: target_x,
            target_y: target_y,
            damage_mod: damage_mod,
            last_action: last_action,
            actions: [
              wait_action,
              actions_data[id * MAX_ACTIONS_PER_CHARACTER as u8].to_be_bytes::<32>(),
              actions_data[id * MAX_ACTIONS_PER_CHARACTER as u8 + 1].to_be_bytes::<32>(),
              actions_data[id * MAX_ACTIONS_PER_CHARACTER as u8 + 2].to_be_bytes::<32>(),
              actions_data[id * MAX_ACTIONS_PER_CHARACTER as u8 + 3].to_be_bytes::<32>(),
              actions_data[id * MAX_ACTIONS_PER_CHARACTER as u8 + 4].to_be_bytes::<32>(),
              actions_data[id * MAX_ACTIONS_PER_CHARACTER as u8 + 5].to_be_bytes::<32>()
            ],
            status: 0 // TODO: status
        };
        (is_valid, c)
}

// unconstrained fn create_character_unconstrained(
//   id: u8,
//   x: u8,
//   y: u8,
//   class: u8,
//   progress: u8,
//   health: u8,
//   has_been_seen: u8
// )

fn select_action_defs_of_character(actions: SerializedArenaActionDefinitions, char_id: u32) -> [ActionDefinition; MAX_ACTIONS_PER_CHARACTER + 1] {
  let mut result: [SerializedArenaCharacterActionDefinition] = &[std::field::bytes32_to_field(get_wait_action_def())];
  let offset = char_id * MAX_ACTIONS_PER_CHARACTER;
  for i in 0..MAX_ACTIONS_PER_CHARACTER {
    result = result.push_back(actions[offset + i]);
  }
  result.as_array().map(|f|f.to_be_bytes())
}

pub fn get_default_characters(side: u8) -> [Character; MAX_CHARACTERS] {
    assert(side < 2, f"Side is too large {side}");
    // let wait_action = arena_action_def_builder.build_wait_action_def();
    let default_actions = get_test_action_register();

    let x = |x| x * ((side + 1) % 2) + (WIDTH - 1 - x) * side;
    [
        Character { id: 0, x: x(2), y: 2, class: ARCHER, health: 100, progress: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0, last_action: WAIT, actions: select_action_defs_of_character(default_actions, 1), status: 0 },
        Character { id: 1, x: x(2), y: 3, class: RITUALIST, health: 60, progress: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0, last_action: WAIT, actions: select_action_defs_of_character(default_actions, 2), status: 0 },
        Character { id: 2, x: x(2), y: 4, class: ROGUE, health: 80, progress: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0, last_action: WAIT, actions: select_action_defs_of_character(default_actions, 3), status: 0 },
        Character { id: 3, x: x(2), y: 5, class: KNIGHT, health: 120, progress: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0, last_action: WAIT, actions: select_action_defs_of_character(default_actions, 4), status: 0 },
        Character { id: 4, x: x(2), y: 6, class: MAGE, health: 40, progress: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0, last_action: WAIT, actions: select_action_defs_of_character(default_actions, 5), status: 0 },
    ]
}

#[export]
pub fn parse_characters(data: SerializedArenaCharacterRoster, actions_data: SerializedArenaActionDefinitions, events: [Event; MAX_EVENTS], enemy_advance: u8) -> pub (bool, [Character; MAX_CHARACTERS]) {
    comptime { assert(MAX_CHARACTERS == 5); }

    let enemy_advance = if enemy_advance >= WIDTH { 0 } else { WIDTH - enemy_advance - 1 };
    let mut is_valid = true;

    let wait_action = get_wait_action_def();

    // no need to optimize, compiler automatically rolls this out
    // let mut result: [Character; MAX_CHARACTERS] = [Character::create_character(0, 0, 0, 0), Character::create_character(1, 0, 0, 0), Character::create_character(2, 0, 0, 0), Character::create_character(3, 0, 0, 0), Character::create_character(4, 0, 0, 0)];
    // for i in 0..(MAX_CHARACTERS as u8) {
    //     let (curr_valid, curr_c) = Character::parse(i, data, actions_data, wait_action, events, enemy_advance);
    //     is_valid &= curr_valid;
    //     result[i] = curr_c;
    // }

        let (curr_valid, curr_c0) = Character::parse(0, data, actions_data, wait_action, events, enemy_advance);
        is_valid &= curr_valid;
        // result[0] = curr_c0;
        let (curr_valid, curr_c1) = Character::parse(1, data, actions_data, wait_action, events, enemy_advance);
        is_valid &= curr_valid;
        // result[1] = curr_c1;
        let (curr_valid, curr_c2) = Character::parse(2, data, actions_data, wait_action, events, enemy_advance);
        is_valid &= curr_valid;
        // result[2] = curr_c2;
        let (curr_valid, curr_c3) = Character::parse(3, data, actions_data, wait_action, events, enemy_advance);
        is_valid &= curr_valid;
        // result[3] = curr_c3;
        let (curr_valid, curr_c4) = Character::parse(4, data, actions_data, wait_action, events, enemy_advance);
        is_valid &= curr_valid;
        // result[4] = curr_c4;
    let result = [curr_c0, curr_c1, curr_c2, curr_c3, curr_c4];
    (is_valid, result)
}

pub fn get_test_my_character(id: u8, x: u8, y: u8, class: u8) -> Character {
    assert(id < 5);
    assert(class as u32 < CLASS_COUNT);
    assert(x < WIDTH);
    assert(y < HEIGHT);

    // let wait_action = arena_action_def_builder.build_wait_action_def();

    Character {
        id: id,
        x: x,
        y: y,
        class: class,
        progress: 0,
        health: 100,
        has_been_seen: false,
        is_hidden: 0,
        target_x: 255,
        target_y: 255,
        damage_mod: 0,
        last_action: WAIT,
        actions: [[0 as u8; 32]; MAX_ACTIONS_PER_CHARACTER + 1],
        status: 0
    }
}

pub fn get_test_their_character(id: u8, x: u8, y: u8, class: u8) -> Character {
    assert(id < 5);
    assert(class as u32 < CLASS_COUNT);
    assert(x < WIDTH);
    assert(y < HEIGHT);

    Character {
        id: id,
        x: x,
        y: y,
        class: class,
        progress: 0,
        health: 255,
        has_been_seen: false,
        is_hidden: 0,
        target_x: 255,
        target_y: 255,
        damage_mod: 0,
        last_action: WAIT,
        actions: [[0 as u8; 32]; MAX_ACTIONS_PER_CHARACTER + 1],
        status: 0
    }
}

#[test]
fn test_serialize_character() {
    let mut character = Character {
        id: 4,
        x: 21,
        y: 9,
        class: 5,
        progress: 9,
        health: 129,
        has_been_seen: false,
        is_hidden: 0,
        target_x: 31,
        target_y: 9,
        damage_mod: 0,
        last_action: WAIT,
        actions: [[0 as u8; 32]; MAX_ACTIONS_PER_CHARACTER + 1],
        status: 0
    };
    let (field, _) = character.serialize();
    assert(field[0] == (21 | (5 << 5)));
    assert(field[1] == (9 | (9 << 4)));
    assert(field[2] == 129);
    assert(field[3] == 31); // TODO: why?
    assert(field[4] == 9);
    assert(field[5] == 0);
}

#[test]
fn test_parse_character() {
    let dummy_events = Event::get_test_dummy_events();
    let data_array: [u8; 32] = [
        0 as u8, 0 as u8,
        0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
        0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
        191 as u8, 249 as u8, 255 as u8, 255 as u8, 9 as u8, 255 as u8,
        181 as u8, 153 as u8, 129 as u8, 127 as u8, 9 as u8, 0 as u8,
        0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
    ];
    let data: Field = std::field::bytes32_to_field(data_array);
    let wait_action = get_wait_action_def();
    let dummy_actions = [wait_action; MAX_ACTIONS_PER_CHARACTER * MAX_CHARACTERS].map(|x|std::field::bytes32_to_field(x));
    println(data);
    assert(data == 0xbff9ffff09ffb599817f0900000000000000, f"Failed assumption: data: {data} != 0xbff9ffff09ffb599817f0900000000000000");
    let (character_valid, character) = Character::parse(3, data, dummy_actions, wait_action, dummy_events, 20);
    assert(character_valid);
    assert(character.get_id() == 3);
    assert(character.get_x() == 21);
    assert(character.get_y() == 9);
    assert(character.get_class() == 5);
    assert(character.get_progress() == 9);
    assert(character.get_health() == 129);
    assert(character.get_has_been_seen());
    assert(character.get_target_x() == 31);
    assert(character.get_target_y() == 9);

    let (character_max_valid, character_max) = Character::parse(2, data, dummy_actions, wait_action, dummy_events, 20);
    assert(character_max_valid);
    assert(character_max.get_id() == 2);
    assert(character_max.get_x() == 31);
    assert(character_max.get_y() == 9);
    assert(character_max.get_class() == 5);
    assert(character_max.get_progress() == 15);
    assert(character_max.get_health() == 255);
    assert(character_max.get_has_been_seen());
    assert(character_max.get_target_x() == 31);
    assert(character_max.get_target_y() == 9);

    let (character_min_valid, character_min) = Character::parse(0, data, dummy_actions, wait_action, dummy_events, 20);
    assert(character_min_valid);
    assert(character_min.get_id() == 0);
    assert(character_min.get_x() == 0);
    assert(character_min.get_y() == 0);
    assert(character_min.get_class() == 0);
    assert(character_min.get_progress() == 0);
    assert(character_min.get_health() == 0);
    assert(character_min.get_has_been_seen() == false);
    assert(character_min.get_target_x() == 0);
    assert(character_min.get_target_y() == 0);
}

#[test]
fn test_parse_character_as_in_game() {
    let wait_action = get_wait_action_def();
    let dummy_actions = [wait_action; MAX_ACTIONS_PER_CHARACTER * MAX_CHARACTERS].map(|x|std::field::bytes32_to_field(x));
    let data: Field = 0x1602ff1f09001603ff1f0f001604ff1f0f001605ff1f0f001606ff1f0f00;
    let (character_valid, character) = Character::parse(0, data, dummy_actions, wait_action, Event::get_test_dummy_events(), 20);
    assert(character_valid);
    assert(character.get_id() == 0);
    assert(character.get_x() == 22, character.get_x());
    assert(character.get_y() == 2, character.get_y());
    assert(character.get_class() == 0, character.get_class());
    assert(character.get_progress() == 0, character.get_progress());
    assert(character.get_health() == 255);
    assert(character.get_has_been_seen() == true);
    assert(character.get_target_x() == 31);
    assert(character.get_target_y() == 9);
}

#[export]
pub fn serialize_chars(chars: [Character; MAX_CHARACTERS]) -> pub (Field, SerializedArenaActionDefinitions) {
    let mut result: [u8; 32] = [0; 32];
    let mut actions: SerializedArenaActionDefinitions = [0; 30]; //&[].as_array();
    for i in 0..MAX_CHARACTERS {
        let (serialized_char_bytes, serialized_actions) = chars[i].serialize();
        for j in 0..6 {
            result[2 + i * 6 + j] = serialized_char_bytes[j];
        }
        for k in 0..MAX_ACTIONS_PER_CHARACTER {
          actions[i * MAX_ACTIONS_PER_CHARACTER + k] = serialized_actions[k];
        }
    }
    
    (std::field::bytes32_to_field(result), actions)
}

/**
* For now we will only take class into account.
*/
pub fn get_attack_damage_to_tile(attack_type: u8, damage: u32, class: u8) -> u32 {
    debug!(quote { assert(class <= arenalib::MAX_DAMAGEABLE_TILE); });
    (damage * resistances[attack_type * 8 + (class & 7)] as u32 / 100) as u32
}

pub fn get_trap_damage_to_tile(damage: u32, class: u8) -> u32 {
    debug!(quote { assert(class <= arenalib::MAX_DAMAGEABLE_TILE); });
    (damage * trap_resistances[class & 7] as u32 / 100) as u32
}

#[test]
fn test_parse_character_round0() {
  // let actions_data = .map(|f|f.to_be_bytes::<32>()).map(|f|std::field::bytes32_to_field(f));
  let data = 0x2912640000004b03190000006c04142000008a0464000000aa47640b340a;
  let enemy_advance = 0x00;
  let events = [
    build_subtype_value_event(NO_EVENT, 4, NOWHERE, NOWHERE, 0, NO_EVENT, 0),
    build_subtype_value_event(NO_EVENT, 4, NOWHERE, NOWHERE, 0, NO_EVENT, 0),
    build_subtype_value_event(NO_EVENT, 4, NOWHERE, NOWHERE, 0, NO_EVENT, 0),
    build_subtype_value_event(NO_EVENT, 4, NOWHERE, NOWHERE, 0, NO_EVENT, 0)
  ];
  let serialized_events = serialize_events(events);
   println(f"events: {serialized_events}");

  let parsed = parse_characters(data, [
    0x03f00001300314002000000000100300000020000000002000000000000000,
    0x02f0000110071020100a000020100a00000020000000002000000000000000,
    0x02f0000a3b1901002000000000000801000020000000002000000000000000,
    0x023100081b161118120a010018120a01000020000000002000000000000000,
    0xf0003f000001002000000000200000000020000000002000000000000000,
    0xf0003f000001002000000000200000000020000000002000000000000000,
    0x03f00001300414002000000000100300000020000000002000000000000000,
    0x02f0000110071008100a000008100a00000020000000002000000000000000,
    0xf0003f1b1c11002000000000000702000020000000002000000000000000,
    0xff003f1b1c1100200e013f00000e013f0020000000002000000000000000,
    0xf0003f000001002000000000200000000020000000002000000000000000,
    0xf0003f000001002000000000200000000020000000002000000000000000,
    0x03f00001300314002000000000100300000020000000002000000000000000,
    0x02f0000110071018100a000018100a00000020000000002000000000000000,
    0x09f0000130060c002000000000200000000020000000002000000000000000,
    0xf00001100610001005000100100500010020000000002000000000000000,
    0xf00001301c0100100d000000100d00000020000000002000000000000000,
    0x0bf00001100c00002000000000200000000010040a00002000000000000000,
    0x03f00001300414002000000000100300000020000000002000000000000000,
    0x02f0000110061028100a000028100a00000020000000002000000000000000,
    0xf0003f000001002000000000200000000020000000002000000000000000,
    0xf0003f000001002000000000200000000020000000002000000000000000,
    0xf0003f000001002000000000200000000020000000002000000000000000,
    0xf0003f000001002000000000200000000020000000002000000000000000,
    0x03f00001300414002000000000100300000020000000002000000000000000,
    0x02f0000110071010100a000010100a00000020000000002000000000000000,
    0xf000071b1611002000000000000705000020000000002000000000000000,
    0x6300061b161164150a020164150a02010020000000002000000000000000,
    0xf0003f000001002000000000200000000020000000002000000000000000,
    0xf0003f000001002000000000200000000020000000002000000000000000
], events, enemy_advance);

  assert(parsed.0);
}