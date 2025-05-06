// // use crate::{ HEIGHT, WIDTH };
// use dep::std::{append::Append};
// use crate::{ NO_EVENT, WAIT, SEE_MOVE, WIN, SEE_SEARCH_TRAP, RECEIVE_ATTACK, SEE_CAST, SEE_DRAW };
// use crate::{ RITUAL_ROUNDS_FOR_WIN };
// use crate::{DISARMED_TRAP};
// use crate::{TRAP, ADD_OBSTACLE};
// use crate::{WIN_BY_RITUAL};
// use crate::{actionResultEffect::build_action_def_result_effects, actionPreCalcEffect::build_action_def_pre_calc_effect, actionResultEvent::build_action_def_result_event, actionRequirements::build_action_def_requirements, actionResultEvent::set_action_def_result_event_in_action_def, actionResultEffect::set_action_def_result_effects_in_action_def, actionPreCalcEffect::set_action_def_pre_calc_effects_in_action_def, actionRequirements::set_action_def_requirements_in_action_def, actionResultEvent::ActionResultEvent, actionResultEffect::ActionResultEffect, actionRequirements::ActionRequirement, actionPreCalcEffect::ActionPreCalcEffect};
// use crate::{MAX_ACTIONS_PER_CHARACTER, MAX_CHARACTERS};

// pub trait ActionDefinitionPartBuilder<T> { fn new() -> T; }
// pub type DEF_ROW<T> = (Quoted, u8, T);
// pub comptime fn get_def_register_value(register: Quoted, bytes: u32, bits: u8, bitsize: u8) -> Quoted {
//     if bitsize == 8 {
//       quote { $register[$bytes] }
//     } else {
//       let divisor = 2 ^ bits;
//       let mask = std::wrapping_sub(2 ^ bitsize, 1);
//       if bitsize == 1 {
//         quote { (($register[$bytes] as u8 / $divisor as u8) == 1 as u8) }
//       } else {
//         quote { (($register[$bytes] as u8 / $divisor as u8) & $mask as u8) }
//       }
//     }
// }
// pub comptime fn build_over_def_array<Env, T>(array: [DEF_ROW<T>], base_index: u32, builder: fn[Env] (u32, u8, Quoted, u8, T) -> Quoted) -> Quoted {
//   let mut result = quote {};
  
//   let mut bits: u8 = 0;
//   let mut bytes: u32 = base_index;

//   for i in 0..array.len() {
//     let (varname, bitsize, args) = array[i];
//     assert(bitsize <= 8, f"Invalid bit size: {bitsize}");
//     if (bits + bitsize) > 8 {
//       bytes += 1;
//       bits = 0;
//     }
//     assert(bits < 8, f"bits must not reach 8 or higher: {bits}");

//     result = result.append(builder(bytes, bits, varname, bitsize, args));

//     bits += bitsize;
//   }
//   result
// }
// pub comptime fn derive_action_def_def_builder<T>(f: FunctionDefinition, array: [DEF_ROW<T>]) {
//   let mut params: [(Quoted, Type)] = &[];
//   let mut last_byte: u32 = 0;
//   let mut result: Quoted = build_over_def_array(array, 0, |bytes, bits, varname, bitsize, _|{
//     let t = if bitsize == 1 { quote { u1 }.as_type() } else { quote { u8 }.as_type() };
//     params = params.push_back((varname, t));
//     let mut r = quote {};
//     if bytes != last_byte {
//       r = r.append(quote { , });
//     } else if (bytes + bits as u32) != 0 {
//       r = r.append(quote { + });
//     }
//     assert(bitsize > 0);
//     assert(bitsize <= 8);
//     if bitsize == 8 {
//       r = r.append(quote { $varname  });
//     } else {
//       let multiplier = 2 ^ bits;
//       if bitsize == 1 {
//         r = r.append(quote { $varname as u8 * $multiplier });
//       } else {
//         let mask = std::wrapping_sub(2 ^ bitsize, 1);
//         r = r.append(quote { (( $varname & $mask ) * $multiplier) });
//       }
//     }
//     last_byte = bytes;
//     r
//   });
//   f.set_parameters(params);

//   let return_type = f.return_type();

//   f.set_body(quote { $return_type { register: [ $result ] } }.as_expr().unwrap());
// }
// pub comptime fn get_action_def_def_register_size<T>(array: [DEF_ROW<T>]) -> u32 {
//   let mut size = 0;
//   let _ = build_over_def_array(array, 0, |bytes, _, _, _, _|{
//     size = bytes;
//     quote {}
//   });
//   size + 1
// }
// pub comptime fn get_action_def_def_register_element_type() -> Type {
//   quote { u8 }.as_type()
// }
// pub comptime fn get_action_def_def_register_type<T>(array: [DEF_ROW<T>]) -> Type {
//   let size = get_action_def_def_register_size(array);
//   let et = get_action_def_def_register_element_type();
//   quote { [$et; $size] }.as_type()
// }
// pub comptime fn derive_action_def_def_struct<T>(s: StructDefinition, array: [DEF_ROW<T>]) {
//   // let size = get_action_def_requirements_register_size();
//   let fields = s.fields([]);
//   assert(fields.len() == 1);
//   s.set_fields([(fields[0].0, get_action_def_def_register_type(array))]);
// }
// pub comptime fn derive_action_def_def_struct_new<T>(f: FunctionDefinition, array: [DEF_ROW<T>]) {
//   let size = get_action_def_def_register_size(array);
//   let et = get_action_def_def_register_element_type();
//   let t = get_action_def_def_register_type(array);
//   f.set_return_type(t);
//   f.set_body(quote { ActionRequirement { [0 as $et; $size] } }.as_expr().unwrap());
// }

// pub type ActionDefinition = [u8; 32];
// pub fn build_action_definition(
//   requirements: ActionRequirement,
//   pre_calc_effects: ActionPreCalcEffect,
//   result_effects: ActionResultEffect,
//   result_events: [ActionResultEvent; 4]
// ) -> ActionDefinition {
//   let mut result = [0 as u8; 32];
//   set_action_def_requirements_in_action_def!(quote { requirements }, quote { result });
//   set_action_def_pre_calc_effects_in_action_def!(quote { pre_calc_effects },  quote { result });
//   set_action_def_result_effects_in_action_def!(quote { result_effects }, quote { result });
//   set_action_def_result_event_in_action_def!(quote { result_events }, quote { result });
//   result
// }
// // pub global ACTION_DEFINITION_SIZE: u32 = get_action_def_requirements_byte_size!() + get_action_def_pre_calc_effects_byte_size!();


// // comptime global ACTION_DEF_REQ_FLAGS_BYTE_IDX: u16 = 0;
// // comptime global ACTION_NEEDS_TARGET_FREE_SPACE: u16 = 0;  // u1
// // comptime global ACTION_NEEDS_TARGET_IS_NOT_SELF: u16 = 1; // u1
// // comptime global ACTION_NEEDS_STATUS_VISIBLE: u16 = 2; // u1
// // comptime global ACTION_NEEDS_STATUS_INVISIBLE: u16 = 3; // u1
// // comptime global ACTION_NEEDS_STATUS_HIDDEN: u16 = 4; // u1
// // comptime global ACTION_SETS_STATUS_HIDDEN: u16 = 5; // u1
// // comptime global ACTION_REMOVES_STATUS_HIDDEN: u16 = 6; // u1
// // comptime global ACTION_EVENT_IS_TRAP: u16 = 7; // u1
// // comptime global ACTION_NEEDS_MIN_STATUS: u16 = 8; // u4
// // comptime global ACTION_NEEDS_MAX_STATUS: u16 = 9; // u4
// // comptime global ACTION_NEEDED_ENERGY: u16 = 10;    // u4
// // comptime global ACTION_MAX_RANGE: u16 = 11; // u6 // TODO: max_range!
// // comptime global ACTION_DEF_FIELD_COUNT: u32 = 10;
// // // comptime fn action_def_def(name: Quoted, bit_size: u8) -> (Quoted, u8) {
// // //     (name, bit_size)
// // // }
// // comptime global ACTION_DEF_DEF: [(Quoted, u8); ACTION_DEF_FIELD_COUNT] = [
// //     action_def_def(quote { ACTION_DEF_REQ_FLAG_NEEDS_TARGET_FREE_SPACE }, 1),
// //     action_def_def(quote { ACTION_DEF_REQ_FLAG_NEEDS_TARGET_IS_NOT_SELF }, 1),
// //     action_def_def(quote { ACTION_DEF_REQ_FLAG_NEEDS_STATUS_VISIBLE }, 1),
// //     action_def_def(quote { ACTION_DEF_REQ_FLAG_NEEDS_STATUS_INVISIBLE }, 1),
// //     action_def_def(quote { ACTION_DEF_REQ_FLAG_NEEDS_STATUS_HIDDEN }, 1),
// //     action_def_def(quote { ACTION_DEF_REQ_PROGRESS_MIN }, 4),
// //     action_def_def(quote { ACTION_DEF_REQ_PROGRESS_MAX }, 4),
// //     action_def_def(quote { ACTION_DEF_REQ_ENERGY }, 4),
// //     action_def_def(quote { ACTION_DEF_REQ_STATUS }, 4),
// //     action_def_def(quote { ACTION_DEF_REQ_MAX_RANGE }, 6),
// // ];

