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

//     pub fn is_obstacle_traversible(self) -> bool {
//         (self.obstacle_type >= NON_EMPTY_WALKABLE_TILE_MIN) | (self.obstacle_type == EMPTY)
//     }

//     pub fn parse_their_obstacles(id: u8, field: [u8; SERIALIZED_OBSTACLE_BYTE_SIZE]) -> Obstacle {
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

//     pub fn parse_obstacle(id: u8, field: [u8; SERIALIZED_OBSTACLE_BYTE_SIZE], events: [Event; MAX_EVENTS]) -> Obstacle {
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
//                 obstacles = obstacles.push_back(Obstacle::parse_their_obstacles(id, serialized_obstacle));
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
//                 obstacles = obstacles.push_back(Obstacle::parse_obstacle(id, serialized_obstacle, events));
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

//     pub fn get_default_obstacles(side: u1) -> [Obstacle; MAX_OBSTACLES] {
//         // assert(side < 2, f"Side is too large {side}");
//         let x = |x| x * (((side as u8) + 1) % 2) + (WIDTH - 1 - x) * (side as u8);
//         [
//             new_obstacle( 0, x(0), y: 2, obstacle_type: 200, WALL),
//             new_obstacle( 1, x(1), y: 2, obstacle_type: 200, WALL),
//             new_obstacle( 2, x(3), y: 2, obstacle_type: 200, WALL),
//             new_obstacle( 3, x(4), y: 2, obstacle_type: 200, WALL),
//             new_obstacle( 4, x(5), y: 3, obstacle_type: 200, WALL),
//             new_obstacle( 5, x(5), y: 4, obstacle_type: 200, WALL),
//             new_obstacle( 6, x(5), y: 5, obstacle_type: 200, WALL),
//             new_obstacle( 7, x(5), y: 7, obstacle_type: 200, WALL),
//             new_obstacle( 8, x(4), y: 7, obstacle_type: 200, WALL),
//             new_obstacle( 9, x(3), y: 7, obstacle_type: 200, WALL),
//             new_obstacle(10, x(1), y: 7, obstacle_type: 200, WALL),
//             new_obstacle(11, x(0), y: 7, obstacle_type: 200, WALL),
//             new_obstacle(12, x(7), y: 0, obstacle_type: 200, WALL),
//             new_obstacle(13, x(7), y: 1, obstacle_type: 200, WALL),
//             new_obstacle(14, x(7), y: 2, obstacle_type: 200, WALL),
//             new_obstacle(15, x(7), y: 3, obstacle_type: 200, WALL),
//             new_obstacle(16, x(7), y: 4, obstacle_type: 200, WALL),
//             new_obstacle(17, x(7), y: 5, obstacle_type: 200, WALL),
//             new_obstacle(18, x(6), y: 8, obstacle_type: 255, WATER),
//             new_obstacle(19, x(7), y: 8, obstacle_type: 255, WATER),
//             new_obstacle(20, x(5), y: 9, obstacle_type: 255, WATER),
//             new_obstacle(21, x(6), y: 9, obstacle_type: 255, WATER),
//             new_obstacle(22, x(7), y: 9, obstacle_type: 255, WATER),
//             new_obstacle(23, x(8), y: 9, obstacle_type: 255, WATER),
//         ]
//     }
// }


use arenalib::MAX_OBSTACLES;
use arenalib::{ HEIGHT, WIDTH };
use arenalib::{ EMPTY, WALL, WATER };
use arenalib::{ MAX_EVENTS, MAX_HEALTH, MAX_OBSTACLE_TYPE, MAX_ENEMY_OBSTACLES }; // MAX_CHARACTERS
// use crate::{ RECEIVE_ATTACK };
// use crate::{ ATTACK_MELEE, ATTACK_RANGED, ATTACK_FIREBALL };
use arenalib::{ SerializedArenaEnemyObstacles, SERIALIZED_OBSTACLE_BYTE_SIZE, SERIALIZED_OBSTACLES_PER_FIELD, SERIALIZED_OBSTACLES_ARRAY_SIZE };
use arenalib::NON_EMPTY_WALKABLE_TILE_MIN;
use arenalib::SerializedArenaObstacles;
use crate::event::Event;
use crate::map::{ is_visible, their_x_to_mine }; //is_neighbor
use dep::std;
use skplg::{softassert, NOWHERE};
use arenalib::SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE;
use arenalib::MAX_CHARACTERS;

