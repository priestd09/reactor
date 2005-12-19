
<cfcomponent hint="I am the base Gateway object for the Country table.  I am generated.  DO NOT EDIT ME."
	extends="reactor.base.abstractGateway" >
	
	<cfset variables.signature = "208CB1E61781E239F5562C506D6BEEA6" />

	<cffunction name="getAll" access="public" hint="I return all rows from the Country table." output="false" returntype="query">
		<cfreturn getByFields() />
	</cffunction>
	
	<cffunction name="getByFields" access="public" hint="I return all matching rows from the Country table." output="false" returntype="query">
		
			<cfargument name="CountryId" hint="If provided, I match the provided value to the CountryId field in the Country table." required="no" type="string" />
		
			<cfargument name="Abbreviation" hint="If provided, I match the provided value to the Abbreviation field in the Country table." required="no" type="string" />
		
			<cfargument name="Name" hint="If provided, I match the provided value to the Name field in the Country table." required="no" type="string" />
		
			<cfargument name="SortOrder" hint="If provided, I match the provided value to the SortOrder field in the Country table." required="no" type="string" />
		
		<cfset var Query = createQuery() />
		<cfset var Where = Query.getWhere() />
		
		
			<cfif IsDefined('arguments.CountryId')>
				<cfset Where.isEqual(
					
							"Country"
						
				, "CountryId", arguments.CountryId) />
			</cfif>
		
			<cfif IsDefined('arguments.Abbreviation')>
				<cfset Where.isEqual(
					
							"Country"
						
				, "Abbreviation", arguments.Abbreviation) />
			</cfif>
		
			<cfif IsDefined('arguments.Name')>
				<cfset Where.isEqual(
					
							"Country"
						
				, "Name", arguments.Name) />
			</cfif>
		
			<cfif IsDefined('arguments.SortOrder')>
				<cfset Where.isEqual(
					
							"Country"
						
				, "SortOrder", arguments.SortOrder) />
			</cfif>
		
		
		<cfreturn getByQuery(Query) />
	</cffunction>
	
</cfcomponent>
	