// // comptime fn action_def_serializer(f: FunctionDefinition) {
    
// // }

// // comptime fn derive_action_definition_trait(s: StructDefinition) -> Quoted {
// //     let struct_name = s.name();
// //     let mut bits: u32 = 0;
// //     let mut bytes: u32 = 0;
// //     let mut 
// //     quote {
// //         impl ResolvedAction for $struct_name {
// //             fn x() -> u32 { 234 }
// //         }
// //     }
// // }

// // #[derive_action_definition_trait]
// // pub struct ActionDefinition3 {}

// // // pub global ACTION_DEFINITION_REGISTER_SIZE: u32 = 5;
// // fn serialize_action_def(def: [Field]) -> 

// // comptime fn evaluate_action_def_req() {
// //     let mut result = "".as_ctstring();
// //     for i = 0..ACTION_DEF_DEF.len() {

// //     }
// // }

// // comptime fn build_action_def_requirements_struct(s: StructDefinition) {
// //     let mut fields: [(Quoted, Type)] = &[];
// //     for i in 0..ACTION_DEF_DEF.len() {
// //         fields.push_back((ACTION_DEF_DEF[i].0, u))
// //     }
// //     s.set_fields(fields);
// // }

// // struct ActionDefRequirements {};
// // comptime fn action_def_req(f: FunctionDefinition) {

// // }

// // comptime fn action_def_def(byte_offset: u16, bit_offset: u16, bit_size: u8) -> (u16, u16, u8) {
// //     (byte_offset, bit_offset, bit_size)
// // }
// // comptime global ACTION_DEF_DEF: [(u16, u16, u8); ACTION_DEF_FIELD_COUNT] = [
// //     action_def_def(0, 0, 1),
// //     action_def_def(0, 1, 1),
// //     action_def_def(0, 2, 1),
// //     action_def_def(0, 3, 1),
// //     action_def_def(0, 4, 1),
// //     action_def_def(0, 5, 1),
// //     action_def_def(0, 6, 1),
// //     action_def_def(0, 7, 1),
// //     action_def_def(1, 0, 4),
// //     action_def_def(1, 4, 1),
// //     action_def_def(2, 0, 1),
// //     action_def_def(3, 0, 1)
// // ]
// // global ACTION_REQUIREMENTS_FIELD_COUNT: u16 = 12;
// // comptime global ACTION_DEF_REQ_FLAG_NEEDS_TARGET_FREE_SPACE: u16 = 0;  // u1
// // comptime global ACTION_DEF_REQ_FLAG_NEEDS_TARGET_IS_NOT_SELF: u16 = 1; // u1
// // comptime global ACTION_DEF_REQ_FLAG_NEEDS_STATUS_VISIBLE: u16 = 2; // u1
// // comptime global ACTION_DEF_REQ_FLAG_NEEDS_STATUS_INVISIBLE: u16 = 3; // u1
// // comptime global ACTION_DEF_REQ_FLAG_NEEDS_STATUS_HIDDEN: u16 = 4; // u1
// // comptime global ACTION_DEF_REQ_FLAG_SETS_STATUS_HIDDEN: u16 = 5; // u1
// // comptime global ACTION_DEF_REQ_FLAG_REMOVES_STATUS_HIDDEN: u16 = 6; // u1
// // comptime global ACTION_DEF_REQ_FLAG_EVENT_IS_TRAP: u16 = 7; // u1
// // comptime global ACTION_DEF_REQ_PROGRESS_BYTE_IDX: u16 = ACTION_DEF_REQ_FLAGS_BYTE_IDX + 1;
// // global ACTION_DEF_REQ_PROGRESS_MIN_BIT_OFFSET: u16 = 0; // u4
// // global ACTION_DEF_REQ_PROGRESS_MAX_BIT_OFFSET: u16 = 4; // u4
// // global ACTION_DEF_REQ_ENERGY_STATUS_BYTE_IDX: u16 = ACTION_DEF_REQ_PROGRESS_BYTE_IDX + 1;
// // global ACTION_DEF_REQ_ENERGY_BIT_OFFSET: u16 = 0;    // u4
// // global ACTION_DEF_REQ_STATUS_BIT_OFFSET: u16 = 4; // u4
// // global ACTION_DEF_REQ_MAX_RANGE_BYTE_IDX: u16 = ACTION_DEF_REQ_ENERGY_STATUS_BYTE_IDX + 1; // u6 // TODO: max_range!
// // global ACTION_DEF_REQS_BYTE_SIZE: u16 = ACTION_DEF_REQ_MAX_RANGE_BYTE_IDX + 1;
// // 2 bit left!
// // global ACTION_REQUIREMENTS_FIELD_COUNT: u16 = 12;
// // ----------- 43 bytes ----------- 8 x 1 + 3 x 4 + ? = 26 - 28 = 3 bytes + 2 - 4 bit
// // comptime fn build_action_requirements_def(
// //     action_needs_target_free_space: u8,
// //     action_needs_target_is_not_self: u8,
// //     action_needs_status_visible: u8,
// //     action_needs_status_invisible: u8,
// //     action_needs_status_hidden: u8,
// //     action_sets_status_hidden: u8,
// //     action_removes_status_hidden: u8,
// //     action_max_range: u8,
// //     action_needs_min_status: u8,
// //     action_needs_max_status: u8,
// //     action_needed_energy: u8,
// //     action_event_is_trap: u8
// // ) -> CtString {
// //     assert(action_needs_target_free_space <= 1);
// //     assert(action_needs_target_is_not_self <= 1);
// //     assert(action_needs_status_visible <= 1);
// //     assert(action_needs_status_invisible <= 1);
// //     assert(action_needs_status_hidden <= 1);
// //     assert(action_sets_status_hidden <= 1);
// //     assert(action_removes_status_hidden <= 1);
// //     assert(action_needs_min_status <= MAX_STATUS);
// //     assert(action_needs_max_status <= MAX_STATUS);
// //     assert((action_sets_status_hidden == 0) | (action_removes_status_hidden == 0));
// //     assert(action_event_is_trap <= 1);
// //     f"{action_needs_target_free_space} as u8,{action_needs_target_is_not_self} as u8,{action_needs_status_visible} as u8,{action_needs_status_invisible} as u8,{action_needs_status_hidden} as u8,{action_sets_status_hidden} as u8,{action_removes_status_hidden} as u8,{action_max_range} as u8,{action_needs_min_status} as u8,{action_needs_max_status} as u8,{action_needed_energy} as u8,{action_event_is_trap} as u8".as_ctstring()
// // }

