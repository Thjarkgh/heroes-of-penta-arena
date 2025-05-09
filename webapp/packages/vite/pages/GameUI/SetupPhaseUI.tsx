// SetupPhaseUI.tsx
import React, { useState, useEffect, Suspense } from 'react';
import { Canvas } from '@react-three/fiber';
import { MapControls, useGLTF, useTexture, Box, Grid, Plane, useFBX, OrthographicCamera } from '@react-three/drei';
import { Character, Obstacle, u8 } from '../../logic/skpl'; // Adjust path
import * as skpl from '../../logic/skpl'; // For new_obstacle
import { CharacterModel } from '../../components/3d/CharacterModel';
import { ObstacleModel } from '../../components/3d/ObstacleModel';
import { Texture } from 'three';
import { FBXLoader } from 'three/examples/jsm/loaders/FBXLoader';

const GRID_CELL_SIZE = 1; // Size of one cell in 3D space
const WALL_HEIGHT = 1.5;
const CHARACTER_SCALE = 0.4;

// Helper to convert number to hex (from your code)
const toHex = (x: number): string => {
  const h = x.toString(16);
  return `0x${h.length % 2 === 0 ? h : '0' + h}`;
};


const defaultCharPositionsP1 = [
  { x: 9, y: 2 }, // Corresponds to my_chars[0] from simulation
  { x: 9, y: 3 }, // my_chars[1] - NOTE: x=11 is outside 0-9 grid! Adjust if needed for setup UI. Let's use 9.
  { x: 9, y: 4 }, // my_chars[2] - Outside 0-9. Let's use 8.
  { x: 9, y: 4 }, // my_chars[3] - Outside 0-9. Let's use 7.
  { x: 8, y: 7 }, // my_chars[4] - Outside 0-9. Let's use 6.
];
// This needs the *full* list of 24 default obstacles from your simulation
const defaultObstacleDataP1 = [
  { id: 0, x: 0, y: 2, health: 200, type: "0x06" /*WALL*/ },
  { id: 1, x: 1, y: 2, health: 200, type: "0x06" },
  { id: 2, x: 3, y: 2, health: 200, type: "0x06" },
  { id: 3, x: 4, y: 2, health: 200, type: "0x06" },
  { id: 4, x: 5, y: 3, health: 200, type: "0x06" },
  { id: 5, x: 5, y: 4, health: 200, type: "0x06" },
  { id: 6, x: 5, y: 5, health: 200, type: "0x06" },
  { id: 7, x: 5, y: 7, health: 200, type: "0x06" },
  { id: 8, x: 4, y: 7, health: 200, type: "0x06" },
  { id: 9, x: 3, y: 7, health: 200, type: "0x06" },
  { id: 10, x: 1, y: 7, health: 200, type: "0x06" },
  { id: 11, x: 0, y: 7, health: 200, type: "0x06" },
  { id: 12, x: 7, y: 0, health: 200, type: "0x06" },
  { id: 13, x: 7, y: 1, health: 200, type: "0x06" },
  { id: 14, x: 7, y: 2, health: 200, type: "0x06" },
  { id: 15, x: 7, y: 3, health: 200, type: "0x06" },
  { id: 16, x: 7, y: 4, health: 200, type: "0x06" },
  { id: 17, x: 7, y: 5, health: 200, type: "0x06" },
  { id: 18, x: 6, y: 8, health: 255, type: "0x07" /*WATER*/ },
  { id: 19, x: 7, y: 8, health: 255, type: "0x07" },
  { id: 20, x: 5, y: 9, health: 255, type: "0x07" },
  { id: 21, x: 6, y: 9, health: 255, type: "0x07" },
  { id: 22, x: 7, y: 9, health: 255, type: "0x07" },
  { id: 23, x: 8, y: 9, health: 255, type: "0x07" },
];

interface GridCellProps {
    position: [number, number, number];
    onClick: () => void;
    isOccupied: boolean;
    isHighlighted?: boolean; // For selected character/obstacle placement
    terrainType: 'grass' | 'water'; // To apply different textures
    texture: Texture; // Pass the texture object directly
}


