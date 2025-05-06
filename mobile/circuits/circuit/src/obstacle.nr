// use crate::MAX_OBSTACLES;
// use crate::{ HEIGHT, WIDTH };
// use crate::{ EMPTY, WALL, WATER };
// use crate::{ MAX_EVENTS }; // MAX_CHARACTERS
// // use crate::{ RECEIVE_ATTACK };
// // use crate::{ ATTACK_MELEE, ATTACK_RANGED, ATTACK_FIREBALL };
// use crate::{ SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE, SERIALIZED_OBSTACLE_BYTE_SIZE, SERIALIZED_OBSTACLES_PER_FIELD, SERIALIZED_OBSTACLES_ARRAY_SIZE };
// use crate::NON_EMPTY_WALKABLE_TILE_MIN;
// use crate::event::Event;
// use crate::map::{ is_visible }; //is_neighbor
// use dep::std;

// pub struct Obstacle {
//     pub id: u8,
//     pub x: u8,             // 5 bit
//     pub y: u8,             // 4 bit
//     pub health: u8,        // 8 bit
//     pub obstacle_type: u8, // 4 bit
// }

// pub impl Obstacle {
//     pub fn serialize(self) -> [u8; SERIALIZED_OBSTACLE_BYTE_SIZE] {
//         assert(SERIALIZED_OBSTACLE_BYTE_SIZE == 3, f"Obstacle byte size is not 3");
//         assert(self.y < 0x10, f"Obstacle y is too large");
//         assert(self.obstacle_type < 0x10, f"Obstacle type is too large");

//         let packed_y = self.obstacle_type * 0x10 + self.y;
//         [ self.x, packed_y, self.health]
//     }

//     pub fn is_traversible(self) -> bool {
//         (self.obstacle_type >= NON_EMPTY_WALKABLE_TILE_MIN) | (self.obstacle_type == EMPTY)
//     }

//     pub fn parse_theirs(id: u8, field: [u8; SERIALIZED_OBSTACLE_BYTE_SIZE]) -> Obstacle {
//         assert(SERIALIZED_OBSTACLE_BYTE_SIZE == 3, f"Obstacle byte size is not 3");
//         //assert((id as u64) >= MAX_CHARACTERS, f"Obstacle id is lower than minimum {id}");
//         let x = field[0];
//         let y = field[1] & 0x0F;
//         let obstacle_type = (field[1] & 0xF0) / 0x10;
//         let health = field[2];
//         let o = Obstacle {
//             id: id,
//             x: x,
//             y: y,
//             health: health,
//             obstacle_type: obstacle_type,
//         };
//         assert(o.is_valid());
//         o
//     }

//     pub fn parse(id: u8, field: [u8; SERIALIZED_OBSTACLE_BYTE_SIZE], events: [Event; MAX_EVENTS]) -> Obstacle {
//         assert(SERIALIZED_OBSTACLE_BYTE_SIZE == 3, f"Obstacle byte size is not 3");
//         //assert((id as u64) >= MAX_CHARACTERS, f"Obstacle id is lower than minimum {id}");
//         let x = field[0];
//         let y = field[1] & 0x0F;
//         let obstacle_type = (field[1] & 0xF0) / 0x10;
//         let mut health = field[2];
//         if (obstacle_type == WALL) | (obstacle_type == WATER) {
//             let mut damage = 0;
//             for i in 0..MAX_EVENTS {
//                 damage += events[i].get_applied_damage_to_my_asset(x, y, obstacle_type);
//             }
//             if damage > (health as u16) {
//                 health = 0;
//             } else {
//                 health -= (damage as u8);
//             }
//         }
//         let o = Obstacle {
//             id: id, // + (MAX_CHARACTERS as u8),
//             x: x,
//             y: y,
//             health: health,
//             obstacle_type: obstacle_type,
//             //was_alive: was_alive,
//         };
//         assert(o.is_valid());
//         o
//     }

//     pub fn is_valid(self) -> bool {
//         (self.x < WIDTH) & (self.y < HEIGHT)
//     }

//     pub fn parse_their_obstacles(serialized_obstacles: [Field; SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE]) -> [Obstacle] {
//         let mut obstacles: [Obstacle] = &[];
//         for i in 0..serialized_obstacles.len() {
//             let serialized_obstacle_field: [u8; 32] = serialized_obstacles[i].to_be_bytes();
//             assert(serialized_obstacle_field.len() == 32);
//             for j in 0..SERIALIZED_OBSTACLES_PER_FIELD {
//                 let serialized_obstacle = [serialized_obstacle_field[2 + j * 3], serialized_obstacle_field[2 + j * 3 + 1], serialized_obstacle_field[2 + j * 3 + 2]];
//                 let id = (i * SERIALIZED_OBSTACLES_PER_FIELD + j) as u8;
//                 obstacles = obstacles.push_back(Obstacle::parse_theirs(id, serialized_obstacle));
//             }
//         }
//         obstacles
//     }

