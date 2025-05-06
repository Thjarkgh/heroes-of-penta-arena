// use skplg::{softassert, UNREADABLE_BYTES_PER_FIELD, NOWHERE};
// use crate::actionDefinitionBuilder::ActionDefinitionBuilder;

pub global ACTION_BYTE_SIZE: u32 = 4;
//pub type Action = [u8; ACTION_BYTE_SIZE];
pub struct Action {
  action_type: u8,
  actor_id: u8,
  target_x: u8,
  target_y: u8
}

global ACTION_TYPE: u8 = 0;
global ACTION_ACTOR: u8 = 1; // TODO: remove?! (point is: currently not implemented, but might be needed for summons!)
global ACTION_TARGET_X: u8 = 2;
global ACTION_TARGET_Y: u8 = 3;

#[export]
pub fn get_action_type(action: Action) -> pub u8 {
    action.action_type //[ACTION_TYPE]
}
#[export]
pub fn get_action_actor(action: Action) -> pub u8 {
    action.actor_id //[ACTION_ACTOR]
}
#[export]
pub fn get_action_target_x(action: Action) -> pub u8 {
    action.target_x //[ACTION_TARGET_X]
}
#[export]
pub fn get_action_target_y(action: Action) -> pub u8 {
    action.target_y //[ACTION_TARGET_Y]
}
#[export]
pub fn new_action(action_type: u8, actor_id: u8, target_x: u8, target_y: u8) -> pub Action {
    // let mut action: Action = [0; 4];
    // action[ACTION_TYPE] = action_type;
    // action[ACTION_ACTOR] = actor_id;
    // action[ACTION_TARGET_X] = target_x;
    // action[ACTION_TARGET_Y] = target_y;
    // action
    Action {
      action_type: action_type,
      actor_id: actor_id,
      target_x: target_x,
      target_y: target_y
    }
}

// pub struct ActionSerDe {
//   max_actions: u32,
//   max_actions_per_character: u8,
//   serialized_actions_array_size: u32,
//   serialized_actions_per_field: u32,
//   width: u8,
//   height: u8,
//   idle_action_id: u8
// }

// global SERIALIZED_ACTION_BYTE_SIZE: u32 = ACTION_BYTE_SIZE;
// fn get_serialized_actions_array_size(max_actions: u32) -> u32 {
//   let needed_usable_bytes = max_actions * SERIALIZED_ACTION_BYTE_SIZE;
//   let usable_bytes_per_field = 32 - UNREADABLE_BYTES_PER_FIELD;
//   let field_count = needed_usable_bytes / usable_bytes_per_field;
//   if field_count * usable_bytes_per_field == needed_usable_bytes {
//     field_count
//   } else {
//     field_count + 1
//   }
// }
// fn get_serialized_actions_per_field(max_actions: u32) -> u32 {
//   (32 - UNREADABLE_BYTES_PER_FIELD) / (max_actions * ACTION_BYTE_SIZE)
// }

// global MAX_SUPPORTED_ACTIONS: u32 = 7;
// impl ActionSerDe {
//   pub fn new(
//     max_actions: u32,
//     max_actions_per_character: u8,
//     width: u8,
//     height: u8,
//     idle_action_id: u8
//   ) -> ActionSerDe {
//     assert(max_actions <= MAX_SUPPORTED_ACTIONS);
//     let serialized_actions_array_size = get_serialized_actions_array_size(max_actions);
//     let serialized_actions_per_field = get_serialized_actions_per_field(max_actions);

//     ActionSerDe {
//       max_actions: max_actions,
//       max_actions_per_character: max_actions_per_character,
//       serialized_actions_array_size: serialized_actions_array_size,
//       serialized_actions_per_field: serialized_actions_per_field,
//       width: width,
//       height: height,
//       idle_action_id: idle_action_id
//     }
//   }
//   pub fn parse_actions(self, max_actor_id: u8, fields: [Field]) -> (bool, [Action]) {
//     let mut valid = true;
//     let serialized_actions_array_size = self.serialized_actions_array_size;
//     softassert!(quote { valid }, quote { fields.len() == serialized_actions_array_size }, quote { f"{fields} does not have size {serialized_actions_array_size}" });
//     comptime {
//       assert(SERIALIZED_ACTION_BYTE_SIZE == 4);
//     }
//       // comptime {
//       //     assert(UNREADABLE_BYTES_PER_FIELD + SERIALIZED_ACTIONS_PER_FIELD * SERIALIZED_ACTION_BYTE_SIZE <= 32);
//       //     assert(SERIALIZED_ACTIONS_ARRAY_SIZE * SERIALIZED_ACTIONS_PER_FIELD == MAX_ACTIONS);
//       //     assert(SERIALIZED_ACTION_BYTE_SIZE >= 4);
//       // }
//       let max_actions_per_character = self.max_actions_per_character;
//       let width = self.width;
//       let height = self.height;

