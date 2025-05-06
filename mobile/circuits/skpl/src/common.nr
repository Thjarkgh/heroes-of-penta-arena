// use skpla::{ActionDefinitionBuilder, ActionSerDe};
// use crate::{MAX_ACTIONS, MAX_ACTIONS_PER_CHARACTER, WIDTH, HEIGHT, WAIT};
// use crate::{MIN_PROGRESS, MAX_PROGRESS, ACTION_RESULT_COORDINATES_IDX_SELF, ACTION_RESULT_COORDINATES_IDX_TARGET, ACTION_RESULT_COORDINATES_IDX_INVISIBLE};
// use crate::{NO_EVENT, RECEIVE_ATTACK, SEE_CAST, SEE_DRAW, SEE_MOVE, SEE_RITUAL, SEE_SEARCH_TRAP, DISARMED_TRAP, ADD_OBSTACLE, WIN};

// // pub comptime fn assert_ct(condition: bool, message: CtString) {
// //   if !condition {
// //     CtString()
// //     panic(CtString("Comptime assertion failed: ")message);
// //   }
// // }

// pub fn get_arena_action_serde() -> ActionSerDe {
//   ActionSerDe::new(MAX_ACTIONS, MAX_ACTIONS_PER_CHARACTER as u8, WIDTH, HEIGHT, WAIT)
// }

// pub fn get_arena_action_def_builder() -> ActionDefinitionBuilder{
//   ActionDefinitionBuilder::new(
//     WAIT,
//     MIN_PROGRESS,
//     MAX_PROGRESS,
//     ACTION_RESULT_COORDINATES_IDX_SELF,
//     ACTION_RESULT_COORDINATES_IDX_TARGET,
//     ACTION_RESULT_COORDINATES_IDX_INVISIBLE,
//     NO_EVENT,
//     RECEIVE_ATTACK,
//     SEE_CAST,
//     SEE_DRAW,
//     SEE_MOVE,
//     SEE_RITUAL,
//     SEE_SEARCH_TRAP,
//     DISARMED_TRAP,
//     ADD_OBSTACLE,
//     WIN
//   )
// }