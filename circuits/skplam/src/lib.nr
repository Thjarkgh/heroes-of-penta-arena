mod actionDefinition;
mod actionRequirements;
mod actionPreCalcEffect;
mod actionResultEffect;
mod actionResultEvent;

pub use actionRequirements::{FrontendActionDefRequirements, derive_frontend_action_def_requirements_struct_builder};
pub use actionPreCalcEffect::{FrontendActionDefPreCalcEffects, derive_frontend_action_def_pre_calc_effects_struct_builder};
pub use actionResultEffect::{FrontendActionDefResultEffects, derive_frontend_action_def_result_effects_struct_builder};
pub use actionResultEvent::{FrontendActionDefResultEvent, derive_frontend_action_def_result_event_struct_builder};
pub use actionDefinition::{derive_frontend_action_def_struct_builder};

pub use actionRequirements::{set_action_def_requirements_in_action_def};
pub use actionPreCalcEffect::{set_action_def_pre_calc_effects_in_action_def};
pub use actionResultEffect::{set_action_def_result_effects_in_action_def};
pub use actionResultEvent::{set_action_def_result_event_in_action_def};

pub use actionRequirements::{ActionRequirement, build_action_def_requirements, validate_action_requirements};
pub use actionPreCalcEffect::{ActionPreCalcEffect, build_action_def_pre_calc_effect, apply_action_pre_calc_effects};
pub use actionResultEffect::{ActionResultEffect, build_action_def_result_effects, apply_action_result_effects};
pub use actionResultEvent::{ActionResultEvent, build_action_def_result_event, build_result_event};

pub use actionDefinition::{SerializedRosterActionDefinitions, SerializedCharacterActionDefinitions, SerializedCharacterActionDefinition};

pub type ActionDefinition = [u8; 32];
pub global ACTION_RESULT_EVENT_COUNT: u32 = 4;



#[export]
pub fn build_action_definition(
  requirements: ActionRequirement,
  pre_calc_effects: ActionPreCalcEffect,
  result_effects: ActionResultEffect,
  result_events: [ActionResultEvent; ACTION_RESULT_EVENT_COUNT]
) -> pub ActionDefinition {
  let mut result = [0 as u8; 32];
  set_action_def_requirements_in_action_def!(quote { requirements }, quote { result });
  set_action_def_pre_calc_effects_in_action_def!(quote { pre_calc_effects },  quote { result });
  set_action_def_result_effects_in_action_def!(quote { result_effects }, quote { result });
  set_action_def_result_event_in_action_def!(quote { result_events }, ACTION_RESULT_EVENT_COUNT, quote { result });
  result
}

#[test]
fn test_build_action() {
  let req = build_action_def_requirements(0, 0, 0, 0, 0, 0, 15, 0, 0);
  let pce = build_action_def_pre_calc_effect(0, 0, 0, 1);
  let res = build_action_def_result_effects(0, 0, 1, 0, 0, 0);
  let rev = [
    build_action_def_result_event(0, 0, 2, 0, 0, 0),
    build_action_def_result_event(0, 0, 2, 0, 0, 0),
    build_action_def_result_event(0, 0, 2, 0, 0, 0),
    build_action_def_result_event(0, 0, 2, 0, 0, 0)
  ];
  let ad = build_action_definition(req, pce, res, rev);

  let should = [0, 0, 240, 0, 0, 32, 0, 1, 0, 32, 0, 0, 0, 0, 32, 0, 0, 0, 0, 32, 0, 0, 0, 0, 32, 0, 0, 0, 0, 0, 0, 0];
  // assert(should == ad, f"{should} != {ad}");
  for i in 0..should.len() {
    let adi = ad[i];
    let shi = should[i];
    assert(ad[i] == should[i], f"{i}: {adi} != {shi}");
  }
}

pub struct FrontendActionDefinition {
  requirements: FrontendActionDefRequirements,
  pre_calc_effects: FrontendActionDefPreCalcEffects,
  result_effects: FrontendActionDefResultEffects,
  result_events: [FrontendActionDefResultEvent; 4]
}

// NOTE: For now, events count is hardcoded @ 4 => if we at some point have more => add more functions
#[export]
pub fn parse_action_def_requirements_for_frontend_4(action_def: ActionDefinition) -> pub FrontendActionDefinition {
  let requirements = derive_frontend_action_def_requirements_struct_builder!(quote { action_def });
  let pre_calc_effects = derive_frontend_action_def_pre_calc_effects_struct_builder!(quote { action_def });
  let result_effects = derive_frontend_action_def_result_effects_struct_builder!(quote {action_def});

  let result_events = [
    derive_frontend_action_def_result_event_struct_builder!(quote {action_def}, 0 as u32),
    derive_frontend_action_def_result_event_struct_builder!(quote {action_def}, 1 as u32),
    derive_frontend_action_def_result_event_struct_builder!(quote {action_def}, 2 as u32),
    derive_frontend_action_def_result_event_struct_builder!(quote {action_def}, 3 as u32)
  ];

  FrontendActionDefinition {
    requirements: requirements,
    pre_calc_effects: pre_calc_effects,
    result_effects: result_effects,
    result_events: result_events
  }
}


