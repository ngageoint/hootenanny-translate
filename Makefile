
SHELL=/bin/bash

# If you're adding another schema file be sure and update the archive target
# too.
# NOTE: This is the list that gets deleted in "make clean"
SCHEMA_FILES=tds61_schema.js tds61_full_schema.js etds61_rules.js etds61_osm_rules.js tds40_schema.js tds40_full_schema.js etds40_rules.js etds40_osm_rules.js mgcp_schema.js emgcp_rules.js emgcp_osm_rules.js ggdm30_schema.js ggdm30_full_schema.js eggdm30_rules.js eggdm30_osm_rules.js tds70_schema.js tds70_full_schema.js etds70_rules.js etds70_osm_rules.js

default: build

all: build
always:

# build: $(SCHEMA_FILES) config.js
build: $(SCHEMA_FILES)

# 	rm -f config.js
clean:
	rm -f *.pyc
	rm -f $(SCHEMA_FILES)

clean-all: clean

check: test
test: translations-test

licenses:
	scripts/copyright/UpdateAllCopyrightHeaders.sh

translations-test: build
ifneq ($(shell which mocha),)
	cd translations-nodejs/test; npm install && npm test
else
	@echo Skipping mocha tests
endif

# config.js: conf/core/ConfigOptions.asciidoc scripts/core/CreateJsConfigCode.py
# 	python scripts/core/CreateJsConfigCode.py conf/core/ConfigOptions.asciidoc config.js

# We now have different versions of the NFDD Schema that are built from Excel files:
# LTDSv40.csv.gz - Local TDS v4.0
# SUTDSv40.csv.gz - Specialized Urban TDS v4.0
# TDSv40.csv.gz - Full TDS v4.0
# The default is to use the LTDSv40 file so we can append to existing LTDS templates
#
# The MGCP schema is built from an XML file
#
# The Macro's are for Jason :-)

##### MGCP
# Build the MGCP schema
mgcp_schema.js: scripts/ConvertMGCPSchema_XML.py conf/MGCP_FeatureCatalogue_TRD4_v4.5_20190208.xml.gz
	mkdir -p $(@D)
	$^ > $@ || (rm -f $@ ; exit -1)

# Build the MGCP  "To English" rules
emgcp_rules.js: scripts/ConvertMGCPSchema_XML.py conf/MGCP_FeatureCatalogue_TRD4_v4.5_20190208.xml.gz
	mkdir -p $(@D)
	$< --toenglish $(word 2,$^) > $@ || (rm -f $@ ; exit -1)

# Build the MGCP "From English" rules
emgcp_osm_rules.js: scripts/ConvertMGCPSchema_XML.py conf/MGCP_FeatureCatalogue_TRD4_v4.5_20190208.xml.gz
	mkdir -p $(@D)
	$< --fromenglish $(word 2,$^) > $@ || (rm -f $@ ; exit -1)
#	$< --fromenglish $(word 2,$^) $(word 3,$^) > $@ || (rm -f $@ ; exit -1)

#### TDSv40
tds40_schema.js: scripts/ConvertTDSv40Schema.py conf/TDSv40.csv.gz
	mkdir -p $(@D)
	$^ > $@ || (rm -f $@ ; exit -1)

tds40_full_schema.js: scripts/ConvertTDSv40Schema.py conf/TDSv40.csv.gz
	mkdir -p $(@D)
	$< --fullschema $(word 2,$^) > $@ || (rm -f $@ ; exit -1)

# Build the TDS40 "To English" rules
# This need to be full TDS so we have access to the full range of attributes
etds40_rules.js: scripts/ConvertTDSv40Schema.py conf/TDSv40.csv.gz
	mkdir -p $(@D)
	$< --toenglish $(word 2,$^) > $@ || (rm -f $@ ; exit -1)

# Build the TDS40 "From English" rules
etds40_osm_rules.js: scripts/ConvertTDSv40Schema.py conf/TDSv40.csv.gz
	mkdir -p $(@D)
	$< --fromenglish $(word 2,$^) > $@ || (rm -f $@ ; exit -1)
#	$< --fromenglish $(word 2,$^) $(word 3,$^) > $@ || (rm -f $@ ; exit -1)

