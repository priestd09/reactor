
<cfcomponent hint="I am the postgresql custom Metadata object for the EntryCategory table.  I am generated, but not overwritten if I exist.  You are safe to edit me."
	extends="EntryCategoryMetadata">
	<!--- Place custom code here, it will not be overwritten --->

	<cfset variables.metadata.owner = "postgres" />
	<cfset variables.metadata.dbms = "postgresql" />
	
</cfcomponent>
	
