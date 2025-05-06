// use crate::{softassert};
// use crate::actionDefinition::{DEF_ROW, build_over_def_array, derive_action_def_def_struct, derive_action_def_def_builder, get_def_register_value, get_action_def_def_register_size};
// use std::append::Append;

//     // fn get_action_req_target_free_space(self) -> bool;
//     // fn get_action_req_target_is_not_self(self) -> bool;
//     // fn get_action_req_status_visible(self) -> bool;
//     // fn get_action_req_status_invisible(self) -> bool;
//     // fn get_action_req_status_hidden(self) -> bool;
//     // fn get_action_req_max_range(self) -> u8;
//     // fn get_action_req_min_status(self) -> u8;
//     // fn get_action_req_max_status(self) -> u8;
//     // fn get_action_req_energy(self) -> u8;
//     // fn get_action_req_previous_action(self) -> u8;
// pub type ActionDefDefRequirementCheck = (Quoted, Quoted);
// comptime fn action_def_def(varname: Quoted, bit_size: u8, expr: Quoted, msg: Quoted) -> DEF_ROW<ActionDefDefRequirementCheck> {
//     (varname, bit_size, (expr, msg))
// }
// // comptime global ACTION_DEF_DEF_FIELD_COUNT: u32 = 11;
// comptime global ACTION_DEF_DEF_REQUIREMENTS: [DEF_ROW<ActionDefDefRequirementCheck>] = [
//     action_def_def(quote { action_req_target_free_space }, 1, quote { can_move_to(distance, action_target_x, action_target_y, my_obstacles, their_obstacles) }, quote { f"Target space ({action_target_x},{action_target_y}) cannot be moved to: {VIEW_DISTANCE},{my_obstacles},{their_obstacles}" }),
//     action_def_def(quote { action_req_target_is_not_self }, 1, quote { (actor_x != action_target_x) | (actor_y != action_target_y) }, quote { f"Target cannot be self ({action_target_x},{action_target_y})" }),
//     action_def_def(quote { action_req_status_visible }, 1, quote { actor_is_in_view_range & !actor_is_hidden },  quote { f"Character must be fully visible for action {action_type}: in_view_range: {actor_is_in_view_range} & !hidden {actor_is_hidden} for enemy_advance {enemy_advance} @ {actor_x}" }),
//     action_def_def(quote { action_req_status_invisible }, 1, quote { !actor_is_in_view_range | actor_is_hidden }, quote { f"Character must not be visible to perform action {action_type}: !in_view_range: {actor_is_in_view_range} || hidden: {actor_is_hidden} for enemy_advance {enemy_advance} @ {actor_x}" }),
//     action_def_def(quote { action_req_status_hidden }, 1, quote { actor_is_hidden }, quote { f"Character needs to be hidden to perform action {action_type}" }),
//     // action_def_def(quote { action_req_previous_action }, 3, quote { true }, quote { f"" }),
//     action_def_def(quote { action_req_min_progress }, 4, quote { action_req_min_progress as u8 <= actor_progress as u8 }, quote { f"Character needs min progress {action_req_min_progress} to perform action {action_type}, but only has {actor_progress}" }),
//     action_def_def(quote { action_req_max_progress }, 4, quote { action_req_max_progress as u8 >= actor_progress as u8 }, quote { f"Character cannot have a higher progress than {action_req_max_progress} to perform action {action_type}: got {actor_progress}" }),
//     action_def_def(quote { action_req_status }, 4, quote { (action_req_status as u8 == 0 as u8) | (action_req_status as u8 == actor_progress as u8) }, quote { f"Character can only perform action {action_type} while having status {action_req_status}. Invalid status {actor_status}" }),
//     // action_def_def(quote { action_req_required_energy }, 4, quote { action_req_required_energy <= energy }, quote { f"Character has insufficient energy left to perform action {action_type}: {energy} < {action_req_required_energy}" }),
//     action_def_def(quote { action_req_max_range }, 6, quote { distance as u16 <= (action_req_max_range as u16) * (action_req_max_range as u16) }, quote { f"Character is out of range! Distance: {distance} > {actor_max_range}: {{{actor_x},{actor_y}}} - {{{action_target_x},{action_target_y}}} with {max_range_part}" }),
// ];
// comptime fn get_action_def_requirements_base_index() -> u32 {
//   0 as u32
// }

