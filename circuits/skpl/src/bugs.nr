// global WIDTH_MASK: u8 = 31;
// global CLASS_MASK: u8 = 7;
// global WIDTH_BITS: u8 = 5;
// global MAX_CHARACTERS: u32 = 5;
// struct Character {
//     pub x: u8, // 5 bit
//     pub class: u8, // 3 bit
//     pub actions: [[u8; 32]; 7],
// }
// impl Character {
//     fn is_class_valid(class: u8) -> bool {
//         class as u32 <= 5
//     }

//     pub fn is_valid(self) -> bool {
//         let mut valid = true;
//         let x = self.x;
//         let class = self.class;
//         println(x);
//         valid &= Character::is_class_valid(class);
//         valid
//     }

//     fn parse(
//         id: u8,
//         data: Field,
//         actions_data: [Field; 30],
//         wait_action: [u8; 32],
//     ) -> (bool, Character) {
//         let mut is_valid = true;

//         let split: [u8; 32] = data.to_be_bytes::<32>();
//         assert(split.len() == 32);
//         let x_packed = split[2 + id * 6]; // 5 bit x, 3 bit class

//         let x = x_packed & WIDTH_MASK;
//         let mut class = (x_packed >> WIDTH_BITS) & CLASS_MASK;
//         if !Character::is_class_valid(class) {
//             class = 0;
//             is_valid = false;
//         }

//         let c = Character {
//             x: x,
//             class: class,
//             actions: [
//                 wait_action,
//                 actions_data[id * 6 as u8].to_be_bytes::<32>(),
//                 actions_data[id * 6 as u8 + 1].to_be_bytes::<32>(),
//                 actions_data[id * 6 as u8 + 2].to_be_bytes::<32>(),
//                 actions_data[id * 6 as u8 + 3].to_be_bytes::<32>(),
//                 actions_data[id * 6 as u8 + 4].to_be_bytes::<32>(),
//                 actions_data[id * 6 as u8 + 5].to_be_bytes::<32>(),
//             ],
//         };
//         (is_valid, c)
//     }
// }

// fn create_character(x: u8, class: u8) -> Character {
//     let c = Character { x: x, class: class, actions: [[0 as u8; 32]; 7] };
//     assert(c.is_valid());
//     c
// }
// fn parse_characters(data: Field, actions_data: [Field; 30]) -> (bool, [Character; MAX_CHARACTERS]) {
//     let mut is_valid = true;

//     let wait_action = [
//         0 as u8, 0 as u8, 240 as u8, 0 as u8, 63 as u8, 0 as u8, 0 as u8, 1 as u8, 0 as u8,
//         32 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 32 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
//         32 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 32 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
//         0 as u8, 0 as u8, 0 as u8,
//     ];

//     // no need to optimize, compiler automatically rolls this out
//     let mut result: [Character; MAX_CHARACTERS] = [
//         create_character(0, 0),
//         create_character(0, 0),
//         create_character(0, 0),
//         create_character(0, 0),
//         create_character(0, 0),
//     ];
//     for i in 0..(MAX_CHARACTERS as u8) {
//         let (curr_valid, curr_c) = Character::parse(i, data, actions_data, wait_action);
//         is_valid &= curr_valid;
//         result[i] = curr_c;
//     }

//     // let (curr_valid, curr_c) = Character::parse(0, data, actions_data, wait_action, events, enemy_advance);
//     // is_valid &= curr_valid;
//     // result[0] = curr_c;
//     // let (curr_valid, curr_c) = Character::parse(1, data, actions_data, wait_action, events, enemy_advance);
//     // is_valid &= curr_valid;
//     // result[1] = curr_c;
//     // let (curr_valid, curr_c) = Character::parse(2, data, actions_data, wait_action, events, enemy_advance);
//     // is_valid &= curr_valid;
//     // result[2] = curr_c;
//     // let (curr_valid, curr_c) = Character::parse(3, data, actions_data, wait_action, events, enemy_advance);
//     // is_valid &= curr_valid;
//     // result[3] = curr_c;
//     // let (curr_valid, curr_c) = Character::parse(4, data, actions_data, wait_action, events, enemy_advance);
//     // is_valid &= curr_valid;
//     // result[4] = curr_c;
//     (is_valid, result)
// }

// #[test]
// fn test_parse_character_round0() {
//     let data = 0x2912640000004b03190000006c04142000008a0464000000aa47640b340a;

