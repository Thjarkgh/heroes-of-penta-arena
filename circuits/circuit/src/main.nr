// mod action;
// use action::Action;
// mod character;
// use character::Character;
// use character::parse_characters;
// mod event;
// use event::Event;
// mod obstacle;
// use obstacle::Obstacle;
// mod map;
// use dep::std;

// // MAP
// global WIDTH_BITS: u8 = 5;
// global WIDTH_MASK: u8 = (1 << WIDTH_BITS) - 1;
// global WIDTH: u8 = 1 << WIDTH_BITS;
// global HEIGHT_BITS: u8 = 4;
// global HEIGHT_MASK: u8 = (1 << HEIGHT_BITS) - 1;
// global HEIGHT: u8 = 10;
// global NOWHERE: u8 = 255;

// // CLASSES
// global UNKNOWN_CLASS: u8 = 0;
// global ARCHER: u8 = 1;
// global RITUALIST: u8 = 2;
// global ROGUE: u8 = 3;
// global KNIGHT: u8 = 4;
// global MAGE: u8 = 5;
// global CLASS_BITS: u8 = 3;
// global CLASS_MASK: u8 = (1 << CLASS_BITS) - 1;
// global CLASS_COUNT: u8 = 6;

// // ACTIONS
// global WAIT: u8 = 0;
// global SNEAK: u8 = 1;
// global MOVE: u8 = 2;          // => SEE_COLUMN (depr: MOVE)
// global RITUAL: u8 = 3;        // => SEE_RITUAL | WIN
// global SEARCH: u8 = 4;        // => SEE_SEARCH_TRAP
// global ATTACK: u8 = 5;        // => RECEIVE_ATTACK | DESTROY // affects my obstacles; TODO: with more attack types might also affect other own characters
// global SET_TRAP: u8 = 6;
// global CAST_FIREBALL: u8 = 7; // => SEE_CAST | SEE_SPELL | DESTROY // affects other characters if status == FIREBALL_ROUNDS_FOR_CAST
// global DRAW: u8 = 8;          // => SEE_DRAW
// global SHOOT: u8 = 9;         // => RECEIVE_ATTACK
// //global TRIGGER_TRAP = 9;  // => TRIGGERED_TRAP ?????????
// global DISARM_TRAP: u8 = 10;  // => DESTROY
// global ACTION_COUNT: u8 = 11;

// // EVENTS
// global NO_EVENT: u8 = 0 ;
// global DESTROY: u8 = 1;          // actor_id = their_char or their_object when receive - no need to handle, only important to have on-chain for the client //use coordinates to determine tile or trap that got destroyed and update map
// //global DISCOVER = 2;         // actor_id = their_char or their_object when receive - handle to update enemy positions, got health & class (this is for all chars, not just the active one)
// //global SEE_COLUMN = 2 ;      // y = the column the player sees => update objects list
// global SEE_MOVE: u8 = 3 ;        // actor_id = their_char or their_object when receive - no need to handle, only important to have on-chain for the client //handle to update enemy positions => DISCOVER
// //global SEE_SPELL = 4 ;       // actor_id = their_char when receive - need to handle effect via coordinates, => RECEIVE_DAMAGE | DESTROY | LOSE // also need to handle my obstacles
// global SEE_SEARCH_TRAP: u8 = 5 ; // actor_id = their_char when receive - need to create found trap event if there is a trap nearby => FOUND_TRAP
// global SEE_RITUAL: u8 = 6 ;      // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
// global SEE_CAST: u8 = 7;         // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
// global SEE_DRAW: u8 = 8;         // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
// //global RECEIVE_DAMAGE = 9;   // actor_id = their_char or their_object when receive - no need to handle, only important to have on-chain for the client
// global RECEIVE_ATTACK: u8 = 10;  // actor_id = 0 when receive - need to handle damage => // no need to events ... health of visible assets gets sent anyway and invisible ones will be updated during discovery //RECEIVE_DAMAGE | DESTROY | LOSE // also need to handle in my obstacles
// global TRIGGERED_TRAP: u8 = 11;  // actor_id = my_char when receive - need to handle damage (for now, later on we might want to handle other effects as well) => RECEIVE_DAMAGE
// global FOUND_TRAP: u8 = 12;      // actor_id = my_char when receive - no need to handle, only important to have on-chain for the client
// global WIN: u8 = 13;
// global LOSE: u8 = 14;
// global EVENT_COUNT: u8 = 15;

