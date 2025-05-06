mod actionRequirements;
mod actionPreCalcEffect;
mod actionResultEffect;
mod actionResultEvent;
mod actionDefinitionBuilder;
mod action;

use skplam::ActionDefinition;

pub use actionDefinitionBuilder::{ActionDefinitionBuilder};
pub use action::{Action, get_action_actor, get_action_type, get_action_target_x, get_action_target_y, ACTION_BYTE_SIZE};
#[export]
pub use action::new_action;

#[test]
fn test_action_builder() {
  let builder = ActionDefinitionBuilder::new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
  let wait_action = builder.build_wait_action_def();
  assert(wait_action[0] == 0);
}

pub trait ActionDefinitionRegister {
  fn get_action_definition(self, actor_id: u8, action_idx: u8) -> (bool,ActionDefinition);
}

// use skplam::{FrontendActionDefRequirements, ActionDefinition, derive_frontend_action_def_requirements_struct_builder};

// #[use_callers_scope]
// comptime fn derive_frontend_action_def_requirements_struct_builderx(f: FunctionDefinition) {
//   derive_frontend_action_def_requirements_struct_builder(f, quote { FrontendActionDefRequirements });
// }
// #[export]
// #[derive_frontend_action_def_requirements_struct_builder]
// pub fn parse_action_def_requirements_for_frontend(action_def: ActionDefinition) -> FrontendActionDefRequirements { FrontendActionDefRequirements::default() }

// #[test]
// fn test_parse_action_def() {
  
// }