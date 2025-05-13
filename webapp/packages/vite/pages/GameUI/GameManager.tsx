// GameManager.tsx
import React, { useState, useEffect, useCallback, useRef } from 'react';
import SetupPhaseUI from './SetupPhaseUI';
import GamePhaseUI from './GamePhaseUI';
import * as skpl from '../../logic/skpl/index'; // Your game logic functions
import * as arenalib from '../../logic/arenalib/index';
import { Character, Obstacle, Event, Action, Field, u8 } from '../../logic/skpl'; // Your types
import { Circuit } from '../../types'; // Your types

// --- Noir Library Imports (main thread versions) ---
import {
    clearCircuit,
    setupCircuit,
    verifyProof,
} from '../../lib/noir';


const isDev = true; //import.meta.env.DEV;
const proverHtmlSrc = isDev ? '/src/prover/prover.html' : '/prover.html';

// --- Circuit JSON Imports (for main thread verification setup) ---
import circuitProof from '../../../../../circuits/circuit/target/skp.json';
// ... other circuits if needed by main thread logic (e.g., for setup verification later)

// --- Initial Game Data (as in SkpProofComponent) ---
const secret = "0x075bcd15";
const initial_my_chars_input = "0x2912640000004b03190000006c04142000008a0464000000aa47640b340a"; // Example for P1
const initial_my_char_actions = ["0x03f00001300314002000000000100300000020000000002000000000000000", "0x02f0000110071020100a000020100a00000020000000002000000000000000", "0x02f0000a3b1901002000000000000801000020000000002000000000000000", "0x023100081b161118120a010018120a01000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0x03f00001300414002000000000100300000020000000002000000000000000", "0x02f0000110071008100a000008100a00000020000000002000000000000000", "0xf0003f1b1c11002000000000000702000020000000002000000000000000", "0xff003f1b1c1100200e013f00000e013f0020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0x03f00001300314002000000000100300000020000000002000000000000000", "0x02f0000110071018100a000018100a00000020000000002000000000000000", "0x09f0000130060c002000000000200000000020000000002000000000000000", "0xf00001100610001005000100100500010020000000002000000000000000", "0xf00001301c0100100d000000100d00000020000000002000000000000000", "0x0bf00001100c00002000000000200000000010040a00002000000000000000", "0x03f00001300414002000000000100300000020000000002000000000000000", "0x02f0000110061028100a000028100a00000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0x03f00001300414002000000000100300000020000000002000000000000000", "0x02f0000110071010100a000010100a00000020000000002000000000000000", "0xf000071b1611002000000000000705000020000000002000000000000000", "0x6300061b161164150a020164150a02010020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000", "0xf0003f000001002000000000200000000020000000002000000000000000"];
// Potentially have different initial inputs/actions for P2 if asymmetric
const initial_enemy_events_for_first_player = ["0x04ffff0000000004ffff0000000004ffff0000000004ffff000000000000"];
const initial_enemy_advance_for_first_player = "0x00";
const initial_enemy_objects_for_first_player = ["0x00", "0x00", "0x00", "0x00"];

// Game constants
const MAX_OBSTACLES_PER_PLAYER = 24;
const GRID_WIDTH = 10;
const GRID_HEIGHT = 10;
const MAX_CHARS_PER_PLAYER = 5;
const TURN_ENERGY = 12;
const MAP_WIDTH = 32; // Full map width
const MAP_HEIGHT = 10; // Full map height
const FOG_ADVANCE_RANGE = 6;

// Helper to convert number to hex (from your code)
const toHex = (x: number): string => {
    const h = x.toString(16);
    return `0x${h.length % 2 === 0 ? h : '0' + h}`;
};


// Define player states more explicitly
interface PlayerSetup {
    characters: Character[];
    obstacles: Obstacle[];
    isDone: boolean;
}

interface PlayerTurnData {
    proof: string;
    // publicInputs: string[]; // Or Map<number, string> depending on your noir.ts adapter
    publicInputs: Map<number, string>;
    gamestate_before_hash: Field;
    gamestate_after_hash: Field;
    result_events: Field[]; // Serialized events
    result_objects: Field[]; // Serialized objects
    result_advance: u8;
    move_number: number;
}

enum GamePhase {
    SETUP_P1,
    SETUP_P2,
    GAME_P1_RECEIVE,
    GAME_P1_ACTION,
    GAME_P1_PROVE,
    GAME_P2_RECEIVE,
    GAME_P2_ACTION,
    GAME_P2_PROVE,
    GAME_OVER,
}