// // ATTACKS
// global ATTACK_MELEE: u8 = 0;
// global ATTACK_RANGED: u8 = 1;
// global ATTACK_FIREBALL: u8 = 2;
// global ATTACK_COUNT: u8 = 3;
// // TODO: instead of enum, use a global array of structs with damage, range, etc.


// // TILES
// global EMPTY: u8 = 0;
// global WALL: u8 = 6;
// global WATER: u8 = 7;
// global UNKNOWN_CLASS_TILE: u8 = 8;
// global NON_EMPTY_WALKABLE_TILE_MIN: u8 = 9;
// global FLAG: u8 = 9;
// global TRAP: u8 = 10;
// global TRAP_USED: u8 = 11;
// global TRAP_FOUND: u8 = 12;
// global BODY: u8 = 13;
// global BODY_LOOTED: u8 = 14;
// global FOG: u8 = 15;
// global TILE_COUNT: u8 = 16;

// // STATUS
// #[export]
// global RITUAL_ROUNDS_FOR_WIN: u8 = 16;
// global FIREBALL_ROUNDS_FOR_CAST: u8 = 3;
// global DRAW_ROUNDS_FOR_SHOOT: u8 = 1;
// global MIN_DRAW_ROUNDS_FOR_SHOOT: u8 = 1;
// global MAX_DRAW_ROUNDS_FOR_SHOOT: u8 = 3;
// global STATUS_BITS: u8 = 4;
// global STATUS_MASK: u8 = (1 << STATUS_BITS) - 1;
// global STATUS_COUNT: u8 = 16 ; // just to be more in line with the other constants, actually used as a counter

// // GAMEPLAY
// global VIEW_DISTANCE: u8 = 6;
// global MAX_TRAPS: Field = 15; // note: only lowest bit of first byte of field is usable! => ! Field = 1 bit + 31 bytes!
// global TRAPS_BUFFER_SIZE: Field = 16;
// global TRAPS_BUFFER_MASK: Field = 15; // has to be 2^n - 1
// global MAX_ACTIONS: u32 = 4;
// global MAX_EVENTS: u32 = 4; // = MAX_ACTIONS // NO! handle traps in a different way (by passing as argument!)+ 4 (2 FOUND_TRAP + WIN/LOSE + 1 reserved)
// global MAX_OBSTACLES: u32 = 24;
// global MAX_CHARACTERS: u32 = 5;
//global SERIALIZED_OBSTACLE_BYTE_SIZE: u32 = 3;
//global SERIALIZED_OBSTACLES_ARRAY_SIZE: u32 = 3; // TODO: we take 3 because 3 x 8 = MAX_OBSTACLES ... should assert on this (MAX_OBSTACLES + MAX_CHARACTERS + 7) / 8;
//global SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE: u32 = SERIALIZED_OBSTACLES_ARRAY_SIZE + 1; // +1 because enemy characters are also serialized as obstacles
//global SERIALIZED_OBSTACLES_PER_FIELD: u32 = 8; // TODO: need to verify that SERIALIED_OBSTACLES_ARRAY_SIZE * SERIALIZED_OBSTACLES_PER_FIELD = MAX_OBSTACLES!
//global SERIALIZED_EVENT_BYTE_SIZE: u32 = 7;
//global SERIALIZED_EVENTS_ARRAY_SIZE: u32 = 1; // MAX_EVENTS / SERIALIZED_EVENTS_PER_FIELD => 4 / 4 = 1
//global SERIALIZED_EVENTS_PER_FIELD: u32 = 4; // 31 / 7 = 4
//global SERIALIZED_ACTION_BYTE_SIZE: u32 = 5;
//global SERIALIZED_ACTIONS_ARRAY_SIZE: u32 = 1;
//global SERIALIZED_ACTIONS_PER_FIELD: u32 = 4; // could be up to 6, but we only use 4
// global UNREADABLE_BYTES_PER_FIELD: u32 = 1;

