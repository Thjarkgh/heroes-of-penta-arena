use skplam::{ActionRequirement, build_action_def_requirements};
use skplam::{ActionPreCalcEffect, build_action_def_pre_calc_effect};
use skplam::{build_action_def_result_effects};
use skplam::{ActionResultEvent, build_action_def_result_event};
use skplam::{ActionDefinition, build_action_definition};
// use skplam::{set_action_def_requirements_in_action_def, set_action_def_pre_calc_effects_in_action_def, set_action_def_result_effects_in_action_def, set_action_def_result_event_in_action_def};

// pub global self.action_result_coordinates_idx_self: u8 = 0; // u2
// pub global self.action_result_coordinates_idx_target: u8 = 1; // u2
// pub global self.action_result_coordinates_idx_invisible: u8 = 2; // u2
// pub type ActionDefinition = [u8; 32];
// pub global ACTION_RESULT_EVENT_COUNT: u32 = 4;
// pub fn build_action_definition(
//   requirements: ActionRequirement,
//   pre_calc_effects: ActionPreCalcEffect,
//   result_effects: ActionResultEffect,
//   result_events: [ActionResultEvent; ACTION_RESULT_EVENT_COUNT]
// ) -> ActionDefinition {
//   let mut result = [0 as u8; 32];
//   set_action_def_requirements_in_action_def!(quote { requirements }, quote { result });
//   set_action_def_pre_calc_effects_in_action_def!(quote { pre_calc_effects },  quote { result });
//   set_action_def_result_effects_in_action_def!(quote { result_effects }, quote { result });
//   set_action_def_result_event_in_action_def!(quote { result_events }, ACTION_RESULT_EVENT_COUNT, quote { result });
//   result
// }
// global YES: u8 = 1;
//global NO: u8 = 0;
// comptime fn 0 -> u1 { 0 }
// comptime fn 1 -> u1 { 1 }

pub struct ActionDefinitionBuilder {
  continues_no_action: u8,
  min_progress: u8,
  max_progress: u8,
  action_result_coordinates_idx_self: u8,
  action_result_coordinates_idx_target: u8,
  action_result_coordinates_idx_invisible: u8,
  no_event_event_type: u8,
  receive_attack_event_type: u8,
  see_cast_event_type: u8,
  see_draw_event_type: u8,
  see_move_event_type: u8,
  see_ritual_event_type: u8,
  see_search_event_type: u8,
  disarm_trap_event_type: u8,
  add_obstacle_event_type: u8,
  win_event_type: u8
}
pub impl ActionDefinitionBuilder {
  pub fn new(
    continues_no_action: u8,
    min_progress: u8,
    max_progress: u8,
    action_result_coordinates_idx_self: u8,
    action_result_coordinates_idx_target: u8,
    action_result_coordinates_idx_invisible: u8,
    no_event_event_type: u8,
    receive_attack_event_type: u8,
    see_cast_event_type: u8,
    see_draw_event_type: u8,
    see_move_event_type: u8,
    see_ritual_event_type: u8,
    see_search_event_type: u8,
    disarm_trap_event_type: u8,
    add_obstacle_event_type: u8,
    win_event_type: u8
  ) -> ActionDefinitionBuilder {
    ActionDefinitionBuilder {
      continues_no_action: continues_no_action,
      min_progress: min_progress,
      max_progress: max_progress,
      action_result_coordinates_idx_self: action_result_coordinates_idx_self,
      action_result_coordinates_idx_target: action_result_coordinates_idx_target,
      action_result_coordinates_idx_invisible: action_result_coordinates_idx_invisible,
      no_event_event_type: no_event_event_type,
      receive_attack_event_type: receive_attack_event_type,
      see_cast_event_type: see_cast_event_type,
      see_draw_event_type: see_draw_event_type,
      see_move_event_type: see_move_event_type,
      see_ritual_event_type: see_ritual_event_type,
      see_search_event_type: see_search_event_type,
      disarm_trap_event_type: disarm_trap_event_type,
      add_obstacle_event_type: add_obstacle_event_type,
      win_event_type: win_event_type

    }
  }

