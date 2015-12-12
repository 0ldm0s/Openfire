<%@ page import="org.jivesoftware.openfire.Connection" %>
<%@ page import="org.jivesoftware.openfire.XMPPServer" %>
<%@ page import="org.jivesoftware.openfire.component.ExternalComponentConfiguration" %>
<%@ page import="org.jivesoftware.openfire.component.ExternalComponentManager" %>
<%@ page import="org.jivesoftware.openfire.spi.ConnectionConfiguration" %>
<%@ page import="org.jivesoftware.openfire.spi.ConnectionListener" %>
<%@ page import="org.jivesoftware.openfire.spi.ConnectionManagerImpl" %>
<%@ page import="org.jivesoftware.openfire.spi.ConnectionType" %>
<%@ page import="org.jivesoftware.util.ModificationNotAllowedException" %>
<%@ page import="org.jivesoftware.util.ParamUtils" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page errorPage="error.jsp" %>

<%@ taglib uri="admin" prefix="admin" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<jsp:useBean id="webManager" class="org.jivesoftware.util.WebManager"  />
<% webManager.init(request, response, session, application, out ); %>
<%
    final ConnectionType connectionType = ConnectionType.COMPONENT;
    final ConnectionManagerImpl manager = (ConnectionManagerImpl) XMPPServer.getInstance().getConnectionManager();

    final ConnectionConfiguration plaintextConfiguration  = manager.getListener( connectionType, false ).generateConnectionConfiguration();
    final ConnectionConfiguration legacymodeConfiguration = manager.getListener( connectionType, true  ).generateConnectionConfiguration();

    final Map<String, String> errors = new HashMap<>();

    final boolean update = request.getParameter( "update" ) != null;

    if ( update && errors.isEmpty() )
    {
        // plaintext
        final boolean plaintextEnabled      = ParamUtils.getBooleanParameter( request, "plaintext-enabled" );
        final int plaintextTcpPort          = ParamUtils.getIntParameter( request, "plaintext-tcpPort", plaintextConfiguration.getPort() );
        final int plaintextReadBuffer       = ParamUtils.getIntParameter( request, "plaintext-readBuffer", plaintextConfiguration.getMaxBufferSize() );
        final String plaintextTlsPolicyText = ParamUtils.getParameter( request, "plaintext-tlspolicy", true );
        final Connection.TLSPolicy plaintextTlsPolicy;
        if ( plaintextTlsPolicyText == null || plaintextTlsPolicyText.isEmpty() ) {
            plaintextTlsPolicy = plaintextConfiguration.getTlsPolicy();
        } else {
            plaintextTlsPolicy = Connection.TLSPolicy.valueOf( plaintextTlsPolicyText );
        }
        final String plaintextMutualAuthenticationText = ParamUtils.getParameter( request, "plaintext-mutualauthentication", true );
        final Connection.ClientAuth plaintextMutualAuthentication;
        if ( plaintextMutualAuthenticationText == null || plaintextMutualAuthenticationText.isEmpty() ) {
            plaintextMutualAuthentication = plaintextConfiguration.getClientAuth();
        } else {
            plaintextMutualAuthentication = Connection.ClientAuth.valueOf( plaintextMutualAuthenticationText );
        }
        final int plaintextListenerMaxThreads = ParamUtils.getIntParameter( request, "plaintext-maxThreads", plaintextConfiguration.getMaxThreadPoolSize() );
        final boolean plaintextAcceptSelfSignedCertificates = ParamUtils.getBooleanParameter( request, "plaintext-accept-self-signed-certificates" );
        final boolean plaintextVerifyCertificateValidity = ParamUtils.getBooleanParameter( request, "plaintext-verify-certificate-validity" );

        // legacymode
        final boolean legacymodeEnabled      = ParamUtils.getBooleanParameter( request, "legacymode-enabled" );
        final int legacymodeTcpPort          = ParamUtils.getIntParameter( request, "legacymode-tcpPort", legacymodeConfiguration.getPort() );
        final int legacymodeReadBuffer       = ParamUtils.getIntParameter( request, "legacymode-readBuffer", legacymodeConfiguration.getMaxBufferSize() );
        final String legacymodeMutualAuthenticationText = ParamUtils.getParameter( request, "legacymode-mutualauthentication", true );
        final Connection.ClientAuth legacymodeMutualAuthentication;
        if ( legacymodeMutualAuthenticationText == null || legacymodeMutualAuthenticationText.isEmpty() ) {
            legacymodeMutualAuthentication = legacymodeConfiguration.getClientAuth();
        } else {
            legacymodeMutualAuthentication = Connection.ClientAuth.valueOf( legacymodeMutualAuthenticationText );
        }
        final int legacymodeListenerMaxThreads = ParamUtils.getIntParameter( request, "legacymode-maxThreads", legacymodeConfiguration.getMaxThreadPoolSize() );
        final boolean legacymodeAcceptSelfSignedCertificates = ParamUtils.getBooleanParameter( request, "legacymode-accept-self-signed-certificates" );
        final boolean legacymodeVerifyCertificateValidity = ParamUtils.getBooleanParameter( request, "legacymode-verify-certificate-validity" );

        // Apply
        final ConnectionListener plaintextListener  = manager.getListener( connectionType, false );
        final ConnectionListener legacymodeListener = manager.getListener( connectionType, true  );

        plaintextListener.enable( plaintextEnabled );
        plaintextListener.setPort( plaintextTcpPort );
        // TODO: plaintextListener.setMaxBufferSize( plaintextReadBuffer );
        plaintextListener.setTLSPolicy( plaintextTlsPolicy );
        plaintextListener.setClientAuth( plaintextMutualAuthentication );
        // TODO: plaintextListener.setMaxThreadPoolSize( plaintextListenerMaxThreads);
        plaintextListener.setAcceptSelfSignedCertificates( plaintextAcceptSelfSignedCertificates );
        plaintextListener.setVerifyCertificateValidity( plaintextVerifyCertificateValidity );

        legacymodeListener.enable( legacymodeEnabled );
        legacymodeListener.setPort( legacymodeTcpPort );
        // TODO: legacymodeListener.setMaxBufferSize( legacymodeReadBuffer );
        legacymodeListener.setClientAuth( legacymodeMutualAuthentication );
        // TODO:  legacymodeListener.setMaxThreadPoolSize( legacymodeListenerMaxThreads);
        legacymodeListener.setAcceptSelfSignedCertificates( legacymodeAcceptSelfSignedCertificates );
        legacymodeListener.setVerifyCertificateValidity( legacymodeVerifyCertificateValidity );

        // Log the event
        webManager.logEvent( "Updated connection settings for " + connectionType, "Applied configuration to plain-text as well as legacy-mode connection listeners." );
        response.sendRedirect( "connection-settings-external-components.jsp?success=true" );
        return;
    }

    // Process Permission update configuration change.
    final boolean permissionUpdate = request.getParameter( "permissionUpdate" ) != null;

    if ( permissionUpdate && errors.isEmpty() )
    {
        final String defaultSecret = ParamUtils.getParameter( request, "defaultSecret" );
        final String permissionFilter = ParamUtils.getParameter( request, "permissionFilter" );
        if ( defaultSecret == null || defaultSecret.trim().isEmpty() )
        {
            errors.put( "defaultSecret", "" );
        }
        else
        {
            try
            {
                ExternalComponentManager.setPermissionPolicy( permissionFilter );
                ExternalComponentManager.setDefaultSecret( defaultSecret );

                // Log the event
                webManager.logEvent( "set external component permission policy", "filter = " + permissionFilter );
                response.sendRedirect( "connection-settings-external-components.jsp?success=true" );
                return;
            }
            catch ( ModificationNotAllowedException e )
            {
                errors.put( "permission", e.getMessage() );
            }
        }
    }

    // Process removal of a blacklist or whitelist item.
    final String configToDelete = ParamUtils.getParameter( request, "deleteConf" );

    if ( configToDelete != null && !configToDelete.trim().isEmpty() && errors.isEmpty() )
    {
        try
        {
            ExternalComponentManager.deleteConfiguration( configToDelete );

            // Log the event
            webManager.logEvent( "deleted a external component configuration", "config is " + configToDelete );
            response.sendRedirect( "connection-settings-external-components.jsp?success=delete" );
            return;
        }
        catch ( ModificationNotAllowedException e )
        {
            errors.put( "delete", e.getMessage() );
        }
    }

    // Process addition to whitelist.
    final boolean componentAllowed = request.getParameter( "componentAllowed" ) != null;
    String subdomain = ParamUtils.getParameter( request, "subdomain" ); // shared with blacklist.
    if ( subdomain != null )
    {
        // Remove the hostname if the user is not sending just the subdomain.
        subdomain = subdomain.replace( "." + XMPPServer.getInstance().getServerInfo().getXMPPDomain(), "" );
    }
    if ( componentAllowed && errors.isEmpty() )
    {
        final String secret = ParamUtils.getParameter( request, "secret" );

        // Validate params
        if ( subdomain == null || subdomain.trim().isEmpty() )
        {
            errors.put( "subdomain", "" );
        }
        if ( secret == null || secret.trim().isEmpty() )
        {
            errors.put( "secret", "" );
        }

        // If no errors, continue:
        if ( errors.isEmpty() )
        {
            final ExternalComponentConfiguration configuration = new ExternalComponentConfiguration( subdomain, false, ExternalComponentConfiguration.Permission.allowed, secret );
            try
            {
                ExternalComponentManager.allowAccess( configuration );

                // Log the event
                webManager.logEvent( "allowed external component access", "configuration = " + configuration );
                response.sendRedirect( "connection-settings-external-components.jsp?success=allow" );
                return;
            }
            catch ( ModificationNotAllowedException e )
            {
                errors.put( "allow", e.getMessage() );
            }
        }
    }

    // Process addition to blacklist.
    final boolean componentBlocked = request.getParameter( "componentBlocked" ) != null;

    if ( componentBlocked && errors.isEmpty() )
    {
        if ( subdomain == null || subdomain.trim().isEmpty() )
        {
            errors.put( "subdomain", "" );
        }

        // If no errors, continue:
        if ( errors.isEmpty() )
        {
            try
            {
                ExternalComponentManager.blockAccess( subdomain );

                // Log the event
                webManager.logEvent( "blocked external component access", "subdomain = " + subdomain );
                response.sendRedirect( "connection-settings-external-components.jsp?success=block" );
                return;
            }
            catch ( ModificationNotAllowedException e )
            {
                errors.put( "block", e.getMessage() );
            }
        }
    }
    pageContext.setAttribute( "errors",                  errors );
    pageContext.setAttribute( "plaintextConfiguration",  plaintextConfiguration );
    pageContext.setAttribute( "legacymodeConfiguration", legacymodeConfiguration );

    pageContext.setAttribute( "defaultSecret", ExternalComponentManager.getDefaultSecret() );
    pageContext.setAttribute( "permissionFilter", ExternalComponentManager.getPermissionPolicy() );
    pageContext.setAttribute( "allowedComponents", ExternalComponentManager.getAllowedComponents() );
    pageContext.setAttribute( "blockedComponents", ExternalComponentManager.getBlockedComponents() );
