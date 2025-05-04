// // pub type ActionResultEffects = (bool, bool, bool, bool);
// // pub comptime fn to_action_result_effect(set_hidden: bool, remove_hidden: bool, move_to_target: bool, continuous: bool) -> Quoted {
// //     quote { ($set_hidden, $remove_hidden, $move_to_target, $continuous ) }
// // }

// // pub comptime fn get_sets_status_hidden_of_action_result_effect(varname: Quoted) -> Quoted {
// //     quote { $varname.0 }
// // }
// // pub comptime fn get_removes_status_hidden_of_action_result_effect(varname: Quoted) -> Quoted {
// //     quote { $varname.1 }
// // }
// // pub comptime fn get_move_to_target_of_action_result_effect(varname: Quoted) -> Quoted {
// //     quote { $varname.2 }
// // }
// // pub comptime fn get_is_continuous_of_action_result_effect(varname: Quoted) -> Quoted {
// //     quote { $varname.3 }
// // }

// use crate::actionDefinition::{DEF_ROW, build_over_def_array, derive_action_def_def_struct, derive_action_def_def_builder, get_def_register_value, get_action_def_def_register_size, derive_action_def_def_struct_new};
// use crate::actionRequirements::get_action_def_requirements_byte_size;
// use crate::softassert;
// use crate::actionPreCalcEffect::get_action_def_pre_calc_effects_byte_size;
// use std::append::Append;

// pub type ActionDefDefPreCalcEffect = (fn (Quoted) -> Quoted,);
// comptime fn action_def_def(varname: Quoted, bit_size: u8, handler: fn (Quoted) -> Quoted) -> DEF_ROW<ActionDefDefPreCalcEffect> {
//     (varname, bit_size, (handler,))
// }
// comptime global ACTION_DEF_DEF_RESULT_EFFECTS: [DEF_ROW<ActionDefDefPreCalcEffect>] = [
//     action_def_def(quote { action_result_required_energy }, 4, |action_required_energy|{
//       let check = softassert(quote { is_valid }, quote { action_required_energy <= result_energy }, quote { f"Character has insufficient energy left to perform action {action_type}: {energy} < {action_req_required_energy}" });
//       quote {
//         let action_required_energy = $action_required_energy;
//         $check
//         result_energy = std::wrapping_sub(result_energy, action_required_energy);
//       }
//     }),
//     action_def_def(quote { action_result_progress_increment }, 4, |progress_increment|quote { let action_result_effect_progress_increment: u32 = $progress_increment as u32; }),
//     action_def_def(quote { action_result_progress_multiplier }, 2, |progress_multiplier|quote { let action_result_effect_progress_multiplier: u32 = $progress_multiplier as u32; }),
//     action_def_def(quote { action_result_move_to_target }, 1, |move_to_target|quote { result_coords = coords[$move_to_target as u8]; }),
//     action_def_def(quote { action_result_hide }, 1, |hide|quote { let action_result_effect_hide: bool = $hide as bool; }),
//     action_def_def(quote { action_result_reveal }, 1, |leave_shadows|quote { let action_result_effect_leave_shadows: bool = $leave_shadows as bool; })
// ];
// comptime fn get_action_def_result_effect_base_index() -> u32 {
//   get_action_def_requirements_byte_size() + get_action_def_pre_calc_effects_byte_size()
// }

// pub comptime fn get_action_def_result_effects_byte_size() -> u32 {
//   get_action_def_def_register_size(ACTION_DEF_DEF_RESULT_EFFECTS)
// }

// comptime fn derive_action_def_def_result_effect_struct(s: StructDefinition) {
//   derive_action_def_def_struct(s, ACTION_DEF_DEF_RESULT_EFFECTS);
// }
// comptime fn derive_action_def_result_event_struct_new(f: FunctionDefinition) {
//   derive_action_def_def_struct_new(f, ACTION_DEF_DEF_RESULT_EFFECTS);
// }
// #[derive_action_def_def_result_effect_struct]
// pub struct ActionResultEffect {
//   pub register: [u8; 32]
// }
// impl ActionResultEffect {
//   #[derive_action_def_result_effects_struct_new]
//   pub fn new() -> ActionResultEffect {
//     ActionResultEffect { register: &[].as_array() }
//   }
// }

// comptime fn derive_action_def_def_result_effects_builder(f: FunctionDefinition) {
//   derive_action_def_def_builder(f, ACTION_DEF_DEF_RESULT_EFFECTS);
// }
// #[derive_action_def_def_result_effects_builder]
// pub fn build_action_def_result_effects() -> ActionResultEffect { ActionResultEffect::new() }

// pub comptime fn apply_action_result_effects(register: Quoted) -> Quoted {
//   let base_index = get_action_def_result_effect_base_index();
//   let mut result = build_over_def_array(ACTION_DEF_DEF_RESULT_EFFECTS, base_index, |bytes, bits, _, bitsize, args|{
//     let expr = get_def_register_value(register, bytes, bits, bitsize);
    
//     //let varname = f"${varname}${event_idx}".quoted_contents();
//     // let (checkexpr, msg) = args;
//     let (handler) = args;
    
//     handler(expr)
//   });

//   quote {
//     $result

//     let result_progress_raw = actor_progress as u32 * action_result_effect_progress_multiplier + action_result_effect_progress_increment;
//     //softassert!(quote { is_valid }, quote { result_progress_raw <= MAX_PROGRESS as u32 }, quote { f"Invalid result progress: {result_progress_raw} > {MAX_PROGRESS}" });
//     result_progress = result_progress_raw as u8;

//     result_is_hidden = (result_is_hidden & !action_result_effect_leave_shadows) | action_result_effect_hide;
//     result_is_visible = !result_is_hidden & is_visible(enemy_advance, result_coords.0);
//   }
// }

// pub comptime fn set_action_def_result_effects_in_action_def(effects: Quoted, action_def: Quoted) -> Quoted {
//   let mut result = quote {};
//   let base_index = get_action_def_result_effect_base_index();
//   for i in 0..get_action_def_result_effects_byte_size() {
//     result = result.append(quote { $action_def[$base_index + $i] = $effects.register[$i]; });
//   }
//   result
// }