// #[export]
// fn get_actor_from_move(mut move: u32) -> u8 {
//     if (move % 2) == 1 {
//         move -= 1; //((move % 10) - 1) >> 1 // actually not needed ... but clearer this way
//     }
//     let single_digit: u32 = (move % 10 as u32) >> 1;
//     single_digit as u8
// }

use skpl::{turn, SERIALIZED_OBSTACLES_ARRAY_SIZE, SERIALIZED_ACTIONS_ARRAY_SIZE, SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE, SERIALIZED_EVENTS_ARRAY_SIZE };


fn main(
    // My Secret State
    secret: Field,
    my_chars_input: Field,
    //my_char_actions: [u8; ACTION_DEFINITION_REGISTER_SIZE],
    my_obstacles_input: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE],
    actions: [Field; SERIALIZED_ACTIONS_ARRAY_SIZE],
    // Common Inputs
    move: pub Field,
    // Enemy Inputs
    enemy_advance: pub Field,
    enemy_objects: pub [Field; SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE],
    enemy_events: pub [Field; SERIALIZED_EVENTS_ARRAY_SIZE], //MAX_EVENTS],
    // My Results
    my_result_advance: pub Field, // 1 bit win, 1 bit lose, 1 bit reserved, 5 bits advance
    my_result_objects: pub [Field; SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE],
    my_result_events: pub [Field; SERIALIZED_EVENTS_ARRAY_SIZE],
    // Gamestate Hashes
    gamestate_before_hash: pub Field,
    gamestate_after_hash: pub Field,
) {
    // let (events_valid, events) = Event::parse_their_events(enemy_events);
    // assert(events_valid, f"Failed to parse their events {events}");
    // let (valid, my_obstacles_parsed) = parse_my_obstacles(my_obstacles, events);
    // assert(valid, f"Failed to parse my obstacles {my_obstacles}");
    let valid = turn(secret, my_chars_input, my_obstacles_input, actions, move as u32, enemy_advance as u8, enemy_objects, enemy_events, my_result_advance as u8, my_result_events, my_result_objects, gamestate_before_hash, gamestate_after_hash);
    assert(valid, "Invalid turn");
    // // Validate global constants (to make sure one didn't change one without updating dependet ones)
    // assert(SERIALIZED_EVENTS_PER_FIELD * SERIALIZED_EVENTS_ARRAY_SIZE == MAX_EVENTS);
    // assert(SERIALIZED_OBSTACLES_PER_FIELD * SERIALIZED_OBSTACLES_ARRAY_SIZE == MAX_OBSTACLES);

    // let secret_be_bytes: [u8; 32] = secret.to_be_bytes();
    // assert(secret_be_bytes.len() == 32);
    // let my_chars_be_bytes: [u8; 32] = my_chars.to_be_bytes();
    // assert(my_chars_be_bytes.len() == 32);
    // let gamestate_before_hash_calculated = get_data_hash(secret_be_bytes, my_chars_be_bytes, my_obstacles);
    // let gamestate_before_hash_calculated_field = std::field::bytes32_to_field(gamestate_before_hash_calculated);
    // assert(gamestate_before_hash == gamestate_before_hash_calculated_field, f"{gamestate_before_hash} != {gamestate_before_hash_calculated_field}");

    // // TODO: Validate map => check that initial setup is ok => unique ids and no coordination overlaps!

    // let events: [Event; MAX_EVENTS] = Event::parse_events(events);
    
    // let side = move as u1;
    // let mut my_chars = parse_characters(my_chars, events, enemy_advance, side);

    // let actor_id = get_actor_from_move(move);
    // let mut actor = my_chars[actor_id]; //Character::parse(actor_id, my_chars, events);
    
    // let actions = Action::parse_actions(actions); // actions.map(|action| Action::from_field(action));
    
    // assert(MAX_OBSTACLES == 24);
    // let mut my_obstacles_parsed = Obstacle::parse_my_obstacles(my_obstacles, events).as_array();
    // // TODO: validate obstacles => check that initial setup is ok => unique ids and no coordination overlaps!

    // // Note: no need to validate enemy obstacles => opponent proof verifies that they are correct already!
    // let enemy_objects_parsed = Obstacle::parse_their_obstacles(enemy_objects);

    // let mut energy: u8 = 12;
    // let mut result_events_calculated: [Event] = &[];
    // for i in 0..MAX_ACTIONS {
    //     // TODO: ensure that if actor committed suicide, it is not allowed to do any more actions
    //     let action = actions[i];
    //     let result = action.execute(side, enemy_advance, actor, energy, my_obstacles_parsed, enemy_objects_parsed);
    //     let result_event = result.0;
    //     actor = result.1;
    //     energy = result.2;
        
    //     my_chars = my_chars.map(|c| wb_apply_damage_to_char(c, result_event, actor));
    //     my_obstacles_parsed = my_obstacles_parsed.map(|obstacle| update_my_obstacle(obstacle, result_event));

    //     result_events_calculated = result_events_calculated.push_back(result_event);
    // }
    // let result_events_calculated = Event::serialize_events(result_events_calculated);
    // assert(result_events_calculated.len() == SERIALIZED_EVENTS_ARRAY_SIZE);
    // for i in 0..SERIALIZED_EVENTS_ARRAY_SIZE {
    //     let result_event_calculated = result_events_calculated[i];
    //     let result_event_should = my_result_events[i];
    //     assert(result_event_should == result_event_calculated, f"Invalid result event {i}: {result_event_should} != {result_event_calculated}");
    // }

    // // send death events => no need

    // // determine view range
    // let mut my_advance_calculated = 0;
    // if side == 0 {
    //     for i in 0..MAX_CHARACTERS {
    //         if my_chars[i].x > my_advance_calculated {
    //             my_advance_calculated = my_chars[i].x;
    //         }
    //     }
    //     my_advance_calculated += VIEW_DISTANCE;
    // } else {
    //     my_advance_calculated = WIDTH - 1;
    //     for i in 0..MAX_CHARACTERS {
    //         if my_chars[i].x < my_advance_calculated {
    //             my_advance_calculated = my_chars[i].x;
    //         }
    //     }
    //     my_advance_calculated -= VIEW_DISTANCE;
    // }
    // assert(my_advance == my_advance_calculated, f"{my_advance} != {my_advance_calculated}");

    // // validate result
    // let serialized_characters = serialize_chars(my_chars);
    // let serialized_obstacles: [Field] = Obstacle::serialize_obstacles(side, enemy_advance, my_obstacles_parsed);
    // assert(serialized_obstacles.len() == SERIALIZED_OBSTACLES_ARRAY_SIZE);
    // // println(secret);
    // // println(serialized_characters);
    // // println(serialized_obstacles);
    // let serialized_characters_be_bytes: [u8; 32] = serialized_characters.to_be_bytes();
    // assert(serialized_characters_be_bytes.len() == 32);
    // let new_hash_bytes = get_data_hash(secret_be_bytes, serialized_characters_be_bytes, serialized_obstacles.as_array());
    // let new_hash = std::field::bytes32_to_field(new_hash_bytes);
    // let serialized_obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE + 1] = serialized_obstacles.push_back(serialize_chars_as_obstacles(my_chars)).as_array();
    // for i in 0..my_result_objects.len() {
    //     let my_result_object = my_result_objects[i];
    //     let serialized_obstacle = serialized_obstacles[i];
    //     assert(my_result_object == serialized_obstacle, f"{i}: {my_result_object} != {serialized_obstacle}");
    // }
    // assert(new_hash == gamestate_after_hash, f"{new_hash} != {gamestate_after_hash}");
}

