
use crate::ARCHER;
use crate::KNIGHT;
use crate::MAGE;
use crate::RITUALIST;
use crate::ROGUE;
use crate::WIDTH;
use crate::HEIGHT;
use crate::{ CLASS_COUNT, STATUS_COUNT };
use crate::{ WAIT, ATTACK_FIREBALL };
use crate::{ MIN_DRAW_ROUNDS_FOR_SHOOT, MAX_DRAW_ROUNDS_FOR_SHOOT, MIN_FIREBALL_ROUNDS_FOR_CAST, MAX_FIREBALL_ROUNDS_FOR_CAST};
use crate::{ MAX_CHARACTERS, MAX_EVENTS, MAX_OBSTACLES, MAX_ACTIONS_PER_CHARACTER };
use crate::{ WIDTH_MASK, HEIGHT_MASK, CLASS_MASK, STATUS_MASK };
use crate::{ WIDTH_BITS, HEIGHT_BITS, CLASS_BITS, STATUS_BITS };
use crate::event::Event;
use crate::map::is_visible;
use crate::obstacle::Obstacle;
use crate::obstacle::new_obstacle;
use crate::actionDefinition::{ build_evocation_action, build_set_trap_action, build_disarm_trap_action, build_search_action, build_sneak_action, build_cast_action, build_ritual_action, build_shoot_action, build_draw_action, build_attack_action, build_move_action};
use crate::{ATTACK_RANGED, ATTACK_MELEE, debug};
use crate::actionDefinition::{ACTION_DEFINITION_REGISTER_SIZE, build_action_def_reg, build_wait_action_def, ActionDefinition };
use crate::action::Action;
use super::softassert;

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
pub fn get_test_action_register() -> [u8; ACTION_DEFINITION_REGISTER_SIZE] {
    build_action_def_reg!([
        [
            build_move_action(class_energy_per_move[ARCHER]),
            build_attack_action(class_energy_per_attack[ARCHER], ATTACK_MELEE, 1, class_damage[0][ARCHER]),
            build_draw_action(3, class_energy_per_draw[ARCHER], 10, ARCHER),
            build_shoot_action(3, class_energy_per_shoot[ARCHER], ATTACK_RANGED, 8, class_damage[1][ARCHER], 2, MIN_DRAW_ROUNDS_FOR_SHOOT, MAX_DRAW_ROUNDS_FOR_SHOOT), // archer
            build_wait_action_def(),
            build_wait_action_def(),
        ],
        [
            build_move_action(class_energy_per_move[RITUALIST]),
            build_attack_action(class_energy_per_attack[RITUALIST], ATTACK_MELEE, 1, class_damage[0][RITUALIST]),
            build_cast_action(3, class_energy_per_cast[RITUALIST], RITUALIST),
            build_ritual_action(3, class_energy_per_ritual[RITUALIST]),
            build_wait_action_def(),
            build_wait_action_def(),
        ],
        [
            build_move_action(class_energy_per_move[ROGUE]),
            build_attack_action(class_energy_per_attack[ROGUE], ATTACK_MELEE, 1, class_damage[0][ROGUE]),
            build_sneak_action(class_energy_per_sneak[ROGUE]),
            build_search_action(class_energy_per_search[ROGUE], 1),
            build_disarm_trap_action(class_energy_per_disarm[ROGUE], 1),
            build_set_trap_action(class_energy_per_disarm[ROGUE], 1),
        ],
        [
            build_move_action(class_energy_per_move[KNIGHT]),
            build_attack_action(class_energy_per_attack[KNIGHT], ATTACK_MELEE, 1, class_damage[0][KNIGHT]),
            build_wait_action_def(),
            build_wait_action_def(),
            build_wait_action_def(),
            build_wait_action_def(),
        ],
        [
            build_move_action(class_energy_per_move[MAGE]),
            build_attack_action(class_energy_per_attack[MAGE], ATTACK_MELEE, 1, class_damage[0][MAGE]),
            build_cast_action(3, class_energy_per_cast[MAGE], MAGE),
            build_evocation_action(3, class_energy_per_cast[MAGE], ATTACK_FIREBALL, 6, 1,class_damage[2][MAGE], 5, MIN_FIREBALL_ROUNDS_FOR_CAST, MAX_FIREBALL_ROUNDS_FOR_CAST),
            build_wait_action_def(),
            build_wait_action_def()
        ]
    ])
}

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
    pub status: u8, // 0 = idle, 1-15 = continuing action => 4 bit
    pub health: u8,
    pub has_been_seen: bool,
    pub is_hidden: u1,
    pub target_x: u8,
    pub target_y: u8,
    pub damage_mod: u8,
    pub last_action: u8,
    pub actions: [[u8; 29]; MAX_ACTIONS_PER_CHARACTER], // BoundedVec<ActionDefinition, MAX_ACTIONS_PER_CHARACTER>,
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

    pub fn get_energy_per_attack(self) -> u8 {
        class_energy_per_attack[self.class]
    }

    pub fn get_energy_per_cast(self) -> u8 {
        class_energy_per_cast[self.class]
    }

    pub fn get_energy_per_disarm(self) -> u8 {
        class_energy_per_disarm[self.class]
    }

    pub fn get_energy_per_move(self) -> u8 {
        class_energy_per_move[self.class]
    }

    pub fn get_energy_per_ritual(self) -> u8 {
        class_energy_per_ritual[self.class]
    }

    pub fn get_energy_per_search(self) -> u8 {
        class_energy_per_search[self.class]
    }

    pub fn get_energy_per_sneak(self) -> u8 {
        class_energy_per_sneak[self.class]
    }

    pub fn get_energy_per_draw(self) -> u8 {
        class_energy_per_draw[self.class]
    }

    pub fn get_energy_per_shoot(self) -> u8 {
        class_energy_per_shoot[self.class]
    }

    pub fn get_damage(self, attack_type: u8) -> u8 {
        self.damage_mod + class_damage[attack_type][self.class]
    }

    pub fn can_sneak(self) -> bool {
        class_energy_per_sneak[self.class] != 255
    }

    pub fn can_ritual(self) -> bool {
        class_energy_per_ritual[self.class] != 255
    }

    pub fn can_cast_fireball(self) -> bool {
        class_energy_per_cast[self.class] != 255
    }

    pub fn can_shoot(self) -> bool {
        self.class == ARCHER
    }
    pub fn can_disarm(self) -> bool {
        class_energy_per_disarm[self.class] != 255
    }

    pub fn can_search(self) -> bool {
        class_energy_per_search[self.class] != 255
    }

    fn is_pos_valid(x: u8, y: u8) -> bool { ((x < WIDTH) & (y < HEIGHT)) | ((x == 255) & (y == 255)) }
    fn is_target_valid(x: u8, y: u8) -> bool { ((x < WIDTH) & (y < HEIGHT)) | ((x == 255) & (y == 255)) }
    fn is_class_valid(class: u8) -> bool { class as u32 < CLASS_COUNT }
    fn is_status_valid(status: u8) -> bool { status < STATUS_COUNT }

    pub fn is_valid(self) -> bool {
        Character::is_pos_valid(self.x, self.y) &
        Character::is_target_valid(self.target_x, self.target_y) &
        Character::is_class_valid(self.class) &
        Character::is_status_valid(self.status)
    }

    pub fn serialize(self) -> [u8; 6] {
        comptime {
            assert(WIDTH <= WIDTH_MASK + 1);
            assert(HEIGHT <= HEIGHT_MASK + 1);
            assert(CLASS_COUNT <= (CLASS_MASK + 1) as u32);
            assert(STATUS_COUNT <= STATUS_MASK + 1);
            assert(WIDTH_BITS + CLASS_BITS <= 8);
            assert(HEIGHT_BITS + STATUS_BITS <= 8);
            assert(WIDTH_BITS + 1 <= 8);
        }
        assert(self.is_valid());
        let packed_x = self.x + (self.class << WIDTH_BITS);
        let packed_y = self.y + (self.status << HEIGHT_BITS);
        let packed_target_x = (self.target_x & WIDTH_MASK) + ((self.is_hidden as u8) << WIDTH_BITS);
        let packed_target_y = (self.target_y & HEIGHT_MASK) + ((self.last_action as u8) << HEIGHT_BITS);
        
        [packed_x, packed_y, self.health, packed_target_x, packed_target_y, self.damage_mod]
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
        let damage_after_resistances = get_attack_damage_to_tile(attack_type, dmg as u16, self.class);
        let mut c = self;
        if damage_after_resistances > (c.health as u16) {
            c.health = 0;
        } else {
            c.health -= (damage_after_resistances as u8);
        }
        c
    }

    pub fn set_status(self, status: u8) -> Character {
        assert(status < STATUS_COUNT);
        let mut c = self;
        c.status = status;
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
            status: 0,
            health: 0,
            has_been_seen: false,
            is_hidden: 0,
            target_x: 255,
            target_y: 255,
            damage_mod: 0,//: class_damage[class],
            last_action: WAIT,
            actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER]// BoundedVec::new()
        };
        assert(c.is_valid());
        c
    }

    pub fn parse(id: u8, data: Field, events: [Event; MAX_EVENTS], enemy_advance: u8) -> (bool, Character) {
        // these asserts could be disabled for production
        comptime {
            assert(WIDTH <= WIDTH_MASK + 1);
            assert(HEIGHT <= HEIGHT_MASK + 1);
            assert(CLASS_COUNT <= (CLASS_MASK + 1) as u32);
            assert(STATUS_COUNT <= STATUS_MASK + 1);
            assert(WIDTH_BITS + CLASS_BITS <= 8);
            assert(HEIGHT_BITS + STATUS_BITS <= 8);
            assert(WIDTH_BITS + 1 <= 8);
        }

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
            class = 0;
            is_valid = false;
            debug!(quote { println(f"Invalid class {class}"); });
        }

        let status = (y_packed >> HEIGHT_BITS) & STATUS_MASK;
        softassert!(quote { is_valid }, quote { Character::is_status_valid(status) }, quote { f"Invalid status {status} during character parsing {id}" });

        let target_x = target_x_packed & WIDTH_MASK;
        let target_y = target_y_packed & HEIGHT_MASK;
        let last_action = (target_y_packed >> HEIGHT_BITS) & STATUS_MASK;

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

        let mut actions = [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER]; //: BoundedVec<ActionDefinition, MAX_ACTIONS_PER_CHARACTER> = BoundedVec::new();
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
            status: status,
            health: health as u8,
            has_been_seen: is_visible, // TODO 
            is_hidden: is_hidden,
            target_x: target_x,
            target_y: target_y,
            damage_mod: damage_mod,
            last_action: last_action,
            actions: actions
        };
        assert(c.is_valid());
        (is_valid, c)
    }
}

