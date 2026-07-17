// GamePhaseUI.tsx
import React, { useState, useEffect, useCallback, Suspense, useMemo } from 'react';
import { Canvas } from '@react-three/fiber';
import { OrbitControls, useGLTF, useTexture, Box, Grid, Plane, Text } from '@react-three/drei';
import { Character, Obstacle, Event, Action, Field, u8 } from '../../logic/skpl'; // Adjust path
import * as skpl from '../../logic/skpl';
import * as arenalib from '../../logic/arenalib';
import { new_action as skpla_new_action } from '../../logic/skpla'; // Rename if clashes
import { CharacterModel } from '../../components/3d/CharacterModel';
import { ObstacleModel } from '../../components/3d/ObstacleModel';

const GRID_CELL_SIZE = 1;
const MAP_DISPLAY_WIDTH = 32; // How much of the 32-width map to show
const MAP_HEIGHT = 10;
const WALL_HEIGHT = 1.5;
const CHARACTER_SCALE = 0.4;
const FOG_COLOR = 'dimgray';

// --- Reusable 3D Models (similar to SetupPhaseUI) ---
// GridCell, CharacterModel, ObstacleModel (can be imported or redefined)

interface GamePhaseUIProps {
    playerNumber: 1 | 2;
    initialMyCharacters: Character[];
    initialMyObstacles: Obstacle[]; // Player's own static obstacles
    initialMySerializedChars: Field;
    initialMySerializedCharActions: Field[];
    initialMySerializedObstacles: Field[];
    generatingProof: boolean; // ADD PROP DEFINITION HERE

    enemyEventsInput: Field[];
    enemyAdvanceInput: u8;
    enemyObjectsInput: Field[]; // Serialized enemy objects

    currentMoveNumber: number;
    turnEnergy: number;
    mapWidth: number; // Full map width (32)
    mapHeight: number; // Full map height (10)
    fogAdvanceRange: number;
    secret: Field;

    onActionPhaseComplete: (
        actions: Action[],
        finalMyCharacters: Character[],
        finalMyObstacles: Obstacle[],
        gamestateBeforeHash: Field
    ) => void;
    setStatusMessage: (msg: string | null) => void;
    setErrorMessage: (msg: string | null) => void;
}
// Helper to convert number to hex (from your code)
const toHex = (x: number): string => {
  const h = x.toString(16);
  return `0x${h.length % 2 === 0 ? h : '0' + h}`;
};
// Action labels per class. Character.class is 1-based (1=ARCHER, 2=RITUALIST,
// 3=ROGUE, 4=KNIGHT, 5=MAGE — see circuits/arenalib/src/lib.nr), so index this
// array with `class - 1`.
const char_action_labels = [
  ["wait", "move", "attack", "draw bow", "shoot", "dummy", "dummy"],
  ["wait", "move", "attack", "cast ritual", "finish ritual", "dummy", "dummy"],
  ["wait", "move", "attack", "sneak", "search", "disarm trap", "set trap"],
  ["wait", "move", "attack", "dummy", "dummy",  "dummy",  "dummy"],
  ["wait", "move", "attack", "start cast fireball", "finish cast fireball", "dummy", "dummy"]
];
// Character.class values are 1-based; returns the label row for that class.
const actionLabelsForClass = (charClass: string | number): string[] | undefined =>
  char_action_labels[Number(charClass) - 1];

// Scene content must live inside <Canvas> because it uses R3F hooks (useTexture).
interface GameSceneProps {
    mapWidth: number;
    mapHeight: number;
    myCharsThisTurn: Character[];
    myObsThisTurn: Obstacle[];
    theirObsThisTurn: Obstacle[];
    selectedActionIndex: number | null;
    performableActionMap: string[][][] | null;
    characterModelPath: string;
    enemyCharacterModelPath: string;
    wallModelPath: string;
    isCellVisible: (x: number, y: number) => boolean;
    get3DPosition: (x: number, y: number, zOffset?: number) => [number, number, number];
    handleCellClickForAction: (x: number, y: number) => void;
}

