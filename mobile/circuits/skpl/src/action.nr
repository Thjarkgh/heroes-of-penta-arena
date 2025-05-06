// use crate::{ HEIGHT, WIDTH };
use arenalib::{ NO_EVENT, WAIT, SEE_MOVE, WIDTH };
use arenalib::{ MAX_ACTIONS, MAX_OBSTACLES };
use arenalib::{ SERIALIZED_ACTION_BYTE_SIZE, SERIALIZED_ACTIONS_ARRAY_SIZE, SERIALIZED_ACTIONS_PER_FIELD, VIEW_DISTANCE };
use skplg::{softassert, NOWHERE, UNREADABLE_BYTES_PER_FIELD};
use arenalib::{Action, get_action_actor, get_action_target_x, get_action_target_y, get_action_type, new_action};
// use crate::NON_EMPTY_WALKABLE_TILE_MIN;
use crate::character::Character;
use crate::event::Event;
use crate::event::{ build_subtype_value_event }; // , build_value_event
use crate::map::{ is_visible, get_distance, can_move_to };
use crate::obstacle::Obstacle;
use crate::obstacle::{ get_default_obstacles };
use arenalib::{MAGE};
use arenalib::{MAX_ACTIONS_PER_CHARACTER, MAX_ENEMY_OBSTACLES};
// use crate::ResolvedAction::ResolvedAction;
// use crate::actionDefinition::{ build_move_action };
use arenalib::{apply_action_result_effects, apply_action_pre_calc_effects, validate_action_requirements, build_result_event};
use arenalib::arena_action_def_builder;
use super::obstacle::new_obstacle;

// use crate::{ACTION_RESULT_COORDINATES_IDX_SELF, ACTION_RESULT_COORDINATES_IDX_TARGET, ACTION_RESULT_COORDINATES_IDX_INVISIBLE};
// use crate::{SEE_CAST, SEE_DRAW, SEE_RITUAL, SEE_SEARCH_TRAP, RECEIVE_ATTACK, DISARMED_TRAP, ADD_OBSTACLE, WIN};
// use crate::action_builder;



// global ACTION_TYPE: u8 = 0;
// global ACTION_ACTOR: u8 = 1;
// global ACTION_TARGET_X: u8 = 2;
// global ACTION_TARGET_Y: u8 = 3;

global SEEN_EVENT_IDX: u32 = 1;
global UNSEEN_EVENT_IDX: u32 = 0;
global WORLD_EVENT_IDX: u32 = 2;
global SELF_EVENT_IDX: u32 = 3;

