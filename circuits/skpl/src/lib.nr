mod common;
mod action;
use action::{ new_action, parse_actions, serialize_actions };
use action::execute_action;
mod character;
use character::{ Character, get_test_action_register };
use character::parse_characters;
mod event;
pub use event::Event;
mod obstacle;
use obstacle::Obstacle;
pub use obstacle::{ new_obstacle, parse_my_obstacles, parse_their_obstacles, get_obstacle_x, get_obstacle_y, get_obstacle_id, get_obstacle_type, get_obstacle_health, serialize_my_obstacles, get_default_obstacles };
mod map;
use dep::std;
use obstacle::serialize_obstacle;
use obstacle::serialize_their_obstacles;
// use action::ACTION_TARGET_X;
// use action::ACTION_TARGET_Y;
// use action::ACTION_TYPE;
use action::get_action_target_y;
use action::get_action_target_x;
use action::get_action_type;
mod actionDefinition;
use actionDefinition::{ ActionDefinitionRegister };
pub use actionDefinition::ACTION_DEFINITION_REGISTER_SIZE;
use obstacle::serialize_my_obstacles_for_me;
use map::is_visible;

mod ResolvedAction;



// #[export]
// pub fn ext_can_move_to(x: u8, y: u8, obstacles: [Obstacle; MAX_OBSTACLES], their_obstacles: [Obstacle]) -> bool {
//     assert(MAX_OBSTACLES == 24);
//     let mut my_obstacles_parsed = Obstacle::parse_my_obstacles(my_obstacles, events).as_array();
//     // TODO: validate obstacles => check that initial setup is ok => unique ids and no coordination overlaps!

//     // Note: no need to validate enemy obstacles => opponent proof verifies that they are correct already!
//     let enemy_objects_parsed = Obstacle::parse_their_obstacles(enemy_objects);

//     let mut can = true;
//     for i in 0..MAX_OBSTACLES {
//         if !obstacles[i].is_traversible() & (obstacles[i].x == x) & (obstacles[i].y == y) {
//             can = false;
//         }
//     }
//     for i in 0..their_obstacles.len() {
//         if !their_obstacles[i].is_traversible() & (their_obstacles[i].x == x) & (their_obstacles[i].y == y) {
//             can = false;
//         }
//     }
//     can
// }

pub comptime global DEBUG: bool = false;
pub comptime fn debug(stmt: Quoted) -> Quoted {
    let debug_result = if DEBUG {
        stmt
    } else { quote {} };
    debug_result
}
pub comptime fn debugmsg<T>(msg: T) -> Quoted {
    debug!(quote { println($msg); })
}
pub comptime fn softassert(varname: Quoted, check: Quoted, msg: Quoted) -> Quoted {
    let result = if DEBUG {
        quote {
            $varname &= $check;
            if !($check) {
                println($msg);
            }
        }
    } else {
        quote {
            $varname &= $check;
        }
    };
    result
}

// MAP
global WIDTH_BITS: u8 = 5;
global WIDTH_MASK: u8 = (1 << WIDTH_BITS) - 1;
global WIDTH: u8 = 1 << WIDTH_BITS;
global HEIGHT_BITS: u8 = 4;
global HEIGHT_MASK: u8 = (1 << HEIGHT_BITS) - 1;
global HEIGHT: u8 = 10;
global NOWHERE: u8 = 255;

// CLASSES
//global UNKNOWN_CLASS: u8 = 0;
global ARCHER: u8 = 1;
global RITUALIST: u8 = 2;
global ROGUE: u8 = 3;
global KNIGHT: u8 = 4;
global MAGE: u8 = 5;
global CLASS_BITS: u8 = 3;
global CLASS_MASK: u8 = (1 << CLASS_BITS) - 1;
global CLASS_COUNT: u32 = 6;
global MAX_ACTIONS_PER_CHARACTER: u32 = 7;

// ACTIONS
global WAIT: u8 = 0;
//global SNEAK: u8 = 1;
//global MOVE: u8 = 2;          // => SEE_COLUMN (depr: MOVE)
//global RITUAL: u8 = 3;        // => SEE_RITUAL | WIN
//global SEARCH: u8 = 4;        // => SEE_SEARCH_TRAP
//global ATTACK: u8 = 5;        // => RECEIVE_ATTACK | DESTROY // affects my obstacles; TODO: with more attack types might also affect other own characters
//global CAST: u8 = 6;          // => SEE_CAST // affects my obstacles; TODO: with more attack types might also affect other own characters
//global CAST_FIREBALL: u8 = 7; // => RECEIVE_ATTACK // affects other characters if status == FIREBALL_ROUNDS_FOR_CAST
//global DRAW: u8 = 8;          // => SEE_DRAW
//global SHOOT: u8 = 9;         // => RECEIVE_ATTACK
//global TRIGGER_TRAP = 9;  // => TRIGGERED_TRAP ?????????
//global DISARM_TRAP: u8 = 10;  // => DESTROY
//global SET_TRAP: u8 = 11;
global ACTION_COUNT: u32 = 12;

