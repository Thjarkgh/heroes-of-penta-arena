// use crate::{ NO_EVENT, SEE_MOVE, RECEIVE_ATTACK, TRIGGERED_TRAP }; //, SEE_RITUAL, SEE_CAST, SEE_DRAW, SEE_SEARCH_TRAP, FOUND_TRAP
// // use crate::{ EMPTY, WALL };
// use crate::{ EVENT_COUNT };
// use crate::{ ATTACK_FIREBALL };
// use crate::{ SERIALIZED_EVENT_BYTE_SIZE, SERIALIZED_EVENTS_ARRAY_SIZE, SERIALIZED_EVENTS_PER_FIELD };
// use crate::{ WIDTH, NOWHERE };
// use crate::{ MAX_CHARACTERS, MAX_EVENTS }; //, MAX_TRAPS
// // use crate::TRAPS_BUFFER_MASK;
// use crate::UNREADABLE_BYTES_PER_FIELD;
// use crate::map::is_neighbor;
// // use crate::character::Character;
// use crate::character::{ get_attack_damage_to_tile, get_trap_damage_to_tile };
// use dep::std;

// pub struct Event {
//     pub event: u8,
//     pub actor_id: u8,
//     pub subtype: u8,
//     pub x: u8,
//     pub y: u8,
//     pub value: u8,
// }

// impl Event {
//     pub fn parse_events(fields: [Field; SERIALIZED_EVENTS_ARRAY_SIZE]) -> [Event; MAX_EVENTS] {
//         assert(UNREADABLE_BYTES_PER_FIELD + SERIALIZED_EVENTS_PER_FIELD * SERIALIZED_EVENT_BYTE_SIZE <= 32);
//         assert(SERIALIZED_EVENTS_ARRAY_SIZE * SERIALIZED_EVENTS_PER_FIELD == MAX_EVENTS);
//         assert(SERIALIZED_EVENT_BYTE_SIZE >= 6);

//         let mut events: [Event; MAX_EVENTS] = [Event::empty(0); MAX_EVENTS];
//         for i in 0..SERIALIZED_EVENTS_ARRAY_SIZE {
//             let split: [u8; 32] = fields[i].to_be_bytes(); //.to_be_bytes<32>();
//             assert(split.len() == 32);
//             for j in 0..SERIALIZED_EVENTS_PER_FIELD {
//                 let offset = UNREADABLE_BYTES_PER_FIELD + j * SERIALIZED_EVENT_BYTE_SIZE;
//                 events[i * SERIALIZED_EVENTS_PER_FIELD + j] = Event {
//                     event: split[offset],
//                     actor_id: split[offset + 1],
//                     x: split[offset + 2],
//                     y: split[offset + 3],
//                     value: split[offset + 4],
//                     subtype: split[offset + 5],
//                 };
//             }
//         }
//         events
//     }
    
//     pub fn serialize_events(events: [Event]) -> [Field] {
//         assert(events.len() == MAX_EVENTS);
//         assert(MAX_EVENTS % SERIALIZED_EVENTS_PER_FIELD == 0);
//         assert(SERIALIZED_EVENT_BYTE_SIZE >= 6);

//         let mut fields: [Field] = &[];
//         for i in 0..SERIALIZED_EVENTS_ARRAY_SIZE {
//             let mut data: [u8; 32] = [0; 32];
//             for j in 0..SERIALIZED_EVENTS_PER_FIELD {
//                 let index = i * SERIALIZED_EVENTS_PER_FIELD + j;
//                 let event = events[index];
//                 let offset = UNREADABLE_BYTES_PER_FIELD + j * SERIALIZED_EVENT_BYTE_SIZE;
//                 data[offset] = event.event;
//                 data[offset + 1] = event.actor_id;
//                 data[offset + 2] = event.x;
//                 data[offset + 3] = event.y;
//                 data[offset + 4] = event.value;
//                 data[offset + 5] = event.subtype;
//             }
//             fields = fields.push_back(std::field::bytes32_to_field(data));
//         }
//         fields
//     }
    
//     fn affects_my_character(self, x: u8, y: u8) -> bool {
//         ((self.x == x) & (self.y == y)) | ((self.event == RECEIVE_ATTACK) & (self.subtype == ATTACK_FIREBALL) & is_neighbor(self.x, self.y, x, y))
//     }

//     fn affects_my_obstacle(self, x: u8, y: u8) -> bool {
//         (self.x == x) & (self.y == y)
//     }

//     fn may_affect_my_other_characters(self) -> bool {
//         (self.event == RECEIVE_ATTACK) & (self.subtype == ATTACK_FIREBALL)
//     }

//     fn may_affect_my_obstacles(self) -> bool {
//         self.event == RECEIVE_ATTACK
//     }

//     /**
//     * For now we will only take class into account.
//     */
//     pub fn get_applied_damage_to_my_asset(self, x: u8, y: u8, tile: u8) -> u16 {
//         let mut damage = 0;
    
//         if self.event == RECEIVE_ATTACK {
//             if (self.x == x) & (self.y == y) {
//                 damage = get_attack_damage_to_tile(self.subtype, self.value as u16, tile);
//             } else if (self.subtype == ATTACK_FIREBALL) & is_neighbor(self.x, self.y, x, y) {
//                 damage = get_attack_damage_to_tile(self.subtype, self.value as u16, tile) / 2;
//             }
//         }
//         if self.event == TRIGGERED_TRAP {
//             damage = get_trap_damage_to_tile(self.value as u16, tile);
//         }
//         damage as u16
//     }

//     pub fn empty(actor_id: u8) -> Event {
//         Event {
//             event: NO_EVENT,
//             actor_id: actor_id,
//             x: 0,
//             y: 0,
//             value: 0,
//             subtype: 0,
//         }
//     }

//     pub fn get_dummy_events() -> [Field; MAX_EVENTS] {
//         [0; MAX_EVENTS]
//     }

//     pub fn get_test_dummy_events() -> [Event; MAX_EVENTS] {
//         [Event::empty(0); MAX_EVENTS]
//     }
// }

// pub fn build_std_event(event: u8, actor_id: u8, x: u8, y: u8) -> Event {
//     assert(event < EVENT_COUNT);
//     assert((actor_id as u32) < MAX_CHARACTERS);
//     assert((x < WIDTH) | (x == NOWHERE));
//     Event {
//         event: event,
//         actor_id: actor_id,
//         x: x,
//         y: y,
//         value: 0,
//         subtype: 0,
//     }
// }

// #[test]
// fn test_build_std_event() {
//     let event = build_std_event(SEE_MOVE, 1, 2, 3);
//     assert(event.event == SEE_MOVE);
//     assert(event.actor_id == 1);
//     assert(event.x == 2);
//     assert(event.y == 3);
// }

// #[test(should_fail)]
// fn test_build_std_event_fail() {
//     let event = build_std_event(EVENT_COUNT, 1, 2, 3);
//     assert(event.event == EVENT_COUNT);
// }

// pub fn build_value_event(event: u8, actor_id: u8, x: u8, y: u8, value: u8) -> Event {
//     Event {
//         event: event,
//         actor_id: actor_id,
//         x: x,
//         y: y,
//         value: value,
//         subtype: 0,
//     }
// }

// pub fn build_subtype_value_event(event: u8, actor_id: u8, x: u8, y: u8, value: u8, subtype: u8) -> Event {
//     Event {
//         event: event,
//         actor_id: actor_id,
//         x: x,
//         y: y,
//         value: value,
//         subtype: subtype,
//     }
// }
