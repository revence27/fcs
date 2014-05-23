XML=fcb.xml

rhema.html: daylight.xml daylight.haml rp.xml rp.haml fcb.xml prefacefcb.haml genrhem.rb rhema.rhtml
	ruby -I. genrhem.rb $(XML)

rhema.js: rhema.coffee
	coffee -cb rhema.coffee

rhema.css: rhema.scss
	sass --update rhema.scss

rhema.pdf: rhema.html rhema.css rhema.js
	prince --server --javascript -s rhema.css --script=rhema.js -o "`ruby rhemname.rb $(XML)`.pdf" rhema.html 2>&1 | ruby tracker.rb

all: rhema.pdf
	echo 'Made all.'

replace:
	make clean test
	cp "`ruby rhemname.rb $(XML)`.pdf" ~/Desktop/Misc/

diapla.html: genrhem.rb diapla.rhtml
	ruby -I. genrhem.rb $(XML)

diapla.css: diapla.scss
	sass --update diapla.scss

koineng: ke.xml diapla.rhtml diapla.html rhema.js diapla.css
	prince --javascript -s diapla.css --script=rhema.js -o "`ruby rhemname.rb $(XML)`.pdf" diapla.html

ke:
	make XML=ke.xml diapla.html
	make XML=ke.xml koineng
	open -apreview "`ruby rhemname.rb ke.xml`.pdf"

lug:
	make XML=lug.xml test

small:
	make XML=tester.xml test

test: all
	open -apreview "`ruby rhemname.rb $(XML)`.pdf"

clean:
	rm -f rhema.css rhema.html rhema.js diapla.html
