<cfcomponent hint="I represent metadata about a database object.">

	<!---<cfset variables.config = "" />--->
	<cfset variables.Config = 0 />
	<cfset variables.ObjectConfig = 0 />
	<cfset variables.Xml = 0 />
	<cfset variables.alias = "" />
	<cfset variables.name = "" />
	<cfset variables.owner = "" />
	<cfset variables.type = "" />
	<cfset variables.database = "" />
	
	<cfset variables.fields = ArrayNew(1) />
	
	<cffunction name="init" access="public" hint="I configure the object." returntype="reactor.core.object">
		<cfargument name="alias" hint="I am the alias of the obeject being represented." required="yes" type="string" />
		<cfargument name="Config" hint="I am a reactor config object" required="yes" type="reactor.config.config" />
		
		<cfset setAlias(arguments.alias) />
		<cfset setConfig(arguments.Config) />
		<cfset setObjectConfig(getConfig().getObjectConfig(getAlias())) />
		<cfset setName(getObjectConfig().object.XmlAttributes.name) />
		
		<!--- this creates the base XML document
		<cfset createXml() /> --->
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getSignature" access="public" hint="I get this table's signature" output="false" returntype="string">
		<cfreturn getXml().object.XmlAttributes.signature />
	</cffunction>
	
 	<cffunction name="getRelationships" access="private" hint="I find relationships between the two provided object aliases" output="false" returntype="array">
		<cfargument name="from" hint="I am the alias of the object the relationship is from" required="yes" type="string" />
		<cfargument name="to" hint="I am the alias of the object the relationship is to" required="yes" type="string" />
		<cfset var fromObject = getConfig().getObjectConfig(arguments.from) />
		<cfset var toObject = getConfig().getObjectConfig(arguments.to) />
		<cfset var relationships = XmlSearch(fromObject, "/object/hasMany[@name='#toObject.object.XmlAttributes.alias#']/relate/..|/object/hasOne[@name='#toObject.object.XmlAttributes.alias#']") />
		<cfset var invert = false />
		<cfset var relationship = ArrayNew(1) />
				
		<!--- check the from object for a relationship to the to object --->
		<cfif NOT ArrayLen(relationships)>
			<cfset relationships = XmlSearch(toObject, "/object/hasMany[@name='#fromObject.object.XmlAttributes.alias#']/relate/..|/object/hasOne[@name='#fromObject.object.XmlAttributes.alias#']") />
			<cfset invert = true />
		</cfif>
		
		<!--- if we don't have any relationships throw an error --->
		<cfif NOT ArrayLen(relationships)>
			<cfthrow message="Relationship Does Not Exist" detail="No relationship exists between #arguments.from# and #arguments.to#." type="reactor.core.object.getRelationships.RelationshipDoesNotExist" />
		</cfif>
		
		<!--- get the first relationship --->
		<cfset relationships = relationships[1] />
		
		<!--- loop over the relations between from and to and make an array --->
		<cfloop from="1" to="#ArrayLen(relationships.XmlChildren)#" index="x">
			<cfset relationship[x] = StructNew() />
			
			<cfif NOT invert>
				<cfset relationship[x].from = relationships.XmlChildren[x].XmlAttributes.from />
				<cfset relationship[x].to = relationships.XmlChildren[x].XmlAttributes.to />
			<cfelse>
				<cfset relationship[x].from = relationships.XmlChildren[x].XmlAttributes.to />
				<cfset relationship[x].to = relationships.XmlChildren[x].XmlAttributes.from />
			</cfif>
		</cfloop>
		
		<cfreturn relationship />
	</cffunction>
	
	<cffunction name="getXml" access="public" hint="I return this table expressed as an XML document" output="false" returntype="string">
		<cfset var Config = Duplicate(getObjectConfig()) />
		<cfset var fields = getFields() />
		<cfset var links = 0 />
		<cfset var link = 0 />
		<cfset var linkFrom = 0 />
		<cfset var linkTo = 0 />
		<cfset var newRelationship = 0 />
		<cfset var newRelationships = 0 />
		<!---
		<cfset var linkerRelationship = 0 />
		<cfset var newHasMany = 0 />--->
		<cfset var x = 0 />
		<cfset var y = 0 />
		<cfset var z = 0 />
		
		<!--- add/validate relationship aliases --->
		<cfset var relationships = XmlSearch(Config, "/object/hasMany | /object/hasOne") />
		<cfset var relationship = 0 />
		<cfset var aliasList = "" />
			
		<!--- insure aliases are set --->
		<cfloop from="1" to="#ArrayLen(relationships)#" index="x">
			<cfset relationship = relationships[x] />
			
			<cfif NOT IsDefined("relationship.XmlAttributes.alias")>
				<cfset relationship.XmlAttributes["alias"] = relationship.XmlAttributes.name />
			</cfif>
		</cfloop>
		
		<!--- Assign aliases for relationships that don't have them --->
		<cfloop from="1" to="#ArrayLen(relationships)#" index="x">
			<cfset relationship = relationships[x] />
			
			<cfif NOT IsDefined("relationship.XmlAttributes.alias")>
				<cfset relationship.XmlAttributes["alias"] = relationship.XmlAttributes.name />
				<!--- make sure this alias hasn't already been used --->
				<cfif ListFindNoCase(aliasList, relationship.XmlAttributes["alias"])>
					<!--- it's been used - throw an error --->
					<cfthrow message="Duplicate Relationship Or Alias" detail="The relationship or alias '#relationship.XmlAttributes["alias"]#' has already been used for the '#getName()#' object." type="reactor.getXml.DuplicateRelationshipOrAlias" />
				<cfelse>
					<!--- all this column to the list --->
					<cfset aliasList = ListAppend(aliasList, relationship.XmlAttributes["alias"]) />
				</cfif>
			</cfif>
			
		</cfloop>
		
		<!--- add the fields to the config settings --->
		
		<!--- check to see if a fields node already exists --->
		<cfif NOT IsDefined("Config.Object.fields")>
			<cfset Config.Object.fields = XMLElemNew(Config, "fields") />
		</cfif>
		
		<cfloop from="1" to="#ArrayLen(fields)#" index="x">
			<cfset addXmlField(fields[x], Config) />
		</cfloop>
		
		<!--- delete the fields from the base config file --->
		<cfloop from="#ArrayLen(Config.object.xmlChildren)#" to="1" index="x" step="-1">
			<cfif Config.object.xmlChildren[x].XmlName IS "field">
				<cfset ArrayDeleteAt(Config.object.xmlChildren, x) />
			</cfif>
		</cfloop>
		
		<!--- set the base config settings --->
		<cfset Config.Object.XmlAttributes["owner"] = getOwner() />
		<cfset Config.Object.XmlAttributes["type"] = getType() />
		<cfset Config.Object.XmlAttributes["database"] = getDatabase() />
		
		<!--- config meta data required for generating objects --->
		<cfset Config.Object.XmlAttributes["project"] = getConfig().getProject() />
		<cfset Config.Object.XmlAttributes["mapping"] = getConfig().getMappingObjectStem() />
		<cfset Config.Object.XmlAttributes["dbms"] = getConfig().getType() />
		
		<!--- add the object's signature --->
		<cfset Config.Object.XmlAttributes["signature"] = Hash(ToString(Config)) />
		
		<!---<cfdump var="#Config#" /><cfabort>--->
		
		<cfreturn Config />
	</cffunction>
	
	<cffunction name="addXmlField" access="private" hint="I add a field to the xml document." output="false" returntype="void">
		<cfargument name="field" hint="I am the field to add to the xml" required="yes" type="reactor.core.field" />
		<cfargument name="config" hint="I am the xml to add the field to." required="yes" type="string" />
		<cfset var xmlField = 0 />
		<cfset var alias = XmlSearch(arguments.config, "/object/field[@name='#arguments.field.getName()#']") />
		
		<!--- create the field node--->
		<cfset xmlField = XMLElemNew(arguments.config, "field") />
		
		<!--- set the field's properties --->
		<cfset xmlField.XmlAttributes["name"] = arguments.field.getName() />
		<cfif ArrayLen(alias)>
			<cfset xmlField.XmlAttributes["alias"] = alias[1].XmlAttributes.alias />
		<cfelse>
			<cfset xmlField.XmlAttributes["alias"] = arguments.field.getName() />
		</cfif>
		<cfset xmlField.XmlAttributes["primaryKey"] = arguments.field.getPrimaryKey() />
		<cfset xmlField.XmlAttributes["identity"] = arguments.field.getIdentity() />
		<cfset xmlField.XmlAttributes["nullable"] = arguments.field.getNullable() />
		<cfset xmlField.XmlAttributes["dbDataType"] = arguments.field.getDbDataType() />
		<cfset xmlField.XmlAttributes["cfDataType"] = arguments.field.getCfDataType() />
		<cfset xmlField.XmlAttributes["cfSqlType"] = arguments.field.getCfSqlType() />
		<cfset xmlField.XmlAttributes["length"] = arguments.field.getLength() />
		<cfset xmlField.XmlAttributes["default"] = arguments.field.getDefault() />
		<cfset xmlField.XmlAttributes["object"] = arguments.config.object.XmlAttributes.name />
		
		<!--- add the field node --->
		<cfset ArrayAppend(arguments.config.Object.fields.XmlChildren, xmlField) />
		
	</cffunction>
	
	<cffunction name="copyNode" access="private"  hint="Copies a node from one document into a second document.  (This code was coppied from Skike's blog at http://www.spike.org.uk/blog/index.cfm?do=ReactorSamples.Blog.cat&catid=8245E3A4-D565-E33F-39BC6E864D6B5DAA)" output="false" returntype="void">
		<cfargument name="xmlDoc" hint="I am the document to copy the nodes into" required="yes" type="any">
		<cfargument name="newNode" hint="I am the node to copy the nodes into" required="yes" type="any">
		<cfargument name="oldNode" hint="I am the node to copy the nodes from" required="yes" type="any">
	
		<cfset var key = "" />
		<cfset var index = "" />
		<cfset var i = "" />
		
		<cfif len(trim(oldNode.xmlComment))>		
			<cfset newNode.xmlComment = trim(oldNode.xmlComment) />
		</cfif>
	
		<cfif len(trim(oldNode.xmlCData))>
			<cfset newNode.xmlCData = trim(oldNode.xmlCData)>
		</cfif>
		
		<cfset newNode.xmlAttributes = oldNode.xmlAttributes>
		
		<cfset newNode.xmlText = trim(oldNode.xmlText) />
		
		<cfloop from="1" to="#arrayLen(oldNode.xmlChildren)#" index="i">
			<cfset newNode.xmlChildren[i] = xmlElemNew(xmlDoc,oldNode.xmlChildren[i].xmlName) />
			<cfset copyNode(xmlDoc,newNode.xmlChildren[i],oldNode.xmlChildren[i]) />
		</cfloop>
	</cffunction>
	
	<cffunction name="addField" access="public" hint="I add a field to this object." output="false" returntype="void">
		<cfargument name="field" hint="I am the field to add" required="yes" type="reactor.core.field" />
		<cfset var fields = getFields() />
		<cfset fields[ArrayLen(fields) + 1] = arguments.field />
		
		<cfset setFields(fields) />
	</cffunction>

	<cffunction name="getField" access="public" hint="I return a specific field." output="false" returntype="reactor.core.field">
		<cfargument name="name" hint="I am the name of the field to return" required="yes" type="string" />
		<cfset var fields = getFields() />
		<cfset var x = 1 />
		
		<cfloop from="1" to="#ArrayLen(fields)#" index="x">
			<cfif fields[x].getName() IS arguments.name>
				<cfreturn fields[x] />
			</cfif>
		</cfloop>
	</cffunction>
	
	<!--- name --->
    <cffunction name="setName" access="public" output="false" returntype="void">
       <cfargument name="name" hint="I am the name of the object" required="yes" type="string" />
       <cfset variables.name = arguments.name />	   
    </cffunction>
    <cffunction name="getName" access="public" output="false" returntype="string">
       <cfreturn variables.name />
    </cffunction>
	
	<!--- alias --->
    <cffunction name="setAlias" access="public" output="false" returntype="void">
       <cfargument name="alias" hint="I am the alias this object is known as." required="yes" type="string" />
       <cfset variables.alias = arguments.alias />
    </cffunction>
    <cffunction name="getAlias" access="public" output="false" returntype="string">
       <cfreturn variables.alias />
    </cffunction>
	
	<!--- owner --->
    <cffunction name="setOwner" access="public" output="false" returntype="void">
       <cfargument name="owner" hint="I am the object owner." required="yes" type="string" />
       <cfset variables.owner = arguments.owner />
    </cffunction>
    <cffunction name="getOwner" access="public" output="false" returntype="string">
       <cfreturn variables.owner />
    </cffunction>
	
	<!--- type --->
    <cffunction name="setType" access="public" output="false" returntype="void">
		<cfargument name="type" hint="I am the object type (options are view or table)" required="yes" type="string" />
		<cfset arguments.type = lcase(arguments.type) />
		
		<cfif NOT ListFind("table,view", arguments.type)>
			<cfthrow type="reactor.object.InvalidObjectType"
				message="Invalid Object Type"
				detail="The Type argument must be one of: table, view" />
		</cfif>
		
		<cfset variables.type = arguments.type />
    </cffunction>
    <cffunction name="getType" access="public" output="false" returntype="string">
       <cfreturn variables.type />
    </cffunction>
	
	<!--- fields --->
    <cffunction name="setFields" access="public" output="false" returntype="void">
       <cfargument name="fields" hint="I am this object's fields" required="yes" type="array" />
       <cfset variables.fields = arguments.fields />
    </cffunction>
    <cffunction name="getFields" access="public" output="false" returntype="array">
       <cfreturn variables.fields />
    </cffunction>
	
	<!--- database --->
    <cffunction name="setDatabase" access="public" output="false" returntype="void">
		<cfargument name="database" hint="I am the database this table is in." required="yes" type="string" />
		<cfset variables.database = arguments.database />
    </cffunction>
    <cffunction name="getDatabase" access="public" output="false" returntype="string">
		<cfreturn variables.database />
    </cffunction>
	
	<!--- config --->
    <cffunction name="setConfig" access="public" output="false" returntype="void">
       <cfargument name="config" hint="I am the config object used to configure reactor" required="yes" type="reactor.config.config" />
       <cfset variables.config = arguments.config />
    </cffunction>
    <cffunction name="getConfig" access="public" output="false" returntype="reactor.config.config">
       <cfreturn variables.config />
    </cffunction>
	
	<!--- objectConfig --->
    <cffunction name="setObjectConfig" access="private" output="false" returntype="void">
       <cfargument name="objectConfig" hint="I am the configuration for this specific object" required="yes" type="xml" />
       <cfset variables.objectConfig = arguments.objectConfig />
    </cffunction>
    <cffunction name="getObjectConfig" access="private" output="false" returntype="xml">
       <cfreturn variables.objectConfig />
    </cffunction>
	
	<!--- xml
    <cffunction name="setXml" access="private" output="false" returntype="void">
       <cfargument name="xml" hint="I return the xml document which describes this object." required="yes" type="string" />
       <cfset variables.xml = arguments.xml />
    </cffunction>
    <cffunction name="getXml" access="public" output="false" returntype="string">
       <cfreturn variables.xml />
    </cffunction> --->
</cfcomponent>