  pub fn build_action_def_requirements_none(self) -> ActionRequirement {
    build_action_def_requirements(
      0,
      0,
      0,
      0,
      0,
      self.min_progress,
      self.max_progress,
      0 as u8,
      255 as u8)
  }
  pub fn build_action_def_pre_calc_effects_idle(self) -> ActionPreCalcEffect {
    build_action_def_pre_calc_effect(
      self.continues_no_action,
      0,
      0,
      0)
  }
  // comptime fn no_requirements() -> CtString {
  //     build_action_requirements_def(
  //         0,
  //         0, 
  //         0,
  //         0,
  //         0,
  //         0,
  //         0,
  //         255 as u8,
  //         self.min_progress,
  //         self.max_progress,
  //         0 as u8,
  //         0)
  // }
  pub fn build_action_def_result_event_none(self) -> ActionResultEvent {
    build_action_def_result_event(
      0,
      0,
      self.action_result_coordinates_idx_invisible,
      self.no_event_event_type,
      self.no_event_event_type,
      0 as u8
    )
  }
  // comptime fn self.no_event_event_type() -> CtString {
  //     build_action_event_def(self.no_event_event_type, self.no_event_event_type, 0 as u8, 0 as u8, self.action_result_coordinates_idx_invisible, 0 as u8)
  // }
  pub fn build_wait_action_def(self) -> ActionDefinition {
    let wa = build_action_definition(
      self.build_action_def_requirements_none(),
      self.build_action_def_pre_calc_effects_idle(),
      build_action_def_result_effects(
        0 as u8,
        0 as u8,
        1 as u8,
        0,
        0,
        0),
      [
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none()
      ]);
      // println(f"wait action: {wa}");
      wa
  }
  // pub comptime fn build_wait_action_def() -> CtString {
  //     build_action_def(
  //         no_requirements(),
  //         self.no_event_event_type(),
  //         self.no_event_event_type(),
  //         1 as u8,
  //         0 as u8,
  //         self.action_result_coordinates_idx_self,
  //         0,
  //         self.continues_no_action
  //     )
  // }
  // pub global WAIT_ACTION: ActionDefinition = comptime { let x = build_wait_action_def(); f"[{x}]".quoted_contents() };
  pub fn build_sneak_action(self, energy: u8) -> ActionDefinition {
    build_action_definition(
      build_action_def_requirements(
        1,
        0,
        0,
        1,
        0,
        self.min_progress,
        self.max_progress,
        0 as u8,
        1 as u8),
      build_action_def_pre_calc_effect(
        0,
        0,
        1,
        1),
      build_action_def_result_effects(
        energy,
        0 as u8,
        0 as u8,
        self.action_result_coordinates_idx_target,
        1,
        0),
      [
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none()
      ])
  }
  // pub comptime fn build_sneak_action(energy: u8) -> CtString { build_action_def(
  //     build_action_requirements_def(
  //         1,
  //         0,
  //         0,
  //         1,
  //         0,
  //         1,
  //         0,
  //         1 as u8,
  //         self.min_progress,
  //         self.max_progress,
  //         energy,
  //         0),
  //     self.no_event_event_type(), // TODO: not sure if on-seen we should not send a move event instead - that way one could sneak and stay hidden, but not sneak while visible
  //     self.no_event_event_type(),
  //     0 as u8,
  //     0 as u8,
  //     self.action_result_coordinates_idx_target,
  //     0,
  //     self.continues_no_action)
  // }
  pub fn build_move_action(self, energy: u8) -> ActionDefinition {
    build_action_definition(
      build_action_def_requirements(
        1,
        1,
        0,
        0,
        0,
        self.min_progress,
        self.max_progress,
        0,
        1),
      build_action_def_pre_calc_effect(
        0,
        0,
        1,
        1),
      build_action_def_result_effects(
        energy,
        0,
        0,
        self.action_result_coordinates_idx_target,
        0,
        1),
      [
        self.build_action_def_result_event_none(),
        build_action_def_result_event(
          0,
          0,
          self.action_result_coordinates_idx_target,
          self.see_move_event_type,
          0,
          0),
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none()
      ])
  }
  // pub comptime fn build_move_action(energy: u8) -> CtString { build_action_def(
  //     build_action_requirements_def(
  //         1,
  //         1,
  //         0,
  //         0,
  //         0,
  //         0,
  //         1,
  //         1 as u8,
  //         self.min_progress,
  //         self.max_progress,
  //         energy,
  //         0),
  //     build_action_event_def(self.see_move_event_type, 0, 0 as u8, 0 as u8, self.action_result_coordinates_idx_target, 0 as u8),
  //     self.no_event_event_type(),
  //     0 as u8,
  //     0 as u8,
  //     self.action_result_coordinates_idx_target,
  //     0,
  //     self.continues_no_action)
  // }
  pub fn build_cast_action(self, this_action_id: u8, energy: u8, class: u8, range: u8) -> ActionDefinition {
    build_action_definition(
      build_action_def_requirements(
        0,
        0,
        0,
        0,
        0,
        self.min_progress,
        self.max_progress,
        0,
        range),
      build_action_def_pre_calc_effect(
        this_action_id,
        1,
        1,
        0),
      build_action_def_result_effects(
        energy,
        1,
        1,
        self.action_result_coordinates_idx_self,
        0,
        1),
      [
        self.build_action_def_result_event_none(),
        build_action_def_result_event(
          0,
          0,
          self.action_result_coordinates_idx_self,
          self.see_cast_event_type,
          class,
          0),
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none()
      ])
  }
  // pub comptime fn build_cast_action(this_action_id: u8, energy: u8, class: u8) -> CtString { build_action_def(
  //     build_action_requirements_def(
  //         0,
  //         0,
  //         0,
  //         0,
  //         0,
  //         0,
  //         1,
  //         255 as u8,
  //         self.min_progress,
  //         self.max_progress,
  //         energy,
  //         0),
  //     build_action_event_def(self.see_cast_event_type, class, 0 as u8, 0 as u8, self.action_result_coordinates_idx_self, 0 as u8),
  //     self.no_event_event_type(),
  //     1 as u8,
  //     1 as u8,
  //     self.action_result_coordinates_idx_self,
  //     1,
  //     this_action_id)
  // }
  pub fn build_ritual_action(self, cast_action_id: u8, energy: u8, casting_time: u8, win_by_ritual_event_subtype: u8) -> ActionDefinition {
    build_action_definition(
      build_action_def_requirements(
        0,
        0,
        0,
        0,
        0,
        casting_time,
        self.max_progress,
        0,
        255),
      build_action_def_pre_calc_effect(
        cast_action_id,
        1,
        1,
        0),
      build_action_def_result_effects(
        energy,
        1,
        1,
        self.action_result_coordinates_idx_self,
        0,
        1),
      [
        build_action_def_result_event(
          0,
          0,
          self.action_result_coordinates_idx_invisible,
          self.win_event_type,
          win_by_ritual_event_subtype,
          255),
        build_action_def_result_event(
          0,
          0,
          self.action_result_coordinates_idx_self,
          self.win_event_type,
          win_by_ritual_event_subtype,
          255),
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none()
      ])
  }
  // pub comptime fn build_ritual_action(this_action_id: u8, energy: u8) -> CtString { build_action_def(
  //     build_action_requirements_def(
  //         0,
  //         0,
  //         0,
  //         0,
  //         0,
  //         0,
  //         1,
  //         255 as u8,
  //         RITUAL_ROUNDS_FOR_WIN,
  //         self.max_progress,
  //         energy,
  //         0),
  //     build_action_event_def(self.win_event_type, WIN_BY_RITUAL, 0 as u8, 0 as u8, self.action_result_coordinates_idx_self, 255 as u8),
  //     build_action_event_def(self.win_event_type, WIN_BY_RITUAL, 0 as u8, 0 as u8, self.action_result_coordinates_idx_invisible, 255 as u8),
  //     0 as u8,
  //     0 as u8,
  //     self.action_result_coordinates_idx_self,
  //     1,
  //     this_action_id)
  // }
  pub fn build_evocation_action(self, cast_action_id: u8, energy: u8, evocation_type: u8, range: u8, radius: u8, damage: u8, damage_upcast: u8, min_cast_time: u8, max_cast_time: u8) -> ActionDefinition {
    build_action_definition(
      build_action_def_requirements(
        0,
        0,
        0,
        0,
        0,
        min_cast_time,
        max_cast_time,
        0,
        range),
      build_action_def_pre_calc_effect(
        cast_action_id,
        1,
        1,
        0),
      build_action_def_result_effects(
        energy,
        1,
        1,
        self.action_result_coordinates_idx_self,
        0,
        1),
      [
        build_action_def_result_event(
          damage,
          damage_upcast,
          self.action_result_coordinates_idx_target,
          self.receive_attack_event_type,
          evocation_type,
          radius),
        build_action_def_result_event(
          damage,
          damage_upcast,
          self.action_result_coordinates_idx_target,
          self.receive_attack_event_type,
          evocation_type,
          radius),
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none()
      ])
  }
  // pub comptime fn build_evocation_action(cast_action_id: u8, energy: u8, evocation_type: u8, range: u8, radius: u8, damage: u8, damage_upcast: u8, min_cast_time: u8, max_cast_time: u8) -> CtString { build_action_def(
  //     build_action_requirements_def(
  //         0,
  //         0,
  //         0,
  //         0,
  //         0,
  //         0,
  //         1,
  //         range,
  //         min_cast_time,
  //         max_cast_time,
  //         energy,
  //         0), // TODO: Maybe set this to handle friendly fire???
  //     build_action_event_def(self.receive_attack_event_type, evocation_type, damage_upcast, damage, self.action_result_coordinates_idx_target, radius),
  //     build_action_event_def(self.receive_attack_event_type, evocation_type, damage_upcast, damage, self.action_result_coordinates_idx_target, radius),
  //     0 as u8,
  //     0 as u8,
  //     self.action_result_coordinates_idx_self,
  //     1,
  //     cast_action_id)
  // }
  pub fn build_search_action(self, energy: u8, range: u8) -> ActionDefinition {
    build_action_definition(
      build_action_def_requirements(
        0,
        0,
        0,
        0,
        0,
        self.min_progress,
        self.max_progress,
        0,
        range),
      build_action_def_pre_calc_effect(
        0,
        0,
        1,
        0),
      build_action_def_result_effects(
        energy,
        0,
        0,
        self.action_result_coordinates_idx_self,
        0,
        1),
      [
        build_action_def_result_event(
          0,
          0,
          self.action_result_coordinates_idx_target,
          self.see_search_event_type,
          0,
          1),
        build_action_def_result_event(
          0,
          0,
          self.action_result_coordinates_idx_target,
          self.see_search_event_type,
          0,
          1),
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none()
      ])
  }
  // pub comptime fn build_search_action(energy: u8, range: u8) -> CtString { build_action_def(
  //     build_action_requirements_def(
  //         0,
  //         0,
  //         0,
  //         0,
  //         0,
  //         0,
  //         0,
  //         range,
  //         self.min_progress,
  //         self.max_progress,
  //         energy,
  //         0),
  //     build_action_event_def(SEE_SEARCH_TRAP, 0, 0 as u8, 0 as u8, self.action_result_coordinates_idx_target, 1 as u8),
  //     build_action_event_def(SEE_SEARCH_TRAP, 0, 0 as u8, 0 as u8, self.action_result_coordinates_idx_target, 1 as u8),
  //     0 as u8,
  //     0 as u8,
  //     self.action_result_coordinates_idx_self,
  //     0,
  //     self.continues_no_action)
  // }
  pub fn build_attack_action(self, energy: u8, damage_type: u8, range: u8, damage: u8) -> ActionDefinition {
    build_action_definition(
      build_action_def_requirements(
        0,
        1,
        0,
        0,
        0,
        self.min_progress,
        self.max_progress,
        0,
        range),
      build_action_def_pre_calc_effect(
        0,
        0,
        1,
        0),
      build_action_def_result_effects(
        energy,
        0,
        0,
        self.action_result_coordinates_idx_self,
        0,
        1),
      [
        build_action_def_result_event(
          damage,
          0,
          self.action_result_coordinates_idx_target,
          self.receive_attack_event_type,
          damage_type,
          0),
        build_action_def_result_event(
          damage,
          0,
          self.action_result_coordinates_idx_target,
          self.receive_attack_event_type,
          damage_type,
          0),
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none()
      ])
  }
  // pub comptime fn build_attack_action(energy: u8, damage_type: u8, range: u8, damage: u8) -> CtString { build_action_def(
  //     build_action_requirements_def(
  //         0,
  //         0,
  //         0,
  //         0,
  //         0,
  //         0,
  //         1,
  //         range,
  //         self.min_progress,
  //         self.max_progress,
  //         energy,
  //         0),
  //     build_action_event_def(self.receive_attack_event_type, damage_type, 0 as u8, damage, self.action_result_coordinates_idx_target, 0 as u8),
  //     build_action_event_def(self.receive_attack_event_type, damage_type, 0 as u8, damage, self.action_result_coordinates_idx_target, 0 as u8),
  //     0 as u8,
  //     0 as u8,
  //     self.action_result_coordinates_idx_self,
  //     0,
  //     self.continues_no_action)
  // }
  pub fn build_draw_action(self, this_action_id: u8, energy: u8, range: u8, class: u8) -> ActionDefinition {
    build_action_definition(
      build_action_def_requirements(
        0,
        1,
        0,
        0,
        0,
        self.min_progress,
        self.max_progress, // should be max of shoot
        0,
        range),
      build_action_def_pre_calc_effect(
        this_action_id,
        1,
        1,
        1),
      build_action_def_result_effects(
        energy,
        1,
        1,
        self.action_result_coordinates_idx_self,
        0,
        0),
      [
        self.build_action_def_result_event_none(),
        build_action_def_result_event(
          0,
          0,
          self.action_result_coordinates_idx_self,
          self.see_draw_event_type,
          class,
          0),
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none()
      ])
  }
  // pub comptime fn build_draw_action(this_action_id: u8, energy: u8, range: u8, class: u8) -> CtString { build_action_def(
  //     build_action_requirements_def(
  //         0,
  //         1,
  //         0,
  //         0,
  //         0,
  //         0,
  //         0,
  //         range,
  //         self.min_progress,
  //         self.max_progress,
  //         energy,
  //         0),
  //     build_action_event_def(self.see_draw_event_type, class, 0 as u8, 0 as u8, self.action_result_coordinates_idx_self, 0 as u8),
  //     self.no_event_event_type(),
  //     1 as u8,
  //     1 as u8,
  //     self.action_result_coordinates_idx_self,
  //     1,
  //     this_action_id)
  // }
  pub fn build_shoot_action(self, draw_action_id: u8, energy: u8, damage_type: u8, range: u8, damage: u8, damage_upcast: u8, min_cast_time: u8, max_cast_time: u8) -> ActionDefinition {
    build_action_definition(
      build_action_def_requirements(
        0,
        1,
        0,
        0,
        0,
        min_cast_time,
        max_cast_time,
        0,
        range),
      build_action_def_pre_calc_effect(
        draw_action_id,
        1,
        1,
        0),
      build_action_def_result_effects(
        energy,
        1,
        1,
        self.action_result_coordinates_idx_self,
        0,
        1),
      [
        build_action_def_result_event(
          damage,
          damage_upcast,
          self.action_result_coordinates_idx_target,
          self.receive_attack_event_type,
          damage_type,
          0),
        build_action_def_result_event(
          damage,
          damage_upcast,
          self.action_result_coordinates_idx_target,
          self.receive_attack_event_type,
          damage_type,
          0),
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none()
      ])
  }
  // pub comptime fn build_shoot_action(draw_action_id: u8, energy: u8, damage_type: u8, range: u8, damage: u8, damage_upcast: u8, min_cast_time: u8, max_cast_time: u8) -> CtString { build_action_def(
  //     build_action_requirements_def(
  //         0,
  //         1,
  //         0,
  //         0,
  //         0,
  //         0,
  //         1,
  //         range,
  //         min_cast_time,
  //         max_cast_time,
  //         energy,
  //         0),
  //     build_action_event_def(self.receive_attack_event_type, damage_type, damage_upcast, damage, self.action_result_coordinates_idx_target, 0 as u8),
  //     build_action_event_def(self.receive_attack_event_type, damage_type, damage_upcast, damage, self.action_result_coordinates_idx_target, 0 as u8),
  //     0 as u8,
  //     0 as u8,
  //     self.action_result_coordinates_idx_self,
  //     1,
  //     draw_action_id)
  // }
  pub fn build_disarm_trap_action(self, energy: u8, range: u8) -> ActionDefinition {
    build_action_definition(
      build_action_def_requirements(
        0,
        0,
        0,
        0,
        0,
        self.min_progress,
        self.max_progress,
        0,
        range),
      build_action_def_pre_calc_effect(
        0,
        0,
        1,
        1),
      build_action_def_result_effects(
        energy,
        1,
        1,
        self.action_result_coordinates_idx_self,
        0,
        0),
      [
        build_action_def_result_event(
          0,
          0,
          self.action_result_coordinates_idx_target,
          self.disarm_trap_event_type,
          0,
          0),
        build_action_def_result_event(
          0,
          0,
          self.action_result_coordinates_idx_target,
          self.disarm_trap_event_type,
          0,
          0),
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none()
      ])
  }
  // pub comptime fn build_disarm_trap_action(energy: u8, range: u8) -> CtString { build_action_def(
  //     build_action_requirements_def(
  //         0,
  //         1,
  //         0,
  //         0,
  //         0,
  //         0,
  //         0,
  //         range,
  //         self.min_progress,
  //         self.max_progress,
  //         energy,
  //         0),
  //     build_action_event_def(DISARMED_TRAP, 0, 0 as u8, 0 as u8, self.action_result_coordinates_idx_target, 0 as u8),
  //     build_action_event_def(DISARMED_TRAP, 0, 0 as u8, 0 as u8, self.action_result_coordinates_idx_target, 0 as u8),
  //     0 as u8,
  //     0 as u8,
  //     self.action_result_coordinates_idx_self,
  //     0,
  //     self.continues_no_action)
  // }
  pub fn build_set_trap_action(self, energy: u8, range: u8, add_obstacle_event_type: u8, obstacle_type_trap: u8) -> ActionDefinition {
    build_action_definition(
      build_action_def_requirements(
        1,
        1,
        0,
        1,
        0,
        self.min_progress,
        self.max_progress,
        0,
        range),
      build_action_def_pre_calc_effect(
        0,
        0,
        1,
        0),
      build_action_def_result_effects(
        energy,
        0,
        0,
        self.action_result_coordinates_idx_self,
        0,
        0),
      [
        self.build_action_def_result_event_none(),
        self.build_action_def_result_event_none(),
        build_action_def_result_event(
          0,
          0,
          self.action_result_coordinates_idx_target,
          add_obstacle_event_type,
          obstacle_type_trap,
          0),
        self.build_action_def_result_event_none()
      ])
  }
  // pub comptime fn build_set_trap_action(energy: u8, range: u8) -> CtString { build_action_def(
  //     build_action_requirements_def(
  //         1,
  //         0,
  //         0,
  //         1,
  //         0,
  //         0,
  //         0,
  //         range,
  //         self.min_progress,
  //         self.max_progress,
  //         energy,
  //         1),
  //     self.no_event_event_type(),
  //     build_action_event_def(ADD_OBSTACLE, TRAP, 0 as u8, 50 as u8, self.action_result_coordinates_idx_target, 0 as u8),
  //     0 as u8,
  //     0 as u8,
  //     self.action_result_coordinates_idx_self,
  //     0,
  //     self.continues_no_action)
  // }
}