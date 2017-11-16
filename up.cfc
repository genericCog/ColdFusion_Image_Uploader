<!--- File: up.cfc
    Called From: index.cfm  Associated Files: index.cfm, profile_image_scripts.js, image_cropper.js, up_action.cfm, up.cfc
    Purpose: Common database queries
    Queries: get_session_user_profile
--->
<cfcomponent>
    
    <cffunction name="session_user_profile" access="public" returntype="query"><!--- establish user profile info --->
        <!---<cfset variables.impersonate_id=1234>---> <!---Impersonate User here for testing (1234 cherochak)   --->
        <cfquery name="get_session_user_profile" datasource="#request_the_database.source#">
            SELECT id, cac_edipi, first_name,  last_name,  middle_initial,  symbol,  phone_number
            FROM user_info
            WHERE 
                <cfif isdefined("variables.impersonate_id")>
                    id=<cfqueryparam value="#variables.impersonate_id#">
                <cfelse>
                    user_info.cac_edipi='#trim(listlast(cgi.cert_subject,"."))#'
                </cfif>
        </cfquery>
        <cfreturn get_session_user_profile>
    </cffunction>

</cfcomponent>