// EVENTS
global NO_EVENT: u8 = 0 ;
// global DESTROY: u8 = 1;          // actor_id = their_char or their_object when receive - no need to handle, only important to have on-chain for the client //use coordinates to determine tile or trap that got destroyed and update map
//global DISCOVER = 2;         // actor_id = their_char or their_object when receive - handle to update enemy positions, got health & class (this is for all chars, not just the active one)
//global SEE_COLUMN = 2 ;      // y = the column the player sees => update objects list
global SEE_MOVE: u8 = 3 ;        // actor_id = their_char or their_object when receive - no need to handle, only important to have on-chain for the client //handle to update enemy positions => DISCOVER
//global SEE_SPELL = 4 ;       // actor_id = their_char when receive - need to handle effect via coordinates, => RECEIVE_DAMAGE | DESTROY | LOSE // also need to handle my obstacles
global SEE_SEARCH_TRAP: u8 = 5 ; // actor_id = their_char when receive - need to create found trap event if there is a trap nearby => FOUND_TRAP
// global SEE_RITUAL: u8 = 6 ;      // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
global SEE_CAST: u8 = 7;         // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
global SEE_DRAW: u8 = 8;         // actor_id = their_char when receive - no need to handle, only important to have on-chain for the client
//global RECEIVE_DAMAGE = 9;   // actor_id = their_char or their_object when receive - no need to handle, only important to have on-chain for the client
global RECEIVE_ATTACK: u8 = 10;  // actor_id = 0 when receive - need to handle damage => // no need to events ... health of visible assets gets sent anyway and invisible ones will be updated during discovery //RECEIVE_DAMAGE | DESTROY | LOSE // also need to handle in my obstacles
global TRIGGERED_TRAP: u8 = 11;  // actor_id = my_char when receive - need to handle damage (for now, later on we might want to handle other effects as well) => RECEIVE_DAMAGE
// global FOUND_TRAP: u8 = 12;      // actor_id = my_char when receive - no need to handle, only important to have on-chain for the client
global DISARMED_TRAP: u8 = 13;      // actor_id = their-char when receive - need to remove my trap from the map
global WIN: u8 = 14;
// global LOSE: u8 = 15;
global ADD_OBSTACLE: u8 = 4;
global EVENT_COUNT: u8 = 16;

// SUBTYPES:
global WIN_BY_RITUAL: u8 = 1;

// ATTACKS
global ATTACK_MELEE: u8 = 0;
global ATTACK_RANGED: u8 = 1;
global ATTACK_FIREBALL: u8 = 2;
// global ATTACK_COUNT: u8 = 3;
// TODO: instead of enum, use a global array of structs with damage, range, etc.


// TILES
global EMPTY: u8 = 0;
global WALL: u8 = 6;
global WATER: u8 = 7;
// global UNKNOWN_CLASS_TILE: u8 = 8;
global NON_EMPTY_WALKABLE_TILE_MIN: u8 = 9;
// global FLAG: u8 = 9;
global TRAP: u8 = 10;
// global TRAP_USED: u8 = 11;
// global TRAP_FOUND: u8 = 12;
// global BODY: u8 = 13;
// global BODY_LOOTED: u8 = 14;
// global FOG: u8 = 15;
global MAX_OBSTACLE_TYPE: u8 = 0x0f;
// global TILE_COUNT: u8 = 16;
// unknown_class, flag, trap, trap_used, trap_found, body, body_looted, fog
// STATUS
global RITUAL_ROUNDS_FOR_WIN: u8 = 15;
global MIN_FIREBALL_ROUNDS_FOR_CAST: u8 = 3;
global MAX_FIREBALL_ROUNDS_FOR_CAST: u8 = 6;
// global DRAW_ROUNDS_FOR_SHOOT: u8 = 1;
global MIN_DRAW_ROUNDS_FOR_SHOOT: u8 = 1;
global MAX_DRAW_ROUNDS_FOR_SHOOT: u8 = 3;
global STATUS_BITS: u8 = 4;
global STATUS_MASK: u8 = (1 << STATUS_BITS) - 1;
global STATUS_COUNT: u8 = 16 ; // just to be more in line with the other constants, actually used as a counter
global MAX_HEALTH: u8 = 255;

// GAMEPLAY
global VIEW_DISTANCE: u8 = 6;
// global MAX_TRAPS: u32 = 8; // note: only lowest bit of first byte of field is usable! => ! Field = 1 bit + 31 bytes!
// global TRAPS_BUFFER_SIZE: Field = 16;
// global TRAPS_BUFFER_MASK: Field = 15; // has to be 2^n - 1
global MAX_ACTIONS: u32 = 4;
global MAX_EVENTS: u32 = 4; // = MAX_ACTIONS // NO! handle traps in a different way (by passing as argument!)+ 4 (2 FOUND_TRAP + WIN/LOSE + 1 reserved)
global MAX_OBSTACLES: u32 = 24; // leave traps for now + MAX_TRAPS; // 24 + 8 player placeables
pub global MAX_CHARACTERS: u32 = 5;
pub global MAX_STATUS: u8 = STATUS_COUNT - 1;
global SERIALIZED_OBSTACLE_BYTE_SIZE: u32 = 3;//3
pub global SERIALIZED_OBSTACLES_ARRAY_SIZE: u32 = 3;//3 // TODO: we take 3 because 3 x 8 = MAX_OBSTACLES ... should assert on this (MAX_OBSTACLES + MAX_CHARACTERS + 7) / 8;
pub global SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE: u32 = SERIALIZED_OBSTACLES_ARRAY_SIZE + 1; // +1 because enemy characters are also serialized as obstacles
global SERIALIZED_OBSTACLES_PER_FIELD: u32 = 8;//8 // TODO: need to verify that SERIALIZED_OBSTACLES_ARRAY_SIZE * SERIALIZED_OBSTACLES_PER_FIELD = MAX_OBSTACLES!
global SERIALIZED_EVENT_BYTE_SIZE: u32 = 7;
pub global SERIALIZED_EVENTS_ARRAY_SIZE: u32 = 1; // MAX_EVENTS / SERIALIZED_EVENTS_PER_FIELD => 4 / 4 = 1
global SERIALIZED_EVENTS_PER_FIELD: u32 = 4; // 31 / 7 = 4
global SERIALIZED_ACTION_BYTE_SIZE: u32 = 5;
pub global SERIALIZED_ACTIONS_ARRAY_SIZE: u32 = 1;
global SERIALIZED_ACTIONS_PER_FIELD: u32 = 4; // could be up to 6, but we only use 4
global UNREADABLE_BYTES_PER_FIELD: u32 = 1;