// pub type Obstacle = [u8; 5];
pub struct Obstacle {
    pub id: u8,
    pub x: u8,             // 5 bit
    pub y: u8,             // 4 bit
    pub health: u8,        // 8 bit
    pub obstacle_type: u8, // 4 bit
}
pub fn get_obstacle_id(obstacle: Obstacle) -> u8 {
    obstacle.id //obstacle[0]
}
pub fn get_obstacle_x(obstacle: Obstacle) -> u8 {
    obstacle.x //[1]
}
pub fn get_obstacle_y(obstacle: Obstacle) -> u8 {
    obstacle.y //[2]
}
pub fn get_obstacle_health(obstacle: Obstacle) -> u8 {
    obstacle.health //[3]
}
pub fn get_obstacle_type(obstacle: Obstacle) -> u8 {
    obstacle.obstacle_type //[4]
}

#[export]
pub fn new_obstacle(id: u8, x: u8, y: u8, health: u8, obstacle_type: u8) -> pub (bool, Obstacle) {
  let valid = ((x < WIDTH) | (x == NOWHERE)) & ((y < HEIGHT) | (y == NOWHERE)) & (health <= MAX_HEALTH) & (obstacle_type <= MAX_OBSTACLE_TYPE) & (id as u32 < (MAX_OBSTACLES + MAX_CHARACTERS));
    // let mut valid = true;
    // softassert!(quote { valid }, quote { (x < WIDTH) | (x == NOWHERE) }, quote { f"Cannot create Obstacle: Invalid x: {x} >= {WIDTH}" });
    // softassert!(quote { valid }, quote { (y < HEIGHT) | (y == NOWHERE) }, quote { f"Cannot create Obstacle: Invalid y: {y} >= {HEIGHT}" });
    // softassert!(quote { valid }, quote { health <= MAX_HEALTH }, quote { f"Cannot create Obstacle: Invalid health: {health} > {MAX_HEALTH}" });
    // softassert!(quote { valid }, quote { obstacle_type <= MAX_OBSTACLE_TYPE }, quote { f"Cannot create Obstacle: Invalid obstacle type: {obstacle_type} > {MAX_OBSTACLE_TYPE}" }); //TODO: not sure if this or is_valid???
    // (valid, [ id, x, y, health, obstacle_type ])
    (valid, Obstacle { id: id, x: x, y: y, health: health, obstacle_type: obstacle_type })
}

#[test]
fn test_new_obstacle() {
  let (val, o) = new_obstacle(0, 0, 2, 0xc8, 0x06);
  assert(val);
  assert(o.id == 0);
}

// #[export]
// pub struct FrontendObstacle {
//   pub id: u8,
//   pub x: u8,
//   pub y: u8,

// }

pub fn serialize_obstacle(obstacle: Obstacle) -> [u8; SERIALIZED_OBSTACLE_BYTE_SIZE] {
    // we could assert here, since obstacles can only be create with new_obstacle?!
    // assert(self.y < 0x10, f"Obstacle y is too large");
    // assert(self.obstacle_type < 0x10, f"Obstacle type is too large");
    comptime {
        let q = if SERIALIZED_OBSTACLE_BYTE_SIZE == 3 {
            quote {
                assert(SERIALIZED_OBSTACLE_BYTE_SIZE == 3, f"Obstacle byte size is not 3");
                let packed_y = get_obstacle_type(obstacle) * 0x10 + get_obstacle_y(obstacle);
                [ get_obstacle_x(obstacle), packed_y, get_obstacle_health(obstacle)]
            }
        } else if SERIALIZED_OBSTACLE_BYTE_SIZE == 4 {
            quote {
                assert(SERIALIZED_OBSTACLE_BYTE_SIZE == 4, f"Obstacle byte size is not 4");
                [ get_obstacle_x(obstacle), get_obstacle_y(obstacle), get_obstacle_health(obstacle), get_obstacle_type(obstacle)]
            }
        } else {
            quote {
                assert((SERIALIZED_OBSTACLE_BYTE_SIZE == 3) | (SERIALIZED_OBSTACLE_BYTE_SIZE == 4), f"Invalid obstacle byte size {SERIALIZED_OBSTACLE_BYTE_SIZE}");
            }
        };
        q
    }
}

