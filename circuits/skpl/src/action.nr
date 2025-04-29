// use crate::{ HEIGHT, WIDTH };
use crate::{ NO_EVENT, WAIT, SEE_MOVE };
use crate::{ MAX_ACTIONS, MAX_OBSTACLES };
use crate::{ SERIALIZED_ACTION_BYTE_SIZE, SERIALIZED_ACTIONS_ARRAY_SIZE, SERIALIZED_ACTIONS_PER_FIELD };
use crate::UNREADABLE_BYTES_PER_FIELD;
// use crate::NON_EMPTY_WALKABLE_TILE_MIN;
use crate::character::Character;
use crate::event::Event;
use crate::event::{ build_subtype_value_event }; // , build_value_event
use crate::map::{ is_visible, get_distance, can_move_to };
use crate::obstacle::Obstacle;
use crate::obstacle::{ get_default_obstacles };
use crate::{MAGE};
use crate::{MAX_ACTIONS_PER_CHARACTER, MAX_STATUS, NOWHERE, VIEW_DISTANCE, softassert};
use crate::ResolvedAction::ResolvedAction;
use crate::actionDefinition::{ TestActionDefinition, ACTION_RESULT_COORDINATES_IDX_INVISIBLE, build_test_action_def, build_move_action };

// pub struct Action {
//     pub action: u8,
//     pub actor: u8,
//     pub target_x: u8,
//     pub target_y: u8,
// }

pub type Action = [u8; 4];

global ACTION_TYPE: u8 = 0;
global ACTION_ACTOR: u8 = 1;
global ACTION_TARGET_X: u8 = 2;
global ACTION_TARGET_Y: u8 = 3;

pub fn get_action_type(action: Action) -> u8 {
    action[ACTION_TYPE]
}
pub fn get_action_actor(action: Action) -> u8 {
    action[ACTION_ACTOR]
}
pub fn get_action_target_x(action: Action) -> u8 {
    action[ACTION_TARGET_X]
}
pub fn get_action_target_y(action: Action) -> u8 {
    action[ACTION_TARGET_Y]
}
pub fn new_action(action_type: u8, actor: u8, target_x: u8, target_y: u8) -> Action {
    let mut action: Action = [0; 4];
    action[ACTION_TYPE] = action_type;
    action[ACTION_ACTOR] = actor;
    action[ACTION_TARGET_X] = target_x;
    action[ACTION_TARGET_Y] = target_y;
    action
}


// pub global ACTION_NEEDS_TARGET_FREE_SPACE: u16 = 0;  // u1
// pub global ACTION_NEEDS_TARGET_IS_NOT_SELF: u16 = 1; // u1
// pub global ACTION_NEEDS_STATUS_VISIBLE: u16 = 2; // u1
// pub global ACTION_NEEDS_STATUS_INVISIBLE: u16 = 3; // u1
// pub global ACTION_NEEDS_STATUS_HIDDEN: u16 = 4; // u1
// pub global ACTION_SETS_STATUS_HIDDEN: u16 = 5; // u1
// pub global ACTION_REMOVES_STATUS_HIDDEN: u16 = 6; // u1
// pub global ACTION_MAX_RANGE: u16 = 7; // u6 // TODO: max_range!
// pub global ACTION_NEEDS_MIN_STATUS: u16 = 8; // u4
// pub global ACTION_NEEDS_MAX_STATUS: u16 = 9; // u4
// pub global ACTION_NEEDED_ENERGY: u16 = 10;    // u4
// pub global ACTION_EVENT_IS_TRAP: u16 = 11; // u1
// global ACTION_REQUIREMENTS_FIELD_COUNT: u16 = 12;
// // ----------- 3 bytes ----------- 10 24bit
// comptime fn build_action_requirements_def(
//     action_needs_target_free_space: u8,
//     action_needs_target_is_not_self: u8,
//     action_needs_status_visible: u8,
//     action_needs_status_invisible: u8,
//     action_needs_status_hidden: u8,
//     action_sets_status_hidden: u8,
//     action_removes_status_hidden: u8,
//     action_max_range: u8,
//     action_needs_min_status: u8,
//     action_needs_max_status: u8,
//     action_needed_energy: u8,
//     action_event_is_trap: u8
// ) -> CtString {
//     assert(action_needs_target_free_space <= 1);
//     assert(action_needs_target_is_not_self <= 1);
//     assert(action_needs_status_visible <= 1);
//     assert(action_needs_status_invisible <= 1);
//     assert(action_needs_status_hidden <= 1);
//     assert(action_sets_status_hidden <= 1);
//     assert(action_removes_status_hidden <= 1);
//     assert(action_needs_min_status <= MAX_STATUS);
//     assert(action_needs_max_status <= MAX_STATUS);
//     assert((action_sets_status_hidden == 0) | (action_removes_status_hidden == 0));
//     assert(action_event_is_trap <= 1);
//     f"{action_needs_target_free_space} as u8,{action_needs_target_is_not_self} as u8,{action_needs_status_visible} as u8,{action_needs_status_invisible} as u8,{action_needs_status_hidden} as u8,{action_sets_status_hidden} as u8,{action_removes_status_hidden} as u8,{action_max_range} as u8,{action_needs_min_status} as u8,{action_needs_max_status} as u8,{action_needed_energy} as u8,{action_event_is_trap} as u8".as_ctstring()
// }

// pub global ACTION_RESULT_EVENT_SEEN_TYPE: u16 =                    ACTION_REQUIREMENTS_FIELD_COUNT;     // u8
// pub global ACTION_RESULT_EVENT_SEEN_SUBTYPE: u16 =                 ACTION_REQUIREMENTS_FIELD_COUNT + 1; // u8
// pub global ACTION_RESULT_EVENT_SEEN_VALUE_STATUS_MULTIPLIER: u16 = ACTION_REQUIREMENTS_FIELD_COUNT + 2; // u2
// pub global ACTION_RESULT_EVENT_SEEN_VALUE_FIXED_ADDITION: u16 =    ACTION_REQUIREMENTS_FIELD_COUNT + 3; // u4
// pub global ACTION_RESULT_EVENT_SEEN_COORD_IDX: u16 =               ACTION_REQUIREMENTS_FIELD_COUNT + 4; // u2
// pub global ACTION_RESULT_EVENT_SEEN_RADIUS: u16 =                  ACTION_REQUIREMENTS_FIELD_COUNT + 5; // u8
// global ACTION_RESULT_EVENT_FIELD_COUNT: u16 = 6; // u8
// // ----------- 3 bytes ----------- 5

// pub global ACTION_RESULT_EVENT_NOT_SEEN_TYPE: u16 =                    ACTION_REQUIREMENTS_FIELD_COUNT + ACTION_RESULT_EVENT_FIELD_COUNT;     // u8
// pub global ACTION_RESULT_EVENT_NOT_SEEN_SUBTYPE: u16 =                 ACTION_REQUIREMENTS_FIELD_COUNT + ACTION_RESULT_EVENT_FIELD_COUNT + 1; // u8
// pub global ACTION_RESULT_EVENT_NOT_SEEN_VALUE_STATUS_MULTIPLIER: u16 = ACTION_REQUIREMENTS_FIELD_COUNT + ACTION_RESULT_EVENT_FIELD_COUNT + 2; // u4
// pub global ACTION_RESULT_EVENT_NOT_SEEN_VALUE_FIXED_ADDITION: u16 =    ACTION_REQUIREMENTS_FIELD_COUNT + ACTION_RESULT_EVENT_FIELD_COUNT + 3; // u8
// pub global ACTION_RESULT_EVENT_NOT_SEEN_COORD_IDX: u16 =               ACTION_REQUIREMENTS_FIELD_COUNT + ACTION_RESULT_EVENT_FIELD_COUNT + 4; // u2
// pub global ACTION_RESULT_EVENT_NOT_SEEN_RADIUS: u16 =                  ACTION_REQUIREMENTS_FIELD_COUNT + ACTION_RESULT_EVENT_FIELD_COUNT + 5; // u8
// // ----------- 3 bytes ----------- 5
// comptime fn build_action_event_def(
//     event_type: u8,
//     event_subtype: u8,
//     event_value_status_multiplier: u8,
//     event_value_fixed_addition: u8,
//     event_coord_idx: u8,
//     event_radius: u8
// ) -> CtString {
//     assert(event_type < EVENT_COUNT);
//     assert(event_subtype as u32 < ACTION_COUNT);
//     assert(event_value_status_multiplier < (STATUS_COUNT / 2));
//     // assert(event_value_fixed_addition < MAX_STATUS);
//     assert(event_coord_idx < 4);
//     f"{event_type} as u8,{event_subtype} as u8,{event_value_status_multiplier} as u8,{event_value_fixed_addition} as u8,{event_coord_idx} as u8, {event_radius} as u8".as_ctstring()
// }