// #[export]
// fn tf(x: Field) -> (u32, [u8;32]) {
//     let mut result: [u8;32] = [0;32];
//     let bts = x.to_be_bytes::<32>();
//     for j in 0..31 {
//         result[j] = 2*j;//bts[j];
//     }
//     (32 , result)
// }
// i,
// 20, 0 -> 25,
// 25 -> 0, 
// x, 0, 0, d0,
// x, 0, 0, 9d, 1, 0,
// x, 0, 0, 1, 0, b4, 1, 0, 1, 1,
// x, 0, 0, 1, 0, 91, 1, 0, 1, 1,
// x, 0, 0, 1, 0, 23, 1, 0, 1, 1, 
// x, 0, 0, 1, 0, d4, 1, 0, 1, 1, 
// x, 0, 0, 1, 0, 66, 1, 0, 1, 1, 
// x, 0, 0, 1, 0, de, 1, 0, 1, 1,
// x, 0, 0, 1, 0, 50, 1, 0, 1, 1,
// x, 0, 0, 1, 0, b9, 1, 0, 1, 1,
// x, 0, 0, 1, 0, c5, 1, 0, 1, 1,
// x, 0, 0, 1, 0, 55, 1, 0, 1, 1,
// x, 0, 0, 1, 0, 8b, 1, 0, 1, 1,
// x, 0, 0, 1, 0, 8c, 1, 0, 1, 1,
// x, 0, 0, 1, 0, b6, 1, 0, 1, 1,
// x, 0, 0, 1, 0, b2, 1, 0, 1, 1,
// x, 0, 0, 1, 0, e8, 1, 0, 1, 1,
// x, 0, 0, 1, 0, de, 1, 0, 1, 1,
// x, 0, 0, 1, 0, 2a, 1, 0, 1, 1,
// x, 0, 0, 1, 0, cb, 1, 0, 1, 1,
// x, 0, 0, 1, 0, 9b, 1, 0, 1, 1,
// x, 0, 0, 1, 0, 5c, 1, 0, 1, 1,
// x, 0, 0, 1, 0, a6, 1, 0, 1, 1,
// x, 0, 0, 1, 0, 86, 1, 0, 1, 1,
// x, 0, 0, 1, 0, d5, 1, 0, 1, 1,
// x, 0, 0, 1, 0, 38, 1, 0, 1, 1,
// x, 0, 0, 1, 0, 2b, 1, 0, 1, 1,
// x, 0, 0, 1, 0, 8e, 1, 0, 0, 1,
// 0, 32, 1, 0, 1, 1, x, 0, 0, 1,
// x, 0, 0, 1, x, 0, 0, 1, 0, 1, 1

// i,
// 20, 0, 1e -> 0, 0 -> 1e, 0
// x, 0, 0, d0,
// x, 0, 0, ba, 1, 0,
// x, 0, 0, 1, 0, cf, 1, 0, 1, 1,

#[export]
fn get_actor_from_move(mut move: u32) -> u8 {
    if (move % 2) == 1 {
        move -= 1; //((move % 10) - 1) >> 1 // actually not needed ... but clearer this way
    }
    let single_digit: u32 = (move % 10 as u32) >> 1;
    single_digit as u8
}
// 3, 1, 1, 1, 0, 1, 2, 0, 2, 8, 1, 0, 0, 1
// 4, 2, 2, 0, x, 0, 0, 0, 4, a, 2, 0, 0, 2

#[export]
pub fn hash_match(my_chars: Field, my_char_actions: [u8; ACTION_DEFINITION_REGISTER_SIZE], my_obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE], secret_be_bytes: [u8; 32]) -> Field {
    let my_chars_be_bytes: [u8; 32] = my_chars.to_be_bytes::<32>();
    assert(my_chars_be_bytes.len() == 32);
    let gamestate_before_hash_calculated = get_data_hash(secret_be_bytes, my_chars_be_bytes, my_char_actions, my_obstacles);
    let gamestate_before_hash_calculated_field = std::field::bytes32_to_field(gamestate_before_hash_calculated);
    gamestate_before_hash_calculated_field
}

#[export]
fn get_serialized_obstacle(id: u8, x: u8, y: u8, obstacle_type: u8) -> Field {
    let mut result: [u8; 32] = [0; 32];
    result[0] = id;
    result[1] = x;
    result[2] = y;
    result[3] = obstacle_type;
    std::field::bytes32_to_field(result)
}