// pub comptime fn get_action_def_requirements_byte_size() -> u32 {
//   get_action_def_def_register_size(ACTION_DEF_DEF_REQUIREMENTS)
// }

// comptime fn derive_action_def_def_req_struct(s: StructDefinition) {
//   derive_action_def_def_struct(s, ACTION_DEF_DEF_REQUIREMENTS);
// }
// // comptime fn derive_action_def_requirements_struct_new(f: FunctionDefinition) {
// //   derive_action_def_def_struct_new(f, ACTION_DEF_DEF_REQUIREMENTS);
// // }

// #[derive_action_def_def_req_struct]
// pub struct ActionRequirement {
//   pub register: [u8; 32]
// }
// impl ActionRequirement {
//   #[derive_action_def_requirements_struct_new()]
//   pub fn new() -> ActionRequirement {
//     ActionRequirement { register: &[].as_array() }
//   }
// }

// comptime fn derive_action_def_def_req_builder(f: FunctionDefinition) {
//   derive_action_def_def_builder(f, ACTION_DEF_DEF_REQUIREMENTS);
// }
// #[derive_action_def_def_req_builder]
// pub fn build_action_def_requirements() -> ActionRequirement { ActionRequirement::new() }

// pub comptime fn validate_action_requirements(valid_varname: Quoted, register: Quoted) -> Quoted {
//   let mut result = build_over_def_array(ACTION_DEF_DEF_REQUIREMENTS, get_action_def_requirements_base_index(), |bytes, bits, varname, bitsize, args|{
//     let expr = get_def_register_value(register, bytes, bits, bitsize);
//     // let varname = f"action_requirement_{i}_is_valid".quoted_contents();
//     let (checkexpr, msg) = args;
//     let check = if bitsize == 1 { quote { !($varname as bool) | ($checkexpr) } } else { quote { $checkexpr } };
//     let sa = softassert(valid_varname, check, msg);
//     quote {
//       let $varname = $expr;
//       $sa
//     }
//   });
//   result
// }