// pub global ACTION_RESULT_STATUS_MULTIPLIER: u16 =     ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT;     // u1
// pub global ACTION_RESULT_STATUS_FIXED_ADDITION: u16 = ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT + 1; // u4
// pub global ACTION_MOVE_TO_TARGET: u16 =               ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT + 2; // u1
// pub global ACTION_IS_CONTINUOUS: u16 =                ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT + 3; // u1
// pub global ACTION_NEEDS_PREVIOUS_ACTION: u16 =        ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT + 4; // u4
// // ----------- 2 bytes ----------- 4
// // => 2 Fields per Character
// // 8 * u1 + 8 * u4 + 5 * u8 = 8 + 32 + 40 = 80 => 10 bytes => 3 / Field => WAIT is static => 2 Fields per Character
// global ACTION_RESULT_COORDINATES_IDX_SELF: u8 = 0; // u2
// global ACTION_RESULT_COORDINATES_IDX_TARGET: u8 = 1; // u2
// global ACTION_RESULT_COORDINATES_IDX_INVISIBLE: u8 = 2; // u2
// comptime fn build_action_def(
//     requirements: CtString,
//     event_seen: CtString,
//     event_not_seen: CtString,
//     status_multiplier: u8,
//     status_fixed_addition: u8,
//     move_to_target: u8,
//     is_continuous: u8,
//     previous_action: u8
// ) -> CtString {
//     assert(status_multiplier < 16);
//     assert(status_fixed_addition < 16);
//     assert(move_to_target < 2);
//     assert(is_continuous < 2);
//     f"{requirements},{event_seen},{event_not_seen},{status_multiplier} as u8,{status_fixed_addition} as u8,{move_to_target} as u8,{is_continuous} as u8,{previous_action} as u8".as_ctstring()
// }
// comptime fn build_test_action_def(
//     def: CtString,
//     action_args: Quoted,
// ) -> Quoted {
//     let result: Quoted = f"TestActionDefinition {{ register: [{def}], action: new_action({action_args}) }}".quoted_contents();
//     result
// }
// pub comptime fn build_action_def_reg(
//     action_defs: [[CtString; MAX_ACTIONS_PER_CHARACTER - 1]; MAX_CHARACTERS]
// ) -> Quoted {
//     let elements: [CtString; MAX_CHARACTERS] = action_defs.map(|x|x.reduce(|acc, cur|f"{acc},{cur}".as_ctstring()));
//     let joined = elements.reduce(|acc,cur|f"{acc},{cur}".as_ctstring());
//     let wait_action = build_wait_action_def();
//     f"[{wait_action},{joined}]".quoted_contents()
// }

// global YES: u8 = 1;
// global NO: u8 = 0;
// global MIN_STATUS: u8 = 0;
// global MAX_STATUS: u8 = 15;

// pub global ACTION_DEFINITION_SIZE: u32 = (ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT + 5) as u32; // 2 bytes for move_to_target and status_multiplier
// pub global ACTION_DEFINITION_REGISTER_SIZE: u32 = ACTION_DEFINITION_SIZE * (1 + (MAX_ACTIONS_PER_CHARACTER - 1) * (CLASS_COUNT - 1));
// pub struct ActionDefinition {
//     base_index: u16,
//     action: Action,
//     register: [u8; ACTION_DEFINITION_REGISTER_SIZE]
// }

// impl ActionDefinition {
//     pub fn new(action: Action, register: [u8; ACTION_DEFINITION_REGISTER_SIZE]) -> ActionDefinition {
//         ActionDefinition {
//             base_index: get_action_base_index(get_action_actor(action), get_action_type(action)),
//             action: action,
//             register: register
//         }
//     }
// }

// // pub type ActionDefinitionRegister = 
// comptime fn no_requirements() -> CtString {
//     build_action_requirements_def(
//         NO,
//         NO, 
//         NO,
//         NO,
//         NO,
//         NO,
//         NO,
//         255 as u8,
//         MIN_STATUS,
//         MAX_STATUS,
//         0 as u8,
//         NO)
// }
// comptime fn no_event() -> CtString {
//     build_action_event_def(NO_EVENT, NO_EVENT, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_INVISIBLE, 0 as u8)
// }
// pub comptime fn build_wait_action_def() -> CtString {
//     build_action_def(
//         no_requirements(),
//         no_event(),
//         no_event(),
//         1 as u8,
//         0 as u8,
//         ACTION_RESULT_COORDINATES_IDX_SELF,
//         NO,
//         WAIT
//     )
// }
// // pub global WAIT_ACTION: ActionDefinition = comptime { let x = build_wait_action_def(); f"[{x}]".quoted_contents() };
// pub comptime fn build_sneak_action(energy: u8) -> CtString { build_action_def(
//     build_action_requirements_def(
//         YES,
//         NO,
//         NO,
//         YES,
//         NO,
//         YES,
//         NO,
//         1 as u8,
//         MIN_STATUS,
//         MAX_STATUS,
//         energy,
//         NO),
//     no_event(), // TODO: not sure if on-seen we should not send a move event instead - that way one could sneak and stay hidden, but not sneak while visible
//     no_event(),
//     0 as u8,
//     0 as u8,
//     ACTION_RESULT_COORDINATES_IDX_TARGET,
//     NO,
//     WAIT)
// }
// pub comptime fn build_move_action(energy: u8) -> CtString { build_action_def(
//     build_action_requirements_def(
//         YES,
//         YES,
//         NO,
//         NO,
//         NO,
//         NO,
//         YES,
//         1 as u8,
//         MIN_STATUS,
//         MAX_STATUS,
//         energy,
//         NO),
//     build_action_event_def(SEE_MOVE, NO, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
//     no_event(),
//     0 as u8,
//     0 as u8,
//     ACTION_RESULT_COORDINATES_IDX_TARGET,
//     NO,
//     WAIT)
// }
// pub comptime fn build_cast_action(this_action_id: u8, energy: u8, class: u8) -> CtString { build_action_def(
//     build_action_requirements_def(
//         NO,
//         NO,
//         NO,
//         NO,
//         NO,
//         NO,
//         YES,
//         255 as u8,
//         MIN_STATUS,
//         MAX_STATUS,
//         energy,
//         NO),
//     build_action_event_def(SEE_CAST, class, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_SELF, 0 as u8),
//     no_event(),
//     1 as u8,
//     1 as u8,
//     ACTION_RESULT_COORDINATES_IDX_SELF,
//     YES,
//     this_action_id)
// }
// pub comptime fn build_ritual_action(this_action_id: u8, energy: u8) -> CtString { build_action_def(
//     build_action_requirements_def(
//         NO,
//         NO,
//         NO,
//         NO,
//         NO,
//         NO,
//         YES,
//         255 as u8,
//         RITUAL_ROUNDS_FOR_WIN,
//         MAX_STATUS,
//         energy,
//         NO),
//     build_action_event_def(WIN, WIN_BY_RITUAL, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_SELF, 255 as u8),
//     build_action_event_def(WIN, WIN_BY_RITUAL, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_INVISIBLE, 255 as u8),
//     0 as u8,
//     0 as u8,
//     ACTION_RESULT_COORDINATES_IDX_SELF,
//     YES,
//     this_action_id)
// }
// pub comptime fn build_evocation_action(cast_action_id: u8, energy: u8, evocation_type: u8, range: u8, radius: u8, damage: u8, damage_upcast: u8, min_cast_time: u8, max_cast_time: u8) -> CtString { build_action_def(
//     build_action_requirements_def(
//         NO,
//         NO,
//         NO,
//         NO,
//         NO,
//         NO,
//         YES,
//         range,
//         min_cast_time,
//         max_cast_time,
//         energy,
//         NO), // TODO: Maybe set this to handle friendly fire???
//     build_action_event_def(RECEIVE_ATTACK, evocation_type, damage_upcast, damage, ACTION_RESULT_COORDINATES_IDX_TARGET, radius),
//     build_action_event_def(RECEIVE_ATTACK, evocation_type, damage_upcast, damage, ACTION_RESULT_COORDINATES_IDX_TARGET, radius),
//     0 as u8,
//     0 as u8,
//     ACTION_RESULT_COORDINATES_IDX_SELF,
//     YES,
//     cast_action_id)
// }
// pub comptime fn build_search_action(energy: u8, range: u8) -> CtString { build_action_def(
//     build_action_requirements_def(
//         NO,
//         NO,
//         NO,
//         NO,
//         NO,
//         NO,
//         NO,
//         range,
//         MIN_STATUS,
//         MAX_STATUS,
//         energy,
//         NO),
//     build_action_event_def(SEE_SEARCH_TRAP, NO, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_TARGET, 1 as u8),
//     build_action_event_def(SEE_SEARCH_TRAP, NO, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_TARGET, 1 as u8),
//     0 as u8,
//     0 as u8,
//     ACTION_RESULT_COORDINATES_IDX_SELF,
//     NO,
//     WAIT)
// }
// pub comptime fn build_attack_action(energy: u8, damage_type: u8, range: u8, damage: u8) -> CtString { build_action_def(
//     build_action_requirements_def(
//         NO,
//         NO,
//         NO,
//         NO,
//         NO,
//         NO,
//         YES,
//         range,
//         MIN_STATUS,
//         MAX_STATUS,
//         energy,
//         NO),
//     build_action_event_def(RECEIVE_ATTACK, damage_type, 0 as u8, damage, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
//     build_action_event_def(RECEIVE_ATTACK, damage_type, 0 as u8, damage, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
//     0 as u8,
//     0 as u8,
//     ACTION_RESULT_COORDINATES_IDX_SELF,
//     NO,
//     WAIT)
// }
// pub comptime fn build_draw_action(this_action_id: u8, energy: u8, range: u8, class: u8) -> CtString { build_action_def(
//     build_action_requirements_def(
//         NO,
//         YES,
//         NO,
//         NO,
//         NO,
//         NO,
//         NO,
//         range,
//         MIN_STATUS,
//         MAX_STATUS,
//         energy,
//         NO),
//     build_action_event_def(SEE_DRAW, class, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_SELF, 0 as u8),
//     no_event(),
//     1 as u8,
//     1 as u8,
//     ACTION_RESULT_COORDINATES_IDX_SELF,
//     YES,
//     this_action_id)
// }
// pub comptime fn build_shoot_action(draw_action_id: u8, energy: u8, damage_type: u8, range: u8, damage: u8, damage_upcast: u8, min_cast_time: u8, max_cast_time: u8) -> CtString { build_action_def(
//     build_action_requirements_def(
//         NO,
//         YES,
//         NO,
//         NO,
//         NO,
//         NO,
//         YES,
//         range,
//         min_cast_time,
//         max_cast_time,
//         energy,
//         NO),
//     build_action_event_def(RECEIVE_ATTACK, damage_type, damage_upcast, damage, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
//     build_action_event_def(RECEIVE_ATTACK, damage_type, damage_upcast, damage, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
//     0 as u8,
//     0 as u8,
//     ACTION_RESULT_COORDINATES_IDX_SELF,
//     YES,
//     draw_action_id)
// }
// pub comptime fn build_disarm_trap_action(energy: u8, range: u8) -> CtString { build_action_def(
//     build_action_requirements_def(
//         NO,
//         YES,
//         NO,
//         NO,
//         NO,
//         NO,
//         NO,
//         range,
//         MIN_STATUS,
//         MAX_STATUS,
//         energy,
//         NO),
//     build_action_event_def(DISARMED_TRAP, NO, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
//     build_action_event_def(DISARMED_TRAP, NO, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
//     0 as u8,
//     0 as u8,
//     ACTION_RESULT_COORDINATES_IDX_SELF,
//     NO,
//     WAIT)
// }
// pub comptime fn build_set_trap_action(energy: u8, range: u8) -> CtString { build_action_def(
//     build_action_requirements_def(
//         YES,
//         NO,
//         NO,
//         YES,
//         NO,
//         NO,
//         NO,
//         range,
//         MIN_STATUS,
//         MAX_STATUS,
//         energy,
//         YES),
//     no_event(),
//     build_action_event_def(ADD_OBSTACLE, TRAP, 0 as u8, 50 as u8, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
//     0 as u8,
//     0 as u8,
//     ACTION_RESULT_COORDINATES_IDX_SELF,
//     NO,
//     WAIT)
// }