pub fn get_default_characters(side: u8) -> [Character; MAX_CHARACTERS] {
    assert(side < 2, f"Side is too large {side}");
    let x = |x| x * ((side + 1) % 2) + (WIDTH - 1 - x) * side;
    [
        Character { id: 0, x: x(2), y: 2, class: ARCHER, health: 100, status: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0, last_action: WAIT, actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
        Character { id: 1, x: x(2), y: 3, class: RITUALIST, health: 60, status: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0, last_action: WAIT,actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
        Character { id: 2, x: x(2), y: 4, class: ROGUE, health: 80, status: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0, last_action: WAIT, actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
        Character { id: 3, x: x(2), y: 5, class: KNIGHT, health: 120, status: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0, last_action: WAIT, actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
        Character { id: 4, x: x(2), y: 6, class: MAGE, health: 40, status: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0, last_action: WAIT, actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
    ]
}

pub fn parse_characters(data: Field, events: [Event; MAX_EVENTS], enemy_advance: u8) -> (bool, [Character; MAX_CHARACTERS]) {
    comptime { assert(MAX_CHARACTERS <= 5); }

    let mut is_valid = true;

    // no need to optimize, compiler automatically rolls this out
    let mut result: [Character; MAX_CHARACTERS] = [Character::create_character(0, 0, 0, 0), Character::create_character(1, 0, 0, 0), Character::create_character(2, 0, 0, 0), Character::create_character(3, 0, 0, 0), Character::create_character(4, 0, 0, 0)];
    for i in 0..(MAX_CHARACTERS as u8) {
        let (curr_valid, curr_c) = Character::parse(i, data, events, enemy_advance);
        is_valid &= curr_valid;
        result[i] = curr_c;
    }
    (is_valid, result)
}

pub fn get_test_my_character(id: u8, x: u8, y: u8, class: u8) -> Character {
    assert(id < 5);
    assert(class as u32 < CLASS_COUNT);
    assert(x < WIDTH);
    assert(y < HEIGHT);

    Character {
        id: id,
        x: x,
        y: y,
        class: class,
        status: 0,
        health: 100,
        has_been_seen: false,
        is_hidden: 0,
        target_x: 255,
        target_y: 255,
        damage_mod: 0,
        last_action: WAIT,
        actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER]
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
        status: 0,
        health: 255,
        has_been_seen: false,
        is_hidden: 0,
        target_x: 255,
        target_y: 255,
        damage_mod: 0,
        last_action: WAIT,
        actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER]
    }
}

#[test]
fn test_serialize_character() {
    let mut character = Character {
        id: 4,
        x: 21,
        y: 9,
        class: 5,
        status: 9,
        health: 129,
        has_been_seen: false,
        is_hidden: 0,
        target_x: 31,
        target_y: 9,
        damage_mod: 0,
        last_action: WAIT,
        actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER]
    };
    let field = character.serialize();
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
    println(data);
    assert(data == 0xbff9ffff09ffb599817f0900000000000000, f"Failed assumption: data: {data} != 0xbff9ffff09ffb599817f0900000000000000");
    let (character_valid, character) = Character::parse(3, data, dummy_events, 20);
    assert(character_valid);
    assert(character.get_id() == 3);
    assert(character.get_x() == 21);
    assert(character.get_y() == 9);
    assert(character.get_class() == 5);
    assert(character.get_status() == 9);
    assert(character.get_health() == 129);
    assert(character.get_has_been_seen());
    assert(character.get_target_x() == 31);
    assert(character.get_target_y() == 9);

    let (character_max_valid, character_max) = Character::parse(2, data, dummy_events, 20);
    assert(character_max_valid);
    assert(character_max.get_id() == 2);
    assert(character_max.get_x() == 31);
    assert(character_max.get_y() == 9);
    assert(character_max.get_class() == 5);
    assert(character_max.get_status() == 15);
    assert(character_max.get_health() == 255);
    assert(character_max.get_has_been_seen());
    assert(character_max.get_target_x() == 31);
    assert(character_max.get_target_y() == 9);

    let (character_min_valid, character_min) = Character::parse(0, data, dummy_events, 20);
    assert(character_min_valid);
    assert(character_min.get_id() == 0);
    assert(character_min.get_x() == 0);
    assert(character_min.get_y() == 0);
    assert(character_min.get_class() == 0);
    assert(character_min.get_status() == 0);
    assert(character_min.get_health() == 0);
    assert(character_min.get_has_been_seen() == false);
    assert(character_min.get_target_x() == 0);
    assert(character_min.get_target_y() == 0);
}

#[test]
fn test_parse_character_as_in_game() {
    let data: Field = 0x1602ff1f09001603ff1f0f001604ff1f0f001605ff1f0f001606ff1f0f00;
    let (character_valid, character) = Character::parse(0, data, Event::get_test_dummy_events(), 20);
    assert(character_valid);
    assert(character.get_id() == 0);
    assert(character.get_x() == 22, character.get_x());
    assert(character.get_y() == 2, character.get_y());
    assert(character.get_class() == 0, character.get_class());
    assert(character.get_status() == 0, character.get_status());
    assert(character.get_health() == 255);
    assert(character.get_has_been_seen() == true);
    assert(character.get_target_x() == 31);
    assert(character.get_target_y() == 9);
}

pub fn serialize_chars(chars: [Character; 5]) -> Field {
    let mut result: [u8; 32] = [0; 32];
    for i in 0..5 {
        let serialized = chars[i].serialize();
        for j in 0..6 {
            result[2 + i * 6 + j] = serialized[j];
        }
    }
    
    std::field::bytes32_to_field(result)
}

/**
* For now we will only take class into account.
*/
pub fn get_attack_damage_to_tile(attack_type: u8, damage: u16, class: u8) -> u16 {
    debug!(quote { assert(class <= crate::WATER); });
    (damage * resistances[attack_type * 8 + (class & 7)] / 100) as u16
}

pub fn get_trap_damage_to_tile(damage: u16, class: u8) -> u16 {
    debug!(quote { assert(class <= crate::WATER); });
    (damage * trap_resistances[class & 7] / 100) as u16
}
