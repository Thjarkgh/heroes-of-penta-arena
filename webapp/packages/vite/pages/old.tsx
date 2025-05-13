// import { useState } from 'react';
// import React from 'react';

// import { useOnChainVerification } from '../hooks/useOnChainVerification.jsx';
// import { useProofGeneration } from '../hooks/useProofGeneration.jsx';
// import { useOffChainVerification } from '../hooks/useOffChainVerification.jsx';

// function Component() {
//   const [input, setInput] = useState<{ x: string; y: string } | undefined>();
//   const { noir, proofData, backend } = useProofGeneration(input);
//   useOffChainVerification(backend!, noir, proofData);
//   const verifyButton = useOnChainVerification(proofData);

//   const submit = (e: React.FormEvent<HTMLFormElement>) => {
//     e.preventDefault();
//     const elements = e.currentTarget.elements;
//     if (!elements) return;

//     const x = elements.namedItem('x') as HTMLInputElement;
//     const y = elements.namedItem('y') as HTMLInputElement;

//     setInput({ x: x.value, y: y.value });
//   };

//   return (
//     <>
//       <form className="container" onSubmit={submit}>
//         <h1>Example starter</h1>
//         <h2>This circuit checks that x and y are different (yey!)</h2>
//         <p>Try it!</p>
//         <input name="x" type="text" />
//         <input name="y" type="text" />
//         <button type="submit">Calculate proof</button>
//       </form>
//       {verifyButton}
//     </>
//   );
// }

// export default Component;

import React, { useEffect, useState } from 'react';

import * as skpl from '../logic/skpl/index';
import * as arenalib from '../logic/arenalib/index';

// --- Noir Library Imports (ASSUMED - Update path as needed) ---
import {
  clearCircuit,
  executeCircuit,
  // extractProof,
  generateProof,
  getVerificationKey,
  setupCircuit,
  verifyProof,
} from '../lib/noir'; // UPDATE THIS PATH

// --- Type Imports (ASSUMED - Update paths as needed) ---
import { Circuit } from '../types'; // UPDATE THIS PATH
import { Action } from '../logic/skpla'; // UPDATE THIS PATH
import { Character, Event, Field, Obstacle, u8 } from '../logic/skpl'; // UPDATE THIS PATH

// --- Circuit Imports (ASSUMED - Update paths as needed) ---
// Ensure your build system handles JSON imports correctly
import circuitTest from '../../../../circuits/skpl/export/turn.json';
import circuitProof from '../../../../circuits/circuit/target/skp.json';
import circuitHashPrivateState from '../../../../circuits/skpl/export/hash_serialized_private_state.json';
import circuitNewAction from '../../../../circuits/skpla/export/new_action.json';
import circuitNewObstacle from '../../../../circuits/skpl/export/new_obstacle.json';
import circuitSerializeCharacters from '../../../../circuits/skpl/export/serialize_chars.json';
import circuitSerializeActions0 from '../../../../circuits/arenalib/export/serialize_actions_0.json';
import circuitSerializeActions1 from '../../../../circuits/arenalib/export/serialize_actions_1.json';
import circuitSerializeActions2 from '../../../../circuits/arenalib/export/serialize_actions_2.json';
import circuitSerializeActions3 from '../../../../circuits/arenalib/export/serialize_actions_3.json';
import circuitSerializeActions4 from '../../../../circuits/arenalib/export/serialize_actions_4.json';
import circuitSerializeObstacles from '../../../../circuits/skpl/export/serialize_my_obstacles_for_me.json';
import circuitSerializeEvents from '../../../../circuits/skpl/export/serialize_events.json';
import circuitDeserializeEvents from '../../../../circuits/skpl/export/parse_their_events.json';
import circuitDeserializeCharacters from '../../../../circuits/skpl/export/parse_characters.json';
import circuitCalculateTurn from '../../../../circuits/skpl/export/calculate_turn.json';
import { skp } from '../logic/skp';

