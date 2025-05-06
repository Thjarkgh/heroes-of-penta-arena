// use crate::actionResultEvent::ActionResultEventDefinition;
// use crate::actionResultEffect::ActionResultEffects;

// // pub global ACTION_RESULT_EVENT_SEEN: u8 = 0;
// // pub global ACTION_RESULT_EVENT_UNSEEN: u8 = 1;
// // pub global ACTION_RESULT_EVENT_CREATE: u8 = 2;
// // pub global ACTION_RESULT_EVENT_SELF: u8 = 3;
// // pub type TUPLE_INDEX


// pub trait ResolvedAction {
//     fn get_action_req_target_free_space(self) -> bool;
//     fn get_action_req_target_is_not_self(self) -> bool;
//     fn get_action_req_status_visible(self) -> bool;
//     fn get_action_req_status_invisible(self) -> bool;
//     fn get_action_req_status_hidden(self) -> bool;
//     fn get_action_req_max_range(self) -> u8;
//     fn get_action_req_min_status(self) -> u8;
//     fn get_action_req_max_status(self) -> u8;
//     fn get_action_req_energy(self) -> u8;
//     fn get_action_req_previous_action(self) -> u8;
//     // fn get_action_unseen_event_is_internal(self) -> bool;
//     fn get_action_result_event_global(self, seen: bool) -> ActionResultEventDefinition;
//     fn get_action_result_event_world(self) -> ActionResultEventDefinition;
//     fn get_action_result_event_party(self) -> ActionResultEventDefinition;
//     // fn get_action_result_event_seen_type(self) -> u8;
//     // fn get_action_result_event_seen_subtype(self) -> u8;
//     // fn get_action_result_event_seen_value_status_multiplier(self) -> u8;
//     // fn get_action_result_event_seen_value_fixed_addition(self) -> u8;
//     // fn get_action_result_event_seen_coord_idx(self) -> u8;
//     // fn get_action_result_event_seen_radius(self) -> u8;
//     // fn get_action_result_event_not_seen_type(self) -> u8;
//     // fn get_action_result_event_not_seen_subtype(self) -> u8;
//     // fn get_action_result_event_not_seen_value_status_multiplier(self) -> u8;
//     // fn get_action_result_event_not_seen_value_fixed_addition(self) -> u8;
//     // fn get_action_result_event_not_seen_coord_idx(self) -> u8;
//     // fn get_action_result_event_not_seen_radius(self) -> u8;
//     fn get_action_result_status_multiplier(self) -> u8;
//     fn get_action_result_status_fixed_addition(self) -> u8;
//     // fn get_action_result_effect_sets_status_hidden(self) -> bool;
//     // fn get_action_result_effect_removes_status_hidden(self) -> bool;
//     // fn get_action_move_to_target(self) -> u1;
//     // fn get_action_is_continuous(self) -> bool;
//     fn get_action_result_effects(self) -> ActionResultEffects;

//     fn get_action_type(self) -> u8;
//     fn get_action_target_x(self) -> u8;
//     fn get_action_target_y(self) -> u8;
// }