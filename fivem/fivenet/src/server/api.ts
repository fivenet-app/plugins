import {
    AddActivityRequest,
    AddActivityResponse,
    GetStatusResponse,
    RegisterAccountResponse,
    SendDataRequest,
    SendDataResponse,
    TransferAccountResponse,
} from '@fivenet-app/gen/services/sync/sync';
import { syncClient } from './client';

async function GetStatus(): Promise<GetStatusResponse | undefined> {
    try {
        const call = syncClient.getStatus({});

        const { response } = await call;
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
    try {
        const call = syncClient.registerAccount({
            identifier: license,
            resetToken: resetToken,
            lastCharId: lastCharId,
        });

        const { response } = await call;
        return response;
    } catch (e) {
        console.error('Error registering account:', e);
        return undefined;
    }
}
exports('RegisterAccount', RegisterAccount);

async function TransferAccount(oldLicense: string, newLicense: string): Promise<TransferAccountResponse | undefined> {
    try {
        const call = syncClient.transferAccount({
            oldLicense: oldLicense,
            newLicense: newLicense,
        });

        const { response } = await call;
        return response;
    } catch (e) {
        console.error(`Error transfering account (old: ${oldLicense}, new: ${newLicense}):`, e);
        return undefined;
    }
}
exports('TransferAccount', TransferAccount);

type Data = SendDataRequest['data'];
async function SendData(data: Data): Promise<SendDataResponse | undefined> {
    try {
        const call = syncClient.sendData(
            SendDataRequest.create({
                data: data,
            }),
        );

        const { response } = await call;
        return response;
    } catch (e) {
        console.error('Error sending data:', e);
        return undefined;
    }
}
exports('SendData', SendData);

type Activity = AddActivityRequest['activity'];
async function AddActivity(activity: Activity): Promise<AddActivityResponse | undefined> {
    try {
        const call = syncClient.addActivity(
            AddActivityRequest.create({
                activity: activity,
            }),
        );

        const { response } = await call;
        return response;
    } catch (e) {
        console.error('Error adding activity:', e);
        return undefined;
    }
}
exports('AddActivity', AddActivity);