pub fn is_obstacle_traversible(obstacle: Obstacle) -> bool {
    (get_obstacle_type(obstacle) >= NON_EMPTY_WALKABLE_TILE_MIN) | (get_obstacle_type(obstacle) == EMPTY)
}

pub fn parse_their_obstacle(id: u8, fld: [u8; SERIALIZED_OBSTACLE_BYTE_SIZE]) -> (bool, Obstacle) {
    comptime {
        assert(SERIALIZED_OBSTACLE_BYTE_SIZE == 3, f"Obstacle byte size is not 3");
    }
    //assert((id as u64) >= MAX_CHARACTERS, f"Obstacle id is lower than minimum {id}");
    let mut valid = true;
    let x_raw = fld[0];
    let (x_parsed_valid, x_parsed) = their_x_to_mine(x_raw);
    softassert!(quote { valid }, quote { x_parsed_valid }, quote { f"Failed to convert their x to mine of their obstacle {id}: {x_raw}" });
    let y = fld[1] & 0x0F;
    let obstacle_type = (fld[1]) / 0x10;
    let health = fld[2];
    let (obstacle_valid, obstacle) = new_obstacle(id, x_parsed, y, health, obstacle_type);
    softassert!(quote { valid }, quote { obstacle_valid }, quote { f"Failed to create new obstacle {id}, {x_parsed}, {y}, {health}, {obstacle_type}" });
    (valid, obstacle)
    // let o = Obstacle {
    //     id: id,
    //     x: x,
    //     y: y,
    //     health: health,
    //     obstacle_type: obstacle_type,
    // };
    // assert(o.is_valid());
    // o
}

pub fn parse_obstacle(id: u8, f: [u8; SERIALIZED_OBSTACLE_BYTE_SIZE], events: [Event; MAX_EVENTS]) -> (bool, Obstacle) {
    //assert((id as u64) >= MAX_CHARACTERS, f"Obstacle id is lower than minimum {id}");
    let x = f[0];
    // let mut y = f[1];
    // let mut obstacle_type = f[1];
    // comptime {
    //     let q = if SERIALIZED_OBSTACLE_BYTE_SIZE == 3 {
    //         quote {
                assert(SERIALIZED_OBSTACLE_BYTE_SIZE == 3, f"Obstacle byte size is not 3");
                let y = f[1] & 0x0F;
                let obstacle_type = (f[1]) / 0x10;
    //         }
    //     } else if SERIALIZED_OBSTACLE_BYTE_SIZE == 4 {
    //         quote {
    //             assert(SERIALIZED_OBSTACLE_BYTE_SIZE == 4, f"Obstacle byte size is not 4");
    //             y = f[1];
    //             obstacle_type = f[3];
    //         }
    //     } else {
    //         quote {
    //             assert((SERIALIZED_OBSTACLE_BYTE_SIZE == 3) | (SERIALIZED_OBSTACLE_BYTE_SIZE == 4), f"Invalid obstacle byte size {SERIALIZED_OBSTACLE_BYTE_SIZE}");
    //         }
    //     };
    //     q
    // }
    // let y = f[1]; // & 0x0F;
    // let obstacle_type = f[3]; //f[1] / 0x10;// (f[1] & 0xF0) / 0x10;
    let mut health = f[2];
    //if (obstacle_type == WALL) | (obstacle_type == WATER) {
        let mut damage = 0;
        for i in 0..MAX_EVENTS {
            damage += events[i].get_applied_damage_to_my_asset(x, y, obstacle_type);
        }
        if damage > (health as u16) {
            health = 0;
        } else {
            health -= (damage as u8);
        }
    //}
    new_obstacle(id, x, y, health, obstacle_type)
    // let o = Obstacle {
    //     id: id, // + (MAX_CHARACTERS as u8),
    //     x: x,
    //     y: y,
    //     health: health,
    //     obstacle_type: obstacle_type,
    //     //was_alive: was_alive,
    // };
    // assert(o.is_valid());
    // o
}