// --- NEW COMPONENT FOR SCENE CONTENT ---
interface SetupSceneProps {
  gridWidth: number;
  gridHeight: number;
  placedCharacters: Character[];
  placedObstacles: Obstacle[];
  occupiedGrid: boolean[][];
  selectedPieceType: 'character' | 'WALL' | 'WATER' | null;
  characterModelPath: string;
  wallModelPath: string;
  handleCellClick: (rowIndex: number, colIndex: number) => void;
  get3DPosition: (x: number, y: number, zOffset?: number) => [number, number, number];
}

const SetupScene: React.FC<SetupSceneProps> = ({
  gridWidth, gridHeight, placedCharacters, placedObstacles, occupiedGrid,
  selectedPieceType, characterModelPath, wallModelPath, handleCellClick, get3DPosition
}) => {
  // Load textures ONCE at the top level OF THIS COMPONENT (WHICH IS INSIDE CANVAS)
  const [grassTexture, waterTexture] = useTexture([
      '/textures/grass.png', // Ensure paths are correct
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
      {/* Use Orthographic Camera */}
      <OrthographicCamera
          makeDefault // Make this the default camera R3F uses
          zoom={50}
          position={[5, 5, 5]} // Typical isometric angle start position (adjust as needed)
          // Adjust near/far planes based on your scene size if needed
          // near={0.1}
          // far={1000}
       />
          <ambientLight intensity={0.6} />
          <directionalLight position={[10, 10, 5]} intensity={1} />
          <pointLight position={[-10, -10, -10]} intensity={0.5} />

            {/* Render the Grid slightly above the ground plane to avoid z-fighting */}
            <Grid
                position={[0, 0.01, 0]} // Adjust Y slightly if needed
                args={[gridWidth * GRID_CELL_SIZE, gridHeight * GRID_CELL_SIZE]} // Total size based on your grid dimensions
                {...gridConfig}
            />

          {/* Grid */}
          {Array.from({ length: gridHeight }).map((_, rIndex) =>
              Array.from({ length: gridWidth }).map((_, cIndex) => {
                  const terrainType = placedObstacles.find(o => Number(o.x) === cIndex && Number(o.y) === rIndex && o.obstacle_type === "0x07")
                      ? 'water' : 'grass';
                  const selectedTexture = terrainType === 'water' ? waterTexture : grassTexture;

                  return (
                      <GridCell
                          key={`cell-${rIndex}-${cIndex}`}
                          position={get3DPosition(cIndex, rIndex)}
                          onClick={() => handleCellClick(rIndex, cIndex)}
                          isOccupied={occupiedGrid[rIndex][cIndex]}
                          isHighlighted={selectedPieceType !== null && !occupiedGrid[rIndex][cIndex]}
                          texture={selectedTexture}
                          terrainType={
                            placedObstacles.find(o => Number(o.x) === cIndex && Number(o.y) === rIndex && o.obstacle_type === "0x07")
                            ? 'water' : 'grass'
                        }
                      />
                  );
              })
          )}

          {/* Placed Characters */}
          {placedCharacters.map((char, index) => (
              <CharacterModel
                  key={`pchar-${char.id || index}`}
                  modelPath={characterModelPath}
                  position={get3DPosition(Number(char.x), Number(char.y), 0.1)}
              />
          ))}

          {/* Placed Obstacles */}
          {placedObstacles.map((obs, index) => (
              <ObstacleModel
                  key={`pobs-${obs.id || index}`}
                  type={obs.obstacle_type === "0x06" ? 'WALL' : 'WATER'}
                  position={get3DPosition(Number(obs.x), Number(obs.y))}
                  wallModelPath={wallModelPath}
              />
          ))}
            <MapControls
                //enableRotate={true} // Allow rotation around Y axis (optional)
                enableZoom={true}
                enablePan={true} // Allow panning (moving camera left/right/up/down)
                //minPolarAngle={Math.PI / 4} // Minimum angle from top-down (e.g., 45 degrees)
                //maxPolarAngle={Math.PI / 3} // Maximum angle from top-down (e.g., 60 degrees) - controls tilt
                minAzimuthAngle={-Infinity} // Allow full horizontal rotation (if enableRotate=true)
                maxAzimuthAngle={Infinity}
                // For a TRULY fixed isometric view (no rotation/tilt at all):
                enableRotate={false}
                minPolarAngle={Math.PI / 3.5} // Fixed angle ~51 degrees
                maxPolarAngle={Math.PI / 3.5} // Fixed angle
            />
      </>
  );
};
// --- END NEW COMPONENT ---

const GridCell: React.FC<GridCellProps> = ({ position, onClick, isOccupied, isHighlighted, texture }) => {
  // NO useTexture call here
  return (
      <Plane args={[GRID_CELL_SIZE, GRID_CELL_SIZE]} position={position} rotation={[-Math.PI / 2, 0, 0]} onClick={onClick}>
          <meshStandardMaterial map={texture} color={isHighlighted ? 'yellow' : (isOccupied ? 'lightgray' : 'white')} transparent opacity={isOccupied && !isHighlighted ? 0.7 : 1}/>
      </Plane>
  );
};
// const GridCell: React.FC<GridCellProps> = ({ position, onClick, isOccupied, isHighlighted, terrainType }) => {
//     const [grassTexture, waterTexture] = useTexture(['/textures/grass.png', '/textures/water.png']); // Paths to your textures
//     const texture = terrainType === 'water' ? waterTexture : grassTexture;

//     return (
//         <Plane args={[GRID_CELL_SIZE, GRID_CELL_SIZE]} position={position} rotation={[-Math.PI / 2, 0, 0]} onClick={onClick}>
//             <meshStandardMaterial map={texture} color={isHighlighted ? 'yellow' : (isOccupied ? 'lightgray' : 'white')} transparent opacity={isOccupied && !isHighlighted ? 0.7 : 1}/>
//         </Plane>
//     );
// };

interface SetupPhaseUIProps {
    playerNumber: 1 | 2;
    onSetupComplete: (characters: Character[], obstacles: Obstacle[]) => void;
    initialCharacters: Character[]; // Parsed from initial_my_chars_input
    gridWidth: number;
    gridHeight: number;
    maxChars: number;
    maxObstacles: number;
}

const SetupPhaseUI: React.FC<SetupPhaseUIProps> = ({
    playerNumber, onSetupComplete, initialCharacters, gridWidth, gridHeight, maxChars, maxObstacles
}) => {
    const [placedCharacters, setPlacedCharacters] = useState<Character[]>([]);
    const [placedObstacles, setPlacedObstacles] = useState<Obstacle[]>([]);
    const [selectedPieceType, setSelectedPieceType] = useState<'character' | 'WALL' | 'WATER' | null>(null);
    const [selectedCharacterIndex, setSelectedCharacterIndex] = useState<number | null>(null); // Index from initialCharacters
    const [nextObstacleId, setNextObstacleId] = useState(0);

    const characterModelPath = '/models/enemy_character.fbx'; // Your GLB/FBX model
    const wallModelPath = '/models/wall.fbx'; // Your wall model

    // Create a 2D array to track occupied cells
    const [occupiedGrid, setOccupiedGrid] = useState<boolean[][]>(
        () => Array(gridHeight).fill(null).map(() => Array(gridWidth).fill(false))
    );

    const resetPlacement = () => {
      setPlacedCharacters([]);
      setPlacedObstacles([]);
      setOccupiedGrid(Array(gridHeight).fill(null).map(() => Array(gridWidth).fill(false)));
      setNextObstacleId(0);
      setSelectedPieceType(null);
      setSelectedCharacterIndex(null);
  };
  const isColumnBlocked = (colIndex: number, grid: boolean[][]): boolean => {
    for (let rowIndex = 0; rowIndex < gridHeight; rowIndex++) {
        if (!grid[rowIndex][colIndex]) {
            return false; // Found a free cell
        }
    }
    return true; // No free cells found in this column
  };
  const applyDefaultPlacement = async () => {
      console.log("Applying default placement...");
      resetPlacement(); // Start fresh

      const defaultChars = [];
      const defaultObs = [];
      const newOccupiedGrid = Array(gridHeight).fill(null).map(() => Array(gridWidth).fill(false));
      let currentObstacleId = 0;

      // --- Place Obstacles First ---
      console.log("Placing default obstacles..."); // Use setStatusMessage prop if passed down
      for (const obsData of defaultObstacleDataP1) {
          if (newOccupiedGrid[obsData.y][obsData.x]) {
              console.warn(`Default placement conflict: Obstacle at ${obsData.x}, ${obsData.y}`);
              continue; // Skip if conflict
          }
          try {
              const [valid, newObstacle] = await skpl.new_obstacle(
                  toHex(currentObstacleId++), // Use auto-incrementing ID for default placement
                  toHex(obsData.x),
                  toHex(obsData.y),
                  toHex(obsData.health),
                  obsData.type
              );
              if (valid) {
                  defaultObs.push(newObstacle);
                  newOccupiedGrid[obsData.y][obsData.x] = true;
              } else {
                  throw new Error(`Failed to create default obstacle at ${obsData.x},${obsData.y}`);
              }
          } catch (error) {
               console.error(error);
               alert(`Error placing default obstacle: ${error}`);
               resetPlacement(); // Reset on error
               return;
          }
      }
      setPlacedObstacles(defaultObs);
      setNextObstacleId(currentObstacleId); // Update next ID counter

      // --- Place Characters ---
      console.log("Placing default characters...");
      for (let i = 0; i < Math.min(initialCharacters.length, defaultCharPositionsP1.length); i++) {
          const pos = defaultCharPositionsP1[i];
          if (newOccupiedGrid[pos.y][pos.x]) {
               console.warn(`Default placement conflict: Character at ${pos.x}, ${pos.y}`);
              continue; // Skip if conflict
          }
          const charToPlace = { ...initialCharacters[i] }; // Take from initial props
          charToPlace.x = toHex(pos.x);
          charToPlace.y = toHex(pos.y);
          defaultChars.push(charToPlace);
          newOccupiedGrid[pos.y][pos.x] = true;
      }
      setPlacedCharacters(defaultChars);
      setOccupiedGrid(newOccupiedGrid); // Update grid state once after all placements
      console.log("Default placement applied.");
  };

    const get3DPosition = (x: number, y: number, zOffset = 0): [number, number, number] => {
        return [
            (x - gridWidth / 2 + 0.5) * GRID_CELL_SIZE,
            zOffset,
            (y - gridHeight / 2 + 0.5) * GRID_CELL_SIZE
        ];
    };

    const handleCellClick = async (rowIndex: number, colIndex: number) => {
        if (occupiedGrid[rowIndex][colIndex] && selectedPieceType !== null) {
            alert("Cell is already occupied!");
            return;
        }

        if (selectedPieceType === 'character' && selectedCharacterIndex !== null) {
            if (placedCharacters.length >= maxChars) {
                alert("Maximum characters placed.");
                return;
            }
            const charToPlace = { ...initialCharacters[selectedCharacterIndex] };
            charToPlace.x = toHex(colIndex); // Player places in their local 0-9 grid
            charToPlace.y = toHex(rowIndex);
            setPlacedCharacters(prev => [...prev, charToPlace]);
            
            const newOccupiedGrid = occupiedGrid.map(r => [...r]);
            newOccupiedGrid[rowIndex][colIndex] = true;
            setOccupiedGrid(newOccupiedGrid);

            setSelectedCharacterIndex(null); // Deselect after placing
            setSelectedPieceType(null);
        } else if (selectedPieceType === 'WALL' || selectedPieceType === 'WATER') {
            if (placedObstacles.length >= maxObstacles) {
                alert("Maximum obstacles placed.");
                return;
            }
            // Obstacles for setup are type WALL or WATER
            const obstacleTypeHex = selectedPieceType === 'WALL' ? "0x06" : "0x07"; // From your constants
            const health = selectedPieceType === 'WALL' ? toHex(200) : toHex(255); // Default health

            const [valid, newObstacle] = await skpl.new_obstacle(
                toHex(nextObstacleId),
                toHex(colIndex),
                toHex(rowIndex),
                health,
                obstacleTypeHex
            );
            if (valid) {
                setPlacedObstacles(prev => [...prev, newObstacle]);
                setNextObstacleId(prev => prev + 1);
                const newOccupiedGrid = occupiedGrid.map(r => [...r]);
                newOccupiedGrid[rowIndex][colIndex] = true;
                setOccupiedGrid(newOccupiedGrid);
            } else {
                alert("Failed to create obstacle (logic error).");
            }
            setSelectedPieceType(null);
        }
    };

    const handleFinishSetup = () => {
        if (placedCharacters.length < maxChars /* || placedObstacles.length < maxObstacles */) {
             // Make obstacle placement optional for now or enforce a minimum
            alert(`Please place all ${maxChars} characters.`);
            return;
        }
        // --- Column Check ---
        for (let c = 0; c < gridWidth; c++) {
            if (isColumnBlocked(c, occupiedGrid)) {
                alert(`Placement invalid: Column ${c + 1} is completely blocked. Please leave at least one empty space per column.`);
                return; // Prevent completion
            }
        }
        // --- End Column Check ---

        console.log("Column check passed. Completing setup.");
        onSetupComplete(placedCharacters, placedObstacles);
    };

    return (
        <div className="setup-phase">
            <h3>Player {playerNumber} Setup</h3>
            {(
                 <button onClick={applyDefaultPlacement} style={{ marginBottom: '10px', marginRight: '10px' }}>
                    Apply Default P1 Placement
                 </button>
            )}
             <button onClick={resetPlacement} style={{ marginBottom: '10px' }}>
                Reset Placement
             </button>
            <div className="piece-selector">
                <h4>Select Piece to Place:</h4>
                {initialCharacters.map((char, index) => {
                    // Check if character already placed
                    const isPlaced = placedCharacters.some(pc => pc.id === char.id); // Assuming characters have unique IDs from parsing
                    return !isPlaced && (
                        <button key={`char-select-${index}`}
                            onClick={() => { setSelectedPieceType('character'); setSelectedCharacterIndex(index); }}
                            disabled={isPlaced || selectedPieceType === 'character'}
                        >
                            Place Character {index + 1} (Class: {char.class})
                        </button>
                    );
                })}
                <button onClick={() => setSelectedPieceType('WALL')} disabled={selectedPieceType==='WALL' || placedObstacles.length >= maxObstacles}>Place Wall</button>
                <button onClick={() => setSelectedPieceType('WATER')} disabled={selectedPieceType==='WATER' || placedObstacles.length >= maxObstacles}>Place Water Area</button>
            </div>
             {selectedPieceType && <p>Placing: {selectedPieceType === 'character' ? `Character ${selectedCharacterIndex! + 1}` : selectedPieceType}. Click on grid.</p>}


            <div style={{ height: '500px', width: '100%', border: '1px solid black' }}>
                <Canvas camera={{ position: [0, 8, 8], fov: 50 }}>
                    <Suspense fallback={null}> {/* Suspense should wrap components that use async resources like useTexture/useGLTF */}
                        <SetupScene
                            gridWidth={gridWidth}
                            gridHeight={gridHeight}
                            placedCharacters={placedCharacters}
                            placedObstacles={placedObstacles}
                            occupiedGrid={occupiedGrid}
                            selectedPieceType={selectedPieceType}
                            characterModelPath={characterModelPath}
                            wallModelPath={wallModelPath}
                            handleCellClick={handleCellClick}
                            get3DPosition={get3DPosition}
                        />
                    </Suspense>
                </Canvas>
            </div>
            <button onClick={handleFinishSetup} disabled={placedCharacters.length < maxChars}>
                Finish Setup for Player {playerNumber}
            </button>
        </div>
    );
};

export default SetupPhaseUI;