mod character;
mod actionSerDe;

pub use skpla::{Action, new_action, get_action_actor, get_action_type, get_action_target_x, get_action_target_y};
pub use skplam::{ActionDefinition};
use skplam::{SerializedRosterActionDefinitions, SerializedCharacterActionDefinitions, SerializedCharacterActionDefinition};
pub use skplam::{apply_action_result_effects, apply_action_pre_calc_effects, validate_action_requirements, build_result_event};
use skpla::{ActionDefinitionBuilder};
pub use actionSerDe::{serialize_actions, parse_actions};
pub use skpla::ActionDefinitionRegister;

// MAP
pub global WIDTH_BITS: u8 = 5;
pub global WIDTH_MASK: u8 = (1 << WIDTH_BITS) - 1;
pub global WIDTH: u8 = 1 << WIDTH_BITS;
pub global HEIGHT_BITS: u8 = 4;
pub global HEIGHT_MASK: u8 = (1 << HEIGHT_BITS) - 1;
pub global HEIGHT: u8 = 10;
// pub global NOWHERE: u8 = 255;

// CLASSES
//pub global UNKNOWN_CLASS: u8 = 0;
pub global ARCHER: u8 = 1;
pub global RITUALIST: u8 = 2;
pub global ROGUE: u8 = 3;
pub global KNIGHT: u8 = 4;
pub global MAGE: u8 = 5;
pub global CLASS_BITS: u8 = 3;
pub global CLASS_MASK: u8 = (1 << CLASS_BITS) - 1;
pub global CLASS_COUNT: u32 = 6;
pub global MAX_ACTIONS_PER_CHARACTER: u32 = 6;

// ACTIONS
pub global WAIT: u8 = 0;
//pub global SNEAK: u8 = 1;
//pub global MOVE: u8 = 2;          // => SEE_COLUMN (depr: MOVE)
//pub global RITUAL: u8 = 3;        // => SEE_RITUAL | WIN
//pub global SEARCH: u8 = 4;        // => SEE_SEARCH_TRAP
//pub global ATTACK: u8 = 5;        // => RECEIVE_ATTACK | DESTROY // affects my obstacles; TODO: with more attack types might also affect other own characters
//pub global CAST: u8 = 6;          // => SEE_CAST // affects my obstacles; TODO: with more attack types might also affect other own characters
//pub global CAST_FIREBALL: u8 = 7; // => RECEIVE_ATTACK // affects other characters if status == FIREBALL_ROUNDS_FOR_CAST
//pub global DRAW: u8 = 8;          // => SEE_DRAW
//pub global SHOOT: u8 = 9;         // => RECEIVE_ATTACK
//pub global TRIGGER_TRAP = 9;  // => TRIGGERED_TRAP ?????????
//pub global DISARM_TRAP: u8 = 10;  // => DESTROY
//pub global SET_TRAP: u8 = 11;
pub global ACTION_COUNT: u32 = 12;
pub global ACTION_RESULT_EVENT_COUNT: u32 = 4;
pub global ACTION_RESULT_COORDINATES_IDX_SELF: u8 = 0;
pub global ACTION_RESULT_COORDINATES_IDX_TARGET: u8 = 1;
pub global ACTION_RESULT_COORDINATES_IDX_INVISIBLE: u8 = 2;

// EVENTS
pub global NO_EVENT: u8 = 0 ;
pub global DESTROY: u8 = 1;          // actor_id = their_char or their_object when receive - no need to handle, only important to have on-chain for the client //use coordinates to determine tile or trap that got destroyed and update map
//pub global DISCOVER = 2;         // actor_id = their_char or their_object when receive - handle to update enemy positions, got health & class (this is for all chars, not just the active one)
//pub global SEE_COLUMN = 2 ;      // y = the column the player sees => update objects list
pub global SEE_MOVE: u8 = 3 ;        // actor_id = their_char or their_object when receive - no need to handle, only important to have on-chain for the client //handle to update enemy positions => DISCOVER
//pub global SEE_SPELL = 4 ;       // actor_id = their_char when receive - need to handle effect via coordinates, => RECEIVE_DAMAGE | DESTROY | LOSE // also need to handle my obstacles
pub global SEE_SEARCH_TRAP: u8 = 5 ; // actor_id = their_char when receive - need to create found trap event if there is a trap nearby => FOUND_TRAP
pub global SEE_RITUAL: u8 = 6 ;      // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
pub global SEE_CAST: u8 = 7;         // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
pub global SEE_DRAW: u8 = 8;         // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
//pub global RECEIVE_DAMAGE = 9;   // actor_id = their_char or their_object when receive - no need to handle, only important to have on-chain for the client
pub global RECEIVE_ATTACK: u8 = 10;  // actor_id = 0 when receive - need to handle damage => // no need to events ... health of visible assets gets sent anyway and invisible ones will be updated during discovery //RECEIVE_DAMAGE | DESTROY | LOSE // also need to handle in my obstacles
pub global TRIGGERED_TRAP: u8 = 11;  // actor_id = my_char when receive - need to handle damage (for now, later on we might want to handle other effects as well) => RECEIVE_DAMAGE
// pub global FOUND_TRAP: u8 = 12;      // actor_id = my_char when receive - no need to handle, only important to have on-chain for the client
pub global DISARMED_TRAP: u8 = 13;      // actor_id = their-char when receive - need to remove my trap from the map
pub global WIN: u8 = 14;
// pub global LOSE: u8 = 15;
pub global ADD_OBSTACLE: u8 = 4;
pub global EVENT_COUNT: u8 = 16;