#[export]
pub fn calculate_turn(
    my_chars_input: Field,
    my_char_actions_input: [u8; ACTION_DEFINITION_REGISTER_SIZE],
    my_obstacles_input: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE],
    //mut my_obstacles_parsed: [[u8; 5]; 24],
    actions_input: [Field; SERIALIZED_ACTIONS_ARRAY_SIZE],
    // Common Inputs
    move_input: u32, //pub
    // Enemy Inputs
    enemy_advance_input: u8, // pub // from enemy point of view => starting from 0
    enemy_objects_input: [Field; SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE], // pub
    enemy_events_input: [Field; SERIALIZED_EVENTS_ARRAY_SIZE], // pub //MAX_EVENTS],

) -> (bool, Field, [u8; ACTION_DEFINITION_REGISTER_SIZE], [[u8; 5];24], u8, [Field; SERIALIZED_EVENTS_ARRAY_SIZE], [Field; SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE]) {
    let mut success = true;

    let actionRegister = ActionDefinitionRegister::new(my_char_actions_input);
    // calculate enemy advance in our coordinates and shadow
    // let (enemy_advance_valid, enemy_advance) = their_x_to_mine(enemy_advance);
    let enemy_advance = if enemy_advance_input >= WIDTH { 0 } else { WIDTH - enemy_advance_input - 1 };


    // TODO: Validate map => check that initial setup is ok => unique ids and no coordination overlaps!

    let (events_valid, events) = Event::parse_their_events(enemy_events_input);
    softassert!(quote { success }, quote { events_valid }, quote { f"Failed to parse their events {events}" });

    // let side = move as u1;
    let (my_chars_valid, mut my_chars) = parse_characters(my_chars_input, events, enemy_advance);
    softassert!(quote { success }, quote { my_chars_valid }, quote { f"Failed to parse my characters {my_chars}" });

    let actor_id = get_actor_from_move(move_input);
    let mut actor = my_chars[actor_id]; //Character::parse(actor_id, my_chars, events);
    
    let actions = parse_actions(actions_input); // actions.map(|action| Action::from_field(action));
    
    comptime {
        assert(MAX_OBSTACLES == 24);
    }

    let (valid, my_obstacles_parsed) = parse_my_obstacles(my_obstacles_input, events);
    softassert!(quote { success }, quote { valid }, quote { f"Failed to parse my obstacles {my_obstacles_input}" });
    let mut my_obstacles_parsed: [Obstacle; MAX_OBSTACLES] = my_obstacles_parsed.as_array();

    // let mut my_obstacles_parsed = my_obstacles_parsed.as_array();
//    let (valid, mut my_obstacles_parsed) = parse_my_obstacles(my_obstacles, events).as_array();
    // TODO: validate obstacles => check that initial setup is ok => unique ids and no coordination overlaps!

    // Note: no need to validate enemy obstacles => opponent proof verifies that they are correct already!
    let (enemy_objects_parsed_valid, enemy_objects_parsed) = parse_their_obstacles(enemy_objects_input);
    softassert!(quote { success }, quote { enemy_objects_parsed_valid }, quote { f"Failed to parse their obstacles {enemy_objects_input}" });

    let mut energy: u8 = 12;
    let mut result_events_calculated: [Event] = &[];
    for i in 0..MAX_ACTIONS {
        // TODO: ensure that if actor committed suicide, it is not allowed to do any more actions
        let action = actions[i];
        let resolved_action = actionRegister.resolve_action(action); //resolve_action(action);
        let result = execute_action(resolved_action, enemy_advance, actor, energy, my_obstacles_parsed, enemy_objects_parsed);
        //assert(result.0);
        success &= result.0;
        let result_event = result.1;
        let internal_event = result.2;
        actor = result.3;
        energy = result.4;
        
        // 4461 / 5 = 892,2
        my_chars = my_chars.map(|c| wb_apply_damage_to_char(c, result_event, actor));
        // 16800 / 24 = 700
        my_obstacles_parsed = my_obstacles_parsed.map(|obstacle| {
            let (updated_obstacle_valid, updated_obstacle) = update_my_obstacle(obstacle, result_event);
            //success = success & updated_obstacle_valid;
            softassert!(quote { success }, quote { updated_obstacle_valid }, quote { f"Failed to update my obstacle {obstacle}, {result_event}" });
            updated_obstacle
        });

        result_events_calculated = result_events_calculated.push_back(result_event);
    }
    let result_events_calculated = Event::serialize_events(result_events_calculated);
    assert(result_events_calculated.len() == SERIALIZED_EVENTS_ARRAY_SIZE);

    // send death events => no need

    // determine view range
    let mut my_advance_calculated = 0;
    for i in 0..MAX_CHARACTERS {
        if my_chars[i].x > my_advance_calculated {
            my_advance_calculated = my_chars[i].x;
        }
    }
    my_advance_calculated += VIEW_DISTANCE;

    let serialized_characters = serialize_chars(my_chars);
    let serialized_obstacles: [Field] = serialize_my_obstacles(enemy_advance, my_obstacles_parsed);
    let (serialized_chars_as_obstacles_valid, serialized_chars_as_obstacles) = serialize_chars_as_obstacles(enemy_advance, my_chars);
    // success = success & serialized_chars_as_obstacles_valid;
    softassert!(quote { success }, quote { serialized_chars_as_obstacles_valid }, quote { f"Failed to serialize chars as obstacles: {my_chars}" });
    let serialized_obstacles_for_enemy: [Field; SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE] = serialized_obstacles.push_back(serialized_chars_as_obstacles).as_array();
    // let serialized_obstacles_for_me = serialize_my_obstacles_for_me(my_obstacles_parsed);

    (success, serialized_characters, my_char_actions_input, my_obstacles_parsed, my_advance_calculated, result_events_calculated.as_array(), serialized_obstacles_for_enemy)
}