//       let mut actions: [Action] = &[];
//       for i in 0..fields.len() {
//           let split: [u8; 32] = fields[i].to_be_bytes::<32>();
//           //assert(split.len() == 32);
//           let mut serialized_actions_per_field = self.serialized_actions_per_field;
//           if serialized_actions_per_field * (i + 1) > self.max_actions {
//             serialized_actions_per_field = self.max_actions - serialized_actions_per_field * i;
//           }
//           for j in 0..serialized_actions_per_field {
//               let offset = UNREADABLE_BYTES_PER_FIELD + j * SERIALIZED_ACTION_BYTE_SIZE;
//               let action_type = split[offset];
//               let actor = split[offset + 1];
//               let target_x = split[offset + 2];
//               let target_y = split[offset + 3];

//               softassert!(quote { valid }, quote { action_type <= max_actions_per_character }, quote { f"Invalid action: action type {action_type} > {max_actions_per_character}" });
//               softassert!(quote { valid }, quote { actor <= max_actor_id }, quote { f"Invalid action: action actor {actor} > {max_actor_id}" });
//               softassert!(quote { valid }, quote { (target_x < width) | (target_x == NOWHERE) }, quote { f"Invalid action: action type {target_x} >= {width} and not {NOWHERE}" });
//               softassert!(quote { valid }, quote { (target_y < height) | (target_y == NOWHERE) }, quote { f"Invalid action: action type {target_y} >= {height} and not {NOWHERE}" });

//               actions = actions.push_back(new_action(
//                   action_type,
//                   actor,
//                   target_x,
//                   target_y
//               ));
//               /*Action {
//                   action: split[offset],
//                   actor: split[offset + 1],
//                   target_x: split[offset + 2],
//                   target_y: split[offset + 3],
//               }*/
//           }
//       }
//       (valid, actions)
//   }

//   /**
//   * Warning: This function can throw!!!
//   */
//   pub fn serialize_actions(self, actor_id: u8, actions: [Action]) -> [Field] {
//       // comptime {
//       //     assert(UNREADABLE_BYTES_PER_FIELD + SERIALIZED_ACTIONS_PER_FIELD * SERIALIZED_ACTION_BYTE_SIZE <= 32);
//       //     assert(SERIALIZED_ACTIONS_ARRAY_SIZE * SERIALIZED_ACTIONS_PER_FIELD == MAX_ACTIONS);
//       //     assert(SERIALIZED_ACTION_BYTE_SIZE >= 4);
//       // }
//       assert(actions.len() <= self.max_actions);

//       let mut actions_stuffed: [Action; MAX_SUPPORTED_ACTIONS] = [new_action(self.idle_action_id, actor_id, NOWHERE, NOWHERE); MAX_SUPPORTED_ACTIONS];
//       for i in 0..actions.len() {
//           actions_stuffed[i] = actions[i];
//       }

//       let mut fields: [Field] = &[];
//       for i in 0..self.serialized_actions_array_size {
//           let mut data: [u8; 32] = [0; 32];
//           for j in 0..self.serialized_actions_per_field {
//               let index = i * self.serialized_actions_per_field + j;
//               let action = actions_stuffed[index];
//               let offset = UNREADABLE_BYTES_PER_FIELD + j * SERIALIZED_ACTION_BYTE_SIZE;
//               data[offset] = get_action_type(action);
//               data[offset + 1] = get_action_actor(action);
//               data[offset + 2] = get_action_target_x(action);
//               data[offset + 3] = get_action_target_y(action);
//           }
//           fields = fields.push_back(std::field::bytes32_to_field(data));
//       }
//       fields
//   }
// }