// --- Hardcoded Data (from original component) ---
const secret = "0x075bcd15";
const initial_my_chars_input = "0x2912640000004b03190000006c04142000008a0464000000aa47640b340a";
const initial_enemy_events = ["0x04ffff0000000004ffff0000000004ffff0000000004ffff000000000000"];
const initial_my_char_actions = ["0x03f00001300314002000000000100300000020000000002000000000000000", "0x02f0000110071020100a000020100a00000020000000002000000000000000", "0x02f0000a3b1901002000000000000801000020000000002000000000000000", "0x023100081b161118120a010018120a01000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0x03f00001300414002000000000100300000020000000002000000000000000", "0x02f0000110071008100a000008100a00000020000000002000000000000000", "0xf0003f1b1c11002000000000000702000020000000002000000000000000", "0xff003f1b1c1100200e013f00000e013f0020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0x03f00001300314002000000000100300000020000000002000000000000000", "0x02f0000110071018100a000018100a00000020000000002000000000000000", "0x09f0000130060c002000000000200000000020000000002000000000000000", "0xf00001100610001005000100100500010020000000002000000000000000", "0xf00001301c0100100d000000100d00000020000000002000000000000000", "0x0bf00001100c00002000000000200000000010040a00002000000000000000", "0x03f00001300414002000000000100300000020000000002000000000000000", "0x02f0000110061028100a000028100a00000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0x03f00001300414002000000000100300000020000000002000000000000000", "0x02f0000110071010100a000010100a00000020000000002000000000000000", "0xf000071b1611002000000000000705000020000000002000000000000000", "0x6300061b161164150a020164150a02010020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000"];
const WALL = "0x06";
const WATER = "0x07";

// Placeholder for the formatProof function if not available
const formatProof = (proof: string): string => {
    if (!proof) return '';
    // Simple formatting: show first and last few characters
    const maxLength = 60;
    if (proof.length <= maxLength) return proof;
    return `${proof.substring(0, maxLength / 2)}...${proof.substring(proof.length - maxLength / 2)}`;
}