#[test]
fn test_build_frontend_action() {
  let req_free_space = 1 as u8;
  let req_not_self = 0 as u8;
  let req_visible = 1 as u8;
  let req_invisible = 0 as u8;
  let req_hidden = 0 as u8;
  let req_min_progress = 5 as u8;
  let req_max_progress = 11 as u8;
  let req_status = 6 as u8;
  let req_range = 9 as u8;
  let req = build_action_def_requirements(
    req_free_space,
    req_not_self,
    req_visible,
    req_invisible,
    req_hidden,
    req_min_progress,
    req_max_progress,
    req_status,
    req_range
  );
  let pce_action = 3 as u8;
  let pce_continuous = 1 as u8;
  let pce_int = 1 as u8;
  let pce_retarget = 0 as u8;
  let pce = build_action_def_pre_calc_effect(
    pce_action,
    pce_continuous,
    pce_int,
    pce_retarget
  );
  let ref_energy = 5 as u8;
  let ref_prog_mul = 2 as u8;
  let ref_prog_add = 0 as u8;
  let ref_move_target = 0 as u8;
  let ref_hide = 0 as u8;
  let ref_reveal = 1 as u8;
  let res = build_action_def_result_effects(
    ref_energy,
    ref_prog_add,
    ref_prog_mul,
    ref_move_target,
    ref_hide,
    ref_reveal
  );
  let rev = [
    build_action_def_result_event(0, 4, 0, 6, 9, 1),
    build_action_def_result_event(1, 3, 1, 7, 8, 2),
    build_action_def_result_event(2, 2, 2, 8, 7, 3),
    build_action_def_result_event(3, 1, 0, 9, 6, 4)
  ];
  let ad = build_action_definition(req, pce, res, rev);

  let fead = parse_action_def_requirements_for_frontend_4(ad);
  let requirements = fead.requirements;
  let pre_calc_effects = fead.pre_calc_effects;
  let result_effects = fead.result_effects;
  let result_events = fead.result_events;

//   let req_manual = ActionRequirement { register: [
//     ((((((req_free_space as u8) * 1) + ((req_not_self as u8) * 2)) + ((req_visible as u8) * 4)) + ((req_invisible as u8) * 8)) + ((req_hidden as u8) * 16)),
//     (((((req_min_progress & 15)) * 1)) + ((((req_max_progress & 15)) * 16))),
//     ((((req_status & 15)) * 1)),
//     ((((req_range & 63)) * 1))] };

// let x = 0x0906b50500;
//     assert((0x0906b50500/512) as u1 == 0, f"{x} / 512 = {y}");

// let mut action_def = 0;
// println(req_manual.register);
//     action_def += req_manual.register[0]as Field * 256;
//     println(action_def);
//     action_def += req_manual.register[1]as Field * 65536;
//     println(action_def);
//     action_def += req_manual.register[2]as Field * 16777216;
//     println(action_def);
//     action_def += req_manual.register[3]as Field * 4294967296;
//     println(action_def);

//     let frontendManual = FrontendActionDefRequirements {
//       action_req_target_free_space: ((action_def / 256)as u1) == 1,
//       action_req_target_is_not_self: ((action_def / 512)as u1) == 1, action_req_status_visible: ((action_def / 1024)as u1) == 1, action_req_status_invisible: ((action_def / 2048)as u1) == 1, action_req_status_hidden: ((action_def / 4096)as u1) == 1, action_req_min_progress: ((action_def / 65536)as u8) & 15 as u8, action_req_max_progress: ((action_def / 1048576)as u8) & 15 as u8, action_req_status: ((action_def / 16777216)as u8) & 15 as u8, action_req_max_range: ((action_def / 4294967296)as u8) & 63 as u8
//     };

  // assert(frontendManual.action_req_target_free_space == (1==req_free_space), f"free space fail: {req_free_space} != {requirements}");
  // assert(frontendManual.action_req_target_is_not_self == (1==req_not_self), f"not self fail: {req_not_self} != {requirements}");
  // assert(frontendManual.action_req_status_visible == (1==req_visible), f"visible fail: {req_visible} != {requirements}");
  // assert(frontendManual.action_req_status_invisible == (1==req_invisible), f"invis fail: {req_invisible} != {requirements}");
  // assert(frontendManual.action_req_status_hidden == (1==req_hidden), f"hidden fail: {req_hidden} != {requirements}");
  // assert(frontendManual.action_req_status == req_status, f"status fail: {req_status} != {requirements}");
  // assert(frontendManual.action_req_min_progress == req_min_progress, f"min progress fail: {req_min_progress} != {requirements}");
  // assert(frontendManual.action_req_max_progress == req_max_progress, f"max progress fail: {req_max_progress} != {requirements}");
  // assert(frontendManual.action_req_max_range == req_range, f"range fail: {req_range} != {requirements}");

  assert(requirements.action_req_target_free_space == (1==req_free_space), f"free space fail: {req_free_space} != {requirements}");
  assert(requirements.action_req_target_is_not_self == (1==req_not_self), f"not self fail: {req_not_self} != {requirements}");
  assert(requirements.action_req_status_visible == (1==req_visible), f"visible fail: {req_visible} != {requirements}");
  assert(requirements.action_req_status_invisible == (1==req_invisible), f"invis fail: {req_invisible} != {requirements}");
  assert(requirements.action_req_status_hidden == (1==req_hidden), f"hidden fail: {req_hidden} != {requirements}");
  assert(requirements.action_req_status == req_status, f"status fail: {req_status} != {requirements}");
  assert(requirements.action_req_min_progress == req_min_progress, f"min progress fail: {req_min_progress} != {requirements}");
  assert(requirements.action_req_max_progress == req_max_progress, f"max progress fail: {req_max_progress} != {requirements}");
  assert(requirements.action_req_max_range == req_range, f"range fail: {req_range} != {requirements}");
}