//     let parsed = parse_characters(
//         data,
//         [
//             0x03f00001300314002000000000100300000020000000002000000000000000,
//             0x02f0000110071020100a000020100a00000020000000002000000000000000,
//             0x02f0000a3b1901002000000000000801000020000000002000000000000000,
//             0x023100081b161118120a010018120a01000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0x03f00001300414002000000000100300000020000000002000000000000000,
//             0x02f0000110071008100a000008100a00000020000000002000000000000000,
//             0xf0003f1b1c11002000000000000702000020000000002000000000000000,
//             0xff003f1b1c1100200e013f00000e013f0020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0x03f00001300314002000000000100300000020000000002000000000000000,
//             0x02f0000110071018100a000018100a00000020000000002000000000000000,
//             0x09f0000130060c002000000000200000000020000000002000000000000000,
//             0xf00001100610001005000100100500010020000000002000000000000000,
//             0xf00001301c0100100d000000100d00000020000000002000000000000000,
//             0x0bf00001100c00002000000000200000000010040a00002000000000000000,
//             0x03f00001300414002000000000100300000020000000002000000000000000,
//             0x02f0000110061028100a000028100a00000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0x03f00001300414002000000000100300000020000000002000000000000000,
//             0x02f0000110071010100a000010100a00000020000000002000000000000000,
//             0xf000071b1611002000000000000705000020000000002000000000000000,
//             0x6300061b161164150a020164150a02010020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//             0xf0003f000001002000000000200000000020000000002000000000000000,
//         ],
//     );
//     assert(parsed.0);
// }

global WIDTH: u8 = 32;
global HEIGHT: u8 = 10;
global WIDTH_BITS: u8 = 5;
global HEIGHT_BITS: u8 = 4;
global WIDTH_MASK: u8 = 31;
global HEIGHT_MASK: u8 = 15;
global PROGRESS_BITS: u8 = 4;
global PROGRESS_COUNT: u8 = 16;
global PROGRESS_MASK: u8 = 15;
global MAX_CHARACTERS: u32 = 5;
global MAX_ACTIONS_PER_CHARACTER: u32 = 6;
global RECEIVE_ATTACK: u8 = 10;
global TRIGGERED_TRAP: u8 = 11;
global MAX_DAMAGEABLE_TILE: u8 = 8;
global MAX_EVENTS: u32 = 4;
global CLASS_BITS: u8 = 3;
global CLASS_COUNT: u32 = 5;
global CLASS_MASK: u8 = 7;
global WAIT: u8 = 0;
global NO_EVENT: u8 = 0;
global NOWHERE: u8 = 255;

pub comptime global DEBUG: bool = true;
pub comptime fn debug(stmt: Quoted) -> Quoted {
    let debug_result = if DEBUG { stmt } else { quote {} };
    debug_result
}
pub comptime fn debugmsg<T>(msg: T) -> Quoted {
    debug!(quote { println($msg); })
}
pub comptime fn softassert(varname: Quoted, check: Quoted, msg: Quoted) -> Quoted {
    let result = if DEBUG {
        quote {
            $varname &= $check;
            if !($check) {
                println($msg);
            }
        }
    } else {
        quote {
            $varname &= $check;
        }
    };
    result
}

global resistances: [u16; 8 * 3] = [
     0,  75, 100, 85,  50, 100, 20,  0, //,  255, 255, 0, 0, 0, 255, 255, 255 ], // Melee vs dummy, archer, ritualist, thief, knight, mage, wall, water, unknown_class, flag, trap, trap_used, trap_found, body, body_looted, fog
     0,  80, 100, 90,  25, 100,  5,  0, // 255, 255, 0, 0, 0, 255, 255, 255 ], // Ranged vs dummy, archer, ritualist, thief, knight, mage, wall, water
     0,  80, 100, 90, 100,  90, 60, 50, // 255, 255, 0, 0, 0, 255, 255, 255 ], // Fireball vs dummy, archer, ritualist, thief, knight, mage, wall, water
];

global trap_resistances: [u16; 8] = [ 0,  75, 100, 50,  75, 90, 5, 0]; //,  255, 255, 255, 255, 255, 255, 255, 255 ]; // Trap vs dummy, archer, ritualist, thief, knight, mage
fn is_visible(enemy_advance: u8, x: u8) -> bool {
    //(x >= enemy_advance) == (side == 0)
    x >= enemy_advance
}