// fn wb_apply_damage_to_char(mut c: Character, event: Event, actor: Character) -> Character {
//     if c.id == actor.id {
//         c = actor;
//     }
//     apply_damage_to_char(c, event)
// }

// fn apply_damage_to_char(c: Character, event: Event) -> Character {
//     let dmg = event.get_applied_damage_to_my_asset(c.x, c.y, c.class);
//     Character {
//         id: c.id,
//         x: c.x,
//         y: c.y,
//         class: c.class,
//         health: safe_subtract_dmg(c.health, dmg),
//         status: c.status,
//         target_x: c.target_x,
//         target_y: c.target_y,
//         has_been_seen: c.has_been_seen,
//         is_hidden: c.is_hidden,
//         damage_mod: c.damage_mod,
//     }
// }
// fn update_my_obstacle(obstacle: Obstacle, event: Event) -> Obstacle {
//     let dmg = event.get_applied_damage_to_my_asset(obstacle.x, obstacle.y, obstacle.obstacle_type);
//     Obstacle {
//         health: safe_subtract_dmg(obstacle.health, dmg),
//         id: obstacle.id,
//         x: obstacle.x,
//         y: obstacle.y,
//         obstacle_type: obstacle.obstacle_type,
//     }
// }

// fn get_data_hash(secret: [u8], characters: [u8], obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE]) -> [u8; 32] {
//     assert(secret.len() == 32);
//     assert(characters.len() == 32);

