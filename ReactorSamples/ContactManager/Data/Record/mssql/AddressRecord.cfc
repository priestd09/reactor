
<cfcomponent hint="I am the custom Record object for the  table.  I am generated, but not overwritten if I exist.  You are safe to edit me."
	extends="ContactManagerData.Record.mssql.base.AddressRecord" >
	<!--- Place custom code here, it will not be overwritten --->
	
	<cffunction name="validate" access="public" hint="I validate this object and populate and return a ValidationErrorCollection object." output="false" returntype="reactor.util.ValidationErrorCollection">
		<cfargument name="ValidationErrorCollection" hint="I am the ValidationErrorCollection to populate." required="no" type="reactor.util.ValidationErrorCollection" default="#createErrorCollection()#" />
		<cfset var ErrorManager = CreateObject("Component", "reactor.core.ErrorManager").init(expandPath("#_getConfig().getMapping()#/ErrorMessages.xml")) />
		<cfset super.validate(arguments.ValidationErrorCollection) />
		
		<!--- Add custom validation logic here, it will not be overwritten --->
		
		<cfreturn arguments.ValidationErrorCollection />
	</cffunction>
	
	<cffunction name="format" access="public" hint="I am a custom method created to demonstrate how to extend and customize Reactor created objects" output="false" returntype="string">
		<cfset var format = "" />
		
		<cfoutput>
			<cfsavecontent variable="format">
				#getLine1()#<br>
				<cfif Len(getLine2())>
					#getLine2()#<br>
				</cfif>
				#getCity()#, #getStateRecord().getAbbreviation()# #getPostalCode()#<br>
				#getCountryRecord().getName()#
			</cfsavecontent>
		</cfoutput>
		
		<cfreturn format />
	</cffunction>
	
</cfcomponent>
	