import {
    AddAccountUpdateRequest,
    AddActivityRequest,
    AddActivityResponse,
    AddColleagueActivityRequest,
    AddColleaguePropsRequest,
    AddDispatchRequest,
    AddJobTimeclockRequest,
    AddMarkerRequest,
    AddUserActivityRequest,
    AddUserOAuth2ConnRequest,
    AddUserPropsRequest,
    AddUserUpdateRequest,
    DeleteDataRequest,
    DeleteDataResponse,
    DeleteMarkerRequest,
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
import { syncClient } from './client';
import { Logger } from './logger';

async function callSync<Request, Response>(
    name: string,
    request: Request,
    call: (client: NonNullable<typeof syncClient>) => PromiseLike<{ response: Response }>,
): Promise<Response | undefined> {
    if (Logger.isDebugEnabled()) Logger.debug(`${name} request:`, request);

    if (!syncClient) {
        Logger.error('Sync client is not initialized');
        return;
    }

    try {
        const { response } = await call(syncClient);
        if (Logger.isDebugEnabled()) Logger.debug(`${name} response:`, response);
        return response;
    } catch (e) {
        Logger.error(`Error calling ${name}:`, e);
        return undefined;
    }
}

async function GetStatus(): Promise<GetStatusResponse | undefined> {
    const request = GetStatusRequest.create({});
    return callSync('GetStatus', request, (client) => client.getStatus(request));
}
exports('GetStatus', GetStatus);

async function RegisterAccount(
    license: string,
    resetToken: boolean,
    lastCharId?: number,
): Promise<RegisterAccountResponse | undefined> {
    const request = RegisterAccountRequest.create({
        identifier: license,
        resetToken: resetToken,
        lastCharId: lastCharId,
    });

    return callSync('RegisterAccount', request, (client) => client.registerAccount(request));
}
exports('RegisterAccount', RegisterAccount);

async function TransferAccount(oldLicense: string, newLicense: string): Promise<TransferAccountResponse | undefined> {
    const request = TransferAccountRequest.create({
        oldLicense: oldLicense,
        newLicense: newLicense,
    });

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
    const normalized = AddUserOAuth2ConnRequest.create(request);
    return callSync('AddUserOAuth2Conn', normalized, (client) => client.addUserOAuth2Conn(normalized));
}
exports('AddUserOAuth2Conn', AddUserOAuth2Conn);

async function AddAccountUpdate(request: AddAccountUpdateRequest): Promise<AddActivityResponse | undefined> {
    const normalized = AddAccountUpdateRequest.create(request);
    return callSync('AddAccountUpdate', normalized, (client) => client.addAccountUpdate(normalized));
}
exports('AddAccountUpdate', AddAccountUpdate);

async function AddUserUpdate(request: AddUserUpdateRequest): Promise<AddActivityResponse | undefined> {
    const normalized = AddUserUpdateRequest.create(request);
    return callSync('AddUserUpdate', normalized, (client) => client.addUserUpdate(normalized));
}
exports('AddUserUpdate', AddUserUpdate);

async function AddUserActivity(request: AddUserActivityRequest): Promise<AddActivityResponse | undefined> {
    const normalized = AddUserActivityRequest.create(request);
    return callSync('AddUserActivity', normalized, (client) => client.addUserActivity(normalized));
}
exports('AddUserActivity', AddUserActivity);

async function AddUserProps(request: AddUserPropsRequest): Promise<AddActivityResponse | undefined> {
    const normalized = AddUserPropsRequest.create(request);
    return callSync('AddUserProps', normalized, (client) => client.addUserProps(normalized));
}
exports('AddUserProps', AddUserProps);

async function AddColleagueActivity(request: AddColleagueActivityRequest): Promise<AddActivityResponse | undefined> {
    const normalized = AddColleagueActivityRequest.create(request);
    return callSync('AddColleagueActivity', normalized, (client) => client.addColleagueActivity(normalized));
}
exports('AddColleagueActivity', AddColleagueActivity);

async function AddColleagueProps(request: AddColleaguePropsRequest): Promise<AddActivityResponse | undefined> {
    const normalized = AddColleaguePropsRequest.create(request);
    return callSync('AddColleagueProps', normalized, (client) => client.addColleagueProps(normalized));
}
exports('AddColleagueProps', AddColleagueProps);

async function AddJobTimeclock(request: AddJobTimeclockRequest): Promise<AddActivityResponse | undefined> {
    const normalized = AddJobTimeclockRequest.create(request);
    return callSync('AddJobTimeclock', normalized, (client) => client.addJobTimeclock(normalized));
}
exports('AddJobTimeclock', AddJobTimeclock);

async function AddDispatch(request: AddDispatchRequest): Promise<AddActivityResponse | undefined> {
    const normalized = AddDispatchRequest.create(request);
    return callSync('AddDispatch', normalized, (client) => client.addDispatch(normalized));
}
exports('AddDispatch', AddDispatch);

async function AddMarker(request: AddMarkerRequest): Promise<AddActivityResponse | undefined> {
    const normalized = AddMarkerRequest.create(request);
    return callSync('AddMarker', normalized, (client) => client.addMarker(normalized));
}
exports('AddMarker', AddMarker);

async function DeleteMarker(request: DeleteMarkerRequest): Promise<DeleteDataResponse | undefined> {
    const normalized = DeleteMarkerRequest.create(request);
    return callSync('DeleteMarker', normalized, (client) => client.deleteMarker(normalized));
}
exports('DeleteMarker', DeleteMarker);

// SendData calls

async function SendData(data: SendDataRequest['data']): Promise<SendDataResponse | undefined> {
    const request = SendDataRequest.create({
        data: data,
    });

    return callSync(`SendData (Kind: ${data.oneofKind})`, request, (client) => client.sendData(request));
}
exports('SendData', SendData);

async function SendJobs(request: SendJobsRequest): Promise<SendDataResponse | undefined> {
    const normalized = SendJobsRequest.create(request);
    return callSync('SendJobs', normalized, (client) => client.sendJobs(normalized));
}
exports('SendJobs', SendJobs);

async function SendLicenses(request: SendLicensesRequest): Promise<SendDataResponse | undefined> {
    const normalized = SendLicensesRequest.create(request);
    return callSync('SendLicenses', normalized, (client) => client.sendLicenses(normalized));
}
exports('SendLicenses', SendLicenses);

async function SendAccounts(request: SendAccountsRequest): Promise<SendDataResponse | undefined> {
    const normalized = SendAccountsRequest.create(request);
    return callSync('SendAccounts', normalized, (client) => client.sendAccounts(normalized));
}
exports('SendAccounts', SendAccounts);

async function SendUsers(request: SendUsersRequest): Promise<SendDataResponse | undefined> {
    const normalized = SendUsersRequest.create(request);
    return callSync('SendUsers', normalized, (client) => client.sendUsers(normalized));
}
exports('SendUsers', SendUsers);

async function SendVehicles(request: SendVehiclesRequest): Promise<SendDataResponse | undefined> {
    const normalized = SendVehiclesRequest.create(request);
    return callSync('SendVehicles', normalized, (client) => client.sendVehicles(normalized));
}
exports('SendVehicles', SendVehicles);

async function SendUserLocations(request: SendUserLocationsRequest): Promise<SendDataResponse | undefined> {
    const normalized = SendUserLocationsRequest.create(request);
    return callSync('SendUserLocations', normalized, (client) => client.sendUserLocations(normalized));
}
exports('SendUserLocations', SendUserLocations);

async function SetLastCharID(request: SetLastCharIDRequest): Promise<SendDataResponse | undefined> {
    const normalized = SetLastCharIDRequest.create(request);
    return callSync('SetLastCharID', normalized, (client) => client.setLastCharID(normalized));
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
    const normalized = DeleteUsersRequest.create(request);
    return callSync('DeleteUsers', normalized, (client) => client.deleteUsers(normalized));
}
exports('DeleteUsers', DeleteUsers);

async function DeleteVehicles(request: DeleteVehiclesRequest): Promise<DeleteDataResponse | undefined> {
    const normalized = DeleteVehiclesRequest.create(request);
    return callSync('DeleteVehicles', normalized, (client) => client.deleteVehicles(normalized));
}
exports('DeleteVehicles', DeleteVehicles);
