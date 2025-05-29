// // src/components/3d/Models.tsx
// import React, { useEffect, useRef, useMemo } from 'react';
// import { useFBX, useAnimations } from '@react-three/drei'; // Use useFBX
// import * as THREE from 'three';

// const CHARACTER_SCALE = 0.4;
import { SkeletonUtils } from 'three-stdlib';
interface CharacterModelProps {
    modelPath: string;
    position: [number, number, number];
    animationName?: string;
    isEnemy?: boolean; // Optional to differentiate styling/model later
    // Add player color/team later
}

// //useFBX.preload( '/models/character.fbx'); // Adjust path
// useFBX.preload( '/models/enemy_character.fbx'); // Adjust path
// export const CharacterModel: React.FC<CharacterModelProps> = ({
//   modelPath,
//   position,
//   animationName = 'Clothes.002|Normal Walk'//Armature|Stand_Idle_0' // Default animation
// }) => {
//   const fbx = useFBX(modelPath); // Load the FBX model directly
//   const animations = useMemo(() => fbx.animations || [], [fbx]); // Extract animations safely
  
//     // --- Manual Deep Clone ---
//     // We clone the entire loaded FBX group for each instance
//     const clonedFbxGroup = useMemo(() => {
//       const clone = fbx.clone(true); // true for recursive/deep clone

//       // IMPORTANT: Ensure materials are cloned if necessary
//       // Sometimes shared materials cause issues with multiple instances or modifications
//       clone.traverse((node) => {
//         if ((node as THREE.Mesh).isMesh && (node as THREE.Mesh).material) {
//           // Clone material(s). If material is an array, clone each one.
//           if (Array.isArray((node as THREE.Mesh).material)) {
//                (node as THREE.Mesh).material = (node as THREE.Mesh).material.map(m => m.clone());
//           } else {
//                (node as THREE.Mesh).material = (node as THREE.Mesh).material.clone();
//           }
//         }
//       });
//       console.log("FBX Cloned:", clone); // Log to inspect the cloned structure
//       return clone;
//   }, [fbx]); // Re-clone only if the loaded fbx object changes

//   // --- Animation ---
//   // Ref for THIS specific cloned instance
//   const groupRef = useRef<THREE.Group>(null!); // Use non-null assertion or initialize properly

//   // Apply animations to the REF of the CLONED group
//   const { actions, mixer } = useAnimations(animations, groupRef);

//   // Log available animation names from the original FBX load
//   useEffect(() => {
//       if (fbx && fbx.animations) {
//           const originalActions = new THREE.AnimationMixer(fbx).clipAction(fbx.animations[0]).getClip().name; // Example way to get names if needed
//           // A better way might be just using the names from the loaded animations array:
//            console.log(`Available animations for ${modelPath}:`, animations.map(clip => clip.name));
//       }
//   }, [modelPath, animations, fbx]); // Add fbx dependency

//   // Play the specified animation on THIS instance
//   useEffect(() => {
//       // Ensure actions object is populated
//       if (!actions || Object.keys(actions).length === 0) {
//           // console.warn("Actions not ready yet for animation:", animationName);
//           return;
//       }

//       const action = actions[animationName];
//       if (action) {
//           // console.log(`Playing animation: ${animationName} on instance`);
//           // Stop others maybe? Be careful with shared mixers if not cloned properly
//           Object.values(actions).forEach(a => {
//                if (a !== action && a?.isRunning()) { // Check if running before stopping
//                   a.fadeOut(0.3); // Fade out others
//                }
//            });

//           action.reset().fadeIn(0.3).play();
//       } else {
//           console.warn(`Animation "${animationName}" not found in model ${modelPath}. Available:`, Object.keys(actions));
//           // Fallback?
//           const fallbackActionName = animations[0]?.name;
//           if (fallbackActionName && actions[fallbackActionName]){
//               actions[fallbackActionName].reset().fadeIn(0.3).play();
//           }
//       }

//       // Cleanup function for fading out
//       return () => {
//           // console.log(`Fading out animation: ${animationName} on instance cleanup`);
//           if (action) {
//               action.fadeOut(0.3);
//           }
//            // It might be necessary to explicitly stop the mixer or actions
//            // if components unmount/remount frequently to prevent animation glitches.
//            // mixer.stopAllAction(); // Uncomment if needed
//       };
//   }, [actions, animationName, mixer, animations]); // Add mixer and animations as dependencies


//   // We render the *cloned* group and attach the ref to it
//   return (
//       <primitive
//           ref={groupRef} // Attach ref here for useAnimations
//           object={clonedFbxGroup} // Render the unique clone
//           position={position}
//           scale={CHARACTER_SCALE}
//       />
//   );
// };

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