#### TDSv61
# TDSv61 is built from the TDSv60 spec with NGA's extensions
tds61_schema.js: scripts/ConvertTDSv61Schema.py conf/TDSv60.csv.gz conf/TDS_NGAv01.csv.gz
	mkdir -p $(@D)
	$< $(word 2,$^) $(word 3,$^) > $@ || (rm -f $@ ; exit -1)

# TDSv61 full schema is built from the TDSv60 spec with NGA's extensions.
# This one has all of the Text Enumerations
tds61_full_schema.js: scripts/ConvertTDSv61Schema.py conf/TDSv60.csv.gz conf/TDS_NGAv01.csv.gz
	mkdir -p $(@D)
	$< --fullschema $(word 2,$^) $(word 3,$^) > $@ || (rm -f $@ ; exit -1)

# Build the TDS61 "To English" rules
etds61_rules.js: scripts/ConvertTDSv61Schema.py conf/TDSv60.csv.gz conf/TDS_NGAv01.csv.gz
	mkdir -p $(@D)
	$< --toenglish $(word 2,$^) $(word 3,$^) > $@ || (rm -f $@ ; exit -1)

# Build the TDS61 "From English" rules
etds61_osm_rules.js: scripts/ConvertTDSv61Schema.py conf/TDSv60.csv.gz conf/TDS_NGAv01.csv.gz
	mkdir -p $(@D)
	$< --fromenglish $(word 2,$^) $(word 3,$^) > $@ || (rm -f $@ ; exit -1)

#### TDSv70
# TDSv70 schema is built from an XML file made from a sample FGDB
#tds70_schema.js: scripts/ConvertTDSv70Schema_XML.py conf/TDSv70.xml.gz conf/TDSv70.xml.gz
tds70_schema.js: scripts/ConvertTDSv70Schema.py conf/TDSv70_Features.csv.gz conf/TDSv70_Values.csv.gz
	mkdir -p $(@D)
	$^ > $@ || (rm -f $@ ; exit -1)

# TDSv70 full schema is built from an XML file made from a sample FGDB
# This one has all of the Text Enumerations
#tds70_full_schema.js: scripts/ConvertTDSv70Schema_XML.py conf/TDSv70.xml.gz
tds70_full_schema.js: scripts/ConvertTDSv70Schema.py conf/TDSv70_Features.csv.gz conf/TDSv70_Values.csv.gz
	mkdir -p $(@D)
	$< --fullschema $(word 2,$^) $(word 3,$^) > $@ || (rm -f $@ ; exit -1)

# Build the TDS70 "To English" rules
#etds70_rules.js: scripts/ConvertTDSv70Schema_XML.py conf/TDSv70.xml.gz
etds70_rules.js: scripts/ConvertTDSv70Schema.py conf/TDSv70_Features.csv.gz conf/TDSv70_Values.csv.gz
	mkdir -p $(@D)
	$< --toenglish $(word 2,$^) $(word 3,$^) > $@ || (rm -f $@ ; exit -1)

# Build the TDS70 "From English" rules
#etds70_osm_rules.js: scripts/ConvertTDSv70Schema_XML.py conf/TDSv70.xml.gz
etds70_osm_rules.js: scripts/ConvertTDSv70Schema.py conf/TDSv70_Features.csv.gz conf/TDSv70_Values.csv.gz
	mkdir -p $(@D)
	$< --fromenglish $(word 2,$^) $(word 3,$^) > $@ || (rm -f $@ ; exit -1)

#### GGDMv30
# GGDMv30 is built from the GGDMv30 spec with additional layers and values files
ggdm30_schema.js: scripts/ConvertGGDMv30Schema.py conf/GGDM30_Features.csv.gz conf/GGDM30_Layers.csv.gz conf/GGDM30_Values.csv.gz
	mkdir -p $(@D)
	$< $(word 2,$^) $(word 3,$^) $(word 4,$^) > $@ || (rm -f $@ ; exit -1)

# GGDMv30 full schema
# This one has all of the Text Enumerations
ggdm30_full_schema.js:  scripts/ConvertGGDMv30Schema.py conf/GGDM30_Features.csv.gz conf/GGDM30_Layers.csv.gz conf/GGDM30_Values.csv.gz
	mkdir -p $(@D)
	$< --fullschema $(word 2,$^) $(word 3,$^) $(word 4,$^) > $@ || (rm -f $@ ; exit -1)