// // global ACTION_DEF_RESULT_EVENT_SEEN_BYTE_OFFSET: u16 = ACTION_DEF_REQS_BYTE_SIZE;
// // global ACTION_DEF_RESULT_EVENT_TYPE_BYTE_OFFSET: u16 =                    0;     // u4
// // global ACTION_DEF_RESULT_EVENT_SUBTYPE_BYTE_OFFSET: u16 =                 ACTION_DEF_RESULT_EVENT_TYPE_BYTE_OFFSET + 1; // u8
// // global ACTION_DEF_RESULT_EVENT_VALUE_BYTE_OFFSET: u16 =                   ACTION_DEF_RESULT_EVENT_SUBTYPE_BYTE_OFFSET + 1;
// // global ACTION_DEF_RESULT_EVENT_VALUE_FIXED_ADDITION_BIT_OFFSET: u16 =     0; // u4
// // global ACTION_DEF_RESULT_EVENT_VALUE_STATUS_MULTIPLIER_BIT_OFFSET: u16 =  4; // u2
// // global ACTION_DEF_RESULT_EVENT_COORD_IDX_BYTE_OFFSET: u16 =               ACTION_DEF_RESULT_EVENT_VALUE_BYTE_OFFSET;
// // global ACTION_DEF_RESULT_EVENT_COORD_IDX_BIT_OFFSET: u16 =                6; // u2
// // global ACTION_DEF_RESULT_EVENT_RADIUS_BYTE_OFFSET: u16 =                  ACTION_DEF_RESULT_EVENT_VALUE_BYTE_OFFSET + 1; // u6
// // global ACTION_DEF_RESULT_EVENT_BYTE_SIZE: u16 =                           ACTION_DEF_RESULT_EVENT_RADIUS_BYTE_OFFSET + 1;
// // global ACTION_DEF_RESULT_EVENT_UNSEEN_BYTE_OFFSET: u16 = ACTION_DEF_RESULT_EVENT_SEEN_BYTE_OFFSET + ACTION_DEF_RESULT_EVENT_BYTE_SIZE;
// // // global ACTION_RESULT_EVENT_FIELD_COUNT: u16 = 6; // u8
// // // ----------- 3-4 bytes ----------- 5

// // // pub global ACTION_RESULT_EVENT_NOT_SEEN_TYPE: u16 =                    ACTION_REQUIREMENTS_FIELD_COUNT + ACTION_RESULT_EVENT_FIELD_COUNT;     // u8
// // // pub global ACTION_RESULT_EVENT_NOT_SEEN_SUBTYPE: u16 =                 ACTION_REQUIREMENTS_FIELD_COUNT + ACTION_RESULT_EVENT_FIELD_COUNT + 1; // u8
// // // pub global ACTION_RESULT_EVENT_NOT_SEEN_VALUE_STATUS_MULTIPLIER: u16 = ACTION_REQUIREMENTS_FIELD_COUNT + ACTION_RESULT_EVENT_FIELD_COUNT + 2; // u4
// // // pub global ACTION_RESULT_EVENT_NOT_SEEN_VALUE_FIXED_ADDITION: u16 =    ACTION_REQUIREMENTS_FIELD_COUNT + ACTION_RESULT_EVENT_FIELD_COUNT + 3; // u8
// // // pub global ACTION_RESULT_EVENT_NOT_SEEN_COORD_IDX: u16 =               ACTION_REQUIREMENTS_FIELD_COUNT + ACTION_RESULT_EVENT_FIELD_COUNT + 4; // u2
// // // pub global ACTION_RESULT_EVENT_NOT_SEEN_RADIUS: u16 =                  ACTION_REQUIREMENTS_FIELD_COUNT + ACTION_RESULT_EVENT_FIELD_COUNT + 5; // u8
// // // ----------- 3-4 bytes ----------- 5
// // comptime fn build_action_event_def(
// //     event_type: u8,
// //     event_subtype: u8,
// //     event_value_status_multiplier: u8,
// //     event_value_fixed_addition: u8,
// //     event_coord_idx: u8,
// //     event_radius: u8
// // ) -> CtString {
// //     assert(event_type < EVENT_COUNT);
// //     assert(event_subtype as u32 < ACTION_COUNT);
// //     assert(event_value_status_multiplier < (PROGRESS_COUNT / 2));
// //     // assert(event_value_fixed_addition < MAX_STATUS);
// //     assert(event_coord_idx < 4);
// //     f"{event_type} as u8,{event_subtype} as u8,{event_value_status_multiplier} as u8,{event_value_fixed_addition} as u8,{event_coord_idx} as u8, {event_radius} as u8".as_ctstring()
// // }

// // global ACTION_DEF_RESULT_EFFECTS_BYTE_OFFSET: u16 = ACTION_DEF_REQS_BYTE_SIZE + 2 * ACTION_DEF_RESULT_EVENT_BYTE_SIZE;
// // global ACTION_DEF_RESULT_EFFECT_STATUS_MOD_BYTE_OFFSET: u16 = 0;
// // global ACTION_DEF_RESULT_EFFECT_STATUS_FIXED_ADDITION_BIT_OFFSET: u16 = 0;
// // global ACTION_DEF_RESULT_EFFECT_STATUS_FIXED_ADDITION_BIT_SIZE: u16 = 4;
// // global ACTION_DEF_RESULT_EFFECT_STATUS_FIXED_ADDITION_BITMASK: u8 = (2 as u16 ^ ACTION_DEF_RESULT_EFFECT_STATUS_FIXED_ADDITION_BIT_SIZE )
// // global ACTION_DEF_RESULT_EFFECT_STATUS_MULTIPLIER_BIT_OFFSET: u16 = 4;
// // global ACTION_DEF_RESULT_EFFECT_MOVE_TO_TARGET_BYTE_OFFSET: u16 = ACTION_DEF_RESULT_EFFECT_STATUS_MULTIPLIER_BYTE_OFFSET;
// // global ACTION_DEF_RESULT_EFFECT_MOVE_TO_TARGET_FLAG: u16 = 2 ^ 
// // // pub global ACTION_RESULT_STATUS_MULTIPLIER: u16 =     ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT;     // u2
// // // pub global ACTION_RESULT_STATUS_FIXED_ADDITION: u16 = ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT + 1; // u4
// // // pub global ACTION_MOVE_TO_TARGET: u16 =               ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT + 2; // u1
// // // pub global ACTION_IS_CONTINUOUS: u16 =                ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT + 3; // u1
// // // pub global ACTION_NEEDS_PREVIOUS_ACTION: u16 =        ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT + 4; // u4
// // // ----------- 2 bytes ----------- 4
// // // => 2 Fields per Character
// // // 8 * u1 + 8 * u4 + 5 * u8 = 8 + 32 + 40 = 80 => 10 bytes => 3 / Field => WAIT is static => 2 Fields per Character
// // // 3.5 + 1.5 = 5 bytes + 2 * 4 = 8 bytes = 13 bytes = 2 actions / Field
// pub global ACTION_RESULT_COORDINATES_IDX_SELF: u8 = 0; // u2
// pub global ACTION_RESULT_COORDINATES_IDX_TARGET: u8 = 1; // u2
// pub global ACTION_RESULT_COORDINATES_IDX_INVISIBLE: u8 = 2; // u2

// // comptime fn build_action_def(
// //     requirements: CtString,
// //     event_seen: CtString,
// //     event_not_seen: CtString,
// //     status_multiplier: u8,
// //     status_fixed_addition: u8,
// //     move_to_target: u8,
// //     is_continuous: u8,
// //     previous_action: u8
// // ) -> CtString {
// //     assert(status_multiplier < 4);
// //     assert(status_fixed_addition < 16);
// //     assert(move_to_target < 2);
// //     assert(is_continuous < 2);
// //     assert(previous_action < 16);
// //     f"{requirements},{event_seen},{event_not_seen},{status_multiplier} as u8,{status_fixed_addition} as u8,{move_to_target} as u8,{is_continuous} as u8,{previous_action} as u8".as_ctstring()
// // }
// // pub comptime fn build_test_action_def(
// //     def: CtString,
// //     action_args: Quoted,
// // ) -> Quoted {
// //     let result: Quoted = f"TestActionDefinition {{ register: [{def}], action: new_action({action_args}) }}".quoted_contents();
// //     result
// // }
// // pub comptime fn build_action_def_reg(
// //     action_defs: [[CtString; MAX_ACTIONS_PER_CHARACTER - 1]; MAX_CHARACTERS]
// // ) -> Quoted {
// //     let elements: [CtString; MAX_CHARACTERS] = action_defs.map(|x|x.reduce(|acc, cur|f"{acc},{cur}".as_ctstring()));
// //     let joined = elements.reduce(|acc,cur|f"{acc},{cur}".as_ctstring());
// //     let wait_action = build_wait_action_def();
// //     f"[{wait_action},{joined}]".quoted_contents()
// // }

