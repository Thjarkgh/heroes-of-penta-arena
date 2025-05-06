// use dep::std;
// use crate::ARCHER;
// use crate::KNIGHT;
// use crate::MAGE;
// use crate::RITUALIST;
// use crate::ROGUE;
// use crate::WIDTH;
// use crate::HEIGHT;
// use crate::{ CLASS_COUNT, STATUS_COUNT };
// use crate::{ MAX_CHARACTERS, MAX_EVENTS, MAX_OBSTACLES };
// use crate::{ WIDTH_MASK, HEIGHT_MASK, CLASS_MASK, STATUS_MASK };
// use crate::{ WIDTH_BITS, HEIGHT_BITS, CLASS_BITS, STATUS_BITS };
// use crate::event::Event;
// use crate::{ WATER };
// use crate::map::is_visible;
// use crate::obstacle::Obstacle;

// // this should be more efficient: for all the following: order is: UNKNOWN_CLASS, ARCHER, RITUALIST, ROGUE, KNIGHT, MAGE
// global class_damage_melee: [u8; 6] = [ 0, 32, 8, 24, 40, 16 ];
// global class_damage_ranged: [u8; 6] = [ 0, 24, 40, 16, 32, 8 ];
// global class_damage_fireball: [u8; 6] = [ 0, 0, 100, 50, 0, 100 ];
// global class_damage: [[u8; 6]; 3] = [ class_damage_melee, class_damage_ranged, class_damage_fireball ];
// global class_energy_per_attack: [u8; 6] = [ 0, 7, 7, 7, 6, 7 ];
// global class_energy_per_cast: [u8; 6] = [ 0, 255, 12, 255, 255, 6 ];
// global class_energy_per_disarm: [u8; 6] = [ 0, 255, 255, 12, 255, 255 ];
// global class_energy_per_move: [u8; 6] = [ 0, 3, 4, 3, 4, 4 ];
// global class_energy_per_ritual: [u8; 6] = [ 0, 255, 12, 255, 255, 255 ];
// global class_energy_per_search: [u8; 6] = [ 0, 255, 255, 6, 255, 255 ];
// global class_energy_per_sneak: [u8; 6] = [ 0, 255, 255, 6, 255, 255 ];
// global class_energy_per_draw: [u8; 6] = [ 0, 9, 255, 255, 255, 255 ];
// global class_energy_per_shoot: [u8; 6] = [ 0, 6, 255, 255, 255, 255 ];
// global resistances: [[u16; 8]; 3] = [
//     [ 0,  75, 100, 85,  50, 100, 20,  0 ], // Melee vs dummy, archer, ritualist, thief, knight, mage, wall, water
//     [ 0,  80, 100, 90,  25, 100,  5,  0 ], // Ranged vs dummy, archer, ritualist, thief, knight, mage, wall, water
//     [ 0,  80, 100, 90, 100,  90, 60, 50 ], // Fireball vs dummy, archer, ritualist, thief, knight, mage, wall, water
// ];

// global trap_resistances: [u16; 8] = [ 0,  75, 100, 50,  75, 90, 5, 0 ]; // Trap vs dummy, archer, ritualist, thief, knight, mage

// // struct CharacterClass {
// //     class: u8,
// //     damage: u8,
// //     energy_per_attack: u8,
// //     energy_per_cast: u8,
// //     energy_per_disarm: u8,
// //     energy_per_move: u8,
// //     energy_per_ritual: u8,
// //     energy_per_search: u8,
// //     energy_per_sneak: u8,
// // }

// pub struct Character {
//     pub id: u8,
//     pub x: u8, // 5 bit
//     pub y: u8, // 4 bit
//     pub class: u8, // 3 bit
//     pub status: u8, // 0 = idle, 1-15 = continuing action => 4 bit
//     pub health: u8,
//     pub has_been_seen: bool,
//     pub is_hidden: u1,
//     pub target_x: u8,
//     pub target_y: u8,
//     pub damage_mod: u8,
// }

