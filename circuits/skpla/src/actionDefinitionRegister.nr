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