// SUBTYPES:
pub global WIN_BY_RITUAL: u8 = 1;

// ATTACKS
pub global ATTACK_MELEE: u8 = 0;
pub global ATTACK_RANGED: u8 = 1;
pub global ATTACK_FIREBALL: u8 = 2;
// pub global ATTACK_COUNT: u8 = 3;
// TODO: instead of enum, use a pub global array of structs with damage, range, etc.


// TILES
pub global EMPTY: u8 = 0;
pub global WALL: u8 = 6;
pub global WATER: u8 = 7;
pub global MAX_DAMAGEABLE_TILE: u8 = 7;
// pub global UNKNOWN_CLASS_TILE: u8 = 8;
pub global NON_EMPTY_WALKABLE_TILE_MIN: u8 = 9;
// pub global FLAG: u8 = 9;
pub global TRAP: u8 = 10;
pub global TRAP_USED: u8 = 11;
pub global TRAP_FOUND: u8 = 12;
pub global BODY: u8 = 13;
pub global BODY_LOOTED: u8 = 14;
// pub global FOG: u8 = 15;
pub global MAX_OBSTACLE_TYPE: u8 = 0x0f;
// pub global TILE_COUNT: u8 = 16;
// unknown_class, flag, trap, trap_used, trap_found, body, body_looted, fog
// STATUS
pub global RITUAL_ROUNDS_FOR_WIN: u8 = 15;
pub global MIN_FIREBALL_ROUNDS_FOR_CAST: u8 = 3;
pub global MAX_FIREBALL_ROUNDS_FOR_CAST: u8 = 6;
// pub global DRAW_ROUNDS_FOR_SHOOT: u8 = 1;
pub global MIN_DRAW_ROUNDS_FOR_SHOOT: u8 = 1;
pub global MAX_DRAW_ROUNDS_FOR_SHOOT: u8 = 3;
pub global PROGRESS_BITS: u8 = 4;
pub global PROGRESS_MASK: u8 = (1 << PROGRESS_BITS) - 1;
pub global PROGRESS_COUNT: u8 = 16 ; // just to be more in line with the other constants, actually used as a counter
pub global MAX_HEALTH: u8 = 255;

