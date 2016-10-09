To compile, do the following:
  javac XmlParser.java

To perform the parsing to CSV, rung the following command:
  java -Djdk.xml.entityExpansionLimit=0 XmlParser path/to/dblp.xml

The header of the CSV file produced can be found in csv-header.txt.


Update:
To cut down the entries in the CSV produced, run the following command:
  java -Djdk.xml.entityExpansionLimit=0 XmlParser path/to/dblp.xml <hashMod> <acceptHash>
where only publication entries with entryId % hashMod == acceptHash will be parsed into the CSV files. For example:
  java -Djdk.xml.entityExpansionLimit=0 XmlParser path/to/dblp.xml 2 0
will cut down the CSV size in half, only parsing XML publication entries for which entryId % 2 == 0.