%>
<html>
<head>
    <title><fmt:message key="component.settings.title"/></title>
    <meta name="pageID" content="external-components-settings"/>
    <script type="text/javascript">
        // Displays or hides the configuration block for a particular connection type, based on the status of the
        // 'enable' checkbox for that connection type.
        function applyDisplayable( connectionType )
        {
            var configBlock, enabled;

            // Select the right configuration block and enable or disable it as defined by the the corresponding checkbox.
            configBlock = document.getElementById( connectionType + "-config" );
            enabled     = document.getElementById( connectionType + "-enabled" ).checked;

            if ( ( configBlock != null ) && ( enabled != null ) )
            {
                if ( enabled )
                {
                    configBlock.style.display = "block";
                }
                else
                {
                    configBlock.style.display = "none";
                }
            }
        }

        // Ensure that the various elements are set properly when the page is loaded.
        window.onload = function()
        {
            applyDisplayable( "plaintext" );
            applyDisplayable( "legacymode" );
        };
    </script>
</head>
<body>

<c:choose>
    <c:when test="${not empty param.success and empty errors}">
        <admin:infoBox type="success">
            <c:choose>
                <c:when test="${param.success eq 'allow'}"><fmt:message key="component.settings.confirm.allowed"/></c:when>
                <c:when test="${param.success eq 'block'}"><fmt:message key="component.settings.confirm.blocked"/></c:when>
                <c:when test="${param.success eq 'delete'}"><fmt:message key="component.settings.confirm.deleted"/></c:when>
                <c:otherwise><fmt:message key="component.settings.confirm.updated"/></c:otherwise>
            </c:choose>
        </admin:infoBox>
    </c:when>
    <c:otherwise>
        <c:forEach var="err" items="${errors}">
            <admin:infobox type="error">
                <c:choose>
                    <c:when test="${err.key eq 'defaultSecret'}"><fmt:message key="component.settings.valid.defaultSecret"/></c:when>
                    <c:when test="${err.key eq 'subdomain'}"><fmt:message key="component.settings.valid.subdomain"/></c:when>
                    <c:when test="${err.key eq 'secret'}"><fmt:message key="component.settings.valid.secret"/></c:when>
                    <c:otherwise>
                        <c:if test="${not empty err.value}">
                            <fmt:message key="admin.error"/>: <c:out value="${err.value}"/>
                        </c:if>
                        (<c:out value="${err.key}"/>)
                    </c:otherwise>
                </c:choose>
            </admin:infobox>
        </c:forEach>
    </c:otherwise>