import React, { useEffect, useMemo, useRef } from 'react';
import { useAnimations, useFBX, useGLTF } from '@react-three/drei';
import * as THREE from 'three'; // Import THREE
import { useFrame } from '@react-three/fiber';
// Constants might be better defined centrally or passed as props if they vary
const GRID_CELL_SIZE = 1;
const WALL_HEIGHT = 1.5;


// Preload the model *outside* the component for potential reuse
// This helps performance slightly, especially if used many times.
//useFBX.preload( '/models/enemy_character.fbx'); // Adjust path
// useFBX.preload('/models/knight.fbx'); // Adjust path if using GLTF
useGLTF.preload('/models/knight.glb'); // Adjust path for GLTF

export const CharacterModel: React.FC<CharacterModelProps> = ({
    modelPath,
    position,
    animationName = 'Idle'//'Retopo_Face|Normal Walk'//'Clothes.002|Normal Walk'//Armature|Stand_Idle_0' // Default animation
  }) => {
    const model = useGLTF('/models/knight.glb');
    // const model = useFBX('/models/knight.fbx'); //modelPath);
    // const box = useMemo(() => new THREE.Box3().setFromObject(model.scene), [model]); // Memoize box calculation
    // const size = useMemo(() => box.getSize(new THREE.Vector3()), [box]);

    // const maxHorizontalSize = Math.max(size.x, size.z);
    // if (maxHorizontalSize === 0) return null; // Avoid division by zero if model is empty

    // // --- Scaling (Uniform based on horizontal) ---
    // const desiredScale = GRID_CELL_SIZE / maxHorizontalSize;

    // // --- Positioning ---
    // // Calculate the height of the model *after* scaling
    // const scaledHeight = size.y * desiredScale;

    // // We want the *bottom* of the scaled model to sit at Y = position[1] (which should be 0 for ground level)
    // // The primitive's position sets its center. So, we need to place the center at Y = position[1] + scaledHeight / 2.
    // const finalYPosition = position[1] + (scaledHeight / 2) -1;

    // Clone the scene
    //const clonedScene = useMemo(() => model.scene.clone(true), [model.scene]);

  // model.scene is stable, so this useMemo runs once per CharacterModel instance
  // const clonedScene = useMemo(() => {
  //   console.log(`Cloning scene for instance at position: ${position}`);
  //   return model.scene.clone(true); // Deep clone
  // }, [model, position]); // position dependency for logging, model.scene is the important one
  // every instance needs its own deep clone:
const clonedScene = useMemo(
  () => SkeletonUtils.clone(model.scene),
  [model.scene]
);

    // 2. Scaling and Positioning (looks okay, ensure GRID_CELL_SIZE is correct)
  const box = useMemo(() => new THREE.Box3().setFromObject(clonedScene), [clonedScene]);
  const size = useMemo(() => box.getSize(new THREE.Vector3()), [box]);

  // Check if size is valid before proceeding
  if (size.x === 0 && size.y === 0 && size.z === 0) {
    console.warn(`Model ${modelPath} has zero size after cloning.`);
    return null; // Avoid division by zero and rendering an empty object
  }
  const maxHorizontalSize = Math.max(size.x, size.z);
  // Handle case where model might be 2D or has no horizontal extent
  const desiredScale = 1; //maxHorizontalSize > 0 ? GRID_CELL_SIZE / maxHorizontalSize : 1; 
  const scaledHeight = size.y * desiredScale;
  const finalYPosition = position[1] + (scaledHeight / 2)// -1; // The -1 is specific, ensure it's intended.
  console.log(`Model ${modelPath} at position ${position} has size:`, size, `Desired scale: ${desiredScale}, Final Y Position: ${finalYPosition}`);

  // --- Animation ---

  const groupRef = useRef<THREE.Group>(null!); // Ref for the primitive hosting the cloned scenes
  // IMPORTANT: useAnimations hook.
  // Pass model.animations (original animation clips) and the ref to the object to be animated.
  const { actions, mixer, names } = useAnimations(model.animations, groupRef);

  useEffect(() => {
    console.log(`[${modelPath} at ${position}] Available animation names:`, names);
    console.log(`[${modelPath} at ${position}] All actions from useAnimations:`, actions);
  }, [names, actions, modelPath, position]); // Log available animations

  useEffect(() => {
    if (!actions || Object.keys(actions).length === 0) {
      // console.log(`[${modelPath} at ${position}] Actions not ready yet for animation: ${animationName}`);
      return;
    }

    // Log the specific action we're trying to play
    const action = actions[animationName];
    // console.log(`[${modelPath} at ${position}] Trying to play: "${animationName}". Action found:`, action);

    if (action) {
      // Stop other animations before playing a new one
      Object.values(actions).forEach(act => {
        if (act && act !== action && act.isRunning()) {
          act.fadeOut(0.3);
        }
      });
      action.reset().fadeIn(0.3).play();
      } else {
      console.warn(`[${modelPath} at ${position}] Animation "${animationName}" not found. Available:`, Object.keys(actions));
      // Optional: Play first available animation as fallback
      if (names.length > 0 && actions[names[0]]) {
        console.log(`[${modelPath} at ${position}] Playing fallback animation: "${names[0]}"`);
        actions[names[0]]!.reset().fadeIn(0.3).play();
      }
    }

    // Cleanup on unmount or when animationName changes
    return () => {
      // console.log(`[${modelPath} at ${position}] Cleaning up animation: "${animationName}"`);
      if (action && action.isRunning()) { // Check if running before trying to fadeOut
        action.fadeOut(0.3);
      }
      // If you want to stop ALL actions on unmount for this instance:
      // mixer.stopAllAction();
    };
  // Rerun effect if animationName changes, or if actions/mixer get re-initialized
  // model.animations is stable from useGLTF
  }, [actions, animationName, mixer, names, modelPath, position]);


  // Ensure groupRef.current is available for the mixer to update if necessary
  // R3F's render loop should handle mixer.update(delta) automatically.
  // If you have a custom loop or frameloop="demand", you'd need to update the mixer manually.
useFrame((_, delta) => {
  mixer?.update(delta);
});
  return (
    <primitive
      ref={groupRef}
      object={clonedScene}
      position={[position[0], finalYPosition, position[2]]}
      scale={desiredScale}
      // Consider adding dispose={null} if you're not manually disposing geometry/materials
      // and relying on R3F/Three.js garbage collection for cloned objects when unmounted.
      dispose={null} // Prevents drei from trying to dispose the original shared geometry/material
    />
  );
};
//   // Ref for THIS specific cloned instance
//   const groupRef = useRef<THREE.Group>(null!); // Use non-null assertion or initialize properly