// GAMEPLAY
pub global VIEW_DISTANCE: u8 = 6;
// pub global MAX_TRAPS: u32 = 8; // note: only lowest bit of first byte of field is usable! => ! Field = 1 bit + 31 bytes!
// pub global TRAPS_BUFFER_SIZE: Field = 16;
// pub global TRAPS_BUFFER_MASK: Field = 15; // has to be 2^n - 1
pub global MAX_ACTIONS: u32 = 4;
pub global MAX_EVENTS: u32 = 4; // = MAX_ACTIONS // NO! handle traps in a different way (by passing as argument!)+ 4 (2 FOUND_TRAP + WIN/LOSE + 1 reserved)
pub global MAX_OBSTACLES: u32 = 24; // leave traps for now + MAX_TRAPS; // 24 + 8 player placeables
pub global MAX_ENEMY_OBSTACLES: u32 = MAX_OBSTACLES + MAX_CHARACTERS;
pub global MAX_CHARACTERS: u32 = 5;
pub global MIN_PROGRESS: u8 = 0;
pub global MAX_PROGRESS: u8 = PROGRESS_COUNT - 1;
pub global SERIALIZED_OBSTACLE_BYTE_SIZE: u32 = 3;//3
pub global SERIALIZED_OBSTACLES_ARRAY_SIZE: u32 = 3;//3 // TODO: we take 3 because 3 x 8 = MAX_OBSTACLES ... should assert on this (MAX_OBSTACLES + MAX_CHARACTERS + 7) / 8;
pub global SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE: u32 = SERIALIZED_OBSTACLES_ARRAY_SIZE + 1; // +1 because enemy characters are also serialized as obstacles
pub global SERIALIZED_OBSTACLES_PER_FIELD: u32 = 8;//8 // TODO: need to verify that SERIALIZED_OBSTACLES_ARRAY_SIZE * SERIALIZED_OBSTACLES_PER_FIELD = MAX_OBSTACLES!
pub global SERIALIZED_EVENT_BYTE_SIZE: u32 = 7;
pub global SERIALIZED_EVENTS_ARRAY_SIZE: u32 = 1; // MAX_EVENTS / SERIALIZED_EVENTS_PER_FIELD => 4 / 4 = 1
pub global SERIALIZED_EVENTS_PER_FIELD: u32 = 4; // 31 / 7 = 4
pub global SERIALIZED_ACTION_BYTE_SIZE: u32 = 5;
pub global SERIALIZED_ACTIONS_ARRAY_SIZE: u32 = 1;
pub global SERIALIZED_ACTIONS_PER_FIELD: u32 = 4; // could be up to 6, but we only use 4


pub type SerializedArenaActionDefinitions = SerializedRosterActionDefinitions<MAX_ACTIONS_PER_CHARACTER, MAX_CHARACTERS>;
pub type SerializedArenaCharacterActionDefinitions = SerializedCharacterActionDefinitions<MAX_ACTIONS_PER_CHARACTER>;
pub type SerializedArenaCharacterActionDefinition = SerializedCharacterActionDefinition;
pub type ArenaCharacterActionDefinitions = [ActionDefinition; MAX_ACTIONS_PER_CHARACTER];
pub type SerializedArenaCharacterRoster = Field;
pub type SerializedArenaObstacles = [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE];
pub type SerializedArenaAction = Field;
pub type SerializedArenaActions = [SerializedArenaAction; SERIALIZED_ACTIONS_ARRAY_SIZE];
pub type SerializedArenaEnemyObstacles = [Field; SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE];
pub type SerializedArenaEvents = [Field; SERIALIZED_EVENTS_ARRAY_SIZE];

// pub comptime fn assert_ct(condition: bool, message: CtString) {
//   if !condition {
//     CtString()
//     panic(CtString("Comptime assertion failed: ")message);
//   }
// }

pub use character::get_test_action_register;
use skplg::NOWHERE;

#[export]
pub fn serialize_actions_0(actor_id: u8) -> pub SerializedArenaActions {
  serialize_actions(actor_id, &[])
}
#[export]
pub fn serialize_actions_1(actor_id: u8, action: Action) -> pub SerializedArenaActions {
  serialize_actions(actor_id, &[action])
}
#[export]
pub fn serialize_actions_2(actor_id: u8, actions: [Action; 2]) -> pub SerializedArenaActions {
  serialize_actions(actor_id, actions)
}
#[export]
pub fn serialize_actions_3(actor_id: u8, actions: [Action; 3]) -> pub SerializedArenaActions {
  serialize_actions(actor_id, actions)
}
#[export]
pub fn serialize_actions_4(actor_id: u8, actions: [Action; 4]) -> pub SerializedArenaActions {
  serialize_actions(actor_id, actions)
}

// pub global arena_action_serde: ActionSerDe = ActionSerDe::new(MAX_ACTIONS, MAX_ACTIONS_PER_CHARACTER as u8, WIDTH, HEIGHT, WAIT);

pub global arena_action_def_builder: ActionDefinitionBuilder = ActionDefinitionBuilder::new(
  WAIT,
  MIN_PROGRESS,
  MAX_PROGRESS,
  ACTION_RESULT_COORDINATES_IDX_SELF,
  ACTION_RESULT_COORDINATES_IDX_TARGET,
  ACTION_RESULT_COORDINATES_IDX_INVISIBLE,
  NO_EVENT,
  RECEIVE_ATTACK,
  SEE_CAST,
  SEE_DRAW,
  SEE_MOVE,
  SEE_RITUAL,
  SEE_SEARCH_TRAP,
  DISARMED_TRAP,
  ADD_OBSTACLE,
  WIN
);
pub global arena_test_action_def_register: SerializedArenaActionDefinitions = get_test_action_register();

