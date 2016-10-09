import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.helpers.DefaultHandler;

public class XmlParser {
public static void main(String[] args) {
    try {
      SAXParserFactory factory = SAXParserFactory.newInstance();
      SAXParser saxParser = factory.newSAXParser();
      int hashMod = DblpXmlHandler.NO_HASH;
      int acceptHash = DblpXmlHandler.ACCEPT_ALL;
      if (args.length == 3) {
        hashMod = Integer.parseInt(args[1]);
        acceptHash = Integer.parseInt(args[2]);
      }
      DblpXmlHandler handler = new DblpXmlHandler(hashMod, acceptHash);
      double startTime = System.currentTimeMillis();
      saxParser.parse(args[0], handler);
      handler.close();
      double endTime = System.currentTimeMillis();
      System.out.println(String.format("Time elapsed: %.3f s\n", (endTime - startTime) / 1000));
    } catch (Exception e) {
      System.err.println(e.toString());
    }
  }
}