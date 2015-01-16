/*
 * Copyright (C) 2015 The CyanogenMod Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.android.internal.telephony;

import static com.android.internal.telephony.RILConstants.*;

import android.content.Context;
import android.os.Parcel;
import android.os.SystemProperties;
import android.util.Log;

/*
 * Custom Qualcomm RIL for Motorola MSM8960 phones
 *
 * {@hide}
 */
public class MotorolaQualcommRIL extends RIL implements CommandsInterface {
    public MotorolaQualcommRIL(Context context, int preferredNetworkType,
            int cdmaSubscription, Integer instanceId) {
        this(context, preferredNetworkType, cdmaSubscription);
    }

    public MotorolaQualcommRIL(Context context, int networkMode, int cdmaSubscription) {
        super(context, networkMode, cdmaSubscription);
    }

    @Override
    protected void
    processUnsolicited (Parcel p) {
        Object ret;
        int dataPosition = p.dataPosition(); // save off position within the Parcel
        int response = p.readInt();

        switch(response) {
            case RIL_UNSOL_RIL_CONNECTED: ret = responseInts(p); break;
            default:
                // Rewind the Parcel
                p.setDataPosition(dataPosition);
                // Forward responses that we are not overriding to the super class
                super.processUnsolicited(p);
                return;
        }
        switch(response) {
            case RIL_UNSOL_RIL_CONNECTED: {
                if (RILJ_LOGD) unsljLogRet(response, ret);

                // Initial conditions
                if (SystemProperties.get("ril.socket.reset").equals("1")) {
                    setRadioPower(false, null);
                }
                // Trigger socket reset if RIL connect is called again
                SystemProperties.set("ril.socket.reset", "1");
                setPreferredNetworkType(mPreferredNetworkType, null);
                setCdmaSubscriptionSource(mCdmaSubscription, null);
                setCellInfoListRate(Integer.MAX_VALUE, null);
                notifyRegistrantsRilConnectionChanged(((int[])ret)[0]);
                break;
            }
        }
    }
}
