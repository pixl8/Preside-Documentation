/**
 * Properties that inform the build about where to get things, etc.
 *
 * @accessors true
 */
component accessors=true {
	cwd     = GetDirectoryFromPath( GetCurrentTemplatePath() );
	docsDir = ExpandPath( "/docs/" );

	property name="editSourceLink"  default="https://github.com/pixl8/Preside-Documentation/blob/master{path}";
	property name="dashBuildNumber" default="1.0.0";
	property name="dashDownloadUrl" default="http://docs.preside.org/dash/presidecms.tgz";
	property name="isBeta"          default="false";

	public any function init() {
		var env          = CreateObject("java", "java.lang.System").getenv();
		var travisBranch = env.travis_branch ?: "";

		if ( StructKeyExists( env, "EDIT_SOURCE_LINK" ) ) {
			setEditSourceLink( env.EDIT_SOURCE_LINK );
		}
		if ( StructKeyExists( env, "DASH_BUILD_NUMBER" ) ) {
			setDashBuildNumber( env.DASH_BUILD_NUMBER );
		}
		if ( StructKeyExists( env, "DASH_DOWNLOAD_URL" ) ) {
			setDashDownloadUrl( env.DASH_DOWNLOAD_URL );
		}
		if ( StructKeyExists( env, "IS_BETA_BUILD" ) ) {
			setIsBeta( IsBoolean( env.IS_BETA_BUILD ) && env.IS_BETA_BUILD );
		}

		return this;
	}
}