pub fn execute_action(
    action: Action,
    enemy_advance: u8,
    actor: Character,
    mut energy: u8,
    my_obstacles: [Obstacle; MAX_OBSTACLES],
    their_obstacles: [Obstacle; MAX_ENEMY_OBSTACLES]
) -> (bool, Event, Event, Event, Character, u8) /*where T: ResolvedAction */{
  let enemy_advance = if enemy_advance >= WIDTH { 0 } else { WIDTH - enemy_advance - 1 };
    //let action_def = c.resolve_action(action.register[action.base_index + ACTION_TYPE]);
        //let mut result_event: Event = build_std_event(NO_EVENT, c.id, 0, 0);
        //let mut result_char = c;
        //let mut required_energy = 0;
        let mut is_valid = true;
        //let action_def = c.resolve_action(get_action_type(action));
        // let mut result_valid = true;

        // let need_sneak = get_action_type(action) == SNEAK;
        //let can_sneak = c.can_sneak();
        // let need_move = get_action_type(action) == MOVE | get_action_type(action) == SNEAK;
        // let can_move = can_move_to(get_action_target_x(action), get_action_target_y(action), my_obstacles_parsed, their_obstacles);
        // let need_target_is_neighbor = get_action_type(action) == SNEAK | get_action_type(action) == MOVE | get_action_type(action) == ATTACK | get_action_type(action) == SEARCH | get_action_type(action) == DISARM_TRAP;
        //let target_is_neighbor = is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action));
        // let need_target_is_not_self = get_action_type(action) == ATTACK | get_action_type(action) == SHOOT;
        // let target_is_not_self = (c.x != get_action_target_x(action)) | (c.y != get_action_target_y(action));
        // let need_ritual = get_action_type(action) == RITUAL;
        //let can_ritual = c.can_ritual();
        // let need_search = get_action_type(action) == SEARCH;
        //let can_search = c.can_search();
        //let can_attack = is_neighbor & not_self;
        // let need_can_cast_fireball = get_action_type(action) == CAST_FIREBALL;
        // let min_rounds_to_finish = if get_action_type(action) == CAST_FIREBALL {
        //     FIREBALL_ROUNDS_FOR_CAST
        // } else if get_action_type(action) == RITUAL {
        //     RITUAL_ROUNDS_FOR_WIN
        // } else if get_action_type(action) == SHOOT {
        //     MIN_DRAW_ROUNDS_FOR_SHOOT
        // } else {
        //     0
        // };
        // let max_rounds_to_finish = if get_action_type(action) == CAST_FIREBALL {
        //     FIREBALL_ROUNDS_FOR_CAST
        // } else if get_action_type(action) == RITUAL {
        //     RITUAL_ROUNDS_FOR_WIN
        // } else if (get_action_type(action) == DRAW) | (get_action_type(action) == SHOOT) {
        //     MAX_DRAW_ROUNDS_FOR_SHOOT
        // } else {
        //     0
        // };
        // let need_check_status = get_action_type(action) == CAST_FIREBALL | get_action_type(action) == RITUAL | get_action_type(action) == DRAW | get_action_type(action) == SHOOT;
        // let can_cast_fireball = c.can_cast_fireball(); // & (result_char.status <= FIREBALL_ROUNDS_FOR_CAST);
        // let can_draw = c.can_shoot(); // & (c.status < MAX_DRAW_ROUNDS_FOR_SHOOT);
        // let can_shoot = c.can_shoot(); // & (c.status >= MIN_DRAW_ROUNDS_FOR_SHOOT);
        // let can_disarm = c.can_disarm();
        // let is_valid =
        //     (get_action_type(action) == WAIT) |
        //     ((get_action_type(action) == SNEAK) & can_sneak & can_move & target_is_neighbor) |
        //     ((get_action_type(action) == MOVE) & can_move & target_is_neighbor) |
        //     ((get_action_type(action) == RITUAL) & can_ritual) |
        //     ((get_action_type(action) == SEARCH) & can_search & target_is_neighbor) |
        //     ((get_action_type(action) == ATTACK) & target_is_neighbor & target_is_not_self) |
        //     ((get_action_type(action) == CAST_FIREBALL) & can_cast_fireball & result_char.status <= max_rounds_to_finish) |
        //     ((get_action_type(action) == DRAW) & can_draw) |
        //     ((get_action_type(action) == SHOOT) & can_shoot & target_is_not_self) |
        //     ((get_action_type(action) == DISARM_TRAP) & can_disarm & target_is_neighbor);




        // need to adapt status first in case of action interruption!

    //let action_type = action.get_action_type(action);
    //let action_def = c.resolve_action(action_type);
    let action_type = get_action_type(action);

    let actor_id = actor.get_id();
    let actor_x = actor.get_x();
    let actor_y = actor.get_y();
    let actor_target_x = actor.get_target_x();
    let actor_target_y = actor.get_target_y();
    let actor_last_action = actor.get_last_action();
    let (action_def_valid, action_def) = actor.get_action(action_type);
    softassert!(quote { is_valid }, quote { action_def_valid }, quote { f"Failed to fetch action def of {action_type}" });

    let action_target_x = get_action_target_x(action);
    let action_target_y = get_action_target_y(action);
    let distance = get_distance(actor_x, actor_y, action_target_x, action_target_y);

    // let is_continuous = action.get_action_is_continuous();
    // let is_not_interrupted = (
    //     ((!is_continuous) & (action.get_action_result_status_multiplier() != 0)) | // that's the ID of the wait action => leave status, but not continuous
    //     ((is_continuous) & (action.get_action_req_previous_action() == c.last_action) & (action_target_x == c.get_target_x()) & (action_target_y == c.get_target_y()))
    // );


    let mut actor_progress = actor.get_progress();
    let mut actor_is_hidden = actor.get_is_hidden() == 1;
    let actor_is_in_view_range = is_visible(enemy_advance, actor_x);
    // let max_range_part = get_action_req_max_range(action) as u16;
    // let mut actor_max_range = max_range_part * max_range_part;
    let mut is_not_interrupted = true;
    let mut actor_damage_mod = actor.get_damage_mod();
    let mut actor_status = actor.get_status();
    // ~200 gates
    apply_action_pre_calc_effects!(quote { action_def });


///////////////////////////
    // ~4000 gates
    validate_action_requirements!(quote { is_valid }, quote { action_def });
    // // pub global ACTION_NEEDS_TARGET_FREE_SPACE: u8 = 0;  // u1
    // let target_is_free_space_valid = !action.get_action_req_target_free_space() | can_move_to(distance, action_target_x, action_target_y, my_obstacles, their_obstacles);
    // softassert!(quote { is_valid }, quote { target_is_free_space_valid }, quote { f"Target space ({action_target_x},{action_target_y}) cannot be moved to: {VIEW_DISTANCE},{my_obstacles},{their_obstacles}" });
    
    // // pub global ACTION_NEEDS_TARGET_IS_NOT_SELF: u8 = 1; // u1
    // let target_is_not_self_valid = !action.get_action_req_target_is_not_self() | (c_x != action_target_x) | (c_y != action_target_y);
    // softassert!(quote { is_valid }, quote { target_is_not_self_valid }, quote { f"Target cannot be self ({action_target_x},{action_target_y})" });

    // // pub global ACTION_NEEDS_STATUS_HIDDEN: u8 = 4; // u1
    // let char_is_hidden = c.is_hidden == 1;
    // let char_is_hidden_valid = !action.get_action_req_status_hidden() | char_is_hidden;
    // softassert!(quote { is_valid }, quote { char_is_hidden_valid }, quote { f"Character needs to be hidden to perform action {action_type}" });
    
    // // pub global ACTION_NEEDS_STATUS_VISIBLE: u8 = 2; // u1
    // let char_is_in_view_range = is_visible(enemy_advance, c_x);
    // let char_is_fully_visible = char_is_in_view_range & !char_is_hidden;
    // let char_is_fully_visible_valid = !action.get_action_req_status_visible() | char_is_fully_visible;
    // softassert!(quote { is_valid }, quote { char_is_fully_visible_valid }, quote { f"Character must be fully visible for action {action_type}: in_view_range: {char_is_in_view_range} & !hidden {char_is_hidden} for enemy_advance {enemy_advance} @ {c_x}" });

    // // pub global ACTION_NEEDS_STATUS_INVISIBLE: u8 = 3; // u1
    // let char_invisible_valid = !action.get_action_req_status_invisible() | !char_is_in_view_range | char_is_hidden;
    // softassert!(quote { is_valid }, quote { char_invisible_valid }, quote { f"Character must not be visible to perform action {action_type}: !in_view_range: {char_is_in_view_range} || hidden: {char_is_hidden} for enemy_advance {enemy_advance} @ {c_x}" });

    // // pub global ACTION_MAX_RANGE: u8 = 7; // u6 // TODO: max_range!
    // let max_range_part = action.get_action_req_max_range() as u16;
    // let max_range = max_range_part * max_range_part;
    // let max_range_valid  = distance <= max_range;
    // softassert!(quote { is_valid }, quote { max_range_valid }, quote { f"Character is out of range! Distance: {distance} > {max_range}: {{{c_x},{c_y}}} - {{{action_target_x},{action_target_y}}} with {max_range_part}" });

    // // pub global ACTION_NEEDS_MIN_STATUS: u8 = 8; // u4
    // let min_status = action.get_action_req_min_status();
    // let min_status_valid = min_status <= status;
    // softassert!(quote { is_valid }, quote { min_status_valid }, quote { f"Character needs min status {min_status} to perform action {action_type}, but only has {status}" });

    // // pub global ACTION_NEEDS_MAX_STATUS: u8 = 9; // u4
    // let max_status = action.get_action_req_max_status();
    // let max_status_valid = max_status >= status;
    // softassert!(quote { is_valid }, quote { max_status_valid }, quote { f"Character cannot have a higher status than {max_status} to perform action {action_type}: got {status}" });

    // // pub global ACTION_NEEDED_ENERGY: u8 = 10;    // u4
    // let required_energy = action.get_action_req_energy();
    // let energy_valid = required_energy <= energy;
    // softassert!(quote { is_valid }, quote { energy_valid }, quote { f"Character has insufficient energy left to perform action {action_type}: {energy} < {required_energy}" });
    //////////////////////
    

        let coords = [
            (actor_x, actor_y),
            (action_target_x, action_target_y),
            (NOWHERE, NOWHERE),
        ];

    // pub global ACTION_RESULT_STATUS_MULTIPLIER: u8 =     ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT;     // u1
    // pub global ACTION_RESULT_STATUS_FIXED_ADDITION: u8 = ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT + 1; // u4
    // pub global ACTION_MOVE_TO_TARGET: u8 =               ACTION_REQUIREMENTS_FIELD_COUNT + 2 * ACTION_RESULT_EVENT_FIELD_COUNT + 2; // u1
    // pub global ACTION_SETS_STATUS_HIDDEN: u8 = 5; // u1
    // pub global ACTION_REMOVES_STATUS_HIDDEN: u8 = 6; // u1

        // CALCULATE EVENTS
        comptime {
          assert(SEEN_EVENT_IDX == 1);
          assert(UNSEEN_EVENT_IDX == 0);
        }
        //let result_event_idx = is_visible as u32;
        let mut events: BoundedVec<Event, 4> = BoundedVec::new();
        // 19000 gates
        // events.push(build_subtype_value_event(0, 0, 0, 0, 0, 0, 0));
        // events.push(build_subtype_value_event(0, 0, 0, 0, 0, 0, 0));
        // events.push(build_subtype_value_event(0, 0, 0, 0, 0, 0, 0));
        // events.push(build_subtype_value_event(0, 0, 0, 0, 0, 0, 0));
        build_result_event!(0 as u32, quote { events }, quote { is_valid }, quote { action_def });
        build_result_event!(1 as u32, quote { events }, quote { is_valid }, quote { action_def });
        build_result_event!(2 as u32, quote { events }, quote { is_valid }, quote { action_def });
        build_result_event!(3 as u32, quote { events }, quote { is_valid }, quote { action_def });
        assert(events.len() == 4);

        // let seen_event_value = status as u32 * action.get_action_result_event_seen_value_status_multiplier() as u32 + action.get_action_result_event_seen_value_fixed_addition() as u32;
        // softassert!(quote { is_valid }, quote { seen_event_value <= 255 as u32 }, quote { f"Invalid event value (seen): {seen_event_value} does not fit in u8!" });

        // let unseen_event_value = status as u32 * action.get_action_result_event_not_seen_value_status_multiplier() as u32 + action.get_action_result_event_not_seen_value_fixed_addition() as u32;
        // softassert!(quote { is_valid }, quote { unseen_event_value <= 255 as u32 }, quote { f"Invalid event value (unseen): {unseen_event_value} does not fit in u8!" });

        // let seen_event_coords_idx = action.get_action_result_event_seen_coord_idx();
        // softassert!(quote { is_valid }, quote { seen_event_coords_idx < 4 }, quote { f"Invalid seen event coord idx: {seen_event_coords_idx} > 3" });

        // let seen_event_coords = coords[seen_event_coords_idx & 3];

        // let unseen_event_coords_idx = action.get_action_result_event_not_seen_coord_idx();
        // softassert!(quote { is_valid }, quote { unseen_event_coords_idx < 4 }, quote { f"Invalid unseen event coord idx: {unseen_event_coords_idx} > 3" });

        // let unseen_event_coords = coords[unseen_event_coords_idx & 3];

        // //let events = [
        // let dummy_event =    build_subtype_value_event(NO_EVENT, c.get_id(), coords[ACTION_RESULT_COORDINATES_IDX_INVISIBLE].0, coords[ACTION_RESULT_COORDINATES_IDX_INVISIBLE].1, 0 as u8, 0 as u8, 0 as u8);
        // let unseen_event =    build_subtype_value_event(
        //         action.get_action_result_event_not_seen_type(),
        //         c.get_id(), 
        //         unseen_event_coords.0,
        //         unseen_event_coords.1,
        //         unseen_event_value as u8,
        //         action.get_action_result_event_not_seen_subtype(),
        //         action.get_action_result_event_not_seen_radius()
        //     );
        // let seen_event =    build_subtype_value_event(
        //         action.get_action_result_event_seen_type(),
        //         c.get_id(), 
        //         seen_event_coords.0,
        //         seen_event_coords.1,
        //         seen_event_value as u8,
        //         action.get_action_result_event_seen_subtype(),
        //         action.get_action_result_event_seen_radius()
        //     );
        //];


        // APPLY EFFECTS ON SELF
        let mut result_energy = energy;
        let mut result_coords = coords[0];
        let mut result_progress = actor_progress;
        let mut result_is_hidden = actor_is_hidden;
        let mut result_is_visible = actor_is_in_view_range;
        let mut result_damage_mod = actor_damage_mod;
        let mut result_health = actor.get_health();
        let mut result_status = actor_status;


        // let energy = std::wrapping_sub(energy, action.get_action_req_energy());
        // let status = actor_progress as u32 * action.get_action_result_status_multiplier() as u32 + action.get_action_result_status_fixed_addition() as u32;
        // softassert!(quote { is_valid }, quote { status <= MAX_STATUS as u32 }, quote { f"Invalid result status: {status} > {MAX_STATUS}" });

        // let final_coords = coords[action.get_action_move_to_target() as u8];
        // // debug!(quote { println(f"final_coords:{final_coords}"); });
        // let is_hidden = ((c.is_hidden == 1) & !action.get_action_result_effect_removes_status_hidden()) | action.get_action_result_effect_sets_status_hidden();
        // let is_visible = !is_hidden & is_visible(enemy_advance, final_coords.0);
        // 200 gates
        apply_action_result_effects!(quote { action_def });

// let result_coord_src = action_def[6] as u8;
// let result_coord_src_fixed = result_coord_src & 4 as u8;
// let result_coord = result_coord_src_fixed != 0 as u8;
// let result_coord_cast = result_coord as u8;
// println(f"result coords: {result_coord_src} {result_coord_src_fixed} {result_coord} {result_coord_cast}");
// result_coords = coords[((action_def[6]as u8 / 4 as u8) == 1 as u8)as u8];
        // let target_coords = [
        //     (target_x, target_y),
        //     (c.get_target_x(), c.get_target_y())
        // ];

        (
            is_valid,
            if result_is_visible { events.get_unchecked(SEEN_EVENT_IDX) } else { events.get_unchecked(UNSEEN_EVENT_IDX) },//events[1 + (is_visible as u8)],
            events.get_unchecked(WORLD_EVENT_IDX),
            events.get_unchecked(SELF_EVENT_IDX),//events[get_action_unseen_event_is_internal(action_def) as u8],
            Character {
                id: actor_id,
                x: result_coords.0,
                y: result_coords.1,
                progress: result_progress, // status as u8,
                is_hidden: result_is_hidden as u1, //is_hidden as u1,
                has_been_seen: result_is_visible, //is_visible,
                last_action: is_not_interrupted as u8 * actor.get_last_action() + (!is_not_interrupted) as u8 * action_type,
                target_x: is_not_interrupted as u8 * actor.get_target_x() + (!is_not_interrupted) as u8 * action_target_x, // if is_not_interrupted { c.get_target_x() } else { get_action_target_x(action) };
                target_y: is_not_interrupted as u8 * actor.get_target_y() + (!is_not_interrupted) as u8 * action_target_y,
                class: actor.class,
                damage_mod: result_damage_mod,
                health: result_health,
                status: result_status,
                actions: actor.actions,
            },
            result_energy
        )

        // if get_action_type(action) == SNEAK {
        //     //assert(c.can_sneak());
        //     if !can_sneak { let actor_id = c.id; println(f"Failed to execute action: Character {actor_id} cannot sneak"); }
        //     //assert(can_move_to(get_action_target_x(action), get_action_target_y(action), my_obstacles_parsed, their_obstacles));
        //     //assert(is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action)));
        //     // result_valid = c.can_sneak() & can_move_to(get_action_target_x(action), get_action_target_y(action), my_obstacles_parsed, their_obstacles) & is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action));
        //     result_char.x = get_action_target_x(action);  
        //     result_char.y = get_action_target_y(action);
        //     result_char.status = 0;
        //     required_energy = c.get_energy_per_sneak();
        // }
        // if get_action_type(action) == MOVE {
        //     // assert(can_move_to(get_action_target_x(action), get_action_target_y(action), my_obstacles_parsed, their_obstacles));
        //     // assert(is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action)));
        //     // result_valid = can_move_to(get_action_target_x(action), get_action_target_y(action), my_obstacles_parsed, their_obstacles) & is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action));
        //     result_char.x = get_action_target_x(action);
        //     result_char.y = get_action_target_y(action);
        //     result_char.status = 0;
        //     required_energy = c.get_energy_per_move();
        //     result_char.has_been_seen = is_visible(enemy_advance, result_char.x);
        //     if c.get_has_been_seen() {
        //         result_event = build_std_event(SEE_MOVE, c.id, get_action_target_x(action), get_action_target_y(action));
        //     }
        // }
        // if get_action_type(action) == RITUAL {
        //     //assert(c.can_ritual());
        //     // result_valid = c.can_ritual();
        //     result_char.status += 1;
        //     if result_char.status >= RITUAL_ROUNDS_FOR_WIN {
        //         result_event = build_std_event(WIN, c.id, 0, 0);
        //     } else {
        //         result_event = build_std_event(SEE_RITUAL, c.id, 0, 0);
        //     }
        //     required_energy = c.get_energy_per_ritual();
        // }
        // if get_action_type(action) == SEARCH {
        //     // assert(c.can_search());
        //     // assert(is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action)));
        //     // result_valid = c.can_search() & is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action));
        //     result_char.status = 0;
        //     result_event = build_std_event(SEE_SEARCH_TRAP, c.id, get_action_target_x(action), get_action_target_y(action));
        //     required_energy = c.get_energy_per_search();
        // }
        // if get_action_type(action) == ATTACK {
        //     // assert(is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action)));
        //     // assert((c.x != get_action_target_x(action)) | (c.y != get_action_target_y(action)));
        //     // result_valid = is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action)) & ((c.x != get_action_target_x(action)) | (c.y != get_action_target_y(action)));
        //     result_char.status = 0;
        //     result_event = build_subtype_value_event(RECEIVE_ATTACK, c.id, get_action_target_x(action), get_action_target_y(action), c.get_damage(ATTACK_MELEE), ATTACK_MELEE);
        //     required_energy = c.get_energy_per_attack();
        // }
        // // TODO: global SET_TRAP = 6 as u8;
        // if get_action_type(action) == CAST_FIREBALL {
        //     // assert(c.can_cast_fireball());
        //     result_char.status += 1;
        //     // assert(result_char.status <= FIREBALL_ROUNDS_FOR_CAST);
        //     // result_valid = c.can_cast_fireball() & (result_char.status <= FIREBALL_ROUNDS_FOR_CAST);
        //     if result_char.status >= FIREBALL_ROUNDS_FOR_CAST {
        //         // TODO: handle friendly fire and destruction of own walls and own traps
        //         result_event = build_subtype_value_event(RECEIVE_ATTACK, c.id, get_action_target_x(action), get_action_target_y(action), c.get_damage(ATTACK_FIREBALL), ATTACK_FIREBALL);
        //     } else {
        //         if c.get_has_been_seen() {
        //             result_event = build_subtype_value_event(SEE_CAST, c.id, get_action_target_x(action), get_action_target_y(action), 0, ATTACK_FIREBALL);
        //         }
        //     }
        //     required_energy = c.get_energy_per_cast();
        // }
        // if get_action_type(action) == DRAW {
        //     // assert(c.can_shoot());
        //     // assert(c.status < MAX_DRAW_ROUNDS_FOR_SHOOT);
        //     // result_valid = c.can_shoot() & (c.status < MAX_DRAW_ROUNDS_FOR_SHOOT);
        //     result_char.status += 1;
        //     if c.get_has_been_seen() {
        //         result_event = build_std_event(SEE_DRAW, c.id, get_action_target_x(action), get_action_target_y(action));
        //     }
        //     required_energy = c.get_energy_per_draw();
        // }
        // if get_action_type(action) == SHOOT {
        //     // assert(c.can_shoot());
        //     // assert(c.status >= MIN_DRAW_ROUNDS_FOR_SHOOT);
        //     // assert((c.x != get_action_target_x(action)) | (c.y != get_action_target_y(action)));
        //     // result_valid = c.can_shoot() & (c.status >= MIN_DRAW_ROUNDS_FOR_SHOOT) & ((c.x != get_action_target_x(action)) | (c.y != get_action_target_y(action)));
        //     result_char.status = 0;
        //     // TODO: check distance! abs(c.x - get_action_target_x(action)) + abs(c.y - get_action_target_y(action)) <= c.get_shoot_range()
        //     result_event = build_subtype_value_event(RECEIVE_ATTACK, c.id, get_action_target_x(action), get_action_target_y(action), c.get_damage(ATTACK_RANGED), ATTACK_RANGED);
        //     required_energy = c.get_energy_per_shoot();

        // }
        // // TODO: SET_TRAP
        // if get_action_type(action) == DISARM_TRAP {
        //     // assert(c.can_disarm());
        //     // assert(is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action)));
        //     // result_valid = c.can_disarm() & is_neighbor(c.x, c.y, get_action_target_x(action), get_action_target_y(action));
        //     result_char.status = 0;
        //     result_event = build_std_event(DESTROY, c.id, get_action_target_x(action), get_action_target_y(action));
        //     required_energy = c.get_energy_per_disarm();
        // }
        
        // // assert(energy >= required_energy);
        // let result_valid = is_valid & (energy >= required_energy);
        // if result_valid {
        //     energy -= required_energy;
        // }
        // // energy -= required_energy;
        // (result_valid, result_event, result_char, energy)
    }