// impl Character {
//     pub fn get_id(self) -> u8 {
//         self.id
//     }

//     pub fn get_x(self) -> u8 {
//         self.x
//     }

//     pub fn get_y(self) -> u8 {
//         self.y
//     }

//     pub fn get_class(self) -> u8 {
//         self.class
//     }

//     pub fn get_status(self) -> u8 {
//         self.status
//     }

//     pub fn get_health(self) -> u8 {
//         self.health
//     }

//     pub fn get_has_been_seen(self) -> bool {
//         self.has_been_seen
//     }

//     pub fn get_target_x(self) -> u8 {
//         self.target_x
//     }

//     pub fn get_target_y(self) -> u8 {
//         self.target_y
//     }

//     pub fn get_energy_per_attack(self) -> u8 {
//         class_energy_per_attack[self.class]
//     }

//     pub fn get_energy_per_cast(self) -> u8 {
//         class_energy_per_cast[self.class]
//     }

//     pub fn get_energy_per_disarm(self) -> u8 {
//         class_energy_per_disarm[self.class]
//     }

//     pub fn get_energy_per_move(self) -> u8 {
//         class_energy_per_move[self.class]
//     }

//     pub fn get_energy_per_ritual(self) -> u8 {
//         class_energy_per_ritual[self.class]
//     }

//     pub fn get_energy_per_search(self) -> u8 {
//         class_energy_per_search[self.class]
//     }

//     pub fn get_energy_per_sneak(self) -> u8 {
//         class_energy_per_sneak[self.class]
//     }

//     pub fn get_energy_per_draw(self) -> u8 {
//         class_energy_per_draw[self.class]
//     }

//     pub fn get_energy_per_shoot(self) -> u8 {
//         class_energy_per_shoot[self.class]
//     }

//     pub fn get_damage(self, attack_type: u8) -> u8 {
//         self.damage_mod + class_damage[attack_type][self.class]
//     }

//     pub fn can_sneak(self) -> bool {
//         class_energy_per_sneak[self.class] != 255
//     }

//     pub fn can_ritual(self) -> bool {
//         class_energy_per_ritual[self.class] != 255
//     }

//     pub fn can_cast_fireball(self) -> bool {
//         class_energy_per_cast[self.class] != 255
//     }

//     pub fn can_shoot(self) -> bool {
//         self.class == ARCHER
//     }
//     pub fn can_disarm(self) -> bool {
//         class_energy_per_disarm[self.class] != 255
//     }

//     pub fn can_search(self) -> bool {
//         class_energy_per_search[self.class] != 255
//     }

//     pub fn is_valid(self) -> bool {
//         (((self.x < WIDTH) & (self.y < HEIGHT)) | ((self.x == 255) & (self.y == 255))) &
//         (((self.target_x < WIDTH) & (self.target_y < HEIGHT)) | ((self.target_x == 255) & (self.target_y == 255))) &
//         (self.class < CLASS_COUNT) &
//         (self.status < STATUS_COUNT)
//     }

//     pub fn serialize(self) -> [u8; 6] {
//         assert(WIDTH <= WIDTH_MASK + 1);
//         assert(HEIGHT <= HEIGHT_MASK + 1);
//         assert(CLASS_COUNT <= CLASS_MASK + 1);
//         assert(STATUS_COUNT <= STATUS_MASK + 1);
//         assert(WIDTH_BITS + CLASS_BITS <= 8);
//         assert(HEIGHT_BITS + STATUS_BITS <= 8);
//         assert(WIDTH_BITS + 1 <= 8);
//         assert(self.is_valid());
//         let packed_x = self.x | (self.class << WIDTH_BITS);
//         let packed_y = self.y | (self.status << HEIGHT_BITS);
//         let packed_target_x = (self.target_x & WIDTH_MASK) + ((self.is_hidden as u8) << WIDTH_BITS);
//         let packed_target_y = self.target_y & HEIGHT_MASK;
        
