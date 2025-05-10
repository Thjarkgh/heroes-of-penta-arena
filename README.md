# Heroes of Penta - Arena

Heroes of Penta - Arena is a serverless 1vs1 PvP turn-based TRPG ENGINE.

**Build a game engine or build a game**

There is this famous saying: Build a game engine or build a game, you can't do both. Thus, what started in the V0rtex Hackathon 2024 as a game project, became a game-engine project in this year's Noirhack hackathon.

## Motivation

For solo indie game devs, one particular bottleneck that always bothered me, was the reliance on a centralized server. Maintaining a secure and performant game server is no small task, often already requiring the full attention of a fulltime admin plus significant costs for the server itself, meaning, for solo dev projects, this is often not feasible. BUT, with Noir and ZK-Proofs, one can actually circumvent this bottleneck, using client-side ZK-proofs.

However, implementing a full game-logic in Noir, with all its constraints, can be another challenging task. This is where the skp engine enters the scene:

## SKPL Engine

Since, so far, there is no Noir game engine, this project tries to remedy this gap in the Noir environment:
As a game engine, SKPL can be used for basically any ZK task that is turn-based, whether a strategy game, a text adventure or even a verifiable survey - SKPL is here to help you out.

## Basic Structure of this monorep:

circuits: This is where the SKPL Engine is at home and all the Noir magic is happening
mobile: This is a small demo with SKPL Engine use within noir_android - however, due to noir_android stability issues, this is not fully functional at the moment.
webapp: This is a small demo with SKPL Engine use within a noir.js powered website. For the Noirhack hackathon, there unfortunately was not enough time to finish it..

## How does it work?

We assume that each player has a secret state, whether this be traps, hidden rogues or cards within your hand, there is a part of the game-state this is hidden and one that is public.
On each turn, we need to exchange the public information, while at the same time, proving that the public information we exchange is correct.
SKPL uses an event based system for this. Basically, all public game state updates happen via events and the Noir circuit proves, that the events received are actually valid.

### Basic data structures:

The game engine differentiates between 6 basic data types:
* Character: These are player controllable entities, that take turns to act.
* Obstacle: These are static objects created by the current player.
* ActionDefinition: These describe workflows that each Character can trigger.
* Action: These are commands at the game engine, they select a Character, an ActionDefinition and arguments for the action definition.
* Object: These are both Obstacles and Characters of the opponent, we only know their position (if we found them) and their type.
* Event: This is the driving factor of the engine: Private Actions using private ActionDefinitions yield Events, which are then publicly sent to the opponent.

Of all of these, only Objects and Events are public, the rest is private.

### Basic workflow:

1. Verify that the player did not secretly change their private state between turns: There is a public hash of a secret + the private state of the end of the last turn. The engine verifies that this state did not change.
2. Apply the opponent's Events to the own Characters and Obstacles.
3. Iterate over all Actions to generate Events and update the private game state.
4. Generate Objects off of all visible Obstacles and Characters.
5. Generate a hash over the new private state.
6. Validate that the provided public result state matches the calculated result state.

### How to use:

First you might want to adapt the default settings for the number of Characters, Obstacles, ActionDefinitions/Character and Actions/Turn:
All game-specific constants are currently stored in /circuits/arenalib/src/lib.nr (subject to change)
Adapt:
MAX_CHARACTERS: Number of Characters per player
MAX_OBSTACLES: Number of Obstacles per player
MAX_ACTIONS_PER_CHARACTER: Number of ActionDefinitions per player IN ADDITION to the default WAIT action (which is simply required)
WIDTH_BITS: Map width in bits
WIDTH: Map width (limited by 2 ^ WIDTH_BITS)
HEIGHT_BITS: Map height in bits
HEIGHT: Map height (limited by 2 ^ HEIGHT_BITS)
MAX_ACTIONS: Max number of actions per round per player

Then create your ActionDefinitions:
Use the /circuits/arenalib/src/character.nr file as template on how to create your own actions (already serialized and ready to use!)

Then, run
```
npm i
npm run generate
```

in either of the two template applications to update the compiled circuits!

In you game you will want to have two phases (whether you display the setup phase in the UI, or simply setup things directly is up to you)

Setup Phase

First you need dummy events from a fictional opponent to get the circuit started (there is no actual turn before this one, so you need dummy values)
In case you kept the default values and ActionDefinitions, you can use the default serialized values to get started (as provided in the samples):

