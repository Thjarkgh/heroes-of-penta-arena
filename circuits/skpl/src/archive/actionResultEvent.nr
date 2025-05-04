// // pub global ACTION_RESULT_EVENT_TYPE: u8 = 0;
// // pub global ACTION_RESULT_EVENT_SUBTYPE: u8 = 1;
// // pub global ACTION_RESULT_EVENT_VALUE_MULTIPLIER: u8 = 2;
// // pub global ACTION_RESULT_EVENT_VALUE_FIXED_ADDITION: u8 = 3;
// // pub global ACTION_RESULT_EVENT_COORD_IDX: u8 = 4;
// // pub global ACTION_RESULT_EVENT_RADIUS: u8 = 5;
// // pub comptime fn to_action_result_event(event_type: Quoted, subtype: Quoted, val_mul: Quoted, val_add: Quoted, coord_idx: Quoted, radius: Quoted) -> Quoted {
// //     quote { ($event_type, $subtype, $val_mul, $val_add, $coord_idx, $radius)}
// // }
// // pub comptime fn get_type_of_action_result_event_type(varname: Quoted) -> Quoted {
// //     quote { $varname.0 }
// // }
// // pub comptime fn get_subtype_of_action_result_event_type(varname: Quoted) -> Quoted {
// //     quote { $varname.1 }
// // }
// // pub comptime fn get_value_multiplier_of_action_result_event_type(varname: Quoted) -> Quoted {
// //     quote { $varname.2 }
// // }
// // pub comptime fn get_value_addition_of_action_result_event_type(varname: Quoted) -> Quoted {
// //     quote { $varname.3 }
// // }
// // pub comptime fn get_coord_idx_of_action_result_event_type(varname: Quoted) -> Quoted {
// //     quote { $varname.4 }
// // }
// // pub comptime fn get_radius_of_action_result_event_type(varname: Quoted) -> Quoted {
// //     quote { $varname.5 }
// // }
// // pub type ActionResultEventDefinition = (u8, u8, u8, u8, u8, u8);

// use crate::{softassert};
// use crate::actionDefinition::{DEF_ROW, build_over_def_array, derive_action_def_def_struct, derive_action_def_def_builder, get_def_register_value, get_action_def_def_register_size};
// use crate::actionRequirements::get_action_def_requirements_byte_size;
// use crate::actionResultEffect::get_action_def_result_effects_byte_size;
// use crate::actionPreCalcEffect::get_action_def_pre_calc_effects_byte_size;
// use std::append::Append;
// use super::{ACTION_RESULT_EVENT_COUNT};

// pub type ActionDefDefResultEventRow = (fn (Quoted) -> Quoted,);
// comptime fn action_def_def(varname: Quoted, bit_size: u8, handler: fn (Quoted) -> Quoted) -> DEF_ROW<ActionDefDefResultEventRow> {
//     (varname, bit_size, (handler,))
// }
// comptime global ACTION_DEF_DEF_RESULT_EVENTS: [DEF_ROW<ActionDefDefResultEventRow>] = [
//     action_def_def(quote { result_event_value_fixed_addition }, 8, |fixed_addition|quote { result_event_value += $fixed_addition as u32; }),
//     action_def_def(quote { result_event_value_scaled_by_progress }, 4, |factor|quote { result_event_value += ($factor as u32) * (actor_progress as u32); }),
//     action_def_def(quote { result_event_coords_idx }, 2, |coords_idx|{
//       let check = softassert(quote { is_valid }, quote { $coords_idx < 3 }, quote { f"Invalid event coord idx: {result_event_coords_idx} does not fit in u8!" });
//       quote {
//         let result_event_coords_idx: u8 = $coords_idx;
//         $check
//         result_event_coords = coords[result_event_coords_idx & 3];
//       }
//     }),
//     action_def_def(quote { result_event_type }, 4, |event_type|quote { result_event_type = $event_type; }),
//     action_def_def(quote { result_event_subtype }, 8, |event_subtype|quote { result_event_subtype = $event_subtype; }),
//     action_def_def(quote { result_event_radius }, 6, |event_radius|quote { result_event_radius = $event_radius; })
// ];
// comptime fn get_action_def_result_event_base_index() -> u32 {
//   get_action_def_requirements_byte_size() + get_action_def_pre_calc_effects_byte_size() + get_action_def_result_effects_byte_size()
// }