//}

//global test_actions: [TestActionDefinition; 1] = [
    // build_test_action_def!(build_wait_action_def(), quote { 0, 1, 3, 4 }),
    //TestActionDefinition { register: build_test_action_def!(build_wait_action_def()), action: new_action(0, 1, 3, 4) },
    // build_move_action(class_energy_per_move[ARCHER]),
    //     build_attack_action(class_energy_per_attack[ARCHER], ATTACK_MELEE, 1, class_damage[0][ARCHER]),
    //     build_draw_action(3, class_energy_per_draw[ARCHER], 10, ARCHER),
    //     build_shoot_action(3, class_energy_per_shoot[ARCHER], ATTACK_RANGED, 8, class_damage[1][ARCHER], 2, MIN_DRAW_ROUNDS_FOR_SHOOT, MAX_DRAW_ROUNDS_FOR_SHOOT), // archer
    //     build_wait_action_def(),
    //     ,
    // ],
    // [
    //     build_move_action(class_energy_per_move[RITUALIST]),
    //     build_attack_action(class_energy_per_attack[RITUALIST], ATTACK_MELEE, 1, class_damage[0][RITUALIST]),
    //     build_cast_action(3, class_energy_per_cast[RITUALIST], RITUALIST),
    //     build_ritual_action(3, class_energy_per_ritual[RITUALIST]),
    //     build_wait_action_def(),
    //     build_wait_action_def(),
    // ],
    // [
    //     build_move_action(class_energy_per_move[ROGUE]),
    //     build_attack_action(class_energy_per_attack[ROGUE], ATTACK_MELEE, 1, class_damage[0][ROGUE]),
    //     build_sneak_action(class_energy_per_sneak[ROGUE]),
    //     build_search_action(class_energy_per_search[ROGUE], 1),
    //     build_disarm_trap_action(class_energy_per_disarm[ROGUE], 1),
    //     build_set_trap_action(class_energy_per_disarm[ROGUE], 1),
    // ],
    // [
    //     build_move_action(class_energy_per_move[KNIGHT]),
    //     build_attack_action(class_energy_per_attack[KNIGHT], ATTACK_MELEE, 1, class_damage[0][KNIGHT]),
    //     build_wait_action_def(),
    //     build_wait_action_def(),
    //     build_wait_action_def(),
    //     build_wait_action_def(),
    // ],
    // [
    //     build_move_action(class_energy_per_move[MAGE]),
    //     build_attack_action(class_energy_per_attack[MAGE], ATTACK_MELEE, 1, class_damage[0][MAGE]),
    //     build_cast_action(3, class_energy_per_cast[MAGE], MAGE),
    //     build_evocation_action(3, class_energy_per_cast[MAGE], ATTACK_FIREBALL, 6, 1,class_damage[2][MAGE], 5, FIREBALL_ROUNDS_FOR_CAST, FIREBALL_ROUNDS_FOR_CAST),
    //     build_wait_action_def(),
    //     build_wait_action_def()
    // ]