// pub fn get_action_base_index(actor_id: u8, action_idx: u8) -> u16 {
//     if (action_idx == 0) | (action_idx as u32 >= MAX_ACTIONS_PER_CHARACTER) | (actor_id as u32 >= MAX_CHARACTERS) {
//         0 as u16
//     } else {
//         (actor_id as u16 * (MAX_ACTIONS_PER_CHARACTER - 1) as u16 + action_idx as u16) * ACTION_DEFINITION_SIZE as u16
//     }
// }

// fn get_action_needs_target_free_space(action: ActionDefinition) -> bool {
//     action.register[action.base_index + ACTION_NEEDS_TARGET_FREE_SPACE] == 1
// }
// fn get_action_needs_target_is_not_self(action: ActionDefinition) -> bool {
//     action.register[action.base_index + ACTION_NEEDS_TARGET_IS_NOT_SELF] == 1
// }
// fn get_action_needs_status_visible(action: ActionDefinition) -> bool {
//     action.register[action.base_index + ACTION_NEEDS_STATUS_VISIBLE] == 1
// }
// fn get_action_needs_status_invisible(action: ActionDefinition) -> bool {
//     action.register[action.base_index + ACTION_NEEDS_STATUS_INVISIBLE] == 1
// }
// fn get_action_needs_status_hidden(action: ActionDefinition) -> bool {
//     action.register[action.base_index + ACTION_NEEDS_STATUS_HIDDEN] == 1
// }
// fn get_action_sets_status_hidden(action: ActionDefinition) -> bool {
//     action.register[action.base_index + ACTION_SETS_STATUS_HIDDEN] == 1
// }
// fn get_action_removes_status_hidden(action: ActionDefinition) -> bool {
//     action.register[action.base_index + ACTION_REMOVES_STATUS_HIDDEN] == 1
// }
// fn get_action_max_range(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_MAX_RANGE]
// }
// fn get_action_needs_min_status(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_NEEDS_MIN_STATUS]
// }
// fn get_action_needs_max_status(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_NEEDS_MAX_STATUS]
// }
// fn get_action_needed_energy(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_NEEDED_ENERGY]
// }
// fn get_action_unseen_event_is_internal(action: ActionDefinition) -> bool {
//     action.register[action.base_index + ACTION_EVENT_IS_TRAP] == 1
// }
// fn get_action_result_event_seen_type(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_RESULT_EVENT_SEEN_TYPE]
// }
// fn get_action_result_event_seen_subtype(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_RESULT_EVENT_SEEN_SUBTYPE]
// }
// fn get_action_result_event_seen_value_status_multiplier(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_RESULT_EVENT_SEEN_VALUE_STATUS_MULTIPLIER]
// }
// fn get_action_result_event_seen_value_fixed_addition(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_RESULT_EVENT_SEEN_VALUE_FIXED_ADDITION]
// }
// fn get_action_result_event_seen_coord_idx(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_RESULT_EVENT_SEEN_COORD_IDX]
// }
// fn get_action_result_event_seen_radius(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_RESULT_EVENT_SEEN_RADIUS]
// }
// fn get_action_result_event_not_seen_type(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_RESULT_EVENT_NOT_SEEN_TYPE]
// }
// fn get_action_result_event_not_seen_subtype(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_RESULT_EVENT_NOT_SEEN_SUBTYPE]
// }
// fn get_action_result_event_not_seen_value_status_multiplier(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_RESULT_EVENT_NOT_SEEN_VALUE_STATUS_MULTIPLIER]
// }
// fn get_action_result_event_not_seen_value_fixed_addition(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_RESULT_EVENT_NOT_SEEN_VALUE_FIXED_ADDITION]
// }
// fn get_action_result_event_not_seen_coord_idx(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_RESULT_EVENT_NOT_SEEN_COORD_IDX]
// }
// fn get_action_result_event_not_seen_radius(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_RESULT_EVENT_NOT_SEEN_RADIUS]
// }
// fn get_action_result_status_multiplier(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_RESULT_STATUS_MULTIPLIER]
// }
// fn get_action_result_status_fixed_addition(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_RESULT_STATUS_FIXED_ADDITION]
// }
// fn get_action_move_to_target(action: ActionDefinition) -> u1 {
//     action.register[action.base_index + ACTION_MOVE_TO_TARGET] as u1
// }
// fn get_action_is_continuous(action: ActionDefinition) -> bool {
//     action.register[action.base_index + ACTION_IS_CONTINUOUS] == 1
// }
// fn get_action_needs_previous_action(action: ActionDefinition) -> u8 {
//     action.register[action.base_index + ACTION_NEEDS_PREVIOUS_ACTION] as u8
// }

