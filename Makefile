#
#  generate openregister entries from police force data
#
#  https://data.police.uk/docs/method/forces/
#
FORCES_URL=https://data.police.uk/api/forces

.PHONY: init test all clean data

all:	flake8 data

data:	data/police-force/police-force.tsv

data/police-force/police-force.tsv:	cache/forces.json bin/forces.py
	@mkdir -p data/police-force
	bin/forces.py < cache/forces.json > $@

cache/forces.json:
	mkdir -p cache
	curl -s $(FORCES_URL) > $@

flake8:
	flake8 bin

test:
	py.test -v

clean:
	find . -name "*.pyc" | xargs rm -f
	find . -name "__pycache__" | xargs rm -rf
	rm -rf cache
	rm -rf data

init:
	pip3 install --upgrade -r requirements.txt