//         [packed_x, packed_y, self.health, packed_target_x, packed_target_y, self.damage_mod]
//     }

//     pub fn to_obstacle(self) -> Obstacle {
//         assert(MAX_CHARACTERS < (255 - MAX_OBSTACLES));
//         assert(self.is_valid());
//         Obstacle {
//             id: self.id + (MAX_CHARACTERS as u8),
//             x: self.x,
//             y: self.y,
//             obstacle_type: self.class,
//             health: self.health,
//             //was_alive: 
//         }
//     }

//     pub fn move(self, x: u8, y: u8) -> Character {
//         let mut c = self;
//         c.x = x;
//         c.y = y;
//         c
//     }

//     pub fn take_damage(self, attack_type: u8, dmg: u8) -> Character {
//         let damage_after_resistances = get_attack_damage_to_tile(attack_type, dmg as u16, self.class);
//         let mut c = self;
//         if damage_after_resistances > (c.health as u16) {
//             c.health = 0;
//         } else {
//             c.health -= (damage_after_resistances as u8);
//         }
//         c
//     }

//     pub fn set_status(self, status: u8) -> Character {
//         assert(status < STATUS_COUNT);
//         let mut c = self;
//         c.status = status;
//         c
//     }

//     pub fn create_character(id: u8, x: u8, y: u8, class: u8) -> Character {
//         let c = Character {
//             id: id,
//             x: x,
//             y: y,
//             class: class,
//             status: 0,
//             health: 0,
//             has_been_seen: false,
//             is_hidden: 0,
//             target_x: 255,
//             target_y: 255,
//             damage_mod: 0,//: class_damage[class],
//         };
//         assert(c.is_valid());
//         c
//     }

//     pub fn parse(id: u8, data: Field, events: [Event; MAX_EVENTS], enemy_advance: u8, side: u1) -> Character {
//         // these asserts could be disabled for production
//         assert(WIDTH <= WIDTH_MASK + 1);
//         assert(HEIGHT <= HEIGHT_MASK + 1);
//         assert(CLASS_COUNT <= CLASS_MASK + 1);
//         assert(STATUS_COUNT <= STATUS_MASK + 1);
//         assert(WIDTH_BITS + CLASS_BITS <= 8);
//         assert(HEIGHT_BITS + STATUS_BITS <= 8);
//         assert(WIDTH_BITS + 1 <= 8);

//         let split: [u8; 32] = data.to_be_bytes();
//         assert(split.len() == 32);
//         let x_packed = split[2 + id * 6]; // 5 bit x, 3 bit class
//         let y_packed = split[2 + id * 6 + 1]; // 4 bit y, 4 bit status
//         let mut health = split[2 + id * 6 + 2] as u16;
//         let target_x_packed = split[2 + id * 6 + 3]; // 5 bit target x, 1 bit hidden, 1 bit has target, 1 bit unused
//         let target_y_packed = split[2 + id * 6 + 4]; // 4 bit target y, 4 bit unused
//         let damage_mod = split[2 + id * 6 + 5]; // last byte: for the moment, use to save damage_mod (buffs, etc)

//         let x = x_packed & WIDTH_MASK;
//         let y = y_packed & HEIGHT_MASK;
//         let class = (x_packed >> WIDTH_BITS) & CLASS_MASK;
//         let status = (y_packed >> HEIGHT_BITS) & STATUS_MASK;
//         let target_x = target_x_packed & WIDTH_MASK;
//         let target_y = target_y_packed & HEIGHT_MASK;

//         let is_visible = is_visible(side, enemy_advance, x); //((target_x_packed >> 5) & 1) as u1;
//         let is_hidden = ((target_x_packed >> WIDTH_BITS) & 1) as u1;

