import { AddActivityRequest, AddActivityResponse, GetStatusResponse, RegisterAccountResponse, SendDataRequest, SendDataResponse, TransferAccountResponse } from '@fivenet-app/gen/services/sync/sync';
import { syncClient } from './client';

async function GetStatus(): Promise<GetStatusResponse> {
    const call = syncClient.getStatus({});

    const { response } = await call;
    return response;
}
exports('GetStatus', GetStatus);

async function RegisterAccount(license: string, resetToken: boolean, lastCharId?: number): Promise<RegisterAccountResponse> {
    const call = syncClient.registerAccount({
        identifier: license,
        resetToken: resetToken,
        lastCharId: lastCharId,
    });

    const { response } = await call;
    return response;
}
exports('RegisterAccount', RegisterAccount);

async function TransferAccount(oldLicense: string, newLicense: string): Promise<TransferAccountResponse> {
    const call = syncClient.transferAccount({
        oldLicense: oldLicense,
        newLicense: newLicense,
    });

    const { response } = await call;
    return response;
}
exports('TransferAccount', TransferAccount);

type Data = SendDataRequest['data'];
async function SendData(data: Data): Promise<SendDataResponse> {
    const call = syncClient.sendData({
        data: data,
    });

    const { response } = await call;
    return response;
}
exports('SendData', SendData);

type Activity = AddActivityRequest['activity'];
async function AddActivity(activity: Activity): Promise<AddActivityResponse> {
    const call = syncClient.addActivity({
        activity: activity,
    });

    const { response } = await call;
    return response;
}
exports('AddActivity', AddActivity);
