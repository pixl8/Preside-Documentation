component {

	public any function init( required string rootPath ) {
		_setRootPath( arguments.rootPath );

		return this;
	}

	public string function render( required string template, struct args={}, string helpers="" ) {
		var rendered = "";

		_includeHelpers( arguments.helpers );

		savecontent variable="rendered" {
			include template=arguments.template;
		}

		rendered = new SyntaxHighlighter().renderHighlights( rendered );

		return Trim( rendered );
	}

	public string function markdownToHtml( required string markdown ) {
		var rendered = new SyntaxHighlighter().renderHighlights( arguments.markdown );

		return new api.parsers.ParserFactory().getMarkdownParser().markdownToHtml( rendered );
	}

	public string function toc( required string content ) {
		var toc      = "";
		var args     = {}

		args.tocItems = new api.parsers.TocGenerator().generateToc( arguments.content );

		if ( args.tocItems.len() && ( args.tocItems.len() != 1 || args.tocItems[1].children.len() ) ) {
			try {
				savecontent variable="toc" {
					include template=_getRootPath() & "layouts/toc.cfm";
				}
			} catch( missinginclude e ) {}
		}

		return toc;
	}

	private void function _includeHelpers( required string helpers ) {
		if ( Len( Trim( arguments.helpers ) ) ) {
			var fullHelpersPath = ExpandPath( arguments.helpers );
			var files           = DirectoryList( fullHelpersPath, false, "path", "*.cfm" );

			for( var file in files ){
				var mappedPath = arguments.helpers & Replace( file, fullHelpersPath, "" );
				include template=mappedPath;
			}
		}
	}

// gets/sets
	private string function _getRootPath() {
		return _rootPath;
	}
	private void function _setRootPath( required string rootPath ) {
		_rootPath = arguments.rootPath;
	}
}