// ]

// pub fn create_test_action(action: Action) -> TestActionDefinition {
//     TestActionDefinition {
//         register: 
//     }
// }

// pub struct TestActionDefinition {
//     pub register: [u8; ACTION_DEFINITION_SIZE],
//     pub action: Action,
// }

// impl ResolvedAction for TestActionDefinition {
//     fn get_action_needs_target_free_space(self: TestActionDefinition) -> bool {
//         self.register[ACTION_NEEDS_TARGET_FREE_SPACE] == 1
//     }
//     fn get_action_needs_target_is_not_self(self: TestActionDefinition) -> bool {
//         self.register[ACTION_NEEDS_TARGET_IS_NOT_SELF] == 1
//     }
//     fn get_action_needs_status_visible(self: TestActionDefinition) -> bool {
//         self.register[ACTION_NEEDS_STATUS_VISIBLE] == 1
//     }
//     fn get_action_needs_status_invisible(self: TestActionDefinition) -> bool {
//         self.register[ACTION_NEEDS_STATUS_INVISIBLE] == 1
//     }
//     fn get_action_needs_status_hidden(self: TestActionDefinition) -> bool {
//         self.register[ACTION_NEEDS_STATUS_HIDDEN] == 1
//     }
//     fn get_action_sets_status_hidden(self: TestActionDefinition) -> bool {
//         self.register[ACTION_SETS_STATUS_HIDDEN] == 1
//     }
//     fn get_action_removes_status_hidden(self: TestActionDefinition) -> bool {
//         self.register[ACTION_REMOVES_STATUS_HIDDEN] == 1
//     }
//     fn get_action_max_range(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_MAX_RANGE]
//     }
//     fn get_action_needs_min_status(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_NEEDS_MIN_STATUS]
//     }
//     fn get_action_needs_max_status(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_NEEDS_MAX_STATUS]
//     }
//     fn get_action_needed_energy(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_NEEDED_ENERGY]
//     }
//     fn get_action_unseen_event_is_internal(self: TestActionDefinition) -> bool {
//         self.register[ACTION_EVENT_IS_TRAP] == 1
//     }
//     fn get_action_result_event_seen_type(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_SEEN_TYPE]
//     }
//     fn get_action_result_event_seen_subtype(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_SEEN_SUBTYPE]
//     }
//     fn get_action_result_event_seen_value_status_multiplier(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_SEEN_VALUE_STATUS_MULTIPLIER]
//     }
//     fn get_action_result_event_seen_value_fixed_addition(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_SEEN_VALUE_FIXED_ADDITION]
//     }
//     fn get_action_result_event_seen_coord_idx(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_SEEN_COORD_IDX]
//     }
//     fn get_action_result_event_seen_radius(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_SEEN_RADIUS]
//     }
//     fn get_action_result_event_not_seen_type(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_NOT_SEEN_TYPE]
//     }
//     fn get_action_result_event_not_seen_subtype(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_NOT_SEEN_SUBTYPE]
//     }
//     fn get_action_result_event_not_seen_value_status_multiplier(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_NOT_SEEN_VALUE_STATUS_MULTIPLIER]
//     }
//     fn get_action_result_event_not_seen_value_fixed_addition(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_NOT_SEEN_VALUE_FIXED_ADDITION]
//     }
//     fn get_action_result_event_not_seen_coord_idx(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_NOT_SEEN_COORD_IDX]
//     }
//     fn get_action_result_event_not_seen_radius(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_EVENT_NOT_SEEN_RADIUS]
//     }
//     fn get_action_result_status_multiplier(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_STATUS_MULTIPLIER]
//     }
//     fn get_action_result_status_fixed_addition(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_RESULT_STATUS_FIXED_ADDITION]
//     }
//     fn get_action_move_to_target(self: TestActionDefinition) -> u1 {
//         self.register[ACTION_MOVE_TO_TARGET] as u1
//     }
//     fn get_action_is_continuous(self: TestActionDefinition) -> bool {
//         self.register[ACTION_IS_CONTINUOUS] == 1
//     }
//     fn get_action_needs_previous_action(self: TestActionDefinition) -> u8 {
//         self.register[ACTION_NEEDS_PREVIOUS_ACTION]
//     }

