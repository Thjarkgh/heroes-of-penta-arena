use arenalib::{ NO_EVENT, SEE_MOVE, RECEIVE_ATTACK, TRIGGERED_TRAP }; //, SEE_RITUAL, SEE_CAST, SEE_DRAW, SEE_SEARCH_TRAP, FOUND_TRAP
// use crate::{ EMPTY, WALL };
use arenalib::{ EVENT_COUNT };
use arenalib::{ ATTACK_FIREBALL };
use arenalib::{ SERIALIZED_EVENT_BYTE_SIZE, SERIALIZED_EVENTS_ARRAY_SIZE, SERIALIZED_EVENTS_PER_FIELD };
use arenalib::{ WIDTH };
use arenalib::{ MAX_CHARACTERS, MAX_EVENTS }; //, MAX_TRAPS
use arenalib::SerializedArenaEvents;
// use crate::TRAPS_BUFFER_MASK;
use crate::map::get_distance;
// use crate::character::Character;
use crate::character::{ get_attack_damage_to_tile, get_trap_damage_to_tile };
use crate::map::their_x_to_mine;
use skplg::{ debug, softassert, NOWHERE, UNREADABLE_BYTES_PER_FIELD };

pub struct Event {
    pub event: u8,
    pub actor_id: u8,
    pub subtype: u8,
    pub x: u8,
    pub y: u8,
    pub value: u8,
    pub radius: u8,
}


    #[export]
    pub fn parse_their_events(fields: SerializedArenaEvents) -> pub (bool, [Event; MAX_EVENTS]) {
        comptime {
            assert(UNREADABLE_BYTES_PER_FIELD + SERIALIZED_EVENTS_PER_FIELD * SERIALIZED_EVENT_BYTE_SIZE <= 32);
            assert(SERIALIZED_EVENTS_ARRAY_SIZE * SERIALIZED_EVENTS_PER_FIELD == MAX_EVENTS);
            assert(SERIALIZED_EVENT_BYTE_SIZE >= 6);
        }

        let mut valid = true;
        let mut events: [Event; MAX_EVENTS] = [Event::empty(0); MAX_EVENTS];
        for i in 0..SERIALIZED_EVENTS_ARRAY_SIZE {
            let split: [u8; 32] = fields[i].to_be_bytes::<32>(); //.to_be_bytes<32>();
            //assert(split.len() == 32);
            for j in 0..SERIALIZED_EVENTS_PER_FIELD {
                let offset = UNREADABLE_BYTES_PER_FIELD + j * SERIALIZED_EVENT_BYTE_SIZE;
                let raw_x = split[offset + 2];
                let (x_parsed_valid, x_parsed) = their_x_to_mine(raw_x);
                softassert!(quote { valid }, quote { x_parsed_valid }, quote { f"Failed to calculate their_x_to_mine: {raw_x}" });
                events[i * SERIALIZED_EVENTS_PER_FIELD + j] = Event {
                    event: split[offset],
                    actor_id: split[offset + 1],
                    x: x_parsed,
                    y: split[offset + 3],
                    value: split[offset + 4],
                    subtype: split[offset + 5],
                    radius: split[offset + 6],
                };
            }
        }
        (valid, events)
    }
    
    #[export]
    pub fn serialize_events(events: [Event; MAX_EVENTS]) -> pub SerializedArenaEvents {
        assert(events.len() == MAX_EVENTS);
        assert(MAX_EVENTS % SERIALIZED_EVENTS_PER_FIELD == 0);
        assert(SERIALIZED_EVENT_BYTE_SIZE >= 6);

        let mut fields: [Field] = &[];
        for i in 0..SERIALIZED_EVENTS_ARRAY_SIZE {
            let mut data: [u8; 32] = [0; 32];
            for j in 0..SERIALIZED_EVENTS_PER_FIELD {
                let index = i * SERIALIZED_EVENTS_PER_FIELD + j;
                let event = events[index];
                let offset = UNREADABLE_BYTES_PER_FIELD + j * SERIALIZED_EVENT_BYTE_SIZE;
                data[offset] = event.event;
                data[offset + 1] = event.actor_id;
                data[offset + 2] = event.x;
                data[offset + 3] = event.y;
                data[offset + 4] = event.value;
                data[offset + 5] = event.subtype;
                data[offset + 6] = event.radius;
            }
            fields = fields.push_back(std::field::bytes32_to_field(data));
        }
        fields.as_array()
    }
    