</c:choose>

<p>
    <fmt:message key="component.settings.info">
        <fmt:param value="<a href='component-session-summary.jsp'>" />
        <fmt:param value="</a>" />
    </fmt:message>
</p>

<form action="connection-settings-external-components.jsp" method="post">

    <admin:contentBox title="Plain-text (with STARTTLS) connections">

        <p>Openfire can accept plain-text connections, which, depending on the policy that is configured here, can be upgraded to encrypted connections (using the STARTTLS protocol).</p>

        <table cellpadding="3" cellspacing="0" border="0">
            <tr valign="middle">
                <td>
                    <input type="checkbox" name="plaintext-enabled" id="plaintext-enabled" onclick="applyDisplayable('plaintext')" ${plaintextConfiguration.enabled ? 'checked' : ''}/><label for="plaintext-enabled">Enabled</label>
                </td>
            </tr>
        </table>

        <div id="plaintext-config">

            <br/>

            <h4>TCP settings</h4>
            <table cellpadding="3" cellspacing="0" border="0">
                <tr valign="middle">
                    <td width="1%" nowrap><label for="plaintext-tcpPort">Port number</label></td>
                    <td width="99%"><input type="text" name="plaintext-tcpPort" id="plaintext-tcpPort" value="${plaintextConfiguration.port}"/></td>
                </tr>
                <tr valign="middle">
                    <td width="1%" nowrap><label for="plaintext-readBuffer">Read buffer</label></td>
                    <td width="99%"><input type="text" name="plaintext-readBuffer" id="plaintext-readBuffer" value="${plaintextConfiguration.maxBufferSize}" readonly/> (in bytes)</td>
                </tr>
            </table>

            <br/>

            <h4>STARTTLS policy</h4>
            <table cellpadding="3" cellspacing="0" border="0">
                <tr valign="middle">
                    <td>
                        <input type="radio" name="plaintext-tlspolicy" value="disabled" id="plaintext-tlspolicy-disabled" ${plaintextConfiguration.tlsPolicy.name() eq 'disabled' ? 'checked' : ''}/>
                        <label for="plaintext-tlspolicy-disabled"><b>Disabled</b> - Encryption is not allowed.</label>
                    </td>
                </tr>
                <tr valign="middle">
                    <td>
                        <input type="radio" name="plaintext-tlspolicy" value="optional" id="plaintext-tlspolicy-optional" ${plaintextConfiguration.tlsPolicy.name() eq 'optional' ? 'checked' : ''}/>
                        <label for="plaintext-tlspolicy-optional"><b>Optional</b> - Encryption may be used, but is not required.</label>
                    </td>
                </tr>
                <tr valign="middle">
                    <td>
                        <input type="radio" name="plaintext-tlspolicy" value="required" id="plaintext-tlspolicy-required" ${plaintextConfiguration.tlsPolicy.name() eq 'required' ? 'checked' : ''}/>
                        <label for="plaintext-tlspolicy-required"><b>Required</b> - Connections cannot be established unless they are encrypted.</label>
                    </td>
                </tr>
            </table>

            <br/>

            <h4>Mutual Authentication</h4>
            <p>In addition to requiring peers to use encryption (which will force them to verify the security certificates of this Openfire instance) an additional level of security can be enabled. With this option, the server can be configured to verify certificates that are to be provided by the peers. This is commonly referred to as 'mutual authentication'.</p>
            <table cellpadding="3" cellspacing="0" border="0">
                <tr valign="middle">
                    <td>
                        <input type="radio" name="plaintext-mutualauthentication" value="disabled" id="plaintext-mutualauthentication-disabled" ${plaintextConfiguration.clientAuth.name() eq 'disabled' ? 'checked' : ''}/>
                        <label for="plaintext-mutualauthentication-disabled"><b>Disabled</b> - Peer certificates are not verified.</label>
                    </td>
                </tr>
                <tr valign="middle">
                    <td>
                        <input type="radio" name="plaintext-mutualauthentication" value="wanted" id="plaintext-mutualauthentication-wanted" ${plaintextConfiguration.clientAuth.name() eq 'wanted' ? 'checked' : ''}/>
                        <label for="plaintext-mutualauthentication-wanted"><b>Wanted</b> - Peer certificates are verified, but only when they are presented by the peer.</label>
                    </td>
                </tr>
                <tr valign="middle">
                    <td>
                        <input type="radio" name="plaintext-mutualauthentication" value="needed" id="plaintext-mutualauthentication-needed" ${plaintextConfiguration.clientAuth.name() eq 'needed' ? 'checked' : ''}/>
                        <label for="plaintext-mutualauthentication-needed"><b>Needed</b> - A connection cannot be established if the peer does not present a valid certificate.</label>
                    </td>
                </tr>
            </table>

            <br/>

            <h4>Certificate chain checking</h4>
            <p>These options configure some aspects of the verification/validation of the certificates that are presented by peers while setting up encrypted connections.</p>
            <table cellpadding="3" cellspacing="0" border="0">
                <tr valign="middle">
                    <td>
                        <input type="checkbox" name="plaintext-accept-self-signed-certificates" id="plaintext-accept-self-signed-certificates" ${plaintextConfiguration.acceptSelfSignedCertificates ? 'checked' : ''}/><label for="plaintext-accept-self-signed-certificates">Allow peer certificates to be self-signed.</label>
                    </td>
                </tr>
                <tr valign="middle">
                    <td>
                        <input type="checkbox" name="plaintext-verify-certificate-validity" id="plaintext-verify-certificate-validity" ${plaintextConfiguration.verifyCertificateValidity ? 'checked' : ''}/><label for="plaintext-verify-certificate-validity">Verify that the certificate is currently valid (based on the 'notBefore' and 'notAfter' values of the certificate).</label>
                    </td>
                </tr>
            </table>

            <br/>

            <h4>Miscellaneous settings</h4>
            <table cellpadding="3" cellspacing="0" border="0">
                <tr valign="middle">
                    <td width="1%" nowrap><label for="plaintext-maxThreads">Maximum worker threads</label></td>
                    <td width="99%"><input type="text" name="plaintext-maxThreads" id="plaintext-maxThreads" value="${plaintextConfiguration.maxThreadPoolSize}" readonly/></td>
                </tr>
            </table>

        </div>

    </admin:contentBox>

    <admin:contentBox title="Encrypted (legacy-mode) connections">

        <p>Connections of this type are established using encryption immediately (as opposed to using STARTTLS). This type of connectivity is commonly referred to as the "legacy" method of establishing encrypted communications.</p>

        <table cellpadding="3" cellspacing="0" border="0">
            <tr valign="middle">
                <td><input type="checkbox" name="legacymode-enabled" id="legacymode-enabled" onclick="applyDisplayable('legacymode')" ${legacymodeConfiguration.enabled ? 'checked' : ''}/><label for="legacymode-enabled">Enabled</label></td>
            </tr>
        </table>

        <div id="legacymode-config">

            <br/>

            <h4>TCP settings</h4>
            <table cellpadding="3" cellspacing="0" border="0">
                <tr valign="middle">
                    <td width="1%" nowrap><label for="legacymode-tcpPort">Port number</label></td>
                    <td width="99%"><input type="text" name="legacymode-tcpPort" id="legacymode-tcpPort" value="${legacymodeConfiguration.port}"></td>
                </tr>
                <tr valign="middle">
                    <td width="1%" nowrap><label for="legacymode-readBuffer">Read buffer</label></td>
                    <td width="99%"><input type="text" name="legacymode-readBuffer" id="legacymode-readBuffer" value="${legacymodeConfiguration.maxBufferSize}" readonly/> (in bytes)</td>
                </tr>
            </table>

            <br/>

            <h4>Mutual Authentication</h4>
            <p>In addition to requiring peers to use encryption (which will force them to verify the security certificates of this Openfire instance) an additional level of security can be enabled. With this option, the server can be configured to verify certificates that are to be provided by the peers. This is commonly referred to as 'mutual authentication'.</p>
            <table cellpadding="3" cellspacing="0" border="0">
                <tr valign="middle">
                    <td>
                        <input type="radio" name="legacymode-mutualauthentication" value="disabled" id="legacymode-mutualauthentication-disabled" ${legacymodeConfiguration.clientAuth.name() eq 'disabled' ? 'checked' : ''}/>
                        <label for="legacymode-mutualauthentication-disabled"><b>Disabled</b> - Peer certificates are not verified.</label>
                    </td>
                </tr>
                <tr valign="middle">
                    <td>
                        <input type="radio" name="legacymode-mutualauthentication" value="wanted" id="legacymode-mutualauthentication-wanted" ${legacymodeConfiguration.clientAuth.name() eq 'optional' ? 'checked' : ''}/>
                        <label for="legacymode-mutualauthentication-wanted"><b>Wanted</b> - Peer certificates are verified, but only when they are presented by the peer.</label>
                    </td>
                </tr>
                <tr valign="middle">
                    <td>
                        <input type="radio" name="legacymode-mutualauthentication" value="needed" id="legacymode-mutualauthentication-needed" ${legacymodeConfiguration.clientAuth.name() eq 'required' ? 'checked' : ''}/>
                        <label for="legacymode-mutualauthentication-needed"><b>Needed</b> - A connection cannot be established if the peer does not present a valid certificate.</label>
                    </td>
                </tr>
            </table>

            <br/>

            <h4>Certificate chain checking</h4>
            <p>These options configure some aspects of the verification/validation of the certificates that are presented by peers while setting up encrypted connections.</p>
            <table cellpadding="3" cellspacing="0" border="0">
                <tr valign="middle">
                    <td>
                        <input type="checkbox" name="legacymode-accept-self-signed-certificates" id="legacymode-accept-self-signed-certificates" ${legacymodeConfiguration.acceptSelfSignedCertificates ? 'checked' : ''}/><label for="legacymode-accept-self-signed-certificates">Allow peer certificates to be self-signed.</label>
                    </td>
                </tr>
                <tr valign="middle">
                    <td>
                        <input type="checkbox" name="legacymode-verify-certificate-validity" id="legacymode-verify-certificate-validity" ${legacymodeConfiguration.verifyCertificateValidity ? 'checked' : ''}/><label for="legacymode-verify-certificate-validity">Verify that the certificate is currently valid (based on the 'notBefore' and 'notAfter' values of the certificate).</label>
                    </td>
                </tr>
            </table>

            <br/>

            <h4>Miscellaneous settings</h4>
            <table cellpadding="3" cellspacing="0" border="0">
                <tr valign="middle">
                    <td width="1%" nowrap><label for="legacymode-maxThreads">Maximum worker threads</label></td>
                    <td width="99%"><input type="text" name="legacymode-maxThreads" id="legacymode-maxThreads" value="${legacymodeConfiguration.maxThreadPoolSize}" readonly/></td>
                </tr>
            </table>

        </div>

    </admin:contentBox>

    <input type="submit" name="update" value="<fmt:message key="global.save_settings" />">