```

const initial_my_chars_input = "0x2912640000004b03190000006c04142000008a0464000000aa47640b340a"; // this you will usually read from NFTs
const initial_enemy_events = ["0x04ffff0000000004ffff0000000004ffff0000000004ffff000000000000"]; // dummy default values
const initial_my_char_actions = ["0x03f00001300314002000000000100300000020000000002000000000000000", "0x02f0000110071020100a000020100a00000020000000002000000000000000", "0x02f0000a3b1901002000000000000801000020000000002000000000000000", "0x023100081b161118120a010018120a01000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0x03f00001300414002000000000100300000020000000002000000000000000", "0x02f0000110071008100a000008100a00000020000000002000000000000000", "0xf0003f1b1c11002000000000000702000020000000002000000000000000", "0xff003f1b1c1100200e013f00000e013f0020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0x03f00001300314002000000000100300000020000000002000000000000000", "0x02f0000110071018100a000018100a00000020000000002000000000000000", "0x09f0000130060c002000000000200000000020000000002000000000000000", "0xf00001100610001005000100100500010020000000002000000000000000", "0xf00001301c0100100d000000100d00000020000000002000000000000000", "0x0bf00001100c00002000000000200000000010040a00002000000000000000", "0x03f00001300414002000000000100300000020000000002000000000000000", "0x02f0000110061028100a000028100a00000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0x03f00001300414002000000000100300000020000000002000000000000000", "0x02f0000110071010100a000010100a00000020000000002000000000000000", "0xf000071b1611002000000000000705000020000000002000000000000000", "0x6300061b161164150a020164150a02010020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000"]; // the serialized default ActionDefinitions
const WALL = "0x06";  // Default non-traversible obstacle
const WATER = "0x07"; // Default traversible obstacle
const initial_enemy_advance = "0x00";
const initial_enemy_objects = ["0x00", "0x00", "0x00", "0x00"]; // assuming that at the beginning all opponent objects are out of sight

const enemy_events = initial_enemy_events;
const enemy_objects = initial_enemy_objects;
const enemy_advance = initial_enemy_advance;
```

Then you will need to deserialize some of these:
```
const [enemy_events_parsed_valid, enemy_events_parsed] = await skpl.parse_their_events(enemy_events);
const [theirObjectsValid, theirObjects] = await skpl.parse_their_obstacles(enemy_objects);
const [my_chars_valid, my_chars] = await skpl.parse_characters(initial_my_chars_input, initial_my_char_actions, enemy_events_parsed, "0x00");

```

Next, you will have to place you Characters and create your Obstacles (assuming you did not deactivate them):

```
// usually, you will want to offer either pre-made maps or let the player place them freely
const obstacleData = [
  { id: "0x00", x: "0x00", y: "0x02", health: 200, type: WALL }, { id: "0x01", x: "0x01", y: "0x02", health: 200, type: WALL },
  { id: "0x02", x: "0x03", y: "0x02", health: 200, type: WALL }, { id: "0x03", x: "0x04", y: "0x02", health: 200, type: WALL },
  { id: "0x04", x: "0x05", y: "0x03", health: 200, type: WALL }, { id: "0x05", x: "0x05", y: "0x04", health: 200, type: WALL },
  { id: "0x06", x: "0x05", y: "0x05", health: 200, type: WALL }, { id: "0x07", x: "0x05", y: "0x07", health: 200, type: WALL },
  { id: "0x08", x: "0x04", y: "0x07", health: 200, type: WALL }, { id: "0x09", x: "0x03", y: "0x07", health: 200, type: WALL },
  { id: "0x0a", x: "0x01", y: "0x07", health: 200, type: WALL }, { id: "0x0b", x: "0x00", y: "0x07", health: 200, type: WALL },
  { id: "0x0c", x: "0x07", y: "0x00", health: 200, type: WALL }, { id: "0x0d", x: "0x07", y: "0x01", health: 200, type: WALL },
  { id: "0x0e", x: "0x07", y: "0x02", health: 200, type: WALL }, { id: "0x0f", x: "0x07", y: "0x03", health: 200, type: WALL },
  { id: "0x10", x: "0x07", y: "0x04", health: 200, type: WALL }, { id: "0x11", x: "0x07", y: "0x05", health: 200, type: WALL },
  { id: "0x12", x: "0x06", y: "0x08", health: 255, type: WATER }, { id: "0x13", x: "0x07", y: "0x08", health: 255, type: WATER },
  { id: "0x14", x: "0x05", y: "0x09", health: 255, type: WATER }, { id: "0x15", x: "0x06", y: "0x09", health: 255, type: WATER },
  { id: "0x16", x: "0x07", y: "0x09", health: 255, type: WATER }, { id: "0x17", x: "0x08", y: "0x09", health: 255, type: WATER },
];
const myObstaclesParsedResults = await Promise.all(obstacleData.map(data => {
  const x = skpl.new_obstacle(data.id, data.x, data.y, toHex(data.health), data.type);
  return x;
}));
if (!myObstaclesParsedResults.every(r => r[0])) throw new Error("Failed to create obstacles!");
let myObstacles = myObstaclesParsedResults.map(r => r[1]);
```

Game Phase

Now, you can start playing in turns - for the first turn, you already handled the opponents events - for follow-up turns, you will start by first deserializing your opponents Events and Objects and then your own Characters, using your opponents Events.

Then you can start asking your player for Actions, whereby you will always first want to get the actually available actions first!
For this, you need to first render your own Characters as Objects and feed them together with your Obstacles to the skpl.get_performable_action function:
```
const myCharsAsObjectsResult = await skpl.chars_to_obstacles(my_chars_for_calc);
if (!myCharsAsObjectsResult[0]) throw new Error("Failed to serialize my characters as objects");

const myObjects = myObstacles.map(x=>x);
myObjects.push(...myCharsAsObjectsResult[1]);
const performableActions = await skpl.get_performable_actions(my_chars_for_calc[actor_id], initial_enemy_advance, toHex(energyLeft), myObjects, theirObjects);
```

