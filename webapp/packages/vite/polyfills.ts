// Global polyfills that must run before any dependency is initialized.
// @aztec/bb.js (>= 1.x) references the Node `Buffer` global in its browser
// build, so it has to exist before bb.js's module code executes. Import this
// file first in every entry point (index.tsx, src/prover/prover.js).
import { Buffer } from 'buffer';

if (typeof (globalThis as { Buffer?: unknown }).Buffer === 'undefined') {
    (globalThis as { Buffer?: unknown }).Buffer = Buffer;
}
