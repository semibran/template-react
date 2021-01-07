# GNU Make 3.8.2 and above

MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:

PATH := $(PWD)/node_modules/.bin:$(PATH)
SHELL := /bin/bash

all: clean assets
	esbuild src/index.js --bundle --minify --define:process.env.NODE_ENV=\"production\" --loader:.js=jsx > tmp/app.bundle.js
	tsc tmp/app.bundle.js --allowJs --lib DOM,ES2015 --target ES5 --outFile tmp/app.bundle.es5.js
	uglifyjs tmp/app.bundle.es5.js --toplevel -m -c drop_console=true,passes=3 > dist/index.js
	sass src/style.scss dist/style.css
	cleancss dist/style.css -o dist/style.css
	html-minifier --collapse-whitespace src/index.html -o dist/index.html
	rm dist/*.map

watch: clean js css html assets
	chokidar "src/**/*.js" -c "make js" \
	& chokidar "src/*.scss" -c "make css" \
	& chokidar "src/*.html" -c "make html" \
	& chokidar "src/assets/*" -c "make assets" \

clean:
	rm -rf dist
	mkdir -p {tmp,dist/assets}

html:
	cp src/index.html dist/index.html

css:
	sass src/style.scss dist/style.css

js:
	esbuild src/index.js --bundle --sourcemap --define:process.env.NODE_ENV=\"dev\" --loader:.js=jsx --outfile=dist/index.js

assets:
	cp src/assets/* dist/assets
