import { AddActivityRequest, AddActivityResponse } from '@fivenet-app/gen/services/sync/sync';
import { syncClient } from './client';

type Activity = AddActivityRequest['activity'];
async function AddActivity(activity: Activity): Promise<AddActivityResponse> {
    const call = syncClient.addActivity({
        activity: activity,
    });

    const { response } = await call;
    return response;
}
exports('AddActivity', AddActivity);

// TODO add wrappers for each oneof type of Activity
