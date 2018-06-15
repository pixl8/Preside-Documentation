( function( $ ){
	$( "a[href^='\#']" ).each(function(){
		this.href = location.href.split("#")[0]+'#'+this.href.substr(this.href.indexOf('#')+1);
	} );
} )( jQuery );