//   // Apply animations to the REF of the CLONED group
//   const { actions, mixer } = useAnimations(model.animations, groupRef);

//   // Log available animation names from the original FBX load
//   useEffect(() => {
//       if (model && model.animations) {
//           //const originalActions = new THREE.AnimationMixer(fbx).clipAction(fbx.animations[0]).getClip().name; // Example way to get names if needed
//           // A better way might be just using the names from the loaded animations array:
//            console.log(`Available animations for ${modelPath}:`, model.animations.map(clip => clip.name));
//       }
//   }, [modelPath, model.animations, model]); // Add fbx dependency

//   // Play the specified animation on THIS instance
//   useEffect(() => {
//       // Ensure actions object is populated
//       if (!actions || Object.keys(actions).length === 0) {
//           // console.warn("Actions not ready yet for animation:", animationName);
//           return;
//       }

//       const action = actions[animationName];
//       if (action) {
//           // console.log(`Playing animation: ${animationName} on instance`);
//           // Stop others maybe? Be careful with shared mixers if not cloned properly
//           Object.values(actions).forEach(a => {
//                if (a !== action && a?.isRunning()) { // Check if running before stopping
//                   a.fadeOut(0.3); // Fade out others
//                }
//            });

//           action.reset().fadeIn(0.3).play();
//       } else {
//           console.warn(`Animation "${animationName}" not found in model ${modelPath}. Available:`, Object.keys(actions));
//           // Fallback?
//           const fallbackActionName = model.animations[0]?.name;
//           if (fallbackActionName && actions[fallbackActionName]){
//               actions[fallbackActionName].reset().fadeIn(0.3).play();
//           }
//       }

//       // Cleanup function for fading out
//       return () => {
//           // console.log(`Fading out animation: ${animationName} on instance cleanup`);
//           if (action) {
//               action.fadeOut(0.3);
//           }
//            // It might be necessary to explicitly stop the mixer or actions
//            // if components unmount/remount frequently to prevent animation glitches.
//            // mixer.stopAllAction(); // Uncomment if needed
//       };
//   }, [actions, animationName, mixer, model.animations]); // Add mixer and animations as dependencies


//     return (
//         <primitive
//             ref={groupRef}
//             object={clonedScene}
//             position={[position[0], finalYPosition, position[2]]} // Use calculated Y
//             scale={desiredScale}
//         />
//     );

// };