#[test]
fn test_event_serde() {
    let events = [
    build_subtype_value_event(NO_EVENT, 4, NOWHERE, NOWHERE, 5, NO_EVENT, 1),
    build_subtype_value_event(NO_EVENT, 4, NOWHERE, NOWHERE, 6, NO_EVENT, 2),
    build_subtype_value_event(NO_EVENT, 4, NOWHERE, NOWHERE, 7, NO_EVENT, 3),
    build_subtype_value_event(NO_EVENT, 4, NOWHERE, NOWHERE, 8, NO_EVENT, 4)
  ];

  let serialized = serialize_events(events);
  let (result_valid, result) = parse_their_events(serialized);
  assert(result_valid);
  assert(result[0].event == events[0].event);
  assert(result[1].event == events[1].event);
  assert(result[2].event == events[2].event);
  assert(result[3].event == events[3].event);
  assert(result[0].actor_id == events[0].actor_id);
  assert(result[1].actor_id == events[1].actor_id);
  assert(result[2].actor_id == events[2].actor_id);
  assert(result[3].actor_id == events[3].actor_id);
  assert(result[0].x == events[0].x);
  assert(result[1].x == events[1].x);
  assert(result[2].x == events[2].x);
  assert(result[3].x == events[3].x);
  assert(result[0].y == events[0].y);
  assert(result[1].y == events[1].y);
  assert(result[2].y == events[2].y);
  assert(result[3].y == events[3].y);
  assert(result[0].value == events[0].value);
  assert(result[1].value == events[1].value);
  assert(result[2].value == events[2].value);
  assert(result[3].value == events[3].value);
  assert(result[0].subtype == events[0].subtype);
  assert(result[1].subtype == events[1].subtype);
  assert(result[2].subtype == events[2].subtype);
  assert(result[3].subtype == events[3].subtype);
  assert(result[0].radius == events[0].radius);
  assert(result[1].radius == events[1].radius);
  assert(result[2].radius == events[2].radius);
  assert(result[3].radius == events[3].radius);
}
    // fn affects_my_character(self, x: u8, y: u8) -> bool {
    //     let distance = get_distance(self.x, self.y, x, y);
    //     ((self.x == x) & (self.y == y)) | ((self.event == RECEIVE_ATTACK) & (self.subtype == ATTACK_FIREBALL) & is_neighbor(self.x, self.y, x, y))
    // }
impl Event {
    fn affects_my_obstacle(self, x: u8, y: u8) -> bool {
        (self.x == x) & (self.y == y)
    }

    fn may_affect_my_other_characters(self) -> bool {
        (self.event == RECEIVE_ATTACK) & (self.subtype == ATTACK_FIREBALL)
    }

    fn may_affect_my_obstacles(self) -> bool {
        self.event == RECEIVE_ATTACK
    }

    /**
    * For now we will only take class into account.
    */
    pub fn get_applied_damage_to_my_asset(self, x: u8, y: u8, tile: u8) -> u16 {
        let mut damage = 0;
        let radius = self.radius as u32;
        let radius = radius * radius;
    
        if self.event == RECEIVE_ATTACK {
            let distance = get_distance(self.x, self.y, x, y) as u32;
            debug!(quote {
                        // let event = self.event;
                        // let actor = self.actor_id;
                        // let self_x = self.x;
                        // let self_y = self.y;
                        // let val = self.value;
                        // println(f"GetAppliedDamageToMyAsset: Event({event}:{val} from {actor}@{self_x}|{self_y})@{x}|{y}: {distance} <= {radius}");
                    });
            if distance <= radius {
                let damage_raw = get_attack_damage_to_tile(self.subtype, self.value as u32, tile) as u32;
                damage = damage_raw * (1 + radius - distance) / (radius + 1) as u32;
                debug!(quote { println(f"Deal damage: {damage_raw} * (1 + {radius} - {distance}) / ({radius} + 1) = {damage}"); });
            }
            // if (self.x == x) & (self.y == y) {
            //     damage = get_attack_damage_to_tile(self.subtype, self.value as u16, tile);
            // } else if (self.subtype == ATTACK_FIREBALL) & is_neighbor(self.x, self.y, x, y) {
            //     damage = get_attack_damage_to_tile(self.subtype, self.value as u16, tile) / 2;
            // }
        }
        if self.event == TRIGGERED_TRAP {
            damage = get_trap_damage_to_tile(self.value as u32, tile);
        }
        damage as u16
    }

    pub fn empty(actor_id: u8) -> Event {
        Event {
            event: NO_EVENT,
            actor_id: actor_id,
            x: 0,
            y: 0,
            value: 0,
            subtype: 0,radius: 0
        }
    }

    pub fn get_dummy_events() -> [Field; MAX_EVENTS] {
        [0; MAX_EVENTS]
    }

    pub fn get_test_dummy_events() -> [Event; MAX_EVENTS] {
        [Event::empty(0); MAX_EVENTS]
    }
}

pub fn build_std_event(event: u8, actor_id: u8, x: u8, y: u8) -> Event {
    assert(event < EVENT_COUNT);
    assert((actor_id as u32) < MAX_CHARACTERS);
    assert((x < WIDTH) | (x == NOWHERE));
    Event {
        event: event,
        actor_id: actor_id,
        x: x,
        y: y,
        value: 0,
        subtype: 0,
        radius: 0,
    }
}

#[test]
fn test_build_std_event() {
    let event = build_std_event(SEE_MOVE, 1, 2, 3);
    assert(event.event == SEE_MOVE);
    assert(event.actor_id == 1);
    assert(event.x == 2);
    assert(event.y == 3);
}

#[test(should_fail)]
fn test_build_std_event_fail() {
    let event = build_std_event(EVENT_COUNT, 1, 2, 3);
    assert(event.event == EVENT_COUNT);
}

pub fn build_value_event(event: u8, actor_id: u8, x: u8, y: u8, value: u8) -> Event {
    Event {
        event: event,
        actor_id: actor_id,
        x: x,
        y: y,
        value: value,
        subtype: 0,
        radius: 0,
    }
}

pub fn build_subtype_value_event(event_type: u8, actor_id: u8, x: u8, y: u8, value: u8, event_subtype: u8, radius: u8) -> Event {
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