// global YES: u8 = 1;
// global NO: u8 = 0;
// global MIN_STATUS: u8 = 0;
// global MAX_STATUS: u8 = 15;

// // pub type ActionDefinitionRegister = 
// pub fn build_action_def_requirements_none() -> ActionRequirement {
//   build_action_def_requirements(
//     NO as u1,
//     NO as u1,
//     NO as u1,
//     NO as u1,
//     NO as u1,
//     MIN_STATUS,
//     MAX_STATUS,
//     0 as u8,
//     255 as u8)
// }
// pub fn build_action_def_pre_calc_effects_idle() -> ActionPreCalcEffect {
//   build_action_def_pre_calc_effect(
//     WAIT,
//     NO as u1,
//     NO as u1,
//     NO as u1)
// }
// // comptime fn no_requirements() -> CtString {
// //     build_action_requirements_def(
// //         NO as u1,
// //         NO as u1, 
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         255 as u8,
// //         MIN_STATUS,
// //         MAX_STATUS,
// //         0 as u8,
// //         NO as u1)
// // }
// pub fn build_action_def_result_event_none() -> ActionResultEvent {
//   build_action_def_result_event(
//     0,
//     0,
//     ACTION_RESULT_COORDINATES_IDX_INVISIBLE,
//     NO_EVENT,
//     NO_EVENT,
//     0 as u8
//   )
// }
// // comptime fn no_event() -> CtString {
// //     build_action_event_def(NO_EVENT, NO_EVENT, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_INVISIBLE, 0 as u8)
// // }
// pub fn build_wait_action_def() -> ActionDefinition {
//   build_action_definition(
//     build_action_def_requirements_none(),
//     build_action_def_pre_calc_effects_idle(),
//     build_action_def_result_effects(
//       0 as u8,
//       0 as u8,
//       1 as u8,
//       NO as u1,
//       NO as u1,
//       NO as u1),
//     [
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none()
//     ])
// }
// // pub comptime fn build_wait_action_def() -> CtString {
// //     build_action_def(
// //         no_requirements(),
// //         no_event(),
// //         no_event(),
// //         1 as u8,
// //         0 as u8,
// //         ACTION_RESULT_COORDINATES_IDX_SELF,
// //         NO as u1,
// //         WAIT
// //     )
// // }
// // pub global WAIT_ACTION: ActionDefinition = comptime { let x = build_wait_action_def(); f"[{x}]".quoted_contents() };
// pub fn build_sneak_action(energy: u8) -> ActionDefinition {
//   build_action_definition(
//     build_action_def_requirements(
//       YES as u1,
//       NO as u1,
//       NO as u1,
//       YES as u1,
//       NO as u1,
//       MIN_STATUS,
//       MAX_STATUS,
//       0 as u8,
//       1 as u8),
//     build_action_def_pre_calc_effect(
//       0,
//       NO as u1,
//       YES as u1,
//       YES as u1),
//     build_action_def_result_effects(
//       energy,
//       0 as u8,
//       0 as u8,
//       ACTION_RESULT_COORDINATES_IDX_TARGET as u1,
//       YES as u1,
//       NO as u1),
//     [
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none()
//     ])
// }
// // pub comptime fn build_sneak_action(energy: u8) -> CtString { build_action_def(
// //     build_action_requirements_def(
// //         YES as u1,
// //         NO as u1,
// //         NO as u1,
// //         YES as u1,
// //         NO as u1,
// //         YES as u1,
// //         NO as u1,
// //         1 as u8,
// //         MIN_STATUS,
// //         MAX_STATUS,
// //         energy,
// //         NO as u1),
// //     no_event(), // TODO: not sure if on-seen we should not send a move event instead - that way one could sneak and stay hidden, but not sneak while visible
// //     no_event(),
// //     0 as u8,
// //     0 as u8,
// //     ACTION_RESULT_COORDINATES_IDX_TARGET,
// //     NO as u1,
// //     WAIT)
// // }
// pub fn build_move_action(energy: u8) -> ActionDefinition {
//   build_action_definition(
//     build_action_def_requirements(
//       YES as u1,
//       YES as u1,
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       MIN_STATUS,
//       MAX_STATUS,
//       0,
//       1),
//     build_action_def_pre_calc_effect(
//       0,
//       NO as u1,
//       YES as u1,
//       YES as u1),
//     build_action_def_result_effects(
//       energy,
//       0,
//       0,
//       ACTION_RESULT_COORDINATES_IDX_TARGET as u1,
//       NO as u1,
//       YES as u1),
//     [
//       build_action_def_result_event_none(),
//       build_action_def_result_event(
//         0,
//         0,
//         ACTION_RESULT_COORDINATES_IDX_TARGET,
//         SEE_MOVE,
//         0,
//         0),
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none()
//     ])
// }
// // pub comptime fn build_move_action(energy: u8) -> CtString { build_action_def(
// //     build_action_requirements_def(
// //         YES as u1,
// //         YES as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         YES as u1,
// //         1 as u8,
// //         MIN_STATUS,
// //         MAX_STATUS,
// //         energy,
// //         NO as u1),
// //     build_action_event_def(SEE_MOVE, NO as u1, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
// //     no_event(),
// //     0 as u8,
// //     0 as u8,
// //     ACTION_RESULT_COORDINATES_IDX_TARGET,
// //     NO as u1,
// //     WAIT)
// // }
// pub fn build_cast_action(this_action_id: u8, energy: u8, class: u8, range: u8) -> ActionDefinition {
//   build_action_definition(
//     build_action_def_requirements(
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       MIN_STATUS,
//       MAX_STATUS,
//       0,
//       range),
//     build_action_def_pre_calc_effect(
//       this_action_id,
//       YES as u1,
//       YES as u1,
//       NO as u1),
//     build_action_def_result_effects(
//       energy,
//       1,
//       1,
//       ACTION_RESULT_COORDINATES_IDX_SELF as u1,
//       NO as u1,
//       YES as u1),
//     [
//       build_action_def_result_event_none(),
//       build_action_def_result_event(
//         0,
//         0,
//         ACTION_RESULT_COORDINATES_IDX_SELF,
//         SEE_CAST,
//         class,
//         0),
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none()
//     ])
// }
// // pub comptime fn build_cast_action(this_action_id: u8, energy: u8, class: u8) -> CtString { build_action_def(
// //     build_action_requirements_def(
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         YES as u1,
// //         255 as u8,
// //         MIN_STATUS,
// //         MAX_STATUS,
// //         energy,
// //         NO as u1),
// //     build_action_event_def(SEE_CAST, class, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_SELF, 0 as u8),
// //     no_event(),
// //     1 as u8,
// //     1 as u8,
// //     ACTION_RESULT_COORDINATES_IDX_SELF,
// //     YES as u1,
// //     this_action_id)
// // }
// pub fn build_ritual_action(cast_action_id: u8, energy: u8) -> ActionDefinition {
//   build_action_definition(
//     build_action_def_requirements(
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       RITUAL_ROUNDS_FOR_WIN,
//       MAX_STATUS,
//       0,
//       255),
//     build_action_def_pre_calc_effect(
//       cast_action_id,
//       YES as u1,
//       YES as u1,
//       NO as u1),
//     build_action_def_result_effects(
//       energy,
//       1,
//       1,
//       ACTION_RESULT_COORDINATES_IDX_SELF as u1,
//       NO as u1,
//       YES as u1),
//     [
//       build_action_def_result_event(
//         0,
//         0,
//         ACTION_RESULT_COORDINATES_IDX_INVISIBLE,
//         WIN,
//         WIN_BY_RITUAL,
//         255),
//       build_action_def_result_event(
//         0,
//         0,
//         ACTION_RESULT_COORDINATES_IDX_SELF,
//         WIN,
//         WIN_BY_RITUAL,
//         255),
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none()
//     ])
// }
// // pub comptime fn build_ritual_action(this_action_id: u8, energy: u8) -> CtString { build_action_def(
// //     build_action_requirements_def(
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         YES as u1,
// //         255 as u8,
// //         RITUAL_ROUNDS_FOR_WIN,
// //         MAX_STATUS,
// //         energy,
// //         NO as u1),
// //     build_action_event_def(WIN, WIN_BY_RITUAL, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_SELF, 255 as u8),
// //     build_action_event_def(WIN, WIN_BY_RITUAL, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_INVISIBLE, 255 as u8),
// //     0 as u8,
// //     0 as u8,
// //     ACTION_RESULT_COORDINATES_IDX_SELF,
// //     YES as u1,
// //     this_action_id)
// // }
// pub fn build_evocation_action(cast_action_id: u8, energy: u8, evocation_type: u8, range: u8, radius: u8, damage: u8, damage_upcast: u8, min_cast_time: u8, max_cast_time: u8) -> ActionDefinition {
//   build_action_definition(
//     build_action_def_requirements(
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       min_cast_time,
//       max_cast_time,
//       0,
//       range),
//     build_action_def_pre_calc_effect(
//       cast_action_id,
//       YES as u1,
//       YES as u1,
//       NO as u1),
//     build_action_def_result_effects(
//       energy,
//       1,
//       1,
//       ACTION_RESULT_COORDINATES_IDX_SELF as u1,
//       NO as u1,
//       YES as u1),
//     [
//       build_action_def_result_event(
//         damage,
//         damage_upcast,
//         ACTION_RESULT_COORDINATES_IDX_TARGET,
//         RECEIVE_ATTACK,
//         evocation_type,
//         radius),
//       build_action_def_result_event(
//         damage,
//         damage_upcast,
//         ACTION_RESULT_COORDINATES_IDX_TARGET,
//         RECEIVE_ATTACK,
//         evocation_type,
//         radius),
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none()
//     ])
// }
// // pub comptime fn build_evocation_action(cast_action_id: u8, energy: u8, evocation_type: u8, range: u8, radius: u8, damage: u8, damage_upcast: u8, min_cast_time: u8, max_cast_time: u8) -> CtString { build_action_def(
// //     build_action_requirements_def(
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         YES as u1,
// //         range,
// //         min_cast_time,
// //         max_cast_time,
// //         energy,
// //         NO as u1), // TODO: Maybe set this to handle friendly fire???
// //     build_action_event_def(RECEIVE_ATTACK, evocation_type, damage_upcast, damage, ACTION_RESULT_COORDINATES_IDX_TARGET, radius),
// //     build_action_event_def(RECEIVE_ATTACK, evocation_type, damage_upcast, damage, ACTION_RESULT_COORDINATES_IDX_TARGET, radius),
// //     0 as u8,
// //     0 as u8,
// //     ACTION_RESULT_COORDINATES_IDX_SELF,
// //     YES as u1,
// //     cast_action_id)
// // }
// pub fn build_search_action(energy: u8, range: u8) -> ActionDefinition {
//   build_action_definition(
//     build_action_def_requirements(
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       MIN_STATUS,
//       MAX_STATUS,
//       0,
//       range),
//     build_action_def_pre_calc_effect(
//       0,
//       NO as u1,
//       YES as u1,
//       NO as u1),
//     build_action_def_result_effects(
//       energy,
//       0,
//       0,
//       ACTION_RESULT_COORDINATES_IDX_SELF as u1,
//       NO as u1,
//       YES as u1),
//     [
//       build_action_def_result_event(
//         0,
//         0,
//         ACTION_RESULT_COORDINATES_IDX_TARGET,
//         SEE_SEARCH_TRAP,
//         0,
//         1),
//       build_action_def_result_event(
//         0,
//         0,
//         ACTION_RESULT_COORDINATES_IDX_TARGET,
//         SEE_SEARCH_TRAP,
//         0,
//         1),
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none()
//     ])
// }
// // pub comptime fn build_search_action(energy: u8, range: u8) -> CtString { build_action_def(
// //     build_action_requirements_def(
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         range,
// //         MIN_STATUS,
// //         MAX_STATUS,
// //         energy,
// //         NO as u1),
// //     build_action_event_def(SEE_SEARCH_TRAP, NO as u1, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_TARGET, 1 as u8),
// //     build_action_event_def(SEE_SEARCH_TRAP, NO as u1, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_TARGET, 1 as u8),
// //     0 as u8,
// //     0 as u8,
// //     ACTION_RESULT_COORDINATES_IDX_SELF,
// //     NO as u1,
// //     WAIT)
// // }
// pub fn build_attack_action(energy: u8, damage_type: u8, range: u8, damage: u8) -> ActionDefinition {
//   build_action_definition(
//     build_action_def_requirements(
//       NO as u1,
//       YES as u1,
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       MIN_STATUS,
//       MAX_STATUS,
//       0,
//       range),
//     build_action_def_pre_calc_effect(
//       0,
//       NO as u1,
//       YES as u1,
//       NO as u1),
//     build_action_def_result_effects(
//       energy,
//       0,
//       0,
//       ACTION_RESULT_COORDINATES_IDX_SELF as u1,
//       NO as u1,
//       YES as u1),
//     [
//       build_action_def_result_event(
//         damage,
//         0,
//         ACTION_RESULT_COORDINATES_IDX_TARGET,
//         RECEIVE_ATTACK,
//         damage_type,
//         0),
//       build_action_def_result_event(
//         damage,
//         0,
//         ACTION_RESULT_COORDINATES_IDX_TARGET,
//         RECEIVE_ATTACK,
//         damage_type,
//         0),
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none()
//     ])
// }
// // pub comptime fn build_attack_action(energy: u8, damage_type: u8, range: u8, damage: u8) -> CtString { build_action_def(
// //     build_action_requirements_def(
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         YES as u1,
// //         range,
// //         MIN_STATUS,
// //         MAX_STATUS,
// //         energy,
// //         NO as u1),
// //     build_action_event_def(RECEIVE_ATTACK, damage_type, 0 as u8, damage, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
// //     build_action_event_def(RECEIVE_ATTACK, damage_type, 0 as u8, damage, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
// //     0 as u8,
// //     0 as u8,
// //     ACTION_RESULT_COORDINATES_IDX_SELF,
// //     NO as u1,
// //     WAIT)
// // }
// pub fn build_draw_action(this_action_id: u8, energy: u8, range: u8, class: u8) -> ActionDefinition {
//   build_action_definition(
//     build_action_def_requirements(
//       NO as u1,
//       YES as u1,
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       MIN_STATUS,
//       MAX_STATUS, // should be max of shoot
//       0,
//       range),
//     build_action_def_pre_calc_effect(
//       this_action_id,
//       YES as u1,
//       YES as u1,
//       YES as u1),
//     build_action_def_result_effects(
//       energy,
//       1,
//       1,
//       ACTION_RESULT_COORDINATES_IDX_SELF as u1,
//       NO as u1,
//       NO as u1),
//     [
//       build_action_def_result_event_none(),
//       build_action_def_result_event(
//         0,
//         0,
//         ACTION_RESULT_COORDINATES_IDX_SELF,
//         SEE_DRAW,
//         class,
//         0),
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none()
//     ])
// }
// // pub comptime fn build_draw_action(this_action_id: u8, energy: u8, range: u8, class: u8) -> CtString { build_action_def(
// //     build_action_requirements_def(
// //         NO as u1,
// //         YES as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         range,
// //         MIN_STATUS,
// //         MAX_STATUS,
// //         energy,
// //         NO as u1),
// //     build_action_event_def(SEE_DRAW, class, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_SELF, 0 as u8),
// //     no_event(),
// //     1 as u8,
// //     1 as u8,
// //     ACTION_RESULT_COORDINATES_IDX_SELF,
// //     YES as u1,
// //     this_action_id)
// // }
// pub fn build_shoot_action(draw_action_id: u8, energy: u8, damage_type: u8, range: u8, damage: u8, damage_upcast: u8, min_cast_time: u8, max_cast_time: u8) -> ActionDefinition {
//   build_action_definition(
//     build_action_def_requirements(
//       NO as u1,
//       YES as u1,
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       min_cast_time,
//       max_cast_time,
//       0,
//       range),
//     build_action_def_pre_calc_effect(
//       draw_action_id,
//       YES as u1,
//       YES as u1,
//       NO as u1),
//     build_action_def_result_effects(
//       energy,
//       1,
//       1,
//       ACTION_RESULT_COORDINATES_IDX_SELF as u1,
//       NO as u1,
//       YES as u1),
//     [
//       build_action_def_result_event(
//         damage,
//         damage_upcast,
//         ACTION_RESULT_COORDINATES_IDX_TARGET,
//         RECEIVE_ATTACK,
//         damage_type,
//         0),
//       build_action_def_result_event(
//         damage,
//         damage_upcast,
//         ACTION_RESULT_COORDINATES_IDX_TARGET,
//         RECEIVE_ATTACK,
//         damage_type,
//         0),
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none()
//     ])
// }
// // pub comptime fn build_shoot_action(draw_action_id: u8, energy: u8, damage_type: u8, range: u8, damage: u8, damage_upcast: u8, min_cast_time: u8, max_cast_time: u8) -> CtString { build_action_def(
// //     build_action_requirements_def(
// //         NO as u1,
// //         YES as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         YES as u1,
// //         range,
// //         min_cast_time,
// //         max_cast_time,
// //         energy,
// //         NO as u1),
// //     build_action_event_def(RECEIVE_ATTACK, damage_type, damage_upcast, damage, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
// //     build_action_event_def(RECEIVE_ATTACK, damage_type, damage_upcast, damage, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
// //     0 as u8,
// //     0 as u8,
// //     ACTION_RESULT_COORDINATES_IDX_SELF,
// //     YES as u1,
// //     draw_action_id)
// // }
// pub fn build_disarm_trap_action(energy: u8, range: u8) -> ActionDefinition {
//   build_action_definition(
//     build_action_def_requirements(
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       NO as u1,
//       MIN_STATUS,
//       MAX_STATUS,
//       0,
//       range),
//     build_action_def_pre_calc_effect(
//       0,
//       NO as u1,
//       YES as u1,
//       YES as u1),
//     build_action_def_result_effects(
//       energy,
//       1,
//       1,
//       ACTION_RESULT_COORDINATES_IDX_SELF as u1,
//       NO as u1,
//       NO as u1),
//     [
//       build_action_def_result_event(
//         0,
//         0,
//         ACTION_RESULT_COORDINATES_IDX_TARGET,
//         DISARMED_TRAP,
//         0,
//         0),
//       build_action_def_result_event(
//         0,
//         0,
//         ACTION_RESULT_COORDINATES_IDX_TARGET,
//         DISARMED_TRAP,
//         0,
//         0),
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none()
//     ])
// }
// // pub comptime fn build_disarm_trap_action(energy: u8, range: u8) -> CtString { build_action_def(
// //     build_action_requirements_def(
// //         NO as u1,
// //         YES as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         range,
// //         MIN_STATUS,
// //         MAX_STATUS,
// //         energy,
// //         NO as u1),
// //     build_action_event_def(DISARMED_TRAP, NO as u1, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
// //     build_action_event_def(DISARMED_TRAP, NO as u1, 0 as u8, 0 as u8, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
// //     0 as u8,
// //     0 as u8,
// //     ACTION_RESULT_COORDINATES_IDX_SELF,
// //     NO as u1,
// //     WAIT)
// // }
// pub fn build_set_trap_action(energy: u8, range: u8) -> ActionDefinition {
//   build_action_definition(
//     build_action_def_requirements(
//       YES as u1,
//       YES as u1,
//       NO as u1,
//       YES as u1,
//       NO as u1,
//       MIN_STATUS,
//       MAX_STATUS,
//       0,
//       range),
//     build_action_def_pre_calc_effect(
//       0,
//       NO as u1,
//       YES as u1,
//       NO as u1),
//     build_action_def_result_effects(
//       energy,
//       0,
//       0,
//       ACTION_RESULT_COORDINATES_IDX_SELF as u1,
//       NO as u1,
//       NO as u1),
//     [
//       build_action_def_result_event_none(),
//       build_action_def_result_event_none(),
//       build_action_def_result_event(
//         0,
//         0,
//         ACTION_RESULT_COORDINATES_IDX_TARGET,
//         ADD_OBSTACLE,
//         TRAP,
//         0),
//       build_action_def_result_event_none()
//     ])
// }
// // pub comptime fn build_set_trap_action(energy: u8, range: u8) -> CtString { build_action_def(
// //     build_action_requirements_def(
// //         YES as u1,
// //         NO as u1,
// //         NO as u1,
// //         YES as u1,
// //         NO as u1,
// //         NO as u1,
// //         NO as u1,
// //         range,
// //         MIN_STATUS,
// //         MAX_STATUS,
// //         energy,
// //         YES as u1),
// //     no_event(),
// //     build_action_event_def(ADD_OBSTACLE, TRAP, 0 as u8, 50 as u8, ACTION_RESULT_COORDINATES_IDX_TARGET, 0 as u8),
// //     0 as u8,
// //     0 as u8,
// //     ACTION_RESULT_COORDINATES_IDX_SELF,
// //     NO as u1,
// //     WAIT)
// // }