</form>

<!-- BEGIN 'Allowed to Connect' -->
<c:set var="allowedTitle">
    <fmt:message key="component.settings.allowed" />
</c:set>
<admin:contentBox title="${allowedTitle}">
    <form action="connection-settings-external-components.jsp" method="post">
        <table cellpadding="3" cellspacing="0" border="0" width="100%" >
            <tr valign="top">
                <td colspan="2">
                    <label for="defaultSecret"><fmt:message key="component.settings.defaultSecret" /></label>&nbsp;
                    <input type="text" size="15" maxlength="70" name="defaultSecret" id="defaultSecret" value="${defaultSecret}"/>
                </td>
            </tr>

            <tr valign="top">
                <td width="1%" nowrap>
                    <input type="radio" name="permissionFilter" value="blacklist" id="rb03" ${permissionFilter eq "blacklist" ? "checked" : ""}>
                </td>
                <td width="99%">
                    <label for="rb03">
                        <b><fmt:message key="component.settings.anyone" /></b> - <fmt:message key="component.settings.anyone_info" />
                    </label>
                </td>
            </tr>
            <tr valign="top">
                <td width="1%">
                    <input type="radio" name="permissionFilter" value="whitelist" id="rb04" ${permissionFilter eq "whitelist" ? "checked" : ""}>
                </td>
                <td width="99%" nowrap>
                    <label for="rb04">
                        <b><fmt:message key="component.settings.whitelist" /></b> - <fmt:message key="component.settings.whitelist_info" />
                    </label>
                </td>
            </tr>
        </table>

        <br/>

        <input type="submit" name="permissionUpdate" value="<fmt:message key="global.save_settings" />">
    </form>

    <br>

    <table class="jive-table" cellpadding="0" cellspacing="0" border="0">
        <tr>
            <th width="1%">&nbsp;</th>
            <th width="50%" nowrap><fmt:message key="component.settings.subdomain" /></th>
            <th width="49%" nowrap><fmt:message key="component.settings.secret" /></th>
            <th width="10%" nowrap><fmt:message key="global.delete" /></th>
        </tr>
        <c:choose>
            <c:when test="${empty allowedComponents}">
                <tr>
                    <td align="center" colspan="7"><fmt:message key="component.settings.empty_list" /></td>
                </tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="component" varStatus="status" items="${allowedComponents}">
                    <tr class="${ ( (status.index + 1) % 2 ) eq 0 ? 'jive-even' : 'jive-odd'}">
                        <td>${ status.index + 1}</td>
                        <td><c:out value="${component.subdomain}"/></td>
                        <td><c:out value="${component.secret}"/></td>
                        <td align="center" style="border-right:1px #ccc solid;">
                            <a href="#" onclick="if (confirm('<fmt:message key="component.settings.confirm_delete" />')) { location.replace('connection-settings-external-components.jsp?deleteConf=${component.subdomain}'); } "
                               title="<fmt:message key="global.click_delete" />"><img src="images/delete-16x16.gif" width="16" height="16" border="0" alt=""></a>
                        </td>
                    </tr>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </table>

    <br/>

    <form action="connection-settings-external-components.jsp" method="post">
        <table cellpadding="3" cellspacing="1" border="0">
            <tr>
                <td nowrap width="1%">
                    <label for="componentAllowedSubdomain"><fmt:message key="component.settings.subdomain" /></label>
                </td>
                <td>
                    <input type="text" size="40" name="subdomain" id="componentAllowedSubdomain" value="${param.containsKey('componentAllowed') and not empty errors ? param[ 'subdomain' ] : ''}"/>
                </td>
                <td nowrap width="1%">
                    <label for="componentAllowedSecret"><fmt:message key="component.settings.secret" /></label>
                </td>
                <td>
                    <input type="text" size="15" name="secret" id="componentAllowedSecret" value="${param.containsKey('componentAllowed') and not empty errors ? param[ 'secret' ] : ''}"/>
                </td>
            </tr>
            <tr align="center">
                <td colspan="4">
                    <input type="submit" name="componentAllowed" value="<fmt:message key="component.settings.allow" />">
                </td>
            </tr>
        </table>
    </form>