// pub trait ResolvedAction {
//     fn get_action_needs_target_free_space(self) -> bool;
//     fn get_action_needs_target_is_not_self(self) -> bool;
//     fn get_action_needs_status_visible(self) -> bool;
//     fn get_action_needs_status_invisible(self) -> bool;
//     fn get_action_needs_status_hidden(self) -> bool;
//     fn get_action_sets_status_hidden(self) -> bool;
//     fn get_action_removes_status_hidden(self) -> bool;
//     fn get_action_max_range(self) -> u8;
//     fn get_action_needs_min_status(self) -> u8;
//     fn get_action_needs_max_status(self) -> u8;
//     fn get_action_needed_energy(self) -> u8;
//     fn get_action_unseen_event_is_internal(self) -> bool;
//     fn get_action_result_event_seen_type(self) -> u8;
//     fn get_action_result_event_seen_subtype(self) -> u8;
//     fn get_action_result_event_seen_value_status_multiplier(self) -> u8;
//     fn get_action_result_event_seen_value_fixed_addition(self) -> u8;
//     fn get_action_result_event_seen_coord_idx(self) -> u8;
//     fn get_action_result_event_seen_radius(self) -> u8;
//     fn get_action_result_event_not_seen_type(self) -> u8;
//     fn get_action_result_event_not_seen_subtype(self) -> u8;
//     fn get_action_result_event_not_seen_value_status_multiplier(self) -> u8;
//     fn get_action_result_event_not_seen_value_fixed_addition(self) -> u8;
//     fn get_action_result_event_not_seen_coord_idx(self) -> u8;
//     fn get_action_result_event_not_seen_radius(self) -> u8;
//     fn get_action_result_status_multiplier(self) -> u8;
//     fn get_action_result_status_fixed_addition(self) -> u8;
//     fn get_action_move_to_target(self) -> u1;
//     fn get_action_is_continuous(self) -> bool;
//     fn get_action_needs_previous_action(self) -> u8;

//     fn get_action_type(self) -> u8;
//     fn get_action_target_x(self) -> u8;
//     fn get_action_target_y(self) -> u8;
// }

// impl ResolvedAction for ActionDefinition {
//     fn get_action_needs_target_free_space(self: ActionDefinition) -> bool {
//         self.register[self.base_index + ACTION_NEEDS_TARGET_FREE_SPACE] == 1
//     }
//     fn get_action_needs_target_is_not_self(self: ActionDefinition) -> bool {
//         self.register[self.base_index + ACTION_NEEDS_TARGET_IS_NOT_SELF] == 1
//     }
//     fn get_action_needs_status_visible(self: ActionDefinition) -> bool {
//         self.register[self.base_index + ACTION_NEEDS_STATUS_VISIBLE] == 1
//     }
//     fn get_action_needs_status_invisible(self: ActionDefinition) -> bool {
//         self.register[self.base_index + ACTION_NEEDS_STATUS_INVISIBLE] == 1
//     }
//     fn get_action_needs_status_hidden(self: ActionDefinition) -> bool {
//         self.register[self.base_index + ACTION_NEEDS_STATUS_HIDDEN] == 1
//     }
//     fn get_action_sets_status_hidden(self: ActionDefinition) -> bool {
//         self.register[self.base_index + ACTION_SETS_STATUS_HIDDEN] == 1
//     }
//     fn get_action_removes_status_hidden(self: ActionDefinition) -> bool {
//         self.register[self.base_index + ACTION_REMOVES_STATUS_HIDDEN] == 1
//     }
//     fn get_action_max_range(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_MAX_RANGE]
//     }
//     fn get_action_needs_min_status(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_NEEDS_MIN_STATUS]
//     }
//     fn get_action_needs_max_status(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_NEEDS_MAX_STATUS]
//     }
//     fn get_action_needed_energy(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_NEEDED_ENERGY]
//     }
//     fn get_action_unseen_event_is_internal(self: ActionDefinition) -> bool {
//         self.register[self.base_index + ACTION_EVENT_IS_TRAP] == 1
//     }
//     fn get_action_result_event_seen_type(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_RESULT_EVENT_SEEN_TYPE]
//     }
//     fn get_action_result_event_seen_subtype(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_RESULT_EVENT_SEEN_SUBTYPE]
//     }
//     fn get_action_result_event_seen_value_status_multiplier(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_RESULT_EVENT_SEEN_VALUE_STATUS_MULTIPLIER]
//     }
//     fn get_action_result_event_seen_value_fixed_addition(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_RESULT_EVENT_SEEN_VALUE_FIXED_ADDITION]
//     }
//     fn get_action_result_event_seen_coord_idx(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_RESULT_EVENT_SEEN_COORD_IDX]
//     }
//     fn get_action_result_event_seen_radius(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_RESULT_EVENT_SEEN_RADIUS]
//     }
//     fn get_action_result_event_not_seen_type(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_RESULT_EVENT_NOT_SEEN_TYPE]
//     }
//     fn get_action_result_event_not_seen_subtype(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_RESULT_EVENT_NOT_SEEN_SUBTYPE]
//     }
//     fn get_action_result_event_not_seen_value_status_multiplier(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_RESULT_EVENT_NOT_SEEN_VALUE_STATUS_MULTIPLIER]
//     }
//     fn get_action_result_event_not_seen_value_fixed_addition(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_RESULT_EVENT_NOT_SEEN_VALUE_FIXED_ADDITION]
//     }
//     fn get_action_result_event_not_seen_coord_idx(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_RESULT_EVENT_NOT_SEEN_COORD_IDX]
//     }
//     fn get_action_result_event_not_seen_radius(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_RESULT_EVENT_NOT_SEEN_RADIUS]
//     }
//     fn get_action_result_status_multiplier(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_RESULT_STATUS_MULTIPLIER]
//     }
//     fn get_action_result_status_fixed_addition(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_RESULT_STATUS_FIXED_ADDITION]
//     }
//     fn get_action_move_to_target(self: ActionDefinition) -> u1 {
//         self.register[self.base_index + ACTION_MOVE_TO_TARGET] as u1
//     }
//     fn get_action_is_continuous(self: ActionDefinition) -> bool {
//         self.register[self.base_index + ACTION_IS_CONTINUOUS] == 1
//     }
//     fn get_action_needs_previous_action(self: ActionDefinition) -> u8 {
//         self.register[self.base_index + ACTION_NEEDS_PREVIOUS_ACTION]
//     }

//     fn get_action_target_x(self) -> u8 {
//         get_action_target_x(self.action)
//     }
//     fn get_action_target_y(self) -> u8 {
//         get_action_target_y(self.action)
//     }
//     fn get_action_type(self) -> u8 {
//         get_action_type(self.action)
//     }
// }


// pub fn validate_action(action: Action, c: Character, energy: u8, advance: u8, enemy_advance: u8, my_obstacles_parsed: [Obstacle; MAX_OBSTACLES], their_obstacles: [Obstacle]) -> bool {
//     let action_def = c.resolve_action(action.register[action.base_index + ACTION_TYPE]);

//     let status = c.status * (
//         ((!get_action_is_continuous(action_def)) as u8 & get_action_result_status_multiplier(action_def)) | 
//         (get_action_is_continuous(action_def) & (get_action_needs_previous_action(action_def) == c.last_action)) as u8);

