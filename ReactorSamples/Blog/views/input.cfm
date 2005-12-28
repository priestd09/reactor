
<cfparam name="attributes.errors" default="" />
<cfparam name="attributes.label" default="" />
<cfparam name="attributes.required" default="false" />
<cfparam name="attributes.comment" default="" />

<cfparam name="attributes.name" />
<cfparam name="attributes.type" />
<cfparam name="attributes.value" default="" />
<cfparam name="attributes.style" default="" />
<cfparam name="attributes.class" default="" />
 
<cfset thisTag.errors = attributes.errors />
<cfset thisTag.label = attributes.label />

<cfset classes = "field" />

<!--- add an input field --->
<cfif ThisTag.executionMode IS "Start">
	
	<cfif IsObject(attributes.errors) AND attributes.errors.hasErrors(attributes.name)>
		<cfset errorsArray = attributes.errors.GetPropertyErrors(attributes.name) />
		
		<p class="errorMessage">
			<cfloop from="1" to="#ArrayLen(errorsArray)#" index="x">
				<cfoutput>
					#errorsArray[x]#
					<cfif x IS NOT ArrayLen(errorsArray)>
						<br />
					</cfif>
				</cfoutput>
			</cfloop>
		</p>
		<cfset classes = classes & " errorField" />
	</cfif>
	
	<cfoutput>
		<div class="#classes#">
			<cfswitch expression="#attributes.type#">
				<!--- a submit button --->
				<cfcase value="submit">
					<label for="#attributes.name#"></label>
					<cfinput name="#attributes.name#"
						type="#attributes.type#" 
						value="#attributes.value#"
						style="#attributes.style#"
						class="inputSubmit #attributes.class#" />
				</cfcase>
				
				<!--- an html editor --->
				<cfcase value="editor">
					<label for="#attributes.name#">#Iif(attributes.required, DE('*'), DE(''))# #attributes.label#</label>
					<cfset pathToEditor = GetDirectoryFromPath(CGI.SCRIPT_NAME) & "views/FCKeditor" />
					<cfset pathToCss = GetDirectoryFromPath(CGI.SCRIPT_NAME) & "scripts/styles/styles.css" />
					
					<cfif DirectoryExists(ExpandPath(pathToEditor))>
						<cfif NOT Len(attributes.value)>
							<cfset attributes.value = "<p>&nbsp;</p>" />
						</cfif>
						<cfset FckEditor = CreateObject("Component", "FckEditor.fckeditor") />
						<cfset FckEditor.instanceName = attributes.name />
						<cfset FckEditor.width = 460 />
						<cfset FckEditor.height = 400 />
						<cfset FckEditor.value = attributes.value />
						<cfset FckEditor.toolbarSet = "Blog" />
						<cfset FckEditor.config.styleSheet = pathToCss />
						<cfset FckEditor.basePath = GetDirectoryFromPath(CGI.SCRIPT_NAME) & "/views/FCKeditor" />
						<cfset FckEditor.create() />
					<cfelse>
						Show textarea
					</cfif>
				</cfcase>
				
				<!--- a checkbox --->
				<cfcase value="checkbox">
					<label for="#attributes.name#"></label>
					<cfinput name="#attributes.name#"
						type="#attributes.type#" 
						value="#attributes.value#"
						style="#attributes.style#"
						class="inputCheckbox #attributes.class#" />
					<span>#Iif(attributes.required, DE('*'), DE(''))# #attributes.label#</span>
				</cfcase>
				
				<!--- other things --->		
				<cfdefaultcase>
					<cfparam name="attributes.size" />
					<cfparam name="attributes.maxLength" />

					<label for="#attributes.name#">#Iif(attributes.required, DE('*'), DE(''))# #attributes.label#</label>
					<cfinput name="#attributes.name#"
						type="#attributes.type#" 
						value="#attributes.value#"
						size="#attributes.size#"
						maxLength="#attributes.maxLength#"
						style="#attributes.style#"
						class="inputText #attributes.class#" />
				</cfdefaultcase>
			</cfswitch>
			<cfif Len(attributes.comment)>
				<small>#attributes.comment#</small>
			</cfif>
		</div>
	</cfoutput>
</cfif>