const serializeActions = async (actor_id: number, actions: Action[]) => {
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

const GameManager: React.FC = () => {
    const [gamePhase, setGamePhase] = useState<GamePhase>(GamePhase.SETUP_P1);
    const [player1Setup, setPlayer1Setup] = useState<PlayerSetup | null>(null);
    const [player2Setup, setPlayer2Setup] = useState<PlayerSetup | null>(null);

    // State to hold the loaded initial characters
    const [player1InitialChars, setPlayer1InitialChars] = useState<Character[] | null>(null);
    const [player2InitialChars, setPlayer2InitialChars] = useState<Character[] | null>(null);
    const [loadingInitialChars, setLoadingInitialChars] = useState(true); // Loading indicator

        // Current game state for the active player
    const [currentMoveNumber, setCurrentMoveNumber] = useState(0);
    const [myCharacters, setMyCharacters] = useState<Character[]>([]);
    const [myObstacles, setMyObstacles] = useState<Obstacle[]>([]); // These are the player's *own* placed obstacles
    const [mySerializedChars, setMySerializedChars] = useState<Field>("");
    const [mySerializedCharActions, setMySerializedCharActions] = useState<Field[]>([]);
    const [mySerializedObstacles, setMySerializedObstacles] = useState<Field[]>([]);


    // Data received from opponent
    const [enemyEventsInput, setEnemyEventsInput] = useState<Field[]>(initial_enemy_events_for_first_player);
    const [enemyAdvanceInput, setEnemyAdvanceInput] = useState<u8>(initial_enemy_advance_for_first_player);
    const [enemyObjectsInput, setEnemyObjectsInput] = useState<Field[]>(initial_enemy_objects_for_first_player);

    // Data to send to opponent
    const [dataForOpponent, setDataForOpponent] = useState<PlayerTurnData | null>(null);

    // UI/Prover State
    const [statusMessage, setStatusMessage] = useState<string | null>(null);
    const [errorMessage, setErrorMessage] = useState<string | null>(null);
    const [proverReady, setProverReady] = useState(false);
    const [generatingProof, setGeneratingProof] = useState(false);
    const iframeRef = useRef<HTMLIFrameElement>(null);

    // Circuit IDs for main thread (e.g., verification)
    const [circuitProofId, setCircuitProofId] = useState<string | null>(null);

    // --- Prover Iframe Communication (Copied & Adapted from SkpProofComponent) ---
    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            const expectedOrigin = window.location.origin;
            if (event.origin !== expectedOrigin) return;
            if (!event.data || typeof event.data.type !== 'string') return;

            const { type, payload } = event.data;
            switch (type) {
                case 'proverReady':
                    setProverReady(true);
                    setStatusMessage('Prover ready.');
                    break;
                case 'statusUpdate':
                    setStatusMessage(payload?.message || 'Status...');
                    break;
                case 'proofGenerated':
                    setGeneratingProof(false);
                    if (payload?.proofData) {
                        setStatusMessage(`Proof generated in ${payload.provingTime || '?'} ms.`);
                        const newTurnData: PlayerTurnData = {
                            proof: payload.proofData.proof,
                            publicInputs: new Map(payload.proofData.publicInputs || []),
                            gamestate_before_hash: payload.proofData.gamestate_before_hash, // Prover needs to send these back
                            gamestate_after_hash: payload.proofData.gamestate_after_hash,   // Prover needs to send these back
                            result_events: payload.proofData.result_events,                 // Prover needs to send these back
                            result_objects: payload.proofData.result_objects,               // Prover needs to send these back
                            result_advance: payload.proofData.result_advance,               // Prover needs to send these back
                            move_number: currentMoveNumber,
                        };
                        setDataForOpponent(newTurnData);
                        // Transition to next phase (e.g., switch player)
                        handleProofGenerated(newTurnData);
                    } else {
                      console.error("Received proofGenerated message with invalid payload:", payload);
                      setErrorMessage("Internal error: Invalid proof data received.");
                    }
                    break;
                case 'proofError':
                    setGeneratingProof(false);
                    setErrorMessage(`Prover Error: ${payload?.message || 'Unknown'}`);
                    break;
            }
        };
        window.addEventListener('message', handleMessage);
        const timer = setTimeout(() => { if (!proverReady) console.warn("Prover not ready"); }, 5000);
        return () => { window.removeEventListener('message', handleMessage); clearTimeout(timer); };
    }, [proverReady, currentMoveNumber]); // Added currentMoveNumber

    // useEffect to load data when the component mounts
