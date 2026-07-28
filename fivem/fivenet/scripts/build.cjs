const esbuild = require('esbuild');
const { builtinModules } = require('module');

const IS_WATCH_MODE = process.env.IS_WATCH_MODE;
const NODE_BUILTINS = new Set(builtinModules.flatMap((name) => [name, `node:${name}`]));

const validateBundle = (metafile) => {
    const externalImports = Object.values(metafile.outputs)
        .flatMap((output) => output.imports)
        .filter((imported) => imported.external && !NODE_BUILTINS.has(imported.path));

    if (!externalImports.length) return;

    console.error(
        `[ESBuild] Bundle has external package imports: ${[
            ...new Set(externalImports.map((imported) => imported.path)),
        ].join(', ')}`,
    );
    process.exit(1);
};

const TARGET_ENTRIES = [
    {
        target: 'node22',
        entryPoints: ['src/server/index.ts'],
        platform: 'node',
        outfile: './dist/server.js',
    },
];

const buildBundle = async () => {
    try {
        const baseOptions = {
            logLevel: 'info',
            bundle: true,
            platform: 'node',
            format: 'esm',
            charset: 'utf8',
            minifyWhitespace: true,
            absWorkingDir: process.cwd(),
            metafile: true,
            banner: {
                js: 'import { createRequire } from "module";const require=createRequire(import.meta.url);',
            },
        };

        for (const targetOpts of TARGET_ENTRIES) {
            const mergedOpts = { ...baseOptions, ...targetOpts };

            if (IS_WATCH_MODE) {
                mergedOpts.watch = {
                    onRebuild(error, result) {
                        if (error) console.error(`[ESBuild Watch] (${targetOpts.entryPoints[0]}) Failed to rebuild bundle`);
                        else {
                            validateBundle(result.metafile);
                            console.log(`[ESBuild Watch] (${targetOpts.entryPoints[0]}) Successfully rebuilt bundle`);
                        }
                    },
                };
            }

            const { errors, metafile } = await esbuild.build(mergedOpts);

            if (errors.length) {
                console.error(`[ESBuild] Bundle failed with ${errors.length} errors`);
                process.exit(1);
            }

            validateBundle(metafile);
        }
    } catch (e) {
        console.log('[ESBuild] Build failed with error');
        console.error(e);
        process.exit(1);
    }
};

buildBundle().catch(() => process.exit(1));