//         let mut damage: u16 = 0;
//         for i in 0..MAX_EVENTS {
//             if events[i].actor_id == id {
//                 let event = events[i];
//                 if event.actor_id == id {
//                     damage += event.get_applied_damage_to_my_asset(x, y, class);
//                 }
//             }
//         }
//         if damage > health {
//             health = 0;
//         } else {
//             health -= damage;
//         }

//         let c = Character {
//             id: id,
//             x: x,
//             y: y,
//             class: class,
//             status: status,
//             health: health as u8,
//             has_been_seen: is_visible, // TODO 
//             is_hidden: is_hidden,
//             target_x: target_x,
//             target_y: target_y,
//             damage_mod: damage_mod,
//         };
//         assert(c.is_valid());
//         c
//     }
// }

// pub fn get_default_characters(side: u8) -> [Character; MAX_CHARACTERS] {
//     assert(side < 2, f"Side is too large {side}");
//     let x = |x| x * ((side + 1) % 2) + (WIDTH - 1 - x) * side;
//     [
//         Character { id: 0, x: x(2), y: 2, class: ARCHER, health: 100, status: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0 },
//         Character { id: 1, x: x(2), y: 3, class: RITUALIST, health: 60, status: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0 },
//         Character { id: 2, x: x(2), y: 4, class: ROGUE, health: 80, status: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0 },
//         Character { id: 3, x: x(2), y: 5, class: KNIGHT, health: 120, status: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0 },
//         Character { id: 4, x: x(2), y: 6, class: MAGE, health: 40, status: 0, target_x: 0, target_y: 0, has_been_seen: false, damage_mod: 0, is_hidden: 0 },
//     ]
// }

// pub fn parse_characters(data: Field, events: [Event; MAX_EVENTS], enemy_advance: u8, side: u1) -> [Character; MAX_CHARACTERS] {
//     assert(MAX_CHARACTERS <= 5);
//     let mut result: [Character; MAX_CHARACTERS] = [Character::create_character(0, 0, 0, 0), Character::create_character(1, 0, 0, 0), Character::create_character(2, 0, 0, 0), Character::create_character(3, 0, 0, 0), Character::create_character(4, 0, 0, 0)];
//     for i in 0..5 {
//         result[i] = Character::parse(i, data, events, enemy_advance, side);
//     }
//     result
// }

// pub fn get_test_my_character(id: u8, x: u8, y: u8, class: u8) -> Character {
//     assert(id < 5);
//     assert(class < CLASS_COUNT);
//     assert(x < WIDTH);
//     assert(y < HEIGHT);

//     Character {
//         id: id,
//         x: x,
//         y: y,
//         class: class,
//         status: 0,
//         health: 100,
//         has_been_seen: false,
//         is_hidden: 0,
//         target_x: 255,
//         target_y: 255,
//         damage_mod: 0,
//     }
// }

// pub fn get_test_their_character(id: u8, x: u8, y: u8, class: u8) -> Character {
//     assert(id < 5);
//     assert(class < CLASS_COUNT);
//     assert(x < WIDTH);
//     assert(y < HEIGHT);

//     Character {
//         id: id,
//         x: x,
//         y: y,
//         class: class,
//         status: 0,
//         health: 255,
//         has_been_seen: false,
//         is_hidden: 0,
//         target_x: 255,
//         target_y: 255,
//         damage_mod: 0,
//     }
// }

// #[test]
// fn test_serialize_character() {
//     let mut character = Character {
//         id: 4,
//         x: 21,
//         y: 9,
//         class: 5,
//         status: 9,
//         health: 129,
//         has_been_seen: false,
//         is_hidden: 0,
//         target_x: 31,
//         target_y: 9,
//         damage_mod: 0,
//     };
//     let field = character.serialize();
//     assert(field[0] == (21 | (5 << 5)));
//     assert(field[1] == (9 | (9 << 4)));
//     assert(field[2] == 129);
//     assert(field[3] == 31); // TODO: why?
//     assert(field[4] == 9);
//     assert(field[5] == 0);
// }