type SerializedArenaActionDefinitions = [Field; 30];
type SerializedArenaCharacterRoster = Field;
type ActionDefinition = [u8;32];
fn get_distance(curr_x: u8, curr_y: u8, x: u8, y: u8) -> u16 {
    // assert(curr_x < WIDTH);
    // assert(curr_y < HEIGHT);
    // assert(x < WIDTH);
    // assert(y < HEIGHT);
    // validating coordinates is not the job of this function
    // only avoid overflows!

    // let dx = unsafe {
    //     let diff_
    //     distance_sqrt(x)
    // }

    let dx = if curr_x > x { curr_x - x } else { x - curr_x } as u16;
    let dy = if curr_y > y { curr_y - y } else { y - curr_y } as u16;

    // let dx = curr_x as i16 - x as i16;
    // let dy = curr_y as i16 - y as i16;

    (dx * dx + dy * dy) as u16
}
fn get_attack_damage_to_tile(attack_type: u8, damage: u16, class: u8) -> u16 {
    debug!(quote { assert(class <= MAX_DAMAGEABLE_TILE); });
    (damage * resistances[attack_type * 8 + (class & 7)] / 100) as u16
}

fn get_trap_damage_to_tile(damage: u16, class: u8) -> u16 {
    debug!(quote { assert(class <= MAX_DAMAGEABLE_TILE); });
    (damage * trap_resistances[class & 7] / 100) as u16
}
struct Event {
    pub event: u8,
    pub actor_id: u8,
    pub subtype: u8,
    pub x: u8,
    pub y: u8,
    pub value: u8,
    pub radius: u8,
}
impl Event {

    fn get_applied_damage_to_my_asset(self, x: u8, y: u8, tile: u8) -> u16 {
        let mut damage = 0;
        let radius = self.radius as u16;
        let radius = radius * radius;
    
        if self.event == RECEIVE_ATTACK {
            let distance = get_distance(self.x, self.y, x, y);
            debug!(quote {
                        // let event = self.event;
                        // let actor = self.actor_id;
                        // let self_x = self.x;
                        // let self_y = self.y;
                        // let val = self.value;
                        // println(f"GetAppliedDamageToMyAsset: Event({event}:{val} from {actor}@{self_x}|{self_y})@{x}|{y}: {distance} <= {radius}");
                    });
            if distance <= radius {
                let damage_raw = get_attack_damage_to_tile(self.subtype, self.value as u16, tile) as u16;
                damage = damage_raw * (1 + radius - distance) / (radius + 1) as u16;
                debug!(quote { println(f"Deal damage: {damage_raw} * (1 + {radius} - {distance}) / ({radius} + 1) = {damage}"); });
            }
            // if (self.x == x) & (self.y == y) {
            //     damage = get_attack_damage_to_tile(self.subtype, self.value as u16, tile);
            // } else if (self.subtype == ATTACK_FIREBALL) & is_neighbor(self.x, self.y, x, y) {
            //     damage = get_attack_damage_to_tile(self.subtype, self.value as u16, tile) / 2;
            // }
        }
        if self.event == TRIGGERED_TRAP {
            damage = get_trap_damage_to_tile(self.value as u16, tile);
        }
        damage as u16
    }
}

fn build_subtype_value_event(event_type: u8, actor_id: u8, x: u8, y: u8, value: u8, event_subtype: u8, radius: u8) -> Event {
    Event {
        event: event_type,
        actor_id: actor_id,
        x: x,
        y: y,
        value: value,
        subtype: event_subtype,
        radius: radius,
    }
}

struct Character {
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

impl Character {

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
        }
        if damage > health {
            health = 0;
        } else {
            health -= damage;
        }

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
        assert(c.is_valid());
        (is_valid, c)
    }
}

global wait_action: ActionDefinition = [0, 0, 240, 0, 63, 0, 0, 1, 0, 32, 0, 0, 0, 0, 32, 0, 0, 0, 0, 32, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0, 0, 0];
fn get_wait_action_def() -> ActionDefinition {
  wait_action
}
fn parse_characters(data: SerializedArenaCharacterRoster, actions_data: SerializedArenaActionDefinitions, events: [Event; MAX_EVENTS], enemy_advance: u8) -> pub (bool, [Character; MAX_CHARACTERS]) {
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
#[test]
fn test_parse_character_round0() {
  let data = 0x2912640000004b03190000006c04142000008a0464000000aa47640b340a;
  let enemy_advance = 0x00;
  let events = [
    build_subtype_value_event(NO_EVENT, 4, NOWHERE, NOWHERE, 0, NO_EVENT, 0),
    build_subtype_value_event(NO_EVENT, 4, NOWHERE, NOWHERE, 0, NO_EVENT, 0),
    build_subtype_value_event(NO_EVENT, 4, NOWHERE, NOWHERE, 0, NO_EVENT, 0),
    build_subtype_value_event(NO_EVENT, 4, NOWHERE, NOWHERE, 0, NO_EVENT, 0)
  ];
   println(f"events: {events}");

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