#[export]
pub fn turn(
    // verification_key: pub [Field; 114],
    // proof: pub [Field; 93],
    // public_inputs: pub [Field; 1 ],//+ 2 * SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE + 2 * SERIALIZED_EVENTS_ARRAY_SIZE],
    // key_hash: pub Field,
    // last_move: pub u32,
    // last_enemy_advance: pub u8,
    // last_enemy_objects: pub [Field; SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE],
    // last_events: pub [Field, SERIALIZED_EVENTS_ARRAY_SIZE],
    // last_my_advance: pub u8,
    // last_my_result_events: pub [Field; SERIALIZED_EVENTS_ARRAY_SIZE],
    // last_my_result_objects: pub [Field; SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE],
    // Gamestate Hashes
    // gamestate_before_hash: pub Field,
    // gamestate_after_hash: pub Field,
    // My Secret State
    secret: Field,
    my_chars_input: Field,
    //my_char_actions: [u8; ACTION_DEFINITION_REGISTER_SIZE],
    my_obstacles_input: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE],
    //my_obstacles: [[u8; 5]; 24],
    actions: [Field; SERIALIZED_ACTIONS_ARRAY_SIZE],
    // Common Inputs
    move: u32, //pub
    // Enemy Inputs
    enemy_advance: u8, // pub // from enemy point of view => starting from 0
    enemy_objects: [Field; SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE], // pub
    enemy_events: [Field; SERIALIZED_EVENTS_ARRAY_SIZE], // pub //MAX_EVENTS],
    // My Results
    my_result_advance: u8, // pub // 1 bit win, 1 bit lose, 1 bit reserved, 5 bits advance
    my_result_events: [Field; SERIALIZED_EVENTS_ARRAY_SIZE], // pub
    my_result_objects: [Field; SERIALIZED_ENEMY_OBSTACLES_ARRAY_SIZE], // pub
    // Gamestate Hashes
    gamestate_before_hash: Field, // pub
    gamestate_after_hash: Field, // pub
) -> pub bool {
    // Validate global constants (to make sure one didn't change one without updating dependet ones)
    comptime {
        assert((SERIALIZED_OBSTACLES_PER_FIELD * SERIALIZED_OBSTACLE_BYTE_SIZE) < 32);
        assert(SERIALIZED_OBSTACLES_PER_FIELD * SERIALIZED_OBSTACLES_ARRAY_SIZE >= MAX_OBSTACLES);
        assert(SERIALIZED_EVENTS_PER_FIELD * SERIALIZED_EVENTS_ARRAY_SIZE == MAX_EVENTS);
        // assert(SERIALIZED_OBSTACLES_PER_FIELD * SERIALIZED_OBSTACLES_ARRAY_SIZE == MAX_OBSTACLES);
    }

    let my_char_actions = get_test_action_register();

    let mut success = true;
    let secret_be_bytes: [u8; 32] = secret.to_be_bytes::<32>();
    assert(secret_be_bytes.len() == 32);

    // let serialized_obstacles_for_me = serialize_my_obstacles_for_me(my_obstacles);
    let gamestate_before_hash_calculated_field = hash_match(my_chars_input, my_char_actions, my_obstacles_input, secret_be_bytes);
    // assert(gamestate_before_hash == gamestate_before_hash_calculated_field, f"{gamestate_before_hash} != {gamestate_before_hash_calculated_field}");
    softassert!(quote { success }, quote { gamestate_before_hash == gamestate_before_hash_calculated_field }, quote { f"Invalid pre-hash: {gamestate_before_hash} != {gamestate_before_hash_calculated_field}" });
    // std::verify_proof(verification_key, proof, public_inputs, key_hash);

    let  (turn_calc_valid, serialized_characters, my_char_actions_after, serialized_obstacles, my_advance_calculated, result_events_calculated, serialized_obstacles_for_enemy) = calculate_turn(
        my_chars_input,
        my_char_actions,
        my_obstacles_input,
        actions,
        move,
        enemy_advance,
        enemy_objects,
        enemy_events
    );
    softassert!(quote { success }, quote { turn_calc_valid }, quote { f"Tun calculation failed" });

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
    softassert!(quote { success }, quote { my_result_advance == my_advance_calculated }, quote { f"Invalid result advance: {my_advance} != {my_advance_calculated}" });

    // validate result
    for i in 0..SERIALIZED_EVENTS_ARRAY_SIZE {
        let result_event_calculated = result_events_calculated[i];
        let result_event_should = my_result_events[i];
        softassert!(quote { success }, quote { result_event_should == result_event_calculated }, quote { f"Invalid result event {i}: {result_event_should} != {result_event_calculated}" });
    }
    // assert(serialized_obstacles.len() == SERIALIZED_OBSTACLES_ARRAY_SIZE);
    let serialized_characters_be_bytes: [u8; 32] = serialized_characters.to_be_bytes::<32>();
    assert(serialized_characters_be_bytes.len() == 32);
    debug!(quote {
        println(f"serialized_obstacles: {serialized_obstacles}");
        println(f"serialized_obstacles_for_enemy: {serialized_obstacles_for_enemy}");
        println(f"serialized_characters: {serialized_characters}");
        println(f"serialized_characters_be_bytes: {serialized_characters_be_bytes}");
    });
    let my_obstacles_serialized_for_me = serialize_my_obstacles_for_me(serialized_obstacles);
    let new_hash_bytes = get_data_hash(secret_be_bytes, serialized_characters_be_bytes, my_char_actions_after, my_obstacles_serialized_for_me);
    let new_hash = std::field::bytes32_to_field(new_hash_bytes);
    for i in 0..my_result_objects.len() {
        let my_result_object = my_result_objects[i];
        let serialized_obstacle = serialized_obstacles_for_enemy[i];
        softassert!(quote { success }, quote { my_result_object == serialized_obstacle }, quote { f"Invalid result obstacle row {i}: {my_result_object} != {serialized_obstacle}" });
    }
    softassert!(quote { success }, quote { new_hash == gamestate_after_hash }, quote { f"Invalid result hash: {new_hash} != {gamestate_after_hash}" });
    success
}

fn wb_apply_damage_to_char(mut c: Character, event: Event, actor: Character) -> Character {
    if c.id == actor.id {
        c = actor;
    }
    apply_damage_to_char(c, event)
}

fn apply_damage_to_char(c: Character, event: Event) -> Character {
    let dmg = event.get_applied_damage_to_my_asset(c.x, c.y, c.class);
    Character {
        id: c.id,
        x: c.x,
        y: c.y,
        class: c.class,
        health: safe_subtract_dmg(c.health, dmg),
        status: c.status,
        target_x: c.target_x,
        target_y: c.target_y,
        has_been_seen: c.has_been_seen,
        is_hidden: c.is_hidden,
        damage_mod: c.damage_mod,
        last_action: c.last_action,
        actions: c.actions
    }
}
fn update_my_obstacle(obstacle: Obstacle, event: Event) -> (bool, Obstacle) {
    let dmg =
        // event.get_applied_damage_to_my_asset(get_obstacle_x(obstacle), get_obstacle_y(obstacle), get_obstacle_type(obstacle)) +
        event.get_applied_damage_to_my_asset(get_obstacle_x(obstacle), get_obstacle_y(obstacle), get_obstacle_type(obstacle));
    new_obstacle(get_obstacle_id(obstacle), get_obstacle_x(obstacle), get_obstacle_y(obstacle), safe_subtract_dmg(get_obstacle_health(obstacle), dmg), get_obstacle_type(obstacle))
    // Obstacle {
    //     health: safe_subtract_dmg(obstacle.health, dmg),
    //     id: obstacle.id,
    //     x: obstacle.x,
    //     y: obstacle.y,
    //     obstacle_type: obstacle.obstacle_type,
    // }
}

fn get_data_hash(secret: [u8], characters: [u8], character_actions: [u8; ACTION_DEFINITION_REGISTER_SIZE], obstacles: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE]) -> [u8; 32] {
    assert(secret.len() == 32);
    assert(characters.len() == 32);

    let mut data: [u8; 32 + 32 + SERIALIZED_OBSTACLES_ARRAY_SIZE * 32 + ACTION_DEFINITION_REGISTER_SIZE] = [0; 32 + 32 + SERIALIZED_OBSTACLES_ARRAY_SIZE * 32 + ACTION_DEFINITION_REGISTER_SIZE];
    for i in 0..32 {
        data[i] = secret[i];
        data[i + 32] = characters[i];
    }
    let offset = 32 + 32;
    for i in 0..SERIALIZED_OBSTACLES_ARRAY_SIZE {
        let obstacle: [u8; 32] = obstacles[i].to_be_bytes::<32>();
        assert(obstacle.len() == 32);
        for j in 0..32 {
            data[offset + i * 32 + j] = obstacle[j];
        }
    }
    let offset = 32 + 32 + 32 * SERIALIZED_OBSTACLES_ARRAY_SIZE;
    for i in 0..ACTION_DEFINITION_REGISTER_SIZE {
        data[offset + i] = character_actions[i];
    }
    // let offset = WIDTH * HEIGHT + 32 * 3;
    // for i in 0..10 {
    //     data[offset + i * 4] = (searched_traps[i] & 255) as u8;
    //     data[offset + i * 4 + 1] = ((searched_traps[i] >> 8) & 255) as u8;
    //     data[offset + i * 4 + 2] = ((searched_traps[i] >> 16) & 255) as u8;
    //     data[offset + i * 4 + 3] = ((searched_traps[i] >> 24) & 255) as u8;
    // }
    std::hash::blake3(data)
}