pub fn is_obstacle_valid(obstacle: Obstacle) -> bool {
    (get_obstacle_x(obstacle) < WIDTH) & (get_obstacle_y(obstacle) < HEIGHT)
}

#[export]
pub fn parse_their_obstacles(serialized_obstacles: SerializedArenaEnemyObstacles) -> (bool, [Obstacle; MAX_ENEMY_OBSTACLES]) {
  let (dummy_obstacle_valid, dummy_obstacle) = new_obstacle(0, NOWHERE, NOWHERE, 255, 0);
  assert(dummy_obstacle_valid);
    let mut obstacles: [Obstacle; MAX_ENEMY_OBSTACLES] = [dummy_obstacle; MAX_ENEMY_OBSTACLES];
    let mut valid_result = true;
    assert(serialized_obstacles.len() == SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE);
    for i in 0..SERIALIZED_OBSTACLES_ARRAY_SIZE {
        let serialized_obstacle_field: [u8; 32] = serialized_obstacles[i].to_be_bytes::<32>();
        assert(serialized_obstacle_field.len() == 32);
        for j in 0..SERIALIZED_OBSTACLES_PER_FIELD {
            let serialized_obstacle = [serialized_obstacle_field[2 + j * 3], serialized_obstacle_field[2 + j * 3 + 1], serialized_obstacle_field[2 + j * 3 + 2]];
            // let serialized_obstacle = [serialized_obstacle_field[2 + j * 3], serialized_obstacle_field[2 + j * 3 + 1], serialized_obstacle_field[2 + j * 3 + 2], serialized_obstacle_field[2 + j * 3 + 2]];
            let id = (i * SERIALIZED_OBSTACLES_PER_FIELD + j) as u8;
            let (valid, obstacle) = parse_their_obstacle(id, serialized_obstacle);
            obstacles[i * SERIALIZED_OBSTACLES_PER_FIELD + j] = obstacle; //s.push_back(obstacle);
            valid_result = valid_result & valid;
        }
    }
    let serialized_obstacle_field = serialized_obstacles[SERIALIZED_OBSTACLES_ARRAY_SIZE].to_be_bytes::<32>();
    assert(serialized_obstacle_field.len() == 32);
    for j in 0..MAX_CHARACTERS {
      let serialized_obstacle = [serialized_obstacle_field[2 + j * 3], serialized_obstacle_field[2 + j * 3 + 1], serialized_obstacle_field[2 + j * 3 + 2]];
      // let serialized_obstacle = [serialized_obstacle_field[2 + j * 3], serialized_obstacle_field[2 + j * 3 + 1], serialized_obstacle_field[2 + j * 3 + 2], serialized_obstacle_field[2 + j * 3 + 2]];
      let id = (MAX_OBSTACLES + j) as u8;
      let (valid, obstacle) = parse_their_obstacle(id, serialized_obstacle);
      obstacles[MAX_OBSTACLES + j] = obstacle; //s.push_back(obstacle);
      valid_result = valid_result & valid;
    }
    (valid_result, obstacles)
}