//     fn get_action_target_x(self) -> u8 {
//         get_action_target_x(self.action)
//     }
//     fn get_action_target_y(self) -> u8 {
//         get_action_target_y(self.action)
//     }
//     fn get_action_type(self) -> u8 {
//         get_action_type(self.action)
//     }
// }

#[test]
fn test_execute_action() {
  // global action_serde: ActionSerDe = ActionSerDe::new(MAX_ACTIONS, MAX_ACTIONS_PER_CHARACTER as u8, WIDTH, HEIGHT, WAIT);
// let action_builder = get_arena_action_def_builder();
    let action_def = arena_action_def_builder.build_move_action(4); //, quote { 1, 2, 3, 4 }; //new_action(1, 2, 3, 4);
    // let wait_action = arena_action_def_builder.build_wait_action_def();
    let action = new_action(1, 2, 3, 4);
    let their_advance = 30;
    let mut actions = [[0; 32]; MAX_ACTIONS_PER_CHARACTER + 1];
    actions[1] = action_def;
    let actor = Character {
        id: 2,
        x: 2,
        y: 4,
        target_x: 0,
        target_y: 0,
        health: 255,
        damage_mod: 1,
        last_action: WAIT,
        class: MAGE,
        is_hidden: 0 as u1,
        has_been_seen: true,
        progress: 0,
        status: 0,
        actions: actions
    };
    let energy = 15;
    let my_obstacles = get_default_obstacles(0);
    let (no_obstacle_valid, no_obstacle) = new_obstacle(0, NOWHERE, NOWHERE, 255, 0);
    assert(no_obstacle_valid);
    let their_obstacles = get_default_obstacles(1).as_slice().push_back(no_obstacle).push_back(no_obstacle).push_back(no_obstacle).push_back(no_obstacle).push_back(no_obstacle);
    let (valid, event, _, internal_event, c, result_energy) = execute_action(
        action,
        their_advance,
        actor,
        energy,
        my_obstacles,
        their_obstacles.as_array()
    );
    assert(valid, "valid");
    assert(event.actor_id == actor.id, f"{event}.actorid is not {actor}.id");
    assert(event.event == SEE_MOVE, f"{event} is not {SEE_MOVE}");
    assert(event.x == get_action_target_x(action), f"{event}.target_x is not action target x");
    assert(event.y == get_action_target_y(action), f"{event}.target_y is not action target y");
    assert(c.x == event.x, f"{c}.x is not event {event}.x");
    assert(internal_event.event == NO_EVENT, f"expected no internal event, got {internal_event}");
    assert(result_energy == 11, f"{result_energy} != 11");
}



