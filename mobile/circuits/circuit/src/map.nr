// use crate::{ WIDTH, HEIGHT };

// pub fn is_neighbor(curr_x: u8, curr_y: u8, x: u8, y: u8) -> bool {
//     assert(curr_x < WIDTH);
//     assert(curr_y < HEIGHT);
//     assert(x < WIDTH);
//     assert(y < HEIGHT);

//     let shifted_curr_x = curr_x + 1;
//     let shifted_curr_y = curr_y + 1;
//     let shifted_x = x + 1;
//     let shifted_y = y + 1;

//     ((shifted_curr_x == shifted_x) & (shifted_curr_y + 1 >= shifted_y) & (shifted_curr_y <= shifted_y + 1)) |
//     ((shifted_curr_y == shifted_y) & (shifted_curr_x + 1 >= shifted_x) & (shifted_curr_x <= shifted_x + 1))
// }

// pub fn is_visible(side: u1, enemy_advance: u8, x: u8) -> bool {
//     (x >= enemy_advance) == (side == 0)
// }

// // TODO: This is for the future - fireballs, etc. only if we have line of sight
// // pub fn is_visible(curr_x: u8, curr_y: u8, x: u8, y: u8, map: &Map) -> bool {
// //     assert(curr_x < WIDTH);
// //     assert(curr_y < HEIGHT);
// //     assert(x < WIDTH);
// //     assert(y < HEIGHT);

// //     let mut x = curr_x as f32;
// //     let mut y = curr_y as f32;
// //     let x2 = x + 0.5;
// //     let y2 = y + 0.5;
// //     let dx = x2 - x;
// //     let dy = y2 - y;
// //     let mut t = 0.0;
// //     let mut max_t = 1.0;
// //     let mut x = x;
// //     let mut y = y;

// //     while t < max_t {
// //         let x = x + dx * t;
// //         let y = y + dy * t;
// //         let x = x as u8;
// //         let y = y as u8;

// //         if map.is_wall(x, y) {
// //             return false;
// //         }

// //         t += 0.1;
// //     }

// //     true
// // }