//     pub fn parse_my_obstacles(serialized_obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE], events: [Event; MAX_EVENTS]) -> [Obstacle] {
//         let mut obstacles: [Obstacle] = &[];
//         for i in 0..serialized_obstacles.len() {
//             let serialized_obstacle_field: [u8; 32] = serialized_obstacles[i].to_be_bytes();
//             assert(serialized_obstacle_field.len() == 32);
//             for j in 0..SERIALIZED_OBSTACLES_PER_FIELD {
//                 let serialized_obstacle = [serialized_obstacle_field[2 + j * 3], serialized_obstacle_field[2 + j * 3 + 1], serialized_obstacle_field[2 + j * 3 + 2]];
//                 let id = (i * SERIALIZED_OBSTACLES_PER_FIELD + j) as u8;
//                 obstacles = obstacles.push_back(Obstacle::parse(id, serialized_obstacle, events));
//             }
//         }
//         obstacles
//     }

//     pub fn serialize_obstacles(side: u1, enemy_advance: u8, obstacles: [Obstacle; MAX_OBSTACLES]) -> [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE] {
//         let mut serialized_obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE] = [0; SERIALIZED_OBSTACLES_ARRAY_SIZE];
//         for i in 0..SERIALIZED_OBSTACLES_ARRAY_SIZE {
//             let mut serialized_obstacle_field: [u8; 32] = [0; 32];
//             for j in 0..SERIALIZED_OBSTACLES_PER_FIELD {
//                 let obstacle = obstacles[i * SERIALIZED_OBSTACLES_PER_FIELD + j];
//                 if is_visible(side, enemy_advance, obstacle.x) {
//                     let serialized_obstacle = obstacle.serialize();
//                     for k in 0..3 {
//                         serialized_obstacle_field[2 + j * 3 + k] = serialized_obstacle[k];
//                     }
//                 }
//             }
//             serialized_obstacles[i] = std::field::bytes32_to_field(serialized_obstacle_field);
//         }
//         serialized_obstacles
//     }

//     pub fn get_default_obstacles(side: u8) -> [Obstacle; MAX_OBSTACLES] {
//         assert(side < 2, f"Side is too large {side}");
//         let x = |x| x * ((side + 1) % 2) + (WIDTH - 1 - x) * side;
//         [
//             Obstacle { id:  0, x: x(0), y: 2, obstacle_type: WALL,  health: 200 },
//             Obstacle { id:  1, x: x(1), y: 2, obstacle_type: WALL,  health: 200 },
//             Obstacle { id:  2, x: x(3), y: 2, obstacle_type: WALL,  health: 200 },
//             Obstacle { id:  3, x: x(4), y: 2, obstacle_type: WALL,  health: 200 },
//             Obstacle { id:  4, x: x(5), y: 3, obstacle_type: WALL,  health: 200 },
//             Obstacle { id:  5, x: x(5), y: 4, obstacle_type: WALL,  health: 200 },
//             Obstacle { id:  6, x: x(5), y: 5, obstacle_type: WALL,  health: 200 },
//             Obstacle { id:  7, x: x(5), y: 7, obstacle_type: WALL,  health: 200 },
//             Obstacle { id:  8, x: x(4), y: 7, obstacle_type: WALL,  health: 200 },
//             Obstacle { id:  9, x: x(3), y: 7, obstacle_type: WALL,  health: 200 },
//             Obstacle { id: 10, x: x(1), y: 7, obstacle_type: WALL,  health: 200 },
//             Obstacle { id: 11, x: x(0), y: 7, obstacle_type: WALL,  health: 200 },
//             Obstacle { id: 12, x: x(7), y: 0, obstacle_type: WALL,  health: 200 },
//             Obstacle { id: 13, x: x(7), y: 1, obstacle_type: WALL,  health: 200 },
//             Obstacle { id: 14, x: x(7), y: 2, obstacle_type: WALL,  health: 200 },
//             Obstacle { id: 15, x: x(7), y: 3, obstacle_type: WALL,  health: 200 },
//             Obstacle { id: 16, x: x(7), y: 4, obstacle_type: WALL,  health: 200 },
//             Obstacle { id: 17, x: x(7), y: 5, obstacle_type: WALL,  health: 200 },
//             Obstacle { id: 18, x: x(6), y: 8, obstacle_type: WATER, health: 255 },
//             Obstacle { id: 19, x: x(7), y: 8, obstacle_type: WATER, health: 255 },
//             Obstacle { id: 20, x: x(5), y: 9, obstacle_type: WATER, health: 255 },
//             Obstacle { id: 21, x: x(6), y: 9, obstacle_type: WATER, health: 255 },
//             Obstacle { id: 22, x: x(7), y: 9, obstacle_type: WATER, health: 255 },
//             Obstacle { id: 23, x: x(8), y: 9, obstacle_type: WATER, health: 255 },
//         ]
//     }
// }