pub fn parse_my_obstacles(serialized_obstacles: SerializedArenaObstacles, events: [Event; MAX_EVENTS]) -> (bool, [Obstacle; MAX_OBSTACLES]) {
    let mut obstacles: [Obstacle] = &[];
    let mut valid_result = true;
    assert(serialized_obstacles.len() == SERIALIZED_OBSTACLES_ARRAY_SIZE);
    for i in 0..serialized_obstacles.len() {
        let serialized_obstacle_field: [u8; 32] = serialized_obstacles[i].to_be_bytes::<32>();
        assert(serialized_obstacle_field.len() == 32);
        for j in 0..SERIALIZED_OBSTACLES_PER_FIELD {
            let serialized_obstacle = [serialized_obstacle_field[2 + j * 3], serialized_obstacle_field[2 + j * 3 + 1], serialized_obstacle_field[2 + j * 3 + 2]];
            //let serialized_obstacle = [serialized_obstacle_field[2 + j * 3], serialized_obstacle_field[2 + j * 3 + 1], serialized_obstacle_field[2 + j * 3 + 2], serialized_obstacle_field[2 + j * 3 + 2]];
            let id = (i * SERIALIZED_OBSTACLES_PER_FIELD + j) as u8;
            let (valid, obstacle) = parse_obstacle(id, serialized_obstacle, events);
            obstacles = obstacles.push_back(obstacle);
            valid_result = valid_result & valid;
        }
    }
    (valid_result, obstacles.as_array())
}

#[export]
pub fn serialize_my_obstacles_for_me(obstacles: [Obstacle; MAX_OBSTACLES]) -> pub [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE] {
    let mut serialized_obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE] = [0; SERIALIZED_OBSTACLES_ARRAY_SIZE];
    for i in 0..SERIALIZED_OBSTACLES_ARRAY_SIZE {
        let mut serialized_obstacle_field: [u8; 32] = [0; 32];
        for j in 0..SERIALIZED_OBSTACLES_PER_FIELD {
            let obstacle = obstacles[i * SERIALIZED_OBSTACLES_PER_FIELD + j];
            let serialized_obstacle = serialize_obstacle(obstacle);
            for k in 0..3 {
                serialized_obstacle_field[2 + j * 3 + k] = serialized_obstacle[k];
            }
        }
        serialized_obstacles[i] = std::field::bytes32_to_field(serialized_obstacle_field);
    }
    serialized_obstacles
}

pub fn serialize_my_obstacles(enemy_advance: u8, obstacles: [Obstacle; MAX_OBSTACLES]) -> [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE] {
  let enemy_advance = if enemy_advance >= WIDTH { 0 } else { WIDTH - enemy_advance - 1 };
    let mut serialized_obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE] = [0; SERIALIZED_OBSTACLES_ARRAY_SIZE];
    for i in 0..SERIALIZED_OBSTACLES_ARRAY_SIZE {
        let mut serialized_obstacle_field: [u8; 32] = [0; 32];
        for j in 0..SERIALIZED_OBSTACLES_PER_FIELD {
            let obstacle = obstacles[i * SERIALIZED_OBSTACLES_PER_FIELD + j];
            if is_visible(enemy_advance, get_obstacle_x(obstacle)) {
                let serialized_obstacle = serialize_obstacle(obstacle);
                for k in 0..3 {
                    serialized_obstacle_field[2 + j * 3 + k] = serialized_obstacle[k];
                }
            }
        }
        serialized_obstacles[i] = std::field::bytes32_to_field(serialized_obstacle_field);
    }
    serialized_obstacles
}
pub fn serialize_their_obstacles(enemy_advance: u8, obstacles: [Obstacle; MAX_OBSTACLES]) -> (bool, [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE]) {
    let mut valid_result = true;
    let enemy_advance = if enemy_advance >= WIDTH { 0 } else { WIDTH - enemy_advance - 1 };
    let mut serialized_obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE] = [0; SERIALIZED_OBSTACLES_ARRAY_SIZE];
    for i in 0..SERIALIZED_OBSTACLES_ARRAY_SIZE {
        let mut serialized_obstacle_field: [u8; 32] = [0; 32];
        for j in 0..SERIALIZED_OBSTACLES_PER_FIELD {
            let obstacle = obstacles[i * SERIALIZED_OBSTACLES_PER_FIELD + j];
            if is_visible(enemy_advance, get_obstacle_x(obstacle)) {
                let parsed_x = their_x_to_mine(get_obstacle_x(obstacle));
                valid_result = valid_result & parsed_x.0;
                let mirrored_obstacle = new_obstacle(
                    get_obstacle_id(obstacle),
                    parsed_x.1,
                    get_obstacle_y(obstacle),
                    get_obstacle_health(obstacle),
                    get_obstacle_type(obstacle)
                );
                valid_result = valid_result & mirrored_obstacle.0;
                let serialized_obstacle = serialize_obstacle(mirrored_obstacle.1);
                for k in 0..3 {
                    serialized_obstacle_field[2 + j * 3 + k] = serialized_obstacle[k];
                }
            }
        }
        serialized_obstacles[i] = std::field::bytes32_to_field(serialized_obstacle_field);
    }
    (valid_result, serialized_obstacles)
}