//     let mut data: [u8; 32 + 32 + SERIALIZED_OBSTACLES_ARRAY_SIZE * 32] = [0; 32 + 32 + SERIALIZED_OBSTACLES_ARRAY_SIZE * 32];
//     for i in 0..32 {
//         data[i] = secret[i];
//         data[i + 32] = characters[i];
//     }
//     let offset = 32 + 32;
//     for i in 0..SERIALIZED_OBSTACLES_ARRAY_SIZE {
//         let obstacle: [u8; 32] = obstacles[i].to_be_bytes();
//         assert(obstacle.len() == 32);
//         for j in 0..32 {
//             data[offset + i * 32 + j] = obstacle[j];
//         }
//     }
//     // let offset = WIDTH * HEIGHT + 32 * 3;
//     // for i in 0..10 {
//     //     data[offset + i * 4] = (searched_traps[i] & 255) as u8;
//     //     data[offset + i * 4 + 1] = ((searched_traps[i] >> 8) & 255) as u8;
//     //     data[offset + i * 4 + 2] = ((searched_traps[i] >> 16) & 255) as u8;
//     //     data[offset + i * 4 + 3] = ((searched_traps[i] >> 24) & 255) as u8;
//     // }
//     std::hash::blake3(data)
// }

// fn serialize_chars(chars: [Character; MAX_CHARACTERS]) -> Field {
//     assert(MAX_CHARACTERS <= 5);
//     let mut result: [u8; 32] = [0; 32];
//     for i in 0..MAX_CHARACTERS {
//         let serialized = chars[i].serialize();
//         for j in 0..6 {
//             result[2 + i * 6 + j] = serialized[j];
//         }
//     }
//     std::field::bytes32_to_field(result)
// }

// fn serialize_chars_as_obstacles(chars: [Character; MAX_CHARACTERS]) -> Field {
//     let mut result: [u8; 32] = [0; 32];
//     for i in 0..MAX_CHARACTERS {
//         let char_as_obstacle = chars[i].to_obstacle();
//         let serialized = char_as_obstacle.serialize();
//         result[2 + i * 3] = serialized[0];
//         result[2 + i * 3 + 1] = serialized[1];
//         result[2 + i * 3 + 2] = serialized[2];
//     }
//     std::field::bytes32_to_field(result)
// }

// fn safe_subtract_dmg(a: u8, b: u16) -> u8 {
//     let mut result = 0;
//     if (a as u16) > b {
//         result = a - (b as u8);
//     }
//     result
// }

// fn test_result_object_builder(chars: [Character; MAX_CHARACTERS], obs: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE]) -> [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE + 1] {
//     let mut result: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE + 1] = [0; SERIALIZED_OBSTACLES_ARRAY_SIZE + 1];
//     for i in 0..SERIALIZED_OBSTACLES_ARRAY_SIZE {
//         result[i] = obs[i];
//     }
//     result[SERIALIZED_OBSTACLES_ARRAY_SIZE] = serialize_chars_as_obstacles(chars);
//     result
// }

// fn test_helper_roster(actor: Character, mut chars: [Character; MAX_CHARACTERS]) -> [Character; MAX_CHARACTERS] {
//     chars[actor.id] = actor;
//     chars
// }