// // pub fn get_action_base_index(actor_id: u8, action_idx: u8) -> u16 {
// //     if (action_idx == 0) | (action_idx as u32 >= MAX_ACTIONS_PER_CHARACTER) | (actor_id as u32 >= MAX_CHARACTERS) {
// //         0 as u16
// //     } else {
// //         (actor_id as u16 * (MAX_ACTIONS_PER_CHARACTER - 1) as u16 + action_idx as u16) * ACTION_DEFINITION_SIZE as u16
// //     }
// // }

// // fn get_action_needs_target_free_space(action: ActionDefinition) -> bool {
// //     action.register[action.base_index + ACTION_NEEDS_TARGET_FREE_SPACE] == 1
// // }
// // fn get_action_needs_target_is_not_self(action: ActionDefinition) -> bool {
// //     action.register[action.base_index + ACTION_NEEDS_TARGET_IS_NOT_SELF] == 1
// // }
// // fn get_action_needs_status_visible(action: ActionDefinition) -> bool {
// //     action.register[action.base_index + ACTION_NEEDS_STATUS_VISIBLE] == 1
// // }
// // fn get_action_needs_status_invisible(action: ActionDefinition) -> bool {
// //     action.register[action.base_index + ACTION_NEEDS_STATUS_INVISIBLE] == 1
// // }
// // fn get_action_needs_status_hidden(action: ActionDefinition) -> bool {
// //     action.register[action.base_index + ACTION_NEEDS_STATUS_HIDDEN] == 1
// // }
// // fn get_action_sets_status_hidden(action: ActionDefinition) -> bool {
// //     action.register[action.base_index + ACTION_SETS_STATUS_HIDDEN] == 1
// // }
// // fn get_action_removes_status_hidden(action: ActionDefinition) -> bool {
// //     action.register[action.base_index + ACTION_REMOVES_STATUS_HIDDEN] == 1
// // }
// // fn get_action_max_range(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_MAX_RANGE]
// // }
// // fn get_action_needs_min_status(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_NEEDS_MIN_STATUS]
// // }
// // fn get_action_needs_max_status(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_NEEDS_MAX_STATUS]
// // }
// // fn get_action_needed_energy(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_NEEDED_ENERGY]
// // }
// // fn get_action_unseen_event_is_internal(action: ActionDefinition) -> bool {
// //     action.register[action.base_index + ACTION_EVENT_IS_TRAP] == 1
// // }
// // fn get_action_result_event_seen_type(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_RESULT_EVENT_SEEN_TYPE]
// // }
// // fn get_action_result_event_seen_subtype(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_RESULT_EVENT_SEEN_SUBTYPE]
// // }
// // fn get_action_result_event_seen_value_status_multiplier(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_RESULT_EVENT_SEEN_VALUE_STATUS_MULTIPLIER]
// // }
// // fn get_action_result_event_seen_value_fixed_addition(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_RESULT_EVENT_SEEN_VALUE_FIXED_ADDITION]
// // }
// // fn get_action_result_event_seen_coord_idx(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_RESULT_EVENT_SEEN_COORD_IDX]
// // }
// // fn get_action_result_event_seen_radius(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_RESULT_EVENT_SEEN_RADIUS]
// // }
// // fn get_action_result_event_not_seen_type(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_RESULT_EVENT_NOT_SEEN_TYPE]
// // }
// // fn get_action_result_event_not_seen_subtype(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_RESULT_EVENT_NOT_SEEN_SUBTYPE]
// // }
// // fn get_action_result_event_not_seen_value_status_multiplier(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_RESULT_EVENT_NOT_SEEN_VALUE_STATUS_MULTIPLIER]
// // }
// // fn get_action_result_event_not_seen_value_fixed_addition(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_RESULT_EVENT_NOT_SEEN_VALUE_FIXED_ADDITION]
// // }
// // fn get_action_result_event_not_seen_coord_idx(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_RESULT_EVENT_NOT_SEEN_COORD_IDX]
// // }
// // fn get_action_result_event_not_seen_radius(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_RESULT_EVENT_NOT_SEEN_RADIUS]
// // }
// // fn get_action_result_status_multiplier(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_RESULT_STATUS_MULTIPLIER]
// // }
// // fn get_action_result_status_fixed_addition(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_RESULT_STATUS_FIXED_ADDITION]
// // }
// // fn get_action_move_to_target(action: ActionDefinition) -> u1 {
// //     action.register[action.base_index + ACTION_MOVE_TO_TARGET] as u1
// // }
// // fn get_action_is_continuous(action: ActionDefinition) -> bool {
// //     action.register[action.base_index + ACTION_IS_CONTINUOUS] == 1
// // }
// // fn get_action_needs_previous_action(action: ActionDefinition) -> u8 {
// //     action.register[action.base_index + ACTION_NEEDS_PREVIOUS_ACTION] as u8
// // }