fn serialize_chars(chars: [Character; MAX_CHARACTERS]) -> Field {
    comptime {
        assert(MAX_CHARACTERS <= 5);
    }
    let mut result: [u8; 32] = [0; 32];
    for i in 0..MAX_CHARACTERS {
        let serialized = chars[i].serialize();
        for j in 0..6 {
            result[2 + i * 6 + j] = serialized[j];
        }
    }
    std::field::bytes32_to_field(result)
}

fn serialize_chars_as_obstacles(enemy_advance: u8, chars: [Character; MAX_CHARACTERS]) -> (bool, Field) {
    let mut result: [u8; 32] = [0; 32];
    let mut valid_result = true;
    for i in 0..MAX_CHARACTERS {
        if (chars[i].is_hidden == 0) & is_visible(enemy_advance, chars[i].get_x()) {
            let (valid, char_as_obstacle) = chars[i].to_obstacle();
            let serialized = serialize_obstacle(char_as_obstacle);
            valid_result = valid_result & valid;
            result[2 + i * 3] = serialized[0];
            result[2 + i * 3 + 1] = serialized[1];
            result[2 + i * 3 + 2] = serialized[2];
        }
    }
    (valid_result, std::field::bytes32_to_field(result))
}

fn safe_subtract_dmg(a: u8, b: u16) -> u8 {
    let mut result = 0;
    if (a as u16) > b {
        result = a - (b as u8);
    }
    result
}

fn test_result_object_builder(enemy_advance: u8, chars: [Character; MAX_CHARACTERS], obs: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE]) -> (bool, [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE + 1]) {
    let mut result: [Field; SERIALIZED_OBSTACLES_ARRAY_SIZE + 1] = [0; SERIALIZED_OBSTACLES_ARRAY_SIZE + 1];
    for i in 0..SERIALIZED_OBSTACLES_ARRAY_SIZE {
        result[i] = obs[i];
    }
    let (valid, chars_as_obstacles) = serialize_chars_as_obstacles(enemy_advance, chars);
    result[SERIALIZED_OBSTACLES_ARRAY_SIZE] = chars_as_obstacles;
    (valid, result)
}

// fn test_helper_roster(actor: Character, mut chars: [Character; MAX_CHARACTERS]) -> [Character; MAX_CHARACTERS] {
//     chars[actor.id] = actor;
//     chars
// }

// fn test_helper_execute_move(move: u32, actor: Character, advances: [u8; 2], secret: [Field; 2], last_hashes: [Field; 2], chars: [[Character; MAX_CHARACTERS]; 2], obs: [[Obstacle; MAX_OBSTACLES]; 2], actions: [Action], my_events: [Event], their_events: [Event]) -> (u32, [Character; MAX_CHARACTERS], Field) {
//     let side = move as u1;
//     let other_side = (side as u8 + 1) as u1;
//     let chars_after = test_helper_roster(actor, chars[side]);
//     let my_obstacles_serialized = serialize_obstacles(advances[other_side], obs[side]);
//     let secret_be_bytes: [u8; 32] = secret[side].to_be_bytes();
//     assert(secret_be_bytes.len() == 32);
//     let serialized_chars_after = serialize_chars(chars_after);
//     let serialized_chars_after_be_bytes: [u8; 32] = serialized_chars_after.to_be_bytes();
//     assert(serialized_chars_after_be_bytes.len() == 32);
//     let current_hash = std::field::bytes32_to_field(get_data_hash(secret_be_bytes, serialized_chars_after_be_bytes, my_obstacles_serialized)); 

//     let (enemy_objects_valid, enemy_objects) = test_result_object_builder(chars[other_side], serialize_obstacles(other_side, advances[side], obs[other_side]));
//     assert(enemy_objects_valid, "Invalid enemy objects");
//     let (my_result_objects_valid, my_result_objects) = test_result_object_builder(chars_after, my_obstacles_serialized);
//     assert(my_result_objects_valid, "Invalid my result objects");

//     let result = turn(
//         secret[side],
//         character::serialize_chars(chars[side]),
//         my_obstacles_serialized,
//         serialize_actions(actions),
//         move,
//         advances[other_side],
//         enemy_objects,
//         Event::serialize_events(their_events).as_array(),
//         advances[side],
//         Event::serialize_events(my_events).as_array(),
//         my_result_objects,
//         last_hashes[side],
//         current_hash
//     );
//     assert(result, "Invalid result");

//     (move + 1, chars_after, current_hash)
// }

// #[test]
// fn test_main() {
//     let secrets = [123456789, 9876543210];
//     let mut chars = [ character::get_default_characters(0), character::get_default_characters(1) ];
//     let mut obs = [ Obstacle::get_default_obstacles(0), Obstacle::get_default_obstacles(1) ];
//     let actions = &[
//         Action { action: MOVE, actor: 0, target_x: 2, target_y: 1 },
//         Action { action: MOVE, actor: 0, target_x: 3, target_y: 1 },
//         Action { action: MOVE, actor: 0, target_x: 4, target_y: 1 },
//         Action { action: MOVE, actor: 0, target_x: 5, target_y: 1 },
//     ];
//     let their_events: [Event] = &[Event::empty(0); MAX_EVENTS];
//     let my_events: [Event] = &[Event::empty(0); MAX_EVENTS];
//     let mut move = 0;
//     let mut actor = chars[0][0].move(5, 1);
//     let mut last_hashes = [ 0x12b8f97907a05ec6a77da3f70368fa3b02e166c74edab8ea0695d6f406146559, 0x2bca22f32b0b864574d0509ba146be256d2186fc490311756f541e1b5f8e391f ];
//     let mut advances = [2 + VIEW_DISTANCE, 29 - VIEW_DISTANCE];
//     advances[0] = 5 + VIEW_DISTANCE;