// fn test_helper_execute_move(move: u32, actor: Character, advances: [u8; 2], secret: [Field; 2], last_hashes: [Field; 2], chars: [[Character; MAX_CHARACTERS]; 2], obs: [[Obstacle; MAX_OBSTACLES]; 2], actions: [Action], my_events: [Event], their_events: [Event]) -> (u32, [Character; MAX_CHARACTERS], Field) {
//     let side = move as u1;
//     let other_side = (side as u8 + 1) as u1;
//     let chars_after = test_helper_roster(actor, chars[side]);
//     let my_obstacles_serialized = Obstacle::serialize_obstacles(side, advances[other_side], obs[side]);
//     let secret_be_bytes: [u8; 32] = secret[side].to_be_bytes();
//     assert(secret_be_bytes.len() == 32);
//     let serialized_chars_after = serialize_chars(chars_after);
//     let serialized_chars_after_be_bytes: [u8; 32] = serialized_chars_after.to_be_bytes();
//     assert(serialized_chars_after_be_bytes.len() == 32);
//     let current_hash = std::field::bytes32_to_field(get_data_hash(secret_be_bytes, serialized_chars_after_be_bytes, my_obstacles_serialized)); 

//     main(
//         secret[side],
//         character::serialize_chars(chars[side]),
//         my_obstacles_serialized,
//         Action::serialize_actions(actions),
//         move,
//         advances[other_side],
//         test_result_object_builder(chars[other_side], Obstacle::serialize_obstacles(other_side, advances[side], obs[other_side])),
//         Event::serialize_events(their_events).as_array(),
//         advances[side],
//         Event::serialize_events(my_events).as_array(),
//         test_result_object_builder(chars_after, my_obstacles_serialized),
//         last_hashes[side],
//         current_hash
//     );

//     (move + 1, chars_after, current_hash)
// }

// // #[test]
// // fn test_main() {
// //     let secrets = [123456789, 9876543210];
// //     let mut chars = [ character::get_default_characters(0), character::get_default_characters(1) ];
// //     let mut obs = [ Obstacle::get_default_obstacles(0), Obstacle::get_default_obstacles(1) ];
// //     let actions = &[
// //         Action { action: MOVE, actor: 0, target_x: 2, target_y: 1 },
// //         Action { action: MOVE, actor: 0, target_x: 3, target_y: 1 },
// //         Action { action: MOVE, actor: 0, target_x: 4, target_y: 1 },
// //         Action { action: MOVE, actor: 0, target_x: 5, target_y: 1 },
// //     ];
// //     let their_events: [Event] = &[Event::empty(0); MAX_EVENTS];
// //     let my_events: [Event] = &[Event::empty(0); MAX_EVENTS];
// //     let mut move = 0;
// //     let mut actor = chars[0][0].move(5, 1);
// //     let mut last_hashes = [ 0x12b8f97907a05ec6a77da3f70368fa3b02e166c74edab8ea0695d6f406146559, 0x2bca22f32b0b864574d0509ba146be256d2186fc490311756f541e1b5f8e391f ];
// //     let mut advances = [2 + VIEW_DISTANCE, 29 - VIEW_DISTANCE];
// //     advances[0] = 5 + VIEW_DISTANCE;

// //     let mut side = move % 2;
// //     let result = test_helper_execute_move(move, actor, advances, secrets, last_hashes, chars, obs, actions, my_events, their_events);
// //     move = result.0;
// //     chars[side] = result.1;
// //     last_hashes[side] = result.2;

// //     side = move % 2;
// //     let actions = &[
// //         Action { action: MOVE, actor: 0, target_x: 29, target_y: 1 },
// //         Action { action: MOVE, actor: 0, target_x: 28, target_y: 1 },
// //         Action { action: MOVE, actor: 0, target_x: 28, target_y: 0 },
// //         Action { action: MOVE, actor: 0, target_x: 27, target_y: 0 },
// //     ];
// //     let their_events = my_events;
// //     let my_events: [Event] = &[Event::empty(0); MAX_EVENTS];
// //     let actor = chars[side][((move as u64 / 2) % MAX_CHARACTERS)].move(27, 0);
// //     advances[side] = 27 - VIEW_DISTANCE;
// //     let result = test_helper_execute_move(move, actor, advances, secrets, last_hashes, chars, obs, actions, my_events, their_events);
// //     move = result.0;
// //     chars[side] = result.1;
// //     last_hashes[side] = result.2;

