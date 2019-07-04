( function( $ ){

	var $searchBox = $( "#presidecms-docs-search-input" )
	  , $searchLink = $( ".search-link" )
	  , $searchContainer = $( ".search-container" )
	  , duckduckgoUrl = "https://duckduckgo.com/?q=site:docs.preside.org "
	  , setupTypeahead, setupBloodhound, renderSuggestion
	  , itemSelectedHandler, tokenizer, generateRegexForInput, search, searchIndex;

	setupTypeahead = function(){
		setupSearchEngine( function( bloodhound ){
			var typeAheadSettings = {
					  hint      : true
					, highlight : false
					, minLength : 1
				}
			  , datasetSettings = {
			  		  source     : bloodhound
			  		, displayKey : 'display'
			  		, limit      : 100
			  		, templates  : { suggestion : renderSuggestion }
			    }

			$searchBox.typeahead( typeAheadSettings, datasetSettings );
			$searchBox.on( "typeahead:selected", function( e, result ){ itemSelectedHandler( result ); } );
		} );
	};

	setupSearchEngine = function( callback ){
		var sourceData, dataReceived = function( data ){
			searchIndex = data;

			callback( function( query, syncCallback ) {
				syncCallback( search( query ) );
			} );
		};

		$.ajax( "/assets/js/searchIndex.json", {
			  method : "GET"
			, success : dataReceived
		} );
	};

	search = function( input ){
		var reg     = generateRegexForInput( input )
		  , fulltextitem, matches;
		var previousMatches = [];


		matches = searchIndex.filter( function( item ) {
			var titleLen = item.text.length
			  , match, nextMatch, i, highlighted, title;

			for( i=0; i < titleLen; i++ ){
				nextMatch = item.text.substr(i).match( reg.expr );

				if ( !nextMatch ) {
					break;
				} else if ( previousMatches.includes( item.display ) ) {
					break;
				} else if ( !match || nextMatch[0].length < match[0].length ) {
					match       = nextMatch;
					title       = item.display;
					highlighted = item.text.substr(0,i) + item.text.substr(i).replace( reg.expr, reg.replace )

					previousMatches.push( item.display );
				}
			}

			if ( match ) {
				item.score     = match[0].length - input.length;
				item.highlight = highlighted;
				item.title     = title;

				return true;
			}
		} );

		matches = matches.sort( function( a, b ){
			return ( a.score - b.score ) || a.text.length - b.text.length;
		} );

		fulltextitem = {
			  value     : duckduckgoUrl + encodeURIComponent( input )
			, text      : 'Search all docs for "' + input + '"'
			, highlight : '<em>Search all docs for <strong>"' + input + '</strong>"</em>'
			, score     : 1000000
			, icon      : "search"
			, type      : ""
		};
		fulltextitem.display = fulltextitem.text;
		matches.unshift( fulltextitem );

		console.log( matches );

		return matches;
	}

	generateRegexForInput = function( input ){
		var inputLetters = input.replace(/\W/, '').split('')
		  , reg = {}, i;

		reg.expr = new RegExp('(' + inputLetters.join( ')(.*?)(' ) + ')', 'i');
  		reg.replace = ""

  		for( i=0; i < inputLetters.length; i++ ) {
    		reg.replace += ( '<b>$' + (i*2+1) + '</b>' );
    		if ( i + 1 < inputLetters.length ) {
      			reg.replace += '$' + (i*2+2);
    		}
  		}

  		return reg
	};

	renderSuggestion = function( item ) {
		return Mustache.render(
			'<div>' +
				'<p style="margin: 0"><i class="fa fa-fw fa-{{icon}}"></i><strong> {{{title}}} </strong></p>' +
				'<p style="margin: -5px 0 2px 22px;line-height:1.1em;"><small><i> {{{highlight}}} </i></small></p>' +
			'</div>'
			, item
			);
	};

	itemSelectedHandler = function( item ) {
		window.location = item.value;
	};

	tokenizer = function( input ) {
		var strippedInput = input.replace( /[^\w\s]/g, "" );
		return Bloodhound.tokenizers.whitespace( strippedInput );
	}

	setupTypeahead();

} )( jQuery );