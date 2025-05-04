use skplg::{softassert, UNREADABLE_BYTES_PER_FIELD, NOWHERE};
use skpla::{ACTION_BYTE_SIZE, Action, new_action, get_action_actor, get_action_type, get_action_target_x, get_action_target_y};
use crate::SerializedArenaActions;
use crate::{MAX_ACTIONS, MAX_ACTIONS_PER_CHARACTER};
use crate::{WIDTH, HEIGHT};
use crate::WAIT;

pub global SERIALIZED_ACTION_BYTE_SIZE: u32 = ACTION_BYTE_SIZE;
pub global SERIALIZED_ACTIONS_PER_FIELD: u32 = 4;
pub global SERIALIZED_ACTIONS_ARRAY_SIZE: u32 = 1;

// comptime fn get_serialized_actions_array_size() -> u32 {
//   let needed_usable_bytes = MAX_ACTIONS * ACTION_BYTE_SIZE;
//   let usable_bytes_per_field = 32 - UNREADABLE_BYTES_PER_FIELD;
//   let field_count = needed_usable_bytes / usable_bytes_per_field;
//   if field_count * usable_bytes_per_field == needed_usable_bytes {
//     field_count
//   } else {
//     field_count + 1
//   }
// }


  pub fn parse_actions(max_actor_id: u8, fields: SerializedArenaActions) -> (bool, [Action; MAX_ACTIONS]) {
    let mut valid = true;
    softassert!(quote { valid }, quote { fields.len() == SERIALIZED_ACTIONS_ARRAY_SIZE }, quote { f"{fields} does not have size {SERIALIZED_ACTIONS_ARRAY_SIZE}" });
    comptime {
      assert(SERIALIZED_ACTION_BYTE_SIZE == 4);
    }
      comptime {
          assert(UNREADABLE_BYTES_PER_FIELD + SERIALIZED_ACTIONS_PER_FIELD * SERIALIZED_ACTION_BYTE_SIZE <= 32);
          assert(SERIALIZED_ACTIONS_ARRAY_SIZE * SERIALIZED_ACTIONS_PER_FIELD == MAX_ACTIONS);
          assert(SERIALIZED_ACTION_BYTE_SIZE >= 4);
      }

      let mut actions: [Action] = &[];
      assert(fields.len() == 1);
      // for i in 0..1 {
      let i = 0;
          let split: [u8; 32] = fields[i].to_be_bytes::<32>();
          assert(split.len() == 32);
          let mut serialized_actions_per_field = SERIALIZED_ACTIONS_PER_FIELD;
          if serialized_actions_per_field * (i + 1) > MAX_ACTIONS {
            serialized_actions_per_field = MAX_ACTIONS - serialized_actions_per_field * i;
          }
          assert(serialized_actions_per_field == SERIALIZED_ACTIONS_PER_FIELD);
          for j in 0..SERIALIZED_ACTIONS_PER_FIELD {
              let offset = UNREADABLE_BYTES_PER_FIELD + j * SERIALIZED_ACTION_BYTE_SIZE;
              let action_type = split[offset];
              let actor = split[offset + 1];
              let target_x = split[offset + 2];
              let target_y = split[offset + 3];

              softassert!(quote { valid }, quote { action_type as u32 <= MAX_ACTIONS_PER_CHARACTER }, quote { f"Invalid action: action type {action_type} > {MAX_ACTIONS_PER_CHARACTER}" });
              softassert!(quote { valid }, quote { actor <= max_actor_id }, quote { f"Invalid action: action actor {actor} > {max_actor_id}" });
              softassert!(quote { valid }, quote { (target_x < WIDTH) | (target_x == NOWHERE) }, quote { f"Invalid action: action type {target_x} >= {WIDTH} and not {NOWHERE}" });
              softassert!(quote { valid }, quote { (target_y < HEIGHT) | (target_y == NOWHERE) }, quote { f"Invalid action: action type {target_y} >= {HEIGHT} and not {NOWHERE}" });

              actions = actions.push_back(new_action(
                  action_type,
                  actor,
                  target_x,
                  target_y
              ));
              /*Action {
                  action: split[offset],
                  actor: split[offset + 1],
                  target_x: split[offset + 2],
                  target_y: split[offset + 3],
              }*/
          }
      // }
      // println(actions);
      (valid, actions.as_array())
  }

  /**
  * Warning: This function can throw!!!
  */
  pub fn serialize_actions(actor_id: u8, actions: [Action]) -> [Field; SERIALIZED_ACTIONS_ARRAY_SIZE] {
      comptime {
          assert(UNREADABLE_BYTES_PER_FIELD + SERIALIZED_ACTIONS_PER_FIELD * SERIALIZED_ACTION_BYTE_SIZE <= 32);
          assert(SERIALIZED_ACTIONS_ARRAY_SIZE * SERIALIZED_ACTIONS_PER_FIELD == MAX_ACTIONS);
          assert(SERIALIZED_ACTION_BYTE_SIZE >= 4);
      }
      assert(actions.len() <= MAX_ACTIONS);

      let mut actions_stuffed: [Action; MAX_ACTIONS] = [new_action(WAIT, actor_id, NOWHERE, NOWHERE); MAX_ACTIONS];
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
