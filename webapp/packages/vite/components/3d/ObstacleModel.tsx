// // src/components/3d/Models.tsx
// import React from 'react';
// import { useFBX } from '@react-three/drei';

// const WALL_HEIGHT = 1.5;     // Adjust as needed
// const WALL_SCALE = 0.5;      // Adjust as needed

// interface ObstacleModelProps {
//     type: 'WALL' | 'WATER'; // WATER is handled by GridCell texture mostly
//     position: [number, number, number];
//     wallModelPath: string;
// }
// export const ObstacleModel: React.FC<ObstacleModelProps> = ({ type, position, wallModelPath }) => {
//     if (type === 'WALL') {
//         const model = useFBX(wallModelPath);
//         // Adjust position if model origin is not at its base center
//         return <primitive object={model.clone()} position={[position[0], position[1] + WALL_HEIGHT / 2, position[2]]} scale={WALL_SCALE} />;
//     }
//     return null; // WATER is part of the grid cell texture
// };

// src/components/3d/Models.tsx (or ObstacleModel.tsx)

import React, { useMemo } from 'react';
import { useFBX } from '@react-three/drei';
import * as THREE from 'three'; // Import THREE

// Constants might be better defined centrally or passed as props if they vary
const GRID_CELL_SIZE = 1;
const WALL_HEIGHT = 1.5;

// ... CharacterModel ...

interface ObstacleModelProps {
    type: 'WALL' | 'WATER';
    position: [number, number, number];
    wallModelPath: string;
}

// Preload the model *outside* the component for potential reuse
// This helps performance slightly, especially if used many times.
useFBX.preload( '/models/wall.fbx'); // Adjust path

export const ObstacleModel: React.FC<ObstacleModelProps> = ({ type, position, wallModelPath }) => {
  if (type === 'WALL') {
    const scene = useFBX(wallModelPath);
    const box = useMemo(() => new THREE.Box3().setFromObject(scene), [scene]); // Memoize box calculation
    const size = useMemo(() => box.getSize(new THREE.Vector3()), [box]);

    const maxHorizontalSize = Math.max(size.x, size.z);
    if (maxHorizontalSize === 0) return null; // Avoid division by zero if model is empty

    // --- Scaling (Uniform based on horizontal) ---
    const desiredScale = GRID_CELL_SIZE / maxHorizontalSize;

    // --- Positioning ---
    // Calculate the height of the model *after* scaling
    const scaledHeight = size.y * desiredScale;

    // We want the *bottom* of the scaled model to sit at Y = position[1] (which should be 0 for ground level)
    // The primitive's position sets its center. So, we need to place the center at Y = position[1] + scaledHeight / 2.
    const finalYPosition = position[1] + (scaledHeight / 2) - 0.1;

    // Clone the scene
    const clonedScene = useMemo(() => scene.clone(), [scene]);

    return (
        <primitive
            object={clonedScene}
            position={[position[0], finalYPosition, position[2]]} // Use calculated Y
            scale={desiredScale}
        />
    );

  }
  return null; // WATER is part of the grid cell texture
};