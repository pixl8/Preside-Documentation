<cfparam name="args.page" type="page" />

<cfscript>
	pg   = args.page;
	body = markdownToHtml( pg.getBody() );
</cfscript>

<cfoutput>
	#toc( body )#

	<a class="pull-right" href="#getSourceLink( path=pg.getSourceFile() )#" title="Improve the docs"><i class="fa fa-pencil fa-fw"></i></a>

	#body#
</cfoutput>