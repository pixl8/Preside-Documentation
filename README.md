# PresideCMS documentation source and builder

[![Build Status](https://travis-ci.org/pixl8/Preside-Documentation.svg?branch=master)](https://travis-ci.org/pixl8/Preside-Documentation)

This directory contains the source and build scripts for creating Preside CMS's documentation. The website output of the docs can be found at [http://docs.preside.org](http://docs.preside.org).

## Build locally

### Prerequisites

The only dependency required is [CommandBox](http://www.ortussolutions.com/products/commandbox). Ensure that commandbox is installed and that the `box` command is in your path.

### Install dependencies

From the root of the project, run:

	/Preside-Documentation$ box install

This should pull down the latest version of Preside.

### Build auto generated documentation

We automatically build documentation from Preside's services, data layer, form definitions, etc. To build this documentation, run:

	/Preside-Documentation$ ./generateDocs.sh

### Building the static documentation output

The purpose of the structure of the documentation is to allow a human readable and editable form of documentation that can be built into multiple output formats. At present, we have an "HTML" builder and a "Dash docs" builder, found at `./builders/html` and `./builders/dash` that will build the documentation website and dash docset respectively. The source of the documentation can be found in the `./docs` folder.

To run the build, execute the `build.sh` file found in the root of the project, i.e.

	/Preside-Documentation$ ./build.sh

Once this has finished, you should find `./builds/html` and `./builds/dash` directories with the website content / dash docsets built.

### Running a server locally

We have provided a utility server whose purpose is to run locally to help while developing/writing the documentation. To start it up, execute the `serve.sh` file found in the root of the project, i.e.

    documentation>./serve.sh

This will spin up a server using CommandBox on port 4040 and open it in your browser. You should also see a tray icon that will allow you to stop the server. Changes to the source docs should trigger an internal rebuild of the documentation tree which may take a little longer than regular requests to the documentation.

> Note: there is currently no batch file equivalent for Windows. If you are running on windows, it should be fairly trivial to copy and adapt what is found in the `.sh` file (please let us know if you get this working).

### License

The project is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License](http://creativecommons.org/licenses/by-nc-sa/3.0/).
