import React, { useEffect, useState, useRef } from 'react'; // Add useRef


import * as skpl from '../logic/skpl/index';
import * as arenalib from '../logic/arenalib/index';

// --- Noir Library Imports (ASSUMED - Update path as needed) ---
import {
  clearCircuit,
  executeCircuit,
  // extractProof,
  // generateProof,
  // getVerificationKey,
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


const isDev = true; //import.meta.env.DEV;
const proverHtmlSrc = isDev ? '/src/prover/prover.html' : '/prover.html';

// Placeholder for the formatProof function if not available
const formatProof = (proof: string): string => {
    if (!proof) return '';
    // Simple formatting: show first and last few characters
    const maxLength = 60;
    if (proof.length <= maxLength) return proof;
    return `${proof.substring(0, maxLength / 2)}...${proof.substring(proof.length - maxLength / 2)}`;
}

// ... (keep types: Circuit, Action, Character, etc.)
// ... (keep circuit imports)
// ... (keep hardcoded data: secret, initial inputs etc.)
// ... (keep formatProof function)

// --- The React Component ---
const SkpProofComponent= () => {
    // Keep existing state: proof, vkey, generatingProof, verifyingProof, etc.
    const [proofDataForVerification, setProofDataForVerification] = useState<{ proof: string; publicInputs: string[]; } | null>(null); // Store proof object
    const [proof, setProof] = useState('');
    const [vkey, setVkey] = useState('');
    const [generatingProof, setGeneratingProof] = useState(false);
    const [verifyingProof, setVerifyingProof] = useState(false);
    const [provingTime, setProvingTime] = useState(0);
    const [statusMessage, setStatusMessage] = useState<string | null>(null);
    const [errorMessage, setErrorMessage] = useState<string | null>(null);
    const [circuitIds, setCircuitIds] = useState<Record<string, string | undefined>>({});
    const [proverReady, setProverReady] = useState(false); // Track iframe readiness

    const iframeRef = useRef<HTMLIFrameElement>(null); // Ref for the iframe

    // --- Circuit Setup Effect (Keep as is) ---
    useEffect(() => {
      // ... (circuit setup logic remains the same) ...
      // It's okay to set up circuits here, the iframe will use the JSON directly
        let mounted = true;
        const setupAllCircuits = async () => {
           // ... (same setup logic using setupCircuit from noir.ts)
            setStatusMessage('Setting up circuits...');
            const circuitsToSetup: { name: string; circuit: Circuit }[] = [
                { name: 'test', circuit: circuitTest as unknown as Circuit },
                { name: 'proof', circuit: circuitProof as unknown as Circuit },
                 // Add all other circuits needed for execution logic BEFORE proof gen
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
            const ids: Record<string, string> = {};
             try {
                for (const { name, circuit } of circuitsToSetup) {
                     // Use the setupCircuit from the MAIN thread's noir.ts
                     // This might only be needed if verification or other steps happen here.
                     // If *everything* is in the iframe, this might not be strictly necessary.
                     const id = await setupCircuit(circuit);
                     if (!mounted) { clearCircuit(id); return; }
                     ids[name] = id;
                     console.log(`Main Thread: Circuit ${name} setup with ID: ${id}`);
                }
                 if (mounted) {
                     setCircuitIds(ids);
                     setStatusMessage('Circuits ready.');
                     console.log('Main Thread: All circuits set up:', ids);
                 }
             } catch (error) {
                // ... (error handling)
                console.error("Circuit setup failed:", error);
                 if (mounted) {
                    setErrorMessage(`Circuit setup failed: ${error instanceof Error ? error.message : String(error)}`);
                     setStatusMessage(null);
                 }
                 Object.values(ids).forEach(id => clearCircuit(id));
             }
        };
        setupAllCircuits();
        return () => {
            mounted = false;
            // ... (cleanup logic remains the same) ...
             console.log('Cleaning up circuits...');
             Object.values(circuitIds).forEach(id => {
                 if (id) {
                     console.log(`Main Thread: Clearing circuit ID: ${id}`);
                     clearCircuit(id); // Use the main thread's clearCircuit
                 }
             });
             setCircuitIds({});
             console.log('Circuit cleanup complete.');
        };
    }, []);

    // --- Effect for Iframe Communication ---
    useEffect(() => {
            // IMPORTANT: Validate origin for security
            // if (event.origin !== 'http://localhost:3000') { // Replace with your origin
            //     // console.warn(`Message rejected from origin: ${event.origin}`);
            //     return;
            // }
            const handleMessage = (event: MessageEvent) => {
              // --- STRONGER VALIDATION ---
              // 1. Validate Origin (Replace 'YOUR_APP_ORIGIN'!)
              const expectedOrigin = window.location.origin; // Or specific origin if different
              if (event.origin !== expectedOrigin) {
                   // console.log(`Ignoring message from origin: ${event.origin}`);
                   return;
              }
      
              // 2. Check if data exists and has a 'type' property
              if (!event.data || typeof event.data.type !== 'string') {
                  // console.log("Ignoring message with invalid structure:", event.data);
                  return; // Ignore messages without a string 'type'
              }
            // Ensure the message is structured as expected
             if (!event.data || typeof event.data !== 'object') {
                 console.warn("Received non-object message:", event.data);
                 return;
             }

            const { type, payload } = event.data;
            console.log("Main window received message:", type, payload);

            switch (type) {
                case 'proverReady':
                    setProverReady(true);
                    setStatusMessage(status => (status === 'Loading prover...' ? 'Prover ready.' : status));
                    break;
                case 'statusUpdate':
                    setStatusMessage(payload.message);
                    break;
                case 'proofGenerated':
                    if (payload?.proofData) { // Add null check
                      setGeneratingProof(false);
                      setStatusMessage(`Proof generated successfully in ${payload.provingTime || '?'} ms.`);
                      setProof(payload.proofData.proof);
                      setProofDataForVerification({
                          proof: payload.proofData.proof,
                          publicInputs: payload.proofData.publicInputs || [] // Add null check/default
                      });
                      setProvingTime(payload.provingTime || 0);
                      setErrorMessage(null);
                  } else {
                      console.error("Received proofGenerated message with invalid payload:", payload);
                      setErrorMessage("Internal error: Invalid proof data received.");
                  }
                    break;
                case 'proofError':
                    setGeneratingProof(false);
                    setErrorMessage(`Proof Generation Error (from prover): ${payload?.message || 'Unknown error'}`); // Add null check
                    setStatusMessage(null);
                    setProof('');
                    setProofDataForVerification(null);
                default:
                    console.warn("Received unknown message type:", type);
            }
        };

        window.addEventListener('message', handleMessage);
        console.log("Main window message listener added.");

        // Optional: Add a timeout to check if prover becomes ready
        const timer = setTimeout(() => {
             if (!proverReady) {
                 setStatusMessage(status => status === 'Setting up circuits...' ? 'Loading prover...' : status);
                 console.warn("Prover iframe did not signal readiness.");
             }
        }, 5000); // 5 seconds timeout

        return () => {
            window.removeEventListener('message', handleMessage);
             clearTimeout(timer);
            console.log("Main window message listener removed.");
        };
    }, [proverReady]); // Rerun if proverReady changes, though listener itself doesn't depend on it

    const areCircuitsReady = (): boolean => {
         // Keep this check if setupCircuit is still used in the main thread
         const requiredCircuits = ['proof']; // Only need proof ID for verifyProof now
         return requiredCircuits.every(name => !!circuitIds[name]);
    };


    // --- Modified Proof Generation Logic ---
    const onGenerateProof = async () => {
        // No need to check areCircuitsReady for *generation* anymore
        if (!proverReady || !iframeRef.current || !iframeRef.current.contentWindow) {
             alert('Prover iframe is not ready yet. Please wait.');
             return;
         }

        setGeneratingProof(true);
        setProof('');
        setProofDataForVerification(null);
        setVkey('');
        setProvingTime(0);
        setStatusMessage('Preparing data for prover...');
        setErrorMessage(null);

        try {
            console.log("Preparing data and sending to prover iframe...");
            const startPrep = Date.now(); // Timer for prep phase

            // --- Perform all the steps *before* generateProof here ---
            // This includes deserialization, execution of intermediate circuits, etc.
            // If these steps are *also* slow, they might need optimization or moving to the iframe too.

            // Helper for hex conversion (can remain here)
            const toHex = (x: number): string => {
              const h = x.toString(16);
              return `0x${h.length % 2 === 0 ? h : '0' + h}`;
          };

            // 1. Deserialize Initial Enemy Events (using main thread noir.ts or direct functions)
             setStatusMessage('Parsing initial events...');
             const enemy_events_parsed_result = await skpl.parse_their_events(initial_enemy_events);
             if (!enemy_events_parsed_result[0]) throw new Error("Failed to parse initial events!");
             const enemy_events_parsed = enemy_events_parsed_result[1];

            // 2. Deserialize Initial Characters
             setStatusMessage('Parsing initial characters...');
            const my_chars_parse_result = await skpl.parse_characters(initial_my_chars_input, initial_my_char_actions, enemy_events_parsed_result[1], "0x00");
             if (!my_chars_parse_result[0]) throw new Error("Failed to parse NFT characters");
             const my_chars = my_chars_parse_result[1];

             // 3. Placement Phase
             my_chars[0].x = "0x09"; my_chars[0].y = "0x02";
             my_chars[1].x = "0x0b"; my_chars[1].y = "0x03";
             my_chars[2].x = "0x0c"; my_chars[2].y = "0x04";
             my_chars[3].x = "0x0a"; my_chars[3].y = "0x04";
             my_chars[4].x = "0x0a"; my_chars[4].y = "0x07";

            // 4. Create Obstacles
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
             if (!myObstaclesParsedResults.every(r => r[0])) throw new Error("Failed to create obstacles!");
             const myObstacles = myObstaclesParsedResults.map(r => r[1]);

            // 5. Define Player Actions
                        const move = "0x00"; // Assuming move 0
                        const actor_id = "0x00"; // Assuming first character acts
                        const actions: Action[] = [ // max 4
                            { action_type: "0x01", actor_id: actor_id, target_x: "0x0a", target_y: "0x02" },
                            // { action_type: "0x01", actor_id: actor_id, target_x: "0x0b", target_y: "0x02" },
                            // { action_type: "0x01", actor_id: actor_id, target_x: "0x0c", target_y: "0x02" },
                            { action_type: "0x03", actor_id: actor_id, target_x: "0x10", target_y: "0x03" }
                        ];

            // 6. Serialize Inputs for Turn Calculation
             setStatusMessage('Serializing inputs...');
             const my_chars_input_result = await skpl.serialize_chars(my_chars);
             const my_chars_input_serialized = my_chars_input_result[0];
             const my_char_actions_input_serialized = my_chars_input_result[1];
             const my_obstacles_input_serialized = await skpl.serialize_my_obstacles_for_me(myObstacles);
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

            // 7. Define Enemy State
             const enemy_advance = "0x00";
             const enemy_objects = ["0x00", "0x00", "0x00", "0x00"];

            // 8. Calculate Turn Result
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
             if (!turnResult[0]) throw new Error("Turn calculation failed!");
             const [ , my_result_chars_serialized, my_result_char_actions_serialized, my_result_obstacles, my_result_advance, my_result_events_serialized, my_result_objects_serialized] = turnResult;

            // 9. Calculate State Hashes
             setStatusMessage('Calculating state hashes...');
             const my_result_obstacles_serialized = await skpl.serialize_my_obstacles_for_me(my_result_obstacles);
             const initial_hash = await skpl.hash_serialized_private_state(my_chars_input_serialized, my_char_actions_input_serialized, my_obstacles_input_serialized, secret);
             const result_hash = await skpl.hash_serialized_private_state(my_result_chars_serialized, my_result_char_actions_serialized, my_result_obstacles_serialized, secret);

            // 10. Prepare Arguments for Proof Generation
             const proofArgs = {
                 secret,
                 my_chars_input: my_chars_input_serialized,
                 my_char_actions: my_char_actions_input_serialized,
                 my_obstacles_input: my_obstacles_input_serialized,
                 actions: actions_input_serialized,
                 move,
                 enemy_advance,
                 enemy_objects,
                 enemy_events: initial_enemy_events, // Pass the initial string array format expected by the circuit
                 my_result_advance,
                 my_result_events: my_result_events_serialized,
                 my_result_objects: my_result_objects_serialized,
                 gamestate_before_hash: initial_hash,
                 gamestate_after_hash: result_hash,
             };
            const endPrep = Date.now();
            console.log(`Data preparation took ${endPrep - startPrep} ms`);
            setStatusMessage('Sending data to prover iframe...');

            // --- Send data to iframe ---
            iframeRef.current.contentWindow.postMessage({
                type: 'generateProof',
                payload: {
                    // Pass the actual circuit JSON for the proof circuit
                    circuitJson: circuitProof as Circuit, // Pass the imported JSON
                    inputs: proofArgs,
                    abi: circuitProof.abi as Circuit["abi"] // Pass the ABI needed by iframe's serializeArguments
                }
            }, '*'); // Use '*' for simplicity, or better: targetOrigin based on iframe src

        } catch (err: any) {
            console.error("Error preparing data for proof generation:", err);
            setGeneratingProof(false); // Stop loading indicator
            setErrorMessage(`Data Preparation Error: ${err.message || JSON.stringify(err)}`);
            setStatusMessage(null);
        }
        // No finally block setting generatingProof=false here, it's handled by messages
    };

    // --- Proof Verification Logic (Keep using main thread noir.ts) ---
    const onVerifyProof = async () => {
        // Check if the proof circuit was set up in the main thread
         if (!circuitIds.proof) {
            alert('Proof circuit setup not found in main thread.');
             return;
         }
         if (!proofDataForVerification) {
             alert('No proof has been generated or received yet.');
             return;
         }

        setVerifyingProof(true);
        setStatusMessage('Verifying proof...');
        setErrorMessage(null);

        try {
            // Use verifyProof from main thread's noir.ts adapter
            // It expects the { proof: string, publicInputs: Map } structure
             const verified = await verifyProof(
                 proofDataForVerification, // Pass the object containing hex proof and Map
                 circuitIds.proof!
             );

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

    // --- Render Logic (Mostly the same) ---
    const circuitsLoadedForVerification = areCircuitsReady(); // Check if needed circuits are ready for verification

    return (
        <div style={styles.container}>
            {/* Render the iframe (hidden) */}
            <iframe
     ref={iframeRef}
     src={proverHtmlSrc} // Use dynamic source
     style={{ display: 'none' }}
    title="Prover Frame"
/>

            <h1>SKP Proof Generation (Web Multi-Threaded via iframe)</h1>

            {/* Status and Error Messages */}
            {statusMessage && <p style={styles.status}>{statusMessage}</p>}
            {errorMessage && <p style={styles.error}>{errorMessage}</p>}
             {!proverReady && !errorMessage && <p style={styles.status}>Loading prover...</p>}

            {/* Proof Generation Button */}
            {!proof && (
                <button
                    style={styles.button}
                    onClick={onGenerateProof}
                    // Disable button until iframe is ready AND while generating
                    disabled={generatingProof || !proverReady}
                >
                    {generatingProof ? 'Generating Proof...' : (proverReady ? 'Generate SKP Proof' : 'Prover Loading...')}
                </button>
            )}

            {/* Proof Display and Verification */}
            {proof && (
                <div style={styles.resultsContainer}>
                    <h2>Proof Generated</h2>
                    {provingTime > 0 && (
                        <p style={styles.info}>Proving time (in prover iframe): {String(provingTime)} ms</p>
                    )}
                     <p style={styles.info}>Proof:</p>
                    <pre style={styles.proofBox}>{formatProof(proof)}</pre>

                    {/* Verification Button */}
                    <button
                        style={styles.button}
                        onClick={onVerifyProof}
                         // Disable based on verifying state AND if verification circuits aren't ready
                        disabled={verifyingProof || !circuitsLoadedForVerification}
                    >
                        {verifyingProof ? 'Verifying...' : (circuitsLoadedForVerification ? 'Verify Proof' : 'Verification Setup Loading...')}
                    </button>

                    {/* Reset Button */}
                     <button
                        style={{...styles.button, ...styles.secondaryButton}}
                        onClick={() => {
                             setProof('');
                             setProofDataForVerification(null);
                             setVkey('');
                             setProvingTime(0);
                             setStatusMessage(proverReady ? 'Prover ready.' : 'Loading prover...');
                             setErrorMessage(null);
                        }}
                        disabled={generatingProof || verifyingProof}
                    >
                        Generate New Proof
                    </button>
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

export default SkpProofComponent;