</admin:contentBox>
<!-- END 'Allowed to Connect' -->

<!-- BEGIN 'Not Allowed to Connect' -->
<c:set var="disallowedTitle">
    <fmt:message key="component.settings.disallowed" />
</c:set>
<admin:contentBox title="${disallowedTitle}">
    <p><fmt:message key="component.settings.disallowed.info" /></p>
    <table class="jive-table" cellpadding="3" cellspacing="0" border="0" >
        <tr>
            <th width="1%">&nbsp;</th>
            <th width="89%" nowrap><fmt:message key="component.settings.subdomain" /></th>
            <th width="10%" nowrap><fmt:message key="global.delete" /></th>
        </tr>
        <c:choose>
            <c:when test="${empty blockedComponents}">
                <tr>
                    <td align="center" colspan="7"><fmt:message key="component.settings.empty_list" /></td>
                </tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="component" varStatus="status" items="${blockedComponents}">
                    <tr class="${ ( (status.index + 1) % 2 ) eq 0 ? 'jive-even' : 'jive-odd'}">
                        <td>${ status.index + 1}</td>
                        <td><c:out value="${component.subdomain}"/></td>
                        <td align="center" style="border-right:1px #ccc solid;">
                            <a href="#" onclick="if (confirm('<fmt:message key="component.settings.confirm_delete" />')) { location.replace('connection-settings-external-components.jsp?deleteConf=${component.subdomain}'); } "
                               title="<fmt:message key="global.click_delete" />"><img src="images/delete-16x16.gif" width="16" height="16" border="0" alt=""></a>
                        </td>
                    </tr>
                </c:forEach>
            </c:otherwise>
        </c:choose>
    </table>

    <br/>

    <form action="connection-settings-external-components.jsp" method="post">
        <table cellpadding="3" cellspacing="1" border="0">
            <tr>
                <td nowrap width="1%">
                    <label for="disallowedSubdomain"><fmt:message key="component.settings.subdomain" /></label>
                </td>
                <td>
                    <input type="text" size="40" name="subdomain" id="disallowedSubdomain"/>&nbsp;
                    <input type="submit" name="componentBlocked" value="<fmt:message key="component.settings.block" />">
                </td>
            </tr>
        </table>
    </form>

</admin:contentBox>
<!-- END 'Not Allowed to Connect' -->

</body>
</html>