#[test]
fn test_builder() {
  let action = arena_action_def_builder.build_cast_action(2, 8, 5, 1);

  assert(action[0] == 0);
}

global wait_action: ActionDefinition = [0, 0, 240, 0, 63, 0, 0, 1, 0, 32, 0, 0, 0, 0, 32, 0, 0, 0, 0, 32, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0, 0, 0];
pub fn get_wait_action_def() -> ActionDefinition {
  wait_action
}

#[test]
fn test_wait_action() {
  let wa = arena_action_def_builder.build_wait_action_def();
  let wag = get_wait_action_def();
  for i in 0..wa.len() {
    assert(wa[i] == wag[i]);
  }
}

  #[test]
  fn test_serde() {
    let actions = [
      new_action(1, 2, 3, 4),
      new_action(1, 2, 3, 4),
      new_action(1, 2, 3, 4),
      new_action(1, 2, 3, 4)
    ];
    let actions_serialized = serialize_actions(2, actions);
    let (actions_parsed_valid, actions_parsed) = parse_actions(MAX_CHARACTERS as u8, actions_serialized);
    assert(actions_parsed_valid);

    // println(actions_parsed);
    // println(actions);

    assert(actions_parsed.len() == actions.len());
  }

fn get_x_of_side(side: u1, x: u8) -> u8 {
    x * ((side as u8 + 1) as u1) as u8 + side as u8 * (WIDTH - 1 - x)
}

fn can_move_to(distance: u16, x: u8, y: u8, obstacles: [[u8; 5]; MAX_OBSTACLES], their_obstacles: [[u8; 5]]) -> bool {
  true
}

fn is_visible(x: u8, y: u8) -> bool {
  true
}

struct Event {
    pub event: u8,
    pub actor_id: u8,
    pub subtype: u8,
    pub x: u8,
    pub y: u8,
    pub value: u8,
    pub radius: u8,
}
fn build_subtype_value_event(event_type: u8, actor_id: u8, x: u8, y: u8, value: u8, event_subtype: u8, radius: u8) -> Event {
    Event {
        event: event_type,
        actor_id: actor_id,
        x: x,
        y: y,
        value: value,
        subtype: event_subtype,
        radius: radius,
    }
}

fn execute_action(
    action: Action,
    enemy_advance: u8,
    // actor: Character,
    mut energy: u8,
    my_obstacles: [[u8; 5]; MAX_OBSTACLES],
    their_obstacles: [[u8; 5]]
) -> (bool, Event, Event, Event, u8) {
  let mut is_valid = true;
  let ad = arena_action_def_builder.build_move_action(4);

  let action_type = get_action_type(action);
  let action_target_x =get_action_target_x(action);
  let action_target_y = get_action_target_y(action);
  let actor_id = get_action_actor(action);
  let actor_x = 3 as u8;
  let actor_y = 5 as u8;
  let actor_is_hidden = false;
  let actor_is_in_view_range = true;
  let distance: u16 = 1;
  let actor_status = 0 as u8;
  let mut is_not_interrupted = true;
  let mut actor_progress = 0 as u8;
  let actor_target_x = 4 as u8;
  let actor_target_y = 5 as u8;
  let actor_last_action = 0 as u8;
  

  validate_action_requirements!(quote { is_valid }, quote { ad });
  apply_action_pre_calc_effects!(quote { ad });

  let coords = [
    (actor_x, actor_y),
    (action_target_x, action_target_y),
    (NOWHERE, NOWHERE)
  ];

          let mut events: BoundedVec<Event, 4> = BoundedVec::new();
        build_result_event!(0 as u32, quote { events }, quote { is_valid }, quote { ad });
        build_result_event!(1 as u32, quote { events }, quote { is_valid }, quote { ad });
        build_result_event!(2 as u32, quote { events }, quote { is_valid }, quote { ad });
        build_result_event!(3 as u32, quote { events }, quote { is_valid }, quote { ad });


        assert(events.len() == 4);

        let mut result_energy = energy;
        let mut result_coords = (action_target_x, action_target_y);
        let mut result_progress = actor_progress;
        let mut result_is_hidden = actor_is_hidden;
        let mut result_is_visible = actor_is_in_view_range;
        let mut result_damage_mod = 0 as u8;
        let mut result_health = 123 as u8;
        let mut result_status = actor_status;
  apply_action_result_effects!(quote { ad });
    
  assert(is_valid);
    (is_valid, events.get(0), events.get(2), events.get(3), energy)
}