// --- The React Component ---
const SkpProofComponent: React.FC = () =>  {
    const [proofAndInputs, setProofAndInputs] = useState<{ proof: string; publicInputs: string[]; } | null>(null);
    const [proof, setProof] = useState('');
    const [vkey, setVkey] = useState(''); // Verification key (optional to store/display)
    const [generatingProof, setGeneratingProof] = useState(false);
    const [verifyingProof, setVerifyingProof] = useState(false);
    const [provingTime, setProvingTime] = useState(0);
    const [statusMessage, setStatusMessage] = useState<string | null>(null);
    const [errorMessage, setErrorMessage] = useState<string | null>(null);

    // State to hold circuit IDs
    const [circuitIds, setCircuitIds] = useState<Record<string, string | undefined>>({});

    // --- Circuit Setup Effect ---
    useEffect(() => {
        const circuitsToSetup: { name: string; circuit: Circuit }[] = [
            { name: 'test', circuit: circuitTest as unknown as Circuit },
            { name: 'proof', circuit: circuitProof as unknown as Circuit },
            { name: 'hashPrivateState', circuit: circuitHashPrivateState as unknown as Circuit },
            { name: 'newAction', circuit: circuitNewAction as unknown as Circuit },
            { name: 'newObstacle', circuit: circuitNewObstacle as unknown as Circuit },
            { name: 'serializeChars', circuit: circuitSerializeCharacters as unknown as Circuit },
            { name: 'serializeActions0', circuit: circuitSerializeActions0 as unknown as Circuit },
            { name: 'serializeActions1', circuit: circuitSerializeActions1 as unknown as Circuit },
            { name: 'serializeActions2', circuit: circuitSerializeActions2 as unknown as Circuit },
            { name: 'serializeActions3', circuit: circuitSerializeActions3 as unknown as Circuit },
            { name: 'serializeActions4', circuit: circuitSerializeActions4 as unknown as Circuit },
            { name: 'serializeObstacles', circuit: circuitSerializeObstacles as unknown as Circuit },
            { name: 'serializeEvents', circuit: circuitSerializeEvents as unknown as Circuit },
            { name: 'deserializeEvents', circuit: circuitDeserializeEvents as unknown as Circuit },
            { name: 'deserializeChars', circuit: circuitDeserializeCharacters as unknown as Circuit },
            { name: 'calculateTurn', circuit: circuitCalculateTurn as unknown as Circuit },
        ];

        let mounted = true;
        const setupAllCircuits = async () => {
            setStatusMessage('Setting up circuits...');
            const ids: Record<string, string> = {};
            try {
                for (const { name, circuit } of circuitsToSetup) {
                    const id = await setupCircuit(circuit);
                    if (!mounted) {
                        // If component unmounted during setup, clear this circuit immediately
                        clearCircuit(id);
                        return;
                    }
                    ids[name] = id;
                     console.log(`Circuit ${name} setup with ID: ${id}`);
                }
                if (mounted) {
                    setCircuitIds(ids);
                    setStatusMessage('Circuits ready.');
                     console.log('All circuits set up:', ids);
                }
            } catch (error) {
                console.error("Circuit setup failed:", error);
                if (mounted) {
                    setErrorMessage(`Circuit setup failed: ${error instanceof Error ? error.message : String(error)}`);
                    setStatusMessage(null);
                }
                // Attempt to clear any circuits that might have been set up
                Object.values(ids).forEach(id => clearCircuit(id));
            }
        };

        setupAllCircuits();

        // Cleanup function
        return () => {
            mounted = false;
            console.log('Cleaning up circuits...');
            Object.values(circuitIds).forEach(id => {
                if (id) {
                    console.log(`Clearing circuit ID: ${id}`);
                    clearCircuit(id);
                }
            });
            setCircuitIds({}); // Clear IDs from state
             console.log('Circuit cleanup complete.');
        };
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []); // Run only once on mount


     // Helper to check if all necessary circuits are loaded
    const areCircuitsReady = (): boolean => {
        const requiredCircuits = [
            'test', 'proof', 'hashPrivateState', 'newAction', 'newObstacle',
            'serializeChars', 'serializeActions0', 'serializeActions1', 'serializeActions2',
            'serializeActions3', 'serializeActions4', 'serializeObstacles', 'serializeEvents',
            'deserializeEvents', 'deserializeChars', 'calculateTurn'
        ];
        const allLoaded = requiredCircuits.every(name => !!circuitIds[name]);
        // console.log(`Checking if circuits ready: ${allLoaded}`, circuitIds);
        return allLoaded;
    };


    // --- Proof Generation Logic ---
    const onGenerateProof = async () => {
        if (!areCircuitsReady()) {
            alert('Circuits are not ready yet. Please wait.');
            return;
        }

        setGeneratingProof(true);
        setProof('');
        setProofAndInputs(null);
        setVkey('');
        setProvingTime(0);
        setStatusMessage('Generating proof...');
        setErrorMessage(null);

        try {
            console.log("Starting proof generation with circuit IDs:", circuitIds);
            // --- Replicate the logic from the original component ---

            // Helper for hex conversion
            const toHex = (x: number): string => {
                const h = x.toString(16);
                return `0x${h.length % 2 === 0 ? h : '0' + h}`;
            };

            // 1. Deserialize Initial Enemy Events
            setStatusMessage('Parsing initial events...');
            const enemy_events_parsed_result = await skpl.parse_their_events(initial_enemy_events);
            // const enemy_events_parsed_result = await executeCircuit<[boolean, Event[]]>(
            //     { fields: initial_enemy_events },
            //     circuitIds.deserializeEvents!,
            //     circuitDeserializeEvents.abi as Circuit["abi"]
            // );
            if (!enemy_events_parsed_result[0]) throw new Error("Failed to parse initial events!");
            const enemy_events_parsed = enemy_events_parsed_result[1];
            console.log("Initial enemy events parsed.");

            // // 2. Deserialize Initial Characters
            setStatusMessage('Parsing initial characters...');
            const my_chars_parse_result = await skpl.parse_characters(initial_my_chars_input, initial_my_char_actions, enemy_events_parsed_result[1], "0x00");
            //  const my_chars_parse_result = await executeCircuit<[boolean, Character[]]>(
            //     {
            //         data: initial_my_chars_input,
            //         actions_data: initial_my_char_actions,
            //         // Flatten events for the circuit input
            //         events: enemy_events_parsed.flatMap(e =>
            //             ([e.event, e.actor_id, e.subtype, e.x, e.y, e.value, e.radius] as unknown as number[])
            //             .map((p: number) => toHex(p))
            //         ),
            //         enemy_advance: "0x00" // Assuming 0 for start
            //     },
            //     circuitIds.deserializeChars!,
            //     circuitDeserializeCharacters.abi as Circuit["abi"]
            // );
            if (!my_chars_parse_result[0]) throw new Error("Failed to parse initial characters!");
            const my_chars = my_chars_parse_result[1];
            console.log("Initial characters parsed.");


            // 3. Placement Phase (Update character positions)
            // These positions should ideally come from game state/user input
            my_chars[0].x = "0x09"; my_chars[0].y = "0x02";
            my_chars[1].x = "0x0b"; my_chars[1].y = "0x03";
            my_chars[2].x = "0x0c"; my_chars[2].y = "0x04";
            my_chars[3].x = "0x0a"; my_chars[3].y = "0x04";
            my_chars[4].x = "0x0a"; my_chars[4].y = "0x07";
            console.log("Character positions updated for placement.");

            // // 4. Create Obstacles
            setStatusMessage('Creating obstacles...');
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
                // executeCircuit<[boolean, Obstacle]>(
                //     { id: data.id, x: data.x, y: data.y, health: toHex(data.health), obstacle_type: data.type },
                //     circuitIds.newObstacle!, circuitNewObstacle.abi as Circuit["abi"]
                // )
            }));

            const myObstaclesParsedValid = myObstaclesParsedResults.every(result => result[0]);
            if (!myObstaclesParsedValid) throw new Error("Failed to create one or more obstacles!");
            const myObstacles = myObstaclesParsedResults.map(result => result[1]);
            console.log("Obstacles created.");

            // --- Start Timer ---
            const start = Date.now();

            // 5. Define Player Actions (Should come from UI/game logic)
            const move = "0x00"; // Assuming move 0
            const actor_id = "0x00"; // Assuming first character acts
            const actions: Action[] = [ // max 4
                { action_type: "0x01", actor_id: actor_id, target_x: "0x0a", target_y: "0x02" },
                // { action_type: "0x01", actor_id: actor_id, target_x: "0x0b", target_y: "0x02" },
                // { action_type: "0x01", actor_id: actor_id, target_x: "0x0c", target_y: "0x02" },
                { action_type: "0x03", actor_id: actor_id, target_x: "0x10", target_y: "0x03" }
            ];
            console.log("Player actions defined.");

             // 6. Serialize Inputs for Turn Calculation
            setStatusMessage('Serializing inputs...');
             // Serialize Characters and Actions (combined)
             const my_chars_input_result = await skpl.serialize_chars(my_chars);
            //  const my_chars_input_result = await executeCircuit<[Field, Field[]]>(
            //     // TODO: Ensure all Character fields are correctly formatted (hex strings)
            //     { chars: my_chars.map(c => ({ ...c /* ensure fields are hex */ })) },
            //     circuitIds.serializeChars!, circuitSerializeCharacters.abi as Circuit["abi"]
            // );
            const my_chars_input_serialized = my_chars_input_result[0];
            const my_char_actions_input_serialized = my_chars_input_result[1];

            // Serialize Obstacles
            const my_obstacles_input_serialized = await skpl.serialize_my_obstacles_for_me(myObstacles);
            // const my_obstacles_input_serialized = await executeCircuit<Field[]>(
            //     { obstacles: myObstacles },
            //     circuitIds.serializeObstacles!, circuitSerializeObstacles.abi as Circuit["abi"]
            // );

            // Serialize Actions (Using appropriate circuit - assuming serializeActions4 for 4 actions)
            // // TODO: Select the correct circuit based on `actions.length`
            const serializeActions = async (actions: Action[]) => {
              if (actions.length === 4) {
                return arenalib.serialize_actions_4(actor_id, actions);
              }
              if (actions.length === 3) {
                return arenalib.serialize_actions_3(actor_id, actions);
              }
              if (actions.length === 2) {
                return arenalib.serialize_actions_2(actor_id, actions);
              }
              if (actions.length === 1) {
                return arenalib.serialize_actions_1(actor_id, actions[0]);
              }
              if (actions.length === 0) {
                return arenalib.serialize_actions_0(actor_id);
              }
              throw new Error(`invalid action number ${actions.length}`);
            }
            const actions_input_serialized = await serializeActions(actions);
            // const actions_input_serialized = await executeCircuit<Field[]>(
            //     { actions: actions },
            //     circuitIds.serializeActions4!, // Change if action count differs
            //      circuitSerializeActions4.abi as Circuit["abi"] // Change if action count differs
            // );
            console.log("Inputs serialized.");

            //  // 7. Define Enemy State (Placeholders - should come from game state)
            const enemy_advance = "0x00";
            const enemy_objects = ["0x00", "0x00", "0x00", "0x00"]; // Placeholder

            // // 8. Calculate Turn Result
            setStatusMessage('Calculating turn...');
            const turnResult = await skpl.calculate_turn(
              my_chars_input_serialized,
              my_char_actions_input_serialized,
              my_obstacles_input_serialized,
              actions_input_serialized,
              move,
              enemy_advance,
              enemy_objects,
              initial_enemy_events);
            // const turnResult = await executeCircuit<[boolean, Field, Field[], Obstacle[], u8, Field[], Field[]]>(
            //     {
            //         my_chars_input: my_chars_input_serialized,
            //         my_char_actions_input: my_char_actions_input_serialized,
            //         my_obstacles_input: my_obstacles_input_serialized,
            //         actions_input: actions_input_serialized,
            //         move_input: move,
            //         enemy_advance_input: enemy_advance,
            //         enemy_objects_input: enemy_objects,
            //         enemy_events_input: enemy_events_parsed // Use parsed events
            //     },
            //     circuitIds.calculateTurn!, circuitCalculateTurn.abi as Circuit["abi"]
            // );

            if (!turnResult[0]) throw new Error("Turn calculation failed!");

            const my_result_chars_serialized = turnResult[1];
            const my_result_char_actions_serialized = turnResult[2];
            const my_result_obstacles = turnResult[3]; // Note: This is Obstacle[], not serialized Field[]
            const my_result_advance = turnResult[4];
            const my_result_events_serialized = turnResult[5];
            const my_result_objects_serialized = turnResult[6];
            console.log("Turn calculated.");

             // 9. Calculate State Hashes
            setStatusMessage('Calculating state hashes...');
             // Serialize the resulting obstacles before hashing
            // const my_result_obstacles_serialized = await executeCircuit<Field[]>(
            //     { obstacles: my_result_obstacles },
            //     circuitIds.serializeObstacles!, circuitSerializeObstacles.abi as Circuit["abi"]
            // );

            const initial_hash = await skpl.hash_serialized_private_state(my_chars_input_serialized, my_char_actions_input_serialized, my_obstacles_input_serialized, secret);
            // const initial_hash = await executeCircuit<Field>(
            //     {
            //         my_chars: my_chars_input_serialized,
            //         my_char_actions: my_char_actions_input_serialized,
            //         my_obstacles: my_obstacles_input_serialized,
            //         secret: secret
            //     },
            //     circuitIds.hashPrivateState!, circuitHashPrivateState.abi as Circuit["abi"]
            // );
            const my_result_obstacles_serialized = await skpl.serialize_my_obstacles_for_me(my_result_obstacles);

            const result_hash = await skpl.hash_serialized_private_state(my_result_chars_serialized, my_result_char_actions_serialized, my_result_obstacles_serialized, secret);
            // const result_hash = await executeCircuit<Field>(
            //     {
            //         my_chars: my_result_chars_serialized,
            //         my_char_actions: my_result_char_actions_serialized,
            //         my_obstacles: my_result_obstacles_serialized, // Use serialized result obstacles
            //         secret: secret
            //     },
            //     circuitIds.hashPrivateState!, circuitHashPrivateState.abi as Circuit["abi"]
            // );
            console.log("State hashes calculated.");

            // 10. Prepare Arguments for Proof Generation
             setStatusMessage('Preparing proof arguments...');
             const proofArgs = {
                secret,
                my_chars_input: my_chars_input_serialized,
                my_char_actions: my_char_actions_input_serialized,
                my_obstacles_input: my_obstacles_input_serialized, // Serialized Field[]
                actions: actions_input_serialized, // Serialized actions Field[]
                move,
                enemy_advance,
                enemy_objects, // Serialized Field[]
                enemy_events: initial_enemy_events, // Parsed Event[] - Circuit needs correct type
                my_result_advance,
                my_result_events: my_result_events_serialized, // Serialized Field[]
                my_result_objects: my_result_objects_serialized, // Serialized Field[]
                gamestate_before_hash: initial_hash,
                gamestate_after_hash: result_hash,
            };
             console.log("Proof arguments prepared:", proofArgs);

            //  // OPTIONAL: Execute test circuit first (if needed for debugging)
            //  setStatusMessage('Executing test circuit...');
            //  const testArgsValid = await executeCircuit<boolean>(proofArgs, circuitIds.test!, circuitTest.abi as Circuit["abi"]);
            //  if (!testArgsValid) {
            //      throw new Error("The provided arguments are invalid for the Turn test circuit");
            //  }
            //   console.log("Test circuit executed successfully.");


             // 11. Generate Proof
            setStatusMessage('Generating ZK proof...');
            // const proofWithPublicInputs = await generateProof()
            // const proofWithPublicInputs = await skp(secret, my_chars_input_serialized, my_char_actions_input_serialized, my_obstacles_input_serialized, actions_input_serialized, move, enemy_advance, enemy_objects, initial_enemy_events, my_result_advance, my_result_objects_serialized, my_result_events_serialized, initial_hash, result_hash)
             const proofWithPublicInputs = await generateProof(
                proofArgs,
                circuitIds.proof!, // Use the actual proof circuit ID
                circuitProof.abi as Circuit["abi"] // Use the actual proof circuit ABI
            );

            const end = Date.now();
            const duration = end - start;
            setProvingTime(duration);
            setProofAndInputs(proofWithPublicInputs);

            // const extracted = extractProof(circuitProof as unknown as Circuit, proofWithPublicInputs);
            setProof(proofWithPublicInputs.proof);
             console.log("Proof generated successfully.", { duration });

            // 12. Get Verification Key (Optional)
            //  setStatusMessage('Fetching verification key...');
            //  try{
            //      const _vkey = await getVerificationKey(circuitIds.proof!);
            //      setVkey(_vkey);
            //       console.log("Verification key fetched.");
            //  } catch (vkError) {
            //      console.warn("Could not fetch verification key:", vkError);
            //      // Non-fatal, verification might still work if key is not needed client-side by verifyProof
            //  }


            setStatusMessage(`Proof generated successfully in ${duration} ms.`);

        } catch (err: any) {
            console.error("Proof generation failed:", err);
            setProof('');
            setProofAndInputs(null);
            setErrorMessage(`Proof Generation Error: ${err.message || JSON.stringify(err)}`);
            setStatusMessage(null);
        } finally {
            setGeneratingProof(false);
        }
    };

    // --- Proof Verification Logic ---
    const onVerifyProof = async () => {
         if (!circuitIds.proof) {
            alert('Proof circuit not ready.');
            return;
        }
        if (!proofAndInputs) {
            alert('No proof has been generated yet.');
            return;
        }

        setVerifyingProof(true);
        setStatusMessage('Verifying proof...');
        setErrorMessage(null);

        try {
             console.log("Verifying proof with ID:", circuitIds.proof);
             // Note: Some implementations of verifyProof might need the VK, others might use the circuitId to retrieve it internally.
            // Adjust the call based on your specific noir library's verifyProof signature.
            const verified = await verifyProof(
                proofAndInputs,
                // vkey, // Pass VKey if required by your library's verifyProof
                circuitIds.proof!
            );

             console.log("Verification result:", verified);
            if (verified) {
                setStatusMessage('Proof verified successfully!');
                alert('Verification Result: The proof is valid!');
            } else {
                setStatusMessage('Proof verification failed.');
                alert('Verification Result: The proof is invalid');
            }
        } catch (err: any) {
            console.error("Verification failed:", err);
            setErrorMessage(`Verification Error: ${err.message || JSON.stringify(err)}`);
            setStatusMessage('Verification failed.');
        } finally {
            setVerifyingProof(false);
        }
    };

    // --- Render Logic ---
    const circuitsLoaded = areCircuitsReady();

    return (
        <div style={styles.container}>
            <h1>SKP Proof Generation (Web)</h1>

            {/* Status and Error Messages */}
            {statusMessage && <p style={styles.status}>{statusMessage}</p>}
            {errorMessage && <p style={styles.error}>{errorMessage}</p>}
             {!circuitsLoaded && !errorMessage && <p style={styles.status}>Loading circuits...</p>}


            {/* Proof Generation Button */}
            {!proof && (
                <button
                    style={styles.button}
                    onClick={onGenerateProof}
                    disabled={generatingProof || !circuitsLoaded}
                >
                    {generatingProof ? 'Generating Proof...' : (circuitsLoaded ? 'Generate SKP Proof' : 'Circuits Loading...')}
                </button>
            )}

            {/* Proof Display and Verification */}
            {proof && (
                <div style={styles.resultsContainer}>
                    <h2>Proof Generated</h2>
                    {provingTime > 0 && (
                        <p style={styles.info}>Proving time: {provingTime} ms</p>
                    )}
                     <p style={styles.info}>Proof:</p>
                    <pre style={styles.proofBox}>{formatProof(proof)}</pre>

                    {/* Verification Button */}
                    <button
                        style={styles.button}
                        onClick={onVerifyProof}
                        disabled={verifyingProof || !circuitsLoaded}
                    >
                        {verifyingProof ? 'Verifying...' : 'Verify Proof'}
                    </button>

                     {/* Reset Button */}
                     <button
                        style={{...styles.button, ...styles.secondaryButton}}
                        onClick={() => {
                             setProof('');
                             setProofAndInputs(null);
                             setVkey('');
                             setProvingTime(0);
                             setStatusMessage('Circuits ready.');
                             setErrorMessage(null);
                        }}
                        disabled={generatingProof || verifyingProof}
                    >
                        Generate New Proof
                    </button>

                    {/* Optional: Display VKey */}
                    {/* {vkey && (
                        <>
                            <p style={styles.info}>Verification Key:</p>
                            <pre style={styles.proofBox}>{formatProof(vkey)}</pre>
                        </>
                    )} */}
                </div>
            )}
        </div>
    );
}

