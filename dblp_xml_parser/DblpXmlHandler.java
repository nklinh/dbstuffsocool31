import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;

public class DblpXmlHandler extends DefaultHandler {
  private static final String ARTICLE_TAG_NAME = "article";
  private static final String INPROCEEDINGS_TAG_NAME = "inproceedings";
  private static final String PROCEEDINGS_TAG_NAME = "proceedings";
  private static final String BOOK_TAG_NAME = "book";
  private static final String INCOLLECTION_TAG_NAME = "incollection";
  private static final String PHDTHESIS_TAG_NAME = "phdthesis";
  private static final String MASTERSTHESIS_TAG_NAME = "mastersthesis";
  private static final String WWW_TAG_NAME = "www";
  private static final String PUBLICATION_TYPE_FIELD_NAME = "pub_type";

  private boolean isPublication = false;
  private String currentField;
  private Map<String, String> fieldValues;
  private static final ArrayList<String> fieldNames;
  static {
    fieldNames = new ArrayList<>();
    fieldNames.add("author");
    fieldNames.add("editor");
    fieldNames.add("title");
    fieldNames.add("booktitle");
    fieldNames.add("pages");
    fieldNames.add("year");
    fieldNames.add("address");
    fieldNames.add("journal");
    fieldNames.add("volume");
    fieldNames.add("number");
    fieldNames.add("month");
    fieldNames.add("url");
    fieldNames.add("ee");
    fieldNames.add("cdrom");
    fieldNames.add("cite");
    fieldNames.add("publisher");
    fieldNames.add("note");
    fieldNames.add("crossref");
    fieldNames.add("isbn");
    fieldNames.add("series");
    fieldNames.add("school");
    fieldNames.add("chapter");
    fieldNames.add("key");
    fieldNames.add("mdate");
    fieldNames.add("publtype");
    fieldNames.add("reviewid");
    fieldNames.add("rating");
  }
  private static final ArrayList<String> tagNames;
  static {
    tagNames = new ArrayList<>();
    tagNames.add(ARTICLE_TAG_NAME);
    tagNames.add(INPROCEEDINGS_TAG_NAME);
    tagNames.add(PROCEEDINGS_TAG_NAME);
    tagNames.add(BOOK_TAG_NAME);
    tagNames.add(INCOLLECTION_TAG_NAME);
    tagNames.add(PHDTHESIS_TAG_NAME);
    tagNames.add(MASTERSTHESIS_TAG_NAME);
    tagNames.add(WWW_TAG_NAME);
  }

  public DblpXmlHandler() {
    fieldValues = new HashMap<>();
  }

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

  public void endElement(String uri, String localName, String qName) throws SAXException {
    if (isPublicationCloseTag(qName)) {
      isPublication = false;
      flushValues();
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

  public void characters(char ch[], int start, int length) throws SAXException {
    if (!isPublication) return;
    fieldValues.put(currentField, new String(ch, start, length));
  }

  private void flushValues() {
    System.out.print(String.format("%s", fieldValues.get(PUBLICATION_TYPE_FIELD_NAME)));
    for (String fieldName : fieldNames) {
      System.out.print(",");
      String value = fieldValues.get(fieldName);
      if (value != null) {
        System.out.print(String.format("\"%s\"", value));
      }
    }
    System.out.println();
    fieldValues.clear();
  }
}