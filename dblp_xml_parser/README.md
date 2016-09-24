To compile, do the following:
  javac XmlParser.java

To perform the parsing to CSV, rung the following command:
  java -Djdk.xml.entityExpansionLimit=0 XmlParser path/to/dblp.xml

The header of the CSV file produced can be found in csv-header.txt.