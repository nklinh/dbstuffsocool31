import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;
import java.io.PrintWriter;
import java.io.File;

public class DblpXmlHandler extends DefaultHandler {
  private static final String PUBLICATION_TYPE_FIELD_NAME = "category";
  private static final String ARTICLE_TAG_NAME = "article";
  private static final String BOOK_TAG_NAME = "book";
  private static final String INPROCEEDINGS_TAG_NAME = "inproceedings";
  private static final String INCOLLECTION_TAG_NAME = "incollection";

  private Map<String, PrintWriter> writers;

  private boolean isPublication = false;
  private String currentField;
  private Map<String, String> fieldValues;
  private static final ArrayList<String> fieldNames;
  static {
    fieldNames = new ArrayList<>();
    fieldNames.add(PUBLICATION_TYPE_FIELD_NAME);
    fieldNames.add("key");
    fieldNames.add("mdate");
    fieldNames.add("publtype");
    fieldNames.add("reviewid");
    fieldNames.add("rating");
    fieldNames.add("title");
    fieldNames.add("booktitle");
    fieldNames.add("pages");
    fieldNames.add("year");
    fieldNames.add("address");
    fieldNames.add("journal");
    fieldNames.add("volume");
    fieldNames.add("number");
    fieldNames.add("month");
    fieldNames.add("school");
    fieldNames.add("chapter");
  }

  private static final ArrayList<String> relationFields;
  static {
    relationFields = new ArrayList<>();
    relationFields.add("publisher");
    relationFields.add("author");
    relationFields.add("editor");
    relationFields.add("cite");
    relationFields.add("url");
    relationFields.add("note");
    relationFields.add("isbn");
    relationFields.add("crossref");
  }

  private static final ArrayList<String> tagNames;
  static {
    tagNames = new ArrayList<>();
    tagNames.add(ARTICLE_TAG_NAME);
    tagNames.add(INPROCEEDINGS_TAG_NAME);
    tagNames.add(BOOK_TAG_NAME);
    tagNames.add(INCOLLECTION_TAG_NAME);
  }

  public DblpXmlHandler() {
    fieldValues = new HashMap<>();
    InitializeFiles();
  }

  private void InitializeFiles() {
    writers = new HashMap<>();
    try {
      for (String relationField : relationFields) {
        String filename = relationField + ".csv";
        writers.put(relationField, new PrintWriter(new File(filename)));
      }
      writers.put("publication", new PrintWriter(new File("publication.csv")));
    } catch (Exception e) {
      System.err.println(e.toString());
    }
  }

  @Override
  public void startElement(String uri, String localName, String qName,
    Attributes attributes) throws SAXException {
    if (isPublicationStartTag(qName)) {
      isPublication = true;
      fieldValues.put(PUBLICATION_TYPE_FIELD_NAME, qName);
      for (int i = 0; i < attributes.getLength(); ++i) {
        fieldValues.put(attributes.getQName(i), attributes.getValue(i));
      }
    }
    currentField = qName;
  }

  @Override
  public void endElement(String uri, String localName, String qName) throws SAXException {
    if (isPublicationCloseTag(qName)) {
      isPublication = false;
      flushValues();
    } else {
      if (!isPublication) return;
      String pubKey = fieldValues.get("key");
      for (String relationField : relationFields) {
        if (!qName.equals(relationField)) continue;
        writers.get(relationField).println(String.format("\"%s\", \"%s\"",
          pubKey, escapeQuote(fieldValues.get(relationField))));
        fieldValues.put(relationField, "");
      }
    }
  }

  private boolean isPublicationStartTag(String qName) {
    for (String tagName : tagNames) {
      if (qName.equalsIgnoreCase(tagName)) return true;
    }
    return false;
  }

  private boolean isPublicationCloseTag(String qName) {
    if (isPublicationStartTag(qName)) {
      // Check for consistency: the start tag should also have the same qName.
      if (!qName.equalsIgnoreCase(fieldValues.get(PUBLICATION_TYPE_FIELD_NAME))) {
        throw new RuntimeException("Bad XML");
      }
      return true;
    }
    return false;
  }

  @Override
  public void characters(char ch[], int start, int length) throws SAXException {
    if (!isPublication) return;
    String currentEntry = fieldValues.get(currentField);
    if (currentEntry == null) currentEntry = "";
    currentEntry += new String(ch, start, length);
    fieldValues.put(currentField, currentEntry);
  }

  private void flushValues() {
    PrintWriter out = writers.get("publication");
    int count = 0;
    for (String fieldName : fieldNames) {
      String value = fieldValues.get(fieldName);
      if (value != null) {
        out.print(String.format("\"%s\"", escapeQuote(value)));
      }
      if (count != fieldNames.size()-1) out.print(",");
      ++count;
    }
    out.println();
    fieldValues.clear();
  }

  private String escapeQuote(String line) {
    String result = "";
    for (int i = 0; i < line.length(); ++i) {
      char c = line.charAt(i);
      result += c;
      // Escape the quotation mark.
      if (c == '\"') {
        result += c;
      }
    }
    return result;
  }

  public void close() {
    for (String relationField : relationFields) {
      writers.get(relationField).close();
    }
    writers.get("publication").close();
  }
}