// // pub global ACTION_DEFINITION_SIZE: u32 = (ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT + 5) as u32; // 2 bytes for move_to_target and status_multiplier
// // pub global ACTION_DEFINITION_REGISTER_SIZE: u32 = ACTION_DEFINITION_SIZE * (1 + (MAX_ACTIONS_PER_CHARACTER - 1) * (CLASS_COUNT - 1));

// // fn get_action_base_index(actor_id: u8, action_idx: u8) -> u16 {
// //     if (action_idx == 0) | (action_idx as u32 >= MAX_ACTIONS_PER_CHARACTER) | (actor_id as u32 >= MAX_CHARACTERS) {
// //         0 as u16
// //     } else {
// //         (actor_id as u16 * (MAX_ACTIONS_PER_CHARACTER - 1) as u16 + action_idx as u16) * ACTION_DEFINITION_SIZE as u16
// //     }
// // }

// // pub struct ActionDefinitionRegister {
// //   register: [u8; ACTION_DEFINITION_REGISTER_SIZE]
// // }

// // impl ActionDefinitionRegister {
// //   pub fn new(register: [u8; ACTION_DEFINITION_REGISTER_SIZE]) -> ActionDefinitionRegister {
// //     ActionDefinitionRegister {
// //       register: register
// //     }
// //   }

