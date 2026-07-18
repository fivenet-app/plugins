type LogLevel = 'debug' | 'info' | 'warn' | 'error' | 'off';

const values: Record<LogLevel, number> = {
    debug: 10,
    info: 20,
    warn: 30,
    error: 40,
    off: 50,
};

let level = values.info;

export function setLevel(nextLevel: LogLevel): void {
    level = values[nextLevel] ?? values.info;
}

export function setDebug(debug: boolean): void {
    level = debug ? values.debug : values.info;
}

export function isDebugEnabled(): boolean {
    return level <= values.debug;
}

function shouldLog(nextLevel: LogLevel): boolean {
    return values[nextLevel] >= level;
}

export const Logger = {
    debug(message?: unknown, ...optionalParams: unknown[]): void {
        if (!shouldLog('debug')) return;

        console.debug('[DEBUG]', message, ...optionalParams);
    },

    info(message?: unknown, ...optionalParams: unknown[]): void {
        if (!shouldLog('info')) return;

        console.info('[INFO]', message, ...optionalParams);
    },

    warn(message?: unknown, ...optionalParams: unknown[]): void {
        if (!shouldLog('warn')) return;

        console.warn('[WARN]', message, ...optionalParams);
    },

    error(message?: unknown, ...optionalParams: unknown[]): void {
        if (!shouldLog('error')) return;

        console.error('[ERROR]', message, ...optionalParams);
    },
};