pub fn parse_actions(fields: [Field; SERIALIZED_ACTIONS_ARRAY_SIZE]) -> [Action; MAX_ACTIONS] {
    comptime {
        assert(UNREADABLE_BYTES_PER_FIELD + SERIALIZED_ACTIONS_PER_FIELD * SERIALIZED_ACTION_BYTE_SIZE <= 32);
        assert(SERIALIZED_ACTIONS_ARRAY_SIZE * SERIALIZED_ACTIONS_PER_FIELD == MAX_ACTIONS);
        assert(SERIALIZED_ACTION_BYTE_SIZE >= 4);
    }

    let mut actions: [Action] = &[];
    for i in 0..SERIALIZED_ACTIONS_ARRAY_SIZE {
        let split: [u8; 32] = fields[i].to_be_bytes::<32>();
        //assert(split.len() == 32);
        for j in 0..SERIALIZED_ACTIONS_PER_FIELD {
            let offset = UNREADABLE_BYTES_PER_FIELD + j * SERIALIZED_ACTION_BYTE_SIZE;
            actions = actions.push_back(new_action(
                split[offset],
                split[offset + 1],
                split[offset + 2],
                split[offset + 3],
            ));
            /*Action {
                action: split[offset],
                actor: split[offset + 1],
                target_x: split[offset + 2],
                target_y: split[offset + 3],
            }*/
        }
    }
    actions.as_array()
}