// //   pub fn resolve_action(self, action: Action) -> ActionDefinition {
// //     ActionDefinition {
// //       base_index: get_action_base_index(get_action_actor(action), get_action_type(action)),
// //       action: action,
// //       register: self.register
// //     }
// //   }
// // }

// // pub struct ActionDefinition {
// //     base_index: u16,
// //     action: Action,
// //     register: [u8; ACTION_DEFINITION_REGISTER_SIZE]
// // }

// // impl ActionDefinition {
// //     pub fn new(action: Action, register: [u8; ACTION_DEFINITION_REGISTER_SIZE]) -> ActionDefinition {
// //         ActionDefinition {
// //             base_index: get_action_base_index(get_action_actor(action), get_action_type(action)),
// //             action: action,
// //             register: register
// //         }
// //     }
// // }

// // impl ResolvedAction for ActionDefinition {
// //     fn get_action_needs_target_free_space(self: ActionDefinition) -> bool {
// //         self.register[self.base_index + ACTION_NEEDS_TARGET_FREE_SPACE] == 1
// //     }
// //     fn get_action_needs_target_is_not_self(self: ActionDefinition) -> bool {
// //         self.register[self.base_index + ACTION_NEEDS_TARGET_IS_NOT_SELF] == 1
// //     }
// //     fn get_action_needs_status_visible(self: ActionDefinition) -> bool {
// //         self.register[self.base_index + ACTION_NEEDS_STATUS_VISIBLE] == 1
// //     }
// //     fn get_action_needs_status_invisible(self: ActionDefinition) -> bool {
// //         self.register[self.base_index + ACTION_NEEDS_STATUS_INVISIBLE] == 1
// //     }
// //     fn get_action_needs_status_hidden(self: ActionDefinition) -> bool {
// //         self.register[self.base_index + ACTION_NEEDS_STATUS_HIDDEN] == 1
// //     }
// //     fn get_action_sets_status_hidden(self: ActionDefinition) -> bool {
// //         self.register[self.base_index + ACTION_SETS_STATUS_HIDDEN] == 1
// //     }
// //     fn get_action_removes_status_hidden(self: ActionDefinition) -> bool {
// //         self.register[self.base_index + ACTION_REMOVES_STATUS_HIDDEN] == 1
// //     }
// //     fn get_action_max_range(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_MAX_RANGE]
// //     }
// //     fn get_action_needs_min_status(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_NEEDS_MIN_STATUS]
// //     }
// //     fn get_action_needs_max_status(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_NEEDS_MAX_STATUS]
// //     }
// //     fn get_action_needed_energy(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_NEEDED_ENERGY]
// //     }
// //     fn get_action_unseen_event_is_internal(self: ActionDefinition) -> bool {
// //         self.register[self.base_index + ACTION_EVENT_IS_TRAP] == 1
// //     }
// //     fn get_action_result_event_seen_type(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_RESULT_EVENT_SEEN_TYPE]
// //     }
// //     fn get_action_result_event_seen_subtype(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_RESULT_EVENT_SEEN_SUBTYPE]
// //     }
// //     fn get_action_result_event_seen_value_status_multiplier(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_RESULT_EVENT_SEEN_VALUE_STATUS_MULTIPLIER]
// //     }
// //     fn get_action_result_event_seen_value_fixed_addition(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_RESULT_EVENT_SEEN_VALUE_FIXED_ADDITION]
// //     }
// //     fn get_action_result_event_seen_coord_idx(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_RESULT_EVENT_SEEN_COORD_IDX]
// //     }
// //     fn get_action_result_event_seen_radius(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_RESULT_EVENT_SEEN_RADIUS]
// //     }
// //     fn get_action_result_event_not_seen_type(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_RESULT_EVENT_NOT_SEEN_TYPE]
// //     }
// //     fn get_action_result_event_not_seen_subtype(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_RESULT_EVENT_NOT_SEEN_SUBTYPE]
// //     }
// //     fn get_action_result_event_not_seen_value_status_multiplier(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_RESULT_EVENT_NOT_SEEN_VALUE_STATUS_MULTIPLIER]
// //     }
// //     fn get_action_result_event_not_seen_value_fixed_addition(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_RESULT_EVENT_NOT_SEEN_VALUE_FIXED_ADDITION]
// //     }
// //     fn get_action_result_event_not_seen_coord_idx(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_RESULT_EVENT_NOT_SEEN_COORD_IDX]
// //     }
// //     fn get_action_result_event_not_seen_radius(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_RESULT_EVENT_NOT_SEEN_RADIUS]
// //     }
// //     fn get_action_result_status_multiplier(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_RESULT_STATUS_MULTIPLIER]
// //     }
// //     fn get_action_result_status_fixed_addition(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_RESULT_STATUS_FIXED_ADDITION]
// //     }
// //     fn get_action_move_to_target(self: ActionDefinition) -> u1 {
// //         self.register[self.base_index + ACTION_MOVE_TO_TARGET] as u1
// //     }
// //     fn get_action_is_continuous(self: ActionDefinition) -> bool {
// //         self.register[self.base_index + ACTION_IS_CONTINUOUS] == 1
// //     }
// //     fn get_action_needs_previous_action(self: ActionDefinition) -> u8 {
// //         self.register[self.base_index + ACTION_NEEDS_PREVIOUS_ACTION]
// //     }

