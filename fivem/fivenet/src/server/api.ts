import { GetStatusResponse, RegisterAccountResponse } from "@fivenet-app/gen/services/sync/sync";
import { syncClient } from "./client.js";

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