#[test]
fn test_action_shite() {
  let action = new_action(1, 2, 4, 5);
  let mut energy = 8 as u8;
  let enemy_advance = 15 as u8;
  let my_obstacles = [[0 as u8; 5]; MAX_OBSTACLES];
  let their_obstacles = [[0 as u8; 5]; MAX_OBSTACLES];

  let result = execute_action(action, enemy_advance, energy, my_obstacles, their_obstacles);
  assert(result.0);
}
//   #[test]
//   fn test_action_execution() {
//     let x = |x| get_x_of_side(side, x); //(((side as u8) + 1) % 2) + (WIDTH - 1 - x) * (side as u8);
//     [
//         new_obstacle( 0, x(0), 2, 200, WALL).1,
//         new_obstacle( 1, x(1), 2, 200, WALL).1,
//         new_obstacle( 2, x(3), 2, 200, WALL).1,
//         new_obstacle( 3, x(4), 2, 200, WALL).1,
//         new_obstacle( 4, x(5), 3, 200, WALL).1,
//         new_obstacle( 5, x(5), 4, 200, WALL).1,
//         new_obstacle( 6, x(5), 5, 200, WALL).1,
//         new_obstacle( 7, x(5), 7, 200, WALL).1,
//         new_obstacle( 8, x(4), 7, 200, WALL).1,
//         new_obstacle( 9, x(3), 7, 200, WALL).1,
//         new_obstacle(10, x(1), 7, 200, WALL).1,
//         new_obstacle(11, x(0), 7, 200, WALL).1,
//         new_obstacle(12, x(7), 0, 200, WALL).1,
//         new_obstacle(13, x(7), 1, 200, WALL).1,
//         new_obstacle(14, x(7), 2, 200, WALL).1,
//         new_obstacle(15, x(7), 3, 200, WALL).1,
//         new_obstacle(16, x(7), 4, 200, WALL).1,
//         new_obstacle(17, x(7), 5, 200, WALL).1,
//         new_obstacle(18, x(6), 8, 255, WATER).1,
//         new_obstacle(19, x(7), 8, 255, WATER).1,
//         new_obstacle(20, x(5), 9, 255, WATER).1,
//         new_obstacle(21, x(6), 9, 255, WATER).1,
//         new_obstacle(22, x(7), 9, 255, WATER).1,
//         new_obstacle(23, x(8), 9, 255, WATER).1,
//         // new_obstacle(24, x(0), 0, 255, EMPTY).1,
//         // new_obstacle(25, x(0), 0, 255, EMPTY).1,
//         // new_obstacle(26, x(0), 0, 255, EMPTY).1,
//         // new_obstacle(27, x(0), 0, 255, EMPTY).1,
//         // new_obstacle(28, x(0), 0, 255, EMPTY).1,
//         // new_obstacle(29, x(0), 0, 255, EMPTY).1,
//         // new_obstacle(30, x(0), 0, 255, EMPTY).1,
//         // new_obstacle(31, x(0), 0, 255, EMPTY).1,
//     ];
//     let enemy_advance: 15,
//     let mut energy = 8,
//     let my_obstacles: [Obstacle; MAX_OBSTACLES] = 
//     their_obstacles: [Obstacle]
//     let mut is_valid = true;
//     let action_type = 2;

//     let actor_id = 1;
//     let actor_x = 3;
//     let actor_y = 4;
//     let action_def = arena_action_def_builder.build_move_action(4)
//     let (action_def_valid, action_def) = actor.get_action(action_type);
//     softassert!(quote { is_valid }, quote { action_def_valid }, quote { f"Failed to fetch action def of {action_type}" });

//     let action_target_x = get_action_target_x(action);
//     let action_target_y = get_action_target_y(action);
//     let distance = get_distance(actor_x, actor_y, action_target_x, action_target_y);

//     // let is_continuous = action.get_action_is_continuous();
//     // let is_not_interrupted = (
//     //     ((!is_continuous) & (action.get_action_result_status_multiplier() != 0)) | // that's the ID of the wait action => leave status, but not continuous
//     //     ((is_continuous) & (action.get_action_req_previous_action() == c.last_action) & (action_target_x == c.get_target_x()) & (action_target_y == c.get_target_y()))
//     // );