//     let mut side = move % 2;
//     let result = test_helper_execute_move(move, actor, advances, secrets, last_hashes, chars, obs, actions, my_events, their_events);
//     move = result.0;
//     chars[side] = result.1;
//     last_hashes[side] = result.2;

//     side = move % 2;
//     let actions = &[
//         Action { action: MOVE, actor: 0, target_x: 29, target_y: 1 },
//         Action { action: MOVE, actor: 0, target_x: 28, target_y: 1 },
//         Action { action: MOVE, actor: 0, target_x: 28, target_y: 0 },
//         Action { action: MOVE, actor: 0, target_x: 27, target_y: 0 },
//     ];
//     let their_events = my_events;
//     let my_events: [Event] = &[Event::empty(0); MAX_EVENTS];
//     let actor = chars[side][((move as u64 / 2) % MAX_CHARACTERS)].move(27, 0);
//     advances[side] = 27 - VIEW_DISTANCE;
//     let result = test_helper_execute_move(move, actor, advances, secrets, last_hashes, chars, obs, actions, my_events, their_events);
//     move = result.0;
//     chars[side] = result.1;
//     last_hashes[side] = result.2;

//     side = move % 2;
//     let actions = &[
//         Action { action: MOVE, actor: 1, target_x: 1, target_y: 3 },
//         Action { action: MOVE, actor: 1, target_x: 0, target_y: 3 },
//         Action { action: WAIT, actor: 1, target_x: 0, target_y: 0 },
//         Action { action: WAIT, actor: 1, target_x: 0, target_y: 0 },
//     ];
//     let their_events = my_events;
//     let my_events: [Event] = &[Event::empty(1); MAX_EVENTS];
//     let actor = chars[side][((move as u64 / 2) % MAX_CHARACTERS)].move(0, 3);
//     //advances[side] = 27 - VIEW_DISTANCE;
//     let result = test_helper_execute_move(move, actor, advances, secrets, last_hashes, chars, obs, actions, my_events, their_events);
//     move = result.0;
//     chars[side] = result.1;
//     last_hashes[side] = result.2;

//     side = move % 2;
//     let actions = &[
//         Action { action: MOVE, actor: 1, target_x: 29, target_y: 2 },
//         Action { action: MOVE, actor: 1, target_x: 29, target_y: 1 },
//         Action { action: MOVE, actor: 1, target_x: 28, target_y: 1 },
//         Action { action: WAIT, actor: 1, target_x: 0, target_y: 0 },
//     ];
//     let their_events = my_events;
//     let my_events: [Event] = &[Event::empty(1); MAX_EVENTS];
//     let actor = chars[side][((move as u64 / 2) % MAX_CHARACTERS)].move(28, 1);
//     //advances[side] = 27 - VIEW_DISTANCE;
//     let result = test_helper_execute_move(move, actor, advances, secrets, last_hashes, chars, obs, actions, my_events, their_events);
//     move = result.0;
//     chars[side] = result.1;
//     last_hashes[side] = result.2;
// }

