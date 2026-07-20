export type LogLevel = 'debug' | 'info' | 'warn' | 'error' | 'off';

const values: Record<LogLevel, number> = {
    debug: 10,
    info: 20,
    warn: 30,
    error: 40,
    off: 50,
};

export const Logger = {
    level: values.info,

    setLevel(nextLevel: LogLevel | undefined): void {
        this.level = nextLevel ? values[nextLevel] : values.info;
    },

    isDebugEnabled(): boolean {
        return this.level <= values.debug;
    },

    shouldLog(nextLevel: LogLevel): boolean {
        return values[nextLevel] >= Logger.level;
    },

    debug(message?: unknown, ...optionalParams: unknown[]): void {
        if (!this.shouldLog('debug')) return;

        console.debug('[DEBUG]', message, ...optionalParams);
    },

    info(message?: unknown, ...optionalParams: unknown[]): void {
        if (!this.shouldLog('info')) return;

        console.info('[INFO]', message, ...optionalParams);
    },

    warn(message?: unknown, ...optionalParams: unknown[]): void {
        if (!this.shouldLog('warn')) return;

        console.warn('[WARN]', message, ...optionalParams);
    },

    error(message?: unknown, ...optionalParams: unknown[]): void {
        if (!this.shouldLog('error')) return;

        console.error('[ERROR]', message, ...optionalParams);
    },
};
