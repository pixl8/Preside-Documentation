<cfparam name="args.body"       type="string" />
<cfparam name="args.page"       type="any" />
<cfparam name="args.crumbs"     type="string" />
<cfparam name="args.navTree"    type="string" />
<cfparam name="args.seeAlso"    type="string" />
<cfparam name="args.isBeta"     type="boolean" />

<cfoutput><!DOCTYPE html>
<html>
	<head>
		<title>Preside Documentation :: #HtmlEditFormat( args.page.getTitle() )#</title>
		<base href="#( repeatString( '../', args.page.getDepth()-1 ) )#">

		<meta content="initial-scale=1.0, width=device-width" name="viewport">

		<link href="assets/css/base.min.css" rel="stylesheet">
		<link href="assets/css/project.css" rel="stylesheet">
		<link href="assets/css/highlight.css" rel="stylesheet">
		<link rel="icon" type="image/png" href="assets/images/preside-favicon.png">

		<cfif args.isBeta>
			<meta name="robots" content="noindex, nofollow">
		</cfif>

		<!-- ie -->
		<!--[if lt IE 9]>
			<script src="assets/js/html5shiv.js" type="text/javascript"></script>
			<script src="assets/js/respond.js" type="text/javascript"></script>
		<![endif]-->
	</head>

	<body class="#LCase( args.page.getPageType() )#">
		<nav class="menu menu-left nav-drawer" id="menu">
			<div class="menu-scroll">
				<div class="menu-wrap">
					<div class="menu-content">
						<a class="nav-drawer-logo" href="index.html"><img src="assets/images/preside-platform.svg"></a>
						#args.navTree#
						<hr>
						<ul class="nav">
							<li>
								<a href="https://www.preside.org"><span class="fa fa-fw fa-globe"></span>Preside Website</a>
							</li>
							<li>
								<a href="https://github.com/pixl8/Preside-CMS"><span class="fa fa-fw fa-github"></span>Source repository</a>
							</li>
							<li>
								<a href="download.html"><span class="fa fa-fw fa-download"></span>Offline docs</a>
							</li>
						</ul>
					</div>
				</div>
			</div>
		</nav>

		<header class="header">
			<ul class="hidden-lg nav nav-list pull-left">
				<li>
					<a class="menu-toggle" href="##menu">
						<span class="access-hide">Menu</span>
						<span class="icon icon-menu icon-lg"></span>
						<span class="header-close icon icon-close icon-lg"></span>
					</a>
				</li>
			</ul>
			<a class="header-logo hidden-lg" href="index.html"><img alt="Preside" src="assets/images/preside-platform-reverse.svg"></a>
			<ul class="nav nav-list pull-right">
				<cfset prevPage = args.page.getPreviousPage() />
				<cfset nextPage = args.page.getNextPage() />
				<cfif not IsNull( prevPage )>
					<li>
						<a href="#( prevPage.getPath() == '/home' ? '/' : '#prevPage.getPath()#.html' )#">
							<span class="access-hide">Previous page: #HtmlEditFormat( prevPage.getTitle() )#</span>
							<span class="icon icon-arrow-back icon-lg"></span>
						</a>
					</li>
				</cfif>
				<cfif not IsNull( nextPage )>
					<li>
						<a href="#( nextPage.getPath() == '/home' ? '/' : '#nextPage.getPath()#.html' )#">
							<span class="access-hide">Previous page: #HtmlEditFormat( nextPage.getTitle() )#</span>
							<span class="icon icon-arrow-forward icon-lg"></span>
						</a>
					</li>
				</cfif>
				<li>
					<a class="menu-toggle" href="##search">
						<span class="access-hide">Search</span>
						<span class="icon icon-search icon-lg"></span>
						<span class="header-close icon icon-close icon-lg"></span>
					</a>
				</li>
			</ul>
			<span class="header-fix-show header-logo pull-none text-overflow">#HtmlEditFormat( args.page.getTitle() )#</span>
		</header>
		<div class="menu menu-right menu-search" id="search">
			<div class="menu-scroll">
				<div class="menu-wrap">
					<div class="menu-content">
						<div class="menu-content-inner">
							<label class="access-hide" for="presidecms-docs-search-input">Search</label>
							<input class="form-control form-control-lg menu-search-focus" id="presidecms-docs-search-input" placeholder="Search" type="search">
						</div>
					</div>
				</div>
			</div>
		</div>

		<div class="content">
			<div class="content-heading">
				<div class="container">
					<div class="row">
						<div class="col-lg-10 col-lg-push-1">
							<h1 class="heading">#HtmlEditFormat( args.page.getTitle() )#</h1>
						</div>
					</div>
				</div>
			</div>

			<div class="content-inner">
				<div class="container">
					<div class="row">
						<div class="col-lg-10 col-lg-push-1 body">
							<cfif args.isBeta>
								<div class="card-wrap">
									<div class="card card-red">
										<aside class="card-side">
											<span class="card-heading icon icon-info"></span>
										</aside>
										<div class="card-main">
											<div class="card-inner">
												<p class="alert alert-info"><strong>You are currently viewing the BETA version of the documentation.</strong> This documentation should be used as a preview for the upcoming release only. For documentation relating to the latest stable version of Preside, visit <a href="https://docs.preside.org">https://docs.preside.org</a></p>
											</div>
										</div>
									</div>
								</div>
							</cfif>

							<div class="tile-wrap">
								<div class="tile">
									#args.crumbs#
								</div>
							</div>
							#args.body#

							#args.seeAlso#
						</div>
					</div>
				</div>
			</div>
		</div>

		<footer class="footer">
			<div class="container">
				<p>The Preside Documentation is developed and maintained by Pixl8 Interactive and is licensed under a
					<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/"><img alt="Creative Commons License" style="border-width:0" src="//i.creativecommons.org/l/by-nc-sa/3.0/80x15.png"></a>
					<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/3.0/">Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License</a>.
				</p>
			</div>
		</footer>

		<script src="assets/js/base.4.min.js" type="text/javascript"></script>
	</body>
</html></cfoutput>