// pub comptime fn set_action_def_requirements_in_action_def(requirements: Quoted, action_def: Quoted) -> Quoted {
//   let mut result = quote {};
//   let base_index = get_action_def_requirements_base_index();
//   for i in 0..get_action_def_requirements_byte_size() {
//     result = result.append(quote { $action_def[$base_index + $i] = $requirements.register[$i]; });
//   }
//   result
// }
/*
quote {
    let action_req_target_free_space = ((ad[0]as u8 / 2 as u8) == 1 as u8);
    valid &= !(action_req_target_free_space as bool)|(can_move_to(distance, action_target_x, action_target_y, my_obstacles, their_obstacles));
    if!(!(action_req_target_free_space as bool)|(can_move_to(distance, action_target_x, action_target_y, my_obstacles, their_obstacles))) {
        println(f[String("Target space ("), Interpolation("action_target_x", Location { span: Span(Span { start: ByteIndex(1307), end: ByteIndex(1322) }), file: FileId(75) }), String(","), Interpolation("action_target_y", Location { span: Span(Span { start: ByteIndex(1325), end: ByteIndex(1340) }), file: FileId(75) }), String(") cannot be moved to: "), Interpolation("VIEW_DISTANCE", Location { span: Span(Span { start: ByteIndex(1364), end: ByteIndex(1377) }), file: FileId(75) }), String(","), Interpolation("my_obstacles", Location { span: Span(Span { start: ByteIndex(1380), end: ByteIndex(1392) }), file: FileId(75) }), String(","), Interpolation("their_obstacles", Location { span: Span(Span { start: ByteIndex(1395), end: ByteIndex(1410) }), file: FileId(75) })]);
    }
    let action_req_target_is_not_self = ((ad[0]as u8 / 3 as u8) == 1 as u8);
    valid &= !(action_req_target_is_not_self as bool)|((actor_x != action_target_x)|(actor_y != action_target_y));
    if!(!(action_req_target_is_not_self as bool)|((actor_x != action_target_x)|(actor_y != action_target_y))) {
        println(f[String("Target cannot be self ("), Interpolation("action_target_x", Location { span: Span(Span { start: ByteIndex(1585), end: ByteIndex(1600) }), file: FileId(75) }), String(","), Interpolation("action_target_y", Location { span: Span(Span { start: ByteIndex(1603), end: ByteIndex(1618) }), file: FileId(75) }), String(")")]);
    }
    let action_req_status_visible = ((ad[0]as u8 / 0 as u8) == 1 as u8);
    valid &= !(action_req_status_visible as bool)|(actor_is_in_view_range & !actor_is_hidden);
    if!(!(action_req_status_visible as bool)|(actor_is_in_view_range & !actor_is_hidden)) {
        println(f[String("Character must be fully visible for action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(1793), end: ByteIndex(1804) }), file: FileId(75) }), String(": in_view_range: "), Interpolation("actor_is_in_view_range", Location { span: Span(Span { start: ByteIndex(1823), end: ByteIndex(1845) }), file: FileId(75) }), String(" & !hidden "), Interpolation("actor_is_hidden", Location { span: Span(Span { start: ByteIndex(1858), end: ByteIndex(1873) }), file: FileId(75) }), String(" for enemy_advance "), Interpolation("enemy_advance", Location { span: Span(Span { start: ByteIndex(1894), end: ByteIndex(1907) }), file: FileId(75) }), String(" @ "), Interpolation("actor_x", Location { span: Span(Span { start: ByteIndex(1912), end: ByteIndex(1919) }), file: FileId(75) })]);
    }
    let action_req_status_invisible = ((ad[0]as u8 / 1 as u8) == 1 as u8);
    valid &= !(action_req_status_invisible as bool)|(!actor_is_in_view_range|actor_is_hidden);
    if!(!(action_req_status_invisible as bool)|(!actor_is_in_view_range|actor_is_hidden)) {
        println(f[String("Character must not be visible to perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(2099), end: ByteIndex(2110) }), file: FileId(75) }), String(": !in_view_range: "), Interpolation("actor_is_in_view_range", Location { span: Span(Span { start: ByteIndex(2130), end: ByteIndex(2152) }), file: FileId(75) }), String(" || hidden: "), Interpolation("actor_is_hidden", Location { span: Span(Span { start: ByteIndex(2166), end: ByteIndex(2181) }), file: FileId(75) }), String(" for enemy_advance "), Interpolation("enemy_advance", Location { span: Span(Span { start: ByteIndex(2202), end: ByteIndex(2215) }), file: FileId(75) }), String(" @ "), Interpolation("actor_x", Location { span: Span(Span { start: ByteIndex(2220), end: ByteIndex(2227) }), file: FileId(75) })]);
    }
    let action_req_status_hidden = ((ad[0]as u8 / 6 as u8) == 1 as u8);
    valid &= !(action_req_status_hidden as bool)|(actor_is_hidden);
    if!(!(action_req_status_hidden as bool)|(actor_is_hidden)) {
        println(f[String("Character needs to be hidden to perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(2377), end: ByteIndex(2388) }), file: FileId(75) })]);
    }
    let action_req_min_progress = ((ad[1]as u8 / 2 as u8) & 5 as u8);
    valid &= action_req_min_progress as u8 <= actor_progress as u8;
    if!(action_req_min_progress as u8 <= actor_progress as u8) {
        println(f[String("Character needs min progress "), Interpolation("action_req_min_progress", Location { span: Span(Span { start: ByteIndex(2652), end: ByteIndex(2675) }), file: FileId(75) }), String(" to perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(2696), end: ByteIndex(2707) }), file: FileId(75) }), String(", but only has "), Interpolation("actor_progress", Location { span: Span(Span { start: ByteIndex(2724), end: ByteIndex(2738) }), file: FileId(75) })]);
    }
    let action_req_max_progress = ((ad[1]as u8 / 6 as u8) & 5 as u8);
    valid &= action_req_max_progress as u8 >= actor_progress as u8;
    if!(action_req_max_progress as u8 >= actor_progress as u8) {
        println(f[String("Character cannot have a higher progress than "), Interpolation("action_req_max_progress", Location { span: Span(Span { start: ByteIndex(2923), end: ByteIndex(2946) }), file: FileId(75) }), String(" to perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(2967), end: ByteIndex(2978) }), file: FileId(75) }), String(": got "), Interpolation("actor_progress", Location { span: Span(Span { start: ByteIndex(2986), end: ByteIndex(3000) }), file: FileId(75) })]);
    }
    let action_req_status = ((ad[2]as u8 / 2 as u8) & 5 as u8);
    valid &= (action_req_status as u8 == 0 as u8)|(action_req_status as u8 == actor_progress as u8);
    if!((action_req_status as u8 == 0 as u8)|(action_req_status as u8 == actor_progress as u8)) {
        println(f[String("Character can only perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(3203), end: ByteIndex(3214) }), file: FileId(75) }), String(" while having status "), Interpolation("action_req_status", Location { span: Span(Span { start: ByteIndex(3237), end: ByteIndex(3254) }), file: FileId(75) }), String(". Invalid status "), Interpolation("actor_status", Location { span: Span(Span { start: ByteIndex(3273), end: ByteIndex(3285) }), file: FileId(75) })]);
    }
    let action_req_max_range = ((ad[3]as u8 / 2 as u8) & 3 as u8);
    valid &= distance as u16 <= (action_req_max_range as u16) * (action_req_max_range as u16);
    if!(distance as u16 <= (action_req_max_range as u16) * (action_req_max_range as u16)) {
        println(f[String("Character is out of range! Distance: "), Interpolation("distance", Location { span: Span(Span { start: ByteIndex(3724), end: ByteIndex(3732) }), file: FileId(75) }), String(" > "), Interpolation("action_req_max_range", Location { span: Span(Span { start: ByteIndex(3737), end: ByteIndex(3757) }), file: FileId(75) }), String(": {"), Interpolation("actor_x", Location { span: Span(Span { start: ByteIndex(3763), end: ByteIndex(3770) }), file: FileId(75) }), String(","), Interpolation("actor_y", Location { span: Span(Span { start: ByteIndex(3773), end: ByteIndex(3780) }), file: FileId(75) }), String("} - {"), Interpolation("action_target_x", Location { span: Span(Span { start: ByteIndex(3789), end: ByteIndex(3804) }), file: FileId(75) }), String(","), Interpolation("action_target_y", Location { span: Span(Span { start: ByteIndex(3807), end: ByteIndex(3822) }), file: FileId(75) }), String("} with "), Interpolation("action_req_max_range", Location { span: Span(Span { start: ByteIndex(3832), end: ByteIndex(3852) }), file: FileId(75) })]);
    }
    
}
quote {
    let action_req_target_free_space = ((ad[0]as u8 / 2 as u8) == 1 as u8);
    valid &= !(action_req_target_free_space as bool)|(can_move_to(distance, action_target_x, action_target_y, my_obstacles, their_obstacles));
    if!(!(action_req_target_free_space as bool)|(can_move_to(distance, action_target_x, action_target_y, my_obstacles, their_obstacles))) {
        println(f[String("Target space ("), Interpolation("action_target_x", Location { span: Span(Span { start: ByteIndex(1307), end: ByteIndex(1322) }), file: FileId(75) }), String(","), Interpolation("action_target_y", Location { span: Span(Span { start: ByteIndex(1325), end: ByteIndex(1340) }), file: FileId(75) }), String(") cannot be moved to: "), Interpolation("VIEW_DISTANCE", Location { span: Span(Span { start: ByteIndex(1364), end: ByteIndex(1377) }), file: FileId(75) }), String(","), Interpolation("my_obstacles", Location { span: Span(Span { start: ByteIndex(1380), end: ByteIndex(1392) }), file: FileId(75) }), String(","), Interpolation("their_obstacles", Location { span: Span(Span { start: ByteIndex(1395), end: ByteIndex(1410) }), file: FileId(75) })]);
    }
    let action_req_target_is_not_self = ((ad[0]as u8 / 3 as u8) == 1 as u8);
    valid &= !(action_req_target_is_not_self as bool)|((actor_x != action_target_x)|(actor_y != action_target_y));
    if!(!(action_req_target_is_not_self as bool)|((actor_x != action_target_x)|(actor_y != action_target_y))) {
        println(f[String("Target cannot be self ("), Interpolation("action_target_x", Location { span: Span(Span { start: ByteIndex(1585), end: ByteIndex(1600) }), file: FileId(75) }), String(","), Interpolation("action_target_y", Location { span: Span(Span { start: ByteIndex(1603), end: ByteIndex(1618) }), file: FileId(75) }), String(")")]);
    }
    let action_req_status_visible = ((ad[0]as u8 / 0 as u8) == 1 as u8);
    valid &= !(action_req_status_visible as bool)|(actor_is_in_view_range & !actor_is_hidden);
    if!(!(action_req_status_visible as bool)|(actor_is_in_view_range & !actor_is_hidden)) {
        println(f[String("Character must be fully visible for action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(1793), end: ByteIndex(1804) }), file: FileId(75) }), String(": in_view_range: "), Interpolation("actor_is_in_view_range", Location { span: Span(Span { start: ByteIndex(1823), end: ByteIndex(1845) }), file: FileId(75) }), String(" & !hidden "), Interpolation("actor_is_hidden", Location { span: Span(Span { start: ByteIndex(1858), end: ByteIndex(1873) }), file: FileId(75) }), String(" for enemy_advance "), Interpolation("enemy_advance", Location { span: Span(Span { start: ByteIndex(1894), end: ByteIndex(1907) }), file: FileId(75) }), String(" @ "), Interpolation("actor_x", Location { span: Span(Span { start: ByteIndex(1912), end: ByteIndex(1919) }), file: FileId(75) })]);
    }
    let action_req_status_invisible = ((ad[0]as u8 / 1 as u8) == 1 as u8);
    valid &= !(action_req_status_invisible as bool)|(!actor_is_in_view_range|actor_is_hidden);
    if!(!(action_req_status_invisible as bool)|(!actor_is_in_view_range|actor_is_hidden)) {
        println(f[String("Character must not be visible to perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(2099), end: ByteIndex(2110) }), file: FileId(75) }), String(": !in_view_range: "), Interpolation("actor_is_in_view_range", Location { span: Span(Span { start: ByteIndex(2130), end: ByteIndex(2152) }), file: FileId(75) }), String(" || hidden: "), Interpolation("actor_is_hidden", Location { span: Span(Span { start: ByteIndex(2166), end: ByteIndex(2181) }), file: FileId(75) }), String(" for enemy_advance "), Interpolation("enemy_advance", Location { span: Span(Span { start: ByteIndex(2202), end: ByteIndex(2215) }), file: FileId(75) }), String(" @ "), Interpolation("actor_x", Location { span: Span(Span { start: ByteIndex(2220), end: ByteIndex(2227) }), file: FileId(75) })]);
    }
    let action_req_status_hidden = ((ad[0]as u8 / 6 as u8) == 1 as u8);
    valid &= !(action_req_status_hidden as bool)|(actor_is_hidden);
    if!(!(action_req_status_hidden as bool)|(actor_is_hidden)) {
        println(f[String("Character needs to be hidden to perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(2377), end: ByteIndex(2388) }), file: FileId(75) })]);
    }
    let action_req_min_progress = ((ad[1]as u8 / 2 as u8) & 5 as u8);
    valid &= action_req_min_progress as u8 <= actor_progress as u8;
    if!(action_req_min_progress as u8 <= actor_progress as u8) {
        println(f[String("Character needs min progress "), Interpolation("action_req_min_progress", Location { span: Span(Span { start: ByteIndex(2652), end: ByteIndex(2675) }), file: FileId(75) }), String(" to perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(2696), end: ByteIndex(2707) }), file: FileId(75) }), String(", but only has "), Interpolation("actor_progress", Location { span: Span(Span { start: ByteIndex(2724), end: ByteIndex(2738) }), file: FileId(75) })]);
    }
    let action_req_max_progress = ((ad[1]as u8 / 6 as u8) & 5 as u8);
    valid &= action_req_max_progress as u8 >= actor_progress as u8;
    if!(action_req_max_progress as u8 >= actor_progress as u8) {
        println(f[String("Character cannot have a higher progress than "), Interpolation("action_req_max_progress", Location { span: Span(Span { start: ByteIndex(2923), end: ByteIndex(2946) }), file: FileId(75) }), String(" to perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(2967), end: ByteIndex(2978) }), file: FileId(75) }), String(": got "), Interpolation("actor_progress", Location { span: Span(Span { start: ByteIndex(2986), end: ByteIndex(3000) }), file: FileId(75) })]);
    }
    let action_req_status = ((ad[2]as u8 / 2 as u8) & 5 as u8);
    valid &= (action_req_status as u8 == 0 as u8)|(action_req_status as u8 == actor_progress as u8);
    if!((action_req_status as u8 == 0 as u8)|(action_req_status as u8 == actor_progress as u8)) {
        println(f[String("Character can only perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(3203), end: ByteIndex(3214) }), file: FileId(75) }), String(" while having status "), Interpolation("action_req_status", Location { span: Span(Span { start: ByteIndex(3237), end: ByteIndex(3254) }), file: FileId(75) }), String(". Invalid status "), Interpolation("actor_status", Location { span: Span(Span { start: ByteIndex(3273), end: ByteIndex(3285) }), file: FileId(75) })]);
    }
    let action_req_max_range = ((ad[3]as u8 / 2 as u8) & 3 as u8);
    valid &= distance as u16 <= (action_req_max_range as u16) * (action_req_max_range as u16);
    if!(distance as u16 <= (action_req_max_range as u16) * (action_req_max_range as u16)) {
        println(f[String("Character is out of range! Distance: "), Interpolation("distance", Location { span: Span(Span { start: ByteIndex(3724), end: ByteIndex(3732) }), file: FileId(75) }), String(" > "), Interpolation("action_req_max_range", Location { span: Span(Span { start: ByteIndex(3737), end: ByteIndex(3757) }), file: FileId(75) }), String(": {"), Interpolation("actor_x", Location { span: Span(Span { start: ByteIndex(3763), end: ByteIndex(3770) }), file: FileId(75) }), String(","), Interpolation("actor_y", Location { span: Span(Span { start: ByteIndex(3773), end: ByteIndex(3780) }), file: FileId(75) }), String("} - {"), Interpolation("action_target_x", Location { span: Span(Span { start: ByteIndex(3789), end: ByteIndex(3804) }), file: FileId(75) }), String(","), Interpolation("action_target_y", Location { span: Span(Span { start: ByteIndex(3807), end: ByteIndex(3822) }), file: FileId(75) }), String("} with "), Interpolation("action_req_max_range", Location { span: Span(Span { start: ByteIndex(3832), end: ByteIndex(3852) }), file: FileId(75) })]);
    }
    
}
quote {
    let action_req_target_free_space = ((ad[0]as u8 / 2 as u8) == 1 as u8);
    valid &= !(action_req_target_free_space as bool)|(can_move_to(distance, action_target_x, action_target_y, my_obstacles, their_obstacles));
    if!(!(action_req_target_free_space as bool)|(can_move_to(distance, action_target_x, action_target_y, my_obstacles, their_obstacles))) {
        println(f[String("Target space ("), Interpolation("action_target_x", Location { span: Span(Span { start: ByteIndex(1307), end: ByteIndex(1322) }), file: FileId(75) }), String(","), Interpolation("action_target_y", Location { span: Span(Span { start: ByteIndex(1325), end: ByteIndex(1340) }), file: FileId(75) }), String(") cannot be moved to: "), Interpolation("VIEW_DISTANCE", Location { span: Span(Span { start: ByteIndex(1364), end: ByteIndex(1377) }), file: FileId(75) }), String(","), Interpolation("my_obstacles", Location { span: Span(Span { start: ByteIndex(1380), end: ByteIndex(1392) }), file: FileId(75) }), String(","), Interpolation("their_obstacles", Location { span: Span(Span { start: ByteIndex(1395), end: ByteIndex(1410) }), file: FileId(75) })]);
    }
    let action_req_target_is_not_self = ((ad[0]as u8 / 3 as u8) == 1 as u8);
    valid &= !(action_req_target_is_not_self as bool)|((actor_x != action_target_x)|(actor_y != action_target_y));
    if!(!(action_req_target_is_not_self as bool)|((actor_x != action_target_x)|(actor_y != action_target_y))) {
        println(f[String("Target cannot be self ("), Interpolation("action_target_x", Location { span: Span(Span { start: ByteIndex(1585), end: ByteIndex(1600) }), file: FileId(75) }), String(","), Interpolation("action_target_y", Location { span: Span(Span { start: ByteIndex(1603), end: ByteIndex(1618) }), file: FileId(75) }), String(")")]);
    }
    let action_req_status_visible = ((ad[0]as u8 / 0 as u8) == 1 as u8);
    valid &= !(action_req_status_visible as bool)|(actor_is_in_view_range & !actor_is_hidden);
    if!(!(action_req_status_visible as bool)|(actor_is_in_view_range & !actor_is_hidden)) {
        println(f[String("Character must be fully visible for action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(1793), end: ByteIndex(1804) }), file: FileId(75) }), String(": in_view_range: "), Interpolation("actor_is_in_view_range", Location { span: Span(Span { start: ByteIndex(1823), end: ByteIndex(1845) }), file: FileId(75) }), String(" & !hidden "), Interpolation("actor_is_hidden", Location { span: Span(Span { start: ByteIndex(1858), end: ByteIndex(1873) }), file: FileId(75) }), String(" for enemy_advance "), Interpolation("enemy_advance", Location { span: Span(Span { start: ByteIndex(1894), end: ByteIndex(1907) }), file: FileId(75) }), String(" @ "), Interpolation("actor_x", Location { span: Span(Span { start: ByteIndex(1912), end: ByteIndex(1919) }), file: FileId(75) })]);
    }
    let action_req_status_invisible = ((ad[0]as u8 / 1 as u8) == 1 as u8);
    valid &= !(action_req_status_invisible as bool)|(!actor_is_in_view_range|actor_is_hidden);
    if!(!(action_req_status_invisible as bool)|(!actor_is_in_view_range|actor_is_hidden)) {
        println(f[String("Character must not be visible to perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(2099), end: ByteIndex(2110) }), file: FileId(75) }), String(": !in_view_range: "), Interpolation("actor_is_in_view_range", Location { span: Span(Span { start: ByteIndex(2130), end: ByteIndex(2152) }), file: FileId(75) }), String(" || hidden: "), Interpolation("actor_is_hidden", Location { span: Span(Span { start: ByteIndex(2166), end: ByteIndex(2181) }), file: FileId(75) }), String(" for enemy_advance "), Interpolation("enemy_advance", Location { span: Span(Span { start: ByteIndex(2202), end: ByteIndex(2215) }), file: FileId(75) }), String(" @ "), Interpolation("actor_x", Location { span: Span(Span { start: ByteIndex(2220), end: ByteIndex(2227) }), file: FileId(75) })]);
    }
    let action_req_status_hidden = ((ad[0]as u8 / 6 as u8) == 1 as u8);
    valid &= !(action_req_status_hidden as bool)|(actor_is_hidden);
    if!(!(action_req_status_hidden as bool)|(actor_is_hidden)) {
        println(f[String("Character needs to be hidden to perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(2377), end: ByteIndex(2388) }), file: FileId(75) })]);
    }
    let action_req_min_progress = ((ad[1]as u8 / 2 as u8) & 5 as u8);
    valid &= action_req_min_progress as u8 <= actor_progress as u8;
    if!(action_req_min_progress as u8 <= actor_progress as u8) {
        println(f[String("Character needs min progress "), Interpolation("action_req_min_progress", Location { span: Span(Span { start: ByteIndex(2652), end: ByteIndex(2675) }), file: FileId(75) }), String(" to perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(2696), end: ByteIndex(2707) }), file: FileId(75) }), String(", but only has "), Interpolation("actor_progress", Location { span: Span(Span { start: ByteIndex(2724), end: ByteIndex(2738) }), file: FileId(75) })]);
    }
    let action_req_max_progress = ((ad[1]as u8 / 6 as u8) & 5 as u8);
    valid &= action_req_max_progress as u8 >= actor_progress as u8;
    if!(action_req_max_progress as u8 >= actor_progress as u8) {
        println(f[String("Character cannot have a higher progress than "), Interpolation("action_req_max_progress", Location { span: Span(Span { start: ByteIndex(2923), end: ByteIndex(2946) }), file: FileId(75) }), String(" to perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(2967), end: ByteIndex(2978) }), file: FileId(75) }), String(": got "), Interpolation("actor_progress", Location { span: Span(Span { start: ByteIndex(2986), end: ByteIndex(3000) }), file: FileId(75) })]);
    }
    let action_req_status = ((ad[2]as u8 / 2 as u8) & 5 as u8);
    valid &= (action_req_status as u8 == 0 as u8)|(action_req_status as u8 == actor_progress as u8);
    if!((action_req_status as u8 == 0 as u8)|(action_req_status as u8 == actor_progress as u8)) {
        println(f[String("Character can only perform action "), Interpolation("action_type", Location { span: Span(Span { start: ByteIndex(3203), end: ByteIndex(3214) }), file: FileId(75) }), String(" while having status "), Interpolation("action_req_status", Location { span: Span(Span { start: ByteIndex(3237), end: ByteIndex(3254) }), file: FileId(75) }), String(". Invalid status "), Interpolation("actor_status", Location { span: Span(Span { start: ByteIndex(3273), end: ByteIndex(3285) }), file: FileId(75) })]);
    }
    let action_req_max_range = ((ad[3]as u8 / 2 as u8) & 3 as u8);
    valid &= distance as u16 <= (action_req_max_range as u16) * (action_req_max_range as u16);
    if!(distance as u16 <= (action_req_max_range as u16) * (action_req_max_range as u16)) {
        println(f[String("Character is out of range! Distance: "), Interpolation("distance", Location { span: Span(Span { start: ByteIndex(3724), end: ByteIndex(3732) }), file: FileId(75) }), String(" > "), Interpolation("action_req_max_range", Location { span: Span(Span { start: ByteIndex(3737), end: ByteIndex(3757) }), file: FileId(75) }), String(": {"), Interpolation("actor_x", Location { span: Span(Span { start: ByteIndex(3763), end: ByteIndex(3770) }), file: FileId(75) }), String(","), Interpolation("actor_y", Location { span: Span(Span { start: ByteIndex(3773), end: ByteIndex(3780) }), file: FileId(75) }), String("} - {"), Interpolation("action_target_x", Location { span: Span(Span { start: ByteIndex(3789), end: ByteIndex(3804) }), file: FileId(75) }), String(","), Interpolation("action_target_y", Location { span: Span(Span { start: ByteIndex(3807), end: ByteIndex(3822) }), file: FileId(75) }), String("} with "), Interpolation("action_req_max_range", Location { span: Span(Span { start: ByteIndex(3832), end: ByteIndex(3852) }), file: FileId(75) })]);
    }
    
}*/