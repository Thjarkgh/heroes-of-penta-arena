use arenalib::{ WIDTH, WIDTH_MASK, VIEW_DISTANCE, MAX_OBSTACLES };
use crate::obstacle::{ Obstacle, get_obstacle_y, get_obstacle_x, is_obstacle_traversible };
use skplg::NOWHERE;

// pub fn is_neighbor(curr_x: u8, curr_y: u8, x: u8, y: u8) -> bool {
//     // assert(curr_x < WIDTH);
//     // assert(curr_y < HEIGHT);
//     // assert(x < WIDTH);
//     // assert(y < HEIGHT);
//     // validating coordinates is not the job of this function
//     // only avoid overflows!


//     let shifted_curr_x = std::wrapping_add(curr_x, 1);
//     let shifted_curr_y = std::wrapping_add(curr_y, 1);
//     let shifted_x = std::wrapping_add(x, 1);
//     let shifted_y = std::wrapping_add(y, 1);

//     ((shifted_curr_x == shifted_x) & (std::wrapping_add(shifted_curr_y, 1) >= shifted_y) & (shifted_curr_y <= std::wrapping_add(shifted_y, 1))) |
//     ((shifted_curr_y == shifted_y) & (std::wrapping_add(shifted_curr_x, 1) >= shifted_x) & (shifted_curr_x <= std::wrapping_add(shifted_x, 1)))
// }

// global DISTANCE_TABLE_HEIGHT: u32 = HEIGHT as u32;
// global DISTANCE_TABLE_WIDTH: u32 = WIDTH as u32;

// unconstrained fn distance_sqrt(x: u32) -> u32 {
//     let mut result: u32 = 0;
//     for i in 0..DISTANCE_TABLE_WIDTH {
//         if i * i == x {
//             result = i;
//             break;
//         }
//     }
//     result
// }

// fn d(a: u8, b: u8) -> u8 {
//     let d = a as i32 - b as i32;
//     let d2 = d * d;
//     assert(d2 >= 0);
//     let d2u = d2 as u32;
//     let result = unsafe {
//         let sq = distance_sqrt(d2u);
//         assert(sq * sq == d2u);
//         sq
//     };
//     assert(result < DISTANCE_TABLE_WIDTH);
//     comptime { assert(DISTANCE_TABLE_WIDTH <= 256) };
//     result as u8
// }
// global DISTANCE_TABLE: [[u8; DISTANCE_TABLE_WIDTH]; DISTANCE_TABLE_HEIGHT] = [
//     [ 0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 ],
//     [ 1,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 ],
//     [ 2,  2,  3,  4,  5,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30 ],
//     [ 3,  3,  3,  4,  4,  5,  6,  7,  8,  9 ,10 ,11 ,12 ,13 ,14 ,15 ,16 ,17 ,18 ,19 ,20 ,21 ,22 ,23 ,24 ,25 ,26 ,27 ,28 ,29 ],
// ]

pub fn get_distance(curr_x: u8, curr_y: u8, x: u8, y: u8) -> u16 {
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


pub fn is_visible(enemy_advance: u8, x: u8) -> bool {
    //(x >= enemy_advance) == (side == 0)
    x >= enemy_advance
}

// TODO: This is for the future - fireballs, etc. only if we have line of sight
// pub fn is_visible(curr_x: u8, curr_y: u8, x: u8, y: u8, map: &Map) -> bool {
//     assert(curr_x < WIDTH);
//     assert(curr_y < HEIGHT);
//     assert(x < WIDTH);
//     assert(y < HEIGHT);

//     let mut x = curr_x as f32;
//     let mut y = curr_y as f32;
//     let x2 = x + 0.5;
//     let y2 = y + 0.5;
//     let dx = x2 - x;
//     let dy = y2 - y;
//     let mut t = 0.0;
//     let mut max_t = 1.0;
//     let mut x = x;
//     let mut y = y;

//     while t < max_t {
//         let x = x + dx * t;
//         let y = y + dy * t;
//         let x = x as u8;
//         let y = y as u8;

//         if map.is_wall(x, y) {
//             return false;
//         }

//         t += 0.1;
//     }

//     true
// }

pub fn their_x_to_mine(x: u8) -> (bool, u8) {
    if x == NOWHERE {
        (true, NOWHERE)
    } else {
        (x < WIDTH, std::wrapping_sub(WIDTH - 1, x) & WIDTH_MASK)
    }
}

pub fn can_move_to(distance: u16, x: u8, y: u8, obstacles: [Obstacle; MAX_OBSTACLES], their_obstacles: [Obstacle]) -> bool {
    let mut can = distance <= (VIEW_DISTANCE as u16 * VIEW_DISTANCE as u16); //x <= advance;

    for i in 0..MAX_OBSTACLES {
        if !is_obstacle_traversible(obstacles[i]) & (get_obstacle_x(obstacles[i]) == x) & (get_obstacle_y(obstacles[i]) == y) {
            can = false;
        }
    }
    for i in 0..their_obstacles.len() {
        if !is_obstacle_traversible(their_obstacles[i]) & (get_obstacle_x(their_obstacles[i]) == x) & (get_obstacle_y(their_obstacles[i]) == y) {
            can = false;
        }
    }
    can
}
// pub fn their_x_to_mine(side: u1, x: i8) -> i8 {
//     let mul = side as i8;
//     mul * 31 + 16 + x
// }

// x * s -16 + y = 0 if s == 0 => y = 16
// x * s -16 + y = 31 if s == 1 => x = 31
// y = 31 * s + 16 + x
// s = 0:
// x = -16 => y = 0
// x = 15 => y = 31
// s = 1:
// x = -16 => y = 31
// x = 15 => y = 0

// pub fn serialize_x(x: i8) -> (bool, u8) {
//     let valid = (x >= -(WIDTH / 2) as i8) & (x < (WIDTH / 2) as i8);
//     (valid, (x + (WIDTH / 2) as i8) as u8)
// }

// pub fn deserialize_x(x: u8) -> (bool, i8) {
//     let valid = x < WIDTH;
//     (valid, x as i8 - (WIDTH / 2) as i8)
// }