// Basic CSS-in-JS for styling (replace with your preferred styling method)
const styles: { [key: string]: React.CSSProperties } = {
    container: {
        fontFamily: 'sans-serif',
        padding: '20px',
        maxWidth: '800px',
        margin: '0 auto',
        border: '1px solid #ccc',
        borderRadius: '8px',
        backgroundColor: '#f9f9f9',
    },
    status: {
        color: '#333',
        fontStyle: 'italic',
        textAlign: 'center',
        marginBottom: '15px',
    },
    error: {
        color: 'red',
        fontWeight: 'bold',
        textAlign: 'center',
        marginBottom: '15px',
        border: '1px solid red',
        padding: '10px',
        borderRadius: '4px',
        backgroundColor: '#ffeeee',
    },
    button: {
        display: 'block',
        width: '100%',
        padding: '12px 20px',
        fontSize: '16px',
        fontWeight: 'bold',
        color: 'white',
        backgroundColor: '#007bff',
        border: 'none',
        borderRadius: '4px',
        cursor: 'pointer',
        marginBottom: '10px',
        transition: 'background-color 0.2s ease',
    },
    secondaryButton: {
        backgroundColor: '#6c757d',
    },
    // Add hover/disabled styles inline or via CSS classes
    // button:disabled { opacity: 0.6; cursor: not-allowed; }
    // button:hover:not(:disabled) { background-color: #0056b3; }
    resultsContainer: {
        marginTop: '25px',
        paddingTop: '15px',
        borderTop: '1px solid #eee',
    },
    info: {
        color: '#555',
        marginBottom: '5px',
    },
    proofBox: {
        backgroundColor: '#eee',
        border: '1px solid #ddd',
        padding: '10px',
        borderRadius: '4px',
        overflowX: 'auto', // Handle long strings
        whiteSpace: 'pre-wrap', // Wrap long lines
        wordBreak: 'break-all', // Break long words/hex strings
        fontSize: '12px',
        marginBottom: '15px',
    }
};


export default SkpProofComponent; // Export the new component