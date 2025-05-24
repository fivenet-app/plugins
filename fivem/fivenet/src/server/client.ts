import { SyncServiceClient } from '@fivenet-app/gen/services/sync/sync.client';
import { ChannelCredentials } from '@grpc/grpc-js';
import { GrpcTransport } from '@protobuf-ts/grpc-transport';

let transport: GrpcTransport;
export let syncClient: SyncServiceClient;
let abort: AbortController | undefined;

export let DEBUG = false;

async function SetupClient(host: string, token: string, insecure: boolean, debug: boolean): Promise<void> {
    abort = new AbortController();

    DEBUG = debug;

    DEBUG && console.debug('Setting up GRPC client for FiveNet Sync API', host)
    transport = new GrpcTransport({
        host: host,
        channelCredentials: insecure ? ChannelCredentials.createInsecure() : ChannelCredentials.createSsl(),
        meta: {
            authorization: `Bearer ${token}`,
        },
        abort: abort.signal,
        timeout: 10000,
    });

    syncClient = new SyncServiceClient(transport);
}
exports('SetupClient', SetupClient);

on('onResourceStop', async (resourceName: string) => {
    if (resourceName !== GetCurrentResourceName()) return;

    if (abort) {
        abort.abort('Resource stopped');
    }
    if (transport) {
        transport.close();
    }

    console.info(`${resourceName} stopped.`);
});