const GameScene: React.FC<GameSceneProps> = ({
    mapWidth, mapHeight, myCharsThisTurn, myObsThisTurn, theirObsThisTurn,
    selectedActionIndex, performableActionMap,
    characterModelPath, enemyCharacterModelPath, wallModelPath,
    isCellVisible, get3DPosition, handleCellClickForAction,
}) => {
    // Load textures ONCE, inside the Canvas tree
    const [grassTexture, waterTexture] = useTexture([
        '/textures/grass.png',
        '/textures/water.png'
    ]);
    const gridConfig = {
        cellSize: GRID_CELL_SIZE,
        cellThickness: 1, // Thickness of grid lines
        cellColor: '#6f6f6f', // Color of grid lines
        sectionSize: 5, // Every 5 cells, a thicker line
        sectionThickness: 1.5,
        sectionColor: '#9d4b4b', // Color of section lines
        fadeDistance: 25, // Where grid starts fading
        fadeStrength: 1,
        followCamera: false, // Keep grid static
        infiniteGrid: false // Don't extend beyond specified size
    };

    return (
        <>
            <ambientLight intensity={0.7} />
            <directionalLight position={[0, 10, 5]} intensity={1} />
            {/* Render the Grid slightly above the ground plane to avoid z-fighting */}
            <Grid
                position={[0, 0.01, 0]}
                args={[mapWidth * GRID_CELL_SIZE, mapHeight * GRID_CELL_SIZE]}
                {...gridConfig}
            />

            {/* Game Grid & Fog */}
            {Array.from({ length: mapHeight }).map((_, rIndex) =>
                Array.from({ length: mapWidth }).map((_, cIndex) => {
                    const cellIsVisible = isCellVisible(cIndex, rIndex);
                    const isTargetable = selectedActionIndex !== null &&
                        performableActionMap &&
                        performableActionMap[selectedActionIndex]?.[rIndex]?.[cIndex]?.endsWith("01");

                    // Determine terrain type (grass or water from obstacles)
                    const ownWater = myObsThisTurn.find(o => Number(o.x) === cIndex && Number(o.y) === rIndex && o.obstacle_type === "0x07");
                    const theirWater = theirObsThisTurn.find(o => Number(o.x) === cIndex && Number(o.y) === rIndex && o.obstacle_type === "0x07");
                    const terrainType = (ownWater || theirWater) ? 'water' : 'grass';
                    const selectedTexture = terrainType === 'water' ? waterTexture : grassTexture;

                    return (
                        <Plane
                            key={`game-cell-${rIndex}-${cIndex}`}
                            args={[GRID_CELL_SIZE, GRID_CELL_SIZE]}
                            position={get3DPosition(cIndex, rIndex, -0.01)} // Slightly below models
                            rotation={[-Math.PI / 2, 0, 0]}
                            onClick={() => selectedActionIndex !== null && cellIsVisible && handleCellClickForAction(cIndex, rIndex)}
                        >
                            <meshStandardMaterial
                                color={!cellIsVisible ? FOG_COLOR : (isTargetable ? 'lightgreen' : 'white')}
                                map={selectedTexture}
                                transparent={!cellIsVisible}
                                opacity={!cellIsVisible ? 0.8 : 1}
                            />
                        </Plane>
                    );
                })
            )}

            {/* My Characters */}
            {myCharsThisTurn.filter(char => isCellVisible(Number(char.x), Number(char.y))).map((char, index) => (
                <CharacterModel key={`mychar-${char.id || index}`} modelPath={characterModelPath} position={get3DPosition(Number(char.x), Number(char.y), 0.1)} />
            ))}
            {/* My Static Obstacles */}
            {myObsThisTurn.filter(obs => isCellVisible(Number(obs.x), Number(obs.y))).map((obs, index) => (
                <ObstacleModel key={`myobs-${obs.id || index}`} type={obs.obstacle_type === "0x06" ? 'WALL' : 'WATER'} position={get3DPosition(Number(obs.x), Number(obs.y))} wallModelPath={wallModelPath} />
            ))}

            {/* Their Visible Objects (Characters and Obstacles) */}
            {theirObsThisTurn.filter(obs => isCellVisible(Number(obs.x), Number(obs.y))).map((obs, index) => {
                // Differentiate between enemy character and obstacle based on your data structure
                const isCharacter = obs.health !== "0xff" && obs.health !== "0xc8"; // Simplistic check; refine based on actual data
                if (isCharacter) {
                    return <CharacterModel key={`theirchar-${obs.id || index}`} modelPath={enemyCharacterModelPath} position={get3DPosition(Number(obs.x), Number(obs.y), 0.1)} />;
                } else {
                    return <ObstacleModel key={`theirobs-${obs.id || index}`} type={obs.obstacle_type === "0x06" ? 'WALL' : 'WATER'} position={get3DPosition(Number(obs.x), Number(obs.y))} wallModelPath={wallModelPath} />;
                }
            })}

            {/* TODO: Display Events (e.g., attack animations, status effects) */}

            <OrbitControls enableRotate={false} mouseButtons={{ LEFT: 0, MIDDLE: 1, RIGHT: 2 }} /> {/* Disable rotation if top-down */}
        </>
    );
};
const GamePhaseUI: React.FC<GamePhaseUIProps> = ({
    playerNumber, initialMyCharacters, initialMyObstacles,
    generatingProof, // DESTRUCTURE THE PROP
    initialMySerializedChars, initialMySerializedCharActions, initialMySerializedObstacles,
    enemyEventsInput, enemyAdvanceInput, enemyObjectsInput,
    currentMoveNumber, turnEnergy, mapWidth, mapHeight, fogAdvanceRange, secret,
    onActionPhaseComplete, setStatusMessage, setErrorMessage
}) => {
    // --- State for the current turn ---
    const [myCharsThisTurn, setMyCharsThisTurn] = useState<Character[]>([]);
    const [myObsThisTurn, setMyObsThisTurn] = useState<Obstacle[]>([]); // Own static obstacles
    const [theirObsThisTurn, setTheirObsThisTurn] = useState<Obstacle[]>([]); // Opponent's visible obstacles/chars
    const [visibleEvents, setVisibleEvents] = useState<Event[]>([]); // Parsed enemy events
    const [currentActorId, setCurrentActorId] = useState(0);
    const [currentEnergy, setCurrentEnergy] = useState(turnEnergy);
    const [actionsThisTurn, setActionsThisTurn] = useState<Action[]>([]);
    const [gamestateBeforeThisTurnHash, setGamestateBeforeThisTurnHash] = useState<Field>("");

    const [selectedActionIndex, setSelectedActionIndex] = useState<number | null>(null);
    const [performableActionMap, setPerformableActionMap] = useState<string[][][] | null>(null); // [[[u8; WIDTH]; HEIGHT]; MAX_ACTIONS_PER_CHARACTER + 1]
    const [maxVisibleX, setMaxVisibleX] = useState(0);

    const characterModelPath = '/models/enemy_character.fbx'; // Your GLB/FBX model
    const enemyCharacterModelPath = '/models/enemy_character.fbx'; // Could be same model with different texture/color
    const wallModelPath = '/models/wall.fbx';

    // NOTE: textures are loaded inside <GameScene> below. R3F hooks like
    // useTexture throw ("Hooks can only be used within the Canvas component!")
    // when called outside the <Canvas> tree, which crashed the whole game phase.

    // --- Initial processing: Apply enemy effects, calculate "before" hash ---
    useEffect(() => {
        const processStartOfTurn = async () => {
            setStatusMessage(`Player ${playerNumber}, Turn ${currentMoveNumber}: Processing opponent's actions...`);
            try {
                // 1. Parse enemy events
                const [validEvents, parsedEnemyEvents] = await skpl.parse_their_events(enemyEventsInput);
                if (!validEvents) throw new Error("Failed to parse enemy events.");
                setVisibleEvents(parsedEnemyEvents);

                // 2. Parse enemy objects (obstacles and characters)
                const [validObs, parsedEnemyObjects] = await skpl.parse_their_obstacles(enemyObjectsInput);
                if (!validObs) throw new Error("Failed to parse enemy objects.");
                setTheirObsThisTurn(parsedEnemyObjects);

                // 3. Apply enemy effects to *our* characters
                // This requires the character state *from the end of our previous turn*
                // For the very first turn of P1, initialMyCharacters is correct.
                // For subsequent turns, we need to load the result of our *last* skpl.calculate_turn
                // This state management is crucial and complex.
                // For now, using initialMyCharacters for simplicity, but this needs refinement.
                // The `my_chars_input` for `parse_characters` should be the *result* from player's previous turn.
                // It means GameManager needs to store `my_result_chars_serialized` from previous PlayerTurnData.
                // Let's assume `initialMyCharacters` is already the state *after* our previous turn.

                const [validCharsAfterEnemy, charsAfterEnemyEffects] = await skpl.parse_characters(
                    initialMySerializedChars, // Serialized chars from *end* of my last turn
                    initialMySerializedCharActions, // Serialized actions defs from *end* of my last turn
                    parsedEnemyEvents, // Events from opponent THIS turn
                    enemyAdvanceInput   // Advance from opponent THIS turn
                );
                if (!validCharsAfterEnemy) throw new Error("Failed to apply enemy effects to characters.");
                setMyCharsThisTurn(charsAfterEnemyEffects);
                setMyObsThisTurn(initialMyObstacles); // Own obstacles are static for now

                // 4. Calculate gamestate_before_hash for *this* turn
                // This uses the character/obstacle state *after* enemy effects, *before* our actions
                const [serCharsNow, serCharActionsNow] = await skpl.serialize_chars(charsAfterEnemyEffects);
                const serObsNow = await skpl.serialize_my_obstacles_for_me(initialMyObstacles);
                const beforeHash = await skpl.hash_serialized_private_state(
                    serCharsNow, serCharActionsNow, serObsNow, secret
                );
                setGamestateBeforeThisTurnHash(beforeHash);

                // 5. Determine current actor and initial performable actions
                const actorIdx = Math.floor(currentMoveNumber / 2) % initialMyCharacters.length;
                setCurrentActorId(actorIdx);
                setCurrentEnergy(turnEnergy);
                setActionsThisTurn([]); // Reset actions for the new turn
                await updatePerformableActions(charsAfterEnemyEffects, initialMyObstacles, parsedEnemyObjects, actorIdx, turnEnergy);

                // 6. Calculate Fog of War
                let currentMaxX = 0;
                charsAfterEnemyEffects.forEach(c => {
                    const charX = Number(c.x); // Assuming hex strings
                    if (charX > currentMaxX) currentMaxX = charX;
                });
                // If player 2, mirror their max X for fog calculation
                const effectiveMaxX = playerNumber === 2 ? (mapWidth - 1 - currentMaxX) : currentMaxX;
                setMaxVisibleX(Math.min(mapWidth -1, effectiveMaxX + fogAdvanceRange));


                setStatusMessage(`Player ${playerNumber}, Turn ${currentMoveNumber}: Your action. Actor: ${actorIdx}, Energy: ${turnEnergy}`);
            } catch (err) {
                setErrorMessage(`Error starting turn: ${err}`);
            }
        };
        processStartOfTurn();
    }, [
        currentMoveNumber, playerNumber, initialMyCharacters, initialMyObstacles,
        enemyEventsInput, enemyAdvanceInput, enemyObjectsInput, secret,
        initialMySerializedChars, initialMySerializedCharActions, // Added dependencies
        setStatusMessage, setErrorMessage, turnEnergy, fogAdvanceRange, mapWidth
    ]);

    const updatePerformableActions = async (
        currentChars: Character[],
        currentOwnObs: Obstacle[],
        currentTheirObs: Obstacle[],
        actorIndex: number,
        energy: number
    ) => {
        if (actorIndex < 0 || actorIndex >= currentChars.length) return;
        setStatusMessage("Calculating valid actions...");
        try {
            const [validMyCharsAsObs, myCharsAsObs] = await skpl.chars_to_obstacles(currentChars);
            if (!validMyCharsAsObs) throw new Error("Failed to convert own chars to obstacles.");

            const allOwnObjects = [...currentOwnObs, ...myCharsAsObs];
            // Their objects already include their characters if they were serialized correctly
            const performable = await skpl.get_performable_actions(
                currentChars[actorIndex],
                enemyAdvanceInput, // This might need to be current player's advance if logic demands
                toHex(energy),
                allOwnObjects,
                currentTheirObs // Pass all their objects (chars + static)
            );
            setPerformableActionMap(performable);
            setStatusMessage("Select an action for your character.");
        } catch (err) {
            setErrorMessage(`Error getting performable actions: ${err}`);
        }
    };

    const handleActionSelection = (actionListIndex: number) => { // This is index into character's action list
        setSelectedActionIndex(actionListIndex);
        // UI should now highlight cells based on performableActionMap[actionListIndex]
    };

    const handleCellClickForAction = async (targetX: number, targetY: number) => {
        if (selectedActionIndex === null || !performableActionMap) return;
        if (currentActorId < 0 || currentActorId >= myCharsThisTurn.length) return;

        const actor = myCharsThisTurn[currentActorId];
        // Validate if (targetX, targetY) is performable for selectedActionIndex
        // performableActionMap[selectedActionIndex][targetY][targetX] should be 1
        if (
            !performableActionMap[selectedActionIndex] ||
            !performableActionMap[selectedActionIndex][targetY] ||
            performableActionMap[selectedActionIndex][targetY][targetX].endsWith("01") !== true
        ) {
            alert("Invalid target for selected action.");
            return;
        }

        setStatusMessage("Calculating action result...");
        try {
            // Create the action object.
            // The action_type is the index into the character's action list: slot 0 is
            // the built-in WAIT action, slots 1+ are the class's custom ActionDefinitions.
            // get_performable_actions returns its map with the same indexing, so
            // selectedActionIndex maps 1:1 to the numeric action_type.
            const numericActionType = selectedActionIndex;

            const newAction = await skpla_new_action(
                toHex(numericActionType),
                toHex(currentActorId),
                toHex(targetX),
                toHex(targetY)
            );

            const [
                actionValid,
                updatedChars,
                updatedMyObs, // Own obstacles might change (e.g., setting a trap)
                updatedEnergyHex,
                resultingEvent, // For UI display
            ] = await skpl.calculate_action(
                newAction,
                myCharsThisTurn,
                myObsThisTurn,
                theirObsThisTurn, // Pass current state of their obstacles
                enemyAdvanceInput, // Or current player's own advance? Check logic.
                toHex(currentEnergy)
            );

            if (!actionValid) throw new Error("Action calculation failed in Noir.");

            setMyCharsThisTurn(updatedChars);
            setMyObsThisTurn(updatedMyObs);
            const newEnergy = parseInt(updatedEnergyHex.substring(2), 16);
            setCurrentEnergy(newEnergy);
            setActionsThisTurn(prev => [...prev, newAction]);
            // TODO: Display resultingEvent in UI (e.g., "Character moved to X,Y", "Attack hit for Z damage")
            console.log("Action Event:", resultingEvent);

            setSelectedActionIndex(null); // Reset selection
            if (newEnergy <= 0 || actionsThisTurn.length + 1 >= 4) {
                setStatusMessage("Energy depleted or max actions. Click 'Finish Turn'.");
            } else {
                await updatePerformableActions(updatedChars, updatedMyObs, theirObsThisTurn, currentActorId, newEnergy);
            }

        } catch (err) {
            setErrorMessage(`Error performing action: ${err}`);
        }
    };

    const handleFinishTurn = () => {
        if (!gamestateBeforeThisTurnHash) {
            alert("Error: Gamestate before hash not calculated.");
            return;
        }
        onActionPhaseComplete(actionsThisTurn, myCharsThisTurn, myObsThisTurn, gamestateBeforeThisTurnHash);
    };

    const get3DPosition = (x: number, y: number, zOffset = 0): [number, number, number] => {
        // Adjust for player 2 to see their side as "left"
        const displayX = playerNumber === 2 ? (mapWidth - 1 - x) : x;
        return [
            (displayX - MAP_DISPLAY_WIDTH / 2 + 0.5) * GRID_CELL_SIZE,
            zOffset,
            (y - mapHeight / 2 + 0.5) * GRID_CELL_SIZE // Y is not mirrored
        ];
    };

    const activeActor = useMemo(() => {
        if (currentActorId >= 0 && currentActorId < myCharsThisTurn.length) {
            return myCharsThisTurn[currentActorId];
        }
        return null;
    }, [myCharsThisTurn, currentActorId]);

    // Determine what cells are visible
    const isCellVisible = (x: number, y: number): boolean => {
         // Player 1 sees from left (0) up to maxVisibleX
         // Player 2 sees from their right (mapWidth - 1) down to (mapWidth - 1 - maxVisibleX)
         // Coordinates are always 0-31 for game logic.
        if (playerNumber === 1) {
            return x <= maxVisibleX;
        } else { // Player 2
            return x >= (mapWidth - 1 - maxVisibleX);
        }
    };
    return (
        <div className="game-phase">
            <h3>Player {playerNumber} - Turn {currentMoveNumber} - Actor: {currentActorId} - Energy: {currentEnergy}</h3>
            {activeActor && (
                <div className="action-selector">
                    <h4>Select Action for Character {activeActor.id} (Class: {activeActor.class}):</h4>
                    {actionLabelsForClass(activeActor.class)?.map((actionName, idx) => (
                         actionName !== "dummy" && // Don't show dummy actions
                        <button key={`action-${idx}`} onClick={() => handleActionSelection(idx)}
                                disabled={selectedActionIndex === idx || performableActionMap === null}>
                            {actionName}
                        </button>
                    ))}
                </div>
            )}
            {selectedActionIndex !== null && activeActor && <p>Selected Action: {actionLabelsForClass(activeActor.class)?.[selectedActionIndex]}. Click target on map.</p>}


            <div style={{ height: '500px', width: '100%', border: '1px solid black', position: 'relative' }}>
                <Canvas camera={{ position: [0, 15, 0.1], fov: 60 }}> {/* Top-downish view */}
                    <Suspense fallback={null}>
                        <GameScene
                            mapWidth={mapWidth}
                            mapHeight={mapHeight}
                            myCharsThisTurn={myCharsThisTurn}
                            myObsThisTurn={myObsThisTurn}
                            theirObsThisTurn={theirObsThisTurn}
                            selectedActionIndex={selectedActionIndex}
                            performableActionMap={performableActionMap}
                            characterModelPath={characterModelPath}
                            enemyCharacterModelPath={enemyCharacterModelPath}
                            wallModelPath={wallModelPath}
                            isCellVisible={isCellVisible}
                            get3DPosition={get3DPosition}
                            handleCellClickForAction={handleCellClickForAction}
                        />
                    </Suspense>
                </Canvas>
            </div>
            <button onClick={handleFinishTurn} disabled={generatingProof}>Finish Turn & Generate Proof</button>
        </div>
    );
};
export default GamePhaseUI;