// //     fn get_action_target_x(self) -> u8 {
// //         get_action_target_x(self.action)
// //     }
// //     fn get_action_target_y(self) -> u8 {
// //         get_action_target_y(self.action)
// //     }
// //     fn get_action_type(self) -> u8 {
// //         get_action_type(self.action)
// //     }
// // }


// // pub struct TestActionDefinition {
// //     pub register: [u8; ACTION_DEFINITION_SIZE],
// //     pub action: Action,
// // }

// // impl ResolvedAction for TestActionDefinition {
// //     fn get_action_needs_target_free_space(self: TestActionDefinition) -> bool {
// //         self.register[ACTION_NEEDS_TARGET_FREE_SPACE] == 1
// //     }
// //     fn get_action_needs_target_is_not_self(self: TestActionDefinition) -> bool {
// //         self.register[ACTION_NEEDS_TARGET_IS_NOT_SELF] == 1
// //     }
// //     fn get_action_needs_status_visible(self: TestActionDefinition) -> bool {
// //         self.register[ACTION_NEEDS_STATUS_VISIBLE] == 1
// //     }
// //     fn get_action_needs_status_invisible(self: TestActionDefinition) -> bool {
// //         self.register[ACTION_NEEDS_STATUS_INVISIBLE] == 1
// //     }
// //     fn get_action_needs_status_hidden(self: TestActionDefinition) -> bool {
// //         self.register[ACTION_NEEDS_STATUS_HIDDEN] == 1
// //     }
// //     fn get_action_sets_status_hidden(self: TestActionDefinition) -> bool {
// //         self.register[ACTION_SETS_STATUS_HIDDEN] == 1
// //     }
// //     fn get_action_removes_status_hidden(self: TestActionDefinition) -> bool {
// //         self.register[ACTION_REMOVES_STATUS_HIDDEN] == 1
// //     }
// //     fn get_action_max_range(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_MAX_RANGE]
// //     }
// //     fn get_action_needs_min_status(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_NEEDS_MIN_STATUS]
// //     }
// //     fn get_action_needs_max_status(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_NEEDS_MAX_STATUS]
// //     }
// //     fn get_action_needed_energy(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_NEEDED_ENERGY]
// //     }
// //     fn get_action_unseen_event_is_internal(self: TestActionDefinition) -> bool {
// //         self.register[ACTION_EVENT_IS_TRAP] == 1
// //     }
// //     fn get_action_result_event_seen_type(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_RESULT_EVENT_SEEN_TYPE]
// //     }
// //     fn get_action_result_event_seen_subtype(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_RESULT_EVENT_SEEN_SUBTYPE]
// //     }
// //     fn get_action_result_event_seen_value_status_multiplier(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_RESULT_EVENT_SEEN_VALUE_STATUS_MULTIPLIER]
// //     }
// //     fn get_action_result_event_seen_value_fixed_addition(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_RESULT_EVENT_SEEN_VALUE_FIXED_ADDITION]
// //     }
// //     fn get_action_result_event_seen_coord_idx(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_RESULT_EVENT_SEEN_COORD_IDX]
// //     }
// //     fn get_action_result_event_seen_radius(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_RESULT_EVENT_SEEN_RADIUS]
// //     }
// //     fn get_action_result_event_not_seen_type(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_RESULT_EVENT_NOT_SEEN_TYPE]
// //     }
// //     fn get_action_result_event_not_seen_subtype(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_RESULT_EVENT_NOT_SEEN_SUBTYPE]
// //     }
// //     fn get_action_result_event_not_seen_value_status_multiplier(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_RESULT_EVENT_NOT_SEEN_VALUE_STATUS_MULTIPLIER]
// //     }
// //     fn get_action_result_event_not_seen_value_fixed_addition(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_RESULT_EVENT_NOT_SEEN_VALUE_FIXED_ADDITION]
// //     }
// //     fn get_action_result_event_not_seen_coord_idx(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_RESULT_EVENT_NOT_SEEN_COORD_IDX]
// //     }
// //     fn get_action_result_event_not_seen_radius(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_RESULT_EVENT_NOT_SEEN_RADIUS]
// //     }
// //     fn get_action_result_status_multiplier(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_RESULT_STATUS_MULTIPLIER]
// //     }
// //     fn get_action_result_status_fixed_addition(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_RESULT_STATUS_FIXED_ADDITION]
// //     }
// //     fn get_action_move_to_target(self: TestActionDefinition) -> u1 {
// //         self.register[ACTION_MOVE_TO_TARGET] as u1
// //     }
// //     fn get_action_is_continuous(self: TestActionDefinition) -> bool {
// //         self.register[ACTION_IS_CONTINUOUS] == 1
// //     }
// //     fn get_action_needs_previous_action(self: TestActionDefinition) -> u8 {
// //         self.register[ACTION_NEEDS_PREVIOUS_ACTION]
// //     }

// //     fn get_action_target_x(self) -> u8 {
// //         get_action_target_x(self.action)
// //     }
// //     fn get_action_target_y(self) -> u8 {
// //         get_action_target_y(self.action)
// //     }
// //     fn get_action_type(self) -> u8 {
// //         get_action_type(self.action)
// //     }
// // }

// // #[test]
// // fn test_execute_action() {
// //     let action = build_test_action_def!(build_move_action(4), quote { 1, 2, 3, 4 }); //new_action(1, 2, 3, 4);
// //     let my_advance = 10;
// //     let their_advance = 1;
// //     let actor = Character {
// //         id: 2,
// //         x: 2,
// //         y: 4,
// //         target_x: 0,
// //         target_y: 0,
// //         health: 255,
// //         damage_mod: 1,
// //         last_action: WAIT,
// //         class: MAGE,
// //         is_hidden: 0 as u1,
// //         has_been_seen: true,
// //         status: 0,
// //         actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER]
// //     };
// //     let energy = 15;
// //     let my_obstacles = get_default_obstacles(0);
// //     let their_obstacles = get_default_obstacles(1);
// //     let (valid, event, internal_event, c, result_energy) = execute_action(
// //         action,
// //         my_advance,
// //         their_advance,
// //         actor,
// //         energy,
// //         my_obstacles,
// //         their_obstacles
// //     );
// //     assert(valid, "valid");
// //     assert(event.actor_id == actor.id, f"{event}.actorid is not {actor}.id");
// //     assert(event.event == SEE_MOVE, f"{event} is not {SEE_MOVE}");
// //     assert(event.x == action.get_action_target_x(), f"{event}.target_x is not action target x");
// //     assert(event.y == action.get_action_target_y(), f"{event}.target_y is not action target y");
// //     assert(c.x == event.x, f"{c}.x is not action target x");
// //     assert(internal_event.event == NO_EVENT, f"expected no internal event, got {internal_event}");
// //     assert(result_energy == 11, f"{result_energy} != 11");
// // }

// // #[export]
// // pub fn build_action_register(actions: [])

// pub type CharacterActionDefinition = [u8; 32];
// pub type CharacterActionDefinitions = [CharacterActionDefinition; MAX_ACTIONS_PER_CHARACTER];
// pub type SerializedCharacterActionDefinition = Field;
// pub type SerializedCharacterActionDefinitions = [SerializedCharacterActionDefinition; MAX_ACTIONS_PER_CHARACTER];
// pub type SerializedRosterActionDefinitions = [SerializedCharacterActionDefinition; MAX_ACTIONS_PER_CHARACTER * MAX_CHARACTERS];