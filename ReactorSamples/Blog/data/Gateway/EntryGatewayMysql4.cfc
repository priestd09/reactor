<!---
	Mod 1/25/2006 SPJ: fixed getMatching() bug w/ MySql 4.0.x
--->
<cfcomponent hint="I am the mysql custom Gateway object for the Entry table.  I am generated, but not overwritten if I exist.  You are safe to edit me."
	extends="EntryGateway" >
	<!--- Place custom code here, it will not be overwritten --->
	
	<cffunction name="getMatching" access="public" hint="I return an array of matching blog entries records." output="false" returntype="query">
		<cfargument name="categoryId" hint="I am a category to match" required="yes" type="numeric" default="0" />
		<cfargument name="month" hint="I am a month to filter for" required="yes" type="numeric" default="0" />
		<cfargument name="year" hint="I am a year to filter for" required="yes" type="numeric" default="0" />
		<cfset var entries = 0 />
		<cfset var recentEntryCutoff = 0 /> 	<!--- needed for MySql 4.0.x b/c the date logic has to be done in CF --->
		
		<cfquery name="entries" datasource="#_getConfig().getDsn()#">
			SELECT e.entryId, e.title, e.preview,
				DATE_FORMAT(e.publicationDate, '%m/%d/%Y') as publicationDate,
				e.publicationDate as publicationDateTime,
				e.views, c.categoryId, c.name as categoryName, 
				u.firstName, u.lastName, e.disableComments,
				
				count(DISTINCT m.commentId) as commentCount,
				
				Round(e.totalRating/e.timesRated) as averageRating
				
			FROM Entry as e LEFT JOIN EntryCategory as ec
				ON e.entryId = ec.entryId
			LEFT JOIN Category as c
				ON ec.categoryId = c.categoryId
			JOIN User as u
				ON e.postedByUserId = u.userID
			LEFT JOIN Comment as m
				ON e.entryId = m.entryId
			
			WHERE e.publicationDate <= now()
				<!--- filter by categoryId --->
				<cfif arguments.categoryId>
					AND c.categoryId = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.categoryId#" />
				</cfif>
				<!--- filter by date --->
				<cfif arguments.month>
					AND MONTH(e.publicationDate) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.month#" />
				</cfif>
				<cfif arguments.year>
					AND YEAR(e.publicationDate) = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.year#" />
				</cfif>
				<cfif NOT arguments.categoryId AND NOT arguments.month AND NOT arguments.year>
					<!--- Mod by SPJ: MySql 4.0.x doesn't have DateDiff() so we have to do the date logic in CF --->
					<!---
						AND DateDiff(e.publicationDate, now()) <= <cfqueryparam cfsqltype="cf_sql_integer" value="#variables.recentEntryDays#" />
					--->
					<cfset recentEntryCutoff = DateAdd("d", -1 * variables.recentEntryDays, Now()) />
					AND e.publicationDate >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#recentEntryCutoff#" />
				</cfif>
			GROUP BY e.entryId, e.title, e.preview, 
				DATE_FORMAT(e.publicationDate, '%m/%d/%Y'),
				e.publicationDate,
				e.views, c.categoryId, c.name, 
				u.firstName, u.lastName, e.disableComments
			ORDER BY e.publicationDate DESC
		</cfquery>
		
		<cfreturn entries />
	</cffunction>
	
	<cffunction name="getHighestRatedEntries" access="public" hint="I return the highest rated entries"  output="false" returntype="query">
		<cfargument name="limit" hint="I am the maximum number of entries to return" required="yes" type="numeric" />
		<cfset var qHighest = 0 />
		
		<cfquery name="qHighest" datasource="#_getConfig().getDsn()#">
			SELECT e.entryId, e.title, Round(e.totalRating/e.timesRated) as averageRating
			FROM Entry as e
			ORDER BY averageRating DESC
			LIMIT 0, #arguments.limit#
		</cfquery>
		
		<cfreturn qHighest />
	</cffunction>
	
	<cffunction name="GetMostViewedEntries" access="public" hint="I return the most viewed entries"  output="false" returntype="query">
		<cfargument name="limit" hint="I am the maximum number of entries to return" required="yes" type="numeric" />
		<cfset var qViews = 0 />
		
		<cfquery name="qViews" datasource="#_getConfig().getDsn()#">
			SELECT e.entryId, e.title, e.views
			FROM Entry as e
			ORDER BY e.views DESC
			LIMIT 0, #arguments.limit#
		</cfquery>
		
		<cfreturn qViews />
	</cffunction>
	
	<cffunction name="GetMostCommentedOn" access="public" hint="I return the most commented on entries"  output="false" returntype="query">
		<cfargument name="limit" hint="I am the maximum number of entries to return" required="yes" type="numeric" />
		<cfset var qComments = 0 />
		
		<cfquery name="qComments" datasource="#_getConfig().getDsn()#">
			SELECT e.entryId, e.title, count(c.commentId) as comments
			FROM Entry as e JOIN Comment as c
				ON e.entryId = c.entryId
			GROUP BY e.entryId, e.title
			ORDER BY comments DESC
			LIMIT 0, #arguments.limit#
		</cfquery>
		
		<cfreturn qComments />
	</cffunction>
	
</cfcomponent>
	
