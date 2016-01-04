# Police force register data

The data for the [police-force register](http://police-force.openregister.org), created from 
[data.police.uk](https://data.police.uk/about/) open data maintained by the [Home Office](https://www.gov.uk/government/organisations/home-office).

# Building

Use make to build register shaped data
— we recommend using a [Python virtual environment](http://virtualenvwrapper.readthedocs.org/en/latest/):

    $ mkvirtualenv -p python3 police-data
    $ workon police-data
    $ make init

    $ make

# Licence

The software in this project is covered by LICENSE file.
The data is [© Crown copyright](http://www.nationalarchives.gov.uk/information-management/re-using-public-sector-information/copyright-and-re-use/crown-copyright/)
and available under the terms of the [Open Government 3.0](https://www.nationalarchives.gov.uk/doc/open-government-licence/version/3/) licence.
