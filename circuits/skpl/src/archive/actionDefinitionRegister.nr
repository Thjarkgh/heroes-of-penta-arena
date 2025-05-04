// use crate::actionDefinition::{ ACTION_DEFINITION_SIZE, ActionDefinition };
// use crate::action::{ Action };
// use crate::{ MAX_ACTIONS_PER_CHARACTER, CLASS_COUNT };
// use super::{action::get_action_actor, action::get_action_type};

// pub global ACTION_DEFINITION_REGISTER_SIZE: u32 = ACTION_DEFINITION_SIZE * (1 + (MAX_ACTIONS_PER_CHARACTER - 1) * (CLASS_COUNT - 1));

// fn get_action_base_index(actor_id: u8, action_idx: u8) -> u16 {
//     if (action_idx == 0) | (action_idx as u32 >= MAX_ACTIONS_PER_CHARACTER) | (actor_id as u32 >= MAX_CHARACTERS) {
//         0 as u16
//     } else {
//         (actor_id as u16 * (MAX_ACTIONS_PER_CHARACTER - 1) as u16 + action_idx as u16) * ACTION_DEFINITION_SIZE as u16
//     }
// }

// pub struct ActionDefinitionRegister {
//   register: [u8; ACTION_DEFINITION_REGISTER_SIZE]
// }

// impl ActionDefinitionRegister {
//   pub fn new(register: [u8; ACTION_DEFINITION_REGISTER_SIZE]) -> ActionDefinitionRegister {
//     ActionDefinitionRegister {
//       register: register
//     }
//   }

//   pub fn resolve_action(self, action: Action) -> ActionDefinition {
//     ActionDefinition {
//       base_index: get_action_base_index(get_action_actor(action), get_action_type(action)),
//       action: action,
//       register: self.register
//     }
//   }
// }



////////////////////////////////// action

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