//     let mut actor_progress = actor.get_progress();
//     let mut actor_is_hidden = actor.get_is_hidden() == 1;
//     let actor_is_in_view_range = is_visible(enemy_advance, actor_x);
//     // let max_range_part = get_action_req_max_range(action) as u16;
//     // let mut actor_max_range = max_range_part * max_range_part;
//     let mut is_not_interrupted = true;
//     let mut actor_damage_mod = actor.get_damage_mod();
//     let mut actor_status = actor.get_status();
//     apply_action_pre_calc_effects!(quote { action_def });


// ///////////////////////////
//     validate_action_requirements!(quote { is_valid }, quote { action_def });

//         let coords = [
//             (actor_x, actor_y),
//             (action_target_x, action_target_y),
//             (NOWHERE, NOWHERE),
//             (NOWHERE, NOWHERE),
//         ];
//         // CALCULATE EVENTS
//         comptime {
//           assert(SEEN_EVENT_IDX == 1);
//           assert(UNSEEN_EVENT_IDX == 0);
//         }
//         //let result_event_idx = is_visible as u32;
//         let mut events: BoundedVec<Event, 4> = BoundedVec::new();
//         build_result_event!(0 as u32, quote { events }, quote { is_valid }, quote { action_def });
//         assert(events.len() == 4);


//         // APPLY EFFECTS ON SELF
//         let mut result_energy = energy;
//         let mut result_coords = coords[0];
//         let mut result_progress = actor_progress;
//         let mut result_is_hidden = actor_is_hidden;
//         let mut result_is_visible = actor_is_in_view_range;
//         let mut result_damage_mod = actor_damage_mod;
//         let mut result_health = actor.get_health();
//         let mut result_status = actor_status;


//         // let energy = std::wrapping_sub(energy, action.get_action_req_energy());
//         // let status = actor_progress as u32 * action.get_action_result_status_multiplier() as u32 + action.get_action_result_status_fixed_addition() as u32;
//         // softassert!(quote { is_valid }, quote { status <= MAX_STATUS as u32 }, quote { f"Invalid result status: {status} > {MAX_STATUS}" });

//         // let final_coords = coords[action.get_action_move_to_target() as u8];
//         // // debug!(quote { println(f"final_coords:{final_coords}"); });
//         // let is_hidden = ((c.is_hidden == 1) & !action.get_action_result_effect_removes_status_hidden()) | action.get_action_result_effect_sets_status_hidden();
//         // let is_visible = !is_hidden & is_visible(enemy_advance, final_coords.0);
//         apply_action_result_effects!(quote { action_def });

//         // let target_coords = [
//         //     (target_x, target_y),
//         //     (c.get_target_x(), c.get_target_y())
//         // ];

//         (
//             is_valid,
//             if result_is_visible { events.get_unchecked(SEEN_EVENT_IDX) } else { events.get_unchecked(UNSEEN_EVENT_IDX) },//events[1 + (is_visible as u8)],
//             events.get_unchecked(WORLD_EVENT_IDX),
//             events.get_unchecked(SELF_EVENT_IDX),//events[get_action_unseen_event_is_internal(action_def) as u8],
//             Character {
//                 id: actor_id,
//                 x: result_coords.0,
//                 y: result_coords.1,
//                 progress: result_progress, // status as u8,
//                 is_hidden: result_is_hidden as u1, //is_hidden as u1,
//                 has_been_seen: result_is_visible, //is_visible,
//                 last_action: is_not_interrupted as u8 * actor.get_last_action() + (!is_not_interrupted) as u8 * action_type,
//                 target_x: is_not_interrupted as u8 * actor.get_target_x() + (!is_not_interrupted) as u8 * action_target_x, // if is_not_interrupted { c.get_target_x() } else { get_action_target_x(action) };
//                 target_y: is_not_interrupted as u8 * actor.get_target_y() + (!is_not_interrupted) as u8 * action_target_y,
//                 class: actor.class,
//                 damage_mod: result_damage_mod,
//                 health: result_health,
//                 status: result_status,
//                 actions: actor.actions,
//                 wait_action: actor.wait_action
//             },
//             result_energy
//         )

//   }

#[test]
fn test_exp() {
  let x = 1 << (0 as u8);
  assert(x == 1, f"{x} != 1");

  let mut events: BoundedVec<u8, 4> = BoundedVec::new();

  events.push(1);
  events.push(2);
  events.push(3);
  events.push(4);

  assert(events.len() == 4);
}