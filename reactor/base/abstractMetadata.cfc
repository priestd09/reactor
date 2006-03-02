<cfcomponent hint="I am an abstract Metadata.  I am used to define an interface and return types." extends="reactor.base.abstractObject">

	<cffunction name="getConventions" access="public" hint="I return a conventions object specific for this database type." output="false" returntype="reactor.data.abstractConvention">
		<cfreturn CreateObject("Component", "reactor.data.#getDbms()#.Convention") />
	</cffunction>
	
	<cffunction name="getDatabase" access="public" hint="I return the name of the database this object is in." output="false" returntype="string">
		<cfreturn getObjectMetadata().database />
	</cffunction>

	<cffunction name="getDbms" access="public" hint="I return the name of the database this object is in." output="false" returntype="string">
		<cfreturn getObjectMetadata().dbms />
	</cffunction>
	
	<cffunction name="getName" access="public" hint="I return the name of the object." output="false" returntype="string">
		<cfreturn getObjectMetadata().name />
	</cffunction>
	
	<cffunction name="getAlias" access="public" hint="I return the alias of the object." output="false" returntype="string">
		<cfreturn getObjectMetadata().alias />
	</cffunction>
	
	<cffunction name="getOwner" access="public" hint="I return the owner of this object." output="false" returntype="string">
		<cfreturn getObjectMetadata().owner />
	</cffunction>
	
	<cffunction name="getType" access="public" hint="I return the type of object (view, table)." output="false" returntype="string">
		<cfreturn getObjectMetadata().type />
	</cffunction>
	
	<cffunction name="getFields" access="public" hint="I return an array of structures describing this object's fields" output="false" returntype="array">
		<cfreturn getObjectMetadata().fields />
	</cffunction>
	
	<cffunction name="getFieldQuery" access="public" hint="I return an Query of describing this object's fields" output="false" returntype="query">
		<cfset var fields = getFields() />
		<cfset var fieldQuery = QueryNew(StructKeyList(fields[1])) />
		<cfset var x = 0 />
		<cfset var field = "" />
		
		<cfloop from="1" to="#ArrayLen(fields)#" index="x">
			<cfset QueryAddRow(fieldQuery) />
			<cfloop collection="#fields[x]#" item="field">
				<cfset QuerySetCell(fieldQuery, field, fields[x][field]) />					
			</cfloop>
		</cfloop>
		
		<cfreturn fieldQuery/>
	</cffunction>
	
	<cffunction name="getField" access="public" hint="I return a structure of data about a specific field." output="false" returntype="struct">
		<cfargument name="alias" hint="I am the alias of the field to get" required="yes" type="string" />
		<cfset var fields = getFields() />
		<cfset var field = 0 />
		<cfset var x = 0 />
		
		<!--- loop over the fields and look for a match --->
		<cfloop from="1" to="#ArrayLen(fields)#" index="x">
			<cfif fields[x].alias IS arguments.alias>
				<cfset field = fields[x] />
				<cfbreak />
			</cfif>
		</cfloop>
		
		<cfif IsStruct(field)>
			<!--- return the field's attributes --->
			<cfreturn field />
				
		<cfelse>
			<cfthrow message="Field Does Not Exist" detail="The field '#arguments.alias#' does not exist for the '#getAlias()#' object." type="reactor.getField.FieldDoesNotExist" />
			
		</cfif>
	</cffunction>
	
	<cffunction name="getFieldList" access="public" hint="I return a list of fields in this object." output="false" returntype="string">
		<cfset var fields = getFields() />
		<cfset var superFields = 0 />
		<cfset var columList = "" />
		<cfset var field = "" />
		<cfset var x = 0 />
		
		<cfloop from="1" to="#ArrayLen(fields)#" index="x">
			<cfset columList = ListAppend(columList, fields[x].alias) />
		</cfloop>
		
		<cfreturn columList />
	</cffunction>
	
	<!--- getRelationships --->
	<cffunction name="getRelationships" access="public" hint="I get an array of all relationships" output="false" returntype="array">
		<cfset var objectMetadata = getObjectMetadata() />
		<cfset var allRelationships = ArrayNew(1) />
		<cfset var relationships = 0 />
		<cfset var x = 0 />
		
		<!--- check the hasone relationships --->
		<cfif ArrayLen(objectMetadata.hasOne)>
			<cfset relationships = objectMetadata.hasOne />
			<!--- loop over the relationships and find a match by alias --->
			<cfloop from="1" to="#ArrayLen(relationships)#" index="x">
				<cfset ArrayAppend(allRelationships, relationships[x]) />
			</cfloop>
		</cfif>
		
		<!--- check the hasMany relationships --->
		<cfif ArrayLen(objectMetadata.hasMany)>
			<cfset relationships = objectMetadata.hasMany />
			<!--- loop over the relationships and find a match by alias --->
			<cfloop from="1" to="#ArrayLen(relationships)#" index="x">
				<cfset ArrayAppend(allRelationships, relationships[x]) />
			</cfloop>
		</cfif>
		
		<cfreturn allRelationships />
	</cffunction>
	
	<!--- getRelationship --->
	<cffunction name="getRelationship" access="public" hint="I get a relationship by alias" output="false" returntype="struct">
		<cfargument name="alias" hint="I am the alias of the related object." required="yes" type="string" />
		<cfset var objectMetadata = getObjectMetadata() />
		<cfset var relationships = 0 />
		<cfset var x = 0 />
				
		<!--- check the hasone relationships --->
		<cfif ArrayLen(objectMetadata.hasOne)>
			<cfset relationships = objectMetadata.hasOne />
			<!--- loop over the relationships and find a match by alias --->
			<cfloop from="1" to="#ArrayLen(relationships)#" index="x">
				<cfif relationships[x].name IS arguments.alias>
					<!--- this is a match --->
					<cfreturn relationships[x]/>
				</cfif> 
			</cfloop>
		</cfif>
		
		<!--- check the hasMany relationships --->
		<cfif ArrayLen(objectMetadata.hasMany)>
			<cfset relationships = objectMetadata.hasMany />
			<!--- loop over the relationships and find a match by alias --->
			<cfloop from="1" to="#ArrayLen(relationships)#" index="x">
				<cfif relationships[x].name IS arguments.alias>
					<!--- this is a match --->
					<cfreturn relationships[x]/>
				</cfif> 
			</cfloop>
		</cfif>
		
		<cfthrow message="Relationship Does Not Exist" detail="The object '#getAlias()#' does not have a relationship with an alias of '#arguments.alias#'." type="reactor.getRelationship.RelationshipDoesNotExist" />
	</cffunction>
	
	<!--- hasRelationship --->
	<cffunction name="hasRelationship" access="public" hint="I indicate if this object as a relationship with another object" output="false" returntype="boolean">
		<cfargument name="alias" hint="I am the alias of the related object." required="yes" type="string" />
		<cfargument name="temp" type="boolean" default="false" />
		<cfset var objectMetadata = getObjectMetadata() />
		<cfset var relationships = 0 />
		<cfset var x = 0 />
		
		<!--- check the hasone relationships --->
		<cfif ArrayLen(objectMetadata.hasOne)>
			<cfset relationships = objectMetadata.hasOne />
			<!--- loop over the relationships and find a match by alias --->
			<cfloop from="1" to="#ArrayLen(relationships)#" index="x">
				<cfif relationships[x].name IS arguments.alias>
					<!--- this is a match --->
					<cfreturn true/>
				</cfif> 
			</cfloop>
		</cfif>
		
		<!--- check the hasMany relationships --->
		<cfif ArrayLen(objectMetadata.hasMany)>
			<cfset relationships = objectMetadata.hasMany />
			<!--- loop over the relationships and find a match by alias --->
			<cfloop from="1" to="#ArrayLen(relationships)#" index="x">
				<cfif relationships[x].name IS arguments.alias>
					<!--- this is a match --->
					<cfreturn true/>
				</cfif> 
			</cfloop>
		</cfif>
		
		<cfreturn false/>
	</cffunction>
		
	<!---- getRelationshipMetadata --->
	<cffunction name="getRelationshipMetadata" access="public" hint="I return a related object's metadata based on the provided alias" output="false" returntype="reactor.base.abstractMetadata">
		<cfargument name="alias" hint="I am the alias of the related object." required="yes" type="string" />
		<!---<cfset var relationship = getRelationship(arguments.alias) />
		<cfset var RelationshipMetadata = _getReactorFactory().createMetadata(relationship.name) />--->
		
		<cfreturn _getReactorFactory().createMetadata(arguments.alias) />
	</cffunction>
	
	<!--- metadata --->
    <cffunction name="getObjectMetadata" access="public" output="false" returntype="struct">
       <cfreturn variables.metadata />
    </cffunction>
		
	<!---<cffunction name="dumpVariables">
		<cfdump var="#variables#" />
		<cfabort />
	</cffunction>--->

</cfcomponent>