//     // pub global ACTION_NEEDS_TARGET_FREE_SPACE: u8 = 0;  // u1
//     let target_is_free_space_valid = !get_action_needs_target_free_space(action_def) | can_move_to(advance, get_action_target_x(action), get_action_target_y(action), my_obstacles_parsed, their_obstacles);
//     // pub global ACTION_NEEDS_TARGET_IS_NOT_SELF: u8 = 1; // u1
//     let target_is_not_self_valid = !get_action_needs_target_is_not_self(action_def) | (c.x != get_action_target_x(action)) | (c.y != get_action_target_y(action));
//     // pub global ACTION_NEEDS_STATUS_HIDDEN: u8 = 4; // u1
//     let char_is_hidden = c.is_hidden == 1;
//     let char_is_hidden_valid = !get_action_needs_status_hidden(action_def) | char_is_hidden;
//     // pub global ACTION_NEEDS_STATUS_VISIBLE: u8 = 2; // u1
//     let char_is_in_view_range = is_visible(enemy_advance, c.x);
//     let char_is_fully_visible = char_is_in_view_range & !char_is_hidden;
//     let char_is_fully_visible_valid = !get_action_needs_status_visible(action_def) | char_is_fully_visible;
//     // pub global ACTION_NEEDS_STATUS_INVISIBLE: u8 = 3; // u1
//     let char_invisible_valid = !get_action_needs_status_invisible(action_def) | !char_is_in_view_range;
//     // pub global ACTION_MAX_RANGE: u8 = 7; // u6 // TODO: max_range!
//     let max_range_part = get_action_max_range(action_def) as u32;
//     let max_range = max_range_part * max_range_part;
//     let distance = get_distance(c.x, c.y, get_action_target_x(action), get_action_target_y(action));
//     let max_range_valid  = distance <= max_range;
//     // pub global ACTION_NEEDS_MIN_STATUS: u8 = 8; // u4
//     let min_status_valid = get_action_needs_min_status(action_def) <= status;
//     // pub global ACTION_NEEDS_MAX_STATUS: u8 = 9; // u4
//     let max_status_valid = get_action_needs_max_status(action_def) >= status;
//     // pub global ACTION_NEEDED_ENERGY: u8 = 10;    // u4
//     let energy_valid = get_action_needed_energy(action_def) <= energy;
    
//     target_is_free_space_valid & target_is_not_self_valid & char_is_hidden_valid & char_is_fully_visible_valid & char_invisible_valid & max_range_valid & min_status_valid & max_status_valid & energy_valid
// }


// TODO: action type as global struct & impl
//pub impl Action {
    // fn from_field(field: Field) -> Action {
    //     Action {
    //         action: field as u8,
    //         actor: (field / 0x100) as u8,
    //         target_x: (field / 0x10000) as u8,
    //         target_y: (field / 0x1000000) as u8,
    //     }
    // }

    // fn to_field(self) -> Field {
    //     action.register[action.base_index + ACTION_ACTION] as Field + (get_action_actor(action) as Field) * 0x100 + (get_action_target_x(action) as Field) * 0x10000 + (get_action_target_y(action) as Field) * 0x1000000
    // }

