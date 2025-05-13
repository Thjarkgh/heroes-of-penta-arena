use skplg::{UNREADABLE_BYTES_PER_FIELD, softassert};
use crate::actionDefinition::{DEF_ROW, build_over_def_array, derive_action_def_def_struct, derive_action_def_def_builder, get_def_register_value, get_action_def_def_register_size};
use std::append::Append;
use crate::{actionDefinition::derive_frontend_action_def_struct, actionDefinition::derive_frontend_action_def_struct_builder};

    // fn get_action_req_target_free_space(self) -> bool;
    // fn get_action_req_target_is_not_self(self) -> bool;
    // fn get_action_req_status_visible(self) -> bool;
    // fn get_action_req_status_invisible(self) -> bool;
    // fn get_action_req_status_hidden(self) -> bool;
    // fn get_action_req_max_range(self) -> u8;
    // fn get_action_req_min_status(self) -> u8;
    // fn get_action_req_max_status(self) -> u8;
    // fn get_action_req_energy(self) -> u8;
    // fn get_action_req_previous_action(self) -> u8;
pub type ActionDefDefRequirementCheck = (Quoted, Quoted);
comptime fn action_def_def(varname: Quoted, bit_size: u8, expr: Quoted, msg: Quoted) -> DEF_ROW<ActionDefDefRequirementCheck> {
    (varname, bit_size, (expr, msg))
}
// comptime global ACTION_DEF_DEF_FIELD_COUNT: u32 = 11;
global ACTION_DEF_DEF_REQUIREMENTS: [DEF_ROW<ActionDefDefRequirementCheck>] = [
    action_def_def(quote { action_req_target_free_space }, 1, quote { could_move_to_target }, quote { f"Target space cannot be moved to {action_target_x},{action_target_y}) cannot be moved to: {VIEW_DISTANCE},{my_obstacles},{their_obstacles}" }),
    action_def_def(quote { action_req_target_is_not_self }, 1, quote { (actor_x != action_target_x) | (actor_y != action_target_y) }, quote { f"Target cannot be self ({action_target_x},{action_target_y})" }),
    action_def_def(quote { action_req_status_visible }, 1, quote { actor_is_in_view_range & !actor_is_hidden },  quote { f"Character must be fully visible for action {action_type}: in_view_range: {actor_is_in_view_range} & !hidden {actor_is_hidden} for enemy_advance {enemy_advance} @ {actor_x}" }),
    action_def_def(quote { action_req_status_invisible }, 1, quote { !actor_is_in_view_range | actor_is_hidden }, quote { f"Character must not be visible to perform action {action_type}: !in_view_range: {actor_is_in_view_range} || hidden: {actor_is_hidden} for enemy_advance {enemy_advance} @ {actor_x}" }),
    action_def_def(quote { action_req_status_hidden }, 1, quote { actor_is_hidden }, quote { f"Character needs to be hidden to perform action {action_type}" }),
    // action_def_def(quote { action_req_previous_action }, 3, quote { true }, quote { f"" }),
    action_def_def(quote { action_req_min_progress }, 4, quote { action_req_min_progress as u8 <= actor_progress as u8 }, quote { f"Character needs min progress {action_req_min_progress} to perform action {action_type}, but only has {actor_progress}" }),
    action_def_def(quote { action_req_max_progress }, 4, quote { action_req_max_progress as u8 >= actor_progress as u8 }, quote { f"Character cannot have a higher progress than {action_req_max_progress} to perform action {action_type}: got {actor_progress}" }),
    action_def_def(quote { action_req_status }, 4, quote { (action_req_status as u8 == 0 as u8) | (action_req_status as u8 == actor_progress as u8) }, quote { f"Character can only perform action {action_type} while having status {action_req_status}. Invalid status {actor_status}" }),
    // action_def_def(quote { action_req_required_energy }, 4, quote { action_req_required_energy <= energy }, quote { f"Character has insufficient energy left to perform action {action_type}: {energy} < {action_req_required_energy}" }),
    action_def_def(quote { action_req_max_range }, 8, quote { distance as u16 <= (action_req_max_range as u16) * (action_req_max_range as u16) }, quote { f"Character is out of range! Distance: {distance} > {action_req_max_range}: {{{actor_x},{actor_y}}} - {{{action_target_x},{action_target_y}}} with {action_req_max_range}" }),
];
pub comptime fn get_action_def_requirements_base_index() -> u32 {
  UNREADABLE_BYTES_PER_FIELD as u32
}

