import {
    AddActivityRequest,
    AddActivityResponse,
    GetStatusResponse,
    RegisterAccountResponse,
    SendDataRequest,
    SendDataResponse,
    TransferAccountResponse,
} from '@fivenet-app/gen/services/sync/sync';
import { DEBUG, syncClient } from './client';

async function GetStatus(): Promise<GetStatusResponse | undefined> {
    if (!syncClient) {
        console.error('Sync client is not initialized');
        return;
    }

    try {
        const call = syncClient.getStatus({});

        const { response } = await call;
        DEBUG && console.debug('GetStatus response:', response);
        return response;
    } catch (e) {
        return undefined;
    }
}
exports('GetStatus', GetStatus);

async function RegisterAccount(
    license: string,
    resetToken: boolean,
    lastCharId?: number,
): Promise<RegisterAccountResponse | undefined> {
    DEBUG && console.debug('RegisterAccount request:', license, resetToken, lastCharId);

    if (!syncClient) {
        console.error('Sync client is not initialized');
        return;
    }

    try {
        const call = syncClient.registerAccount({
            identifier: license,
            resetToken: resetToken,
            lastCharId: lastCharId,
        });

        const { response } = await call;
        DEBUG && console.debug('RegisterAccount response:', response);
        return response;
    } catch (e) {
        console.error('Error registering account:', e);
        return undefined;
    }
}
exports('RegisterAccount', RegisterAccount);

async function TransferAccount(oldLicense: string, newLicense: string): Promise<TransferAccountResponse | undefined> {
    DEBUG && console.debug('TransferAccount response:', oldLicense, newLicense);

    if (!syncClient) {
        console.error('Sync client is not initialized');
        return;
    }

    try {
        const call = syncClient.transferAccount({
            oldLicense: oldLicense,
            newLicense: newLicense,
        });

        const { response } = await call;
        DEBUG && console.debug('TransferAccount response:', response);
        return response;
    } catch (e) {
        console.error(`Error transfering account (old: ${oldLicense}, new: ${newLicense}):`, e);
        return undefined;
    }
}
exports('TransferAccount', TransferAccount);

type Data = SendDataRequest['data'];
async function SendData(data: Data): Promise<SendDataResponse | undefined> {
    DEBUG && console.debug('SendData response:', data);

    if (!syncClient) {
        console.error('Sync client is not initialized');
        return;
    }

    try {
        const call = syncClient.sendData(
            SendDataRequest.create({
                data: data,
            }),
        );

        const { response } = await call;
        DEBUG && console.debug('SendData response:', response);
        return response;
    } catch (e) {
        console.error('Error sending data:', e);
        return undefined;
    }
}
exports('SendData', SendData);

type Activity = AddActivityRequest['activity'];
async function AddActivity(activity: Activity): Promise<AddActivityResponse | undefined> {
    DEBUG && console.debug('AddActivity request:', activity);

    if (!syncClient) {
        console.error('Sync client is not initialized');
        return;
    }

    try {
        const call = syncClient.addActivity(
            AddActivityRequest.create({
                activity: activity,
            }),
        );

        const { response } = await call;
        DEBUG && console.debug('AddActivity response:', response);
        return response;
    } catch (e) {
        console.error('Error adding activity:', e);
        return undefined;
    }
}
exports('AddActivity', AddActivity);