pub fn execute_action<T>(
    action: T,
    enemy_advance: u8,
    c: Character,
    energy: u8,
    my_obstacles: [Obstacle; MAX_OBSTACLES],
    their_obstacles: [Obstacle]
) -> (bool, Event, Event, Character, u8) where T: ResolvedAction {
    //let action_def = c.resolve_action(action.register[action.base_index + ACTION_TYPE]);
        //let mut result_event: Event = build_std_event(NO_EVENT, c.id, 0, 0);
        //let mut result_char = c;
        //let mut required_energy = 0;
        let mut is_valid = true;
        //let action_def = c.resolve_action(get_action_type(action));
        // let mut result_valid = true;

        // let need_sneak = get_action_type(action) == SNEAK;
        //let can_sneak = c.can_sneak();
        // let need_move = get_action_type(action) == MOVE | get_action_type(action) == SNEAK;
        // let can_move = can_move_to(get_action_target_x(action), get_action_target_y(action), my_obstacles_parsed, their_obstacles);
        // let need_target_is_neighbor = get_action_type(action) == SNEAK | get_action_type(action) == MOVE | get_action_type(action) == ATTACK | get_action_type(action) == SEARCH | get_action_type(action) == DISARM_TRAP;
        //let target_is_neighbor = is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action));
        // let need_target_is_not_self = get_action_type(action) == ATTACK | get_action_type(action) == SHOOT;
        // let target_is_not_self = (c.x != get_action_target_x(action)) | (c.y != get_action_target_y(action));
        // let need_ritual = get_action_type(action) == RITUAL;
        //let can_ritual = c.can_ritual();
        // let need_search = get_action_type(action) == SEARCH;
        //let can_search = c.can_search();
        //let can_attack = is_neighbor & not_self;
        // let need_can_cast_fireball = get_action_type(action) == CAST_FIREBALL;
        // let min_rounds_to_finish = if get_action_type(action) == CAST_FIREBALL {
        //     FIREBALL_ROUNDS_FOR_CAST
        // } else if get_action_type(action) == RITUAL {
        //     RITUAL_ROUNDS_FOR_WIN
        // } else if get_action_type(action) == SHOOT {
        //     MIN_DRAW_ROUNDS_FOR_SHOOT
        // } else {
        //     0
        // };
        // let max_rounds_to_finish = if get_action_type(action) == CAST_FIREBALL {
        //     FIREBALL_ROUNDS_FOR_CAST
        // } else if get_action_type(action) == RITUAL {
        //     RITUAL_ROUNDS_FOR_WIN
        // } else if (get_action_type(action) == DRAW) | (get_action_type(action) == SHOOT) {
        //     MAX_DRAW_ROUNDS_FOR_SHOOT
        // } else {
        //     0
        // };
        // let need_check_status = get_action_type(action) == CAST_FIREBALL | get_action_type(action) == RITUAL | get_action_type(action) == DRAW | get_action_type(action) == SHOOT;
        // let can_cast_fireball = c.can_cast_fireball(); // & (result_char.status <= FIREBALL_ROUNDS_FOR_CAST);
        // let can_draw = c.can_shoot(); // & (c.status < MAX_DRAW_ROUNDS_FOR_SHOOT);
        // let can_shoot = c.can_shoot(); // & (c.status >= MIN_DRAW_ROUNDS_FOR_SHOOT);
        // let can_disarm = c.can_disarm();
        // let is_valid =
        //     (get_action_type(action) == WAIT) |
        //     ((get_action_type(action) == SNEAK) & can_sneak & can_move & target_is_neighbor) |
        //     ((get_action_type(action) == MOVE) & can_move & target_is_neighbor) |
        //     ((get_action_type(action) == RITUAL) & can_ritual) |
        //     ((get_action_type(action) == SEARCH) & can_search & target_is_neighbor) |
        //     ((get_action_type(action) == ATTACK) & target_is_neighbor & target_is_not_self) |
        //     ((get_action_type(action) == CAST_FIREBALL) & can_cast_fireball & result_char.status <= max_rounds_to_finish) |
        //     ((get_action_type(action) == DRAW) & can_draw) |
        //     ((get_action_type(action) == SHOOT) & can_shoot & target_is_not_self) |
        //     ((get_action_type(action) == DISARM_TRAP) & can_disarm & target_is_neighbor);




        // need to adapt status first in case of action interruption!

    //let action_type = action.get_action_type(action);
    //let action_def = c.resolve_action(action_type);
    let action_type = action.get_action_type();

    let action_target_x = action.get_action_target_x();
    let action_target_y = action.get_action_target_y();
    let c_x = c.get_x();
    let c_y = c.get_y();
    let distance = get_distance(c_x, c_y, action_target_x, action_target_y);

    let is_continuous = action.get_action_is_continuous();
    let is_not_interrupted = (
        ((!is_continuous) & (action.get_action_result_status_multiplier() != 0)) | // that's the ID of the wait action => leave status, but not continuous
        ((is_continuous) & (action.get_action_needs_previous_action() == c.last_action) & (action_target_x == c.get_target_x()) & (action_target_y == c.get_target_y()))
    );
    let status = c.status * is_not_interrupted as u8;

    // pub global ACTION_NEEDS_TARGET_FREE_SPACE: u8 = 0;  // u1
    let target_is_free_space_valid = !action.get_action_needs_target_free_space() | can_move_to(distance, action_target_x, action_target_y, my_obstacles, their_obstacles);
    softassert!(quote { is_valid }, quote { target_is_free_space_valid }, quote { f"Target space ({action_target_x},{action_target_y}) cannot be moved to: {VIEW_DISTANCE},{my_obstacles},{their_obstacles}" });
    
    // pub global ACTION_NEEDS_TARGET_IS_NOT_SELF: u8 = 1; // u1
    let target_is_not_self_valid = !action.get_action_needs_target_is_not_self() | (c_x != action_target_x) | (c_y != action_target_y);
    softassert!(quote { is_valid }, quote { target_is_not_self_valid }, quote { f"Target cannot be self ({action_target_x},{action_target_y})" });

    // pub global ACTION_NEEDS_STATUS_HIDDEN: u8 = 4; // u1
    let char_is_hidden = c.is_hidden == 1;
    let char_is_hidden_valid = !action.get_action_needs_status_hidden() | char_is_hidden;
    softassert!(quote { is_valid }, quote { char_is_hidden_valid }, quote { f"Character needs to be hidden to perform action {action_type}" });
    
    // pub global ACTION_NEEDS_STATUS_VISIBLE: u8 = 2; // u1
    let char_is_in_view_range = is_visible(enemy_advance, c_x);
    let char_is_fully_visible = char_is_in_view_range & !char_is_hidden;
    let char_is_fully_visible_valid = !action.get_action_needs_status_visible() | char_is_fully_visible;
    softassert!(quote { is_valid }, quote { char_is_fully_visible_valid }, quote { f"Character must be fully visible for action {action_type}: in_view_range: {char_is_in_view_range} & !hidden {char_is_hidden} for enemy_advance {enemy_advance} @ {c_x}" });

    // pub global ACTION_NEEDS_STATUS_INVISIBLE: u8 = 3; // u1
    let char_invisible_valid = !action.get_action_needs_status_invisible() | !char_is_in_view_range | char_is_hidden;
    softassert!(quote { is_valid }, quote { char_invisible_valid }, quote { f"Character must not be visible to perform action {action_type}: !in_view_range: {char_is_in_view_range} || hidden: {char_is_hidden} for enemy_advance {enemy_advance} @ {c_x}" });

    // pub global ACTION_MAX_RANGE: u8 = 7; // u6 // TODO: max_range!
    let max_range_part = action.get_action_max_range() as u16;
    let max_range = max_range_part * max_range_part;
    let max_range_valid  = distance <= max_range;
    softassert!(quote { is_valid }, quote { max_range_valid }, quote { f"Character is out of range! Distance: {distance} > {max_range}: {{{c_x},{c_y}}} - {{{action_target_x},{action_target_y}}} with {max_range_part}" });

    // pub global ACTION_NEEDS_MIN_STATUS: u8 = 8; // u4
    let min_status = action.get_action_needs_min_status();
    let min_status_valid = min_status <= status;
    softassert!(quote { is_valid }, quote { min_status_valid }, quote { f"Character needs min status {min_status} to perform action {action_type}, but only has {status}" });

    // pub global ACTION_NEEDS_MAX_STATUS: u8 = 9; // u4
    let max_status = action.get_action_needs_max_status();
    let max_status_valid = max_status >= status;
    softassert!(quote { is_valid }, quote { max_status_valid }, quote { f"Character cannot have a higher status than {max_status} to perform action {action_type}: got {status}" });

    // pub global ACTION_NEEDED_ENERGY: u8 = 10;    // u4
    let required_energy = action.get_action_needed_energy();
    let energy_valid = required_energy <= energy;
    softassert!(quote { is_valid }, quote { energy_valid }, quote { f"Character has insufficient energy left to perform action {action_type}: {energy} < {required_energy}" });
    
    

        let coords = [
            (c_x, c_y),
            (action_target_x, action_target_y),
            (NOWHERE, NOWHERE),
            (NOWHERE, NOWHERE),
        ];

        // CALCULATE EVENTS
        let seen_event_value = status as u32 * action.get_action_result_event_seen_value_status_multiplier() as u32 + action.get_action_result_event_seen_value_fixed_addition() as u32;
        softassert!(quote { is_valid }, quote { seen_event_value <= 255 as u32 }, quote { f"Invalid event value (seen): {seen_event_value} does not fit in u8!" });

        let unseen_event_value = status as u32 * action.get_action_result_event_not_seen_value_status_multiplier() as u32 + action.get_action_result_event_not_seen_value_fixed_addition() as u32;
        softassert!(quote { is_valid }, quote { unseen_event_value <= 255 as u32 }, quote { f"Invalid event value (unseen): {unseen_event_value} does not fit in u8!" });

        let seen_event_coords_idx = action.get_action_result_event_seen_coord_idx();
        softassert!(quote { is_valid }, quote { seen_event_coords_idx < 4 }, quote { f"Invalid seen event coord idx: {seen_event_coords_idx} > 3" });

        let seen_event_coords = coords[seen_event_coords_idx & 3];

        let unseen_event_coords_idx = action.get_action_result_event_not_seen_coord_idx();
        softassert!(quote { is_valid }, quote { unseen_event_coords_idx < 4 }, quote { f"Invalid unseen event coord idx: {unseen_event_coords_idx} > 3" });

        let unseen_event_coords = coords[unseen_event_coords_idx & 3];

        //let events = [
        let dummy_event =    build_subtype_value_event(NO_EVENT, c.get_id(), coords[ACTION_RESULT_COORDINATES_IDX_INVISIBLE].0, coords[ACTION_RESULT_COORDINATES_IDX_INVISIBLE].1, 0 as u8, 0 as u8, 0 as u8);
        let unseen_event =    build_subtype_value_event(
                action.get_action_result_event_not_seen_type(),
                c.get_id(), 
                unseen_event_coords.0,
                unseen_event_coords.1,
                unseen_event_value as u8,
                action.get_action_result_event_not_seen_subtype(),
                action.get_action_result_event_not_seen_radius()
            );
        let seen_event =    build_subtype_value_event(
                action.get_action_result_event_seen_type(),
                c.get_id(), 
                seen_event_coords.0,
                seen_event_coords.1,
                seen_event_value as u8,
                action.get_action_result_event_seen_subtype(),
                action.get_action_result_event_seen_radius()
            );
        //];

        // APPLY EFFECTS ON SELF
        let energy = std::wrapping_sub(energy, action.get_action_needed_energy());
        let status = status as u32 * action.get_action_result_status_multiplier() as u32 + action.get_action_result_status_fixed_addition() as u32;
        softassert!(quote { is_valid }, quote { status <= MAX_STATUS as u32 }, quote { f"Invalid result status: {status} > {MAX_STATUS}" });

        let final_coords = coords[action.get_action_move_to_target() as u8];
        // debug!(quote { println(f"final_coords:{final_coords}"); });
        let is_hidden = ((c.is_hidden == 1) & !action.get_action_removes_status_hidden()) | action.get_action_sets_status_hidden();
        let is_visible = !is_hidden & is_visible(enemy_advance, final_coords.0);
    // pub global ACTION_RESULT_STATUS_MULTIPLIER: u8 =     ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT;     // u1
    // pub global ACTION_RESULT_STATUS_FIXED_ADDITION: u8 = ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT + 1; // u4
    // pub global ACTION_MOVE_TO_TARGET: u8 =               ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT + 2; // u1
    // pub global ACTION_SETS_STATUS_HIDDEN: u8 = 5; // u1
    // pub global ACTION_REMOVES_STATUS_HIDDEN: u8 = 6; // u1

        // let target_coords = [
        //     (target_x, target_y),
        //     (c.get_target_x(), c.get_target_y())
        // ];

        (
            is_valid,
            if is_visible { seen_event } else { unseen_event },//events[1 + (is_visible as u8)],
            if action.get_action_unseen_event_is_internal() { unseen_event } else { dummy_event },//events[get_action_unseen_event_is_internal(action_def) as u8],
            Character {
                id: c.id,
                x: final_coords.0,
                y: final_coords.1,
                status: status as u8,
                is_hidden: is_hidden as u1,
                has_been_seen: is_visible,
                last_action: is_not_interrupted as u8 * c.last_action + (!is_not_interrupted) as u8 * action.get_action_type(),
                target_x: is_not_interrupted as u8 * c.get_target_x() + (!is_not_interrupted) as u8 * action_target_x, // if is_not_interrupted { c.get_target_x() } else { get_action_target_x(action) };
                target_y: is_not_interrupted as u8 * c.get_target_y() + (!is_not_interrupted) as u8 * action_target_y,
                class: c.class,
                damage_mod: c.damage_mod,
                health: c.health,
                actions: c.actions
            },
            energy
        )

        // if get_action_type(action) == SNEAK {
        //     //assert(c.can_sneak());
        //     if !can_sneak { let actor_id = c.id; println(f"Failed to execute action: Character {actor_id} cannot sneak"); }
        //     //assert(can_move_to(get_action_target_x(action), get_action_target_y(action), my_obstacles_parsed, their_obstacles));
        //     //assert(is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action)));
        //     // result_valid = c.can_sneak() & can_move_to(get_action_target_x(action), get_action_target_y(action), my_obstacles_parsed, their_obstacles) & is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action));
        //     result_char.x = get_action_target_x(action);  
        //     result_char.y = get_action_target_y(action);
        //     result_char.status = 0;
        //     required_energy = c.get_energy_per_sneak();
        // }
        // if get_action_type(action) == MOVE {
        //     // assert(can_move_to(get_action_target_x(action), get_action_target_y(action), my_obstacles_parsed, their_obstacles));
        //     // assert(is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action)));
        //     // result_valid = can_move_to(get_action_target_x(action), get_action_target_y(action), my_obstacles_parsed, their_obstacles) & is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action));
        //     result_char.x = get_action_target_x(action);
        //     result_char.y = get_action_target_y(action);
        //     result_char.status = 0;
        //     required_energy = c.get_energy_per_move();
        //     result_char.has_been_seen = is_visible(enemy_advance, result_char.x);
        //     if c.get_has_been_seen() {
        //         result_event = build_std_event(SEE_MOVE, c.id, get_action_target_x(action), get_action_target_y(action));
        //     }
        // }
        // if get_action_type(action) == RITUAL {
        //     //assert(c.can_ritual());
        //     // result_valid = c.can_ritual();
        //     result_char.status += 1;
        //     if result_char.status >= RITUAL_ROUNDS_FOR_WIN {
        //         result_event = build_std_event(WIN, c.id, 0, 0);
        //     } else {
        //         result_event = build_std_event(SEE_RITUAL, c.id, 0, 0);
        //     }
        //     required_energy = c.get_energy_per_ritual();
        // }
        // if get_action_type(action) == SEARCH {
        //     // assert(c.can_search());
        //     // assert(is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action)));
        //     // result_valid = c.can_search() & is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action));
        //     result_char.status = 0;
        //     result_event = build_std_event(SEE_SEARCH_TRAP, c.id, get_action_target_x(action), get_action_target_y(action));
        //     required_energy = c.get_energy_per_search();
        // }
        // if get_action_type(action) == ATTACK {
        //     // assert(is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action)));
        //     // assert((c.x != get_action_target_x(action)) | (c.y != get_action_target_y(action)));
        //     // result_valid = is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action)) & ((c.x != get_action_target_x(action)) | (c.y != get_action_target_y(action)));
        //     result_char.status = 0;
        //     result_event = build_subtype_value_event(RECEIVE_ATTACK, c.id, get_action_target_x(action), get_action_target_y(action), c.get_damage(ATTACK_MELEE), ATTACK_MELEE);
        //     required_energy = c.get_energy_per_attack();
        // }
        // // TODO: global SET_TRAP = 6 as u8;
        // if get_action_type(action) == CAST_FIREBALL {
        //     // assert(c.can_cast_fireball());
        //     result_char.status += 1;
        //     // assert(result_char.status <= FIREBALL_ROUNDS_FOR_CAST);
        //     // result_valid = c.can_cast_fireball() & (result_char.status <= FIREBALL_ROUNDS_FOR_CAST);
        //     if result_char.status >= FIREBALL_ROUNDS_FOR_CAST {
        //         // TODO: handle friendly fire and destruction of own walls and own traps
        //         result_event = build_subtype_value_event(RECEIVE_ATTACK, c.id, get_action_target_x(action), get_action_target_y(action), c.get_damage(ATTACK_FIREBALL), ATTACK_FIREBALL);
        //     } else {
        //         if c.get_has_been_seen() {
        //             result_event = build_subtype_value_event(SEE_CAST, c.id, get_action_target_x(action), get_action_target_y(action), 0, ATTACK_FIREBALL);
        //         }
        //     }
        //     required_energy = c.get_energy_per_cast();
        // }
        // if get_action_type(action) == DRAW {
        //     // assert(c.can_shoot());
        //     // assert(c.status < MAX_DRAW_ROUNDS_FOR_SHOOT);
        //     // result_valid = c.can_shoot() & (c.status < MAX_DRAW_ROUNDS_FOR_SHOOT);
        //     result_char.status += 1;
        //     if c.get_has_been_seen() {
        //         result_event = build_std_event(SEE_DRAW, c.id, get_action_target_x(action), get_action_target_y(action));
        //     }
        //     required_energy = c.get_energy_per_draw();
        // }
        // if get_action_type(action) == SHOOT {
        //     // assert(c.can_shoot());
        //     // assert(c.status >= MIN_DRAW_ROUNDS_FOR_SHOOT);
        //     // assert((c.x != get_action_target_x(action)) | (c.y != get_action_target_y(action)));
        //     // result_valid = c.can_shoot() & (c.status >= MIN_DRAW_ROUNDS_FOR_SHOOT) & ((c.x != get_action_target_x(action)) | (c.y != get_action_target_y(action)));
        //     result_char.status = 0;
        //     // TODO: check distance! abs(c.x - get_action_target_x(action)) + abs(c.y - get_action_target_y(action)) <= c.get_shoot_range()
        //     result_event = build_subtype_value_event(RECEIVE_ATTACK, c.id, get_action_target_x(action), get_action_target_y(action), c.get_damage(ATTACK_RANGED), ATTACK_RANGED);
        //     required_energy = c.get_energy_per_shoot();

        // }
        // // TODO: SET_TRAP
        // if get_action_type(action) == DISARM_TRAP {
        //     // assert(c.can_disarm());
        //     // assert(is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action)));
        //     // result_valid = c.can_disarm() & is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action));
        //     result_char.status = 0;
        //     result_event = build_std_event(DESTROY, c.id, get_action_target_x(action), get_action_target_y(action));
        //     required_energy = c.get_energy_per_disarm();
        // }
        
        // // assert(energy >= required_energy);
        // let result_valid = is_valid & (energy >= required_energy);
        // if result_valid {
        //     energy -= required_energy;
        // }
        // // energy -= required_energy;
        // (result_valid, result_event, result_char, energy)
    }
