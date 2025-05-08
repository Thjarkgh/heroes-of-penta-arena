use arenalib::{ WIDTH, HEIGHT, WIDTH_MASK, VIEW_DISTANCE, MAX_OBSTACLES, MAX_ENEMY_OBSTACLES };
use crate::obstacle::{ Obstacle, get_obstacle_y, get_obstacle_x, is_obstacle_traversible };
use skplg::NOWHERE;
use std::collections::bounded_vec;

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

global MAX_DISTANCE: u32 = 0xff * 0xff;
pub type DISTANCE = u16;
fn get_distance_part(curr: u8, target: u8) -> DISTANCE_PART_ROLLED_OUT {
  let d = if curr > target { curr - target } else { target - curr } as u32;
  d * d
}
pub fn get_distance(curr_x: u8, curr_y: u8, x: u8, y: u8) -> DISTANCE {
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

    let dx = get_distance_part(curr_x, x);
    let dy = get_distance_part(curr_y, y);

    // let dx = curr_x as i16 - x as i16;
    // let dy = curr_y as i16 - y as i16;
  get_distance_from_parts(dx, dy)
}
// NOTE: Leaving it for now, but no actual performance benefit from splitting this
pub type DISTANCE_PART_ROLLED_OUT = u32;
fn get_distance_from_parts(x: DISTANCE_PART_ROLLED_OUT, y: DISTANCE_PART_ROLLED_OUT) -> DISTANCE {
  let distance = x + y;
  if distance > MAX_DISTANCE {
    MAX_DISTANCE as u16
  } else {
    distance as u16
  }
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

pub fn is_distance_within_viewing_range(distance: u16) -> bool {
  distance <= (VIEW_DISTANCE as u16 * VIEW_DISTANCE as u16)
}

pub fn is_tile_free_or_invisible(x: u8, y: u8, obstacles: [Obstacle; MAX_ENEMY_OBSTACLES], their_obstacles: [Obstacle; MAX_ENEMY_OBSTACLES]) -> bool {
  let mut can = true;
  for i in 0..MAX_OBSTACLES {
      if !is_obstacle_traversible(obstacles[i]) & (get_obstacle_x(obstacles[i]) == x) & (get_obstacle_y(obstacles[i]) == y) {
          can = false;
      }
  }
  for i in 0..MAX_ENEMY_OBSTACLES {
      if !is_obstacle_traversible(their_obstacles[i]) & (get_obstacle_x(their_obstacles[i]) == x) & (get_obstacle_y(their_obstacles[i]) == y) {
          can = false;
      }
  }
  can
}

global W: u32 = WIDTH as u32;
global H: u32 = HEIGHT as u32;
unconstrained fn _get_free_map(obstacles: [Obstacle; MAX_ENEMY_OBSTACLES], their_obstacles: [Obstacle; MAX_ENEMY_OBSTACLES]) -> [[u8; H]; W] {
  let mut map = [[0; H]; W];
  for i in 0..MAX_ENEMY_OBSTACLES {
    let obstacle = obstacles[i];
    let x = get_obstacle_x(obstacle);
    let y = get_obstacle_y(obstacle);
    if (x != NOWHERE) & (y != NOWHERE) {
      assert(x < WIDTH);
      assert(y < HEIGHT);
      if !is_obstacle_traversible(obstacle) {//} & (get_obstacle_x(obstacles[i]) == x) & (get_obstacle_y(obstacles[i]) == y) {
        map[x][y] += 1;
      }
    }
  }
  for i in 0..MAX_ENEMY_OBSTACLES {
    let obstacle = their_obstacles[i];
    let x = get_obstacle_x(obstacle);
    let y = get_obstacle_y(obstacle);
    if (x != NOWHERE) & (y != NOWHERE) {
      assert(x < WIDTH);
      assert(y < HEIGHT);
      if !is_obstacle_traversible(obstacle) {//} & (get_obstacle_x(obstacles[i]) == x) & (get_obstacle_y(obstacles[i]) == y) {
        map[x][y] += 1;
      }
    }
  }
  map
}

unconstrained fn _to_obstacle_collision_array(obstacles: [Obstacle; MAX_ENEMY_OBSTACLES], their_obstacles: [Obstacle; MAX_ENEMY_OBSTACLES]) -> [(u8, u8, bool); MAX_ENEMY_OBSTACLES * 2] {
  let mut o = [(NOWHERE, NOWHERE, true); 58];

  for i in 0..MAX_ENEMY_OBSTACLES {
    let obstacle = obstacles[i];
    let x = get_obstacle_x(obstacle);
    let y = get_obstacle_y(obstacle);

    o[i] = (x,y,is_obstacle_traversible(obstacle));

    // if (x != NOWHERE) & (y != NOWHERE) {
    //   assert(x < WIDTH);
    //   assert(y < HEIGHT);
    //   if !is_obstacle_traversible(obstacle) {//} & (get_obstacle_x(obstacles[i]) == x) & (get_obstacle_y(obstacles[i]) == y) {
    //     o.push((x,y));
    //   }
    // }
  }
  for i in 0..MAX_ENEMY_OBSTACLES {
    let obstacle = their_obstacles[i];
    let x = get_obstacle_x(obstacle);
    let y = get_obstacle_y(obstacle);

    o[i + MAX_ENEMY_OBSTACLES] = (x,y,is_obstacle_traversible(obstacle));
    // if (x != NOWHERE) & (y != NOWHERE) {
    //   assert(x < WIDTH);
    //   assert(y < HEIGHT);
    //   if !is_obstacle_traversible(obstacle) {//} & (get_obstacle_x(obstacles[i]) == x) & (get_obstacle_y(obstacles[i]) == y) {
    //     o.push((x,y));
    //   }
    // }
  }
  o
}

pub fn get_free_map(obstacles: [Obstacle; MAX_ENEMY_OBSTACLES], their_obstacles: [Obstacle; MAX_ENEMY_OBSTACLES]) -> [[u8; H]; W] { // missing own chars
  // Safety: verifying all map elements afterwards
  let map = unsafe { _get_free_map(obstacles, their_obstacles) };
  
  // Safety: verifying all below
  //let o = unsafe { _to_obstacle_collision_array(obstacles, their_obstacles) };
   //let mut o = [(NOWHERE, NOWHERE, true); 58];

        for i in 0..MAX_ENEMY_OBSTACLES {
          let obstacle = obstacles[i];
          let x = get_obstacle_x(obstacle);
          let y = get_obstacle_y(obstacle);

          if !is_obstacle_traversible(obstacle) {
            assert(map[x][y] > 0);
          }
          //o[i] = (x,y,is_obstacle_traversible(obstacle));
          // assert(o[i].0 == x);
          // assert(o[i].1 == y);
          // assert(o[i].2 == is_obstacle_traversible(obstacle));

          // if (x != NOWHERE) & (y != NOWHERE) {
          //   assert(x < WIDTH);
          //   assert(y < HEIGHT);
          //   if !is_obstacle_traversible(obstacle) {//} & (get_obstacle_x(obstacles[i]) == x) & (get_obstacle_y(obstacles[i]) == y) {
          //     o.push((x,y));
          //   }
          // }
        }
        for i in 0..MAX_ENEMY_OBSTACLES {
          let obstacle = their_obstacles[i];
          let x = get_obstacle_x(obstacle);
          let y = get_obstacle_y(obstacle);
 if !is_obstacle_traversible(obstacle) {
            assert(map[x][y] > 0);
          }
          //  o[i + MAX_ENEMY_OBSTACLES] = (x,y,is_obstacle_traversible(obstacle));

          // assert(o[i + MAX_ENEMY_OBSTACLES].0 == x);
          // assert(o[i + MAX_ENEMY_OBSTACLES].1 == y);
          // assert(o[i + MAX_ENEMY_OBSTACLES].2 == is_obstacle_traversible(obstacle));
          // if (x != NOWHERE) & (y != NOWHERE) {
          //   assert(x < WIDTH);
          //   assert(y < HEIGHT);
          //   if !is_obstacle_traversible(obstacle) {//} & (get_obstacle_x(obstacles[i]) == x) & (get_obstacle_y(obstacles[i]) == y) {
          //     o.push((x,y));
          //   }
          // }
        }
        let mut sum: u32 = 0;
  for x in 0..WIDTH {
    for y in 0..HEIGHT {
      sum += map[x][y] as u32;
      // let val = map[x][y];
      // if !val {
      //   let mut found_obstacle = false;

      //   for i in 0..58 {
      //     if (x == o[i].0) & (y == o[i].1) & o[i].2 {
      //       found_obstacle = true;
      //     }
      //   }

      //   assert(found_obstacle);
      // }
    }
  }
  let mut obstacle_sum: u32 = 0;
  for i in 0..MAX_ENEMY_OBSTACLES {
    obstacle_sum += (!is_obstacle_traversible(obstacles[i])) as u32 + (!is_obstacle_traversible(their_obstacles[i])) as u32;
  }
  assert(sum == obstacle_sum);

  map
}

pub fn can_move_to(distance: u16, x: u8, y: u8, obstacles: [Obstacle; MAX_ENEMY_OBSTACLES], their_obstacles: [Obstacle; MAX_ENEMY_OBSTACLES]) -> bool {
    let mut can = is_distance_within_viewing_range(distance); //x <= advance;
    can &= is_tile_free_or_invisible(x, y, obstacles, their_obstacles);

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