// //     side = move % 2;
// //     let actions = &[
// //         Action { action: MOVE, actor: 1, target_x: 1, target_y: 3 },
// //         Action { action: MOVE, actor: 1, target_x: 0, target_y: 3 },
// //         Action { action: WAIT, actor: 1, target_x: 0, target_y: 0 },
// //         Action { action: WAIT, actor: 1, target_x: 0, target_y: 0 },
// //     ];
// //     let their_events = my_events;
// //     let my_events: [Event] = &[Event::empty(1); MAX_EVENTS];
// //     let actor = chars[side][((move as u64 / 2) % MAX_CHARACTERS)].move(0, 3);
// //     //advances[side] = 27 - VIEW_DISTANCE;
// //     let result = test_helper_execute_move(move, actor, advances, secrets, last_hashes, chars, obs, actions, my_events, their_events);
// //     move = result.0;
// //     chars[side] = result.1;
// //     last_hashes[side] = result.2;

// //     side = move % 2;
// //     let actions = &[
// //         Action { action: MOVE, actor: 1, target_x: 29, target_y: 2 },
// //         Action { action: MOVE, actor: 1, target_x: 29, target_y: 1 },
// //         Action { action: MOVE, actor: 1, target_x: 28, target_y: 1 },
// //         Action { action: WAIT, actor: 1, target_x: 0, target_y: 0 },
// //     ];
// //     let their_events = my_events;
// //     let my_events: [Event] = &[Event::empty(1); MAX_EVENTS];
// //     let actor = chars[side][((move as u64 / 2) % MAX_CHARACTERS)].move(28, 1);
// //     //advances[side] = 27 - VIEW_DISTANCE;
// //     let result = test_helper_execute_move(move, actor, advances, secrets, last_hashes, chars, obs, actions, my_events, their_events);
// //     move = result.0;
// //     chars[side] = result.1;
// //     last_hashes[side] = result.2;
// // }

