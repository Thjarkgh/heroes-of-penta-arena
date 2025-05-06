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

// use crate::actionDefinition::{DEF_ROW, build_over_def_array, derive_action_def_def_struct, derive_action_def_def_builder, get_def_register_value, get_action_def_def_register_size};
// use crate::actionRequirements::get_action_def_requirements_byte_size;
// use std::append::Append;


// pub type ActionDefDefPreCalcEffect = (fn (Quoted) -> Quoted,);
// comptime fn action_def_def(varname: Quoted, bit_size: u8, handler: fn (Quoted) -> Quoted) -> DEF_ROW<ActionDefDefPreCalcEffect> {
//     (varname, bit_size, (handler,))
// }
// comptime global ACTION_DEF_DEF_PRE_CALC_EFFECTS: [DEF_ROW<ActionDefDefPreCalcEffect>] = [
//     action_def_def(quote { pre_calc_effect_continues_action }, 3, |continued_action|quote { let continues_action: bool = $continued_action as u8 == actor.get_last_action() as u8; }),
//     action_def_def(quote { pre_calc_effect_is_continuous }, 1, |is_continuous|quote { let is_continuous: bool = $is_continuous as bool; }),
//     action_def_def(quote { pre_calc_effect_interrupts }, 1, |is_interrupting|quote { let is_interrupting: bool = $is_interrupting as bool; }),
//     action_def_def(quote { pre_calc_effect_allow_retargeting }, 1, |allows_retargetting|quote { let not_interrupted_through_retargeting: bool = $allows_retargetting as bool | ((action_target_x == actor.get_target_x()) & (action_target_y == actor.get_target_y())); })
// ];
// comptime fn get_action_def_pre_calc_base_index() -> u32 {
//   get_action_def_requirements_byte_size()
// }

// pub comptime fn get_action_def_pre_calc_effects_byte_size() -> u32 {
//   get_action_def_def_register_size(ACTION_DEF_DEF_PRE_CALC_EFFECTS)
// }

// comptime fn derive_action_def_def_pre_calc_event_struct(s: StructDefinition) {
//   derive_action_def_def_struct(s, ACTION_DEF_DEF_PRE_CALC_EFFECTS);
// }
// // comptime fn derive_action_def_result_event_struct_new(f: FunctionDefinition) {
// //   derive_action_def_def_struct_new(f, ACTION_DEF_DEF_PRE_CALC_EFFECTS);
// // }
// #[derive_action_def_def_pre_calc_event_struct]
// pub struct ActionPreCalcEffect {
//   pub register: [u8; 32]
// }
// impl ActionPreCalcEffect {
//   #[derive_action_def_pre_calc_effect_struct_new]
//   pub fn new() -> ActionPreCalcEffect {
//     ActionPreCalcEffect { register: &[].as_array() }
//   }
// }

// comptime fn derive_action_def_def_pre_calc_effect_builder(f: FunctionDefinition) {
//   derive_action_def_def_builder(f, ACTION_DEF_DEF_PRE_CALC_EFFECTS);
// }
// #[derive_action_def_def_pre_calc_effect_builder]
// pub fn build_action_def_pre_calc_effect() -> ActionPreCalcEffect { ActionPreCalcEffect::new() }

// pub comptime fn apply_action_pre_calc_effects(register: Quoted) -> Quoted {
//   let base_index = get_action_def_pre_calc_base_index();
//   let mut result = build_over_def_array(ACTION_DEF_DEF_PRE_CALC_EFFECTS, base_index, |bytes, bits, _, bitsize, args|{
//     let expr = get_def_register_value(register, bytes, bits, bitsize);
    
//     //let varname = f"${varname}${event_idx}".quoted_contents();
//     // let (checkexpr, msg) = args;
//     let (handler) = args;
    
//     handler(expr)
//   });

//   quote {
//     $result
//     is_not_interrupted = (
//       ((!is_continuous) & (!is_interrupting)) | // that's the ID of the wait action => leave status, but not continuous
//       ((is_continuous) & continues_action & not_interrupted_through_retargeting)
//     );

//     actor_progress *= is_not_interrupted as u8;
//   }
// }

// pub comptime fn set_action_def_pre_calc_effects_in_action_def(effects: Quoted, action_def: Quoted) -> Quoted {
//   let mut result = quote {};
//   let base_index = get_action_def_pre_calc_base_index();
//   for i in 0..get_action_def_pre_calc_effects_byte_size() {
//     result = result.append(quote { $action_def[$base_index + $i] = $effects.register[$i]; });
//   }
//   result
// }