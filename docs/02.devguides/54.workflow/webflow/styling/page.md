---
id: webflowstyling
title: "Webflows How-To: Style the default webflow layout"
---

## How-To: Style the default webflow layout

### HTML Markup

The Webflow system comes with a default layout that is broken into micro views for things like previous and next buttons, and the progress bar navigation.

Here is the key HTML markup with annotations:

```html
<!-- BEGIN: CONTAINER DIV -->
<div class="webflow-layout">

	<!-- BEGIN: PROGRESS BAR -->
	<div class="webflow-progress-bar">
		<ol class="webflow-progress-bar-list" role="progressbar" aria-valuemin="1" aria-valuemax="7" aria-valuenow="4">
			<li class="webflow-progress-bar-item step-complete" title="Step 1">
				<a href="" class="webflow-progress-bar-item-title webflow-progress-bar-item-link"><span class="webflow-progress-bar-item-text">Step 1</span></a>
			</li>
			<li class="webflow-progress-bar-item step-complete" title="Step 2">
				<a href="" class="webflow-progress-bar-item-title webflow-progress-bar-item-link"><span class="webflow-progress-bar-item-text">Step 2</span></a>
			</li>
			<li class="webflow-progress-bar-item step-complete" title="Step 3">
				<a href="" class="webflow-progress-bar-item-title webflow-progress-bar-item-link"><span class="webflow-progress-bar-item-text">Step 3</span></a>
			</li>
			<li class="webflow-progress-bar-item step-current" title="Step 4" aria-current="step">
				<span class="webflow-progress-bar-item-title"><span class="webflow-progress-bar-item-text">Step 4</span></span>
			</li>
			<li class="webflow-progress-bar-item step-pending" title="Step 5">
				<span class="webflow-progress-bar-item-title"><span class="webflow-progress-bar-item-text">Step 5</span></span>
			</li>
			<li class="webflow-progress-bar-item step-pending" title="Step 6">
				<span class="webflow-progress-bar-item-title"><span class="webflow-progress-bar-item-text">Step 6</span></span>
			</li>
			<li class="webflow-progress-bar-item step-pending" title="Step 7">
				<span class="webflow-progress-bar-item-title"><span class="webflow-progress-bar-item-text">Step 7</span></span>
			</li>
		</ol>
	</div>
	<!-- END: PROGRESS BAR -->

	<!-- any success/error messages here -->

	<h2 class="webflow-step-title">Step title</h2>

	<!-- any editorial intro content here -->

	<form id="webflow-form" action="" method="post" enctype="multipart/form-data">
		<!-- specific step rendering here (form fields, for example) -->

		<!-- BEGIN: NAVIGATION BUTTONS -->
		<div class="webflow-action-buttons">
			<div class="webflow-prev-btn-container">
				<a href="" class="btn webflow-btn webflow-prev-btn">Back</a>
			</div>
			<div class="webflow-next-btn-container">
				<button class="btn btn-primary webflow-btn webflow-next-btn" type="submit" default>Next</button>
			</div>
		</div>
		<!-- END: NAVIGATION BUTTONS -->
	</form>
</div>
<!-- END: CONTAINER DIV -->
```

### Baseline CSS

Here is an example LESS file that we are using to style the key elements of the webflow layout:


```css
.webflow-action-buttons {
	&:after {
		clear: both
	}
	&:after, &:before {
		content: " ";
		display: table;
	}

	.webflow-prev-btn-container {
		float: left;
	}

	.webflow-next-btn-container {
		float: right;
	}
}

.webflow-progress-bar {
	.webflow-progress-bar-list {
		display       : block;
		text-align    : justify;
		position      : relative;
		margin-bottom : 20px;
		padding-left  : 0;

		// style the horizontal line of the progress bar
		&:before {
			content    : '';
			height     : 2px;
			width      : auto;
			position   : absolute;
			top        : 14px;
			left       : 0;
			right      : 0;
			z-index    : 0;
			background : @grey-light;

			@media @md {
				left : 40px;
				right: 40px;
			}

			@media @xs-portrait {
				left : 0;
				right: 0;
			}
		}
		&:after {
			content : '';
			display : inline-block;
			width   : 100%;
		}

		// progress bar items should display as dots
		.webflow-progress-bar-item {
			position: relative;
			display: inline-block;
			vertical-align: middle;

			cursor: default;
			background: @link-color;
			list-style-type: none;
			padding: 0;
			margin: 0;

			width: 15px;
			height: 15px;
			.border-radius(100px);

			&:before {
				// reset this, gets set in base styles for li
				content: "";
				display: none;
			}

			// current step has a bigger dot
			&.step-current {
				width: 30px;
				height: 30px;
				cursor: pointer;

				.text {
					font-weight: 700;
				}
			}

			&.step-pending {
				background: @placeholder-color;
			}

			&.step-complete {
				cursor: pointer;
			}

			// do not show the titles
			.webflow-progress-bar-item-text {
				display: none;
			}
		}
	}
}
```