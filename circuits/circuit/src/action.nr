// // use crate::{ HEIGHT, WIDTH };
// use crate::{ SNEAK, MOVE, RITUAL, SEARCH, ATTACK, CAST_FIREBALL, DRAW, DISARM_TRAP, SHOOT };
// use crate::{ NO_EVENT, WAIT, SEE_MOVE, WIN, SEE_RITUAL, SEE_SEARCH_TRAP, RECEIVE_ATTACK, ATTACK_MELEE, SEE_CAST, SEE_DRAW, DESTROY, ATTACK_FIREBALL, ATTACK_RANGED };
// use crate::{ FIREBALL_ROUNDS_FOR_CAST, RITUAL_ROUNDS_FOR_WIN };
// use crate::{ MIN_DRAW_ROUNDS_FOR_SHOOT, MAX_DRAW_ROUNDS_FOR_SHOOT };
// use crate::{ MAX_ACTIONS, MAX_OBSTACLES };
// use crate::{ SERIALIZED_ACTION_BYTE_SIZE, SERIALIZED_ACTIONS_ARRAY_SIZE, SERIALIZED_ACTIONS_PER_FIELD };
// use crate::UNREADABLE_BYTES_PER_FIELD;
// // use crate::NON_EMPTY_WALKABLE_TILE_MIN;
// use crate::character::Character;
// use crate::event::Event;
// use crate::event::{ build_std_event, build_subtype_value_event }; // , build_value_event
// use crate::map::{ is_neighbor, is_visible };
// use crate::obstacle::Obstacle;
// use dep::std;

// pub struct Action {
//     pub action: u8,
//     pub actor: u8,
//     pub target_x: u8,
//     pub target_y: u8,
// }
// // TODO: action type as global struct & impl
// pub impl Action {
//     pub fn parse_actions(fields: [Field; SERIALIZED_ACTIONS_ARRAY_SIZE]) -> [Action; MAX_ACTIONS] {
//         assert(UNREADABLE_BYTES_PER_FIELD + SERIALIZED_ACTIONS_PER_FIELD * SERIALIZED_ACTION_BYTE_SIZE <= 32);
//         assert(SERIALIZED_ACTIONS_ARRAY_SIZE * SERIALIZED_ACTIONS_PER_FIELD == MAX_ACTIONS);
//         assert(SERIALIZED_ACTION_BYTE_SIZE >= 4);

//         let mut actions: [Action] = &[];
//         for i in 0..SERIALIZED_ACTIONS_ARRAY_SIZE {
//             let split: [u8; 32] = fields[i].to_be_bytes();
//             assert(split.len() == 32);
//             for j in 0..SERIALIZED_ACTIONS_PER_FIELD {
//                 let offset = UNREADABLE_BYTES_PER_FIELD + j * SERIALIZED_ACTION_BYTE_SIZE;
//                 actions = actions.push_back(Action {
//                     action: split[offset],
//                     actor: split[offset + 1],
//                     target_x: split[offset + 2],
//                     target_y: split[offset + 3],
//                 });
//             }
//         }
//         actions.as_array()
//     }
    
//     pub fn serialize_actions(actions: [Action]) -> [Field; SERIALIZED_ACTIONS_ARRAY_SIZE] {
//         assert(UNREADABLE_BYTES_PER_FIELD + SERIALIZED_ACTIONS_PER_FIELD * SERIALIZED_ACTION_BYTE_SIZE <= 32);
//         assert(SERIALIZED_ACTIONS_ARRAY_SIZE * SERIALIZED_ACTIONS_PER_FIELD == MAX_ACTIONS);
//         assert(SERIALIZED_ACTION_BYTE_SIZE >= 4);

//         assert(actions.len() <= MAX_ACTIONS);

//         let mut actions_stuffed: [Action; MAX_ACTIONS] = [Action { action: WAIT, actor: 0, target_x: 0, target_y: 0 }; MAX_ACTIONS];
//         for i in 0..actions.len() {
//             actions_stuffed[i] = actions[i];
//         }

//         let mut fields: [Field] = &[];
//         for i in 0..SERIALIZED_ACTIONS_ARRAY_SIZE {
//             let mut data: [u8; 32] = [0; 32];
//             for j in 0..SERIALIZED_ACTIONS_PER_FIELD {
//                 let index = i * SERIALIZED_ACTIONS_PER_FIELD + j;
//                 let action = actions_stuffed[index];
//                 let offset = UNREADABLE_BYTES_PER_FIELD + j * SERIALIZED_ACTION_BYTE_SIZE;
//                 data[offset] = action.action;
//                 data[offset + 1] = action.actor;
//                 data[offset + 2] = action.target_x;
//                 data[offset + 3] = action.target_y;
//             }
//             fields = fields.push_back(std::field::bytes32_to_field(data));
//         }
//         fields.as_array()
//     }

//     // fn from_field(field: Field) -> Action {
//     //     Action {
//     //         action: field as u8,
//     //         actor: (field / 0x100) as u8,
//     //         target_x: (field / 0x10000) as u8,
//     //         target_y: (field / 0x1000000) as u8,
//     //     }
//     // }

//     // fn to_field(self) -> Field {
//     //     self.action as Field + (self.actor as Field) * 0x100 + (self.target_x as Field) * 0x10000 + (self.target_y as Field) * 0x1000000
//     // }

//     pub fn execute(self, side: u1, enemy_advance: u8, c: Character, mut energy: u8, my_obstacles_parsed: [Obstacle; MAX_OBSTACLES], their_obstacles: [Obstacle]) -> (Event, Character, u8) {
//         // WAIT: Do nothing