//}

//global test_actions: [TestActionDefinition; 1] = [
    // build_test_action_def!(build_wait_action_def(), quote { 0, 1, 3, 4 }),
    //TestActionDefinition { register: build_test_action_def!(build_wait_action_def()), action: new_action(0, 1, 3, 4) },
    // build_move_action(class_energy_per_move[ARCHER]),
    //     build_attack_action(class_energy_per_attack[ARCHER], ATTACK_MELEE, 1, class_damage[0][ARCHER]),
    //     build_draw_action(3, class_energy_per_draw[ARCHER], 10, ARCHER),
    //     build_shoot_action(3, class_energy_per_shoot[ARCHER], ATTACK_RANGED, 8, class_damage[1][ARCHER], 2, MIN_DRAW_ROUNDS_FOR_SHOOT, MAX_DRAW_ROUNDS_FOR_SHOOT), // archer
    //     build_wait_action_def(),
    //     ,
    // ],
    // [
    //     build_move_action(class_energy_per_move[RITUALIST]),
    //     build_attack_action(class_energy_per_attack[RITUALIST], ATTACK_MELEE, 1, class_damage[0][RITUALIST]),
    //     build_cast_action(3, class_energy_per_cast[RITUALIST], RITUALIST),
    //     build_ritual_action(3, class_energy_per_ritual[RITUALIST]),
    //     build_wait_action_def(),
    //     build_wait_action_def(),
    // ],
    // [
    //     build_move_action(class_energy_per_move[ROGUE]),
    //     build_attack_action(class_energy_per_attack[ROGUE], ATTACK_MELEE, 1, class_damage[0][ROGUE]),
    //     build_sneak_action(class_energy_per_sneak[ROGUE]),
    //     build_search_action(class_energy_per_search[ROGUE], 1),
    //     build_disarm_trap_action(class_energy_per_disarm[ROGUE], 1),
    //     build_set_trap_action(class_energy_per_disarm[ROGUE], 1),
    // ],
    // [
    //     build_move_action(class_energy_per_move[KNIGHT]),
    //     build_attack_action(class_energy_per_attack[KNIGHT], ATTACK_MELEE, 1, class_damage[0][KNIGHT]),
    //     build_wait_action_def(),
    //     build_wait_action_def(),
    //     build_wait_action_def(),
    //     build_wait_action_def(),
    // ],
    // [
    //     build_move_action(class_energy_per_move[MAGE]),
    //     build_attack_action(class_energy_per_attack[MAGE], ATTACK_MELEE, 1, class_damage[0][MAGE]),
    //     build_cast_action(3, class_energy_per_cast[MAGE], MAGE),
    //     build_evocation_action(3, class_energy_per_cast[MAGE], ATTACK_FIREBALL, 6, 1,class_damage[2][MAGE], 5, FIREBALL_ROUNDS_FOR_CAST, FIREBALL_ROUNDS_FOR_CAST),
    //     build_wait_action_def(),
    //     build_wait_action_def()
    // ]
// ]

// pub fn create_test_action(action: Action) -> TestActionDefinition {
//     TestActionDefinition {
//         register: 
//     }
// }

// pub struct TestActionDefinition {
//     pub register: [u8; ACTION_DEFINITION_SIZE],
//     pub action: Action,
// }