As you can see in the above sample, you also need to track "Energy": This is similar to action points and similar mechanics:
Basically, each action has a defined cost in energy. Each player gets 12 energy per turn allowing for a variable number of actions (up to MAX_ACTIONS).

Once you get player input, you can create an action:
```
// Sample Action:
// type 1 means first custom ActionDefinition of the Character
// actor_id needs to refer to the active Character
// 10 & 2 are the target coordinates where to execute the Action
const action = await new_action(toHex(1), toHex(actor_id), toHex(10), toHex(2));
```

Then you can update your temporary local state, by executing the action:
```
const [actionCalcValid, myCharsUpdated, myObstaclesUpdated, energyLeft, resultEvent] =
    await skpl.calculate_action(action, my_chars_for_calc, myObstacles, theirObjects, enemy_advance, toHex(energyLeft));
```

The resultEvent is here mostly for the UI so you can display effects.

Once all Actions have been defined, you can start with the proof generation.
For this, you will first need to serialize your inputs:
```
const [my_chars_input_serialized_valid, my_chars_input_serialized] = await skpl.serialize_chars(my_chars);
const [my_obstacles_input_serialized_valid, my_obstacles_input_serialized] = await skpl.serialize_my_obstacles_for_me(myObstacles);

```

Action serialization is a little tricky, as you can have a varying number of them, but Noir requires fixed size arrays for proof inputs.
One option is to use different functions for each possible number of actions like in the arenalib sample:
```
const serializeActions = async (actions: Action[]) => {
  if (actions.length === 4) {
    return arenalib.serialize_actions_4(toHex(actor_id), actions);
  }
  if (actions.length === 3) {
    return arenalib.serialize_actions_3(toHex(actor_id), actions);
  }
  if (actions.length === 2) {
    return arenalib.serialize_actions_2(toHex(actor_id), actions);
  }
  if (actions.length === 1) {
    return arenalib.serialize_actions_1(toHex(actor_id), actions[0]);
  }
  if (actions.length === 0) {
    return arenalib.serialize_actions_0(toHex(actor_id));
  }
  throw new Error(`invalid action number ${actions.length}`);
}
const actions_input_serialized = await serializeActions(actions);
```

Then you can calculate the turn results (which **should** match the results you got from calling skpl.calculate_action):
```
const [
  calculate_turn_valid,
  my_result_chars_serialized,
  my_result_char_actions_serialized,
  my_result_obstacles,
  my_result_advance,
  my_result_events_serialized,
  my_result_objects_serialized
] = await skpl.calculate_turn(
  my_chars_input_serialized,
  my_char_actions_input_serialized,
  my_obstacles_input_serialized,
  actions_input_serialized,
  toHex(move),
  initial_enemy_advance,
  initial_enemy_objects,
  initial_enemy_events
);
```

To generate the proof, you will also need to serialize those result obstacles:
```
const my_result_obstacles_serialized = await skpl.serialize_my_obstacles_for_me(my_result_obstacles);
```

In the first turn, you need to generate two hashes - in follow-up turns, you can re-use the last turns gamestate_after_hash as you gamestate_before_hash:
```
const initial_hash = await skpl.hash_serialized_private_state(my_chars_input_serialized, my_char_actions_input_serialized, my_obstacles_input_serialized, secret);
const result_hash = await skpl.hash_serialized_private_state(my_result_chars_serialized, my_result_char_actions_serialized, my_result_obstacles_serialized, secret);
```

With all the data ready, you can create the actual proof - which atm is still slightly more complicated as you cannot use noir-codegen functions:
Thus you still need to load the circuit in a separate iframe and then execute it.
If you use the webapp template, you can reuse the prover.js iframe:

```
const proofArgs = {
    secret,
    my_chars_input: my_chars_input_serialized,
    my_char_actions: my_char_actions_input_serialized,
    my_obstacles_input: my_obstacles_input_serialized,
    actions: actions_input_serialized,
    move,
    enemy_advance: initial_enemy_advance,
    enemy_objects: initial_enemy_objects,
    enemy_events: initial_enemy_events, // Pass the initial string array format expected by the circuit
    my_result_advance,
    my_result_events: my_result_events_serialized,
    my_result_objects: my_result_objects_serialized,
    gamestate_before_hash: initial_hash,
    gamestate_after_hash: result_hash,
};
iframeRef.current.contentWindow.postMessage({
  type: 'generateProof',
  payload: {
    // Pass the actual circuit JSON for the proof circuit
    circuitJson: circuitProof as Circuit, // Pass the imported JSON
    inputs: proofArgs,
    abi: circuitProof.abi as Circuit["abi"] // Pass the ABI needed by iframe's serializeArguments
  }
}, '*');
```

Then you can send:
move, my_result_advance, my_result_events, my_result_objects, initial_hash and result_hash together with the proof to your opponent (either via webRTC or by pushing on a blockchain).


## NOTE

This is an in active development pre-alpha version, so there is still a lot that will change!