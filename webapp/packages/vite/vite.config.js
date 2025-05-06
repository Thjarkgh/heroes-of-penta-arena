import react from '@vitejs/plugin-react-swc';
import { defineConfig } from 'vite'
import { resolve } from 'path'

//import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],

  build: {
    target: 'esnext', // Needed for top-level await used by bb.js
    outDir: 'dist',
    emptyOutDir: true, // Default, usually true
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'), // Verify this path
        prover: resolve(__dirname, 'src/prover/prover.html') // Verify this path
      },
      // output: {
      //   entryFileNames: `assets/[name].[ext]`,
      //   chunkFileNames: `assets/[name]-[hash].[ext]`,
      //   assetFileNames: `assets/[name]-[hash].[ext]`
      // }
    }
    // rollupOptions: {
    //   input: {
    //     // Entry point for your main React application
    //     main: resolve(__dirname, 'index.html'),

    //     // Entry point for the prover iframe HTML
    //     // Vite will process this HTML, find the script tag, bundle prover.js,
    //     // and update the script src path in the output dist/prover.html
    //     prover: resolve(__dirname, 'src/prover/prover.html')
    //   },
    //   output: {
    //     // Optional: Customize output filenames if needed,
    //     // but default hashing is usually good for caching.
    //     // If you need predictable names:
    //     // entryFileNames: `assets/[name].js`,
    //     // chunkFileNames: `assets/[name]-[hash].js`,
    //     // assetFileNames: `assets/[name]-[hash].[ext]`
    //   }
    // }
  },

  server: {
    // // Apply COOP/COEP headers. '*' might be too broad in dev.
    // // Applying them globally might be easiest for dev server iframe testing,
    // // BUT be aware they might break other things (external scripts, etc.).
    headers: {
      'Cross-Origin-Opener-Policy': 'same-origin',
      'Cross-Origin-Embedder-Policy': 'require-corp',
    },

    //--- More targeted COOP/COEP for dev server (Alternative) ---
    //If global headers cause issues, use a middleware approach:
    // configureServer(server) {
    //   server.middlewares.use((req, res, next) => {
    //     // Apply only to the HTML file or related prover assets if needed
    //     if (req.url?.startsWith('/src/prover/')) { // Adjust path matching as needed
    //       res.setHeader('Cross-Origin-Opener-Policy', 'same-origin');
    //       res.setHeader('Cross-Origin-Embedder-Policy', 'require-corp');
    //     }
    //     next();
    //   });
    // }
    //--- End Alternative ---
  },

  // Optional: Define global constants or polyfills if needed
  // define: {
  //   'global': {}, // Provide global for polyfills like Buffer
  // },
  // resolve: {
  //   alias: {
  //     // Make sure 'buffer' resolves correctly if using polyfill
  //     // 'buffer': 'buffer/', // May not be needed with vite-plugin-node-stdlib-browser
  //   },
  // },
})