import {
    AddAccountUpdateRequest,
    AddActivityRequest,
    AddActivityResponse,
    AddColleagueActivityRequest,
    AddColleaguePropsRequest,
    AddDispatchRequest,
    AddJobTimeclockRequest,
    AddUserActivityRequest,
    AddUserOAuth2ConnRequest,
    AddUserPropsRequest,
    AddUserUpdateRequest,
    DeleteDataRequest,
    DeleteDataResponse,
    DeleteUsersRequest,
    DeleteVehiclesRequest,
    GetStatusRequest,
    GetStatusResponse,
    RegisterAccountRequest,
    RegisterAccountResponse,
    SendAccountsRequest,
    SendDataRequest,
    SendDataResponse,
    SendJobsRequest,
    SendLicensesRequest,
    SendUserLocationsRequest,
    SendUsersRequest,
    SendVehiclesRequest,
    SetLastCharIDRequest,
    TransferAccountRequest,
    TransferAccountResponse,
} from '@fivenet-app/gen/services/sync/sync';
import { DEBUG, syncClient } from './client';

async function callSync<Request, Response>(
    name: string,
    request: Request,
    call: (client: NonNullable<typeof syncClient>) => PromiseLike<{ response: Response }>,
): Promise<Response | undefined> {
    DEBUG && console.debug(`${name} request:`, request);

    if (!syncClient) {
        console.error('Sync client is not initialized');
        return;
    }

    try {
        const { response } = await call(syncClient);
        DEBUG && console.debug(`${name} response:`, response);
        return response;
    } catch (e) {
        console.error(`Error calling ${name}:`, e);
        return undefined;
    }
}

async function GetStatus(): Promise<GetStatusResponse | undefined> {
    const request: GetStatusRequest = {};
    return callSync('GetStatus', request, (client) => client.getStatus(request));
}
exports('GetStatus', GetStatus);

async function RegisterAccount(
    license: string,
    resetToken: boolean,
    lastCharId?: number,
): Promise<RegisterAccountResponse | undefined> {
    const request: RegisterAccountRequest = {
        identifier: license,
        resetToken: resetToken,
        lastCharId: lastCharId,
    };

    return callSync('RegisterAccount', request, (client) => client.registerAccount(request));
}
exports('RegisterAccount', RegisterAccount);

async function TransferAccount(oldLicense: string, newLicense: string): Promise<TransferAccountResponse | undefined> {
    const request: TransferAccountRequest = {
        oldLicense: oldLicense,
        newLicense: newLicense,
    };

    return callSync('TransferAccount', request, (client) => client.transferAccount(request));
}
exports('TransferAccount', TransferAccount);

// AddActivity calls

async function AddActivity(activity: AddActivityRequest['activity']): Promise<AddActivityResponse | undefined> {
    const request = AddActivityRequest.create({
        activity: activity,
    });

    return callSync(`AddActivity (Kind: ${activity.oneofKind})`, request, (client) => client.addActivity(request));
}
exports('AddActivity', AddActivity);

async function AddUserOAuth2Conn(request: AddUserOAuth2ConnRequest): Promise<AddActivityResponse | undefined> {
    return callSync('AddUserOAuth2Conn', request, (client) => client.addUserOAuth2Conn(request));
}
exports('AddUserOAuth2Conn', AddUserOAuth2Conn);

async function AddAccountUpdate(request: AddAccountUpdateRequest): Promise<AddActivityResponse | undefined> {
    return callSync('AddAccountUpdate', request, (client) => client.addAccountUpdate(request));
}
exports('AddAccountUpdate', AddAccountUpdate);

async function AddUserUpdate(request: AddUserUpdateRequest): Promise<AddActivityResponse | undefined> {
    return callSync('AddUserUpdate', request, (client) => client.addUserUpdate(request));
}
exports('AddUserUpdate', AddUserUpdate);

async function AddUserActivity(request: AddUserActivityRequest): Promise<AddActivityResponse | undefined> {
    return callSync('AddUserActivity', request, (client) => client.addUserActivity(request));
}
exports('AddUserActivity', AddUserActivity);