// #[test]
// fn test_parse_character() {
//     let dummy_events = Event::get_test_dummy_events();
//     let data_array: [u8; 32] = [
//         0 as u8, 0 as u8,
//         0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
//         0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
//         191 as u8, 249 as u8, 255 as u8, 255 as u8, 9 as u8, 255 as u8,
//         181 as u8, 153 as u8, 129 as u8, 127 as u8, 9 as u8, 0 as u8,
//         0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8, 0 as u8,
//     ];
//     let data: Field = std::field::bytes32_to_field(data_array);
//     println(data);
//     assert(data == 0xbff9ffff09ffb599817f0900000000000000, f"Failed assumption: data: {data} != 0xbff9ffff09ffb599817f0900000000000000");
//     let character = Character::parse(3, data, dummy_events, 20, 0);
//     assert(character.get_id() == 3);
//     assert(character.get_x() == 21);
//     assert(character.get_y() == 9);
//     assert(character.get_class() == 5);
//     assert(character.get_status() == 9);
//     assert(character.get_health() == 129);
//     assert(character.get_has_been_seen());
//     assert(character.get_target_x() == 31);
//     assert(character.get_target_y() == 9);

//     let character_max = Character::parse(2, data, dummy_events, 20, 0);
//     assert(character_max.get_id() == 2);
//     assert(character_max.get_x() == 31);
//     assert(character_max.get_y() == 9);
//     assert(character_max.get_class() == 5);
//     assert(character_max.get_status() == 15);
//     assert(character_max.get_health() == 255);
//     assert(character_max.get_has_been_seen());
//     assert(character_max.get_target_x() == 31);
//     assert(character_max.get_target_y() == 9);

//     let character_min = Character::parse(0, data, dummy_events, 20, 0);
//     assert(character_min.get_id() == 0);
//     assert(character_min.get_x() == 0);
//     assert(character_min.get_y() == 0);
//     assert(character_min.get_class() == 0);
//     assert(character_min.get_status() == 0);
//     assert(character_min.get_health() == 0);
//     assert(character_min.get_has_been_seen() == false);
//     assert(character_min.get_target_x() == 0);
//     assert(character_min.get_target_y() == 0);
// }

// #[test]
// fn test_parse_character_as_in_game() {
//     let data: Field = 0x1602ff1f09001603ff1f0f001604ff1f0f001605ff1f0f001606ff1f0f00;
//     let character = Character::parse(0, data, Event::get_test_dummy_events(), 20, 0);
//     assert(character.get_id() == 0);
//     assert(character.get_x() == 22, character.get_x());
//     assert(character.get_y() == 2, character.get_y());
//     assert(character.get_class() == 0, character.get_class());
//     assert(character.get_status() == 0, character.get_status());
//     assert(character.get_health() == 255);
//     assert(character.get_has_been_seen() == true);
//     assert(character.get_target_x() == 31);
//     assert(character.get_target_y() == 9);
// }

// pub fn serialize_chars(chars: [Character; 5]) -> Field {
//     let mut result: [u8; 32] = [0; 32];
//     for i in 0..5 {
//         let serialized = chars[i].serialize();
//         for j in 0..6 {
//             result[2 + i * 6 + j] = serialized[j];
//         }
//     }
    
//     std::field::bytes32_to_field(result)
// }

// /**
// * For now we will only take class into account.
// */
// pub fn get_attack_damage_to_tile(attack_type: u8, damage: u16, class: u8) -> u16 {
//     assert(class <= WATER);
//     (damage * resistances[attack_type][class] / 100) as u16
// }

// pub fn get_trap_damage_to_tile(damage: u16, class: u8) -> u16 {
//     assert(class <= WATER);
//     (damage * trap_resistances[class] / 100) as u16
// }