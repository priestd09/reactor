<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text" indent="no"  />
	<xsl:template match="/">
	
&lt;cfcomponent hint="I am the base DAO object for the <xsl:value-of select="object/@name"/> table.  I am generated.  DO NOT EDIT ME (but feel free to delete me)."
	extends="reactor.base.abstractDao" &gt;
	
	&lt;cfset variables.signature = "<xsl:value-of select="object/@signature" />" /&gt;

	&lt;cffunction name="save" access="public" hint="I create or update a <xsl:value-of select="object/@name" /> record." output="false" returntype="void"&gt;
		&lt;cfargument name="to" hint="I am the transfer object for <xsl:value-of select="object/@name" />" required="yes" type="reactor.project.<xsl:value-of select="object/@mapping"/>.To.<xsl:value-of select="object/@name"/>To" /&gt;

		<xsl:choose>
			<xsl:when test="count(object/fields/field[@primaryKey = 'true']) &gt; 0 and count(object/fields/field[@identity = 'true']) &gt; 0">
		&lt;cfif <xsl:for-each select="object/fields/field[@primaryKey = 'true']">IsNumeric(arguments.to.<xsl:value-of select="@name" />) AND Val(arguments.to.<xsl:value-of select="@name" />)<xsl:if test="position() != last()"> AND </xsl:if>
			</xsl:for-each>&gt;
			&lt;cfset update(arguments.to) /&gt;
		&lt;cfelse&gt;
			&lt;cfset create(arguments.to) /&gt;
		&lt;/cfif&gt;
			</xsl:when>
			<xsl:when test="count(object/fields/field[@primaryKey = 'true']) &gt; 0 and count(object/fields/field[@identity = 'true']) = 0">
		
		&lt;cfif <xsl:for-each select="object/fields/field[@primaryKey = 'true']">Len(arguments.to.<xsl:value-of select="@name" />) AND </xsl:for-each>exists(arguments.to)&gt;
			&lt;cfset update(arguments.to) /&gt;
		&lt;cfelse&gt;
			&lt;cfset create(arguments.to) /&gt;
		&lt;/cfif&gt;
			</xsl:when>
			<xsl:when test="count(object/fields/field[@primaryKey = 'true']) = 0">
		&lt;cfset create(arguments.to) /&gt;
			</xsl:when>
		</xsl:choose>
	&lt;/cffunction&gt;
	
	<xsl:if test="count(object/fields/field[@primaryKey = 'true']) &gt; 0 and count(object/fields/field[@identity = 'true']) = 0">
	&lt;cffunction name="exists" access="public" hint="I check to see if the <xsl:value-of select="object/@name" /> object exists." output="false" returntype="boolean"&gt;
		&lt;cfargument name="to" hint="I am the transfer object for <xsl:value-of select="object/@name" /> which will be populated." required="yes" type="reactor.project.<xsl:value-of select="object/@mapping"/>.To.<xsl:value-of select="object/@name"/>To" /&gt;
		&lt;cfset var qExists = 0 /&gt;
		&lt;cfset var <xsl:value-of select="object/@name" />Gateway = _getReactorFactory().createGateway("<xsl:value-of select="object/@name" />") /&gt;
				
		&lt;cfset qExists = <xsl:value-of select="object/@name" />Gateway.getByFields(
			<xsl:for-each select="object/fields/field[@primaryKey = 'true']">
				<xsl:value-of select="@name" /> = arguments.to.<xsl:value-of select="@name" />
				<xsl:if test="position() != last()">,</xsl:if>
			</xsl:for-each>
		) /&gt;
		
		&lt;cfif qExists.recordCount&gt;
			&lt;cfreturn true /&gt;
		&lt;cfelse&gt;
			&lt;cfreturn false /&gt;
		&lt;/cfif&gt;
	&lt;/cffunction&gt;
	</xsl:if>
	
	&lt;cffunction name="create" access="public" hint="I create a <xsl:value-of select="object/@name" /> object." output="false" returntype="void"&gt;
		&lt;cfargument name="to" hint="I am the transfer object for <xsl:value-of select="object/@name" />" required="yes" type="reactor.project.<xsl:value-of select="object/@mapping"/>.To.<xsl:value-of select="object/@name"/>To" /&gt;
		&lt;cfset var Convention = getConventions() /&gt;
		&lt;cfset var qCreate = 0 /&gt;
		<xsl:if test="count(object/super) &gt; 0">
			&lt;cfset super.create(arguments.to) /&gt;
			<xsl:if test="object/super/relate/@from != object/super/relate/@to">
				&lt;cfset arguments.to.<xsl:value-of select="object/super/relate/@from" /> = arguments.to.<xsl:value-of select="object/super/relate/@to" /> /&gt;
			</xsl:if>
		</xsl:if>
			
		&lt;cftransaction&gt;
			&lt;cfquery name="qCreate" datasource="#_getConfig().getDsn()#" username="#_getConfig().getUsername()#" password="#_getConfig().getPassword()#"&gt;
				INSERT INTO #Convention.FormatObjectName(getObjectMetadata(), '<xsl:value-of select="object/super/@name"/>')#
				(
					<xsl:for-each select="object/fields/field">
						<xsl:if test="@identity != 'true'">
							#Convention.formatFieldName('<xsl:value-of select="@name" />', '<xsl:value-of select="../../@name" />')#
							<xsl:if test="position() != last()">,</xsl:if>
						</xsl:if>
					</xsl:for-each>
				) VALUES (
					<xsl:for-each select="object/fields/field">
						<xsl:if test="@identity != 'true'">
							&lt;cfqueryparam cfsqltype="<xsl:value-of select="@cfSqlType" />"
							<xsl:if test="@length > 0 and @cfSqlType != 'cf_sql_longvarchar'">
								scale="<xsl:value-of select="@length" />"
							</xsl:if>
							value="<xsl:choose>
								<xsl:when test="@dbDataType = 'uniqueidentifier'">#Left(arguments.to.<xsl:value-of select="@name" />, 23)#-#Right(arguments.to.<xsl:value-of select="@name" />, 12)#</xsl:when>
								<xsl:otherwise>#arguments.to.<xsl:value-of select="@name" />#</xsl:otherwise>
							</xsl:choose>"
							<xsl:if test="@nullable = 'true'">	
								null="#Iif(NOT Len(arguments.to.<xsl:value-of select="@name" />), DE(true), DE(false))#"
							</xsl:if> /&gt;
							<xsl:if test="position() != last()">
								<xsl:text>,</xsl:text>
							</xsl:if>
						</xsl:if>
					</xsl:for-each>
				)
				
				<!-- some dbms require the last inserted id syntax to be run at the same time as the query -->
				&lt;cfif ListFindNoCase("mssql", _getConfig().getType())&gt;
					#Convention.lastInseredIdSyntax(getObjectMetadata())#
				&lt;/cfif&gt;
				
			&lt;/cfquery&gt;
			<!-- other dbms require this in a seperate query -->
			&lt;cfif NOT ListFindNoCase("mssql", _getConfig().getType())&gt;
				&lt;cfquery name="qCreate" datasource="#_getConfig().getDsn()#" username="#_getConfig().getUsername()#" password="#_getConfig().getPassword()#"&gt;	
					#Convention.lastInseredIdSyntax(getObjectMetadata())#
				&lt;/cfquery&gt;		
			&lt;/cfif&gt;
			
			<!-- 
			<xsl:if test="object/fields/field[@identity = 'true']">
				<xsl:choose>
					<xsl:when test="object/@dbms = 'mysql'">
						&lt;/cfquery&gt;
						
						&lt;cfquery name="qCreate" datasource="#_getConfig().getDsn()#"&gt;	
							#Convention.lastInseredIdSyntax(getObjectMetadata())#
					</xsl:when>
					<xsl:when test="object/@dbms = 'mysql4'">
						&lt;/cfquery&gt;
						
						&lt;cfquery name="qCreate" datasource="#_getConfig().getDsn()#"&gt;	
							#Convention.lastInseredIdSyntax(getObjectMetadata())#
					</xsl:when>
					<xsl:otherwise>
							#Convention.lastInseredIdSyntax(getObjectMetadata())#
					</xsl:otherwise>
				</xsl:choose>
			</xsl:if>
			
			&lt;/cfquery&gt;
			-->
		&lt;/cftransaction&gt;
			
		<xsl:if test="object/fields/field[@identity = 'true']">
			&lt;cfif qCreate.recordCount&gt;
				&lt;cfset arguments.to.<xsl:value-of select="object/fields/field[@identity = 'true']/@name" /> = qCreate.id /&gt;
			&lt;/cfif&gt;
		</xsl:if>
	&lt;/cffunction&gt;
	
	<xsl:if test="count(object/fields/field[@primaryKey = 'true'])">
	&lt;cffunction name="read" access="public" hint="I read a  <xsl:value-of select="object/@name" /> object." output="false" returntype="void"&gt;
		&lt;cfargument name="to" hint="I am the transfer object for <xsl:value-of select="object/@name" /> which will be populated." required="yes" type="reactor.project.<xsl:value-of select="object/@mapping"/>.To.<xsl:value-of select="object/@name"/>To" /&gt;
		&lt;cfargument name="loadFieldList" hint="I am an optional list of fields to load the record based on.  If not provided I default to the primary key values." required="no" type="string" default="" /&gt;
		&lt;cfset var qRead = 0 /&gt;
		&lt;cfset var <xsl:value-of select="object/@name" />Gateway = _getReactorFactory().createGateway("<xsl:value-of select="object/@name" />") /&gt;
		&lt;cfset var <xsl:value-of select="object/@name" />Query = <xsl:value-of select="object/@name" />Gateway.createQuery() /&gt;
		&lt;cfset var field = "" /&gt;
		
		&lt;cfif Len(arguments.loadFieldList)&gt;
			&lt;cfloop list="#arguments.loadFieldList#" index="field"&gt;
				&lt;cfset <xsl:value-of select="object/@name" />Query.getWhere().isEqual("<xsl:value-of select="object/@name" />", field, arguments.to[field]) /&gt;
			&lt;/cfloop&gt;
			
			&lt;cfset qRead = <xsl:value-of select="object/@name" />Gateway.getByQuery(<xsl:value-of select="object/@name" />Query) /&gt;
		&lt;cfelse&gt;
			&lt;cfset qRead = <xsl:value-of select="object/@name" />Gateway.getByFields(
				<xsl:for-each select="object/fields/field[@primaryKey = 'true']">
					<xsl:value-of select="@name" /> = arguments.to.<xsl:value-of select="@name" />
					<xsl:if test="position() != last()">, </xsl:if>
				</xsl:for-each>
			) /&gt;
		&lt;/cfif&gt;
		
		&lt;cfif qRead.recordCount IS 1&gt;<xsl:for-each select="object/superTables[@sort = 'backward']//fields/fields[@overridden = 'false']">
			&lt;cfset arguments.to.<xsl:value-of select="@name" /> = qRead.<xsl:value-of select="@name" /> /&gt;</xsl:for-each>
			<xsl:for-each select="//field[@overridden = 'false']">
				&lt;cfset arguments.to.<xsl:value-of select="@name" /> = 
				<xsl:choose>
					<xsl:when test="string-length(../../../@alias) and ../../../@alias != ../../../@name">
						qRead.<xsl:value-of select="../../../@alias" /><xsl:value-of select="@name" />
					</xsl:when>
					<xsl:otherwise>
						qRead.<xsl:value-of select="@name" />
					</xsl:otherwise>
				</xsl:choose>
				/&gt;
			</xsl:for-each>
		&lt;cfelseif qRead.recordCount GT 1&gt;
			&lt;cfthrow message="Ambiguous Record" detail="Your request matched more than one record." type="Reactor.Record.AmbiguousRecord" /&gt;
		&lt;/cfif&gt;
	&lt;/cffunction&gt;
	
	&lt;cffunction name="update" access="public" hint="I update a <xsl:value-of select="object/@name" /> object." output="false" returntype="void"&gt;
		&lt;cfargument name="to" hint="I am the transfer object for <xsl:value-of select="object/@name" /> which will be used to update a record in the table." required="yes" type="reactor.project.<xsl:value-of select="object/@mapping"/>.To.<xsl:value-of select="object/@name"/>To" /&gt;
		&lt;cfset var Convention = getConventions() /&gt;
		&lt;cfset var qUpdate = 0 /&gt;
		<xsl:if test="count(object/super) &gt; 0">
			<xsl:if test="object/super/relate/@from != object/super/relate/@to">
				&lt;cfset arguments.to.<xsl:value-of select="object/super/relate/@to" /> = arguments.to.<xsl:value-of select="object/super/relate/@from" /> /&gt;
			</xsl:if>
			&lt;cfset super.update(arguments.to) /&gt;
		</xsl:if>
		
		&lt;cfquery name="qUpdate" datasource="#_getConfig().getDsn()#" username="#_getConfig().getUsername()#" password="#_getConfig().getPassword()#"&gt;
			UPDATE #Convention.FormatObjectName(getObjectMetadata(), '<xsl:value-of select="object/super/@name"/>')#
			SET 
			<xsl:for-each select="object/fields/field[@primaryKey = 'false']">
				#Convention.formatUpdateFieldName('<xsl:value-of select="@name" />')# = &lt;cfqueryparam
					cfsqltype="<xsl:value-of select="@cfSqlType" />"
					<xsl:if test="@length > 0 and @cfSqlType != 'cf_sql_longvarchar'">
						scale="<xsl:value-of select="@length" />"
					</xsl:if>
					value="<xsl:choose>
						<xsl:when test="@dbDataType = 'uniqueidentifier'">#Left(arguments.to.<xsl:value-of select="@name" />, 23)#-#Right(arguments.to.<xsl:value-of select="@name" />, 12)#</xsl:when>
						<xsl:otherwise>#arguments.to.<xsl:value-of select="@name" />#</xsl:otherwise>
					</xsl:choose>"
					<xsl:if test="@nullable = 'true'">
						null="#Iif(NOT Len(arguments.to.<xsl:value-of select="@name" />), DE(true), DE(false))#"
					</xsl:if> /&gt;
				<xsl:if test="position() != last()">
					<xsl:text>,</xsl:text>
				</xsl:if>
			</xsl:for-each>
			WHERE
			<xsl:for-each select="object/fields/field[@primaryKey = 'true']">
				#Convention.formatUpdateFieldName('<xsl:value-of select="@name" />')# = &lt;cfqueryparam
					cfsqltype="<xsl:value-of select="@cfSqlType" />"
					<xsl:if test="@length > 0 and @cfSqlType != 'cf_sql_longvarchar'">
						scale="<xsl:value-of select="@length" />"
					</xsl:if>
					value="<xsl:choose>
						<xsl:when test="@dbDataType = 'uniqueidentifier'">#Left(arguments.to.<xsl:value-of select="@name" />, 23)#-#Right(arguments.to.<xsl:value-of select="@name" />, 12)#</xsl:when>
						<xsl:otherwise>#arguments.to.<xsl:value-of select="@name" />#</xsl:otherwise>
					</xsl:choose>"
					<xsl:if test="@nullable = 'true'">
						null="#Iif(NOT Len(arguments.to.<xsl:value-of select="@name" />), DE(true), DE(false))#"
					</xsl:if> /&gt;
				<xsl:if test="position() != last()">
					AND 
				</xsl:if>
			</xsl:for-each>
		&lt;/cfquery&gt;
	&lt;/cffunction&gt;
	</xsl:if>
	&lt;cffunction name="delete" access="public" hint="I delete a record in the <xsl:value-of select="object/@name" /> table." output="false" returntype="void"&gt;
		&lt;cfargument name="to" hint="I am the transfer object for <xsl:value-of select="object/@name" /> which will be used to delete from the table." required="yes" type="reactor.project.<xsl:value-of select="object/@mapping"/>.To.<xsl:value-of select="object/@name"/>To" /&gt;
		&lt;cfset var Convention = getConventions() /&gt;
		&lt;cfset var qDelete = 0 /&gt;
		<xsl:if test="count(object/super) &gt; 0">
			<xsl:if test="object/super/relate/@from != object/super/relate/@to">
				&lt;cfset arguments.to.<xsl:value-of select="object/super/relate/@to" /> = arguments.to.<xsl:value-of select="object/super/relate/@from" /> /&gt;
			</xsl:if>
		</xsl:if>
		
		&lt;cfquery name="qDelete" datasource="#_getConfig().getDsn()#" username="#_getConfig().getUsername()#" password="#_getConfig().getPassword()#"&gt;
			DELETE FROM #Convention.FormatObjectName(getObjectMetadata(), '<xsl:value-of select="object/super/@name"/>')#
			WHERE
			<xsl:for-each select="object/fields/field[@primaryKey = 'true']">
				#Convention.formatFieldName('<xsl:value-of select="@name" />', '<xsl:value-of select="../../@name" />')# = &lt;cfqueryparam
					cfsqltype="<xsl:value-of select="@cfSqlType" />"
					<xsl:if test="@length > 0 and @cfSqlType != 'cf_sql_longvarchar'">
						scale="<xsl:value-of select="@length" />"
					</xsl:if>
					value="<xsl:choose>
						<xsl:when test="@dbDataType = 'uniqueidentifier'">#Left(arguments.to.<xsl:value-of select="@name" />, 23)#-#Right(arguments.to.<xsl:value-of select="@name" />, 12)#</xsl:when>
						<xsl:otherwise>#arguments.to.<xsl:value-of select="@name" />#</xsl:otherwise>
					</xsl:choose>"
					<xsl:if test="@nullable = 'true'">
						null="#Iif(NOT Len(arguments.to.<xsl:value-of select="@name" />), DE(true), DE(false))#"
					</xsl:if> /&gt;
				<xsl:if test="position() != last()">
					AND 
				</xsl:if>
			</xsl:for-each>
		&lt;/cfquery&gt;
		
		<xsl:if test="count(object/super) &gt; 0">
			&lt;cfset super.delete(arguments.to) /&gt;
		</xsl:if>
	&lt;/cffunction&gt;
	
&lt;/cfcomponent&gt;
	</xsl:template>
		
</xsl:stylesheet>