async function AddUserProps(request: AddUserPropsRequest): Promise<AddActivityResponse | undefined> {
    return callSync('AddUserProps', request, (client) => client.addUserProps(request));
}
exports('AddUserProps', AddUserProps);

async function AddColleagueActivity(request: AddColleagueActivityRequest): Promise<AddActivityResponse | undefined> {
    return callSync('AddColleagueActivity', request, (client) => client.addColleagueActivity(request));
}
exports('AddColleagueActivity', AddColleagueActivity);

async function AddColleagueProps(request: AddColleaguePropsRequest): Promise<AddActivityResponse | undefined> {
    return callSync('AddColleagueProps', request, (client) => client.addColleagueProps(request));
}
exports('AddColleagueProps', AddColleagueProps);

async function AddJobTimeclock(request: AddJobTimeclockRequest): Promise<AddActivityResponse | undefined> {
    return callSync('AddJobTimeclock', request, (client) => client.addJobTimeclock(request));
}
exports('AddJobTimeclock', AddJobTimeclock);

async function AddDispatch(request: AddDispatchRequest): Promise<AddActivityResponse | undefined> {
    return callSync('AddDispatch', request, (client) => client.addDispatch(request));
}
exports('AddDispatch', AddDispatch);

// SendData calls

async function SendData(data: SendDataRequest['data']): Promise<SendDataResponse | undefined> {
    const request = SendDataRequest.create({
        data: data,
    });

    return callSync(`SendData (Kind: ${data.oneofKind})`, request, (client) => client.sendData(request));
}
exports('SendData', SendData);

async function SendJobs(request: SendJobsRequest): Promise<SendDataResponse | undefined> {
    return callSync('SendJobs', request, (client) => client.sendJobs(request));
}
exports('SendJobs', SendJobs);

async function SendLicenses(request: SendLicensesRequest): Promise<SendDataResponse | undefined> {
    return callSync('SendLicenses', request, (client) => client.sendLicenses(request));
}
exports('SendLicenses', SendLicenses);

async function SendAccounts(request: SendAccountsRequest): Promise<SendDataResponse | undefined> {
    return callSync('SendAccounts', request, (client) => client.sendAccounts(request));
}
exports('SendAccounts', SendAccounts);

async function SendUsers(request: SendUsersRequest): Promise<SendDataResponse | undefined> {
    return callSync('SendUsers', request, (client) => client.sendUsers(request));
}
exports('SendUsers', SendUsers);

async function SendVehicles(request: SendVehiclesRequest): Promise<SendDataResponse | undefined> {
    return callSync('SendVehicles', request, (client) => client.sendVehicles(request));
}
exports('SendVehicles', SendVehicles);

async function SendUserLocations(request: SendUserLocationsRequest): Promise<SendDataResponse | undefined> {
    return callSync('SendUserLocations', request, (client) => client.sendUserLocations(request));
}
exports('SendUserLocations', SendUserLocations);

async function SetLastCharID(request: SetLastCharIDRequest): Promise<SendDataResponse | undefined> {
    return callSync('SetLastCharID', request, (client) => client.setLastCharID(request));
}
exports('SetLastCharID', SetLastCharID);

// DeleteData calls

async function DeleteData(data: DeleteDataRequest['data']): Promise<DeleteDataResponse | undefined> {
    const request = DeleteDataRequest.create({
        data: data,
    });

    return callSync(`DeleteData (Kind: ${data.oneofKind})`, request, (client) => client.deleteData(request));
}
exports('DeleteData', DeleteData);

async function DeleteUsers(request: DeleteUsersRequest): Promise<DeleteDataResponse | undefined> {
    return callSync('DeleteUsers', request, (client) => client.deleteUsers(request));
}
exports('DeleteUsers', DeleteUsers);

async function DeleteVehicles(request: DeleteVehiclesRequest): Promise<DeleteDataResponse | undefined> {
    return callSync('DeleteVehicles', request, (client) => client.deleteVehicles(request));
}
exports('DeleteVehicles', DeleteVehicles);