/**
* Warning: This function can throw!!!
*/
// pub fn serialize_actions(actions: [Action]) -> [Field; SERIALIZED_ACTIONS_ARRAY_SIZE] {
//     comptime {
//         assert(UNREADABLE_BYTES_PER_FIELD + SERIALIZED_ACTIONS_PER_FIELD * SERIALIZED_ACTION_BYTE_SIZE <= 32);
//         assert(SERIALIZED_ACTIONS_ARRAY_SIZE * SERIALIZED_ACTIONS_PER_FIELD == MAX_ACTIONS);
//         assert(SERIALIZED_ACTION_BYTE_SIZE >= 4);
//     }

//     assert(actions.len() <= MAX_ACTIONS);

//     let mut actions_stuffed: [Action; MAX_ACTIONS] = [new_action(WAIT, 0, 0, 0); MAX_ACTIONS];
//     for i in 0..actions.len() {
//         actions_stuffed[i] = actions[i];
//     }

//     let mut fields: [Field] = &[];
//     for i in 0..SERIALIZED_ACTIONS_ARRAY_SIZE {
//         let mut data: [u8; 32] = [0; 32];
//         for j in 0..SERIALIZED_ACTIONS_PER_FIELD {
//             let index = i * SERIALIZED_ACTIONS_PER_FIELD + j;
//             let action = actions_stuffed[index];
//             let offset = UNREADABLE_BYTES_PER_FIELD + j * SERIALIZED_ACTION_BYTE_SIZE;
//             data[offset] = get_action_type(action);
//             data[offset + 1] = get_action_actor(action);
//             data[offset + 2] = get_action_target_x(action);
//             data[offset + 3] = get_action_target_y(action);
//         }
//         fields = fields.push_back(std::field::bytes32_to_field(data));
//     }
//     fields.as_array()
// }