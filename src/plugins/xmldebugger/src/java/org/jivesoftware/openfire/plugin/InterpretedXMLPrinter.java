/*
 * Copyright (C) 2005-2008 Jive Software. All rights reserved.
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

package org.jivesoftware.openfire.plugin;

import org.jivesoftware.openfire.interceptor.PacketInterceptor;
import org.jivesoftware.openfire.session.Session;
import org.jivesoftware.util.JiveGlobals;
import org.xmpp.packet.Packet;

/**
 * Packet interceptor that prints to the stdout XML packets (i.e. XML after
 * it was parsed).<p>
 *
 * If you find in the logs an entry for raw XML, an entry that a session was closed and
 * never find the corresponding interpreted XML for the raw XML then there was an error
 * while parsing the XML that closed the session.
 *
 * @author Gaston Dombiak.
 */
public class InterpretedXMLPrinter implements PacketInterceptor {

    static final String PROPERTY_ENABLED = "plugin.debugger.interpretedAllowed";

    public void interceptPacket(final Packet packet, final Session session, final boolean incoming, final boolean processed) {
        if (!processed && incoming) {
            System.out.println("INTERPRETED: " + packet.toXML());
        }
    }

    public boolean isEnabled() {
        return JiveGlobals.getBooleanProperty(PROPERTY_ENABLED);
    }

    public void setEnabled(final boolean enabled) {
        JiveGlobals.setProperty(PROPERTY_ENABLED, Boolean.toString(enabled));
    }

}
