use arenalib::{ActionDefinition, ActionDefinitionRegister};
use arenalib::{MAX_CHARACTERS, MAX_ACTIONS_PER_CHARACTER};
use arenalib::MAX_ACTIONS_PER_CHARACTER;
use arenalib::SerializedArenaActionDefinitions;
use arenalib::get_wait_action_def;

pub struct ArrayActionDefinitionRegister {
  wait_action: ActionDefinition,
  register: [ActionDefinition; MAX_CHARACTERS * MAX_ACTIONS_PER_CHARACTER]
}

impl ArrayActionDefinitionRegister {
  pub fn new(action_definitions: SerializedArenaActionDefinitions) -> ArrayActionDefinitionRegister {
    let parsed = action_definitions.map(|ad|ad.to_be_bytes::<32>());
    let wait_action = get_wait_action_def();

    ArrayActionDefinitionRegister {
      wait_action: wait_action,
      register: parsed
    }
  }
}

impl ActionDefinitionRegister for ArrayActionDefinitionRegister {
  fn get_action_definition(self, actor_id: u8, action_idx: u8) -> (bool,ActionDefinition) {
    if (actor_id as u32 >= MAX_CHARACTERS) | (action_idx as u32 > MAX_ACTIONS_PER_CHARACTER) {
      (false, self.wait_action)
    } else {
      if (action_idx == 0) {
        (true, self.wait_action)
      } else {
        (true, self.register[action_idx - 1])
      }
    }
  }
}