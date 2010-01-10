/**
 * $RCSfile$
 * $Revision: 19263 $
 * $Date: 2005-07-08 15:30:05 -0700 (Fri, 08 Jul 2005) $
 *
 * Copyright (C) 2004-2008 Jive Software. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.jivesoftware.xmpp.workgroup.interceptor;

import java.util.Arrays;
import java.util.Collection;

/**
 * Manages the packet interceptors that will be invoked when sending an offer to an agent or when
 * an agent accepts or rejects the offer.
 *
 * @author Gaston Dombiak
 */
public class OfferInterceptorManager extends InterceptorManager {

    private static InterceptorManager instance = new OfferInterceptorManager();

    /**
     * Returns a singleton instance of OfferInterceptorManager.
     *
     * @return an instance of OfferInterceptorManager.
     */
    public static InterceptorManager getInstance() {
        return instance;
    }

    protected String getPropertySuffix() {
        return "offer";
    }

    protected Collection<Class> getBuiltInInterceptorClasses() {
        return Arrays.asList((Class) TrafficMonitor.class);
    }
}