// impl ResolvedAction for TestActionDefinition {
//     fn get_action_needs_target_free_space(self: TestActionDefinition) -> bool {
//         self.register[ACTION_NEEDS_TARGET_FREE_SPACE] == 1
//     }
//     fn get_action_needs_target_is_not_self(self: TestActionDefinition) -> bool {
//         self.register[ACTION_NEEDS_TARGET_IS_NOT_SELF] == 1
//     }
//     fn get_action_needs_status_visible(self: TestActionDefinition) -> bool {
//         self.register[ACTION_NEEDS_STATUS_VISIBLE] == 1
//     }
//     fn get_action_needs_status_invisible(self: TestActionDefinition) -> bool {
//         self.register[ACTION_NEEDS_STATUS_INVISIBLE] == 1
//     }
//     fn get_action_needs_status_hidden(self: TestActionDefinition) -> bool {
//         self.register[ACTION_NEEDS_STATUS_HIDDEN] == 1
//     }
//     fn get_action_sets_status_hidden(self: TestActionDefinition) -> bool {
//         self.register[ACTION_SETS_STATUS_HIDDEN] == 1
//     }
//     fn get_action_removes_status_hidden(self: TestActionDefinition) -> bool {
//         self.register[ACTION_REMOVES_STATUS_HIDDEN] == 1
//     }
//     fn get_action_max_range(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_MAX_RANGE]
//     }
//     fn get_action_needs_min_status(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_NEEDS_MIN_STATUS]
//     }
//     fn get_action_needs_max_status(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_NEEDS_MAX_STATUS]
//     }
//     fn get_action_needed_energy(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_NEEDED_ENERGY]
//     }
//     fn get_action_unseen_event_is_internal(self: TestActionDefinition) -> bool {
//         self.register[ACTION_EVENT_IS_TRAP] == 1
//     }
//     fn get_action_result_event_seen_type(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_SEEN_TYPE]
//     }
//     fn get_action_result_event_seen_subtype(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_SEEN_SUBTYPE]
//     }
//     fn get_action_result_event_seen_value_status_multiplier(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_SEEN_VALUE_STATUS_MULTIPLIER]
//     }
//     fn get_action_result_event_seen_value_fixed_addition(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_SEEN_VALUE_FIXED_ADDITION]
//     }
//     fn get_action_result_event_seen_coord_idx(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_SEEN_COORD_IDX]
//     }
//     fn get_action_result_event_seen_radius(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_SEEN_RADIUS]
//     }
//     fn get_action_result_event_not_seen_type(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_NOT_SEEN_TYPE]
//     }
//     fn get_action_result_event_not_seen_subtype(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_NOT_SEEN_SUBTYPE]
//     }
//     fn get_action_result_event_not_seen_value_status_multiplier(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_NOT_SEEN_VALUE_STATUS_MULTIPLIER]
//     }
//     fn get_action_result_event_not_seen_value_fixed_addition(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_NOT_SEEN_VALUE_FIXED_ADDITION]
//     }
//     fn get_action_result_event_not_seen_coord_idx(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_NOT_SEEN_COORD_IDX]
//     }
//     fn get_action_result_event_not_seen_radius(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_NOT_SEEN_RADIUS]
//     }
//     fn get_action_result_status_multiplier(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_STATUS_MULTIPLIER]
//     }
//     fn get_action_result_status_fixed_addition(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_STATUS_FIXED_ADDITION]
//     }
//     fn get_action_move_to_target(self: TestActionDefinition) -> u1 {
//         self.register[ACTION_MOVE_TO_TARGET] as u1
//     }
//     fn get_action_is_continuous(self: TestActionDefinition) -> bool {
//         self.register[ACTION_IS_CONTINUOUS] == 1
//     }
//     fn get_action_needs_previous_action(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_NEEDS_PREVIOUS_ACTION]
//     }

//     fn get_action_target_x(self) -> u8 {
//         get_action_target_x(self.action)
//     }
//     fn get_action_target_y(self) -> u8 {
//         get_action_target_y(self.action)
//     }
//     fn get_action_type(self) -> u8 {
//         get_action_type(self.action)
//     }
// }

#[test]
fn test_execute_action() {
    let action = build_test_action_def!(build_move_action(4), quote { 1, 2, 3, 4 }); //new_action(1, 2, 3, 4);
    let their_advance = 1;
    let actor = Character {
        id: 2,
        x: 2,
        y: 4,
        target_x: 0,
        target_y: 0,
        health: 255,
        damage_mod: 1,
        last_action: WAIT,
        class: MAGE,
        is_hidden: 0 as u1,
        has_been_seen: true,
        status: 0,
        actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER]
    };
    let energy = 15;
    let my_obstacles = get_default_obstacles(0);
    let their_obstacles = get_default_obstacles(1);
    let (valid, event, internal_event, c, result_energy) = execute_action(
        action,
        their_advance,
        actor,
        energy,
        my_obstacles,
        their_obstacles
    );
    assert(valid, "valid");
    assert(event.actor_id == actor.id, f"{event}.actorid is not {actor}.id");
    assert(event.event == SEE_MOVE, f"{event} is not {SEE_MOVE}");
    assert(event.x == action.get_action_target_x(), f"{event}.target_x is not action target x");
    assert(event.y == action.get_action_target_y(), f"{event}.target_y is not action target y");
    assert(c.x == event.x, f"{c}.x is not action target x");
    assert(internal_event.event == NO_EVENT, f"expected no internal event, got {internal_event}");
    assert(result_energy == 11, f"{result_energy} != 11");
}



pub fn parse_actions(fields: [Field; SERIALIZED_ACTIONS_ARRAY_SIZE]) -> [Action; MAX_ACTIONS] {
    comptime {
        assert(UNREADABLE_BYTES_PER_FIELD + SERIALIZED_ACTIONS_PER_FIELD * SERIALIZED_ACTION_BYTE_SIZE <= 32);
        assert(SERIALIZED_ACTIONS_ARRAY_SIZE * SERIALIZED_ACTIONS_PER_FIELD == MAX_ACTIONS);
        assert(SERIALIZED_ACTION_BYTE_SIZE >= 4);
    }

    let mut actions: [Action] = &[];
    for i in 0..SERIALIZED_ACTIONS_ARRAY_SIZE {
        let split: [u8; 32] = fields[i].to_be_bytes::<32>();
        //assert(split.len() == 32);
        for j in 0..SERIALIZED_ACTIONS_PER_FIELD {
            let offset = UNREADABLE_BYTES_PER_FIELD + j * SERIALIZED_ACTION_BYTE_SIZE;
            actions = actions.push_back(new_action(
                split[offset],
                split[offset + 1],
                split[offset + 2],
                split[offset + 3],
            ));
            /*Action {
                action: split[offset],
                actor: split[offset + 1],
                target_x: split[offset + 2],
                target_y: split[offset + 3],
            }*/
        }
    }
    actions.as_array()
}

/**
* Warning: This function can throw!!!
*/
pub fn serialize_actions(actions: [Action]) -> [Field; SERIALIZED_ACTIONS_ARRAY_SIZE] {
    comptime {
        assert(UNREADABLE_BYTES_PER_FIELD + SERIALIZED_ACTIONS_PER_FIELD * SERIALIZED_ACTION_BYTE_SIZE <= 32);
        assert(SERIALIZED_ACTIONS_ARRAY_SIZE * SERIALIZED_ACTIONS_PER_FIELD == MAX_ACTIONS);
        assert(SERIALIZED_ACTION_BYTE_SIZE >= 4);
    }

    assert(actions.len() <= MAX_ACTIONS);

    let mut actions_stuffed: [Action; MAX_ACTIONS] = [new_action(WAIT, 0, 0, 0); MAX_ACTIONS];
    for i in 0..actions.len() {
        actions_stuffed[i] = actions[i];
    }

    let mut fields: [Field] = &[];
    for i in 0..SERIALIZED_ACTIONS_ARRAY_SIZE {
        let mut data: [u8; 32] = [0; 32];
        for j in 0..SERIALIZED_ACTIONS_PER_FIELD {
            let index = i * SERIALIZED_ACTIONS_PER_FIELD + j;
            let action = actions_stuffed[index];
            let offset = UNREADABLE_BYTES_PER_FIELD + j * SERIALIZED_ACTION_BYTE_SIZE;
            data[offset] = get_action_type(action);
            data[offset + 1] = get_action_actor(action);
            data[offset + 2] = get_action_target_x(action);
            data[offset + 3] = get_action_target_y(action);
        }
        fields = fields.push_back(std::field::bytes32_to_field(data));
    }
    fields.as_array()
}