// pub comptime fn get_action_def_result_event_byte_size() -> u32 {
//   get_action_def_def_register_size(ACTION_DEF_DEF_RESULT_EVENTS)
// }


// comptime fn derive_action_def_def_result_event_struct(s: StructDefinition) {
//   derive_action_def_def_struct(s, ACTION_DEF_DEF_RESULT_EVENTS);
// }
// // comptime fn derive_action_def_result_event_struct_new(f: FunctionDefinition) {
// //   derive_action_def_def_struct_new(f, ACTION_DEF_DEF_RESULT_EVENTS);
// // }
// #[derive_action_def_def_result_event_struct]
// pub struct ActionResultEvent {
//   pub register: [u8; 32]
// }
// impl ActionResultEvent {
//   #[derive_action_def_result_event_struct_new]
//   pub fn new() -> ActionResultEvent {
//     ActionResultEvent { register: &[].as_array() }
//   }
// }

// comptime fn derive_action_def_def_result_event_builder(f: FunctionDefinition) {
//   derive_action_def_def_builder(f, ACTION_DEF_DEF_RESULT_EVENTS);
// }
// #[derive_action_def_def_result_event_builder]
// pub fn build_action_def_result_event() -> ActionResultEvent { ActionResultEvent::new() }

// pub comptime fn build_result_event(event_idx: u32, events_collection_varname: Quoted, valid_varname: Quoted, register: Quoted) -> Quoted {
//   let base_index = get_action_def_result_event_base_index();
//   let event_data_start_idx = base_index + event_idx * get_action_def_result_event_byte_size();
//   let mut result = build_over_def_array(ACTION_DEF_DEF_RESULT_EVENTS, event_data_start_idx, |bytes, bits, _, bitsize, args|{
//     let expr = get_def_register_value(register, bytes, bits, bitsize);
    
//     //let varname = f"${varname}${event_idx}".quoted_contents();
//     // let (checkexpr, msg) = args;
//     let (handler) = args;
    
//     handler(expr)
//   });

//   let value_valid_msg = f"Invalid event value ({event_idx}): {{result_event_value}} does not fit in u8!".quoted_contents();
//   let value_valid = softassert(valid_varname, quote { result_event_value <= 255 as u32 }, value_valid_msg);
//   quote {
//     let mut result_event_type: u8 = 0;
//     let mut result_event_subtype: u8 = 0;
//     let mut result_event_coords: (u8,u8) = (NOWHERE, NOWHERE);
//     let mut result_event_value: u32 = 0;
//     let mut result_event_radius: u8 = 0;
//     $result
//     $value_valid

//     $events_collection_varname.push(build_subtype_value_event(
//       result_event_type,
//       actor_id,
//       result_event_coords.0,
//       result_event_coords.1,
//       result_event_value as u8,
//       result_event_subtype,
//       result_event_radius
//     ));
//   }
// }

// pub comptime fn set_action_def_result_event_in_action_def(event: Quoted, action_def: Quoted) -> Quoted {
//   let mut result = quote {};
//   let mut base_index = get_action_def_result_event_base_index();
//   for event_idx in 0..ACTION_RESULT_EVENT_COUNT {
//     let idx = event_idx * get_action_def_result_event_byte_size();
//     for i in 0..get_action_def_result_event_byte_size() {
//       let destination_idx = base_index + idx + i;
//       result = result.append(quote { $action_def[$destination_idx] = $event[$event_idx].register[$i]; });
//     }
//   }
//   result
// }