// #[test]
// fn test_main_fireball_ff() {
//     let secrets = [123456789, 9876543210];
//     let mut chars = [
//         [
//             Character { id: 0, class: ARCHER, x: 9, y: 2, health: 100, status: 1, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 0, damage_mod: 0 },
//             Character { id: 1, class: RITUALIST, x: 11, y: 3, health: 25, status: 0, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 0, damage_mod: 0 },
//             Character { id: 2, class: ROGUE, x: 12, y: 4, health: 20, status: 0, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 1, damage_mod: 0 },
//             Character { id: 3, class: KNIGHT, x: 10, y: 4, health: 100, status: 0, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 0, damage_mod: 0 },
//             Character { id: 4, class: MAGE, x: 10, y: 7, health: 100, status: 2, target_x: 11, target_y: 4, has_been_seen: true, is_hidden: 0, damage_mod: 10 },
//         ], [
//             Character { id: 0, class: MAGE, x: 13, y: 2, health: 100, status: 2, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 0, damage_mod: 0 },
//             Character { id: 1, class: ROGUE, x: 14, y: 6, health: 0, status: 0, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 1, damage_mod: 0 },
//             Character { id: 2, class: RITUALIST, x: 16, y: 3, health: 20, status: 0, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 0, damage_mod: 0 },
//             Character { id: 3, class: ARCHER, x: 16, y: 6, health: 100, status: 0, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 0, damage_mod: 0 },
//             Character { id: 4, class: KNIGHT, x: 11, y: 4, health: 30, status: 0, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 0, damage_mod: 0 },
//         ]
//     ];
//     let mut obs = [ Obstacle::get_default_obstacles(0), Obstacle::get_default_obstacles(1) ];
//     let actions = &[
//         Action { action: CAST_FIREBALL, actor: 4, target_x: 11, target_y: 4 },
//         Action { action: MOVE, actor: 4, target_x: 9, target_y: 7 },
//         Action { action: WAIT, actor: 4, target_x: 0, target_y: 0 },
//         Action { action: WAIT, actor: 4, target_x: 0, target_y: 0 },
//     ];
//     let their_events: [Event] = &[
//         Event { event: RECEIVE_ATTACK, actor_id: 3, x: 11, y: 3, subtype: ATTACK_RANGED, value: 50 },
//         Event { event: SEE_MOVE, actor_id: 3, x: 16, y: 5, subtype: 0, value: 0 },
//         Event { event: SEE_MOVE, actor_id: 3, x: 16, y: 6, subtype: 0, value: 0 },
//         Event { event: NO_EVENT, actor_id: 3, x: 0, y: 0, subtype: 0, value: 0 },
//     ];
//     let my_events: [Event] = &[
//         Event { event: RECEIVE_ATTACK, actor_id: 4, x: 11, y: 4, subtype: ATTACK_FIREBALL, value: 110 },
//         Event { event: SEE_MOVE, actor_id: 4, x: 9, y: 7, subtype: 0, value: 0 },
//         Event { event: NO_EVENT, actor_id: 4, x: 0, y: 0, subtype: 0, value: 0 },
//         Event { event: NO_EVENT, actor_id: 4, x: 0, y: 0, subtype: 0, value: 0 },
//     ];
//     let mut move = 8;
//     let mut actor = chars[0][4].move(9, 7).set_status(0);
//     let mut last_hashes = [ 0x090a46a65d4c7c05f3c98b25c2639539d91c1542fd78e9c9c837f96de08c6a84, 0x2bca22f32b0b864574d0509ba146be256d2186fc490311756f541e1b5f8e391f ];
//     let mut advances = [12 + VIEW_DISTANCE, 11 - VIEW_DISTANCE];

//     let side = move as u1;
//     let other_side = (side as u8 + 1) as u1;
//     let chars_after = [ chars[side][0], chars[side][1].take_damage(ATTACK_RANGED, 50).take_damage(ATTACK_FIREBALL, 55), chars[side][2].take_damage(ATTACK_FIREBALL, 55), chars[side][3].take_damage(ATTACK_FIREBALL, 55), actor ];
//     let my_obstacles_serialized = Obstacle::serialize_obstacles(side, advances[other_side], obs[side]);
//     let secret_be_bytes: [u8; 32] = secrets[side].to_be_bytes();
//     assert(secret_be_bytes.len() == 32);
//     let serialized_chars_after = serialize_chars(chars_after);
//     let serialized_chars_after_be_bytes: [u8; 32] = serialized_chars_after.to_be_bytes();
//     assert(serialized_chars_after_be_bytes.len() == 32);
//     let current_hash = std::field::bytes32_to_field(get_data_hash(secret_be_bytes, serialized_chars_after_be_bytes, my_obstacles_serialized)); 

//     println(secrets[side]);
//     println(character::serialize_chars(chars[side]));
//     println(my_obstacles_serialized);
//     println(Action::serialize_actions(actions));
//     println(move);
//     println(advances[other_side]);
//     println(test_result_object_builder(chars[other_side], Obstacle::serialize_obstacles(other_side, advances[side], obs[other_side])));
//     println(Event::serialize_events(their_events));
//     println(advances[side]);
//     println(Event::serialize_events(my_events));
//     println(test_result_object_builder(chars_after, my_obstacles_serialized));
//     println(last_hashes[side]);
//     println(f"Current hash: {current_hash}");
//     main(
//         secrets[side],
//         character::serialize_chars(chars[side]),
//         my_obstacles_serialized,
//         Action::serialize_actions(actions),
//         move,
//         advances[other_side],
//         test_result_object_builder(chars[other_side], Obstacle::serialize_obstacles(other_side, advances[side], obs[other_side])),
//         Event::serialize_events(their_events).as_array(),
//         advances[side],
//         Event::serialize_events(my_events).as_array(),
//         test_result_object_builder(chars_after, my_obstacles_serialized),
//         last_hashes[side],
//         current_hash
//     );
// }