useEffect(() => {
  const loadInitialCharacterData = async () => {
      setLoadingInitialChars(true); // Start loading
      try {
          console.log("GameManager: Loading initial character data...");
          // For Player 1
          const [eventsValidP1, eventsP1] = await skpl.parse_their_events(initial_enemy_events_for_first_player);
          if (!eventsValidP1) throw new Error("Failed to parse initial events for P1 chars");
          const [validP1, charsP1] = await skpl.parse_characters(
               initial_my_chars_input, // Assuming this is for P1
               initial_my_char_actions, // Assuming this is for P1
               eventsP1,
               initial_enemy_advance_for_first_player
          );
          if (validP1) setPlayer1InitialChars(charsP1);
          else console.error("Failed to parse P1 initial characters");

          // For Player 2 (assuming symmetrical for now, or use different initial inputs)
          const [eventsValidP2, eventsP2] = await skpl.parse_their_events(initial_enemy_events_for_first_player); // Or different P2 events
          if (!eventsValidP2) throw new Error("Failed to parse initial events for P2 chars");
          const [validP2, charsP2] = await skpl.parse_characters(
               initial_my_chars_input, // Or P2 specific input
               initial_my_char_actions, // Or P2 specific actions
               eventsP2,
               initial_enemy_advance_for_first_player
          );
          if (validP2) setPlayer2InitialChars(charsP2);
          else console.error("Failed to parse P2 initial characters");

          console.log("GameManager: Initial character data loaded.");
      } catch (error) {
          console.error("Error loading initial character data:", error);
          setErrorMessage(`Failed to load initial game data: ${error instanceof Error ? error.message : String(error)}`);
      } finally {
          setLoadingInitialChars(false); // Finish loading
      }
  };
  loadInitialCharacterData();
}, []); // Empty dependency array: run once on mount

    // --- Setup Verification Circuit (main thread) ---
    useEffect(() => {
        setupCircuit(circuitProof as unknown as Circuit)
            .then(id => setCircuitProofId(id))
            .catch(err => setErrorMessage(`Failed to setup verification circuit: ${err}`));
        return () => { if (circuitProofId) clearCircuit(circuitProofId); };
    }, []); // Empty dependency array - run once

    // --- Handler for when setup is complete for a player ---
    const handleSetupComplete = useCallback(async (player: 1 | 2, characters: Character[], obstacles: Obstacle[]) => {
        setStatusMessage(`Player ${player} setup complete. Processing...`);
        try {
            // TODO: Later, implement verify_setup function call here
            // For now, just store it
            const setupData: PlayerSetup = { characters, obstacles, isDone: true };
            if (player === 1) {
                setPlayer1Setup(setupData);
                // Serialize P1's initial state for their first turn's "before" hash
                const [serChars, serCharActions] = await skpl.serialize_chars(characters);
                const serObstacles = await skpl.serialize_my_obstacles_for_me(obstacles);
                setMySerializedChars(serChars);
                setMySerializedCharActions(serCharActions);
                setMySerializedObstacles(serObstacles);

                setGamePhase(GamePhase.SETUP_P2);
                setStatusMessage("Player 1 setup saved. Player 2, place your pieces.");
            } else {
                setPlayer2Setup(setupData);
                setStatusMessage("Player 2 setup saved. Starting game...");
                // Both players ready, start P1's first turn (receive phase)
                setMyCharacters(player1Setup!.characters); // P1 starts
                setMyObstacles(player1Setup!.obstacles);   // P1 starts
                // Initial enemy inputs are already set for the very first turn
                setGamePhase(GamePhase.GAME_P1_RECEIVE);
            }
        } catch (error) {
            setErrorMessage(`Error processing P${player} setup: ${error}`);
        }
    }, [player1Setup]);


    // --- Handler for when a player finishes their action phase ---
    const handleActionPhaseComplete = useCallback(async (
        finalActions: Action[],
        finalMyCharacters: Character[], // Characters after local action calculations
        finalMyObstacles: Obstacle[],   // Obstacles after local action calculations
        gamestateBeforeHash: Field      // Hash from start of THIS player's turn
    ) => {
        if (!iframeRef.current || !iframeRef.current.contentWindow || !proverReady) {
            setErrorMessage("Prover not ready to generate proof.");
            return;
        }
        setGeneratingProof(true);
        setStatusMessage("Calculating final turn and generating proof...");

        const currentPlayer = (gamePhase === GamePhase.GAME_P1_ACTION) ? 1 : 2;
        const initialPlayerSetup = currentPlayer === 1 ? player1Setup : player2Setup;

        try {
            // Get initial character/obstacle state for this turn's *proof* calculation
            // These are the states *before* this turn's actions were applied.
            const [initialTurnSerChars, initialTurnSerCharActions] = await skpl.serialize_chars(
                 // This needs to be the state of *my* characters at the *start* of the current player's turn,
                 // *after* enemy effects were applied. This logic needs careful state management.
                 // For now, assuming `myCharacters` holds this state before `handleActionPhaseComplete` modifies it.
                 // Or, pass this initial state explicitly.
                 (currentPlayer === 1 && currentMoveNumber === 0) ? initialPlayerSetup!.characters : myCharacters // Simplification
            );
            const initialTurnSerObstacles = await skpl.serialize_my_obstacles_for_me(
                 (currentPlayer === 1 && currentMoveNumber === 0) ? initialPlayerSetup!.obstacles : myObstacles // Simplification
            );

            // Serialize chosen actions for the proof
            const actorId = (currentMoveNumber / 2) % MAX_CHARS_PER_PLAYER;
            const serializedTurnActions = await serializeActions(actorId, finalActions); // Generic serializer

            // 1. Calculate final turn results using Noir (should match local calculations)
            const [
                turnValid,
                finalSerChars,
                finalSerCharActions,
                _finalObs, // We already have finalMyObstacles in JS, use that for hashing
                finalAdvance,
                finalSerEvents,
                finalSerObjects,
            ] = await skpl.calculate_turn(
                initialTurnSerChars,
                initialTurnSerCharActions,
                initialTurnSerObstacles,
                serializedTurnActions,
                toHex(currentMoveNumber),
                enemyAdvanceInput,
                enemyObjectsInput,
                enemyEventsInput
            );

            if (!turnValid) throw new Error("Noir calculate_turn returned invalid.");

            // 2. Calculate "after" hash using Noir-calculated final states
            const finalSerObstaclesFromNoir = await skpl.serialize_my_obstacles_for_me(
                // We need to parse the obstacles from calculate_turn if they are different from finalMyObstacles
                // For now, assume they match. If calculate_turn modifies obstacles in a way calculate_action doesn't, this needs sync.
                finalMyObstacles
            );
            const gamestateAfterHash = await skpl.hash_serialized_private_state(
                finalSerChars,
                finalSerCharActions,
                finalSerObstaclesFromNoir,
                secret
            );

            const proofArgs = {
                secret,
                my_chars_input: initialTurnSerChars,
                my_char_actions: initialTurnSerCharActions,
                my_obstacles_input: initialTurnSerObstacles,
                actions: serializedTurnActions,
                move: toHex(currentMoveNumber),
                enemy_advance: enemyAdvanceInput,
                enemy_objects: enemyObjectsInput,
                enemy_events: enemyEventsInput,
                my_result_advance: finalAdvance,
                my_result_events: finalSerEvents,
                my_result_objects: finalSerObjects,
                gamestate_before_hash: gamestateBeforeHash,
                gamestate_after_hash: gamestateAfterHash,
            };

            iframeRef.current.contentWindow.postMessage({
                type: 'generateProof',
                payload: {
                    circuitJson: circuitProof as Circuit,
                    inputs: proofArgs,
                    abi: circuitProof.abi as Circuit["abi"],
                    // Send back these calculated values so they are part of the PlayerTurnData
                    // (or recalculate them in the iframe if proofArgs are slightly different for prover)
                    gamestate_before_hash: gamestateBeforeHash,
                    gamestate_after_hash: gamestateAfterHash,
                    result_events: finalSerEvents,
                    result_objects: finalSerObjects,
                    result_advance: finalAdvance,
                }
            }, '*');

        } catch (err) {
            setGeneratingProof(false);
            setErrorMessage(`Error in proving phase: ${err}`);
        }
    }, [
        gamePhase, currentMoveNumber, proverReady, iframeRef,
        enemyAdvanceInput, enemyEventsInput, enemyObjectsInput,
        player1Setup, player2Setup, myCharacters, myObstacles // Dependencies for initial state
    ]);


    // --- Handler for when a proof is generated ---
    const handleProofGenerated = (turnData: PlayerTurnData) => {
        setStatusMessage(`Player ${gamePhase === GamePhase.GAME_P1_PROVE ? 1 : 2} turn ${turnData.move_number} complete. Proof generated. Switching players.`);
        // Store the results that become the *next* player's inputs
        // This also becomes the *current* player's "after" state for their *next* turn's "before" hash.

        if (gamePhase === GamePhase.GAME_P1_PROVE) {
            // Player 1 finished, set up for Player 2's receive phase
            setMyCharacters(player2Setup!.characters); // P2's characters
            setMyObstacles(player2Setup!.obstacles);   // P2's obstacles
            // Update serialized state for P2's turn start
            skpl.serialize_chars(player2Setup!.characters).then(([sc, sca]) => {
                setMySerializedChars(sc);
                setMySerializedCharActions(sca);
            });
            skpl.serialize_my_obstacles_for_me(player2Setup!.obstacles).then(so => setMySerializedObstacles(so));


            setEnemyEventsInput(turnData.result_events);
            setEnemyAdvanceInput(turnData.result_advance);
            setEnemyObjectsInput(turnData.result_objects);
            // Player 2 will use Player 1's gamestate_after_hash as their gamestate_before_hash
            // This needs to be managed per player.
            // For simplicity now, GamePhaseUI will need the correct "before" hash.
            setGamePhase(GamePhase.GAME_P2_RECEIVE);
        } else if (gamePhase === GamePhase.GAME_P2_PROVE) {
            // Player 2 finished, set up for Player 1's receive phase
            setMyCharacters(player1Setup!.characters);
            setMyObstacles(player1Setup!.obstacles);
             skpl.serialize_chars(player1Setup!.characters).then(([sc, sca]) => {
                setMySerializedChars(sc);
                setMySerializedCharActions(sca);
            });
            skpl.serialize_my_obstacles_for_me(player1Setup!.obstacles).then(so => setMySerializedObstacles(so));

            setEnemyEventsInput(turnData.result_events);
            setEnemyAdvanceInput(turnData.result_advance);
            setEnemyObjectsInput(turnData.result_objects);
            setGamePhase(GamePhase.GAME_P1_RECEIVE);
        }
        setCurrentMoveNumber(prev => prev + 1);
    };


    // --- Render Logic ---
    const renderCurrentPhase = () => {

      if (loadingInitialChars) {
        return <div>Loading initial game assets... (Characters)</div>;
    }
    const currentPlayer = (gamePhase === GamePhase.SETUP_P1 || gamePhase === GamePhase.GAME_P1_RECEIVE || gamePhase === GamePhase.GAME_P1_ACTION || gamePhase === GamePhase.GAME_P1_PROVE) ? 1 : 2;
              // const initialChars = async (player: 1 | 2) => {
        //     // TODO: This needs to load from a defined source, not hardcoded strings
        //     // For now, use hardcoded example. Later, allow selecting character sets or NFT data.
        //     const [eventsValid, events] = await skpl.parse_their_events(initial_enemy_events_for_first_player);
        //     if (!eventsValid) return [];
        //     const [valid, chars] = await skpl.parse_characters(
        //          initial_my_chars_input, // Player 1 data for now
        //          initial_my_char_actions,
        //          events,
        //          initial_enemy_advance_for_first_player // Dummy enemy events for initial parsing
        //     );
        //     return valid ? chars : [];
        // };
  
    switch (gamePhase) {
        case GamePhase.SETUP_P1:
            if (!player1InitialChars) return <div>Error: Player 1 character data not loaded. {errorMessage}</div>;
            return <SetupPhaseUI
                        key="player1-setup" // Add unique key
                        playerNumber={1}
                        onSetupComplete={(chars, obs) => handleSetupComplete(1, chars, obs)}
                        initialCharacters={player1InitialChars} // PASS THE STATE VARIABLE
                        gridWidth={GRID_WIDTH}
                        gridHeight={GRID_HEIGHT}
                        maxChars={MAX_CHARS_PER_PLAYER}
                        maxObstacles={MAX_OBSTACLES_PER_PLAYER}
                    />;
        case GamePhase.SETUP_P2:
            if (!player2InitialChars) return <div>Error: Player 2 character data not loaded. {errorMessage}</div>;
            return <SetupPhaseUI
                        key="player2-setup" // Add unique key
                        playerNumber={2}
                        onSetupComplete={(chars, obs) => handleSetupComplete(2, chars, obs)}
                        initialCharacters={player2InitialChars} // PASS THE STATE VARIABLE
                        gridWidth={GRID_WIDTH}
                        gridHeight={GRID_HEIGHT}
                        maxChars={MAX_CHARS_PER_PLAYER}
                        maxObstacles={MAX_OBSTACLES_PER_PLAYER}
                    />;
            case GamePhase.GAME_P1_RECEIVE:
            case GamePhase.GAME_P2_RECEIVE:
                 // "Receive" phase implicitly handled by GamePhaseUI which will use the enemy inputs
                 // Transition to action phase after processing enemy inputs
                 // This could be a brief "Opponent's turn results..." screen
                 // For now, auto-transition or manual "Start My Turn" button
                 setTimeout(() => {
                     setGamePhase(currentPlayer === 1 ? GamePhase.GAME_P1_ACTION : GamePhase.GAME_P2_ACTION);
                 }, 100); // Auto-transition for now
                 return <div>Player {currentPlayer} processing opponent's turn...</div>;

            case GamePhase.GAME_P1_ACTION:
            case GamePhase.GAME_P2_ACTION:
                if (!player1Setup || !player2Setup) return <div>Waiting for setup...</div>;
                return <GamePhaseUI
                            playerNumber={currentPlayer}
                            // State for THIS player's turn:
                            initialMyCharacters={myCharacters}
                            initialMyObstacles={myObstacles}
                            initialMySerializedChars={mySerializedChars}
                            initialMySerializedCharActions={mySerializedCharActions}
                            initialMySerializedObstacles={mySerializedObstacles}
                            generatingProof={generatingProof} // PASS THE PROP HERE
                            // Opponent's data:
                            enemyEventsInput={enemyEventsInput}
                            enemyAdvanceInput={enemyAdvanceInput}
                            enemyObjectsInput={enemyObjectsInput}
                            // Game params:
                            currentMoveNumber={currentMoveNumber}
                            turnEnergy={TURN_ENERGY}
                            mapWidth={MAP_WIDTH}
                            mapHeight={MAP_HEIGHT}
                            fogAdvanceRange={FOG_ADVANCE_RANGE}
                            secret={secret} // Needed for calculating "before" hash
                            // Callbacks:
                            onActionPhaseComplete={handleActionPhaseComplete}
                            setStatusMessage={setStatusMessage}
                            setErrorMessage={setErrorMessage}
                        />;
            case GamePhase.GAME_P1_PROVE:
            case GamePhase.GAME_P2_PROVE:
                return <div>Generating proof for Player {currentPlayer}... {statusMessage}</div>;
            case GamePhase.GAME_OVER:
                return <div>Game Over!</div>;
            default:
                return <div>Loading game...</div>;
        }
    };

    return (
        <div className="game-manager">
            <iframe ref={iframeRef} src={proverHtmlSrc} style={{ display: 'none' }} title="Prover Frame" />
            <h2>Turn Based ZK Game</h2>
            {errorMessage && <div className="error-message">{errorMessage}</div>}
            {statusMessage && !generatingProof && <div className="status-message">{statusMessage}</div>}
            {generatingProof && <div className="status-message">Generating proof... {statusMessage}</div>}

            {/* TODO: Add UI for displaying dataForOpponent to copy/paste in hot-seat mode */}
            {dataForOpponent && (
                <div className="opponent-data-transfer">
                    <h3>Player {dataForOpponent.move_number % 2 === 0 ? 1 : 2} to Player {dataForOpponent.move_number % 2 === 0 ? 2 : 1}:</h3>
                    <p>Copy this data for your opponent:</p>
                    <textarea readOnly value={JSON.stringify(dataForOpponent, (key, value) =>
                        typeof value === 'bigint' ? value.toString() + 'n' : // Handle BigInt
                        value instanceof Map ? Array.from(value.entries()) : // Handle Map
                        value
                    , 2)} rows={10} cols={80} />
                    <button onClick={() => setDataForOpponent(null)}>Clear/Continue</button>
                </div>
            )}

            {!dataForOpponent && renderCurrentPhase()}
        </div>
    );
};

export default GameManager;