# Build the GGDMv30 "To English" rules
eggdm30_rules.js:  scripts/ConvertGGDMv30Schema.py conf/GGDM30_Features.csv.gz conf/GGDM30_Layers.csv.gz conf/GGDM30_Values.csv.gz
	mkdir -p $(@D)
	$< --toenglish $(word 2,$^) $(word 3,$^) $(word 4,$^) > $@ || (rm -f $@ ; exit -1)

# Build the GGDMv30 "From English" rules
eggdm30_osm_rules.js:  scripts/ConvertGGDMv30Schema.py conf/GGDM30_Features.csv.gz conf/GGDM30_Layers.csv.gz conf/GGDM30_Values.csv.gz
	mkdir -p $(@D)
	$< --fromenglish $(word 2,$^) $(word 3,$^) $(word 4,$^) > $@ || (rm -f $@ ; exit -1)


HOOT_TARNAME=hootenanny-translations-$(HOOT_VERSION)
dist: archive
archive: build
	rm -f $(HOOT_TARNAME).tar.gz
	scripts/git/git-archive-all.sh --prefix $(HOOT_TARNAME)/ $(HOOT_TARNAME).tar
	# Copy the auto-generated schema definitions. This eases another dependency on CentOS
	mkdir -p $(HOOT_TARNAME)/
	# TDSv40
	cp tds40_schema.js $(HOOT_TARNAME)/tds40_schema.js
	cp tds40_full_schema.js $(HOOT_TARNAME)/tds40_full_schema.js
	cp etds40_rules.js $(HOOT_TARNAME)/etds40_osm_rules.js
	cp etds40_osm_rules.js $(HOOT_TARNAME)/etds40_osm_rules.js
	# TDSv61
	cp tds61_schema.js $(HOOT_TARNAME)/tds61_schema.js
	cp tds61_full_schema.js $(HOOT_TARNAME)/tds61_full_schema.js
	cp etds61_rules.js $(HOOT_TARNAME)/etds61_rules.js
	cp etds61_osm_rules.js $(HOOT_TARNAME)/etds61_osm_rules.js
	# TDSv70
	cp tds70_schema.js $(HOOT_TARNAME)/tds70_schema.js
	cp tds70_full_schema.js $(HOOT_TARNAME)/tds70_full_schema.js
	cp etds70_rules.js $(HOOT_TARNAME)/etds70_rules.js
	cp etds70_osm_rules.js $(HOOT_TARNAME)/etds70_osm_rules.js
	# MGCP
	cp mgcp_schema.js $(HOOT_TARNAME)/mgcp_schema.js
	cp emgcp_rules.js $(HOOT_TARNAME)/emgcp_rules.js
	cp emgcp_osm_rules.js $(HOOT_TARNAME)/emgcp_osm_rules.js
	# GGDMv30
	cp ggdm30_schema.js $(HOOT_TARNAME)/ggdm30_schema.js
	cp ggdm30_full_schema.js $(HOOT_TARNAME)/ggdm30_full_schema.js
	cp eggdm30_rules.js $(HOOT_TARNAME)/eggdm30_osm_rules.js
	cp eggdm30_osm_rules.js $(HOOT_TARNAME)/eggdm30_osm_rules.js
	# Don't include RF files at this time, to speed up archive
	#mkdir -p $(HOOT_TARNAME)/conf/models/
	#cp conf/models/BuildingModel.rf $(HOOT_TARNAME)/conf/models/BuildingModel.rf
	#cp conf/models/HighwayModel.rf $(HOOT_TARNAME)/conf/models/HighwayModel.rf
	#cp conf/models/PoiModel.rf $(HOOT_TARNAME)/conf/models/PoiModel.rf
	# Create the version file
	echo $(HOOT_VERSION) > $(HOOT_TARNAME)/version
	# tar the file and zip it
	tar rf $(HOOT_TARNAME).tar $(HOOT_TARNAME)/*
	rm -rf $(HOOT_TARNAME)
	gzip -9 $(HOOT_TARNAME).tar