fn get_x_of_side(side: u1, x: u8) -> u8 {
    x * ((side as u8 + 1) as u1) as u8 + side as u8 * (WIDTH - 1 - x)
}

#[test]
fn test_x() {
    let x8s0 = get_x_of_side(0, 8);
    assert(x8s0 == 8, f"{x8s0} != 8");
    let x8s1 = get_x_of_side(1, 8);
    assert(x8s1 == 23, f"{x8s1} != 23");
}

pub fn get_default_obstacles(side: u1) -> [Obstacle; MAX_OBSTACLES] {
    // assert(side < 2, f"Side is too large {side}");
    let x = |x| get_x_of_side(side, x); //(((side as u8) + 1) % 2) + (WIDTH - 1 - x) * (side as u8);
    [
        new_obstacle( 0, x(0), 2, 200, WALL).1,
        new_obstacle( 1, x(1), 2, 200, WALL).1,
        new_obstacle( 2, x(3), 2, 200, WALL).1,
        new_obstacle( 3, x(4), 2, 200, WALL).1,
        new_obstacle( 4, x(5), 3, 200, WALL).1,
        new_obstacle( 5, x(5), 4, 200, WALL).1,
        new_obstacle( 6, x(5), 5, 200, WALL).1,
        new_obstacle( 7, x(5), 7, 200, WALL).1,
        new_obstacle( 8, x(4), 7, 200, WALL).1,
        new_obstacle( 9, x(3), 7, 200, WALL).1,
        new_obstacle(10, x(1), 7, 200, WALL).1,
        new_obstacle(11, x(0), 7, 200, WALL).1,
        new_obstacle(12, x(7), 0, 200, WALL).1,
        new_obstacle(13, x(7), 1, 200, WALL).1,
        new_obstacle(14, x(7), 2, 200, WALL).1,
        new_obstacle(15, x(7), 3, 200, WALL).1,
        new_obstacle(16, x(7), 4, 200, WALL).1,
        new_obstacle(17, x(7), 5, 200, WALL).1,
        new_obstacle(18, x(6), 8, 255, WATER).1,
        new_obstacle(19, x(7), 8, 255, WATER).1,
        new_obstacle(20, x(5), 9, 255, WATER).1,
        new_obstacle(21, x(6), 9, 255, WATER).1,
        new_obstacle(22, x(7), 9, 255, WATER).1,
        new_obstacle(23, x(8), 9, 255, WATER).1,
        // new_obstacle(24, x(0), 0, 255, EMPTY).1,
        // new_obstacle(25, x(0), 0, 255, EMPTY).1,
        // new_obstacle(26, x(0), 0, 255, EMPTY).1,
        // new_obstacle(27, x(0), 0, 255, EMPTY).1,
        // new_obstacle(28, x(0), 0, 255, EMPTY).1,
        // new_obstacle(29, x(0), 0, 255, EMPTY).1,
        // new_obstacle(30, x(0), 0, 255, EMPTY).1,
        // new_obstacle(31, x(0), 0, 255, EMPTY).1,
    ]
}