//         let mut result_event: Event = build_std_event(NO_EVENT, c.id, 0, 0);
//         let mut result_char = c;
//         let mut required_energy = 0;

//         if self.action == SNEAK {
//             assert(c.can_sneak());
//             assert(can_move_to(self.target_x, self.target_y, my_obstacles_parsed, their_obstacles));
//             assert(is_neighbor(c.x, c.y, self.target_x, self.target_y));
//             result_char.x = self.target_x;  
//             result_char.y = self.target_y;
//             result_char.status = 0;
//             required_energy = c.get_energy_per_sneak();
//         }
//         if self.action == MOVE {
//             assert(can_move_to(self.target_x, self.target_y, my_obstacles_parsed, their_obstacles));
//             assert(is_neighbor(c.x, c.y, self.target_x, self.target_y));
//             result_char.x = self.target_x;
//             result_char.y = self.target_y;
//             result_char.status = 0;
//             required_energy = c.get_energy_per_move();
//             result_char.has_been_seen = is_visible(side, enemy_advance, result_char.x);
//             if c.get_has_been_seen() {
//                 result_event = build_std_event(SEE_MOVE, c.id, self.target_x, self.target_y);
//             }
//         }
//         if self.action == RITUAL {
//             assert(c.can_ritual());
//             result_char.status += 1;
//             if result_char.status >= RITUAL_ROUNDS_FOR_WIN {
//                 result_event = build_std_event(WIN, c.id, 0, 0);
//             } else {
//                 result_event = build_std_event(SEE_RITUAL, c.id, 0, 0);
//             }
//             required_energy = c.get_energy_per_ritual();
//         }
//         if self.action == SEARCH {
//             assert(c.can_search());
//             assert(is_neighbor(c.x, c.y, self.target_x, self.target_y));
//             result_char.status = 0;
//             result_event = build_std_event(SEE_SEARCH_TRAP, c.id, self.target_x, self.target_y);
//             required_energy = c.get_energy_per_search();
//         }
//         if self.action == ATTACK {
//             assert(is_neighbor(c.x, c.y, self.target_x, self.target_y));
//             assert((c.x != self.target_x) | (c.y != self.target_y));
//             result_char.status = 0;
//             result_event = build_subtype_value_event(RECEIVE_ATTACK, c.id, self.target_x, self.target_y, c.get_damage(ATTACK_MELEE), ATTACK_MELEE);
//             required_energy = c.get_energy_per_attack();
//         }
//         // TODO: global SET_TRAP = 6 as u8;
//         if self.action == CAST_FIREBALL {
//             assert(c.can_cast_fireball());
//             result_char.status += 1;
//             assert(result_char.status <= FIREBALL_ROUNDS_FOR_CAST);
//             if result_char.status >= FIREBALL_ROUNDS_FOR_CAST {
//                 // TODO: handle friendly fire and destruction of own walls and own traps
//                 result_event = build_subtype_value_event(RECEIVE_ATTACK, c.id, self.target_x, self.target_y, c.get_damage(ATTACK_FIREBALL), ATTACK_FIREBALL);
//             } else {
//                 if c.get_has_been_seen() {
//                     result_event = build_subtype_value_event(SEE_CAST, c.id, self.target_x, self.target_y, 0, ATTACK_FIREBALL);
//                 }
//             }
//             required_energy = c.get_energy_per_cast();
//         }
//         if self.action == DRAW {
//             assert(c.can_shoot());
//             assert(c.status < MAX_DRAW_ROUNDS_FOR_SHOOT);
//             result_char.status += 1;
//             if c.get_has_been_seen() {
//                 result_event = build_std_event(SEE_DRAW, c.id, self.target_x, self.target_y);
//             }
//             required_energy = c.get_energy_per_draw();
//         }
//         if self.action == SHOOT {
//             assert(c.can_shoot());
//             assert(c.status >= MIN_DRAW_ROUNDS_FOR_SHOOT);
//             assert((c.x != self.target_x) | (c.y != self.target_y));
//             result_char.status = 0;
//             // TODO: check distance! abs(c.x - self.target_x) + abs(c.y - self.target_y) <= c.get_shoot_range()
//             result_event = build_subtype_value_event(RECEIVE_ATTACK, c.id, self.target_x, self.target_y, c.get_damage(ATTACK_RANGED), ATTACK_RANGED);
//             required_energy = c.get_energy_per_shoot();

//         }
//         // TODO: SET_TRAP
//         if self.action == DISARM_TRAP {
//             assert(c.can_disarm());
//             assert(is_neighbor(c.x, c.y, self.target_x, self.target_y));
//             result_char.status = 0;
//             result_event = build_std_event(DESTROY, c.id, self.target_x, self.target_y);
//             required_energy = c.get_energy_per_disarm();
//         }
        
//         assert(energy >= required_energy);
//         energy -= required_energy;
//         (result_event, result_char, energy)
//     }
// }

// fn can_move_to(x: u8, y: u8, obstacles: [Obstacle; MAX_OBSTACLES], their_obstacles: [Obstacle]) -> bool {
//     let mut can = true;
//     for i in 0..MAX_OBSTACLES {
//         if !obstacles[i].is_traversible() & (obstacles[i].x == x) & (obstacles[i].y == y) {
//             can = false;
//         }
//     }
//     for i in 0..their_obstacles.len() {
//         if !their_obstacles[i].is_traversible() & (their_obstacles[i].x == x) & (their_obstacles[i].y == y) {
//             can = false;
//         }
//     }
//     can
// }