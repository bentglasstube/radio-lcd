PHONY: install deps files

install: deps files

deps: cpanfile
	cpanm --installdeps .

files: 99-lcd.rules radio-lcd.service lib/* driver
	install -m 0644 99-lcd.rules /etc/udev/rules.d/
	install -m 0644 radio-lcd.service /etc/systemd/system/
	install -d /usr/local/lib/radio-lcd/lib/
	install -m 0755 driver /usr/local/lib/radio-lcd/
	install -m 0644 lib/* /usr/local/lib/radio-lcd/lib/