pub comptime fn get_action_def_requirements_byte_size() -> u32 {
  get_action_def_def_register_size(ACTION_DEF_DEF_REQUIREMENTS)
}

comptime fn derive_action_def_def_req_struct(s: StructDefinition) {
  derive_action_def_def_struct(s, ACTION_DEF_DEF_REQUIREMENTS);
}
// comptime fn derive_action_def_requirements_struct_new(f: FunctionDefinition) {
//   derive_action_def_def_struct_new(f, ACTION_DEF_DEF_REQUIREMENTS);
// }

#[derive_action_def_def_req_struct]
pub struct ActionRequirement {
  pub register: [u8; 32]
}
impl ActionRequirement {
  #[derive_action_def_requirements_struct_new()]
  pub fn new() -> ActionRequirement {
    ActionRequirement { register: &[].as_array() }
  }
}

comptime fn derive_action_def_def_req_builder(f: FunctionDefinition) {
  derive_action_def_def_builder(f, ACTION_DEF_DEF_REQUIREMENTS);
}
#[export]
#[derive_action_def_def_req_builder]
pub fn build_action_def_requirements() -> pub ActionRequirement { ActionRequirement::new() }

pub comptime fn validate_action_requirements(valid_varname: Quoted, register: Quoted) -> Quoted {
  let mut result = build_over_def_array(ACTION_DEF_DEF_REQUIREMENTS, get_action_def_requirements_base_index(), |bytes, bits, varname, bitsize, args|{
    let expr = get_def_register_value(register, bytes, bits, bitsize);
    // let varname = f"action_requirement_{i}_is_valid".quoted_contents();
    let (checkexpr, msg) = args;
    let check = if bitsize == 1 { quote { !($varname as bool) | ($checkexpr) } } else { quote { $checkexpr } };
    let sa = softassert(valid_varname, check, msg);
    quote {
      let $varname = $expr;
      $sa
    }
  });
  // println(result);
  // quote { assert(1==1); }
  result
}

pub comptime fn set_action_def_requirements_in_action_def(requirements: Quoted, action_def: Quoted) -> Quoted {
  let mut result = quote {};
  let base_index = get_action_def_requirements_base_index();
  // let mut multiplier = 2.pow_32(base_index as Field * 8);
  for i in 0..get_action_def_requirements_byte_size() {
    result = result.append(quote { $action_def[$base_index + $i] = $requirements.register[$i]; });
    // result = quote { $result $action_def += $requirements.register[$i] as Field * $multiplier; };
    // multiplier *= 2.pow_32(8);
  }
  // println(result);
  result
}

comptime fn derive_frontend_action_def_requirements_struct(s: StructDefinition) {
  derive_frontend_action_def_struct(s, ACTION_DEF_DEF_REQUIREMENTS);
}
#[derive_frontend_action_def_requirements_struct]
#[derive(Default)]
pub struct FrontendActionDefRequirements {}


pub comptime fn derive_frontend_action_def_requirements_struct_builder(param_name: Quoted) -> Quoted {
  let content = derive_frontend_action_def_struct_builder(param_name, get_action_def_requirements_base_index(), ACTION_DEF_DEF_REQUIREMENTS);
  // println(content);
  quote { FrontendActionDefRequirements { $content } }
}