#[test]
fn test_main_fireball_ff() {
    let secrets = [123456789, 9876543210];
    let mut chars = [
        [
            Character { id: 0, class: ARCHER, x: 9, y: 2, health: 100, status: 1, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 0, damage_mod: 0, last_action: WAIT, actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
            Character { id: 1, class: RITUALIST, x: 11, y: 3, health: 25, status: 0, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 0, damage_mod: 0, last_action: WAIT, actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
            Character { id: 2, class: ROGUE, x: 12, y: 4, health: 20, status: 0, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 1, damage_mod: 0, last_action: WAIT, actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
            Character { id: 3, class: KNIGHT, x: 10, y: 4, health: 100, status: 0, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 0, damage_mod: 0, last_action: WAIT, actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
            Character { id: 4, class: MAGE, x: 10, y: 7, health: 100, status: MIN_FIREBALL_ROUNDS_FOR_CAST + 1, target_x: 11, target_y: 4, has_been_seen: true, is_hidden: 0, damage_mod: 10, last_action: 3, actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
        ], [
            Character { id: 0, class: MAGE, x: 13, y: 2, health: 100, status: 2, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 0, damage_mod: 0, last_action: WAIT, actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
            Character { id: 1, class: ROGUE, x: 14, y: 6, health: 0, status: 0, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 1, damage_mod: 0, last_action: WAIT, actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
            Character { id: 2, class: RITUALIST, x: 16, y: 3, health: 20, status: 0, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 0, damage_mod: 0, last_action: WAIT, actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
            Character { id: 3, class: ARCHER, x: 16, y: 6, health: 100, status: 0, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 0, damage_mod: 0, last_action: WAIT, actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
            Character { id: 4, class: KNIGHT, x: 11, y: 4, health: 30, status: 0, target_x: 0, target_y: 0, has_been_seen: true, is_hidden: 0, damage_mod: 0, last_action: WAIT,actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER] },
        ]
    ];
// x, y & type, health
// 0x091264 0b2300 0c3400 0a442d 095764 000000000000000000000000000000 // direct
// 0x091264 0b2319 0c3414 0a4464 095764 000000000000000000000000000000 // turn
    let mut obs = [ get_default_obstacles(0), get_default_obstacles(1) ];
    let actions = &[
        new_action(4, 4, 11, 4), //Action { action: CAST_FIREBALL, actor: 4, target_x: 11, target_y: 4 },
        new_action(1, 4, 9, 7), //Action { action: MOVE, actor: 4, target_x: 9, target_y: 7 },
        new_action(WAIT, 4, 0, 0), //Action { action: WAIT, actor: 4, target_x: 0, target_y: 0 },
        new_action(WAIT, 4, 0, 0), //Action { action: WAIT, actor: 4, target_x: 0, target_y: 0 },
    ];
    let their_events: [Event] = &[
        Event { event: RECEIVE_ATTACK, actor_id: 3, x: 20, y: 3, subtype: ATTACK_RANGED, value: 50, radius: 0 },
        Event { event: SEE_MOVE, actor_id: 3, x: 16, y: 5, subtype: 0, value: 0, radius: 0 },
        Event { event: SEE_MOVE, actor_id: 3, x: 16, y: 6, subtype: 0, value: 0, radius: 0 },
        Event { event: NO_EVENT, actor_id: 3, x: 255, y: 255, subtype: 0, value: 0, radius: 0 },
    ];
    let my_events: [Event] = &[
        Event { event: RECEIVE_ATTACK, actor_id: 4, x: 11, y: 4, subtype: ATTACK_FIREBALL, value: 0x78, radius: 1 },
        Event { event: SEE_MOVE, actor_id: 4, x: 9, y: 7, subtype: 0, value: 0, radius: 0 },
        Event { event: NO_EVENT, actor_id: 4, x: 255, y: 255, subtype: 0, value: 0, radius: 0 },
        Event { event: NO_EVENT, actor_id: 4, x: 255, y: 255, subtype: 0, value: 0, radius: 0 },
    ];
    // event actor x y value subt rad
    // 0x091264 0b2300 0c3400 0a4428 0b5464 000000000000000000000000000000
    // 0x0a040b04780201 03040907000000 0004000000000000040000000000000000
    // 0x0a040b04780201 03040907000000 0004ffff0000000004ffff000000000000
    // 0x091264 0b2300 0c3400 0a4428 095764000000000000000000000000000000
    let mut move = 8;
    let mut actor = Character { //chars[0][4].move(9, 7).set_status(0);
        id: chars[0][4].id,
        class: chars[0][4].class,
        x: get_action_target_x(actions[1]),
        y: get_action_target_y(actions[1]),
        target_x: get_action_target_x(actions[1]), // TODO
        target_y: get_action_target_y(actions[1]),
        has_been_seen: chars[0][4].has_been_seen,
        is_hidden: 0 as u1,
        health: chars[0][4].health,
        damage_mod: chars[0][4].damage_mod,
        last_action: get_action_type(actions[1]),
        status: 0,
        actions: [[0 as u8; 29]; MAX_ACTIONS_PER_CHARACTER]
    };
    //let mut last_hashes = [ 0x090a46a65d4c7c05f3c98b25c2639539d91c1542fd78e9c9c837f96de08c6a84, 0x2bca22f32b0b864574d0509ba146be256d2186fc490311756f541e1b5f8e391f ];
    let mut last_hashes = [ 0x118fec2c103f254f64c0bf927eaf0a2cab59e21e5e1d5121b2dd7ae234b25965, 0x2bca22f32b0b864574d0509ba146be256d2186fc490311756f541e1b5f8e391f ];
    let mut advances = [12 + VIEW_DISTANCE, 18 + VIEW_DISTANCE];

    let side = move as u1;
    let other_side = (side as u8 + 1) as u1;
    let chars_after = [ chars[side][0], chars[side][1].take_damage(ATTACK_RANGED, 50).take_damage(ATTACK_FIREBALL, 60), chars[side][2].take_damage(ATTACK_FIREBALL, 54), chars[side][3].take_damage(ATTACK_FIREBALL, 60), actor ];
    let my_obstacles_serialized_for_enemy = serialize_my_obstacles(31 - advances[other_side], obs[side]);
    let my_obstacles_serialized_for_me = serialize_my_obstacles_for_me(obs[side]);
    let secret_be_bytes: [u8; 32] = secrets[side].to_be_bytes::<32>();
    assert(secret_be_bytes.len() == 32);
    let serialized_chars_after = serialize_chars(chars_after);
    let serialized_chars_after_be_bytes: [u8; 32] = serialized_chars_after.to_be_bytes::<32>();
    assert(serialized_chars_after_be_bytes.len() == 32);
    let current_hash = std::field::bytes32_to_field(get_data_hash(secret_be_bytes, serialized_chars_after_be_bytes, get_test_action_register(), my_obstacles_serialized_for_me)); 

    // turn:  0x2912640000004b03000000006c04002000008a0428000000a9076400000a
    // calc:  0x2912640000004b03000000006c04002000008a0428000000a907640b340a
    let (test_result_object_chars_after_valid, test_result_object_chars_after) = test_result_object_builder(31 - advances[other_side], chars_after, my_obstacles_serialized_for_enemy);
    let test_result_object_other_side_result = serialize_their_obstacles(31 - advances[side], obs[other_side]);
    let test_result_object_other_side = test_result_object_other_side_result.1;
    let (test_result_object_other_chars_valid, test_result_object_other_chars) = test_result_object_builder(31 - advances[side], chars[other_side], test_result_object_other_side);
    println("Test-Inputs:");
    println(secrets[side]);
    println(character::serialize_chars(chars[side]));
    // println(get_test_action_register());
    println(my_obstacles_serialized_for_me);
    println(serialize_actions(actions));
    println(move);
    println(advances[other_side]);
    println(test_result_object_other_chars);
    println(Event::serialize_events(their_events));
    println(advances[side]);
    println(Event::serialize_events(my_events));
    println(test_result_object_chars_after);
    println(last_hashes[side]);
    println(current_hash);
    println("Test-Inputs done");
    assert(test_result_object_chars_after_valid, "Invalid test result object chars after");
    assert(test_result_object_other_chars_valid, "Invalid test result object other chars");
    let result = turn(
        secrets[side],
        character::serialize_chars(chars[side]),
        // get_test_action_register(),
        my_obstacles_serialized_for_me, //obs[side],
        serialize_actions(actions),
        move,
        advances[other_side],
        test_result_object_other_chars,
        Event::serialize_events(their_events).as_array(),
        advances[side],
        Event::serialize_events(my_events).as_array(),
        test_result_object_chars_after,
        last_hashes[side],
        current_hash
    );
    assert(result, "Turn failed");
}


#[export]
pub fn setup_obstacles(
    
)